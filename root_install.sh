#!/system/bin/sh
# Surfing 免模块安装脚本：直接用 root 权限安装，不经过 Magisk / KernelSU / APatch 管理器
#
# 用法（任选其一）：
#   su -c sh root_install.sh /sdcard/Download/Surfing_v7.8.4_release.zip
#   su -c sh root_install.sh            # 在解压后的 release 目录中执行
#
# 选项：
#   --hosts      挂载 box_bll/clash/etc/hosts 到 /system/etc/hosts（会留下 bind mount 痕迹，默认不挂载）
#   --app        安装 SurfingTile App（App 内的启停开关依赖模块目录，免模块方式下不可用）
#   --no-start   安装后不立即启动（开机仍会自动启动，可用 surfing start 启动）

BOX_BLL_PATH="/data/adb/box_bll"
BIN_PATH="$BOX_BLL_PATH/bin"
SCRIPTS_PATH="$BOX_BLL_PATH/scripts"
SWITCH_DIR="$BOX_BLL_PATH/switch"
CONFIG_FILE="$BOX_BLL_PATH/clash/config.yaml"
BACKUP_FILE="$BOX_BLL_PATH/clash/proxies/subscribe_urls_backup.txt"
HOSTS_PATH="$BOX_BLL_PATH/clash/etc"
HOSTS_FILE="$HOSTS_PATH/hosts"
STAGE="/data/local/tmp/surfing_root_stage"

MOUNT_HOSTS=false
INSTALL_APP=false
START_NOW=true
SRC=""

for arg in "$@"; do
  case "$arg" in
    --hosts) MOUNT_HOSTS=true ;;
    --app) INSTALL_APP=true ;;
    --no-start) START_NOW=false ;;
    -*) echo "未知选项: $arg"; exit 1 ;;
    *) SRC="$arg" ;;
  esac
done

ui_print() { echo "$@"; }
abort() { echo "错误: $*"; rm -rf "$STAGE"; exit 1; }

[ "$(id -u)" = 0 ] || abort "需要 root 权限，请使用: su -c sh $0"

for d in /data/adb/modules/Surfing /data/adb/lite_modules/Surfing; do
  [ -d "$d" ] && abort "检测到已安装模块版 Surfing ($d)，请先在管理器中卸载模块并重启"
done

# ---------- 准备安装源 ----------
rm -rf "$STAGE"
mkdir -p "$STAGE"
if [ -z "$SRC" ]; then
  SRC=$(cd "$(dirname "$0")" && pwd)
fi
if [ -f "$SRC" ]; then
  command -v unzip >/dev/null 2>&1 || abort "系统缺少 unzip 命令，请先在电脑上解压后再执行"
  unzip -qo "$SRC" -x 'META-INF/*' -d "$STAGE" || abort "解压失败: $SRC"
elif [ -d "$SRC/box_bll" ]; then
  cp -rf "$SRC/." "$STAGE/"
else
  abort "找不到安装文件，请指定 release zip 路径或在解压目录中执行"
fi
[ -d "$STAGE/box_bll" ] && [ -f "$STAGE/Surfing_service.sh" ] || abort "安装包内容不完整"
[ -f "$STAGE/box_bll/bin/clash" ] || abort "安装包缺少内核 box_bll/bin/clash，请使用 release 构建产物"

VERSION=$(grep '^version=' "$STAGE/module.prop" 2>/dev/null | cut -d'=' -f2-)
ui_print "Surfing 免模块安装 ${VERSION}"

