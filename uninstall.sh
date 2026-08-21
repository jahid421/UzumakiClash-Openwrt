#!/bin/sh
# ═══════════════════════════════════════════════
# 🌀 UzumakiClash - Master Uninstaller & Purger
# ═══════════════════════════════════════════════

echo ""
echo "╔══════════════════════════════════════╗"
echo "║  🌀 UzumakiClash Uninstaller         ║"
echo "║  Safely Reverting Network & Firewall ║"
echo "╚══════════════════════════════════════╝"
echo ""

# ১. সার্ভিস বন্ধ করা
if [ -f /etc/init.d/mihomo ]; then
    echo "[*] Stopping UzumakiClash service..."
    /etc/init.d/mihomo stop >/dev/null 2>&1
    /etc/init.d/mihomo disable >/dev/null 2>&1
    killall -9 mihomo >/dev/null 2>&1 || true
    rm -f /etc/init.d/mihomo
fi

# ২. ফায়ারওয়াল এবং পলিসি রাউটিং টেবিল ক্লিনআপ
echo "[*] Cleaning up nftables & policy routes..."
nft delete table inet uzumaki 2>/dev/null || true
nft delete table inet mihomo 2>/dev/null || true
ip rule del fwmark 0x1 table 100 2>/dev/null || true
ip route del local 0.0.0.0/0 dev lo table 100 2>/dev/null || true

# ৩. হটপ্লাগ স্ক্রিপ্ট রিমুভ
rm -f /etc/hotplug.d/iface/99-uzumaki

# ৪. কোর বাইনারি ও কনফিগ ফোল্ডার রিমুভ
echo "[*] Removing core binaries and configurations..."
rm -f /usr/bin/mihomo
rm -rf /etc/mihomo

# ৫. CGI API স্ক্রিপ্ট রিমুভ
rm -f /www/cgi-bin/mihomo-api
rm -f /www/cgi-bin/mihomo-cfg
rm -f /www/cgi-bin/mihomo-sub

# ৬. LuCI মেনু এবং টেমপ্লেট ক্লিনআপ
echo "[*] Cleaning LuCI interface..."
rm -f /usr/lib/lua/luci/controller/mihomo.lua
rm -rf /usr/lib/lua/luci/view/mihomo
rm -f /usr/share/luci/menu.d/luci-app-uzumakiclash.json
rm -f /usr/share/luci/menu.d/luci-app-dinoclash.json

# ৭. ফায়ারওয়াল রুলস ক্লিনআপ (UCI)
uci -q delete firewall.mihomo_proxy 2>/dev/null
uci commit firewall
/etc/init.d/firewall restart >/dev/null 2>&1 || true

# ৮. ক্যাশ ক্লিয়ার ও সার্ভার রিলোড
rm -rf /tmp/luci-*
/etc/init.d/rpcd restart >/dev/null 2>&1
/etc/init.d/uhttpd restart >/dev/null 2>&1

echo ""
echo "════════════════════════════════════════════"
echo "✅ UzumakiClash has been completely removed!"
echo "   Your router network is back to normal."
echo "════════════════════════════════════════════"
echo ""
