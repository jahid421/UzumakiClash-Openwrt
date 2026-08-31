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

# ডিপেন্ডেন্সি চেক (opkg vs apk)
if command -v apk >/dev/null 2>&1; then
    PKG="apk"; apk update; pkg_ins() { apk add "$@"; }
else
    PKG="opkg"; opkg update; pkg_ins() { opkg install "$@"; }
fi

echo "[*] Installing dependencies..."
pkg_ins curl ca-bundle ca-certificates ip-full kmod-tun coreutils-nohup gzip tar busybox nftables
[ "$PKG" = "opkg" ] && pkg_ins luci-compat luci-lib-ipkg

# mt7621 / mipsel_24kc এর জন্য নিখুঁত ডিটেকশন (Fix for 'unexpected (' error)
RAW_ARCH=$(opkg print-architecture 2>/dev/null | grep -E "mipsel_24kc|mipsel" | awk '{print $2}' | head -n 1)
[ -z "$RAW_ARCH" ] && RAW_ARCH=$(uname -m)

case "$RAW_ARCH" in
    mipsel*|mipsle*) M="mipsle-softfloat" ;;
    mips*) M="mips-softfloat" ;;
    aarch64*|arm64*) M="arm64" ;;
    x86_64*|amd64*) M="amd64-compatible" ;;
    *) M="mipsle-softfloat" ;; 
esac

echo "[✓] Precise Architecture: $RAW_ARCH -> Core: $M"

# কোর ডাউনলোড ও ইন্সটলেশন
cd /tmp && rm -f mihomo.gz mihomo
curl -sL -o mihomo.gz "https://github.com/MetaCubeX/mihomo/releases/download/$V/mihomo-linux-$M-$V.gz"
gzip -d -f mihomo.gz 2>/dev/null || gunzip -f mihomo.gz
chmod +x mihomo && mv mihomo /usr/bin/mihomo

# ডিরেক্টরি এবং ফাইল সিঙ্ক
mkdir -p $D/ui /www/cgi-bin /usr/lib/lua/luci/controller /usr/lib/lua/luci/view/mihomo
curl -sL -o /etc/init.d/mihomo "$REPO/files/mihomo.init" && chmod +x /etc/init.d/mihomo
curl -sL -o /www/cgi-bin/mihomo-api "$REPO/files/mihomo-api" && chmod +x /www/cgi-bin/mihomo-api
curl -sL -o /www/cgi-bin/mihomo-cfg "$REPO/files/mihomo-cfg" && chmod +x /www/cgi-bin/mihomo-cfg
curl -sL -o /www/cgi-bin/mihomo-sub "$REPO/files/mihomo-sub" && chmod +x /www/cgi-bin/mihomo-sub
curl -sL -o $D/nft.conf "$REPO/files/nft.conf"
curl -sL -o $D/config.yaml "$REPO/files/config.default.yaml"
curl -sL -o /usr/lib/lua/luci/controller/mihomo.lua "$REPO/files/mihomo.lua"
curl -sL -o /usr/lib/lua/luci/view/mihomo/main.htm "$REPO/files/main.htm"

# জিও-ডাটাবেজ ডাউনলোড (সুপার ইম্পরট্যান্ট!)
echo "📥 Downloading GeoData Databases..."
cd $D
curl -sL -o Country.mmdb "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/country-lite.mmdb"
curl -sL -o geoip.dat "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip-lite.dat"
curl -sL -o geosite.dat "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat"

# ড্যাশবোর্ড রিস্টোর
cd /tmp && curl -sL -o ui.tgz "https://github.com/MetaCubeX/metacubexd/releases/latest/download/compressed-dist.tgz"
tar -xzf ui.tgz -C $D/ui/ && [ -d "$D/ui/dist" ] && mv $D/ui/dist/* $D/ui/ && rm -rf $D/ui/dist

# বুট এবং ক্যাশ ক্লিয়ার
echo "1" > $D/enabled
echo "1" > $D/transparent
/etc/init.d/mihomo enable && /etc/init.d/mihomo restart
rm -rf /tmp/luci-* && /etc/init.d/rpcd restart
echo "✅ UzumakiClash Ultimate Fixed Version Installed!"