# ---------- 去模块化补丁（兼容官方原版 zip）----------
# 原版用 /data/adb/modules/Surfing/disable 作为服务开关，这里改为 $SWITCH_DIR/disable
patch_module_dir() {
  f="$1"
  [ -f "$f" ] || return 0
  sed -i \
    -e '/magisk -v | grep -q lite && module_dir=/d' \
    -e "s|^module_dir=\"/data/adb/modules/Surfing\"|module_dir=\"$SWITCH_DIR\"|" \
    -e '/^BASE_MODULES_DIR=/d' \
    -e '/BASE_MODULES_DIR="\/data\/adb\/lite_modules"/d' \
    -e "s|^SURFING_DIR=\"\${BASE_MODULES_DIR}/Surfing\"|SURFING_DIR=\"$SWITCH_DIR\"|" \
    "$f"
  if grep -qE '/data/adb/(lite_)?modules|BASE_MODULES_DIR' "$f"; then
    abort "上游脚本结构已变化，无法自动去模块化: ${f#$STAGE/}"
  fi
}
patch_module_dir "$STAGE/box_bll/scripts/start.sh"
patch_module_dir "$STAGE/box_bll/scripts/ctr.inotify"
patch_module_dir "$STAGE/Surfing_service.sh"

# ---------- service.d 目录 ----------
service_dir="/data/adb/service.d"
[ ! -d "$service_dir" ] && [ -d /data/adb/ksu/service.d ] && service_dir="/data/adb/ksu/service.d"
mkdir -p "$service_dir"

# ---------- 工具函数（与 customize.sh 保持一致）----------
init_busybox_toolchain() { chmod 755 "$BIN_PATH/busybox" && (cd "$BIN_PATH" && find . -type l -delete && ./busybox --install -s .); }

set_perm_recursive() {
  # $1 路径 $2 uid $3 gid $4 目录权限 $5 文件权限
  chown -R "$2:$3" "$1"
  find "$1" -type d -exec chmod "$4" {} +
  find "$1" -type f -exec chmod "$5" {} +
}

extract_subscribe_urls() {
  if [ -f "$CONFIG_FILE" ]; then
    mkdir -p "$(dirname "$BACKUP_FILE")"
    sed -n '/# 订阅地址相关/,/profile:.*↑/p' "$CONFIG_FILE" > "$BACKUP_FILE"
    if [ -s "$BACKUP_FILE" ]; then
      ui_print "已备份订阅配置."
    else
      ui_print "未找到订阅块.将使用默认值."
    fi
  fi
}

restore_subscribe_urls() {
  if [ -f "$BACKUP_FILE" ] && [ -s "$BACKUP_FILE" ]; then
    awk -v backup="$BACKUP_FILE" '
      BEGIN { skip = 0 }
      /# 订阅地址相关/ {
        skip = 1
        while ((getline < backup) > 0) { print }
        close(backup)
        next
      }
      /profile:.*↑/ {
        skip = 0
        next
      }
      !skip { print }
    ' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    ui_print "已恢复订阅配置."
  fi
}

migrate_box_config() {
  OLD_CONFIG="$SCRIPTS_PATH/box.config.bak"; NEW_CONFIG="$SCRIPTS_PATH/box.config"
  [ -f "$OLD_CONFIG" ] || return 0
  ui_print "正在迁移网络服务控制设置..."
  TMP_CONFIG="${NEW_CONFIG}.tmp"; cp -f "$NEW_CONFIG" "$TMP_CONFIG"
  VARS="enable_network_service_control bypass_via_iptables enable_cellular_proxy enable_wifi_proxy enable_ssid_filter enable_mac_filter use_wifi_list_mode blacklist_wifi_macs whitelist_wifi_macs blacklist_wifi_ssids whitelist_wifi_ssids ap_list gid_list user_packages_list proxy_mode proxy_method ipv6"
  for var in $VARS; do
    val=$(grep "^${var}=" "$OLD_CONFIG" | cut -d'=' -f2-)
    [ -n "$val" ] && sed "s@^${var}=.*@${var}=${val}@" "$TMP_CONFIG" > "${TMP_CONFIG}.bak" && mv -f "${TMP_CONFIG}.bak" "$TMP_CONFIG"
  done
  mv -f "$TMP_CONFIG" "$NEW_CONFIG"
}

kill_watchers() {
  for pid in $(pidof inotifyd); do
    grep -qE "box.inotify|net.inotify|ctr.inotify" "/proc/$pid/cmdline" 2>/dev/null && kill "$pid"
  done
}

