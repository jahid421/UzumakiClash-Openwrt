#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════
# 🌀 UzumakiClash - Master Installer (Ultimate Stable)
# ═══════════════════════════════════════════════════════════════════════

REPO="https://raw.githubusercontent.com/jahid421/UzumakiClash-Openwrt/main"
V="v1.18.10"; D="/etc/mihomo"

echo "🌀 Installing UzumakiClash Ultimate..."

if command -v apk >/dev/null 2>&1; then
    PKG="apk"; apk update; pkg_ins() { apk add "$@"; }
else
    PKG="opkg"; opkg update; pkg_ins() { opkg install "$@"; }
fi

pkg_ins curl ca-bundle ca-certificates ip-full kmod-tun coreutils-nohup gunzip tar hexdump
command -v nft >/dev/null 2>&1 && pkg_ins kmod-nft-tproxy || pkg_ins iptables-mod-tproxy

# ⚡ Bulletproof Architecture Detection
RAW_ARCH=$(opkg print-architecture | awk 'NR==1{print $2}' 2>/dev/null || apk arch 2>/dev/null || uname -m)
case "$RAW_ARCH" in
    mipsel*|mipsle*) M="mipsle-softfloat" ;;
    mips*) M="mips-softfloat" ;;
    aarch64*) M="arm64" ;;
    x86_64) M="amd64-compatible" ;;
    armv7*) M="armv7" ;;
    *) M="mipsle-softfloat" ;;
esac

cd /tmp && rm -f mihomo.gz mihomo
curl -sL -o mihomo.gz "https://github.com/MetaCubeX/mihomo/releases/download/$V/mihomo-linux-$M-$V.gz"
gunzip -f mihomo.gz && mv /tmp/mihomo /usr/bin/mihomo && chmod +x /usr/bin/mihomo

mkdir -p $D/ui /www/cgi-bin /usr/lib/lua/luci/controller /usr/lib/lua/luci/view/mihomo
curl -sL -o /etc/init.d/mihomo "$REPO/files/mihomo.init" && chmod +x /etc/init.d/mihomo
curl -sL -o /www/cgi-bin/mihomo-api "$REPO/files/mihomo-api" && chmod +x /www/cgi-bin/mihomo-api
curl -sL -o /www/cgi-bin/mihomo-cfg "$REPO/files/mihomo-cfg" && chmod +x /www/cgi-bin/mihomo-cfg
curl -sL -o /www/cgi-bin/mihomo-sub "$REPO/files/mihomo-sub" && chmod +x /www/cgi-bin/mihomo-sub
curl -sL -o $D/nft.conf "$REPO/files/nft.conf"
curl -sL -o $D/config.yaml "$REPO/files/config.default.yaml"
curl -sL -o /usr/lib/lua/luci/controller/mihomo.lua "$REPO/files/mihomo.lua"
curl -sL -o /usr/lib/lua/luci/view/mihomo/main.htm "$REPO/files/main.htm"

cd /tmp && curl -sL -o ui.tgz "https://github.com/MetaCubeX/metacubexd/releases/latest/download/compressed-dist.tgz"
tar -xzf ui.tgz -C $D/ui/ && [ -d "$D/ui/dist" ] && mv $D/ui/dist/* $D/ui/ && rm -rf $D/ui/dist

/etc/init.d/mihomo enable && /etc/init.d/mihomo restart
rm -rf /tmp/luci-* && /etc/init.d/rpcd restart
echo "✅ UzumakiClash Ultimate Fixed! Restart PC and Gaming."
