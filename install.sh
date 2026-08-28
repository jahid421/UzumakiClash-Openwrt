#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════
# 🌀 UzumakiClash - Master Installer (Ultimate Stable & Dependency Fixed)
# Repo: https://github.com/jahid421/UzumakiClash-Openwrt
# Developer: Jahid Hasan Shuvo (@crazy_boy_jahid)
# ═══════════════════════════════════════════════════════════════════════

REPO="https://raw.githubusercontent.com/jahid421/UzumakiClash-Openwrt/main"
V="v1.18.10"; D="/etc/mihomo"

echo "🌀 Installing UzumakiClash Ultimate..."

# ওএস এবং প্যাকেজ ম্যানেজার ডিটেকশন
if command -v apk >/dev/null 2>&1; then
    PKG="apk"; apk update; pkg_ins() { apk add "$@"; }
else
    PKG="opkg"; opkg update; pkg_ins() { opkg install "$@"; }
fi

# মূল ডিপেন্ডেন্সি ইন্সটল (gunzip বাদ দেওয়া হয়েছে)
echo "[*] Installing core dependencies..."
pkg_ins curl ca-bundle ca-certificates ip-full kmod-tun coreutils-nohup tar 
[ "$PKG" = "opkg" ] && pkg_ins luci-compat luci-lib-ipkg busybox

command -v nft >/dev/null 2>&1 && pkg_ins kmod-nft-tproxy || pkg_ins iptables-mod-tproxy

# ⚡ নিখুঁত আর্কিটেকচার ডিটেকশন লজিক
RAW_ARCH=$(opkg print-architecture | awk 'NR==1{print $2}' 2>/dev/null || apk arch 2>/dev/null || uname -m)

case "$RAW_ARCH" in
    mipsel*|mipsle*|mipsel_24kc*) M="mipsle-softfloat" ;;
    mips*|mips_24kc*) M="mips-softfloat" ;;
    aarch64*|arm64*) M="arm64" ;;
    x86_64*|amd64*) M="amd64-compatible" ;;
    armv7*) M="armv7" ;;
    *) 
        # ফেইলসেফ ডিটেকশন
        if uname -a | grep -qi "mipsel"; then M="mipsle-softfloat";
        elif uname -a | grep -qi "mips"; then M="mips-softfloat";
        else M="mipsle-softfloat"; fi
        ;;
esac

echo "[✓] Architecture Detected: $RAW_ARCH -> Using Binary: $M"

# কোর ডাউনলোড এবং এক্সট্রাক্ট (zcat ব্যবহার করে gunzip এরর এড়ানো হয়েছে)
cd /tmp && rm -f mihomo.gz mihomo
curl -sL -o mihomo.gz "https://github.com/MetaCubeX/mihomo/releases/download/$V/mihomo-linux-$M-$V.gz"

if [ -f "mihomo.gz" ]; then
    zcat mihomo.gz > mihomo
    chmod +x mihomo && mv mihomo /usr/bin/mihomo
    rm -f mihomo.gz
else
    echo "❌ Download failed! Please check your internet."
    exit 1
fi

# ডিরেক্টরি এবং ফাইল ডাউনলোড
mkdir -p $D/ui /www/cgi-bin /usr/lib/lua/luci/controller /usr/lib/lua/luci/view/mihomo
curl -sL -o /etc/init.d/mihomo "$REPO/files/mihomo.init" && chmod +x /etc/init.d/mihomo
curl -sL -o /www/cgi-bin/mihomo-api "$REPO/files/mihomo-api" && chmod +x /www/cgi-bin/mihomo-api
curl -sL -o /www/cgi-bin/mihomo-cfg "$REPO/files/mihomo-cfg" && chmod +x /www/cgi-bin/mihomo-cfg
curl -sL -o /www/cgi-bin/mihomo-sub "$REPO/files/mihomo-sub" && chmod +x /www/cgi-bin/mihomo-sub
curl -sL -o $D/nft.conf "$REPO/files/nft.conf"
curl -sL -o $D/config.yaml "$REPO/files/config.default.yaml"
curl -sL -o /usr/lib/lua/luci/controller/mihomo.lua "$REPO/files/mihomo.lua"
curl -sL -o /usr/lib/lua/luci/view/mihomo/main.htm "$REPO/files/main.htm"

# ড্যাশবোর্ড রিস্টোর
cd /tmp && curl -sL -o ui.tgz "https://github.com/MetaCubeX/metacubexd/releases/latest/download/compressed-dist.tgz"
tar -xzf ui.tgz -C $D/ui/ && [ -d "$D/ui/dist" ] && mv $D/ui/dist/* $D/ui/ && rm -rf $D/ui/dist

cat > /usr/share/luci/menu.d/luci-app-uzumakiclash.json << EOF
{"admin/services/mihomo":{"title":"UzumakiClash 🌀","order":60,"action":{"type":"template","path":"mihomo/main"}}}
EOF

/etc/init.d/mihomo enable && /etc/init.d/mihomo restart
rm -rf /tmp/luci-* && /etc/init.d/rpcd restart
echo "✅ UzumakiClash Fixed & Installed Successfully!"
