#!/bin/sh

SKIPUNZIP=1
ASH_STANDALONE=1

SURFING_PATH="/data/adb/modules/Surfing"
SCRIPTS_PATH="/data/adb/box_bll/scripts"
NET_PATH="/data/misc/net"
CTR_PATH="/data/misc/net/rt_tables"
CONFIG_FILE="/data/adb/box_bll/clash/config.yaml"
BACKUP_FILE="/data/adb/box_bll/clash/proxies/subscribe_urls_backup.txt"
APK_FILE="$MODPATH/webroot/Web.apk"
INSTALL_DIR="/data/app"
HOSTS_FILE="/data/adb/box_bll/clash/etc/hosts"
HOSTS_PATH="/data/adb/box_bll/clash/etc"
HOSTS_BACKUP="/data/adb/box_bll/clash/etc/hosts.bak"

SURFING_TILE_ZIP="$MODPATH/SurfingTile.zip"
SURFING_TILE_DIR_UPDATE="/data/adb/modules/SurfingTile"
SURFING_TILE_DIR="/data/adb/modules_update/SurfingTile"

MODULE_PROP_PATH="/data/adb/modules/Surfing/module.prop"
MODULE_VERSION_CODE=$(awk -F'=' '/versionCode/ {print $2}' "$MODULE_PROP_PATH")

if [ "$MODULE_VERSION_CODE" -lt 1638 ]; then
  INSTALL_TILE=true
else
  INSTALL_TILE=false
fi

# 语言选择函数
choose_language() {
  ui_print ""
  ui_print "=========================================="
  ui_print "  Please choose language / 请选择语言"
  ui_print "  音量 +  Volume Up: English (default)"
  ui_print "  音量 -  Volume Down: 中文"
  ui_print "=========================================="
  
  timeout_seconds=10
  ui_print "Waiting for input (10s)... / 等待输入（10秒）..."
  
  read -r -t $timeout_seconds line < <(getevent -ql | awk '/KEY_VOLUME/ {print; exit}')
  
  if [ $? -eq 142 ]; then
    ui_print "No input detected. Using English as default."
    ui_print "未检测到输入，默认使用英文。"
    export LANG="en"
    return
  fi
  
  if echo "$line" | grep -q "KEY_VOLUMEDOWN"; then
    export LANG="zh"
    ui_print "已选择：中文"
  else
    export LANG="en"
    ui_print "Selected: English"
  fi
}

# 先执行语言选择
choose_language

