# 🌀 UzumakiClash for OpenWrt

<p align="center">
  <img src="https://raw.githubusercontent.com/MetaCubeX/metacubexd/gh-pages/favicon.svg" width="100" height="100" alt="UzumakiClash"/>
</p>

<p align="center">
  <b>Ultra-Lightweight, Blazing Fast & Low-RAM Gateway Client for OpenWrt</b><br>
  <i>Powered by Mihomo Core • Optimized for Low-Resource Hardware</i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/OpenWrt-21.02%20%7C%2022.03%20%7C%2023.05%20%7C%20Snapshot-blue?style=flat-square&logo=openwrt" alt="OpenWrt">
  <img src="https://img.shields.io/badge/Architecture-x86__64%20%7C%20ARM64%20%7C%20ARMv7%20%7C%20MIPS-orange?style=flat-square" alt="Arch">
  <img src="https://img.shields.io/badge/RAM%20Usage-~20MB-brightgreen?style=flat-square" alt="RAM">
  <img src="https://img.shields.io/badge/Kernel%20Engine-Full%20TPROXY%20%2B%20Fake--IP-purple?style=flat-square" alt="Engine">
</p>

---

![Stars](https://img.shields.io/github/stars/jahid421/UzumakiClash?style=for-the-badge&logo=github&color=8b5cf6)
![Forks](https://img.shields.io/github/forks/jahid421/UzumakiClash?style=for-the-badge&logo=github&color=7c3aed)
![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)
![OpenWrt](https://img.shields.io/badge/OpenWrt-19.07--25.x%2B-blue?style=for-the-badge&logo=openwrt)
![RAM Footprint](https://img.shields.io/badge/RAM%20Usage-~20MB%20Locked-brightgreen?style=for-the-badge)
![Version](https://img.shields.io/badge/version-1.0%20Release-orange?style=for-the-badge)

# 🌀 UzumakiClash for OpenWrt

**Ultra-lightweight, lightning-fast, and universal gateway proxy panel for OpenWrt routers.**

A modern transparent gateway powered by Mihomo (Clash.Meta) Core. Engineered specifically for embedded routers with limited memory, **UzumakiClash** boots in **~1.2 seconds**, uses only **~20MB–30MB RAM**, and provides full **L4 TPROXY Gaming**, **Fake-IP DNS**, **Device-level ACL**, **Dark/Light theme**, **Auto Proxy Testing**, **Data Usage Tracking**, and **Browser Notifications** — with universal support across all CPU architectures and OpenWrt versions (v19 to v25+).

---

## ✨ Features

### 🚀 Core & Performance
* **Full L4 TPROXY (TCP + UDP)** — Zero-lag transparent proxying for gaming (PUBG, FreeFire, COD) and 4K streaming.
* **Fake-IP DNS Engine (`198.18.0.0/15`)** — Instant 0ms DNS responses, completely eliminating ISP DNS poisoning and leaks.
* **Ultra-Low RAM Guardian** — Locked at **~20MB–30MB RAM**; dynamic memory limits protect 128MB/256MB routers from OOM crashes.
* **Lightning Fast Boot** — Starts in **~1.2s** and stops in **~0.5s** with atomic `nftables` injection.
* **Universal Protocols** — Native support for VLESS (Reality/Vision), Hysteria 2, TUIC v5, VMess (AEAD), Trojan, Shadowsocks 2022, SSR, WireGuard, and SOCKS5.

### 🛡️ Client Access Control (ACL)
* **Device IP Whitelist Bypass** — Exclude specific devices (e.g., Smart TVs, Work Laptops, CCTV, Consoles) via LAN IP to bypass the proxy directly.
* **Router Self-Proxy Safety** — Automatic anti-loop mechanism prevents router DNS and routing lockups.

### 🎨 Modern Web UI
* **🌗 Dark & Light Theme** — 1-Click theme toggle with persistent state saved in browser cache.
* **📱 Fully Responsive** — Adaptive mobile, tablet, and desktop layout with touch-friendly controls.
* **📊 Live Traffic Canvas** — 60fps real-time visual traffic graph with automatic display DPI scaling.
* **⚡ Zero CDN Dependency** — 100% self-hosted assets for instant dashboard loading.

### ⚡ Smart Subscription & Routing
* **Universal Subconverter** — Converts raw V2Ray, VLESS-Reality, Trojan, Shadowsocks, and Base64 subscription URLs into clean runtime YAML configs.
* **Active Latency Sorting** — Nodes sorted by real-time ping (fastest first) with green/yellow/red color badges.
* **🇧🇩 Bangladesh Smart Routing** — Built-in direct bypass for bKash, Nagad, Rocket, Upay, Daraz, Chorki, and local banking portals.
* **🖥️ Remote Desktop Bypass** — Pre-configured direct bypass for UltraViewer, AnyDesk, TeamViewer, RustDesk, LogMeIn, and Parsec.

### 🔔 Automated Testing & Alerts
* **🔄 Auto Proxy Testing** — Autonomous latency testing at custom intervals (1/2/5/10/15/30 min).
* **🎯 Auto Select Fastest** — Automatically switches selector groups to the lowest-ping active proxy.
* **📊 Data Usage Tracker** — Tracks session, daily, and monthly bandwidth with granular reset controls.
* **🔔 Browser & Sound Alerts** — Real-time alerts for proxy failure, service stop, or high latency with customizable snooze timers.

---

## 📊 Why UzumakiClash?

UzumakiClash is designed specifically for routers with limited hardware resources, focusing on stability, low memory usage, and zero DNS issues.

| Feature / Metric | Specifications & Capabilities |
|---|---|
| **RAM Footprint** | `~20MB - 30MB` (Ultra-low memory guardian) |
| **Boot Startup Time** | `~1.2 Seconds` (Instant atomic injection) |
| **Stop Teardown Time** | `~0.5 Seconds` (Instant clean release) |
| **Firewall Engine** | Universal L4 TPROXY (TCP + UDP) with nftables & iptables fallback |
| **DNS Architecture** | Zero-Loop Fake-IP (`198.18.0.0/15`) + Encrypted DoH Fallback |
| **Access Control (ACL)**| 1-Click Device LAN IP Whitelist Bypass |
| **Next-Gen Protocols** | VLESS-Reality, Hysteria 2 (UDP Turbo), TUIC v5, Trojan, VMess |
| **OpenWrt Compatibility**| Universal support from v19.07 to v25+ (opkg and apk) |

---

## 📋 System Requirements

| Component | Minimum | Recommended |
|---|---|---|
| **RAM** | 128 MB (with ZRAM/Swap) | 256 MB or higher |
| **Storage (Flash)** | 32 MB free space | 64 MB+ free space |
| **CPU Architecture** | 500 MHz Single-Core MIPS | Dual/Quad-Core ARM or x86_64 |
| **Supported OS** | OpenWrt 19.07 | OpenWrt 21.02 / 22.03 / 23.05 / 24.x / 25+ |
| **Web Browser** | Chrome, Edge, Firefox, Safari | Latest Modern Browser |

---

## 🎯 Supported Hardware & Architectures

| Architecture | Chipsets & Devices |
|---|---|
| **x86_64 / amd64** | Intel / AMD Mini PCs, Soft Routers, VMware, Proxmox, VirtualBox |
| **ARM64 / aarch64** | Raspberry Pi 3/4/5, NanoPi R2S/R4S/R5S/R6S, GL.iNet MT3000, AX3000 |
| **ARMv7** | IPQ40xx, IPQ806x, MT7622, Linksys WRT series |
| **MIPSEL / mipsle** | MediaTek MT7621, MT7628, MT7620 (Xiaomi 4A Gigabit, MikroTik RB750Gr3) |
| **MIPS / mips** | Atheros AR7xxx, AR9xxx, QCA95xx (TP-Link Archer C7) |
| **RISC-V / LoongArch** | VisionFive, Milk-V, Loongson-based routers |

---

## 🚀 Installation

### 1. OpenWrt v19 - v24 (`opkg`):
```bash
opkg update && opkg install curl ca-bundle ca-certificates kmod-tun && sh -c "$(curl -fsSL https://raw.githubusercontent.com/jahid421/UzumakiClash-Openwrt/main/install.sh)"
```

### 2. OpenWrt v25+ / Snapshot (`apk`):
```bash
apk update && apk add curl ca-bundle ca-certificates kmod-tun && sh -c "$(curl -fsSL https://raw.githubusercontent.com/jahid421/UzumakiClash-Openwrt/main/install.sh)"
```

### 3. Universal Fallback (`wget` — Works on all versions):
```bash
sh -c "$(wget -qO- --no-check-certificate https://raw.githubusercontent.com/jahid421/UzumakiClash-Openwrt/main/install.sh)"
```

---

## 📱 Quick Start Guide

### Step 1: Open the Panel
Open your browser and navigate to your router's LuCI web interface:
```text
http://192.168.1.1 ➔ Services ➔ UzumakiClash 🌀
```

### Step 2: Import Configuration
* **Option A (Subscription Link):** Paste your VLESS / Trojan / Clash subscription URL in the **Config Manager** tab and click **Convert & Apply Sub**.
* **Option B (Upload YAML):** Click **Select YAML Config**, choose your file, and click **Apply YAML**.

### Step 3: Enable TPROXY
Go to the **Overview** tab and click the **TPROXY: DISABLED** button to switch it to **TPROXY: ACTIVE**.

### Step 4: Done!
All devices connected to your router via Wi-Fi or Ethernet will now route through proxy rules automatically without client-side setup!

---

## 🎨 Panel Overview & Navigation

```text
[ UzumakiClash Navigation Bar ]
 ├── 📊 Overview       ➔ Service status, TPROXY switch, Live traffic canvas, Mode toggle, Quick cache tools
 ├── 🌐 Proxy Nodes    ➔ Latency speed-test, Active node switcher, Search filter, Delay color codes
 ├── 🛡️ ACL / Devices  ➔ Device IP bypass manager (Direct whitelist routing for TVs/Consoles)
 ├── 📤 Config Manager ➔ Subscription converter, YAML file uploader, Live YAML syntax editor
 ├── 🔗 Connections    ➔ Real-time active socket inspector, Bandwidth per socket, 1-Click connection killer
 └── 📋 Live Logs      ➔ Real-time Mihomo kernel log stream with level filtering
```

---

## ⚡ Automated Features Deep Dive

### 1. Auto Proxy Testing & Latency Optimizer
* **Autonomous Probing:** Pings all active nodes at chosen intervals (1, 2, 5, 10, 15, or 30 minutes).
* **Smart Auto-Select:** Automatically binds the fastest responsive node to your selector group with zero manual interaction.
* **Dead Node Isolation:** Bypasses failing nodes to ensure uninterrupted connectivity.

### 2. Bandwidth & Data Usage Tracker
* **Real-time Stats:** Track upload and download bandwidth categorized by **Today**, **This Month**, and **Current Session**.
* **Midnight Reset:** Daily statistics reset automatically at 00:00.
* **Auto-Save:** Saves metrics to browser cache every 30 seconds and on window unload.

### 3. Browser & Audio Notifications
* **Alert Types:** Triggers alerts on service stoppage, complete proxy outage, sudden node failure drops, or slow latency (>500ms).
* **Smart Cooldown:** Anti-spam mechanism prevents duplicate notifications within 5 minutes.
* **Snooze Engine:** Temporarily silence alerts for 5m, 10m, 30m, or 1 hour.

---

## 🖥️ Remote Desktop Support (UltraViewer / AnyDesk)

Remote desktop tools often fail over proxies. **UzumakiClash includes pre-configured direct bypass rules:**
* UltraViewer (`ultraviewer.net`)
* AnyDesk (`anydesk.com`)
* TeamViewer (`teamviewer.com`)
* RustDesk (`rustdesk.com`)
* LogMeIn (`logmein.com`)
* Splashtop (`splashtop.com`)
* Parsec (`parsec.app`)

---

## 🔧 Useful Command-Line (CLI) Utilities

### Check Service Status
```bash
pgrep -f mihomo && echo "UzumakiClash: RUNNING" || echo "UzumakiClash: STOPPED"
```

### Restart Service & Re-apply Firewall
```bash
/etc/init.d/mihomo restart
```

### View Live Mihomo Kernel Logs
```bash
logread | grep mihomo | tail -25
```

### Enable / Disable TPROXY from CLI
```bash
# Enable
echo "1" > /etc/mihomo/transparent && /etc/init.d/mihomo restart

# Disable
echo "0" > /etc/mihomo/transparent && /etc/init.d/mihomo restart
```

### Validate Current YAML Syntax
```bash
/usr/bin/mihomo -d /etc/mihomo -f /etc/mihomo/config.yaml -t
```

### Inspect Active `nftables` Rules
```bash
nft list table inet uzumaki
```

### Manual Full Update (Pull Latest from GitHub)
```bash
curl -sL https://raw.githubusercontent.com/jahid421/UzumakiClash/main/install.sh | sh
```

---

## ⏰ Automated Cron Tasks (Optional)

To keep your GeoIP database and sub-rules updated automatically every night at 4:00 AM, go to **System ➔ Scheduled Tasks** in OpenWrt and add:

```cron
0 4 * * * /usr/bin/curl -s "http://127.0.0.1/cgi-bin/mihomo-api?action=update_geo" >/dev/null 2>&1
```

---

## 🗑️ Uninstallation

### 1. Universal Uninstall (`curl`):
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/jahid421/UzumakiClash-Openwrt/main/uninstall.sh)"
```

### 2. Universal Uninstall (`wget`):
```bash
sh -c "$(wget -qO- --no-check-certificate https://raw.githubusercontent.com/jahid421/UzumakiClash-Openwrt/main/uninstall.sh)"
```

---

## ⚠️ Important Notes

1. **Port Conflicts:** Do not run other proxy clients (like standard OpenClash or PassWall) at the same time on conflicting ports (`7890`, `7893`, `1053`, `9595`). Disable them before starting UzumakiClash:
   ```bash
   /etc/init.d/openclash stop && /etc/init.d/openclash disable
   ```
2. **Manual Device Proxies:** Once TPROXY is active, turn **OFF** all manual proxy/VPN settings on your individual phones and PCs.

---

## 🐛 Troubleshooting

<details>
<summary><b>1. LuCI menu entry is not visible after install?</b></summary>

Run the following commands to rebuild LuCI index cache:
```bash
rm -rf /tmp/luci-*
/etc/init.d/rpcd restart
/etc/init.d/uhttpd restart
```
</details>

<details>
<summary><b>2. Service fails to start?</b></summary>

Check the binary and validate your config:
```bash
/usr/bin/mihomo -v
/usr/bin/mihomo -d /etc/mihomo -f /etc/mihomo/config.yaml -t
```
</details>

<details>
<summary><b>3. Internet breaks after enabling TPROXY?</b></summary>

Disable TPROXY instantly to restore direct routing:
```bash
echo "0" > /etc/mihomo/transparent
/etc/init.d/mihomo restart
nft delete table inet uzumaki 2>/dev/null
```
Verify that your proxy nodes are active and reachable in the **Proxy Nodes** tab.
</details>

<details>
<summary><b>4. Need to bypass a specific Smart TV or console?</b></summary>

Go to **Services ➔ UzumakiClash ➔ ACL / Devices**, input the client's local IP (e.g., `192.168.1.50`), and click **Add Bypass**.
</details>

---

## 📁 Repository Structure

```text
UzumakiClash/
├── README.md                 # Project documentation & usage guide
├── install.sh                # 1-Click universal installer (opkg & apk)
├── uninstall.sh              # 1-Click safe system purger
└── files/
    ├── config.default.yaml   # Fallback default core configuration
    ├── main.htm              # Responsive LuCI UI template with Dark Mode
    ├── mihomo-api            # Gateway control API & ACL bypass controller
    ├── mihomo-cfg            # Smart YAML optimizer & validator
    ├── mihomo-sub            # Multi-protocol subscription converter
    ├── mihomo.init           # Procd init service with Low-RAM guardian
    ├── mihomo.lua            # LuCI menu controller bridge
    └── nft.conf              # L4 Gaming TPROXY & Fake-IP firewall engine
```

---

## 🙏 Credits & Acknowledgments

* **[MetaCubeX / Mihomo](https://github.com/MetaCubeX/mihomo)** — High-performance core proxy engine.
* **[MetaCubeX / MetaCubeXD](https://github.com/MetaCubeX/metacubexd)** — Web dashboard.
* **[OpenWrt Project](https://openwrt.org/)** — The extensible Linux distribution for embedded devices.

---

## 👨‍💻 Developer & Maintainer

**Jahid Hasan Shuvo**

[![Instagram](https://img.shields.io/badge/Instagram-@crazy__boy__jahid-E4405F?style=for-the-badge&logo=instagram&logoColor=white)](https://instagram.com/crazy_boy_jahid)
[![GitHub](https://img.shields.io/badge/GitHub-@jahid421-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/jahid421)

---

## ⭐ Support the Project

If **UzumakiClash** improved your OpenWrt networking experience, please consider giving this repository a **⭐ Star** on GitHub and sharing it with the community!

---

## 📄 License

This project is licensed under the **MIT License** — free to use, modify, and distribute for personal and educational purposes.

---

<p align="center">
  <b>Made with 🌀 for the global OpenWrt community</b><br>
  <i>Ultra Lightweight • Blazing Fast • Zero RAM Bloat</i>
</p>
