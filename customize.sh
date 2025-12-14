#!/bin/sh

SKIPUNZIP=1
ASH_STANDALONE=1

LOCALE=$(getprop "persist.sys.locale")

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

SURFING_TILE_ZIP="$MODPATH/Surfingtile.zip"
SURFING_TILE_DIR_UPDATE="/data/adb/modules/Surfing_Tile"
SURFING_TILE_DIR="/data/adb/modules_update/Surfing_Tile"

MODULE_PROP_PATH="/data/adb/modules/Surfing/module.prop"
MODULE_VERSION_CODE=$(awk -F'=' '/versionCode/ {print $2}' "$MODULE_PROP_PATH")

print_loc() {  # print locale content

  if [ "$LOCALE" = "zh-CN" ]; then
    ui_print " $1"
  else
    ui_print " $2"
  fi

}

printl() {  # print line

  length=28
  symbol=*

  line=$(printf "%-${length}s" | tr ' ' "$symbol")
  ui_print "$line"

}

printe() { ui_print " "; }  # print empty line

if [ "$MODULE_VERSION_CODE" -lt 1622 ]; then
  INSTALL_APK=true
  INSTALL_TILE_APK=true
else
  INSTALL_APK=false
  INSTALL_TILE_APK=false
fi
if [ "$MODULE_VERSION_CODE" -lt 1623 ]; then
  COPY_WEB=true
else
  COPY_WEB=false
fi


if [ "$BOOTMODE" != true ]; then
  abort "Error: Please install via Magisk Manager / KernelSU Manager / APatch"
elif [ "$KSU" = true ] && [ "$KSU_VER_CODE" -lt 10670 ]; then
  abort "Error: Please update your KernelSU Manager version"
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
      print_loc "已备份订阅地址至：" "Backed up the subscription URLs to:"
      ui_print " proxies/subscribe_urls_backup.txt"
    else
      print_loc "未找到 URLs，请检查配置文件格式" "No URLs found. Check config format."
    fi
  else
    print_loc "配置文件不存在，无法提取 URLs" "Config file missing. Cannot extract URLs."
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
    print_loc "已还原 URLs 至 config.yaml" "Restored URLs to config.yaml"
  else
    print_loc "找不到可用备份，已跳过还原" "No valid backup found. Skipped restore."
  fi
  printe
}

install_Web_apk() {
  if [ -f "$APK_FILE" ]; then
    cp "$APK_FILE" "$INSTALL_DIR/"
    print_loc "正在安装 Web APP…" "Installing Web APP..."
    pm install "$INSTALL_DIR/Web.apk" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      print_loc "已安装" "Success"
    else
      print_loc "安装失败" "Failed"
    fi
    printe
    rm -rf "$INSTALL_DIR/Web.apk"
  else
    print_loc "Web.apk 未找到" "Web.apk not found"
  fi
}

install_Surfingtile_apk() {
  APK_SRC="$SURFING_TILE_DIR/system/app/com.surfing.tile/com.surfing.tile.apk"
  APK_TMP="$INSTALL_DIR/com.surfing.tile.apk"
  if [ -f "$APK_SRC" ]; then
    cp "$APK_SRC" "$APK_TMP"
    print_loc "正在安装 SurfingTile APP…" "Installing SurfingTile APP..."
    pm install "$APK_TMP" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      print_loc "已安装" "Success"
    else
      print_loc "安装失败" "Failed"
    fi
    printe
    rm -f "$APK_TMP"
  else
    print_loc "SurfingTile APK 未找到" "SurfingTile APK not found"
  fi
}

install_surfingtile_module() {
  mkdir -p "$SURFING_TILE_DIR"
  mkdir -p "$SURFING_TILE_DIR_UPDATE"

  unzip -o "$SURFING_TILE_ZIP" -d "$SURFING_TILE_DIR" >/dev/null 2>&1

  cp -f "$SURFING_TILE_DIR/module.prop" "$SURFING_TILE_DIR_UPDATE"
  touch "$SURFING_TILE_DIR_UPDATE/update"

  if [ "$KSU" = true ] && [ "$KSU_VER_CODE" -ge 22098 ]; then
      printe
      print_loc "检测到当前 KernelSU 版本使用了元模块功能" "Detect current KernelSU is using meta-module feature"
      print_loc "如果你使用 SurfingTile 模块" "Make sure you have installed meta-module"
      print_loc "请务必确保已安装元模块!" "if you use SurfingTile module!"
      printe
      print_loc "注意：若你不知道元模块是什么" "NOTICE: If you don’t know what is meta-module,"
      print_loc "请查阅 KernelSU 官方网站" "please check KernelSU official website."
      printe
  fi

}

choose_volume_key() {
    timeout_seconds=10

    print_loc "等待按键中 (${timeout_seconds}秒)" "Waiting for pressing key (${timeout_seconds}s)..."

    read -r -t $timeout_seconds line < <(getevent -ql | awk '/KEY_VOLUME/ {print; exit}')

    printe
    if [ $? -eq 142 ]; then
        print_loc "未检测到按键，执行默认选项…" "No input detected. Running default option..."
        return 1
    fi

    if echo "$line" | grep -q "KEY_VOLUMEUP"; then
        return 0
    else
        return 1
    fi
}