_( ) {
  case "$LANG" in
    zh)
      case "$1" in
        "Error: Please install via Magisk Manager / KernelSU Manager / APatch")
          echo "错误：请通过 Magisk / KernelSU / APatch 管理器安装！"
          ;;
        "Error: Please update your KernelSU Manager version")
          echo "错误：请更新你的 KernelSU 管理器版本！"
          ;;
        "Backed up subscription URLs to:")
          echo "订阅链接已备份至："
          ;;
        "No URLs found. Check config format.")
          echo "未找到订阅链接，请检查配置文件格式。"
          ;;
        "Config file missing. Cannot extract URLs.")
          echo "配置文件缺失，无法提取订阅链接。"
          ;;
        "Restored URLs to config.yaml")
          echo "已将订阅链接恢复到 config.yaml"
          ;;
        "No valid backup found. Skipped restore.")
          echo "未找到有效备份，跳过恢复。"
          ;;
        "Installing Web.apk...")
          echo "正在安装 Web.apk..."
          ;;
        "Web.apk not found")
          echo "未找到 Web.apk"
          ;;
        "Installing Surfingtile APK...")
          echo "正在安装 SurfingTile 应用..."
          ;;
        "Surfingtile APK not found")
          echo "未找到 SurfingTile APK"
          ;;
        "Mount the hosts file to the system ?")
          echo "是否将 hosts 文件挂载到系统？"
          ;;
        "Volume Up: Mount")
          echo "音量 + 挂载"
          ;;
        "Volume Down: Uninstall (default)")
          echo "音量 - 卸载（默认）"
          ;;
        "Hosts file mounted")
          echo "hosts 文件已挂载"
          ;;
        "Uninstalling hosts file is complete")
          echo "hosts 文件卸载完成"
          ;;
        "Uninstalling old SurfingTile module...")
          echo "正在卸载旧版 SurfingTile 模块..."
          ;;
        "Reboot to take effect")
          echo "重启后生效"
          ;;
        "Uninstalling old SurfingTile app...")
          echo "正在卸载旧版 SurfingTile 应用..."
          ;;
        "Updating...")
          echo "正在更新..."
          ;;
        "Initializing services...")
          echo "正在初始化服务..."
          ;;
        "Update completed. No need to reboot...")
          echo "更新完成，无需重启..."
          ;;
        "Installing...")
          echo "正在安装..."
          ;;
        "Module installation completed. Working directory:")
          echo "模块安装完成。工作目录："
          ;;
        "Please add your subscription to")
          echo "请将你的订阅链接添加到"
          ;;
        "config.yaml under the working directory")
          echo "工作目录下的 config.yaml 中"
          ;;
        "A reboot is required after first installation...")
          echo "首次安装后需要重启..."
          ;;
        "Follow the steps from top to bottom")
          echo "请按从上到下的步骤操作"
          ;;
        "Waiting for input (10s)...")
          echo "等待输入（10秒）..."
          ;;
        "No input detected. Running default option...")
          echo "未检测到输入，执行默认选项..."
          ;;
        "Restarting service...")
          echo "正在重启服务..."
          ;;
        "Please choose language / 请选择语言")
          echo "请选择语言"
          ;;
        "Volume Up: English (default)")
          echo "音量+：英文（默认）"
          ;;
        "Volume Down: 中文")
          echo "音量-：中文"
          ;;
        "No input detected. Using English as default.")
          echo "未检测到输入，默认使用英文。"
          ;;
        "Selected: English")
          echo "已选择：英文"
          ;;
        "Selected: 中文")
          echo "已选择：中文"
          ;;
        *)
          echo "$1"
          ;;
      esac
      ;;
    *)
      echo "$1"
      ;;
  esac
}

if [ "$BOOTMODE" != true ]; then
  abort "$(_ "Error: Please install via Magisk Manager / KernelSU Manager / APatch")"
elif [ "$KSU" = true ] && [ "$KSU_VER_CODE" -lt 10670 ]; then
  abort "$(_ "Error: Please update your KernelSU Manager version")"
fi

if [ "$KSU" = true ] && [ "$KSU_VER_CODE" -lt 10683 ]; then
  service_dir="/data/adb/ksu/service.d"
else
  service_dir="/data/adb/service.d"
fi

if [ ! -d "$service_dir" ]; then
  mkdir -p "$service_dir"
fi

extract_subscribe_urls() {
  if [ -f "$CONFIG_FILE" ]; then
    awk '/proxy-providers:/,/^profile:/' "$CONFIG_FILE" | \
    grep -Eo 'url: ".*"' | \
    sed -E 's/url: "(.*)"/\1/' | \
    sed 's/&/\\&/g' > "$BACKUP_FILE"
    
    if [ -s "$BACKUP_FILE" ]; then
      ui_print "$(_ "Backed up subscription URLs to:")"
      ui_print "proxies/subscribe_urls_backup.txt"
    else
      ui_print "$(_ "No URLs found. Check config format.")"
    fi
  else
    ui_print "$(_ "Config file missing. Cannot extract URLs.")"
  fi
}

restore_subscribe_urls() {
  if [ -f "$BACKUP_FILE" ] && [ -s "$BACKUP_FILE" ]; then
    awk 'NR==FNR {
           urls[++n] = $0; next
         }
         /proxy-providers:/ { inBlock = 1 }
         inBlock && /url: / {
           sub(/url: ".*"/, "url: \"" urls[++i] "\"")
         }
         /profile:/ { inBlock = 0 }
         { print }
        ' "$BACKUP_FILE" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    ui_print "$(_ "Restored URLs to config.yaml")"
  else
    ui_print "$(_ "No valid backup found. Skipped restore.")"
  fi
}

