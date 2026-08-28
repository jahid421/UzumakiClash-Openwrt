#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════
# 🌀 UzumakiClash - Ultimate Master Installer (Fixed Architecture Logic)
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

pkg_ins curl ca-bundle ca-certificates ip-full kmod-tun coreutils-nohup
command -v nft >/dev/null 2>&1 && pkg_ins kmod-nft-tproxy || pkg_ins iptables-mod-tproxy
[ "$PKG" = "opkg" ] && pkg_ins luci-compat luci-lib-ipkg

# ⚡ নিখুঁত আর্কিটেকচার ডিটেকশন (Fix for "unexpected (" error)
A=$(uname -m)
case "$A" in
    x86_64) M="amd64-compatible" ;;
    aarch64) M="arm64" ;;
    armv7*) M="armv7" ;;
    mips*) 
        # MIPS এর জন্য এন্ডিয়াননেস চেক
        if echo -n I | hexdump -o | grep -q '0000002'; then M="mipsle-softfloat"; else M="mips-softfloat"; fi
        ;;
    *) M="amd64-compatible" ;;
esac

echo "[✓] Detected Architecture: $A -> Using Binary: $M"

# কোর ডাউনলোড এবং ভেরিফিকেশন
cd /tmp && curl -sL -o mihomo.gz "https://github.com/MetaCubeX/mihomo/releases/download/$V/mihomo-linux-$M-$V.gz"
gunzip -f mihomo.gz && chmod +x mihomo && mv mihomo /usr/bin/mihomo

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

# বুট এবং ক্যাশ ক্লিয়ার
/etc/init.d/mihomo enable && /etc/init.d/mihomo restart
rm -rf /tmp/luci-* && /etc/init.d/rpcd restart
echo "✅ UzumakiClash Fixed Successfully!"
