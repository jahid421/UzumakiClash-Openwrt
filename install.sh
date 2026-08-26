#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════
# 🌀 UzumakiClash - Universal Master Installer (Sharingan Edition)
# Repo: https://github.com/jahid421/UzumakiClash-Openwrt
# Developer: Jahid Hasan Shuvo (@crazy_boy_jahid)
# ═══════════════════════════════════════════════════════════════════════

REPO="https://raw.githubusercontent.com/jahid421/UzumakiClash-Openwrt/main"
V="v1.18.10"
D="/etc/mihomo"

# --- 🌀 Sharingan Animation Logic ---
sharingun() {
    local pid=$!
    local delay=0.1
    local spinstr='.,°øOø°.,'
    while [ "$(ps | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        # \e[31m হচ্ছ লাল রঙ (Sharingan Red)
        printf "\e[31m%c\e[0m" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b"
    done
    printf "\b\e[32m [Done! ✅]\e[0m\n"
}

type_text() {
    text="$1"
    i=0
    while [ $i -lt ${#text} ]; do
        printf "${text:$i:1}"
        i=$((i+1))
        sleep 0.03
    done
    echo ""
}

# --- 🌀 Setup Starts ---
clear
echo -e "\e[31m"
echo "   ▄█    █▄       ▀█████████▄   ███    █▄     ▄▄▄▄███▄▄▄▄      ▄████████    ▄█   ▄█▄  ▄█  "
echo "  ███    ███        ███    ███  ███    ███  ▄██▀▀▀███▀▀▀██▄   ███    ███   ███ ▄███▀ ███  "
echo "  ███    ███        ███    ███  ███    ███  ███   ███   ███   ███    ███   ███▐██▀   ███  "
echo "  ███    ███       ▄███▄▄▄██▀   ███    ███  ███   ███   ███   ███    ███  ▄█████▀    ███  "
echo "  ███    ███      ▀▀███▄▄▄██▀   ███    ███  ███   ███   ███ ▀███████████ ▀▀█████▄    ███  "
echo "  ███    ███        ███    ███  ███    ███  ███   ███   ███   ███    ███   ███▐██▄   ███  "
echo "  ███    ███        ███    ███  ███    ███  ███   ███   ███   ███    ███   ███ ▀███▄ ███  "
echo "   ▀██████▀       ▄█████████▀   ████████▀    ▀█   ███   █▀    ███    █▀    ███   ▀█▀ █▀   "
echo -e "\e[1;37m     Developed by: Jahid Hasan Shuvo (@crazy_boy_jahid)\e[0m"
echo ""

type_text "🌀 Awakening Sharingan... Detecting System Environment..."
sleep 1

[ ! -f /etc/openwrt_release ] && { echo "❌ ERROR: This script only works on OpenWrt!"; exit 1; }

. /etc/openwrt_release 2>/dev/null
echo -e "[✓] OpenWrt: \e[36m$DISTRIB_ID $DISTRIB_RELEASE\e[0m"

if command -v apk >/dev/null 2>&1; then
    PKG_TYPE="apk"
    apk update >/dev/null 2>&1 || true
    pkg_install() { apk add "$@" >/dev/null 2>&1 || true; }
elif command -v opkg >/dev/null 2>&1; then
    PKG_TYPE="opkg"
    opkg update >/dev/null 2>&1 || true
    pkg_install() { opkg install "$@" >/dev/null 2>&1 || true; }
else
    echo "❌ No supported package manager found!"; exit 1
fi

echo -n "[*] Installing Dependencies "
pkg_install curl ca-bundle ca-certificates ip-full kmod-tun coreutils-nohup & sharingun

if command -v nft >/dev/null 2>&1; then
    pkg_install kmod-nft-tproxy & sharingun
else
    pkg_install iptables-mod-tproxy kmod-ipt-tproxy iptables-mod-extra & sharingun
fi

dl() {
    curl -sL -k -o "$2" "$1" 2>/dev/null || wget -q --no-check-certificate -O "$2" "$1" 2>/dev/null
}

A="${DISTRIB_ARCH:-$(uname -m)}"
case "$A" in
    x86_64*|amd64*) M="amd64-compatible" ;;
    aarch64*|arm64*) M="arm64" ;;
    armv7*) M="armv7" ;;
    mipsel*) M="mipsle-softfloat" ;;
    mips*) M="mips-softfloat" ;;
    *) M="amd64-compatible" ;;
esac

echo -n "[*] Downloading Uzumaki Core ($M) "
cd /tmp && rm -f mihomo.gz
dl "https://github.com/MetaCubeX/mihomo/releases/download/$V/mihomo-linux-$M-$V.gz" mihomo.gz & sharingun

gunzip -f mihomo.gz && chmod +x mihomo && mv mihomo /usr/bin/mihomo

mkdir -p $D/ui $D/profiles /www/cgi-bin /usr/lib/lua/luci/controller /usr/lib/lua/luci/view/mihomo
echo "0" > $D/transparent
echo "0" > $D/enabled

echo -n "[*] Fetching Scripts & Core Assets "
dl "$REPO/files/mihomo.init" /etc/init.d/mihomo && chmod +x /etc/init.d/mihomo &
dl "$REPO/files/mihomo-api" /www/cgi-bin/mihomo-api && chmod +x /www/cgi-bin/mihomo-* &
dl "$REPO/files/mihomo-cfg" /www/cgi-bin/mihomo-cfg &
dl "$REPO/files/mihomo-sub" /www/cgi-bin/mihomo-sub &
dl "$REPO/files/mihomo.lua" /usr/lib/lua/luci/controller/mihomo.lua &
dl "$REPO/files/main.htm" /usr/lib/lua/luci/view/mihomo/main.htm &
dl "$REPO/files/nft.conf" $D/nft.conf &
dl "$REPO/files/config.default.yaml" $D/config.yaml & sharingun

# LuCI Menu Setup
if [ -d /usr/share/luci/menu.d ]; then
    cat > /usr/share/luci/menu.d/luci-app-uzumakiclash.json << EOF
{"admin/services/mihomo":{"title":"UzumakiClash 🌀","order":60,"action":{"type":"template","path":"mihomo/main"}}}
EOF
fi

echo -n "[*] Finalizing System Integration "
/etc/init.d/mihomo enable >/dev/null 2>&1
/etc/init.d/mihomo restart >/dev/null 2>&1
rm -rf /tmp/luci-*
/etc/init.d/rpcd restart >/dev/null 2>&1
/etc/init.d/uhttpd restart >/dev/null 2>&1 & sharingun

echo -e "\n\e[31m🌀 UzumakiClash Activated! You are now under the Genjutsu of Speed.\e[0m"
echo -e "\e[1;37mDeveloped with ❤️ by Jahid Hasan Shuvo\e[0m"
echo "------------------------------------------------------"
echo -e "🌐 Dashboard: \e[32mhttp://$(uci -q get network.lan.ipaddr || echo "192.168.1.1")/cgi-bin/luci/admin/services/mihomo\e[0m"
echo "------------------------------------------------------"
