#!/system/bin/sh
# shellcheck shell=sh

# action.sh for Surfing module

# 变量定义
BOX_DIR="/data/adb/box_bll"
RUN_DIR="${BOX_DIR}/run"
SCRIPTS_DIR="${BOX_DIR}/scripts"
PID_FILE="${RUN_DIR}/clash.pid"

# 使用 su 执行命令的辅助函数
run_as_su() {
    su -c "$1"
}

# 停止服务的函数
stop_service() {
    echo "正在停止 Surfing 服务..."
    run_as_su "${SCRIPTS_DIR}/box.tproxy disable"
    run_as_su "${SCRIPTS_DIR}/box.service stop"
}

# 启动服务的函数
start_service() {
    echo "正在启动 Surfing 服务, 请稍候..."
    run_as_su "${SCRIPTS_DIR}/box.service start"
    run_as_su "${SCRIPTS_DIR}/box.tproxy enable"
}

# 主要逻辑: 切换服务状态
if [ -f "${PID_FILE}" ]; then
    PID=$(cat "${PID_FILE}")
    # 检查进程是否存在
    if [ -n "$PID" ] && [ -e "/proc/${PID}" ]; then
        stop_service
    else
        # PID 文件存在但进程已死，直接启动
        start_service
    fi
else
    # PID 文件不存在，启动服务
    start_service
fi

exit 0