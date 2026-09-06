#!/bin/sh

SKIPUNZIP=1
ASH_STANDALONE=1
MIN_KSU_VER=10670; KSU_DIR_VER=10683
LANG_EN=false

CURRENT_MODULES_DIR="/data/adb/modules"
magisk -v | grep -q lite && CURRENT_MODULES_DIR="/data/adb/lite_modules"

SURFING_PATH="$CURRENT_MODULES_DIR/Surfing"
BOX_BLL_PATH="/data/adb/box_bll"
BIN_PATH="$BOX_BLL_PATH/bin"

SCRIPTS_PATH="$BOX_BLL_PATH/scripts"
NET_PATH="/data/misc/net"
CTR_PATH="/data/misc/net/rt_tables"
CONFIG_FILE="$BOX_BLL_PATH/clash/config.yaml"
BACKUP_FILE="$BOX_BLL_PATH/clash/proxies/subscribe_urls_backup.txt"
INSTALL_DIR="/data/app"
HOSTS_FILE="$BOX_BLL_PATH/clash/etc/hosts"
HOSTS_PATH="$BOX_BLL_PATH/clash/etc"
HOSTS_BACKUP="$BOX_BLL_PATH/clash/etc/hosts.bak"
SURFING_TILE_ZIP="$MODPATH/SurfingTile.zip"
MODULE_PROP_PATH="$CURRENT_MODULES_DIR/Surfing/module.prop"
MODULE_VERSION_CODE=0

[ -f "$MODULE_PROP_PATH" ] && MODULE_VERSION_CODE=$(awk -F'=' '/versionCode/ {print $2}' "$MODULE_PROP_PATH")

[ "$MODULE_VERSION_CODE" -lt 1653 ] && INSTALL_TILE=true || INSTALL_TILE=false

[ "$BOOTMODE" != true ] && abort "Error: Please install via Magisk Manager / KernelSU Manager / APatch"; [ "$KSU" = true ] && [ "$KSU_VER_CODE" -lt "$MIN_KSU_VER" ] && abort "Error: Please update your KernelSU Manager version"; [ "$KSU" = true ] && [ "$KSU_VER_CODE" -lt "$KSU_DIR_VER" ] && service_dir="/data/adb/ksu/service.d" || service_dir="/data/adb/service.d"

[ ! -d "$service_dir" ] && mkdir -p "$service_dir"; unzip -qo "${ZIPFILE}" -x 'META-INF/*' -d "$MODPATH"

init_busybox_toolchain() { chmod 755 "$BIN_PATH/busybox" && (cd "$BIN_PATH" && find . -type l -delete && ./busybox --install -s .); }

run_watch() { nohup inotifyd "${SCRIPTS_PATH}/$1" "$2" >/dev/null 2>&1 & }

print_lang() { [ "$LANG_EN" = true ] && ui_print "$2" || ui_print "$1"; }

choose_volume_key() {
  timeout_seconds=10
  line=$(timeout $timeout_seconds getevent -ql | awk '/KEY_VOLUME/ {print; exit}')
  if [ -z "$line" ]; then
      print_lang "未检测到输入，执行默认操作..." "No input detected. Running default option..."
      return 1
  fi
  if echo "$line" | grep -q "KEY_VOLUMEUP"; then
      return 0
  else
      return 1
  fi
}

choose_language() {
  ui_print "*********************************"
  ui_print "请选择安装日志语言 / Choose language:"
  ui_print "音量上键 / Vol Up: 中文 (Chinese)"
  ui_print "音量下键 / Vol Down: English"
  ui_print "*********************************"
  ui_print "请在 10 秒内按下音量键 / Please press Vol Key in 10s..."
  if choose_volume_key; then
    LANG_EN=false
    ui_print "已选择: 中文"
  else
    LANG_EN=true
    ui_print "Selected: English"
  fi
  ui_print " "
}

extract_subscribe_urls() {
  if [ -f "$CONFIG_FILE" ]; then
    sed -n '/# 订阅地址相关/,/profile:.*↑/p' "$CONFIG_FILE" > "$BACKUP_FILE"
    
    if [ -s "$BACKUP_FILE" ]; then
      print_lang "已备份订阅配置." "Backed up subscription configuration."
    else
      print_lang "未找到订阅块.将使用默认值." "No subscription block found. Using default."
    fi
  else
    print_lang "配置文件丢失.无法提取订阅." "Config file missing. Cannot extract subscriptions."
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
    print_lang "已恢复订阅配置." "Restored subscription configuration."
  else
    print_lang "未找到有效备份.跳过恢复操作." "No valid backup found. Skipped restore."
  fi
}

