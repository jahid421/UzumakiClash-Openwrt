#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════
# 🌀 UzumakiClash - Universal Uninstaller (opkg & apk Clean Purge)
# Repo: https://github.com/jahid421/UzumakiClash-Openwrt
# Developer: Jahid Hasan Shuvo (@crazy_boy_jahid)
# ═══════════════════════════════════════════════════════════════════════

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  🌀 UzumakiClash Universal Uninstaller                        ║"
echo "║  Safely Reverting Network, Firewall & System Changes         ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# ১. সার্ভিস বন্ধ করা
if [ -f /etc/init.d/mihomo ]; then
    echo "[*] Stopping UzumakiClash daemon..."
    /etc/init.d/mihomo stop >/dev/null 2>&1
    /etc/init.d/mihomo disable >/dev/null 2>&1
    killall -9 mihomo >/dev/null 2>&1 || true
    rm -f /etc/init.d/mihomo
fi

# ২. ফায়ারওয়াল টেবিল ক্লিনআপ
echo "[*] Flushing firewall tables..."
/usr/sbin/nft delete table ip uzumaki 2>/dev/null || true

# ৩. হটপ্লাগ ও বাইনারি রিমুভ
rm -f /usr/bin/mihomo
rm -rf /etc/mihomo

# ৪. পুরনো CGI স্ক্রিপ্টস রিমুভ
rm -f /www/cgi-bin/mihomo-*

# ৫. LuCI মেনু ক্লিনআপ
rm -f /usr/lib/lua/luci/controller/mihomo.lua
rm -rf /usr/lib/lua/luci/view/mihomo
rm -f /usr/share/luci/menu.d/luci-app-uzumakiclash.json

# ৬. ফায়ারওয়াল UCI রুলস রিমুভ
uci -q delete firewall.uzumaki_rule 2>/dev/null
uci -q delete firewall.mihomo_proxy 2>/dev/null
uci commit firewall
/etc/init.d/firewall restart >/dev/null 2>&1 || true

# ৭. LuCI ও uhttpd ক্যাশ রিলোড
rm -rf /tmp/luci-*
/etc/init.d/rpcd restart >/dev/null 2>&1
/etc/init.d/uhttpd restart >/dev/null 2>&1

echo "✅ UzumakiClash has been completely removed!"
