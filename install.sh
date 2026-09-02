#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════
# 🌀 UzumakiClash - Master Installer (Final Precision Edition)
# Repo: https://github.com/jahid421/UzumakiClash-Openwrt
# Developer: Jahid Hasan Shuvo (@crazy_boy_jahid)
# ═══════════════════════════════════════════════════════════════════════

REPO="https://raw.githubusercontent.com/jahid421/UzumakiClash-Openwrt/main"
V="v1.18.10"; D="/etc/mihomo"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  🌀 UzumakiClash Universal Installer (Fixed Edition)          ║"
echo "║  Auto-Detect: opkg/apk | Precision Arch | Turbo Gaming       ║"
echo "╚══════════════════════════════════════════════════════════════╝"

# ১. ডিপেন্ডেন্সি চেক
if command -v apk >/dev/null 2>&1; then
    PKG="apk"
    echo "[*] Updating package manager (apk)..."
    apk update >/dev/null 2>&1
    pkg_ins() { apk add --no-cache "$@"; }
else
    PKG="opkg"
    echo "[*] Updating package manager (opkg)..."
    opkg update >/dev/null 2>&1
    pkg_ins() { opkg install "$@"; }
fi

echo "[*] Installing required dependencies..."
pkg_ins curl ca-bundle ca-certificates ip-full kmod-tun coreutils-nohup gzip tar busybox nftables
[ "$PKG" = "opkg" ] && pkg_ins luci-compat luci-lib-ipkg >/dev/null 2>&1

# ২. আর্কিটেকচার ডিটেকশন
RAW_ARCH=""
if command -v opkg >/dev/null 2>&1; then
    RAW_ARCH=$(opkg print-architecture 2>/dev/null | grep -E "mipsel_24kc|mipsel|ramips" | awk '{print $2}' | head -n 1)
fi
[ -z "$RAW_ARCH" ] && RAW_ARCH=$(uname -m)

case "$RAW_ARCH" in
    mipsel*|mipsle*) M="mipsle-softfloat" ;;
    mips*) M="mips-softfloat" ;;
    aarch64*|arm64*) M="arm64" ;;
    x86_64*|amd64*) M="amd64-compatible" ;;
    armv7*) M="armv7" ;;
    *) M="mipsle-softfloat" ;; 
esac

echo "[✓] Precise Architecture: $RAW_ARCH -> Core: $M"

# ৩. কোর ডাউনলোড
echo "[*] Downloading Mihomo Core Engine..."
cd /tmp && rm -f mihomo.gz mihomo
curl -sL -o mihomo.gz "https://github.com/MetaCubeX/mihomo/releases/download/$V/mihomo-linux-$M-$V.gz"

if [ -f mihomo.gz ]; then
    gzip -d -f mihomo.gz 2>/dev/null || gunzip -f mihomo.gz 2>/dev/null
    chmod 755 mihomo 2>/dev/null
    if [ -s mihomo ]; then
        mv mihomo /usr/bin/mihomo
        echo "[✓] Mihomo Core installed successfully!"
    else
        echo "❌ Core extraction failed!"
        exit 1
    fi
else
    echo "❌ Core download failed! Check your internet connection."
    exit 1
fi

# ৪. ডিরেক্টরি এবং ফাইল সিঙ্ক
echo "[*] Syncing UzumakiClash System Files..."
mkdir -p $D/ui /www/cgi-bin /usr/lib/lua/luci/controller /usr/lib/lua/luci/view/mihomo

curl -sL -o /etc/init.d/mihomo "$REPO/files/mihomo.init" && chmod 755 /etc/init.d/mihomo
curl -sL -o /www/cgi-bin/mihomo-api "$REPO/files/mihomo-api" && chmod 755 /www/cgi-bin/mihomo-api
curl -sL -o /www/cgi-bin/mihomo-cfg "$REPO/files/mihomo-cfg" && chmod 755 /www/cgi-bin/mihomo-cfg
curl -sL -o /www/cgi-bin/mihomo-sub "$REPO/files/mihomo-sub" && chmod 755 /www/cgi-bin/mihomo-sub
curl -sL -o $D/nft.conf "$REPO/files/nft.conf"
curl -sL -o $D/config.yaml "$REPO/files/config.default.yaml"
curl -sL -o /usr/lib/lua/luci/controller/mihomo.lua "$REPO/files/mihomo.lua"
curl -sL -o /usr/lib/lua/luci/view/mihomo/main.htm "$REPO/files/main.htm"

# ৫. জিও-ডাটাবেজ ডাউনলোড
echo "[*] Downloading GeoData Databases..."
cd $D
curl -sL -o Country.mmdb "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/country-lite.mmdb"
curl -sL -o geoip.dat "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip-lite.dat"
curl -sL -o geosite.dat "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat"

# ৬. ড্যাশবোর্ড রিস্টোর
echo "[*] Setting up Web Dashboard UI..."
cd /tmp && rm -rf ui.tgz dist
curl -sL -o ui.tgz "https://github.com/MetaCubeX/metacubexd/releases/latest/download/compressed-dist.tgz"
if [ -f ui.tgz ]; then
    tar -xzf ui.tgz -C $D/ui/ 2>/dev/null
    [ -d "$D/ui/dist" ] && mv $D/ui/dist/* $D/ui/ 2>/dev/null && rm -rf $D/ui/dist
    rm -f ui.tgz
fi

# ৭. Kernel IP Routing Enable (Crucial)
sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1

# ৮. বুট এবং ক্যাশ ক্লিয়ার
echo "[*] Enabling Services..."
echo "1" > $D/enabled
echo "1" > $D/transparent

/etc/init.d/mihomo enable && /etc/init.d/mihomo restart
rm -rf /tmp/luci-* /tmp/luci-indexcache 2>/dev/null
/etc/init.d/rpcd restart 2>/dev/null
/etc/init.d/uhttpd restart 2>/dev/null

echo ""
echo "✅ UzumakiClash Ultimate Fixed Version Installed!"
echo "🔗 Dashboard: http://$(uci get network.lan.ipaddr):9595/ui"
echo "🔑 Secret: flclash123"
