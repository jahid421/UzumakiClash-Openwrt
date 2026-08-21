#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════
# 🌀 UzumakiClash - Universal Master Installer (OpenWrt v19 to v25+)
# Supports: opkg (v19-v24) & apk (v25+) | fw3 (iptables) & fw4 (nftables)
# Developer: Jahid Hasan Shuvo
# ═══════════════════════════════════════════════════════════════════════

REPO="https://raw.githubusercontent.com/jahid421/UzumakiClash/main"
V="v1.18.10"
D="/etc/mihomo"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  🌀 UzumakiClash Universal Installer (v19 - v25+)             ║"
echo "║  Auto-Detect: opkg/apk | iptables/nftables | Universal Arch  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

[ ! -f /etc/openwrt_release ] && { echo "❌ ERROR: This script only works on OpenWrt!"; exit 1; }

. /etc/openwrt_release 2>/dev/null
OWRT_VER="${DISTRIB_RELEASE:-Snapshot}"
echo "[✓] OpenWrt detected: $DISTRIB_ID $OWRT_VER"

# ১. প্যাকেজ ম্যানেজার ডিটেকশন (opkg vs apk)
if command -v apk >/dev/null 2>&1; then
    PKG_TYPE="apk"
    echo "[✓] Package Engine: apk (OpenWrt v25+ Detected)"
    apk update >/dev/null 2>&1 || true
    pkg_install() { apk add "$@" >/dev/null 2>&1 || true; }
elif command -v opkg >/dev/null 2>&1; then
    PKG_TYPE="opkg"
    echo "[✓] Package Engine: opkg (OpenWrt v19-v24 Detected)"
    opkg update >/dev/null 2>&1 || true
    pkg_install() { opkg install "$@" >/dev/null 2>&1 || true; }
else
    echo "❌ No supported package manager found!"
    exit 1
fi

# ২. ডিপেন্ডেন্সি ইনস্টলেশন (Universal Dependency Fallback)
echo "[*] Installing network and cryptographic dependencies..."
pkg_install curl ca-bundle ca-certificates ip-full kmod-tun coreutils-nohup

# ফায়ারওয়াল নির্ভর ডিপেন্ডেন্সি
if command -v nft >/dev/null 2>&1; then
    pkg_install kmod-nft-tproxy
else
    pkg_install iptables-mod-tproxy kmod-ipt-tproxy iptables-mod-extra
fi

# LuCI কম্প্যাটিবিলিটি প্যাকেজ
if [ "$PKG_TYPE" = "opkg" ]; then
    pkg_install luci-compat luci-lib-ipkg luci-lib-nixio
fi

# ৩. ডাউনলোড ইঞ্জিন ভ্যালিডেশন
dl() {
    if command -v curl >/dev/null 2>&1; then
        curl -sL -k -o "$2" "$1" 2>/dev/null
    else
        wget -q --no-check-certificate -O "$2" "$1" 2>/dev/null
    fi
}

# ৪. আর্কিটেকচার ডিটেকশন (All CPU Platforms)
A="${DISTRIB_ARCH:-$(uname -m)}"
echo "[*] Detecting CPU Architecture: $A"

case "$A" in
    x86_64*|amd64*) M="amd64-compatible" ;;
    aarch64*|arm64*) M="arm64" ;;
    armv7*|arm_cortex-a7*|arm_cortex-a9*|arm_cortex-a15*|arm_cortex-a53*) M="armv7" ;;
    armv6*|arm_arm1176*) M="armv6" ;;
    armv5*|arm_arm926*) M="armv5" ;;
    mips64el*|mips64le*) M="mips64le" ;;
    mips64*) M="mips64" ;;
    mipsel*|mipsle*|mipsel_24kc*|mipsel_74kc*) M="mipsle-softfloat" ;;
    mips*|mips_24kc*|mips_4kec*) M="mips-softfloat" ;;
    riscv64*) M="riscv64" ;;
    i386*|i686*) M="386" ;;
    loongarch64*) M="loong64" ;;
    *) M="amd64-compatible" ;;
esac
echo "[✓] Selected Core Binary: mihomo-linux-$M-$V"

# ৫. কোর ইঞ্জিন ডাউনলোড
echo "[*] Downloading Core Engine..."
cd /tmp && rm -f mihomo.gz mihomo
dl "https://github.com/MetaCubeX/mihomo/releases/download/$V/mihomo-linux-$M-$V.gz" mihomo.gz
[ -s mihomo.gz ] || { echo "❌ Core download failed!"; exit 1; }