stop_running_service() {
  [ -x "$SCRIPTS_PATH/box.iptables" ] && "$SCRIPTS_PATH/box.iptables" disable >/dev/null 2>&1
  [ -x "$SCRIPTS_PATH/box.service" ] && "$SCRIPTS_PATH/box.service" stop >/dev/null 2>&1
}

install_surfingtile_apk() {
  [ -f "$STAGE/SurfingTile.zip" ] || { ui_print "安装包中没有 SurfingTile，跳过."; return 0; }
  APK_TMP="/data/local/tmp/com.github.surfing.apk"
  unzip -o "$STAGE/SurfingTile.zip" "com.github.surfing.apk" -d /data/local/tmp >/dev/null 2>&1
  if [ -f "$APK_TMP" ]; then
    ui_print "正在安装 SurfingTile APK..."
    pm install "$APK_TMP"
    rm -f "$APK_TMP"
  fi
}

# ---------- 安装 / 更新 ----------
kill_watchers
if [ -d "$BOX_BLL_PATH" ]; then
  ui_print "检测到已有安装，正在更新..."
  stop_running_service
  export PATH="$BIN_PATH:$PATH"

  cp -f "$STAGE/box_bll/bin/busybox" "$BIN_PATH/busybox" && init_busybox_toolchain
  cp -f "$STAGE/box_bll/bin/curl" "$BIN_PATH/curl" 2>/dev/null
  cp -f "$STAGE/box_bll/bin/clash" "$BIN_PATH/clash"
  extract_subscribe_urls

  cp -f "$CONFIG_FILE" "$CONFIG_FILE.bak"
  cp -f "$STAGE/box_bll/clash/config.yaml" "$BOX_BLL_PATH/clash/"

  cp -f "$SCRIPTS_PATH/box.config" "$SCRIPTS_PATH/box.config.bak"
  cp -f "$STAGE/box_bll/scripts/"* "$SCRIPTS_PATH/"
  migrate_box_config
  restore_subscribe_urls
  ui_print "已备份: config.yaml.bak / box.config.bak"
else
  ui_print "正在安装..."
  cp -rf "$STAGE/box_bll" /data/adb/
  init_busybox_toolchain
fi

mkdir -p "$HOSTS_PATH" "$SWITCH_DIR"
if [ "$MOUNT_HOSTS" = true ]; then
  [ -f "$HOSTS_FILE" ] || cp -f "$STAGE/box_bll/clash/etc/hosts" "$HOSTS_FILE"
  ui_print "将挂载 hosts 文件."
else
  umount -l /system/etc/hosts >/dev/null 2>&1
  rm -f "$HOSTS_FILE"
  ui_print "不挂载 hosts 文件."
fi

cp -f "$STAGE/Surfing_service.sh" "$service_dir/Surfing_service.sh"

set_perm_recursive "$BOX_BLL_PATH" 0 3005 0755 0644
set_perm_recursive "$SCRIPTS_PATH" 0 3005 0755 0700
set_perm_recursive "$BIN_PATH" 0 0 0755 0755
set_perm_recursive "$HOSTS_PATH" 0 0 0755 0644
chown 0:0 "$service_dir/Surfing_service.sh"
chmod 0700 "$service_dir/Surfing_service.sh"
chmod ugo+x "$SCRIPTS_PATH/"*

[ "$INSTALL_APP" = true ] && install_surfingtile_apk
rm -rf "$STAGE"

# ---------- 启动 ----------
if [ "$START_NOW" = true ]; then
  rm -f "$SWITCH_DIR/disable"
  ui_print "正在启动服务..."
else
  touch "$SWITCH_DIR/disable"
  ui_print "已安装但未启动，启动请执行: su -c $SCRIPTS_PATH/surfing start"
fi
# 与开机流程相同：由 service.d 脚本拉起服务和监听进程
nohup sh "$service_dir/Surfing_service.sh" >/dev/null 2>&1 &

ui_print ""
ui_print "安装完成."
ui_print "  配置文件: $CONFIG_FILE"
ui_print "  控制命令: su -c $SCRIPTS_PATH/surfing start|stop|restart|status"
ui_print "  卸载:     su -c sh $SCRIPTS_PATH/root_uninstall.sh"
