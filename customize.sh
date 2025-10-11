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

SURFING_TILE_ZIP="$MODPATH/Surfingtile.zip"
SURFING_TILE_DIR_UPDATE="/data/adb/modules/Surfingtile"
SURFING_TILE_DIR="/data/adb/modules_update/Surfingtile"

MODULE_PROP_PATH="/data/adb/modules/Surfing/module.prop"

MODULE_VERSION_CODE=$(awk -F'=' '/versionCode/ {print $2}' "$MODULE_PROP_PATH")

if [ "$MODULE_VERSION_CODE" -lt 1622 ]; then
  INSTALL_APK=true
else
  INSTALL_APK=false
fi
if [ "$MODULE_VERSION_CODE" -lt 1622 ]; then
  INSTALL_TILE_APK=true
else
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
      ui_print "Backed up subscription URLs to:"
      ui_print "proxies/subscribe_urls_backup.txt"
    else
      ui_print "No URLs found. Check config format."
    fi
  else
    ui_print "Config file missing. Cannot extract URLs."
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
    ui_print "Restored URLs to config.yaml"
  else
    ui_print "No valid backup found. Skipped restore."
  fi
}

install_Web_apk() {
  if [ -f "$APK_FILE" ]; then
    cp "$APK_FILE" "$INSTALL_DIR/"
    pm install "$INSTALL_DIR/Web.apk"
    ui_print "Installing Web.apk..."
    ui_print "installation complete"
    rm -rf "$INSTALL_DIR/Web.apk"
  else
    ui_print "Web.apk not found"
  fi
}

install_Surfingtile_apk() {
  APK_SRC="$SURFING_TILE_DIR/system/app/com.yadli.surfingtile/com.yadli.surfingtile.apk"
  APK_TMP="$INSTALL_DIR/com.yadli.surfingtile.apk"
  if [ -f "$APK_SRC" ]; then
    cp "$APK_SRC" "$APK_TMP"
    pm install "$APK_TMP"
    ui_print "Installing Surfingtile APK..."
    ui_print "installation complete"
    rm -f "$APK_TMP"
  else
    ui_print "Surfingtile APK not found"
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
  ui_print "Mount the hosts file to the system ？"
  ui_print "Volume Up: Mount"
  ui_print "Volume Down: Uninstall"
  ui_print "Waiting for input (10s)..."

  TMP_FILE="/dev/tmp/vol_key_choice"
  rm -f "$TMP_FILE"

  getevent -qlc 1 > "$TMP_FILE" &
  GETEVENT_PID=$!

  for i in $(seq 1 100); do
    if [ -s "$TMP_FILE" ]; then
      if grep -q KEY_VOLUMEUP "$TMP_FILE"; then
        kill "$GETEVENT_PID" 2>/dev/null
        rm -f "$TMP_FILE"
        return 0
      elif grep -q KEY_VOLUMEDOWN "$TMP_FILE"; then
        kill "$GETEVENT_PID" 2>/dev/null
        rm -f "$TMP_FILE"
        return 1
      fi
    fi
    sleep 0.1
  done

  kill "$GETEVENT_PID" 2>/dev/null
  rm -f "$TMP_FILE"
  ui_print "No input detected. Default: Uninstall"
  return 1
}

unzip -qo "${ZIPFILE}" -x 'META-INF/*' -d "$MODPATH"
if [ -d /data/adb/box_bll ]; then
  ui_print "Updating..."
  ui_print "↴"
  ui_print "Initializing services..."
  /data/adb/box_bll/scripts/box.service stop > /dev/null 2>&1
  sleep 1.5
  
  install_surfingtile_module
  
  if [ "$INSTALL_TILE_APK" = true ]; then
    install_Surfingtile_apk
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

  if choose_volume_key; then
    ui_print "Hosts file mounted"
  else
    ui_print "Uninstalling hosts file is complete"
    rm -f "$HOSTS_FILE"
  fi
  
  sleep 1
  ui_print "Restarting service..."
  /data/adb/box_bll/scripts/box.service start > /dev/null 2>&1
  ui_print "Update completed. No need to reboot..."
else
  ui_print "Installing..."
  ui_print "↴"
  mv "$MODPATH/box_bll" /data/adb/
  install_surfingtile_module
  install_Surfingtile_apk
  install_Web_apk
  ui_print "Module installation completed. Working directory:"
  ui_print "data/adb/box_bll/"
  ui_print "Please add your subscription to"
  ui_print "config.yaml under the working directory"
  ui_print "A reboot is required after first installation..."
  ui_print "Follow the steps from top to bottom"
  
  if choose_volume_key; then
    ui_print "Hosts file mounted"
  else
    ui_print "Uninstalling hosts file is complete"
    rm -f "$HOSTS_FILE"
  fi
  
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