choose_to_umount_hosts_file() {
  printl
  printe
  print_loc "是否挂载 hosts 文件至系统？" "Mount the hosts file to the system ?"
  printe
  print_loc "音量增加键：挂载" "Volume Up: Mount"
  print_loc "音量减少键：卸载 (默认)" "Volume Down: Uninstall (default)"

  if choose_volume_key; then
    print_loc "已挂载 hosts 文件" "Hosts file mounted"
  else
    print_loc "已卸载 hosts 文件" "Uninstalling hosts file is complete"
    rm -f "$HOSTS_FILE"
  fi
  printe

}

choose_to_install_surfingtile_module() {
  printl
  printe
  print_loc "是否安装 SurfingTile APP?" "Install SurfingTile APP?"
  printe
  print_loc "音量增加键：否" "Volume Up: No"
  print_loc "音量减少键：是 (默认)" "Volume Down: Yes (default)"

  if choose_volume_key; then
    print_loc "已跳过安装 SurfingTile APP…" "Skip installing SurfingTile APP..."
  else
    install_surfingtile_module
    install_Surfingtile_apk
  fi
}

choose_to_install_Web_apk() {
  printl
  printe
  print_loc "是否安装 Web APP?" "Install Web APP?"
  printe
  print_loc "音量增加键：否" "Volume Up: No"
  print_loc "音量减少键：是 (默认)" "Volume Down: Yes (default)"

  if choose_volume_key; then
    print_loc "已跳过安装 Web APP…" "Skip installing Web APP..."
  else
    install_Web_apk
  fi
}

remove_old_surfingtile() {
  OLD_TILE_MODDIR="/data/adb/modules/Surfingtile"
  OLD_TILE_APP="$(pm path "com.yadli.surfingtile" 2>/dev/null | sed 's/package://')"

  if [ -d "$OLD_TILE_MODDIR" ]; then
    print_loc "卸载旧版本 SurfingTile 模块中…" "Uninstalling old SurfingTile module..."
    touch "${OLD_TILE_MODDIR}/remove" && print_loc "重启后完成卸载" "Reboot to take effect"
  fi

  if [ -n "$OLD_TILE_APP" ]; then
    print_loc "卸载旧版本 SurfingTile APP 中…" "Uninstalling old SurfingTile APP..."
    pm uninstall "com.yadli.surfingtile" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      print_loc "已卸载" "Success"
    else
      print_loc "卸载失败" "Failed"
    fi
  fi
}

unzip -qo "${ZIPFILE}" -x 'META-INF/*' -d "$MODPATH"

if [ -z "$LOCALE" ]; then
  printe
  ui_print "  请选择你所使用的语言：
  Please select your language:
  
- 音量增加键：简体中文
  Volume Up: Simplified Chinese
- 音量减少键：English
  Volume Down: English (default)
  "
  if choose_volume_key; then
    LOCALE=zh-CN
  else
    LOCALE=en-US
  fi
fi

printe
print_loc "欢迎使用 Surfing" "Welcome to Surfing"
remove_old_surfingtile

if [ -d /data/adb/box_bll ]; then
  print_loc "更新中…" "Updating..."
  ui_print " ↴"
  printl
  printe
  print_loc "正在初始化服务…" "Initializing services..."
  /data/adb/box_bll/scripts/box.service stop > /dev/null 2>&1
  sleep 1.5
  printe
  if [ "$INSTALL_TILE_APK" = true ] || [ -d "$SURFING_TILE_DIR_UPDATE" ]; then
    install_surfingtile_module
  else
    choose_to_install_surfingtile_module
  fi
  if [ "$INSTALL_APK" = true ]; then
    install_Web_apk
  fi
  
  extract_subscribe_urls
  
  if [ -f "$HOSTS_FILE" ]; then
    cp -f "$HOSTS_FILE" "$HOSTS_BACKUP"
  fi

  mkdir -p "$HOSTS_PATH"
  touch "$HOSTS_FILE"
  
  cp /data/adb/box_bll/bin/clash /data/adb/box_bll/bin/clash.bak
  
  cp /data/adb/box_bll/clash/config.yaml /data/adb/box_bll/clash/config.yaml.bak
  cp /data/adb/box_bll/scripts/box.config /data/adb/box_bll/scripts/box.config.bak
  cp -f "$MODPATH/box_bll/clash/config.yaml" /data/adb/box_bll/clash/
  cp -f "$MODPATH/box_bll/clash/Toolbox.sh" /data/adb/box_bll/clash/
  cp -f "$MODPATH/box_bll/bin/clash" /data/adb/box_bll/bin/
  
  if [ "$COPY_WEB" = true ]; then
    cp -rf "$MODPATH/box_bll/clash/Web" /data/adb/box_bll/clash/
  fi
  
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
  printl
  printe
  print_loc "正在重启服务…" "Restarting service..."
  /data/adb/box_bll/scripts/box.service start > /dev/null 2>&1
  print_loc "更新完成，无需重启" "Update completed. No need to reboot."
  printe
else
  print_loc "安装中…" "Installing..."
  ui_print " ↴"
  mv "$MODPATH/box_bll" /data/adb/
  choose_to_install_surfingtile_module
  choose_to_install_Web_apk
  choose_to_umount_hosts_file
  printl
  printe
  print_loc "模块安装完毕，工作目录为：" "Module installation completed. Working directory:"
  printe
  ui_print " /data/adb/box_bll/"
  printe
  print_loc "请在该工作目录下的 config.yaml" "Please add your subscription to"
  print_loc "添加你的订阅" "config.yaml under the working directory"
  printe
  print_loc "首次安装完成后需要重启" "A reboot is required after first installation..."
  printe
  
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