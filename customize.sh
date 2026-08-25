#!/bin/sh

SKIPUNZIP=1
ASH_STANDALONE=1

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

if [ "$MODULE_VERSION_CODE" -lt 1653 ]; then
  INSTALL_TILE=true
else
  INSTALL_TILE=false
fi

init_busybox_toolchain() {
  chmod 755 "$BIN_PATH/busybox"
  cd "$BIN_PATH" && find . -type l -delete && ./busybox --install -s . && cd "$MODPATH"
}

extract_subscribe_urls() {
  if [ -f "$CONFIG_FILE" ]; then
    sed -n '/# 订阅地址相关/,/profile:.*↑/p' "$CONFIG_FILE" > "$BACKUP_FILE"
    
    if [ -s "$BACKUP_FILE" ]; then
      ui_print "Backed up subscription configuration."
    else
      ui_print "No subscription block found. Using default."
    fi
  else
    ui_print "Config file missing. Cannot extract subscriptions."
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
    ui_print "Restored subscription configuration."
  else
    ui_print "No valid backup found. Skipped restore."
  fi
}

install_surfingtile_apk() {
  APK_TMP="$INSTALL_DIR/com.github.surfing.apk"
  rm -f "$APK_TMP"
  unzip -o "$SURFING_TILE_ZIP" "com.github.surfing.apk" -d "$INSTALL_DIR" >/dev/null 2>&1
  if [ -f "$APK_TMP" ]; then
    ui_print "Installing Surfingtile APK..."
    pm install "$APK_TMP"
    rm -f "$APK_TMP"
  else
    ui_print "Surfingtile APK not found"
  fi
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
[ ! -d "$service_dir" ] && mkdir -p "$service_dir"

unzip -qo "${ZIPFILE}" -x 'META-INF/*' -d "$MODPATH"

remove_old_surfingtile() {
  pm uninstall "com.surfing.tile" >/dev/null 2>&1 || pm uninstall --user 0 "com.surfing.tile" >/dev/null 2>&1
  OLD_UNINSTALL="$CURRENT_MODULES_DIR/SurfingTile/uninstall.sh"
  [ -f "$OLD_UNINSTALL" ] && sh "$OLD_UNINSTALL"
}

sync_version_from_module_prop

if [ -d "$BOX_BLL_PATH" ]; then
  ui_print "Updating..."
  ui_print "↴"

  [ "$INSTALL_TILE" = "true" ] && remove_old_surfingtile && install_surfingtile_apk
  cp -f "$MODPATH/box_bll/bin/busybox" "$BIN_PATH/busybox" && init_busybox_toolchain
  extract_subscribe_urls

  [ -f "$HOSTS_FILE" ] && cp -f "$HOSTS_FILE" "$HOSTS_BACKUP"
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
    VARS="enable_network_service_control bypass_via_iptables enable_cellular_proxy enable_wifi_proxy enable_mac_filter use_wifi_list_mode blacklist_wifi_macs whitelist_wifi_macs ap_list gid_list user_packages_list proxy_mode proxy_method ipv6"
    for var in $VARS; do
      val=$(grep "^${var}=" "$OLD_CONFIG" | cut -d'=' -f2-)
      [ -n "$val" ] && sed "s@^${var}=.*@${var}=${val}@" "$TMP_CONFIG" > "${TMP_CONFIG}.bak" && mv -f "${TMP_CONFIG}.bak" "$TMP_CONFIG"
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

  sleep 1
  cp -f "$MODPATH/box_bll/clash/etc/hosts" "$BOX_BLL_PATH/clash/etc/"
  rm -f "$BOX_BLL_PATH/clash/Toolbox.sh"
  rm -rf "$BOX_BLL_PATH/clash/Model.bin" "$BOX_BLL_PATH/clash/smart_weight_data.csv" "$BOX_BLL_PATH/scripts/box.upgrade"
  rm -rf "$MODPATH/box_bll"

  choose_to_umount_hosts_file
  ui_print "Update completed."
else
  ui_print "Installing..."
  ui_print "↴"
  mv "$MODPATH/box_bll" /data/adb/

  init_busybox_toolchain

  install_surfingtile_apk
  ui_print "Module installation completed."
  choose_to_umount_hosts_file
fi

mv -f "$MODPATH/Surfing_service.sh" "$service_dir/"
rm -f "$SURFING_TILE_ZIP"

set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm_recursive "$BOX_BLL_PATH" 0 3005 0755 0644

set_perm_recursive "$BOX_BLL_PATH/scripts" 0 3005 0755 0700
set_perm_recursive "$BIN_PATH" 0 0 0755 0755
set_perm_recursive "$BOX_BLL_PATH/clash/etc" 0 0 0755 0644

set_perm "$service_dir/Surfing_service.sh" 0 0 0700
chmod ugo+x "$BOX_BLL_PATH/scripts/"*

rm -f customize.sh