install_surfingtile_apk() {
  APK_TMP="$INSTALL_DIR/com.github.surfing.apk"
  rm -f "$APK_TMP"
  unzip -o "$SURFING_TILE_ZIP" "com.github.surfing.apk" -d "$INSTALL_DIR" >/dev/null 2>&1
  if [ -f "$APK_TMP" ]; then
    print_lang "正在安装 SurfingTile APK..." "Installing Surfingtile APK..."
    pm install "$APK_TMP"
    rm -f "$APK_TMP"
  else
    print_lang "未找到 SurfingTile APK 文件." "Surfingtile APK not found."
  fi
}

sync_version_from_module_prop() {
  dst_prop="$CURRENT_MODULES_DIR/Surfing/module.prop"
  if [ -f "$MODPATH/module.prop" ] && [ -d "$CURRENT_MODULES_DIR/Surfing" ]; then
    cp -f "$MODPATH/module.prop" "$dst_prop"
  fi
}

choose_to_umount_hosts_file() {
  print_lang "是否挂载 hosts 文件到系统？" "Mount the hosts file to the system?"
  print_lang "音量上键: 挂载" "Volume Up: Mount"
  print_lang "音量下键: 卸载 (恢复默认)" "Volume Down: Uninstall default"
  print_lang "请等待输入 (10s)..." "Waiting for input (10s)..."
  if choose_volume_key; then
    print_lang "Hosts 文件已挂载." "Hosts file mounted."
  else
    print_lang "Hosts 文件卸载完成." "Uninstalling hosts file is complete."
    rm -f "$HOSTS_FILE"
  fi
}

choose_to_restore_config() {
  if pm path "com.github.surfing" >/dev/null 2>&1; then
    ui_print " "
    print_lang "检测到已安装 SurfingTile APP..." "SurfingTile APP detected..."
    print_lang "是否需要通过 APP 恢复 Clash 配置文件？" "Do you need to restore Clash config via APP?"
    print_lang "音量上键: 是 (恢复)" "Volume Up: Yes (Restore)"
    print_lang "音量下键: 否 (跳过)" "Volume Down: No (Skip)"
    print_lang "请等待输入 (10s)..." "Waiting for input (10s)..."
    
    if choose_volume_key; then
      print_lang "正在拉起 APP 恢复配置..." "Waking up APP to restore config..."
      am broadcast -a com.github.surfing.ACTION_SAVE_CONFIG -n com.github.surfing/com.github.surfing.service.BootReceiver >/dev/null 2>&1
      print_lang "恢复指令已发送！" "Restore command sent!"
    else
      print_lang "已跳过配置文件恢复." "Skipped configuration restore."
    fi
  fi
}

remove_old_surfingtile() {
  pm uninstall "com.surfing.tile" >/dev/null 2>&1 || pm uninstall --user 0 "com.surfing.tile" >/dev/null 2>&1
  OLD_UNINSTALL="$CURRENT_MODULES_DIR/SurfingTile/uninstall.sh"
  [ -f "$OLD_UNINSTALL" ] && sh "$OLD_UNINSTALL"
}

choose_language

