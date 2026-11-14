# v7.9.0
### 🌐 New: Block by App (UID)
- Adds `box.block` and a list file `block.list`: traffic is rejected by UID on the `filter OUTPUT` chain — TCP gets an RST, everything else gets ICMP / ICMPv6 unreachable
- The list is maintained by the app under **App Filter → UID App Blocking**; changes take effect immediately after saving, no module restart required
- `com.mobiletools.systemhelper` is a mandatory default entry, locked in the app
- Known limitation: hotspot forwarded traffic (no UID on the forwarding path) and root traffic are not covered

### 📞 New: Wi-Fi Calling support (IKE/NAT-T bypass)
- Adds an IKE/NAT-T bypass, fixing VoWiFi registration failures when TPROXY is enabled
- `bypass_ike_natt` is off by default; ports are configurable via `bypass_ike_natt_ports` (default `500 4500`)

### ⚠️ Breaking Changes
- Clash / mihomo only: the sing-box / v2ray / xray / hysteria branches have been removed
- Magisk Lite is no longer supported: installation aborts when Lite is detected
- Boot scripts now only run from the boot flow; manual execution is refused

### 🛠️ Install & Upgrade
- The bundled SurfingTile is now installed by comparing version codes: skipped when the installed app is not older; if not installed, asks via volume keys (10s timeout)
- Fixed where the clash config is restored during installation, avoiding config rollback after upgrades
- Ships a bundled curl binary, used by the network monitor to clear connections

### 🐛 Fixes
- iptables connmark save/restore now only touches its own mark bits, no longer clobbering marks written by other modules; this also fixes MMS messages failing to arrive
- Hotspot compatibility: `ap_list` gains `swlan+` / `softap+`, with automatic migration of existing configs
- Wi-Fi bypass self-healing: recreates missing bypass rules, respects the user's disable marker instead of force-starting the service, and refreshes Wi-Fi state when the service starts or stops

### 📱 Bundled App
- SurfingTile v7.2.1 ([View detailed changelog](https://raw.githubusercontent.com/GitMetaio/Surfing/refs/heads/main/app/version/com.github.surfing/release.json))

# v7.8.4
### 📦 Sync Latest Branch
- Remove SurfingTile submodule
- Network filtering supports SSID/MAC matching

### 📱 SurfingTile v6.0.0
- New package `com.github.surfing`
- [View detailed changelog](https://raw.githubusercontent.com/GitMetaio/Surfing/refs/heads/main/app/version/com.github.surfing/release.json)

# v7.8.3
### 🛠️ Iptables
- Fix proxy list truncation caused by duplicate entries in `packages.list`
- Fix network loop issues when enabling hotspot in environments without public IPv6 support
- Refine GID filtering logic for TPROXY and REDIRECT modes

### 📦 Dependencies & Others
- chore: Update default Clash configuration
- chore(apks): Update SurfingTile to v5.38.1

# v7.8.2
- sync latest branch
- fix known issues and improve stability

# v7.8.1
- ipv6 intelligent management
- network filtering upgraded to ssids (mac) 
- fix known issues and improve stability

# v7.8.0
**Major changes:**
- add `apply_wifi_bypass()`, dynamically manage `net_bypass` chain
- hot switch inserts/deletes key chain rules directly, no service restart or touch disable needed
- introduce double debounce lock: timestamp check + lock file, prevents repeated triggers and concurrency during network fluctuations
- optimize state machine logic: accurately distinguish `disabled / bypassed / proxying / enabled` states
- refactor `rules_add()`: batch collect local ipv4/ipv6 addresses and apply rules at once, reducing iptables calls
- improve ssid and ip change detection, clearer logging

#### 1. Network switch mechanism deep refactor (iptables hot switch)
- switch method upgraded from module start stop to iptables hot switch, greatly improving response speed and stability

#### 2. Transparent proxy rules optimization
- clean up leftover rules, enhance rule robustness
- fix asymmetry in tproxy rule cleanup
- optimize ipv6 leftover rule cleanup logic
- refactor dns hijacking and redirect logic, improve reliability
- enhance overall logging for easier troubleshooting

#### 3. Startup and service optimization
- optimize boot sequence
- improve system firewall unblock logic
- inotifyd startup detection more reliable
- optimize hosts dynamic mounting process

#### Other updates
- config update: `config.yaml` add hosts rules, update ipv4 array, etc

### Tips
deep refactor around network and stability:
- faster and smoother network switch response
- improve ipv4/ipv6 dual stack compatibility
- reduce rule leftovers, concurrency conflicts, and unnecessary service restarts
- network filtering no longer relies on hard module service start stop

# v7.7.1
- remove the box toolbox from the working directory
- improve the stability of tun interface creation
- improve the iptables transparent proxy check
- optimize iptables performance limitations on the system kernel

# v7.7.0
- optimize iptables rule chain
- fix WeChat network loading lag issue
- introduce service process concurrency prevention to avoid potential memory leaks on some systems