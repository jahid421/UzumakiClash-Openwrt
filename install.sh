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
echo "║  Auto-Detect: opkg/apk | Precision Arch | Stable Gateway   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# ─────────────────────────────────────────────
# Root check
# ─────────────────────────────────────────────

if [ "$(id -u)" != "0" ]; then
    echo "[✗] Please run as root."
    exit 1
fi

# ─────────────────────────────────────────────
# Package manager
# ─────────────────────────────────────────────

if command -v apk >/dev/null 2>&1; then

    PKG="apk"

    echo "[*] Using apk..."
    apk update >/dev/null 2>&1

    pkg_ins() {
        apk add "$@"
    }

else

    PKG="opkg"

    echo "[*] Using opkg..."
    opkg update >/dev/null 2>&1

    pkg_ins() {
        opkg install "$@"
    }

fi

# ─────────────────────────────────────────────
# Dependencies
# ─────────────────────────────────────────────

echo "[*] Installing dependencies..."

pkg_ins \
    curl \
    ca-bundle \
    ca-certificates \
    ip-full \
    kmod-tun \
    gzip \
    tar \
    busybox

# nftables / TPROXY support where available
pkg_ins nftables 2>/dev/null || true
pkg_ins kmod-nft-tproxy 2>/dev/null || true
pkg_ins kmod-nf-tproxy 2>/dev/null || true

if [ "$PKG" = "opkg" ]; then
    pkg_ins luci-compat 2>/dev/null || true
    pkg_ins luci-lib-ipkg 2>/dev/null || true
fi

# ─────────────────────────────────────────────
# Architecture detection
# ─────────────────────────────────────────────

RAW_ARCH=""

if command -v opkg >/dev/null 2>&1; then
    RAW_ARCH=$(
        opkg print-architecture 2>/dev/null |
        grep -E 'mipsel_24kc|mipsel' |
        awk '{print $2}' |
        head -n 1
    )
fi

[ -z "$RAW_ARCH" ] && RAW_ARCH="$(uname -m 2>/dev/null)"

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

    x86_64*|amd64*)
        M="amd64-compatible"
        ;;

    *)
        echo "[✗] Unsupported/unknown architecture: $RAW_ARCH"
        exit 1
        ;;

esac

echo "[✓] Architecture: $RAW_ARCH -> Mihomo core: $M"

# ─────────────────────────────────────────────
# Download Mihomo
# ─────────────────────────────────────────────

TMP_DIR="/tmp/uzumakiclash"

rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

cd "$TMP_DIR" || exit 1

echo "[*] Downloading Mihomo $V..."

if ! curl -fL \
    --connect-timeout 15 \
    --max-time 180 \
    -o mihomo.gz \
    "https://github.com/MetaCubeX/mihomo/releases/download/$V/mihomo-linux-$M-$V.gz"
then
    echo "[✗] Mihomo download failed."
    rm -rf "$TMP_DIR"
    exit 1
fi

if ! gzip -d -f mihomo.gz 2>/dev/null; then
    if ! gunzip -f mihomo.gz 2>/dev/null; then
        echo "[✗] Unable to decompress Mihomo."
        rm -rf "$TMP_DIR"
        exit 1
    fi
fi

if [ ! -f mihomo ]; then
    echo "[✗] Mihomo binary not found after extraction."
    rm -rf "$TMP_DIR"
    exit 1
fi

chmod +x mihomo

mv -f mihomo /usr/bin/mihomo

if [ ! -x /usr/bin/mihomo ]; then
    echo "[✗] Mihomo installation failed."
    rm -rf "$TMP_DIR"
    exit 1
fi

echo "[✓] Mihomo core installed."

# ─────────────────────────────────────────────
# Directories
# ─────────────────────────────────────────────

mkdir -p \
    "$D/ui" \
    /www/cgi-bin \
    /usr/lib/lua/luci/controller \
    /usr/lib/lua/luci/view/mihomo

# ─────────────────────────────────────────────
# Download project files
# ─────────────────────────────────────────────

echo "[*] Installing UzumakiClash files..."

download_file() {
    SRC="$1"
    DST="$2"

    if ! curl -fsSL \
        --connect-timeout 15 \
        --max-time 120 \
        -o "$DST" \
        "$SRC"
    then
        echo "[✗] Failed: $DST"
        return 1
    fi

    return 0
}

download_file \
    "$REPO/files/mihomo.init" \
    "/etc/init.d/mihomo" || exit 1

download_file \
    "$REPO/files/mihomo-api" \
    "/www/cgi-bin/mihomo-api" || exit 1

download_file \
    "$REPO/files/mihomo-cfg" \
    "/www/cgi-bin/mihomo-cfg" || exit 1

