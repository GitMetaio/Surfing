#!/system/bin/sh
# Surfing 免模块卸载：su -c sh /data/adb/box_bll/scripts/root_uninstall.sh [--app]
[ "$(id -u)" = 0 ] || { echo "需要 root 权限"; exit 1; }

BOX_BLL_PATH="/data/adb/box_bll"
SCRIPTS_PATH="$BOX_BLL_PATH/scripts"

[ -x "$SCRIPTS_PATH/box.iptables" ] && "$SCRIPTS_PATH/box.iptables" disable >/dev/null 2>&1
[ -x "$SCRIPTS_PATH/box.service" ] && "$SCRIPTS_PATH/box.service" stop >/dev/null 2>&1

for pid in $(pidof inotifyd); do
  grep -qE "box.inotify|net.inotify|ctr.inotify" "/proc/$pid/cmdline" 2>/dev/null && kill "$pid"
done

umount -l /system/etc/hosts >/dev/null 2>&1
rm -f /data/adb/service.d/Surfing_service.sh /data/adb/ksu/service.d/Surfing_service.sh
rm -rf "$BOX_BLL_PATH"

if [ "$1" = "--app" ]; then
  pm uninstall com.github.surfing >/dev/null 2>&1
fi

echo "已卸载 Surfing（免模块版）"
