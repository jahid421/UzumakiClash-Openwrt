#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════
# 🌀 UzumakiClash - Master Universal Installer (Final)
# Repo: https://github.com/jahid421/UzumakiClash-Openwrt
# Developer: Jahid Hasan Shuvo (@crazy_boy_jahid)
# Supports: OpenWrt 21/22/23/24 (opkg) + OpenWrt 25+ (apk)
# Run: curl -fsSL https://raw.githubusercontent.com/jahid421/UzumakiClash-Openwrt/main/install.sh | sh
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

# ─── 1. Package Manager (opkg / apk) ──────────────────────────
printf "%b\n" "${YELLOW}[→] Detecting package manager...${NC}"
if command -v apk >/dev/null 2>&1; then
    PKG="apk"
    printf "%b\n" "${GREEN}[✓] Detected: APK (OpenWrt 25+ / Snapshot)${NC}"
    apk update >/dev/null 2>&1 || true
    # NOTE: apk has NO ca-bundle package — use ca-certificates
    apk add curl ca-certificates kmod-tun ip-full coreutils-nohup gzip tar busybox \
            luci-lua-runtime lua luci-compat \
            luci-lib-nixio luci-lib-ip luci-lib-jsonc \
            >/dev/null 2>&1 || true
    apk add lua5.1 2>/dev/null || true
elif command -v opkg >/dev/null 2>&1; then
    PKG="opkg"
    printf "%b\n" "${GREEN}[✓] Detected: OPKG (OpenWrt Stable 21–24)${NC}"
    opkg update >/dev/null 2>&1 || true
    opkg install curl ca-bundle ca-certificates kmod-tun ip-full coreutils-nohup gzip tar busybox \
                 luci-lua-runtime lua luci-compat luci-lib-ipkg \
                 luci-lib-nixio luci-lib-ip luci-lib-jsonc \
                 >/dev/null 2>&1 || true
else
    printf "%b\n" "${RED}[✗] No apk/opkg found. Aborting.${NC}"
    exit 1
fi

# ─── 2. CPU Architecture ─────────────────────────────────────
printf "\n"
printf "%b\n" "${YELLOW}[→] Detecting CPU architecture...${NC}"
UNAME_M=$(uname -m)
ARCH_HINT=""
if [ "$PKG" = "opkg" ]; then
    ARCH_HINT=$(opkg print-architecture 2>/dev/null | awk '{print $2}' | grep -v 'all\|noarch' | head -n 1)
fi

if echo "$ARCH_HINT" | grep -q "mipsel" || grep -q "MT7621" /proc/cpuinfo 2>/dev/null || echo "$UNAME_M" | grep -qi "mipsel"; then
    M="mipsle-softfloat"
elif echo "$ARCH_HINT" | grep -q "mips" || echo "$UNAME_M" | grep -q "mips"; then
    M="mips-softfloat"
elif [ "$UNAME_M" = "aarch64" ] || echo "$ARCH_HINT" | grep -q "aarch64"; then
    M="arm64"
elif echo "$UNAME_M" | grep -q "armv7" || echo "$ARCH_HINT" | grep -q "arm_cortex"; then
    M="armv7"
elif [ "$UNAME_M" = "x86_64" ] || echo "$ARCH_HINT" | grep -q "x86_64"; then
    M="amd64-compatible"
elif echo "$UNAME_M" | grep -q "i[3-6]86"; then
    M="386"
else
    M="mipsle-softfloat"
fi
printf "%b\n" "${GREEN}[✓] Target Core: ${BOLD}${M}${NC} ${GREEN}(Device: ${ARCH_HINT:-$UNAME_M})${NC}"

# ─── 3. Mihomo Core ──────────────────────────────────────────
printf "\n"
printf "%b\n" "${YELLOW}[→] Downloading Mihomo Core (${V})...${NC}"
cd /tmp
rm -f mihomo.gz mihomo

curl -fsSL -o mihomo.gz \
  "https://github.com/MetaCubeX/mihomo/releases/download/${V}/mihomo-linux-${M}-${V}.gz" \
  || curl -fsSL -o mihomo.gz \
  "https://github.com/MetaCubeX/mihomo/releases/download/${V}/mihomo-linux-${M}-${V}.gz"

gzip -d -f mihomo.gz 2>/dev/null || gunzip -f mihomo.gz
chmod +x mihomo

if ./mihomo -v >/dev/null 2>&1; then
    mv -f mihomo /usr/bin/mihomo
    printf "%b\n" "${GREEN}[✓] Core: ${BOLD}$(/usr/bin/mihomo -v | head -n 1)${NC}"
else
    printf "%b\n" "${YELLOW}[!] Softfloat failed, trying mipsle-hardfloat...${NC}"
    rm -f mihomo.gz mihomo
    curl -fsSL -o mihomo.gz \
      "https://github.com/MetaCubeX/mihomo/releases/download/${V}/mihomo-linux-mipsle-hardfloat-${V}.gz"
    gunzip -f mihomo.gz
    chmod +x mihomo
    mv -f mihomo /usr/bin/mihomo
    if /usr/bin/mihomo -v >/dev/null 2>&1; then
        printf "%b\n" "${GREEN}[✓] Core installed (hardfloat)${NC}"
    else
        printf "%b\n" "${RED}[✗] Mihomo binary failed to run on this arch${NC}"
        exit 1
    fi
fi

# ─── 4. Directories ──────────────────────────────────────────
printf "\n"
printf "%b\n" "${YELLOW}[→] Creating directories...${NC}"
mkdir -p "$D/ui" "$D/proxy_provider" "$D/rule_provider" "$D/logs"
mkdir -p /www/cgi-bin
mkdir -p /usr/lib/lua/luci/controller
mkdir -p /usr/lib/lua/luci/view/mihomo
mkdir -p /usr/share/luci/menu.d
mkdir -p /usr/share/rpcd/acl.d
printf "%b\n" "${GREEN}[✓] Directories ready${NC}"

