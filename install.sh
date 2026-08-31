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
echo "║  🌀 UzumakiClash Universal Installer                        ║"
echo "║  Auto-Detect: opkg/apk | Mihomo | Transparent Gateway       ║"
echo "╚══════════════════════════════════════════════════════════════╝"

# ─────────────────────────────────────────────
# Package manager
# ─────────────────────────────────────────────

if command -v apk >/dev/null 2>&1; then
    PKG="apk"
    apk update
    pkg_ins() {
        apk add "$@"
    }
else
    PKG="opkg"
    opkg update
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
    kmod-nft-tproxy \
    kmod-nf-tproxy \
    kmod-nft-core \
    coreutils-nohup \
    gzip \
    tar \
    busybox

[ "$PKG" = "opkg" ] && \
    pkg_ins luci-compat luci-lib-ipkg

# ─────────────────────────────────────────────
# Architecture detection
# ─────────────────────────────────────────────

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
    x86_64*|amd64*)
        M="amd64-compatible"
        ;;
    *)
        echo "[!] Unknown architecture: $RAW_ARCH"
        exit 1
        ;;
esac

echo "[✓] Architecture: $RAW_ARCH -> Core: $M"

# ─────────────────────────────────────────────
# Mihomo core
# ─────────────────────────────────────────────

cd /tmp || exit 1

rm -f mihomo.gz mihomo

echo "[*] Downloading Mihomo $V ..."

if ! curl -fL \
    --connect-timeout 15 \
    --max-time 120 \
    -o mihomo.gz \
    "https://github.com/MetaCubeX/mihomo/releases/download/$V/mihomo-linux-$M-$V.gz"
then
    echo "[✗] Mihomo download failed"
    exit 1
fi

gzip -d -f mihomo.gz 2>/dev/null || \
gunzip -f mihomo.gz 2>/dev/null

[ -f mihomo ] || {
    echo "[✗] Mihomo binary not found"
    exit 1
}

chmod +x mihomo
mv -f mihomo /usr/bin/mihomo

# ─────────────────────────────────────────────
# Directories
# ─────────────────────────────────────────────

mkdir -p \
    "$D/ui" \
    /www/cgi-bin \
    /usr/lib/lua/luci/controller \
    /usr/lib/lua/luci/view/mihomo

# ─────────────────────────────────────────────
# Project files
# ─────────────────────────────────────────────

curl -fsSL -o /etc/init.d/mihomo \
    "$REPO/files/mihomo.init"

curl -fsSL -o /www/cgi-bin/mihomo-api \
    "$REPO/files/mihomo-api"

curl -fsSL -o /www/cgi-bin/mihomo-cfg \
    "$REPO/files/mihomo-cfg"

curl -fsSL -o /www/cgi-bin/mihomo-sub \
    "$REPO/files/mihomo-sub"

curl -fsSL -o "$D/nft.conf" \
    "$REPO/files/nft.conf"

curl -fsSL -o "$D/config.yaml" \
    "$REPO/files/config.default.yaml"

curl -fsSL -o /usr/lib/lua/luci/controller/mihomo.lua \
    "$REPO/files/mihomo.lua"

curl -fsSL -o /usr/lib/lua/luci/view/mihomo/main.htm \
    "$REPO/files/main.htm"

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

cd /tmp || exit 1

rm -f ui.tgz

if curl -fsSL \
    --connect-timeout 15 \
    --max-time 120 \
    -o ui.tgz \
    "https://github.com/MetaCubeX/metacubexd/releases/latest/download/compressed-dist.tgz"
then
    rm -rf "$D/ui/"*
    tar -xzf ui.tgz -C "$D/ui/" 2>/dev/null || true

    if [ -d "$D/ui/dist" ]; then
        mv "$D/ui/dist/"* "$D/ui/" 2>/dev/null || true
        rmdir "$D/ui/dist" 2>/dev/null || true
    fi
fi

# ─────────────────────────────────────────────
# Default state
# ─────────────────────────────────────────────

echo "1" > "$D/enabled"
echo "1" > "$D/transparent"

# ─────────────────────────────────────────────
# Service
# ─────────────────────────────────────────────

/etc/init.d/mihomo enable
/etc/init.d/mihomo restart

rm -rf /tmp/luci-*

/etc/init.d/rpcd restart >/dev/null 2>&1 || true
/etc/init.d/uhttpd restart >/dev/null 2>&1 || true

echo ""
echo "✅ UzumakiClash installed successfully!"
echo ""
