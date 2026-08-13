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