#!/bin/sh
# UzumakiClash - Universal Installer
# Supports: OpenWrt 21.02+ (opkg) & OpenWrt 24.10+ SNAPSHOT (apk)

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
REPO_URL="https://raw.githubusercontent.com/YourGitHub/UzumakiClash/main"

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
# ধাপ ১: সিস্টেম ডিটেক্ট করা (opkg নাকি apk)
# ==========================================
if command -v apk >/dev/null 2>&1; then
    PKG="apk"
    PKG_UPDATE="apk update"
    PKG_INSTALL="apk add"
    echo -e "${GREEN}[✓] Detected: APK Package Manager (OpenWrt SNAPSHOT)${NC}"
elif command -v opkg >/dev/null 2>&1; then
    PKG="opkg"
    PKG_UPDATE="opkg update"
    PKG_INSTALL="opkg install"
    echo -e "${GREEN}[✓] Detected: OPKG Package Manager (OpenWrt Stable)${NC}"
else
    echo -e "${RED}[✗] No supported package manager found!${NC}"
    exit 1
fi

# ==========================================
# ধাপ ২: CPU আর্কিটেকচার ডিটেক্ট
# ==========================================
ARCH=$(uname -m)
case "$ARCH" in
    aarch64)   MIHOMO_ARCH="linux-arm64" ;;
    armv7l)    MIHOMO_ARCH="linux-armv7" ;;
    mips)      MIHOMO_ARCH="linux-mips-softfloat" ;;
    mipsel)    MIHOMO_ARCH="linux-mipsle-softfloat" ;;
    x86_64)    MIHOMO_ARCH="linux-amd64-compatible" ;;
    i386|i686) MIHOMO_ARCH="linux-386" ;;
    *)         echo -e "${RED}[✗] Unsupported architecture: $ARCH${NC}"; exit 1 ;;
esac
echo -e "${GREEN}[✓] Architecture: $ARCH ($MIHOMO_ARCH)${NC}"

# ==========================================
# ধাপ ৩: ডিপেন্ডেন্সি ইনস্টল
# ==========================================
echo -e "${YELLOW}[→] Installing dependencies...${NC}"
$PKG_UPDATE >/dev/null 2>&1

DEPS="curl ca-certificates kmod-tun kmod-nft-tproxy ip-full coreutils-base64 jsonfilter"
for pkg in $DEPS; do
    $PKG_INSTALL $pkg >/dev/null 2>&1 || echo -e "${YELLOW}[!] Skipped: $pkg${NC}"
done

# ==========================================
# ধাপ ৪: Mihomo Core ডাউনলোড
# ==========================================
echo -e "${YELLOW}[→] Downloading Mihomo Core...${NC}"
MIHOMO_VER=$(curl -sL "https://api.github.com/repos/MetaCubeX/mihomo/releases/latest" | grep tag_name | cut -d'"' -f4)
MIHOMO_URL="https://github.com/MetaCubeX/mihomo/releases/download/${MIHOMO_VER}/mihomo-${MIHOMO_ARCH}-${MIHOMO_VER}.gz"

curl -L --progress-bar -o /tmp/mihomo.gz "$MIHOMO_URL"
gunzip -f /tmp/mihomo.gz
mv /tmp/mihomo ${BIN_DIR}/uzumaki-core
chmod +x ${BIN_DIR}/uzumaki-core
echo -e "${GREEN}[✓] Core installed: $(${BIN_DIR}/uzumaki-core -v | head -1)${NC}"

# ==========================================
# ধাপ ৫: ডিরেক্টরি স্ট্রাকচার তৈরি
# ==========================================
mkdir -p ${INSTALL_DIR}/{proxy_provider,rule_provider,dashboard,logs}
mkdir -p ${WWW_DIR}
mkdir -p ${LUCI_DIR}/controller ${LUCI_DIR}/model/cbi/uzumaki

# ==========================================
# ধাপ ৬: প্রজেক্ট ফাইল কপি
# ==========================================
echo -e "${YELLOW}[→] Installing UzumakiClash files...${NC}"
cp files/config.default.yaml ${INSTALL_DIR}/config.yaml
cp files/main.htm            ${WWW_DIR}/main.htm
cp files/mihomo-api          ${BIN_DIR}/uzumaki-api
cp files/mihomo-cfg          ${BIN_DIR}/uzumaki-cfg
cp files/mihomo-sub          ${BIN_DIR}/uzumaki-sub
cp files/mihomo.init         /etc/init.d/uzumaki
cp files/mihomo.lua          ${LUCI_DIR}/controller/uzumaki.lua
cp files/nft.conf            ${INSTALL_DIR}/nft.conf

chmod +x ${BIN_DIR}/uzumaki-* /etc/init.d/uzumaki

# ==========================================
# ধাপ ৭: ড্যাশবোর্ড (MetaCubeXD) ডাউনলোড
# ==========================================
echo -e "${YELLOW}[→] Installing Web Dashboard...${NC}"
curl -sL "https://github.com/MetaCubeX/metacubexd/archive/gh-pages.tar.gz" | \
    tar -xz -C /tmp/
mv /tmp/metacubexd-gh-pages/* ${INSTALL_DIR}/dashboard/ 2>/dev/null || true
rm -rf /tmp/metacubexd-gh-pages

# ==========================================
# ধাপ ৮: সার্ভিস চালু
# ==========================================
/etc/init.d/uzumaki enable
/etc/init.d/uzumaki start

# LuCI cache clean
rm -rf /tmp/luci-* 2>/dev/null

echo -e "${GREEN}"
echo "========================================================"
echo "  ✓ UzumakiClash Installed Successfully!"
echo "========================================================"
echo -e "${NC}"
echo -e "  ${CYAN}Web Panel   :${NC} http://$(uci get network.lan.ipaddr)/cgi-bin/luci/admin/services/uzumaki"
echo -e "  ${CYAN}Dashboard   :${NC} http://$(uci get network.lan.ipaddr):9090/ui"
echo -e "  ${CYAN}API Secret  :${NC} uzumaki-clash-secret"
echo -e "  ${CYAN}Config Path :${NC} ${INSTALL_DIR}/config.yaml"
echo ""
echo -e "  ${YELLOW}Start   :${NC} /etc/init.d/uzumaki start"
echo -e "  ${YELLOW}Stop    :${NC} /etc/init.d/uzumaki stop"
echo -e "  ${YELLOW}Restart :${NC} /etc/init.d/uzumaki restart"
echo ""
