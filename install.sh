#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════
# 🌀 UzumakiClash - Universal Master Installer (Fixed & Stable Edition)
# Repo: https://github.com/jahid421/UzumakiClash-Openwrt
# Developer: Jahid Hasan Shuvo (@crazy_boy_jahid)
# ═══════════════════════════════════════════════════════════════════════

REPO="https://raw.githubusercontent.com/jahid421/UzumakiClash-Openwrt/main"
V="v1.18.10"
D="/etc/mihomo"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  🌀 UzumakiClash Universal Installer (Fixed Edition)          ║"
echo "║  Developer: Jahid Hasan Shuvo (@crazy_boy_jahid)              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

[ ! -f /etc/openwrt_release ] && { echo "❌ ERROR: This script only works on OpenWrt!"; exit 1; }

. /etc/openwrt_release 2>/dev/null
if command -v apk >/dev/null 2>&1; then
    PKG_TYPE="apk"; apk update >/dev/null 2>&1 || true
    pkg_install() { apk add "$@" >/dev/null 2>&1 || true; }
elif command -v opkg >/dev/null 2>&1; then
    PKG_TYPE="opkg"; opkg update >/dev/null 2>&1 || true
    pkg_install() { opkg install "$@" >/dev/null 2>&1 || true; }
else
    echo "❌ No supported package manager found!"; exit 1
fi

pkg_install curl ca-bundle ca-certificates ip-full kmod-tun coreutils-nohup
command -v nft >/dev/null 2>&1 && pkg_install kmod-nft-tproxy || pkg_install iptables-mod-tproxy
[ "$PKG_TYPE" = "opkg" ] && pkg_install luci-compat luci-lib-ipkg luci-lib-nixio

A="${DISTRIB_ARCH:-$(uname -m)}"
case "$A" in
    x86_64*|amd64*) M="amd64-compatible" ;;
    aarch64*|arm64*) M="arm64" ;;
    armv7*|arm_cortex-a7*|arm_cortex-a9*|arm_cortex-a15*) M="armv7" ;;
    mipsel*|mipsle*) M="mipsle-softfloat" ;;
    mips*) M="mips-softfloat" ;;
    *) M="amd64-compatible" ;;
esac

cd /tmp && curl -sL -o mihomo.gz "https://github.com/MetaCubeX/mihomo/releases/download/$V/mihomo-linux-$M-$V.gz"
gunzip -f mihomo.gz && chmod +x mihomo && mv mihomo /usr/bin/mihomo

mkdir -p $D/ui /www/cgi-bin /usr/lib/lua/luci/controller /usr/lib/lua/luci/view/mihomo
curl -sL -o /etc/init.d/mihomo "$REPO/files/mihomo.init" && chmod +x /etc/init.d/mihomo
curl -sL -o /www/cgi-bin/mihomo-api "$REPO/files/mihomo-api" && chmod +x /www/cgi-bin/mihomo-*
curl -sL -o /www/cgi-bin/mihomo-cfg "$REPO/files/mihomo-cfg"
curl -sL -o /www/cgi-bin/mihomo-sub "$REPO/files/mihomo-sub"
curl -sL -o $D/nft.conf "$REPO/files/nft.conf"
curl -sL -o $D/config.yaml "$REPO/files/config.default.yaml"
curl -sL -o /usr/lib/lua/luci/controller/mihomo.lua "$REPO/files/mihomo.lua"
curl -sL -o /usr/lib/lua/luci/view/mihomo/main.htm "$REPO/files/main.htm"

# 🌀 Dashboard/UI Restore Logic
cd /tmp && curl -sL -o ui.tgz "https://github.com/MetaCubeX/metacubexd/releases/latest/download/compressed-dist.tgz"
if [ -s ui.tgz ]; then
    rm -rf $D/ui/*
    tar -xzf ui.tgz -C $D/ui/ 2>/dev/null && rm -f ui.tgz
    [ -d "$D/ui/dist" ] && mv $D/ui/dist/* $D/ui/ 2>/dev/null && rm -rf $D/ui/dist
    chmod -R 755 $D/ui
fi

if [ -d /usr/share/luci/menu.d ]; then
    cat > /usr/share/luci/menu.d/luci-app-uzumakiclash.json << EOF
{"admin/services/mihomo":{"title":"UzumakiClash 🌀","order":60,"action":{"type":"template","path":"mihomo/main"}}}
EOF
fi

/etc/init.d/mihomo enable
/etc/init.d/mihomo restart >/dev/null 2>&1
rm -rf /tmp/luci-* && /etc/init.d/rpcd restart && /etc/init.d/uhttpd restart
echo "✅ UzumakiClash Fixed & Stable Version Installed!"