sync_version_from_module_prop
    if [ -d "$BOX_BLL_PATH" ]; then
      print_lang "正在更新模块..." "Updating module..."
      ui_print "↴"

      [ "$INSTALL_TILE" = "true" ] && { remove_old_surfingtile; install_surfingtile_apk; }
      cp -f "$MODPATH/box_bll/bin/busybox" "$BIN_PATH/busybox" && init_busybox_toolchain
      extract_subscribe_urls

      if pm path "com.github.surfing" >/dev/null 2>&1; then
        CORE_HASH=$(grep '^version=' "$MODPATH/module.prop" | sed 's/.*(//; s/).*//; s/.*-//')
        [ -n "$CORE_HASH" ] && {
          for prefs_dir in "/data/user/0/com.github.surfing" "/data/data/com.github.surfing"; do
            prefs_file="${prefs_dir}/shared_prefs/OverviewsPrefs.xml"
            if [ -f "$prefs_file" ]; then
              sed "s|<string name=\"cached_core_version\">[^<]*</string>|<string name=\"cached_core_version\">${CORE_HASH}</string>|" "$prefs_file" > "${prefs_file}.tmp"
              cat "${prefs_file}.tmp" > "$prefs_file"; rm -f "${prefs_file}.tmp"
            fi
          done
        }
      fi

      [ -f "$HOSTS_FILE" ] && cp -f "$HOSTS_FILE" "$HOSTS_BACKUP"
      mkdir -p "$HOSTS_PATH" && touch "$HOSTS_FILE"

      cp "$BOX_BLL_PATH/clash/config.yaml" "$BOX_BLL_PATH/clash/config.yaml.bak"
      cp -f "$MODPATH/box_bll/clash/config.yaml" "$BOX_BLL_PATH/clash/"
      
      cp "$BOX_BLL_PATH/scripts/box.config" "$BOX_BLL_PATH/scripts/box.config.bak"
      cp -f "$MODPATH/box_bll/scripts/"* "$BOX_BLL_PATH/scripts/"

      OLD_CONFIG="$BOX_BLL_PATH/scripts/box.config.bak"; NEW_CONFIG="$BOX_BLL_PATH/scripts/box.config"
      [ -f "$OLD_CONFIG" ] && {
        print_lang "正在迁移网络服务控制设置..." "Migrating network service control settings..."
        TMP_CONFIG="${NEW_CONFIG}.tmp"; cp -f "$NEW_CONFIG" "$TMP_CONFIG"
        VARS="enable_network_service_control bypass_via_iptables enable_cellular_proxy enable_wifi_proxy enable_ssid_filter enable_mac_filter use_wifi_list_mode blacklist_wifi_macs whitelist_wifi_macs blacklist_wifi_ssids whitelist_wifi_ssids ap_list gid_list user_packages_list proxy_mode proxy_method ipv6"
        for var in $VARS; do
          val=$(grep "^${var}=" "$OLD_CONFIG" | cut -d'=' -f2-)
          [ -n "$val" ] && sed "s@^${var}=.*@${var}=${val}@" "$TMP_CONFIG" > "${TMP_CONFIG}.bak" && mv -f "${TMP_CONFIG}.bak" "$TMP_CONFIG"
        done
        mv -f "$TMP_CONFIG" "$NEW_CONFIG"
        print_lang "设置迁移成功." "Settings migrated successfully."
      }

      restore_subscribe_urls

      for pid in $(pidof inotifyd); do grep -qE "box.inotify|net.inotify|ctr.inotify" "/proc/$pid/cmdline" 2>/dev/null && kill "$pid"; done

      run_watch "box.inotify" "$HOSTS_PATH"; run_watch "box.inotify" "$SURFING_PATH"; run_watch "net.inotify" "$NET_PATH"; run_watch "ctr.inotify" "$CTR_PATH"

      sleep 1
      cp -f "$MODPATH/box_bll/clash/etc/hosts" "$BOX_BLL_PATH/clash/etc/"
      rm -rf "$MODPATH/box_bll"

      choose_to_umount_hosts_file
      choose_to_restore_config
      
      print_lang "更新已完成." "Update completed."
    else
      print_lang "正在安装..." "Installing..."
      ui_print "↴"
      mv "$MODPATH/box_bll" /data/adb/; init_busybox_toolchain; install_surfingtile_apk
      print_lang "模块安装完毕." "Module installation completed."
      
      choose_to_umount_hosts_file
      choose_to_restore_config
    fi

mv -f "$MODPATH/Surfing_service.sh" "$service_dir/"; rm -f "$SURFING_TILE_ZIP"

set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm_recursive "$BOX_BLL_PATH" 0 3005 0755 0644
set_perm_recursive "$BOX_BLL_PATH/scripts" 0 3005 0755 0700
set_perm_recursive "$BIN_PATH" 0 0 0755 0755
set_perm_recursive "$BOX_BLL_PATH/clash/etc" 0 0 0755 0644
set_perm "$service_dir/Surfing_service.sh" 0 0 0700

chmod ugo+x "$BOX_BLL_PATH/scripts/"*

rm -f customize.sh