download_file \
    "$REPO/files/mihomo-sub" \
    "/www/cgi-bin/mihomo-sub" || exit 1

download_file \
    "$REPO/files/nft.conf" \
    "$D/nft.conf" || exit 1

download_file \
    "$REPO/files/mihomo.lua" \
    "/usr/lib/lua/luci/controller/mihomo.lua" || exit 1

download_file \
    "$REPO/files/main.htm" \
    "/usr/lib/lua/luci/view/mihomo/main.htm" || exit 1

# ─────────────────────────────────────────────
# Default config
#
# IMPORTANT:
# Do not overwrite an existing user config.
# On a fresh install config.yaml does not exist,
# so default config is installed.
# ─────────────────────────────────────────────

if [ ! -f "$D/config.yaml" ]; then

    download_file \
        "$REPO/files/config.default.yaml" \
        "$D/config.yaml" || exit 1

    echo "[✓] Default config installed."

else

    echo "[✓] Existing config preserved."

fi

# ─────────────────────────────────────────────
# Permissions
# ─────────────────────────────────────────────

chmod +x \
    /etc/init.d/mihomo \
    /www/cgi-bin/mihomo-api \
    /www/cgi-bin/mihomo-cfg \
    /www/cgi-bin/mihomo-sub

chmod 644 \
    "$D/config.yaml" \
    "$D/nft.conf" \
    /usr/lib/lua/luci/controller/mihomo.lua \
    /usr/lib/lua/luci/view/mihomo/main.htm

# ─────────────────────────────────────────────
# Dashboard
# ─────────────────────────────────────────────

echo "[*] Installing MetaCube dashboard..."

cd "$TMP_DIR" || exit 1

rm -f ui.tgz

if curl -fsSL \
    --connect-timeout 15 \
    --max-time 180 \
    -o ui.tgz \
    "https://github.com/MetaCubeX/metacubexd/releases/latest/download/compressed-dist.tgz"
then

    rm -rf "$D/ui/"*

    if tar -xzf ui.tgz -C "$D/ui/" 2>/dev/null; then

        if [ -d "$D/ui/dist" ]; then
            mv "$D/ui/dist/"* "$D/ui/" 2>/dev/null || true
            rm -rf "$D/ui/dist"
        fi

        echo "[✓] Dashboard installed."

    else

        echo "[!] Dashboard extraction failed; core installation continues."

    fi

else

    echo "[!] Dashboard download failed; core installation continues."

fi

# ─────────────────────────────────────────────
# Runtime state
# ─────────────────────────────────────────────

[ -f "$D/enabled" ] ||
    echo "1" > "$D/enabled"

[ -f "$D/transparent" ] ||
    echo "1" > "$D/transparent"

# ─────────────────────────────────────────────
# Validate config before service start
# ─────────────────────────────────────────────

echo "[*] Validating Mihomo configuration..."

if ! /usr/bin/mihomo \
    -d "$D" \
    -f "$D/config.yaml" \
    -t >/tmp/uzumaki_config_test.log 2>&1
then

    echo "[✗] Current config is invalid."
    echo ""
    head -n 12 /tmp/uzumaki_config_test.log
    echo ""

    rm -rf "$TMP_DIR"
    exit 1
fi

echo "[✓] Mihomo configuration valid."

# ─────────────────────────────────────────────
# Service registration
# ─────────────────────────────────────────────

/etc/init.d/mihomo enable >/dev/null 2>&1 || true

# Make sure stale instance is gone.
/etc/init.d/mihomo stop >/dev/null 2>&1 || true
killall -9 mihomo >/dev/null 2>&1 || true

sleep 1

/etc/init.d/mihomo start >/dev/null 2>&1

sleep 3

# ─────────────────────────────────────────────
# Verify actual process
# ─────────────────────────────────────────────

PID="$(pidof mihomo 2>/dev/null | awk '{print $1}')"

if [ -n "$PID" ] && [ -d "/proc/$PID" ]; then

    echo "[✓] Mihomo is running. PID: $PID"

else

    echo "[✗] Mihomo failed to start."
    echo ""
    logread | grep -i mihomo | tail -20

    rm -rf "$TMP_DIR"
    exit 1

fi

# ─────────────────────────────────────────────
# Reload LuCI/RPC
# ─────────────────────────────────────────────

rm -rf /tmp/luci-* 2>/dev/null || true

/etc/init.d/rpcd restart >/dev/null 2>&1 || true
/etc/init.d/uhttpd restart >/dev/null 2>&1 || true

rm -rf "$TMP_DIR"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  ✅ UzumakiClash installation completed successfully!       ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "LuCI → Services → UzumakiClash 🌀"
echo ""
