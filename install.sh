#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════
# 🌀 UzumakiClash - Master Installer (Universal Precision Edition)
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

# 1. Package Manager Detection & Dependency Installation
if command -v apk >/dev/null 2>&1; then
    PKG="apk"
    echo "[*] Package Manager Detected: APK"
    apk update >/dev/null 2>&1
    pkg_ins() { apk add --no-cache "$@"; }
else
    PKG="opkg"
    echo "[*] Package Manager Detected: OPKG"
    opkg update >/dev/null 2>&1
    pkg_ins() { opkg install "$@"; }
fi

echo "[*] Installing required dependencies..."
pkg_ins curl ca-bundle ca-certificates ip-full kmod-tun coreutils-nohup gzip tar busybox nftables
[ "$PKG" = "opkg" ] && pkg_ins luci-compat luci-lib-ipkg >/dev/null 2>&1

# 2. Smart & Universal CPU Architecture Detection
ARCH=$(uname -m)
case "$ARCH" in
    aarch64*|arm64*) M="arm64" ;;
    x86_64*|amd64*) M="amd64-compatible" ;;
    armv7*) M="armv7" ;;
    armv6*) M="armv5" ;;
    mipsle*|mipsel*) M="mipsle-softfloat" ;;
    mips*) M="mips-softfloat" ;;
    *)
        if command -v opkg >/dev/null 2>&1; then
            RAW_ARCH=$(opkg print-architecture 2>/dev/null | grep -E "mipsel|ramips|aarch64|x86_64|arm" | head -n 1 | awk '{print $2}')
            case "$RAW_ARCH" in
                *mipsel*|*ramips*) M="mipsle-softfloat" ;;
                *aarch64*) M="arm64" ;;
                *x86_64*) M="amd64-compatible" ;;
                *arm*) M="armv7" ;;
                *) M="mipsle-softfloat" ;;
            esac
        else
            M="mipsle-softfloat"
        fi
        ;;
esac

echo "[✓] Detected Architecture: $ARCH -> Core Target: $M"

# 3. Core Binary Download & Verification
echo "[*] Downloading Mihomo Engine ($V)..."
cd /tmp && rm -f mihomo.gz mihomo
curl -sL -o mihomo.gz "https://github.com/MetaCubeX/mihomo/releases/download/$V/mihomo-linux-$M-$V.gz"

if [ -f mihomo.gz ]; then
    gzip -d -f mihomo.gz 2>/dev/null || gunzip -f mihomo.gz 2>/dev/null
    chmod +x mihomo
    if [ -s mihomo ]; then
        mv mihomo /usr/bin/mihomo
        echo "[✓] Mihomo Core installed successfully!"
    else
        echo "❌ Core Extraction Failed! Check system space."
        exit 1
    fi
else
    echo "❌ Core Download Failed! Check internet connection."
    exit 1
fi

# 4. Directory Setup & File Synchronization
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

# 5. GeoData Database Download
echo "[*] Downloading GeoData Databases..."
cd $D
curl -sL -o Country.mmdb "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/country-lite.mmdb"
curl -sL -o geoip.dat "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip-lite.dat"
curl -sL -o geosite.dat "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat"

# 6. Web Dashboard Installation
echo "[*] Installing Web UI Dashboard..."
cd /tmp && rm -rf ui.tgz dist
curl -sL -o ui.tgz "https://github.com/MetaCubeX/metacubexd/releases/latest/download/compressed-dist.tgz"
if [ -f ui.tgz ]; then
    tar -xzf ui.tgz -C $D/ui/ 2>/dev/null
    if [ -d "$D/ui/dist" ]; then
        mv $D/ui/dist/* $D/ui/ 2>/dev/null
        rm -rf $D/ui/dist
    fi
    rm -f ui.tgz
fi

# 7. Enable Service & Clear Cache
echo "[*] Starting Services..."
echo "1" > $D/enabled
echo "1" > $D/transparent

/etc/init.d/mihomo enable
/etc/init.d/mihomo restart

rm -rf /tmp/luci-* /tmp/luci-indexcache 2>/dev/null
/etc/init.d/rpcd restart 2>/dev/null
/etc/init.d/uhttpd restart 2>/dev/null

echo ""
echo "══════════════════════════════════════════════════════════════"
echo " ✅ UzumakiClash Ultimate Fixed Version Installed!"
echo " 🌐 Access OpenWrt LuCI -> UzumakiClash Menu"
echo "══════════════════════════════════════════════════════════════"
