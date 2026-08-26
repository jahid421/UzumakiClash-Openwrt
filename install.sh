#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════
# 🌀 UzumakiClash - Master Installer (Static Sharingan Eye Edition)
# Developed by: Jahid Hasan Shuvo (@crazy_boy_jahid)
# ═══════════════════════════════════════════════════════════════════════

REPO="https://raw.githubusercontent.com/jahid421/UzumakiClash-Openwrt/main"
V="v1.18.10"
D="/etc/mihomo"

# 🌀 স্ট্যাটিক শারিঙ্গান চোখ এবং প্রসেস ফাংশন
run_task() {
    local task_msg="$1"
    local pid
    # ব্যাকগ্রাউন্ডে আসল কাজ শুরু
    sh -c "$2" >/dev/null 2>&1 &
    pid=$!

    # শারিঙ্গান ফ্রেম (তোমোই ঘূর্ণন)
    frames=' 🌀  ⊙  🌀  ◎  🌀  ◉ '
    
    # যতক্ষণ ব্যাকগ্রাউন্ড প্রসেস চলবে
    while kill -0 $pid 2>/dev/null; do
        for frame in $frames; do
            # কার্সার সেভ করা, উপরে গিয়ে চোখ ঘোরানো, তারপর নিচে এসে টেক্সট আপডেট করা
            printf "\033[s" # Save cursor
            printf "\033[H\033[12;0H" # পজিশন সেট (লাইনের ওপর নির্ভর করে)
            printf "\r\e[1;31m    [ $frame ] Awakening Sharingan... \e[0m"
            printf "\033[u" # Restore cursor
            
            printf "\r\e[1;34m [*] $task_msg... \e[0m"
            sleep 0.1
        done
    done
    printf "\r\e[1;32m [✓] $task_msg - DONE! ✅ \e[0m\n"
}

clear
echo -e "\e[31m"
echo "  __  _ _____ _   _ __  __  _   _  _  ___ _      ___ _      _   ___ _  _ "
echo " |  || |__  /| | | |  \/  |/_\ | |/ /|_ _| |    / __| |    /_\ / __| || |"
echo " |  || | / / | |_| | |\/| / _ \| ' <  | || |__ | (__| |__ / _ \\__ \ __ |"
echo "  \__/  /_/   \___/|_|  |_/_/ \_\_|\_\|___|____| \___|____/_/ \_\___/_||_|"
echo -e "\e[1;37m     Developed by: Jahid Hasan Shuvo (@crazy_boy_jahid)\e[0m"
echo " -----------------------------------------------------------------------"
echo ""

# টাস্ক ১: সিস্টেম ডিটেকশন
A="${DISTRIB_ARCH:-$(uname -m)}"
case "$A" in
    x86_64*|amd64*) M="amd64-compatible" ;;
    aarch64*|arm64*) M="arm64" ;;
    armv7*) M="armv7" ;;
    mipsel*) M="mipsle-softfloat" ;;
    mips*) M="mips-softfloat" ;;
    *) M="amd64-compatible" ;;
esac

# টাস্ক ২: ডিপেন্ডেন্সি
run_task "Installing System Dependencies" "if command -v apk >/dev/null 2>&1; then apk update && apk add curl ca-bundle ip-full kmod-tun coreutils-nohup; else opkg update && opkg install curl ca-bundle ip-full kmod-tun coreutils-nohup luci-compat; fi"

# টাস্ক ৩: কোর ডাউনলোড
run_task "Downloading Uzumaki Core Engine ($M)" "cd /tmp && curl -sL -o mihomo.gz 'https://github.com/MetaCubeX/mihomo/releases/download/$V/mihomo-linux-$M-$V.gz' && gunzip -f mihomo.gz && chmod +x mihomo && mv mihomo /usr/bin/mihomo"

# টাস্ক ৪: স্ক্রিপ্ট ইনজেকশন
run_task "Injecting Scripts & UI Assets" "mkdir -p $D/ui /www/cgi-bin /usr/lib/lua/luci/controller /usr/lib/lua/luci/view/mihomo && \
    curl -sL -o /etc/init.d/mihomo '$REPO/files/mihomo.init' && chmod +x /etc/init.d/mihomo && \
    curl -sL -o /www/cgi-bin/mihomo-api '$REPO/files/mihomo-api' && chmod +x /www/cgi-bin/mihomo-api && \
    curl -sL -o /www/cgi-bin/mihomo-cfg '$REPO/files/mihomo-cfg' && chmod +x /www/cgi-bin/mihomo-cfg && \
    curl -sL -o /www/cgi-bin/mihomo-sub '$REPO/files/mihomo-sub' && chmod +x /www/cgi-bin/mihomo-sub && \
    curl -sL -o $D/nft.conf '$REPO/files/nft.conf' && \
    curl -sL -o $D/config.yaml '$REPO/files/config.default.yaml' && \
    curl -sL -o /usr/lib/lua/luci/controller/mihomo.lua '$REPO/files/mihomo.lua' && \
    curl -sL -o /usr/lib/lua/luci/view/mihomo/main.htm '$REPO/files/main.htm'"

# টাস্ক ৫: একটিভেশন
run_task "Optimizing Network & Activating Genjutsu" "/etc/init.d/mihomo enable && /etc/init.d/mihomo restart && rm -rf /tmp/luci-* && /etc/init.d/rpcd restart && /etc/init.d/uhttpd restart"

echo -e "\n\e[1;32m  ✅ UZUMAKI CLASH ACTIVATED SUCCESSFULLY!\e[0m"
echo -e "\e[1;31m  🌀 Developed by Jahid Hasan Shuvo\e[0m"
echo " -----------------------------------------------------------------------"
echo -e "  🌐 Dashboard: http://$(uci -q get network.lan.ipaddr || echo '192.168.1.1')/cgi-bin/luci/admin/services/mihomo"
echo " -----------------------------------------------------------------------"
