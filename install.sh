#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════
# 🌀 UzumakiClash - Master Installer
# Repo: https://github.com/jahid421/UzumakiClash-Openwrt
# Developer: Jahid Hasan Shuvo (@crazy_boy_jahid)
# ═══════════════════════════════════════════════════════════════════════

REPO="https://raw.githubusercontent.com/jahid421/UzumakiClash-Openwrt/main"
V="v1.18.10"
D="/etc/mihomo"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  🌀 UzumakiClash Universal Installer                       ║"
echo "║  Auto-Detect: opkg/apk | TCP + UDP | Low-RAM              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# ==============================================================
# PACKAGE MANAGER
# ==============================================================
if command -v apk >/dev/null 2>&1; then
    PKG="apk"

    apk update >/dev/null 2>&1

    pkg_ins() {
        apk add "$@"
    }
else
    PKG="opkg"

    opkg update >/dev/null 2>&1

    pkg_ins() {
        opkg install "$@"
    }
fi

echo "[*] Installing dependencies..."

pkg_ins \
    curl \
    ca-bundle \
    ca-certificates \
    ip-full \
    kmod-tun \
    kmod-nf-conntrack \
    kmod-nf-tproxy \
    kmod-nft-core \
    kmod-nft-tproxy \
    nftables \
    coreutils-nohup \
    gzip \
    tar \
    busybox

if [ "$PKG" = "opkg" ]; then
    pkg_ins luci-compat luci-lib-ipkg
fi

# ==============================================================
# ARCHITECTURE DETECTION
# ==============================================================
RAW_ARCH=""

if command -v opkg >/dev/null 2>&1; then
    RAW_ARCH=$(
        opkg print-architecture 2>/dev/null |
        grep -E "mipsel_24kc|mipsel" |
        awk '{print $2}' |
        head -n 1
    )
fi

[ -z "$RAW_ARCH" ] && RAW_ARCH=$(uname -m)

case "$RAW_ARCH" in
    mipsel*|mipsle*)
        M="mipsle-softfloat"
        ;;
    mips*)
        M="mips-softfloat"
        ;;
    aarch64*|arm64*)
        M="arm64"
        ;;
    armv7*|armhf*)
        M="armv7"
        ;;
    x86_64*|amd64*)
        M="amd64-compatible"
        ;;
    *)
        echo "[!] Unsupported architecture: $RAW_ARCH"
        exit 1
        ;;
esac

echo "[✓] Architecture: $RAW_ARCH -> $M"

# ==============================================================
# MIHOMO CORE
# ==============================================================
echo "[*] Installing Mihomo core..."

cd /tmp || exit 1

rm -f mihomo mihomo.gz

CORE_URL="https://github.com/MetaCubeX/mihomo/releases/download/$V/mihomo-linux-$M-$V.gz"

if ! curl -fLs \
    --connect-timeout 15 \
    --max-time 120 \
    -o mihomo.gz \
    "$CORE_URL"
then
    echo "[!] Mihomo download failed."
    exit 1
fi

if ! gzip -d -f mihomo.gz; then
    echo "[!] Mihomo extraction failed."
    exit 1
fi

if [ ! -s mihomo ]; then
    echo "[!] Mihomo binary is missing."
    exit 1
fi

chmod +x mihomo
mv mihomo /usr/bin/mihomo

echo "[✓] Mihomo installed."

# ==============================================================
# DIRECTORIES
# ==============================================================
mkdir -p \
    "$D/ui" \
    /www/cgi-bin \
    /usr/lib/lua/luci/controller \
    /usr/lib/lua/luci/view/mihomo

# ==============================================================
# DOWNLOAD HELPER
# ==============================================================
download_file() {

    SRC="$1"
    DST="$2"

    echo "[*] Installing $SRC"

    if ! curl -fLs \
        --connect-timeout 15 \
        --max-time 60 \
        -o "$DST" \
        "$REPO/$SRC"
    then
        echo "[!] Failed: $SRC"
        return 1
    fi

    return 0
}

# ==============================================================
# PROJECT FILES
# ==============================================================
download_file files/mihomo.init \
    /etc/init.d/mihomo || exit 1

download_file files/mihomo-api \
    /www/cgi-bin/mihomo-api || exit 1

download_file files/mihomo-cfg \
    /www/cgi-bin/mihomo-cfg || exit 1

download_file files/mihomo-sub \
    /www/cgi-bin/mihomo-sub || exit 1

download_file files/nft.conf \
    "$D/nft.conf" || exit 1

download_file files/config.default.yaml \
    "$D/config.default.yaml" || exit 1

download_file files/mihomo.lua \
    /usr/lib/lua/luci/controller/mihomo.lua || exit 1

download_file files/main.htm \
    /usr/lib/lua/luci/view/mihomo/main.htm || exit 1

chmod +x \
    /etc/init.d/mihomo \
    /www/cgi-bin/mihomo-api \
    /www/cgi-bin/mihomo-cfg \
    /www/cgi-bin/mihomo-sub

# ==============================================================
# STATE
# ==============================================================
[ -f "$D/enabled" ] || echo "1" > "$D/enabled"
[ -f "$D/transparent" ] || echo "1" > "$D/transparent"

# Do not destroy an existing working config.
if [ ! -f "$D/config.yaml" ]; then
    cp "$D/config.default.yaml" "$D/config.yaml"
fi

# ==============================================================
# DASHBOARD
# ==============================================================
echo "[*] Installing MetaCubeXD..."

cd /tmp || exit 1

rm -f ui.tgz

if curl -fLs \
    --connect-timeout 15 \
    --max-time 120 \
    -o ui.tgz \
    "https://github.com/MetaCubeX/metacubexd/releases/latest/download/compressed-dist.tgz"
then

    rm -rf "$D/ui"/*

    tar -xzf ui.tgz \
        -C "$D/ui/" 2>/dev/null || true

    if [ -d "$D/ui/dist" ]; then
        cp -a "$D/ui/dist"/. "$D/ui"/
        rm -rf "$D/ui/dist"
    fi
fi

# ==============================================================
# BASIC CHECKS
# ==============================================================
echo "[*] Checking scripts..."

sh -n /etc/init.d/mihomo || exit 1
sh -n /www/cgi-bin/mihomo-api || exit 1
sh -n /www/cgi-bin/mihomo-cfg || exit 1
sh -n /www/cgi-bin/mihomo-sub || exit 1

echo "[✓] Shell syntax OK."

echo "[*] Checking Mihomo configuration..."

if /usr/bin/mihomo \
    -d "$D" \
    -f "$D/config.yaml" \
    -t >/tmp/uzumaki-config-test.log 2>&1
then
    echo "[✓] Configuration test successful."
else
    echo "[!] Current configuration failed validation:"
    cat /tmp/uzumaki-config-test.log
fi

echo "[*] Checking nft.conf..."

if nft -c -f "$D/nft.conf" >/tmp/uzumaki-nft-test.log 2>&1; then
    echo "[✓] nft.conf syntax OK."
else
    echo "[!] nft.conf test failed:"
    cat /tmp/uzumaki-nft-test.log
fi

# ==============================================================
# ENABLE + START
# ==============================================================
/etc/init.d/mihomo enable >/dev/null 2>&1

echo "[*] Starting UzumakiClash..."

/etc/init.d/mihomo restart

sleep 3

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "✅ UzumakiClash installation completed."
echo "══════════════════════════════════════════════════════════════"
echo ""