install_web_apk() {
  if [ -f "$APK_FILE" ]; then
    cp "$APK_FILE" "$INSTALL_DIR/"
    ui_print "$(_ "Installing Web.apk...")"
    pm install "$INSTALL_DIR/Web.apk"
    rm -rf "$INSTALL_DIR/Web.apk"
  else
    ui_print "$(_ "Web.apk not found")"
  fi
}

install_surfingtile_apk() {
  APK_SRC="$SURFING_TILE_DIR/system/app/com.surfing.tile/com.surfing.tile.apk"
  APK_TMP="$INSTALL_DIR/com.surfing.tile.apk"
  if [ -f "$APK_SRC" ]; then
    cp "$APK_SRC" "$APK_TMP"
    ui_print "$(_ "Installing Surfingtile APK...")"
    pm install "$APK_TMP"
    rm -f "$APK_TMP"
  else
    ui_print "$(_ "Surfingtile APK not found")"
  fi
}

install_surfingtile_module() {
  mkdir -p "$SURFING_TILE_DIR"
  mkdir -p "$SURFING_TILE_DIR_UPDATE"

  unzip -o "$SURFING_TILE_ZIP" -d "$SURFING_TILE_DIR" >/dev/null 2>&1

  cp -f "$SURFING_TILE_DIR/module.prop" "$SURFING_TILE_DIR_UPDATE"
  touch "$SURFING_TILE_DIR_UPDATE/update"
}

choose_volume_key() {
    timeout_seconds=10

    ui_print "$(_ "Waiting for input (10s)...")"

    read -r -t $timeout_seconds line < <(getevent -ql | awk '/KEY_VOLUME/ {print; exit}')

    if [ $? -eq 142 ]; then
        ui_print "$(_ "No input detected. Running default option...")"
        return 1
    fi

    if echo "$line" | grep -q "KEY_VOLUMEUP"; then
        return 0
    else
        return 1
    fi
}

choose_to_umount_hosts_file() {
  ui_print "$(_ "Mount the hosts file to the system ?")"
  ui_print "$(_ "Volume Up: Mount")"
  ui_print "$(_ "Volume Down: Uninstall (default)")"

  if choose_volume_key; then
    ui_print "$(_ "Hosts file mounted")"
  else
    ui_print "$(_ "Uninstalling hosts file is complete")"
    rm -f "$HOSTS_FILE"
  fi
}

remove_old_surfingtile() {
  OLD_TILE_MODDIR="/data/adb/modules/Surfingtile"
  OLD_TILE_APP="$(pm path "com.yadli.surfingtile" 2>/dev/null | sed 's/package://')"

  if [ -d "$OLD_TILE_MODDIR" ]; then
    ui_print "$(_ "Uninstalling old SurfingTile module...")"
    touch "${OLD_TILE_MODDIR}/remove" && ui_print "$(_ "Reboot to take effect")"
  fi

  if [ -n "$OLD_TILE_APP" ]; then
    ui_print "$(_ "Uninstalling old SurfingTile app...")"
    pm uninstall "com.yadli.surfingtile"
  fi
}

unzip -qo "${ZIPFILE}" -x 'META-INF/*' -d "$MODPATH"

remove_old_surfingtile

