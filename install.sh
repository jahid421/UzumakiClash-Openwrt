#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════
# 🌀 UzumakiClash - Master Universal Installer (Themed + ash-safe)
# Repo: https://github.com/jahid421/UzumakiClash-Openwrt
# Developer: Jahid Hasan Shuvo (@crazy_boy_jahid)
# Run: curl -fsSL .../install.sh | sh
# ═══════════════════════════════════════════════════════════════════════

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

REPO="https://raw.githubusercontent.com/jahid421/UzumakiClash-Openwrt/main"
TS=$(date +%s)
V="v1.18.10"
D="/etc/mihomo"

clear 2>/dev/null || true

printf "%b\n" "${PURPLE}"
cat << "EOF"
   _   _                            _    _  ____ _           _     
  | | | |_____   _ _ __ ___   __ _ | | _(_)/ ___| | __ _ ___| |__  
  | | | |_  / | | | '_ ` _ \ / _` || |/ / | |   | |/ _` / __| '_ \ 
  | |_| |/ /| |_| | | | | | | (_| ||   <| | |___| | (_| \__ \ | | |
   \___//___|\__,_|_| |_| |_|\__,_||_|\_\_|\____|_|\__,_|___/_| |_|

        🌀 Ultra-Lightweight • Zero-Delay • Gaming Optimized 🎮
EOF
printf "%b\n" "${NC}"

printf "%b\n" "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
printf "%b\n" "${CYAN}║${BOLD}${YELLOW}   UzumakiClash Universal Installer  v${V}                ${NC}${CYAN}║${NC}"
printf "%b\n" "${CYAN}║${NC}   Auto-Detect: opkg/apk | Precision Arch | Turbo Gaming     ${CYAN}║${NC}"
printf "%b\n" "${CYAN}║${NC}   Developer: ${BOLD}Jahid Hasan Shuvo${NC} ${GREEN}(@crazy_boy_jahid)${NC}          ${CYAN}║${NC}"
printf "%b\n" "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
printf "\n"

printf "%b\n" "${YELLOW}[→] Detecting package manager...${NC}"
if command -v apk >/dev/null 2>&1; then
    PKG="apk"
    printf "%b\n" "${GREEN}[✓] Detected: APK Package Manager (OpenWrt Snapshot)${NC}"
    apk update >/dev/null 2>&1 || true
    apk add curl ca-certificates ip-full kmod-tun coreutils-nohup gzip tar busybox >/dev/null 2>&1 || true
else
    PKG="opkg"
    printf "%b\n" "${GREEN}[✓] Detected: OPKG Package Manager (OpenWrt Stable)${NC}"
    opkg update >/dev/null 2>&1 || true
    opkg install curl ca-bundle ca-certificates ip-full kmod-tun coreutils-nohup gzip tar busybox luci-compat luci-lib-ipkg >/dev/null 2>&1 || true
fi

printf "\n"
printf "%b\n" "${YELLOW}[→] Detecting CPU architecture...${NC}"
UNAME_M=$(uname -m)
OPKG_ARCH=""
if [ "$PKG" = "opkg" ]; then
    OPKG_ARCH=$(opkg print-architecture 2>/dev/null | awk '{print $2}' | grep -v 'all\|noarch' | head -n 1)
fi

if echo "$OPKG_ARCH" | grep -q "mipsel" || grep -q "MT7621" /proc/cpuinfo 2>/dev/null; then
    M="mipsle-softfloat"
elif echo "$OPKG_ARCH" | grep -q "mips" || echo "$UNAME_M" | grep -q "mips"; then
    M="mips-softfloat"
elif [ "$UNAME_M" = "aarch64" ] || echo "$OPKG_ARCH" | grep -q "aarch64"; then
    M="arm64"
elif echo "$UNAME_M" | grep -q "armv7" || echo "$OPKG_ARCH" | grep -q "arm"; then
    M="armv7"
elif [ "$UNAME_M" = "x86_64" ]; then
    M="amd64-compatible"
elif echo "$UNAME_M" | grep -q "i[3-6]86"; then
    M="386"
else
    M="mipsle-softfloat"
fi
printf "%b\n" "${GREEN}[✓] Target Core: ${BOLD}${M}${NC} ${GREEN}(Device: ${OPKG_ARCH:-$UNAME_M})${NC}"

printf "\n"
printf "%b\n" "${YELLOW}[→] Downloading Mihomo Core (${V})...${NC}"
cd /tmp && rm -f mihomo.gz mihomo
curl -sL -o mihomo.gz "https://github.com/MetaCubeX/mihomo/releases/download/${V}/mihomo-linux-${M}-${V}.gz"
gzip -d -f mihomo.gz 2>/dev/null || gunzip -f mihomo.gz
chmod +x mihomo

if ./mihomo -v >/dev/null 2>&1; then
    mv mihomo /usr/bin/mihomo
    printf "%b\n" "${GREEN}[✓] Core installed: ${BOLD}$(/usr/bin/mihomo -v | head -n 1)${NC}"
else
    printf "%b\n" "${YELLOW}[!] Softfloat failed, trying hardfloat fallback...${NC}"
    curl -sL -o mihomo.gz "https://github.com/MetaCubeX/mihomo/releases/download/${V}/mihomo-linux-mipsle-hardfloat-${V}.gz"
    gunzip -f mihomo.gz
    chmod +x mihomo
    mv mihomo /usr/bin/mihomo
    printf "%b\n" "${GREEN}[✓] Core installed (hardfloat)${NC}"
fi

printf "\n"
printf "%b\n" "${YELLOW}[→] Creating directory structure...${NC}"
mkdir -p "$D/ui" "$D/proxy_provider" "$D/rule_provider" "$D/logs"
mkdir -p /www/cgi-bin /usr/lib/lua/luci/controller /usr/lib/lua/luci/view/mihomo
mkdir -p /usr/share/luci/menu.d /usr/share/rpcd/acl.d
printf "%b\n" "${GREEN}[✓] Directories created${NC}"

printf "\n"
printf "%b\n" "${YELLOW}[→] Syncing project files from GitHub...${NC}"
curl -sL -o /etc/init.d/mihomo "${REPO}/files/mihomo.init?${TS}" && chmod +x /etc/init.d/mihomo
curl -sL -o /www/cgi-bin/mihomo-api "${REPO}/files/mihomo-api?${TS}" && chmod +x /www/cgi-bin/mihomo-api
curl -sL -o /www/cgi-bin/mihomo-cfg "${REPO}/files/mihomo-cfg?${TS}" && chmod +x /www/cgi-bin/mihomo-cfg
curl -sL -o /www/cgi-bin/mihomo-sub "${REPO}/files/mihomo-sub?${TS}" && chmod +x /www/cgi-bin/mihomo-sub
curl -sL -o "$D/nft.conf" "${REPO}/files/nft.conf?${TS}"
curl -sL -o "$D/config.yaml" "${REPO}/files/config.default.yaml?${TS}"
curl -sL -o /usr/lib/lua/luci/controller/mihomo.lua "${REPO}/files/mihomo.lua?${TS}"
curl -sL -o /usr/lib/lua/luci/view/mihomo/main.htm "${REPO}/files/main.htm?${TS}"
printf "%b\n" "${GREEN}[✓] All project files synced${NC}"

printf "\n"
printf "%b\n" "${YELLOW}[→] Registering LuCI menu & ACL permissions...${NC}"
cat << 'EOF' > /usr/share/luci/menu.d/luci-app-mihomo.json
{
    "admin/services/mihomo": {
        "title": "UzumakiClash 🌀",
        "action": {
            "type": "template",
            "path": "mihomo/main"
        }
    }
}
EOF

cat << 'EOF' > /usr/share/rpcd/acl.d/luci-app-mihomo.json
{
    "luci-app-mihomo": {
        "description": "Grant access to UzumakiClash",
        "read": { "ubus": { "file": [ "read", "stat" ] }, "uci": [ "mihomo" ] },
        "write": { "file": { "/etc/mihomo/*": [ "read", "write" ] } }
    }
}
EOF
printf "%b\n" "${GREEN}[✓] LuCI integration complete${NC}"

printf "\n"
printf "%b\n" "${YELLOW}[→] Installing MetaCubeXD Dashboard...${NC}"
cd /tmp && rm -f ui.tgz
curl -sL -o ui.tgz "https://github.com/MetaCubeX/metacubexd/releases/latest/download/compressed-dist.tgz"
tar -xzf ui.tgz -C "$D/ui/"
if [ -d "$D/ui/dist" ]; then
    mv "$D/ui/dist/"* "$D/ui/" 2>/dev/null || true
    rm -rf "$D/ui/dist"
fi
rm -f /tmp/ui.tgz
printf "%b\n" "${GREEN}[✓] Dashboard installed${NC}"

printf "\n"
printf "%b\n" "${YELLOW}[→] Enabling and starting UzumakiClash service...${NC}"
echo "1" > "$D/enabled"
echo "1" > "$D/transparent"
/etc/init.d/mihomo enable 2>/dev/null || true
/etc/init.d/mihomo restart 2>/dev/null || true
rm -rf /tmp/luci-*
/etc/init.d/rpcd restart 2>/dev/null || true
/etc/init.d/uhttpd restart 2>/dev/null || true
sleep 2

LAN_IP=$(uci get network.lan.ipaddr 2>/dev/null || echo "192.168.1.1")
PID=$(pidof mihomo 2>/dev/null || true)
RAM=""
if [ -n "$PID" ]; then
    RAM=$(awk '/VmRSS/{print $2}' /proc/$PID/status 2>/dev/null || true)
fi

printf "\n"
printf "%b\n" "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
printf "%b\n" "${GREEN}║${BOLD}          ✅  UzumakiClash Installed Successfully!  ✅        ${NC}${GREEN}║${NC}"
printf "%b\n" "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
printf "\n"
printf "%b\n" "  ${CYAN}🌐 LuCI Panel     :${NC} ${BOLD}http://${LAN_IP}/cgi-bin/luci/admin/services/mihomo${NC}"
printf "%b\n" "  ${CYAN}🎨 Dashboard      :${NC} ${BOLD}http://${LAN_IP}:9595/ui${NC}"
printf "%b\n" "  ${CYAN}🔑 API Secret     :${NC} ${BOLD}flclash123${NC}"
printf "%b\n" "  ${CYAN}📂 Config Path    :${NC} ${BOLD}/etc/mihomo/config.yaml${NC}"
printf "\n"
if [ -n "$PID" ]; then
    printf "%b\n" "  ${GREEN}⚡ Engine Status   : ${BOLD}Running${NC} ${GREEN}(PID: ${PID} | RAM: ${RAM} kB)${NC}"
else
    printf "%b\n" "  ${YELLOW}⚡ Engine Status   : Starting...${NC}"
fi
printf "\n"
printf "%b\n" "${PURPLE}  ┌────────────────────────────────────────────────────────┐${NC}"
printf "%b\n" "${PURPLE}  │${NC}  ${YELLOW}▸ Start   :${NC} /etc/init.d/mihomo start                  ${PURPLE}│${NC}"
printf "%b\n" "${PURPLE}  │${NC}  ${YELLOW}▸ Stop    :${NC} /etc/init.d/mihomo stop                   ${PURPLE}│${NC}"
printf "%b\n" "${PURPLE}  │${NC}  ${YELLOW}▸ Restart :${NC} /etc/init.d/mihomo restart                ${PURPLE}│${NC}"
printf "%b\n" "${PURPLE}  └────────────────────────────────────────────────────────┘${NC}"
printf "\n"
printf "%b\n" "${CYAN}  💜 Thank you for choosing UzumakiClash! Enjoy the speed! 🚀${NC}"
printf "\n"
