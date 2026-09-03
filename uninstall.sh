#!/bin/sh
# UzumakiClash - Safe Uninstaller

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[!] This will completely remove UzumakiClash. Continue? (y/N)${NC}"
read -r confirm
[ "$confirm" != "y" ] && [ "$confirm" != "Y" ] && exit 0

echo -e "${YELLOW}[→] Stopping service...${NC}"
/etc/init.d/uzumaki stop 2>/dev/null
/etc/init.d/uzumaki disable 2>/dev/null

echo -e "${YELLOW}[→] Cleaning firewall rules...${NC}"
nft delete table inet uzumaki 2>/dev/null
ip rule del fwmark 0x1 table 100 2>/dev/null
ip route flush table 100 2>/dev/null
ip link del uzumaki-tun 2>/dev/null

echo -e "${YELLOW}[→] Removing files...${NC}"
rm -rf /etc/uzumaki
rm -rf /www/luci-static/resources/view/uzumaki
rm -f  /usr/bin/uzumaki-core
rm -f  /usr/bin/uzumaki-api
rm -f  /usr/bin/uzumaki-cfg
rm -f  /usr/bin/uzumaki-sub
rm -f  /etc/init.d/uzumaki
rm -f  /usr/lib/lua/luci/controller/uzumaki.lua
rm -rf /tmp/luci-*

echo -e "${GREEN}[✓] UzumakiClash removed successfully!${NC}"
