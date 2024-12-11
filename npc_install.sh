#!/bin/bash

# 检查是否提供了必要的参数
if [ $# -lt 6 ]; then
    echo "Usage: $0 -server=<server_address> -vkey=<vkey> -type=<type>"
    exit 1
fi

# 解析参数
for arg in "$@"; do
    case $arg in
        -server=*)
            SERVER="${arg#*=}"
            shift
            ;;
        -vkey=*)
            VKEY="${arg#*=}"
            shift
            ;;
        -type=*)
            TYPE="${arg#*=}"
            shift
            ;;
        *)
            echo "Unknown parameter passed: $arg"
            exit 1
            ;;
    esac
done

# 下载 NPC 客户端
wget https://gh.llkk.cc/https://github.com/djylb/nps/releases/download/v0.26.32/linux_amd64_client.tar.gz

# 创建目录
mkdir -p /opt/npc/

# 解压文件
tar -zxf linux_amd64_client.tar.gz -C /opt/npc/

# 创建 init.d 脚本
cat << EOF > /etc/init.d/npc
#!/bin/bash
# chkconfig: 2345 90 10
# description: NPC daemon for client connection

### BEGIN INIT INFO
# Provides:          npc
# Required-Start:    $network
# Required-Stop:     $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: NPC daemon
# Description:       Starts and stops the NPC client daemon
### END INIT INFO

# 服务的名称
NAME="npc"
# NPC 二进制文件路径
DAEMON="/opt/npc/npc"
# 启动参数
DAEMON_OPTS="-server=$SERVER -vkey=$VKEY -type=$TYPE"
# PID 文件路径
PIDFILE="/var/run/$NAME.pid"
# 日志文件路径
LOGFILE="/var/log/$NAME.log"

# 检查 NPC 是否存在
[ -x "$DAEMON" ] || exit 1

start() {
    echo "Starting $NAME..."
    if [ -e "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then
        echo "$NAME is already running."
        return 1
    fi
    # 启动 NPC 并将日志重定向
    nohup "$DAEMON" $DAEMON_OPTS >> "$LOGFILE" 2>&1 &
    echo $! > "$PIDFILE"
    echo "$NAME started."
}

stop() {
    echo "Stopping $NAME..."
    if [ -e "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then
        kill $(cat "$PIDFILE")
        rm -f "$PIDFILE"
        echo "$NAME stopped."
    else
        echo "$NAME is not running."
    fi
}

restart() {
    echo "Restarting $NAME..."
    stop
    sleep 1
    start
}

status() {
    if [ -e "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then
        echo "$NAME is running."
    else
        echo "$NAME is not running."
    fi
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    status)
        status
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 2
        ;;
esac

exit 0
EOF

# 设置 init.d 脚本为可执行
chmod +x /etc/init.d/npc

# 更新 rc.d 以使用新的 init.d 脚本
update-rc.d npc defaults

echo "NPC 客户端安装完成，init.d 脚本已创建并配置。"
