#!/bin/sh

SKIPUNZIP=1
ASH_STANDALONE=1

CURRENT_MODULES_DIR="/data/adb/modules"
UPDATE_MODULES_DIR="/data/adb/modules_update"

magisk -v | grep -q lite && CURRENT_MODULES_DIR="/data/adb/lite_modules" && UPDATE_MODULES_DIR="/data/adb/lite_modules_update"

SURFING_PATH="$CURRENT_MODULES_DIR/Surfing"
BOX_BLL_PATH="/data/adb/box_bll"

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
CURRENT_SURFING_TILE_DIR="$CURRENT_MODULES_DIR/SurfingTile"
UPDATE_SURFING_TILE_DIR="$UPDATE_MODULES_DIR/SurfingTile"

MODULE_PROP_PATH="$CURRENT_MODULES_DIR/Surfing/module.prop"
MODULE_VERSION_CODE=0
[ -f "$MODULE_PROP_PATH" ] && MODULE_VERSION_CODE=$(awk -F'=' '/versionCode/ {print $2}' "$MODULE_PROP_PATH")

if [ "$MODULE_VERSION_CODE" -lt 1644 ]; then
  INSTALL_TILE=true
else
  INSTALL_TILE=false
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

install_surfingtile_apk() {
  APK_SRC="$UPDATE_SURFING_TILE_DIR/system/app/com.surfing.tile/com.surfing.tile.apk"
  APK_TMP="$INSTALL_DIR/com.surfing.tile.apk"
  if [ -f "$APK_SRC" ]; then
    cp "$APK_SRC" "$APK_TMP"
    ui_print "Installing Surfingtile APK..."
    pm install "$APK_TMP"
    rm -f "$APK_TMP"
  else
    ui_print "Surfingtile APK not found"
  fi
}

install_surfingtile_module() {
  mkdir -p "$UPDATE_SURFING_TILE_DIR"
  mkdir -p "$CURRENT_SURFING_TILE_DIR"

  unzip -o "$SURFING_TILE_ZIP" -d "$UPDATE_SURFING_TILE_DIR" >/dev/null 2>&1

  cp -f "$UPDATE_SURFING_TILE_DIR/module.prop" "$CURRENT_SURFING_TILE_DIR"
  touch "$CURRENT_SURFING_TILE_DIR/update"
}

sync_version_from_module_prop() {
  dst_prop="$CURRENT_MODULES_DIR/Surfing/module.prop"
  if [ -f "$MODPATH/module.prop" ] && [ -d "$CURRENT_MODULES_DIR/Surfing" ]; then
    cp -f "$MODPATH/module.prop" "$dst_prop"
  fi
}

choose_volume_key() {
  timeout_seconds=10
  ui_print "Waiting for input (${timeout_seconds}s)..."

  line=$(timeout $timeout_seconds getevent -ql | awk '/KEY_VOLUME/ {print; exit}')

  if [ -z "$line" ]; then
      ui_print "No input detected. Running default option..."
      return 1
  fi
  if echo "$line" | grep -q "KEY_VOLUMEUP"; then
      return 0
  else
      return 1
  fi
}

choose_to_umount_hosts_file() {
  ui_print "Mount the hosts file to the system ?"
  ui_print "Volume Up: Mount"
  ui_print "Volume Down: Uninstall (default)"

  if choose_volume_key; then
    ui_print "Hosts file mounted"
  else
    ui_print "Uninstalling hosts file is complete"
    rm -f "$HOSTS_FILE"
  fi

}

remove_old_surfingtile(){
  rm -rf /data/adb/modules/Surfingtile 2>/dev/null
  rm -rf /data/adb/modules_update/Surfingtile 2>/dev/null
  rm -rf /data/adb/lite_modules/Surfingtile 2>/dev/null
  rm -rf /data/adb/lite_modules_update/Surfingtile 2>/dev/null

  rm -rf /data/adb/modules/Surfing_Tile 2>/dev/null
  rm -rf /data/adb/modules_update/Surfing_Tile 2>/dev/null
  rm -rf /data/adb/lite_modules/Surfing_Tile 2>/dev/null
  rm -rf /data/adb/lite_modules_update/Surfing_Tile 2>/dev/null

  pm uninstall "com.yadli.surfingtile" > /dev/null 2>&1 || pm uninstall --user 0 "com.yadli.surfingtile" > /dev/null 2>&1
}

unzip -qo "${ZIPFILE}" -x 'META-INF/*' -d "$MODPATH"

remove_old_surfingtile

sync_version_from_module_prop

