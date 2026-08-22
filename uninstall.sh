#!/bin/sh
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  🌀 UzumakiClash Safe Uninstaller                             ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# ১. সার্ভিস পুরোপুরি বন্ধ করা
if [ -f /etc/init.d/mihomo ]; then
    /etc/init.d/mihomo stop >/dev/null 2>&1
    /etc/init.d/mihomo disable >/dev/null 2>&1
    killall -9 mihomo >/dev/null 2>&1 || true
    rm -f /etc/init.d/mihomo
fi

# ২. dnsmasq ডিফল্ট অবস্থায় নিশ্চিত করা
uci -q delete dhcp.@dnsmasq[0].server
uci -q delete dhcp.@dnsmasq[0].noresolv
uci commit dhcp
/etc/init.d/dnsmasq restart >/dev/null 2>&1

# ৩. কাস্টম টেবিল ডিলিট
nft delete table inet uzumaki 2>/dev/null || true
nft delete table inet mihomo 2>/dev/null || true
/etc/init.d/firewall restart >/dev/null 2>&1

# ৪. ফাইল রিমুভ
rm -f /usr/bin/mihomo
rm -rf /etc/mihomo
rm -f /www/cgi-bin/mihomo-*
rm -f /usr/lib/lua/luci/controller/mihomo.lua
rm -rf /usr/lib/lua/luci/view/mihomo
rm -f /usr/share/luci/menu.d/luci-app-uzumakiclash.json
rm -f /etc/hotplug.d/iface/99-uzumaki

rm -rf /tmp/luci-*
/etc/init.d/rpcd restart >/dev/null 2>&1
/etc/init.d/uhttpd restart >/dev/null 2>&1

echo "✅ UzumakiClash has been safely removed. Your internet is 100% normal!"
