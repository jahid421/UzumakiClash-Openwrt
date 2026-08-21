#!/bin/sh
# ═══════════════════════════════════════════════
# 🌀 UzumakiClash - Master Installer
# ═══════════════════════════════════════════════

REPO="https://raw.githubusercontent.com/jahid421/UzumakiClash/main"
V="v1.18.10"
D="/etc/mihomo"

echo ""
echo "╔══════════════════════════════════════╗"
echo "║  🌀 UzumakiClash for OpenWrt         ║"
echo "║  Ultra Lightweight & Lightning Fast  ║"
echo "╚══════════════════════════════════════╝"
echo ""

[ ! -f /etc/openwrt_release ] && { echo "❌ Only works on OpenWrt!"; exit 1; }

if command -v apk >/dev/null 2>&1; then
    apk update >/dev/null 2>&1
    PKG_INSTALL="apk add"
else
    opkg update >/dev/null 2>&1
    PKG_INSTALL="opkg install"
fi

echo "[*] Installing core dependencies..."
for p in curl ca-bundle ca-certificates ip-full kmod-tun kmod-nft-tproxy iptables-mod-tproxy; do
    $PKG_INSTALL $p >/dev/null 2>&1 || true
done

dl() {
    curl -sL -k -o "$2" "$1" 2>/dev/null || wget -q --no-check-certificate -O "$2" "$1" 2>/dev/null
}

A=$(uname -m)
case "$A" in
    x86_64*|amd64*) M="amd64-compatible" ;;
    aarch64*|arm64*) M="arm64" ;;
    armv7*) M="armv7" ;;
    mipsel*|mipsle*) M="mipsle-softfloat" ;;
    mips*) M="mips-softfloat" ;;
    *) M="amd64-compatible" ;;
esac

echo "[*] Downloading Core Engine ($M)..."
cd /tmp && rm -f mihomo.gz mihomo
dl "https://github.com/MetaCubeX/mihomo/releases/download/$V/mihomo-linux-$M-$V.gz" mihomo.gz
gunzip -f mihomo.gz 2>/dev/null || true
chmod +x mihomo
mv mihomo /usr/bin/mihomo

mkdir -p $D/ui /www/cgi-bin /usr/lib/lua/luci/controller /usr/lib/lua/luci/view/mihomo

echo "0" > $D/transparent
echo "0" > $D/enabled

echo "[*] Fetching GeoData & Offline UI..."
dl "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip-lite.dat" $D/geoip.dat
dl "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat" $D/geosite.dat
dl "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/country-lite.mmdb" $D/Country.mmdb

cd /tmp && dl "https://github.com/MetaCubeX/metacubexd/releases/latest/download/compressed-dist.tgz" ui.tgz
tar -xzf ui.tgz -C $D/ui/ 2>/dev/null && rm -f ui.tgz
[ -d "$D/ui/dist" ] && mv $D/ui/dist/* $D/ui/ 2>/dev/null && rm -rf $D/ui/dist

echo "[*] Injecting Uzumaki Engine Scripts..."
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

mkdir -p /etc/hotplug.d/iface
cat > /etc/hotplug.d/iface/99-uzumaki << 'HEOF'
#!/bin/sh
[ "$ACTION" = "ifup" ] && [ -f /etc/mihomo/transparent ] && [ "$(cat /etc/mihomo/transparent)" = "1" ] && {
    /etc/init.d/mihomo restart >/dev/null 2>&1
}
HEOF

rm -rf /tmp/luci-*
/etc/init.d/rpcd restart >/dev/null 2>&1
/etc/init.d/uhttpd restart >/dev/null 2>&1

echo ""
echo "═══════════════════════════════════════"
echo "🌀 UzumakiClash Installed Successfully!"
echo "   Access LuCI -> Services -> UzumakiClash 🌀"
echo "═══════════════════════════════════════"