gunzip -f mihomo.gz 2>/dev/null || true
chmod +x mihomo
mv mihomo /usr/bin/mihomo
echo "[✓] Core Engine verified and installed"

# ৬. ডিরেক্টরি সেটআপ
mkdir -p $D/ui $D/profiles /www/cgi-bin /usr/lib/lua/luci/controller /usr/lib/lua/luci/view/mihomo

echo "0" > $D/transparent
echo "0" > $D/enabled

# ৭. জিও-ডাটা ও অফলাইন ড্যাশবোর্ড
echo "[*] Fetching GeoData & Offline UI..."
dl "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip-lite.dat" $D/geoip.dat
dl "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat" $D/geosite.dat
dl "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/country-lite.mmdb" $D/Country.mmdb

cd /tmp && dl "https://github.com/MetaCubeX/metacubexd/releases/latest/download/compressed-dist.tgz" ui.tgz
if [ -s ui.tgz ]; then
    rm -rf $D/ui/*
    tar -xzf ui.tgz -C $D/ui/ 2>/dev/null && rm -f ui.tgz
    [ -d "$D/ui/dist" ] && mv $D/ui/dist/* $D/ui/ 2>/dev/null && rm -rf $D/ui/dist
fi

# ৮. স্ক্রিপ্ট ইনজেকশন
echo "[*] Injecting Uzumaki Scripts..."
dl "$REPO/files/mihomo.init" /etc/init.d/mihomo
chmod +x /etc/init.d/mihomo
dl "$REPO/files/config.default.yaml" $D/config.yaml
dl "$REPO/files/nft.conf" $D/nft.conf

dl "$REPO/files/mihomo-api" /www/cgi-bin/mihomo-api
dl "$REPO/files/mihomo-cfg" /www/cgi-bin/mihomo-cfg
dl "$REPO/files/mihomo-sub" /www/cgi-bin/mihomo-sub
chmod +x /www/cgi-bin/mihomo-*

# ৯. ইউনিভার্সাল LuCI ইন্টিগ্রেশন (Lua + JSON Menu for v19-v25+)
dl "$REPO/files/mihomo.lua" /usr/lib/lua/luci/controller/mihomo.lua
dl "$REPO/files/main.htm" /usr/lib/lua/luci/view/mihomo/main.htm

if [ -d /usr/share/luci/menu.d ]; then
    cat > /usr/share/luci/menu.d/luci-app-uzumakiclash.json << 'JSONEOF'
{
    "admin/services/mihomo": {
        "title": "UzumakiClash \ud83c\udf00",
        "order": 60,
        "action": {
            "type": "template",
            "path": "mihomo/main"
        }
    }
}
JSONEOF
fi

# ১০. ইউনিভার্সাল হটপ্লাগ পারসিসটেন্স
mkdir -p /etc/hotplug.d/iface
cat > /etc/hotplug.d/iface/99-uzumaki << 'HEOF'
#!/bin/sh
[ "$ACTION" = "ifup" ] && [ -f /etc/mihomo/transparent ] && [ "$(cat /etc/mihomo/transparent)" = "1" ] && {
    /etc/init.d/mihomo restart >/dev/null 2>&1
}
HEOF

# ১১. ফায়ারওয়াল পোর্ট এলাউ রুল
uci -q delete firewall.uzumaki_rule 2>/dev/null
uci set firewall.uzumaki_rule=rule
uci set firewall.uzumaki_rule.name='Allow-UzumakiClash'
uci set firewall.uzumaki_rule.src='lan'
uci add_list firewall.uzumaki_rule.proto='tcp'
uci add_list firewall.uzumaki_rule.proto='udp'
uci set firewall.uzumaki_rule.dest_port='7890 7893 9595 1053'
uci set firewall.uzumaki_rule.target='ACCEPT'
uci commit firewall
/etc/init.d/firewall restart >/dev/null 2>&1 || true

# ১২. LuCI ও ওয়েব সার্ভার ক্যাশ রিলোড
rm -rf /tmp/luci-*
/etc/init.d/rpcd restart >/dev/null 2>&1
/etc/init.d/uhttpd restart >/dev/null 2>&1

LAN_IP=$(uci -q get network.lan.ipaddr || echo "192.168.1.1")

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "🌀 UzumakiClash Installed Successfully on OpenWrt ($PKG_TYPE)!"
echo ""
echo "   🌐 LuCI Panel: http://$LAN_IP"
echo "                  ➔ Services ➔ UzumakiClash 🌀"
echo "   📊 Dashboard:  http://$LAN_IP:9595/ui"
echo "   🔑 Secret:     flclash123"
echo "══════════════════════════════════════════════════════════════"
