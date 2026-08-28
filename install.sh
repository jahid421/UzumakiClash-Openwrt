#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════
# 🌀 UzumakiClash - Master Installer (mt7621 / mipsel_24kc Fix)
# ═══════════════════════════════════════════════════════════════════════

REPO="https://raw.githubusercontent.com/jahid421/UzumakiClash-Openwrt/main"
V="v1.18.10"; D="/etc/mihomo"

echo "🌀 Installing UzumakiClash Ultimate..."

if command -v apk >/dev/null 2>&1; then
    PKG="apk"; apk update; pkg_ins() { apk add "$@"; }
else
    PKG="opkg"; opkg update; pkg_ins() { opkg install "$@"; }
fi

# gunzip এর বদলে gzip এবং coreutils-gunzip ব্যবহার করা হয়েছে
echo "[*] Installing core dependencies..."
pkg_ins curl ca-bundle ca-certificates ip-full kmod-tun coreutils-nohup gzip tar busybox
[ "$PKG" = "opkg" ] && pkg_ins luci-compat luci-lib-ipkg

command -v nft >/dev/null 2>&1 && pkg_ins kmod-nft-tproxy || pkg_ins iptables-mod-tproxy

# ⚡ mt7621 / mipsel_24kc এর জন্য সঠিক ডিটেকশন
RAW_ARCH=$(opkg print-architecture | grep -E "mipsel_24kc|mipsel" | awk '{print $2}' | head -n 1)
[ -z "$RAW_ARCH" ] && RAW_ARCH=$(uname -m)

case "$RAW_ARCH" in
    mipsel*|mipsle*) M="mipsle-softfloat" ;;
    mips*) M="mips-softfloat" ;;
    aarch64*|arm64*) M="arm64" ;;
    x86_64*|amd64*) M="amd64-compatible" ;;
    *) M="mipsle-softfloat" ;; # mt7621 এর জন্য এটিই সেফ
esac

echo "[✓] Precise Architecture: $RAW_ARCH -> Binary: $M"

cd /tmp && rm -f mihomo.gz mihomo
curl -sL -o mihomo.gz "https://github.com/MetaCubeX/mihomo/releases/download/$V/mihomo-linux-$M-$V.gz"

if [ -f "mihomo.gz" ]; then
    gzip -d -f mihomo.gz 2>/dev/null || gunzip -f mihomo.gz
    chmod +x mihomo && mv mihomo /usr/bin/mihomo
    echo "[✓] Engine installed to /usr/bin/mihomo"
else
    echo "❌ Download failed!"
    exit 1
fi

# ফাইল ডাউনলোড এবং ডিরেক্টরি সেটআপ
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

cat > /usr/share/luci/menu.d/luci-app-uzumakiclash.json << EOF
{"admin/services/mihomo":{"title":"UzumakiClash 🌀","order":60,"action":{"type":"template","path":"mihomo/main"}}}
EOF

/etc/init.d/mihomo enable && /etc/init.d/mihomo restart
rm -rf /tmp/luci-* && /etc/init.d/rpcd restart
echo "✅ UzumakiClash Fixed Successfully for mt7621!"