if [ -d /data/adb/box_bll ]; then
  ui_print "$(_ "Updating...")"
  ui_print "↴"
  ui_print "$(_ "Initializing services...")"
  /data/adb/box_bll/scripts/box.service stop > /dev/null 2>&1
  sleep 1.5
    
  if [ "$INSTALL_TILE" = "true" ]; then
    rm -rf /data/adb/modules/Surfingtile 2>/dev/null
    rm -rf /data/adb/modules/Surfing_Tile 2>/dev/null
    install_surfingtile_module
    install_surfingtile_apk
  fi

  extract_subscribe_urls

  if [ -f "$HOSTS_FILE" ]; then
    cp -f "$HOSTS_FILE" "$HOSTS_BACKUP"
  fi

  mkdir -p "$HOSTS_PATH"
  touch "$HOSTS_FILE"
  
  cp /data/adb/box_bll/clash/config.yaml /data/adb/box_bll/clash/config.yaml.bak
  cp /data/adb/box_bll/scripts/box.config /data/adb/box_bll/scripts/box.config.bak
  cp -f "$MODPATH/box_bll/clash/config.yaml" /data/adb/box_bll/clash/
  cp -f "$MODPATH/box_bll/clash/Toolbox.sh" /data/adb/box_bll/clash/  
  cp -f "$MODPATH/box_bll/scripts/"* /data/adb/box_bll/scripts/
  
  restore_subscribe_urls

  for pid in $(pidof inotifyd); do
    if grep -qE "box.inotify|net.inotify|ctr.inotify" /proc/${pid}/cmdline; then
      kill "$pid"
    fi
  done
  nohup inotifyd "${SCRIPTS_PATH}/box.inotify" "$HOSTS_PATH" > /dev/null 2>&1 &
  nohup inotifyd "${SCRIPTS_PATH}/box.inotify" "$SURFING_PATH" > /dev/null 2>&1 &
  nohup inotifyd "${SCRIPTS_PATH}/net.inotify" "$NET_PATH" > /dev/null 2>&1 &
  nohup inotifyd "${SCRIPTS_PATH}/ctr.inotify" "$CTR_PATH" > /dev/null 2>&1 &
  sleep 1
  cp -f "$MODPATH/box_bll/clash/etc/hosts" /data/adb/box_bll/clash/etc/
  rm -rf /data/adb/box_bll/clash/Model.bin
  rm -rf /data/adb/box_bll/clash/smart_weight_data.csv
  rm -rf /data/adb/box_bll/scripts/box.upgrade
  rm -rf "$MODPATH/box_bll"

  choose_to_umount_hosts_file
  
  sleep 1
  ui_print "$(_ "Restarting service...")"
  /data/adb/box_bll/scripts/box.service start > /dev/null 2>&1
  ui_print "$(_ "Update completed. No need to reboot...")"
else
  ui_print "$(_ "Installing...")"
  ui_print "↴"
  mv "$MODPATH/box_bll" /data/adb/
  install_surfingtile_module
  install_surfingtile_apk
  install_web_apk
  
  ui_print "$(_ "Module installation completed. Working directory:")"
  ui_print "data/adb/box_bll/"
  ui_print "$(_ "Please add your subscription to")"
  ui_print "$(_ "config.yaml under the working directory")"
  ui_print "$(_ "A reboot is required after first installation...")"
  ui_print "$(_ "Follow the steps from top to bottom")"
  
  choose_to_umount_hosts_file
fi

if [ "$KSU" = true ]; then
  sed -i 's/name=Surfingmagisk/name=SurfingKernelSU/g' "$MODPATH/module.prop"
fi

if [ "$APATCH" = true ]; then
  sed -i 's/name=Surfingmagisk/name=SurfingAPatch/g' "$MODPATH/module.prop"
fi

mv -f "$MODPATH/Surfing_service.sh" "$service_dir/"
rm -f "$SURFING_TILE_ZIP"

set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm_recursive "$SURFING_TILE_DIR" 0 0 0755 0644
set_perm_recursive /data/adb/box_bll/ 0 3005 0755 0644
set_perm_recursive /data/adb/box_bll/scripts/ 0 3005 0755 0700
set_perm_recursive /data/adb/box_bll/bin/ 0 3005 0755 0700
set_perm_recursive /data/adb/box_bll/clash/etc/ 0 0 0755 0644
set_perm "$service_dir/Surfing_service.sh" 0 0 0700

chmod ugo+x /data/adb/box_bll/scripts/*

rm -f customize.sh
