#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════
# 🌀 UzumakiClash - Universal Master Installer (OpenWrt v19 to v25+)
# Repo: https://github.com/jahid421/UzumakiClash-Openwrt
# Developer: Jahid Hasan Shuvo (@crazy_boy_jahid)
# ═══════════════════════════════════════════════════════════════════════

REPO="https://raw.githubusercontent.com/jahid421/UzumakiClash-Openwrt/main"
V="v1.18.10"
D="/etc/mihomo"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  🌀 UzumakiClash Universal Installer (v19 - v25+)             ║"
echo "║  Auto-Detect: opkg/apk | iptables/nftables | Universal Arch  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

[ ! -f /etc/openwrt_release ] && { echo "❌ ERROR: This script only works on OpenWrt!"; exit 1; }

. /etc/openwrt_release 2>/dev/null
OWRT_VER="${DISTRIB_RELEASE:-Snapshot}"
echo "[✓] OpenWrt detected: $DISTRIB_ID $OWRT_VER"

if command -v apk >/dev/null 2>&1; then
    PKG_TYPE="apk"
    echo "[✓] Package Engine: apk (OpenWrt v25+ Detected)"
    apk update >/dev/null 2>&1 || true
    pkg_install() { apk add "$@" >/dev/null 2>&1 || true; }
elif command -v opkg >/dev/null 2>&1; then
    PKG_TYPE="opkg"
    echo "[✓] Package Engine: opkg (OpenWrt v19-v24 Detected)"
    opkg update >/dev/null 2>&1 || true
    pkg_install() { opkg install "$@" >/dev/null 2>&1 || true; }
else
    echo "❌ No supported package manager found!"
    exit 1
fi

echo "[*] Installing dependencies..."
pkg_install curl ca-bundle ca-certificates ip-full kmod-tun coreutils-nohup

if command -v nft >/dev/null 2>&1; then
    pkg_install kmod-nft-tproxy
else
    pkg_install iptables-mod-tproxy kmod-ipt-tproxy iptables-mod-extra
fi

if [ "$PKG_TYPE" = "opkg" ]; then
    pkg_install luci-compat luci-lib-ipkg luci-lib-nixio
fi

dl() {
    if command -v curl >/dev/null 2>&1; then
        curl -sL -k -o "$2" "$1" 2>/dev/null
    else
        wget -q --no-check-certificate -O "$2" "$1" 2>/dev/null
    fi
}

A="${DISTRIB_ARCH:-$(uname -m)}"
echo "[*] Detecting CPU Architecture: $A"

case "$A" in
    x86_64*|amd64*) M="amd64-compatible" ;;
    aarch64*|arm64*) M="arm64" ;;
    armv7*|arm_cortex-a7*|arm_cortex-a9*|arm_cortex-a15*|arm_cortex-a53*) M="armv7" ;;
    armv6*|arm_arm1176*) M="armv6" ;;
    armv5*|arm_arm926*) M="armv5" ;;
    mipsel*|mipsle*|mipsel_24kc*|mipsel_74kc*) M="mipsle-softfloat" ;;
    mips*|mips_24kc*|mips_4kec*) M="mips-softfloat" ;;
    *) M="amd64-compatible" ;;
esac
echo "[✓] Selected Core Binary: mihomo-linux-$M-$V"

echo "[*] Downloading Core Engine..."
cd /tmp && rm -f mihomo.gz mihomo
dl "https://github.com/MetaCubeX/mihomo/releases/download/$V/mihomo-linux-$M-$V.gz" mihomo.gz
[ -s mihomo.gz ] || { echo "❌ Core download failed!"; exit 1; }

gunzip -f mihomo.gz 2>/dev/null || true
chmod +x mihomo
mv mihomo /usr/bin/mihomo
echo "[✓] Core Engine verified and installed"

mkdir -p $D/ui $D/profiles /www/cgi-bin /usr/lib/lua/luci/controller /usr/lib/lua/luci/view/mihomo

echo "0" > $D/transparent
echo "0" > $D/enabled

echo "[*] Injecting Uzumaki Scripts..."
dl "$REPO/files/mihomo.init" /etc/init.d/mihomo
chmod +x /etc/init.d/mihomo
dl "$REPO/files/config.default.yaml" $D/config.yaml
dl "$REPO/files/nft.conf" $D/nft.conf

dl "$REPO/files/mihomo-api" /www/cgi-bin/mihomo-api
dl "$REPO/files/mihomo-cfg" /www/cgi-bin/mihomo-cfg
dl "$REPO/files/mihomo-sub" /www/cgi-bin/mihomo-sub
chmod +x /www/cgi-bin/mihomo-*

dl "$REPO/files/mihomo.lua" /usr/lib/lua/luci/controller/mihomo.lua
dl "$REPO/files/main.htm" /usr/lib/lua/luci/view/mihomo/main.htm

if [ -d /usr/share/luci/menu.d ]; then
    cat > /usr/share/luci/menu.d/luci-app-uzumakiclash.json << 'JSONEOF'
{
    "admin/services/mihomo": {
        "title": "UzumakiClash \ud83c\udf00",
        "order": 60,
        "action": {
            "type": "template",
            "path": "mihomo/main"
        }
    }
}
JSONEOF
fi

# বুট এনাবল করা ও ক্যাশ ক্লিন
/etc/init.d/mihomo enable
/etc/init.d/mihomo restart >/dev/null 2>&1
rm -rf /tmp/luci-*
/etc/init.d/rpcd restart >/dev/null 2>&1
/etc/init.d/uhttpd restart >/dev/null 2>&1

LAN_IP=$(uci -q get network.lan.ipaddr || echo "192.168.1.1")

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "🌀 UzumakiClash Fixed Version Installed Successfully!"
echo "   🌐 Dashboard: http://$LAN_IP/cgi-bin/luci/admin/services/mihomo"
echo "══════════════════════════════════════════════════════════════"
