#!/bin/sh
echo "🌀 UzumakiClash Universal Uninstaller"

if [ -f /etc/init.d/mihomo ]; then
    /etc/init.d/mihomo stop >/dev/null 2>&1 || true
    /etc/init.d/mihomo disable >/dev/null 2>&1 || true
    rm -f /etc/init.d/mihomo
fi

killall -9 mihomo 2>/dev/null || true

/usr/sbin/nft delete table ip uzumaki 2>/dev/null || true
/usr/sbin/nft delete table inet uzumaki 2>/dev/null || true

rm -f /usr/bin/mihomo
rm -rf /etc/mihomo
rm -f /www/cgi-bin/mihomo-api /www/cgi-bin/mihomo-cfg /www/cgi-bin/mihomo-sub
rm -f /usr/lib/lua/luci/controller/mihomo.lua
rm -rf /usr/lib/lua/luci/view/mihomo
rm -f /usr/share/luci/menu.d/*mihomo*.json
rm -f /usr/share/rpcd/acl.d/*mihomo*.json

rm -rf /tmp/luci-*
/etc/init.d/rpcd restart >/dev/null 2>&1 || true
/etc/init.d/uhttpd restart >/dev/null 2>&1 || true

echo "✅ UzumakiClash has been completely removed!"