# ─── 5. Project files from GitHub ────────────────────────────
printf "\n"
printf "%b\n" "${YELLOW}[→] Syncing project files from GitHub...${NC}"
curl -fsSL -o /etc/init.d/mihomo          "${REPO}/files/mihomo.init?${TS}"
curl -fsSL -o /www/cgi-bin/mihomo-api     "${REPO}/files/mihomo-api?${TS}"
curl -fsSL -o /www/cgi-bin/mihomo-cfg     "${REPO}/files/mihomo-cfg?${TS}"
curl -fsSL -o /www/cgi-bin/mihomo-sub     "${REPO}/files/mihomo-sub?${TS}"
curl -fsSL -o "$D/nft.conf"               "${REPO}/files/nft.conf?${TS}"
curl -fsSL -o "$D/config.yaml"            "${REPO}/files/config.default.yaml?${TS}"
curl -fsSL -o /usr/lib/lua/luci/controller/mihomo.lua "${REPO}/files/mihomo.lua?${TS}"
curl -fsSL -o /usr/lib/lua/luci/view/mihomo/main.htm  "${REPO}/files/main.htm?${TS}"

chmod +x /etc/init.d/mihomo /www/cgi-bin/mihomo-api /www/cgi-bin/mihomo-cfg /www/cgi-bin/mihomo-sub /usr/bin/mihomo
printf "%b\n" "${GREEN}[✓] Project files synced${NC}"

# ─── 6. LuCI Menu + ACL (OpenWrt 23/24/25) ───────────────────
printf "\n"
printf "%b\n" "${YELLOW}[→] Registering LuCI menu & ACL...${NC}"
cat << 'EOF' > /usr/share/luci/menu.d/luci-app-mihomo.json
{
  "admin/services/mihomo": {
    "title": "UzumakiClash 🌀",
    "order": 60,
    "action": {
      "type": "template",
      "path": "mihomo/main"
    },
    "depends": {
      "acl": [ "luci-app-mihomo" ]
    }
  }
}
EOF

cat << 'EOF' > /usr/share/rpcd/acl.d/luci-app-mihomo.json
{
  "luci-app-mihomo": {
    "description": "Grant access to UzumakiClash",
    "read": {
      "ubus": { "file": [ "read", "stat", "exec" ] },
      "cgi-io": [ "exec" ],
      "file": {
        "/etc/mihomo/*": [ "read" ],
        "/usr/bin/mihomo": [ "read" ],
        "/www/cgi-bin/mihomo-*": [ "exec" ]
      },
      "uci": [ "mihomo" ]
    },
    "write": {
      "ubus": { "file": [ "write", "exec" ] },
      "cgi-io": [ "exec" ],
      "file": {
        "/etc/mihomo/*": [ "write" ],
        "/www/cgi-bin/mihomo-*": [ "exec" ]
      }
    }
  }
}
EOF
printf "%b\n" "${GREEN}[✓] LuCI integration complete${NC}"

# ─── 7. MetaCubeXD Dashboard ─────────────────────────────────
printf "\n"
printf "%b\n" "${YELLOW}[→] Installing MetaCubeXD Dashboard...${NC}"
cd /tmp
rm -f ui.tgz
rm -rf "$D/ui"
mkdir -p "$D/ui"
if curl -fsSL -o ui.tgz "https://github.com/MetaCubeX/metacubexd/releases/latest/download/compressed-dist.tgz"; then
    tar -xzf ui.tgz -C "$D/ui/" 2>/dev/null || true
    if [ -d "$D/ui/dist" ]; then
        mv "$D/ui/dist/"* "$D/ui/" 2>/dev/null || true
        rm -rf "$D/ui/dist"
    fi
    rm -f ui.tgz
    printf "%b\n" "${GREEN}[✓] Dashboard installed${NC}"
else
    printf "%b\n" "${YELLOW}[!] Dashboard download skipped (optional)${NC}"
fi

# ─── 8. Enable flags + start service ─────────────────────────
printf "\n"
printf "%b\n" "${YELLOW}[→] Enabling and starting service...${NC}"
echo "1" > "$D/enabled"
echo "1" > "$D/transparent"

/etc/init.d/mihomo enable 2>/dev/null || true
/etc/init.d/mihomo restart 2>/dev/null || true

rm -rf /tmp/luci-* /tmp/luci-indexcache* 2>/dev/null || true
/etc/init.d/rpcd restart 2>/dev/null || true
/etc/init.d/uhttpd restart 2>/dev/null || true
/etc/init.d/nginx restart 2>/dev/null || true
sleep 2

LAN_IP=$(uci -q get network.lan.ipaddr 2>/dev/null || echo "192.168.1.1")
PID=$(pidof mihomo 2>/dev/null || true)
RAM=""
if [ -n "$PID" ] && [ -r "/proc/$PID/status" ]; then
    RAM=$(awk '/VmRSS/{print $2}' "/proc/$PID/status" 2>/dev/null || true)
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
printf "%b\n" "  ${CYAN}📦 Package Mgr    :${NC} ${BOLD}${PKG}${NC}"
printf "\n"
if [ -n "$PID" ]; then
    printf "%b\n" "  ${GREEN}⚡ Engine Status   : ${BOLD}Running${NC} ${GREEN}(PID: ${PID} | RAM: ${RAM:-?} kB)${NC}"
else
    printf "%b\n" "  ${YELLOW}⚡ Engine Status   : Starting / check logs: logread | grep mihomo${NC}"
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
