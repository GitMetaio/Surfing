#!/system/bin/sh

module_dir="/data/adb/modules/Surfing"
[ -n "$(magisk -v | grep lite)" ] && module_dir="/data/adb/lite_modules/Surfing"

scripts=$(realpath "$0")
scripts_dir=$(dirname "${scripts}")
mkdir -p "${run_path}"
source "${scripts_dir}/box.config"

wait_until_login() {
  local test_file="/sdcard/Android/.SURFINGTEST"
  true > "$test_file"
  while [ ! -f "$test_file" ]; do
    true > "$test_file"
    sleep 1
  done
  rm -f "$test_file"

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
  "${scripts_dir}/box.linkclear" >> "${run_path}/run_error.log" 2>&1 &
fi

chown -R 0:0 /data/adb/box_bll/clash/etc/
find /data/adb/box_bll/clash/etc/ -type d -exec chmod 755 {} \;
find /data/adb/box_bll/clash/etc/ -type f -exec chmod 644 {} \;