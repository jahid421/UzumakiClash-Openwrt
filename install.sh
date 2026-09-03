#!/bin/sh
# UzumakiClash - Universal Fixed Installer
# Repository: jahid421/UzumakiClash-Openwrt

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

INSTALL_DIR="/etc/uzumaki"
BIN_DIR="/usr/bin"
LUCI_DIR="/usr/lib/lua/luci"
WWW_DIR="/www/luci-static/resources/view/uzumaki"
RAW_BASE="https://raw.githubusercontent.com/jahid421/UzumakiClash-Openwrt/main/files"

echo -e "${CYAN}"
cat << "EOF"
 _   _                            _    _  ____ _           _     
| | | |_____   _ _ __ ___   __ _ | | _(_)/ ___| | __ _ ___| |__  
| | | |_  / | | | '_ ` _ \ / _` || |/ / | |   | |/ _` / __| '_ \ 
| |_| |/ /| |_| | | | | | | (_| ||   <| | |___| | (_| \__ \ | | |
 \___//___|\__,_|_| |_| |_|\__,_||_|\_\_|\____|_|\__,_|___/_| |_|
                    Lightweight • Fast • Universal
EOF
echo -e "${NC}"

# ==========================================
# ধাপ ১: সিস্টেম ও আর্কিটেকচার নিখুঁতভাবে ডিটেক্ট
# ==========================================
if command -v apk >/dev/null 2>&1; then
    PKG="apk"
    PKG_UPDATE="apk update"
    PKG_INSTALL="apk add"
    echo -e "${GREEN}[✓] Detected: APK Package Manager${NC}"
elif command -v opkg >/dev/null 2>&1; then
    PKG="opkg"
    PKG_UPDATE="opkg update"
    PKG_INSTALL="opkg install"
    echo -e "${GREEN}[✓] Detected: OPKG Package Manager${NC}"
else
    echo -e "${RED}[✗] No supported package manager found!${NC}"
    exit 1
fi

# OpenWrt এর জন্য 100% অ্যাকুরেট আর্কিটেকচার ডিটেকশন
OPKG_ARCH=$(opkg print-architecture 2>/dev/null | awk '{print $2}' | grep -v 'all\|noarch' | head -n 1)
UNAME_ARCH=$(uname -m)

if echo "$OPKG_ARCH" | grep -q "mipsel"; then
    MIHOMO_ARCH="linux-mipsle-softfloat"
elif echo "$OPKG_ARCH" | grep -q "mips"; then
    MIHOMO_ARCH="linux-mips-softfloat"
elif [ "$UNAME_ARCH" = "aarch64" ] || echo "$OPKG_ARCH" | grep -q "aarch64"; then
    MIHOMO_ARCH="linux-arm64"
elif [ "$UNAME_ARCH" = "x86_64" ]; then
    MIHOMO_ARCH="linux-amd64-compatible"
elif echo "$UNAME_ARCH" | grep -q "armv7"; then
    MIHOMO_ARCH="linux-armv7"
elif echo "$UNAME_ARCH" | grep -q "i[3-6]86"; then
    MIHOMO_ARCH="linux-386"
else
    MIHOMO_ARCH="linux-mipsle-softfloat"
fi

echo -e "${GREEN}[✓] Target Core: $MIHOMO_ARCH (Device: $OPKG_ARCH)${NC}"

# ==========================================
# ধাপ ২: ডিপেন্ডেন্সি ইনস্টল
# ==========================================
echo -e "${YELLOW}[→] Installing dependencies...${NC}"
$PKG_UPDATE >/dev/null 2>&1

DEPS="curl ca-certificates kmod-tun kmod-nft-tproxy ip-full coreutils-base64 jsonfilter"
for pkg in $DEPS; do
    $PKG_INSTALL $pkg >/dev/null 2>&1 || true
done

# ==========================================
# ধাপ ৩: Mihomo Core ডাউনলোড ও ইনস্টল
# ==========================================
echo -e "${YELLOW}[→] Downloading Mihomo Core (${MIHOMO_ARCH})...${NC}"
MIHOMO_VER=$(curl -sL "https://api.github.com/repos/MetaCubeX/mihomo/releases/latest" | grep tag_name | cut -d'"' -f4)
[ -z "$MIHOMO_VER" ] && MIHOMO_VER="v1.18.10" # fallback

MIHOMO_URL="https://github.com/MetaCubeX/mihomo/releases/download/${MIHOMO_VER}/mihomo-${MIHOMO_ARCH}-${MIHOMO_VER}.gz"

curl -sL -o /tmp/mihomo.gz "$MIHOMO_URL"
gunzip -f /tmp/mihomo.gz
mv /tmp/mihomo ${BIN_DIR}/uzumaki-core
chmod +x ${BIN_DIR}/uzumaki-core

# টেস্ট রান ভ্যালিডেশন
if ${BIN_DIR}/uzumaki-core -v >/dev/null 2>&1; then
    echo -e "${GREEN}[✓] Core installed successfully: $(${BIN_DIR}/uzumaki-core -v | head -1)${NC}"
else
    echo -e "${RED}[✗] Core binary execution failed! Trying alternative build...${NC}"
    # যদি softfloat ব্যর্থ হয়, hardfloat ট্রাই করবে
    curl -sL -o /tmp/mihomo.gz "https://github.com/MetaCubeX/mihomo/releases/download/${MIHOMO_VER}/mihomo-linux-mipsle-hardfloat-${MIHOMO_VER}.gz"
    gunzip -f /tmp/mihomo.gz
    mv /tmp/mihomo ${BIN_DIR}/uzumaki-core
    chmod +x ${BIN_DIR}/uzumaki-core
fi

# ==========================================
# ধাপ ৪: ডিরেক্টরি স্ট্রাকচার তৈরি
# ==========================================
mkdir -p ${INSTALL_DIR}/proxy_provider
mkdir -p ${INSTALL_DIR}/rule_provider
mkdir -p ${INSTALL_DIR}/dashboard
mkdir -p ${INSTALL_DIR}/logs
mkdir -p ${WWW_DIR}
mkdir -p ${LUCI_DIR}/controller

# ==========================================
# ধাপ ৫: GitHub থেকে ফাইলগুলো ডাউনলোড করা
# ==========================================
echo -e "${YELLOW}[→] Downloading UzumakiClash components from GitHub...${NC}"

curl -sL "${RAW_BASE}/config.default.yaml" -o "${INSTALL_DIR}/config.yaml"
curl -sL "${RAW_BASE}/main.htm"            -o "${WWW_DIR}/main.htm"
curl -sL "${RAW_BASE}/mihomo-api"          -o "${BIN_DIR}/uzumaki-api"
curl -sL "${RAW_BASE}/mihomo-cfg"          -o "${BIN_DIR}/uzumaki-cfg"
curl -sL "${RAW_BASE}/mihomo-sub"          -o "${BIN_DIR}/uzumaki-sub"
curl -sL "${RAW_BASE}/mihomo.init"         -o "/etc/init.d/uzumaki"
curl -sL "${RAW_BASE}/mihomo.lua"          -o "${LUCI_DIR}/controller/uzumaki.lua"
curl -sL "${RAW_BASE}/nft.conf"            -o "${INSTALL_DIR}/nft.conf"

chmod +x ${BIN_DIR}/uzumaki-* /etc/init.d/uzumaki

# ==========================================
# ধাপ ৬: ড্যাশবোর্ড (MetaCubeXD) ইনস্টল
# ==========================================
echo -e "${YELLOW}[→] Installing Dashboard UI...${NC}"
curl -sL "https://github.com/MetaCubeX/metacubexd/archive/gh-pages.tar.gz" | tar -xz -C /tmp/
cp -r /tmp/metacubexd-gh-pages/* ${INSTALL_DIR}/dashboard/ 2>/dev/null || true
rm -rf /tmp/metacubexd-gh-pages

# ==========================================
# ধাপ ৭: সার্ভিস এনাবল ও স্টার্ট
# ==========================================
echo -e "${YELLOW}[→] Starting service...${NC}"
/etc/init.d/uzumaki enable
/etc/init.d/uzumaki restart 2>/dev/null || true
rm -rf /tmp/luci-* 2>/dev/null

LAN_IP=$(uci get network.lan.ipaddr 2>/dev/null || echo "192.168.1.1")

echo -e "${GREEN}"
echo "========================================================"
echo "  ✓ UzumakiClash Installed Successfully!"
echo "========================================================"
echo -e "${NC}"
echo -e "  ${CYAN}LuCI Panel  :${NC} http://${LAN_IP}/cgi-bin/luci/admin/services/uzumaki"
echo -e "  ${CYAN}Dashboard   :${NC} http://${LAN_IP}:9090/ui"
echo -e "  ${CYAN}API Secret  :${NC} uzumaki-clash-secret"
echo -e "  ${CYAN}Config Path :${NC} ${INSTALL_DIR}/config.yaml"
echo ""
