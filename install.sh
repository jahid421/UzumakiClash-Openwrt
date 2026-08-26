#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════
# 🌀 UzumakiClash - Master Installer (Sharingan Edition)
# Developed by: Jahid Hasan Shuvo (@crazy_boy_jahid)
# ═══════════════════════════════════════════════════════════════════════

REPO="https://raw.githubusercontent.com/jahid421/UzumakiClash-Openwrt/main"
V="v1.18.10"
D="/etc/mihomo"

# 🌀 Sharingan Spinner Logic
sharingan_eye() {
    local pid=$!
    local delay=0.1
    local frames='◜ ◠ ◝ ◞ ◡ ◟'
    while [ "$(ps | awk '{print $1}' | grep $pid)" ]; do
        for frame in $frames; do
            printf "\r \e[31m🌀 Connecting... $frame \e[0m"
            sleep $delay
        done
    done
    printf "\r \e[32m🌀 Connection Success! ✅\e[0m\n"
}

# ব্যানার টাইপিং ইফেক্ট
type_fast() {
    text="$1"
    printf "\e[1;31m"
    i=0
    while [ $i -lt ${#text} ]; do
        printf "${text:$i:1}"
        i=$((i+1))
        sleep 0.02
    done
    printf "\e[0m\n"
}

clear
echo -e "\e[31m"
echo "  __  _ _____ _   _ __  __  _   _  _  ___ _      ___ _      _   ___ _  _ "
echo " |  || |__  /| | | |  \/  |/_\ | |/ /|_ _| |    / __| |    /_\ / __| || |"
echo " |  || | / / | |_| | |\/| / _ \| ' <  | || |__ | (__| |__ / _ \\__ \ __ |"
echo "  \__/  /_/   \___/|_|  |_/_/ \_\_|\_\|___|____| \___|____/_/ \_\___/_||_|"
echo -e "\e[1;37m     Developed by: Jahid Hasan Shuvo (@crazy_boy_jahid)\e[0m"
echo " -----------------------------------------------------------------------"

type_fast ">>> Awakening the Sharingan... System Check Initialized..."
sleep 1

A="${DISTRIB_ARCH:-$(uname -m)}"
case "$A" in
    x86_64*|amd64*) M="amd64-compatible" ;;
    aarch64*|arm64*) M="arm64" ;;
    armv7*) M="armv7" ;;
    mipsel*) M="mipsle-softfloat" ;;
    mips*) M="mips-softfloat" ;;
    *) M="amd64-compatible" ;;
esac

echo -n "Installing System Dependencies... "
(
    if command -v apk >/dev/null 2>&1; then
        apk update && apk add curl ca-bundle ip-full kmod-tun coreutils-nohup
    else
        opkg update && opkg install curl ca-bundle ip-full kmod-tun coreutils-nohup luci-compat
    fi
) >/dev/null 2>&1 & sharingan_eye

echo -n "Downloading Uzumaki Core Engine ($M)... "
(
    cd /tmp && curl -sL -o mihomo.gz "https://github.com/MetaCubeX/mihomo/releases/download/$V/mihomo-linux-$M-$V.gz"
    gunzip -f mihomo.gz && chmod +x mihomo && mv mihomo /usr/bin/mihomo
) >/dev/null 2>&1 & sharingan_eye

echo -n "Injecting Uzumaki Scripts & Rules... "
(
    mkdir -p $D/ui /www/cgi-bin /usr/lib/lua/luci/controller /usr/lib/lua/luci/view/mihomo
    curl -sL -o /etc/init.d/mihomo "$REPO/files/mihomo.init" && chmod +x /etc/init.d/mihomo
    curl -sL -o /www/cgi-bin/mihomo-api "$REPO/files/mihomo-api" && chmod +x /www/cgi-bin/mihomo-api
    curl -sL -o /www/cgi-bin/mihomo-cfg "$REPO/files/mihomo-cfg" && chmod +x /www/cgi-bin/mihomo-cfg
    curl -sL -o /www/cgi-bin/mihomo-sub "$REPO/files/mihomo-sub" && chmod +x /www/cgi-bin/mihomo-sub
    curl -sL -o $D/nft.conf "$REPO/files/nft.conf"
    curl -sL -o $D/config.yaml "$REPO/files/config.default.yaml"
    curl -sL -o /usr/lib/lua/luci/controller/mihomo.lua "$REPO/files/mihomo.lua"
    curl -sL -o /usr/lib/lua/luci/view/mihomo/main.htm "$REPO/files/main.htm"
) >/dev/null 2>&1 & sharingan_eye

echo -n "Optimizing Network & Activating Genjutsu... "
(
    /etc/init.d/mihomo enable && /etc/init.d/mihomo restart
    rm -rf /tmp/luci-* && /etc/init.d/rpcd restart && /etc/init.d/uhttpd restart
) >/dev/null 2>&1 & sharingan_eye

echo -e "\n\e[1;32m  ✅ UZUMAKI CLASH ACTIVATED SUCCESSFULLY!\e[0m"
echo -e "\e[1;31m  🌀 Developed by Jahid Hasan Shuvo\e[0m"
echo " -----------------------------------------------------------------------"
echo -e "  🌐 Dashboard: http://$(uci -q get network.lan.ipaddr || echo '192.168.1.1')/cgi-bin/luci/admin/services/mihomo"
echo " -----------------------------------------------------------------------"
