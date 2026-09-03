#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════
# 🌀 UzumakiClash - Universal Uninstaller (opkg & apk Clean Purge)
# Repo: https://github.com/jahid421/UzumakiClash-Openwrt
# Developer: Jahid Hasan Shuvo (@crazy_boy_jahid)
# ═══════════════════════════════════════════════════════════════════════

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  🌀 UzumakiClash Universal Uninstaller                       ║"
echo "║  Safely Reverting Network, Firewall & System Changes         ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

if [ -f /etc/init.d/mihomo ]; then
    echo "[*] Stopping UzumakiClash daemon..."
    /etc/init.d/mihomo stop >/dev/null 2>&1
    /etc/init.d/mihomo disable >/dev/null 2>&1
    killall -9 mihomo >/dev/null 2>&1 || true
    rm -f /etc/init.d/mihomo
fi

echo "[*] Flushing firewall tables..."
/usr/sbin/nft delete table ip uzumaki 2>/dev/null || true
/usr/sbin/nft delete table inet uzumaki 2>/dev/null || true
rm -f /etc/sysctl.d/99-uzumaki-tune.conf

rm -f /etc/hotplug.d/iface/99-uzumaki
rm -f /usr/bin/mihomo
rm -rf /etc/mihomo

rm -f /www/cgi-bin/mihomo-api
rm -f /www/cgi-bin/mihomo-cfg
rm -f /www/cgi-bin/mihomo-sub

rm -f /usr/lib/lua/luci/controller/mihomo.lua
rm -rf /usr/lib/lua/luci/view/mihomo
rm -f /usr/share/luci/menu.d/luci-app-uzumakiclash.json

uci -q delete firewall.uzumaki_rule 2>/dev/null
uci -q delete firewall.mihomo_proxy 2>/dev/null
uci commit firewall
/etc/init.d/firewall restart >/dev/null 2>&1 || true

rm -rf /tmp/luci-*
/etc/init.d/rpcd restart >/dev/null 2>&1
/etc/init.d/uhttpd restart >/dev/null 2>&1

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "✅ UzumakiClash has been completely removed!"
echo "    Your router's native network has been fully restored."
echo "══════════════════════════════════════════════════════════════"
echo ""
