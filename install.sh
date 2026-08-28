#!/bin/sh
# UzumakiClash - Universal Master Installer
REPO="https://raw.githubusercontent.com/jahid421/UzumakiClash-Openwrt/main"
V="v1.18.10"; D="/etc/mihomo"

echo "🌀 Installing UzumakiClash Ultimate..."

if command -v apk >/dev/null 2>&1; then
    PKG="apk"; apk update; pkg_ins() { apk add "$@"; }
else
    PKG="opkg"; opkg update; pkg_ins() { opkg install "$@"; }
fi

pkg_ins curl ca-bundle ca-certificates ip-full kmod-tun coreutils-nohup
command -v nft >/dev/null 2>&1 && pkg_ins kmod-nft-tproxy || pkg_ins iptables-mod-tproxy

A="${DISTRIB_ARCH:-$(uname -m)}"
case "$A" in
    x86_64*) M="amd64-compatible" ;;
    aarch64*) M="arm64" ;;
    armv7*) M="armv7" ;;
    mipsel*) M="mipsle-softfloat" ;;
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

# Dashboard Restore
cd /tmp && curl -sL -o ui.tgz "https://github.com/MetaCubeX/metacubexd/releases/latest/download/compressed-dist.tgz"
tar -xzf ui.tgz -C $D/ui/ && [ -d "$D/ui/dist" ] && mv $D/ui/dist/* $D/ui/ && rm -rf $D/ui/dist

cat > /usr/share/luci/menu.d/luci-app-uzumakiclash.json << EOF
{"admin/services/mihomo":{"title":"UzumakiClash 🌀","order":60,"action":{"type":"template","path":"mihomo/main"}}}
EOF

chmod +x /www/cgi-bin/mihomo-* /etc/init.d/mihomo
/etc/init.d/mihomo enable && /etc/init.d/mihomo restart

echo "✅ UzumakiClash Activated! Upload YAML to start."
