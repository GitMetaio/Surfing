#!/system/bin/sh
export PATH="/data/adb/box_bll/bin:$PATH"

module_dir="/data/adb/modules/Surfing"
magisk -v | grep -q lite && module_dir="/data/adb/lite_modules/Surfing"

scripts=$(realpath "$0")
scripts_dir=$(dirname "${scripts}")
mkdir -p "${run_path}"
source "${scripts_dir}/box.config"

wait_until_login() {
  local test_file="/sdcard/Android/.SURFINGTEST"
  until [ -d "/sdcard/Android" ]; do
    sleep 1
  done
  true > "$test_file" 2>/dev/null
  while [ ! -f "$test_file" ]; do
    true > "$test_file" 2>/dev/null
    sleep 1
  done
  rm -f "$test_file" 2>/dev/null
  while [ ! -f "/data/system/packages.xml" ]; do
    sleep 1
  done
}
wait_until_login

if [ ! -f "${box_path}/manual" ] && [ ! -f "${module_dir}/disable" ]; then
  mv "${run_path}/run.log" "${run_path}/run.log.bak" 2>/dev/null
  mv "${run_path}/run_error.log" "${run_path}/run_error.log.bak" 2>/dev/null
  "${scripts_dir}/box.service" start >> "${run_path}/run.log" 2>> "${run_path}/run_error.log" && \
  "${scripts_dir}/box.iptables" enable >> "${run_path}/run.log" 2>> "${run_path}/run_error.log"
fi

(
sleep 1
while true; do
    if ! pm path com.github.surfing >/dev/null 2>&1; then
        break
    fi
    if service list 2>/dev/null | grep -q "activity"; then
        if am broadcast -a com.github.surfing.ACTION_WAKEUP_CLASH \
                     -n com.github.surfing/com.github.surfing.service.BootReceiver \
                     -f 0x01000020 2>&1 | grep -q "Broadcast completed"; then
            break
        fi
    fi
    sleep 3
done
) &

find /data/adb/box_bll/clash/etc/ -type d -exec chmod 755 {} \; -o -type f -exec chmod 644 {} \;
