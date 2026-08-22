#!/bin/sh /etc/rc.common
USE_PROCD=1
START=95
STOP=05

CONF_DIR="/etc/mihomo"
PROG="/usr/bin/mihomo"
ENABLED_FILE="$CONF_DIR/enabled"

should_start() {
    [ -f "$ENABLED_FILE" ] && [ "$(cat "$ENABLED_FILE")" = "0" ] && return 1
    return 0
}

start_service() {
    if ! should_start; then
        return 0
    fi

    # Low-RAM Optimization
    RAM_KB=$(awk '/MemTotal/{print $2}' /proc/meminfo)
    if [ "$RAM_KB" -lt 262144 ]; then
        export GOMEMLIMIT=35MiB
        export GOGC=20
    else
        export GOMEMLIMIT=120MiB
        export GOGC=50
    fi

    procd_open_instance mihomo
    procd_set_param command "$PROG" -d "$CONF_DIR" -f "$CONF_DIR/config.yaml"
    procd_set_param respawn 3600 5 3
    procd_set_param limits nofile="1048576 1048576"
    procd_set_param stdout 0
    procd_set_param stderr 1
    procd_set_param pidfile /var/run/mihomo.pid
    procd_close_instance

    logger -t uzumaki "🌀 UzumakiClash Started in TUN Auto-Route Mode."
}

stop_service() {
    killall -9 mihomo 2>/dev/null || true
    logger -t uzumaki "🌀 UzumakiClash Stopped cleanly."
}

service_triggers() {
    procd_add_reload_trigger "mihomo"
}