if [ -d "$BOX_BLL_PATH" ]; then
  ui_print "Updating..."
  ui_print "↴"
  ui_print "Initializing services..."
  
  [ "$INSTALL_TILE" = "true" ] && install_surfingtile_module && install_surfingtile_apk

  extract_subscribe_urls

  if [ -f "$HOSTS_FILE" ]; then
    cp -f "$HOSTS_FILE" "$HOSTS_BACKUP"
  fi
  mkdir -p "$HOSTS_PATH" && touch "$HOSTS_FILE"
  
  cp "$BOX_BLL_PATH/clash/config.yaml" "$BOX_BLL_PATH/clash/config.yaml.bak"
  cp "$BOX_BLL_PATH/scripts/box.config" "$BOX_BLL_PATH/scripts/box.config.bak"
  cp -f "$MODPATH/box_bll/clash/config.yaml" "$BOX_BLL_PATH/clash/"
  cp -f "$MODPATH/box_bll/scripts/"* "$BOX_BLL_PATH/scripts/"
  
  OLD_CONFIG="$BOX_BLL_PATH/scripts/box.config.bak"
  NEW_CONFIG="$BOX_BLL_PATH/scripts/box.config"
  if [ -f "$OLD_CONFIG" ]; then
    ui_print "Migrating network service control settings..."

    TMP_CONFIG="${NEW_CONFIG}.tmp"
    cp -f "$NEW_CONFIG" "$TMP_CONFIG"

    VARS="enable_network_service_control use_module_on_wifi_disconnect use_module_on_wifi use_ssid_matching use_wifi_list_mode blacklist_wifi_ssids whitelist_wifi_ssids ap_list gid_list user_packages_list proxy_mode proxy_method ipv6"
    for var in $VARS; do
      val=$(grep "^${var}=" "$OLD_CONFIG" | cut -d'=' -f2-)
      if [ -n "$val" ]; then
        sed "s@^${var}=.*@${var}=${val}@" "$TMP_CONFIG" > "${TMP_CONFIG}.bak" && mv -f "${TMP_CONFIG}.bak" "$TMP_CONFIG"
      fi
    done
    mv -f "$TMP_CONFIG" "$NEW_CONFIG"
    ui_print "Settings migrated successfully"
  fi
  
  restore_subscribe_urls
  
  for pid in $(pidof inotifyd); do
    if [ -f "/proc/${pid}/cmdline" ] && grep -qE "box.inotify|net.inotify|ctr.inotify" "/proc/${pid}/cmdline"; then
      kill "$pid"
    fi
  done
  nohup inotifyd "${SCRIPTS_PATH}/box.inotify" "$HOSTS_PATH" > /dev/null 2>&1 &
  nohup inotifyd "${SCRIPTS_PATH}/box.inotify" "$SURFING_PATH" > /dev/null 2>&1 &
  nohup inotifyd "${SCRIPTS_PATH}/net.inotify" "$NET_PATH" > /dev/null 2>&1 &
  nohup inotifyd "${SCRIPTS_PATH}/ctr.inotify" "$CTR_PATH" > /dev/null 2>&1 &
  [ -d "$CURRENT_SURFING_TILE_DIR" ] && inotifyd "${SCRIPTS_PATH}/box.inotify" "/data/system" >/dev/null 2>&1 &
  sleep 1
  cp -f "$MODPATH/box_bll/clash/etc/hosts" "$BOX_BLL_PATH/clash/etc/"
  rm -f "$BOX_BLL_PATH/clash/Toolbox.sh"
  rm -rf "$BOX_BLL_PATH/clash/Model.bin"
  rm -rf "$BOX_BLL_PATH/clash/smart_weight_data.csv"
  rm -rf "$BOX_BLL_PATH/scripts/box.upgrade"
  rm -rf "$MODPATH/box_bll"

  choose_to_umount_hosts_file
  
  ui_print "Update completed. No need to reboot..."
else
  ui_print "Installing..."
  ui_print "↴"
  mv "$MODPATH/box_bll" /data/adb/
  install_surfingtile_module
  install_surfingtile_apk

  ui_print "Module installation completed. Working directory:"
  ui_print "data/adb/box_bll/"
  ui_print "Please add your subscription to"
  ui_print "config.yaml under the working directory"
  ui_print "A reboot is required after first installation..."
  ui_print "Follow the steps from top to bottom"
  
  choose_to_umount_hosts_file
  
fi

mv -f "$MODPATH/Surfing_service.sh" "$service_dir/"
rm -f "$SURFING_TILE_ZIP"

set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm_recursive "$UPDATE_SURFING_TILE_DIR" 0 0 0755 0644
set_perm_recursive "$BOX_BLL_PATH" 0 3005 0755 0644
set_perm_recursive "$BOX_BLL_PATH/scripts" 0 3005 0755 0700
set_perm_recursive "$BOX_BLL_PATH/bin" 0 3005 0755 0700
set_perm_recursive "$BOX_BLL_PATH/clash/etc" 0 0 0755 0644
set_perm "$service_dir/Surfing_service.sh" 0 0 0700

chmod ugo+x "$BOX_BLL_PATH/scripts/"*

rm -f customize.sh
