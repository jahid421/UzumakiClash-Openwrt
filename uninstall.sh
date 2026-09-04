#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════
# 🌀 UzumakiClash - Universal Uninstaller (Themed Edition)
# Repo: https://github.com/jahid421/UzumakiClash-Openwrt
# ═══════════════════════════════════════════════════════════════════════

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

clear
echo -e "${PURPLE}"
cat << "EOF"
   _   _                            _    _  ____ _           _     
  | | | |_____   _ _ __ ___   __ _ | | _(_)/ ___| | __ _ ___| |__  
  | | | |_  / | | | '_ ` _ \ / _` || |/ / | |   | |/ _` / __| '_ \ 
  | |_| |/ /| |_| | | | | | | (_| ||   <| | |___| | (_| \__ \ | | |
   \___//___|\__,_|_| |_| |_|\__,_||_|\_\_|\____|_|\__,_|___/_| |_|

              🗑️  Universal Uninstaller  🗑️
EOF
echo -e "${NC}"
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${BOLD}${YELLOW}         UzumakiClash Safe & Clean Purge System         ${NC}${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}[→] Stopping UzumakiClash daemon...${NC}"
if [ -f /etc/init.d/mihomo ]; then
    /etc/init.d/mihomo stop >/dev/null 2>&1 || true
    /etc/init.d/mihomo disable >/dev/null 2>&1 || true
    rm -f /etc/init.d/mihomo
fi
killall -9 mihomo 2>/dev/null || true
echo -e "${GREEN}[✓] Service stopped${NC}"

echo ""
echo -e "${YELLOW}[→] Flushing firewall tables...${NC}"
/usr/sbin/nft delete table ip uzumaki 2>/dev/null || true
/usr/sbin/nft delete table inet uzumaki 2>/dev/null || true
rm -f /etc/sysctl.d/99-uzumaki-tune.conf
echo -e "${GREEN}[✓] Firewall cleaned${NC}"

echo ""
echo -e "${YELLOW}[→] Removing binaries and configurations...${NC}"
rm -f /usr/bin/mihomo
rm -rf /etc/mihomo
echo -e "${GREEN}[✓] Core files removed${NC}"

echo ""
echo -e "${YELLOW}[→] Removing CGI backend scripts...${NC}"
rm -f /www/cgi-bin/mihomo-api /www/cgi-bin/mihomo-cfg /www/cgi-bin/mihomo-sub
echo -e "${GREEN}[✓] CGI scripts removed${NC}"

echo ""
echo -e "${YELLOW}[→] Removing LuCI UI, Menu, and ACL...${NC}"
rm -f /usr/lib/lua/luci/controller/mihomo.lua
rm -rf /usr/lib/lua/luci/view/mihomo
rm -f /usr/share/luci/menu.d/*mihomo*.json
rm -f /usr/share/rpcd/acl.d/*mihomo*.json
echo -e "${GREEN}[✓] Web UI components removed${NC}"

echo ""
echo -e "${YELLOW}[→] Reloading web server cache...${NC}"
rm -rf /tmp/luci-*
/etc/init.d/rpcd restart >/dev/null 2>&1 || true
/etc/init.d/uhttpd restart >/dev/null 2>&1 || true
echo -e "${GREEN}[✓] Web server refreshed${NC}"

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${BOLD}         ✅  UzumakiClash Completely Removed!  ✅            ${NC}${GREEN}║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${CYAN}💜 Your router's native network is now fully restored.${NC}"
echo -e "  ${CYAN}   Thank you for using UzumakiClash!${NC}"
echo ""
