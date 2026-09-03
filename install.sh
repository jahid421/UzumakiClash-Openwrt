#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════
# 🌀 UzumakiClash - Master Universal Installer
# ═══════════════════════════════════════════════════════════════════════

set -e

REPO="https://raw.githubusercontent.com/jahid421/UzumakiClash-Openwrt/main"
TS=$(date +%s)
V="v1.18.10"
D="/etc/mihomo"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  🌀 UzumakiClash Universal Installer (Master Edition)        ║"
echo "║  Auto-Detect: opkg/apk | Precision Arch | Turbo Gaming       ║"
echo "╚══════════════════════════════════════════════════════════════╝"

if command -v apk >/dev/null 2>&1; then
    PKG="apk"
    apk update
    apk add curl ca-certificates ip-full kmod-tun coreutils-nohup gzip tar busybox
else
    PKG="opkg"
    opkg update
    opkg install curl ca-bundle ca-certificates ip-full kmod-tun coreutils-nohup gzip tar busybox luci-compat luci-lib-ipkg 2>/dev/null || true
fi

UNAME_M=$(uname -m)
OPKG_ARCH=""
[ "$PKG" = "opkg" ] && OPKG_ARCH=$(opkg print-architecture 2>/dev/null | awk '{print $2}' | grep -v 'all\|noarch' | head -n 1)

if echo "$OPKG_ARCH" | grep -q "mipsel" || grep -q "MT7621" /proc/cpuinfo 2>/dev/null; then
    M="mipsle-softfloat"
elif echo "$OPKG_ARCH" | grep -q "mips" || echo "$UNAME_M" | grep -q "mips"; then
    M="mips-softfloat"
elif [ "$UNAME_M" = "aarch64" ] || echo "$OPKG_ARCH" | grep -q "aarch64"; then
    M="arm64"
elif echo "$UNAME_M" | grep -q "armv7" || echo "$OPKG_ARCH" | grep -q "arm"; then
    M="armv7"
elif [ "$UNAME_M" = "x86_64" ]; then
    M="amd64-compatible"
elif echo "$UNAME_M" | grep -q "i[3-6]86"; then
    M="386"
else
    M="mipsle-softfloat"
fi

echo "[✓] Architecture: $M"

cd /tmp && rm -f mihomo.gz mihomo
curl -sL -o mihomo.gz "https://github.com/MetaCubeX/mihomo/releases/download/$V/mihomo-linux-$M-$V.gz"
gzip -d -f mihomo.gz 2>/dev/null || gunzip -f mihomo.gz
chmod +x mihomo

if ./mihomo -v >/dev/null 2>&1; then
    mv mihomo /usr/bin/mihomo
else
    curl -sL -o mihomo.gz "https://github.com/MetaCubeX/mihomo/releases/download/$V/mihomo-linux-mipsle-hardfloat-$V.gz"
    gunzip -f mihomo.gz && chmod +x mihomo && mv mihomo /usr/bin/mihomo
fi

mkdir -p $D/ui $D/proxy_provider $D/rule_provider $D/logs
mkdir -p /www/cgi-bin /usr/lib/lua/luci/controller /usr/lib/lua/luci/view/mihomo
mkdir -p /usr/share/luci/menu.d /usr/share/rpcd/acl.d

curl -sL -o /etc/init.d/mihomo "$REPO/files/mihomo.init?$TS" && chmod +x /etc/init.d/mihomo
curl -sL -o /www/cgi-bin/mihomo-api "$REPO/files/mihomo-api?$TS" && chmod +x /www/cgi-bin/mihomo-api
curl -sL -o /www/cgi-bin/mihomo-cfg "$REPO/files/mihomo-cfg?$TS" && chmod +x /www/cgi-bin/mihomo-cfg
curl -sL -o /www/cgi-bin/mihomo-sub "$REPO/files/mihomo-sub?$TS" && chmod +x /www/cgi-bin/mihomo-sub
curl -sL -o $D/nft.conf "$REPO/files/nft.conf?$TS"
curl -sL -o $D/config.yaml "$REPO/files/config.default.yaml?$TS"
curl -sL -o /usr/lib/lua/luci/controller/mihomo.lua "$REPO/files/mihomo.lua?$TS"
curl -sL -o /usr/lib/lua/luci/view/mihomo/main.htm "$REPO/files/main.htm?$TS"

cat << 'EOF' > /usr/share/luci/menu.d/luci-app-mihomo.json
{
    "admin/services/mihomo": {
        "title": "UzumakiClash 🌀",
        "action": {
            "type": "template",
            "path": "mihomo/main"
        }
    }
}
EOF

cat << 'EOF' > /usr/share/rpcd/acl.d/luci-app-mihomo.json
{
    "luci-app-mihomo": {
        "description": "Grant access to UzumakiClash",
        "read": { "ubus": { "file": [ "read", "stat" ] }, "uci": [ "mihomo" ] },
        "write": { "file": { "/etc/mihomo/*": [ "read", "write" ] } }
    }
}
EOF

cd /tmp && rm -f ui.tgz
curl -sL -o ui.tgz "https://github.com/MetaCubeX/metacubexd/releases/latest/download/compressed-dist.tgz"
tar -xzf ui.tgz -C $D/ui/ && [ -d "$D/ui/dist" ] && mv $D/ui/dist/* $D/ui/ && rm -rf $D/ui/dist

echo "1" > $D/enabled
echo "1" > $D/transparent
/etc/init.d/mihomo enable
/etc/init.d/mihomo restart 2>/dev/null || true
rm -rf /tmp/luci-*
/etc/init.d/rpcd restart 2>/dev/null || true
/etc/init.d/uhttpd restart 2>/dev/null || true

echo "✅ UzumakiClash Installed Successfully!"
