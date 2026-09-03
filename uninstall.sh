#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════
# 🌀 UzumakiClash - Universal Uninstaller
# Repo: https://github.com/jahid421/UzumakiClash-Openwrt
# Developer: Jahid Hasan Shuvo (@crazy_boy_jahid)
# ═══════════════════════════════════════════════════════════════════════

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  🌀 UzumakiClash Universal Uninstaller                        ║"
echo "║  Safely Reverting Network, Firewall & System Changes         ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# ১. সার্ভিস ও বাইনারি বন্ধ করা
if [ -f /etc/init.d/mihomo ]; then
    echo "[*] Stopping UzumakiClash daemon..."
    /etc/init.d/mihomo stop >/dev/null 2>&1 || true
    /etc/init.d/mihomo disable >/dev/null 2>&1 || true
    rm -f /etc/init.d/mihomo
fi

killall -9 mihomo 2>/dev/null || true

# ২. ফায়ারওয়াল টেবিল ও আইপি ক্লিনআপ
echo "[*] Flushing firewall tables..."
/usr/sbin/nft delete table ip uzumaki 2>/dev/null || true
/usr/sbin/nft delete table inet uzumaki 2>/dev/null || true
rm -f /etc/sysctl.d/99-uzumaki-tune.conf

# ৩. ফাইল ও কনফিগ রিমুভ
echo "[*] Removing core binaries and configurations..."
rm -f /usr/bin/mihomo
rm -rf /etc/mihomo

# ৪. CGI স্ক্রিপ্টস রিমুভ
rm -f /www/cgi-bin/mihomo-api /www/cgi-bin/mihomo-cfg /www/cgi-bin/mihomo-sub

# ৫. LuCI মেনু ও ACL ক্লিনআপ
echo "[*] Removing Web UI components..."
rm -f /usr/lib/lua/luci/controller/mihomo.lua
rm -rf /usr/lib/lua/luci/view/mihomo
rm -f /usr/share/luci/menu.d/*mihomo*.json
rm -f /usr/share/rpcd/acl.d/*mihomo*.json

# ৬. ক্যাশ রিলোড
rm -rf /tmp/luci-*
/etc/init.d/rpcd restart >/dev/null 2>&1 || true
/etc/init.d/uhttpd restart >/dev/null 2>&1 || true

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "✅ UzumakiClash has been completely removed!"
echo "   Your router's native network has been fully restored."
echo "══════════════════════════════════════════════════════════════"
echo ""
