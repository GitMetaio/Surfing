<h1 align="center">
  <img src="./folder/logo.svg" alt="logo" width="200">
  <br>Surfing<br>
</h1>

<h3 align="center">Magisk, Kernelsu, APatch</h3>

<div align="center">
    <a href="https://github.com/GitMetaio/Surfing/releases/tag/Prerelease-Alpha">
        <img alt="Android" src="https://img.shields.io/badge/Module Latestsnapshot-F05033.svg?logo=android&logoColor=white">
    </a>
    <a href="https://github.com/GitMetaio/Surfing/releases">
    <img alt="Downloads" src="https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/GitMetaio/Surfing/data/stats.json">
</a>
</div>
<br>
<div align="center">
    <strong>English</strong> | <a href="./README_CN.md">简体中文</a>
</div>

---

This project is a [Magisk](https://github.com/topjohnwu/Magisk), [Kernelsu](https://github.com/tiann/KernelSU), [APatch](https://github.com/bmax121/APatch) module for Clash/mihomo, sing-box, v2ray, xray, hysteria. It supports REDIRECT (TCP only), TPROXY (TCP + UDP) transparent proxy, TUN (TCP + UDP), and hybrid mode REDIRECT (TCP) + TUN (UDP) proxy.

Based on upstream integration for one-stop service, ready to use. Suitable for:
- Lazy people
- Beginners

The project's theme and configuration focus on [Clash/mihomo.Meta](https://github.com/MetaCubeX/Clash.Meta).

This module needs to be used in a Magisk/Kernelsu environment. If you don't know how to configure the required environment, you might need applications like ClashForAndroid, v2rayNG, surfboard, SagerNet, AnXray.

# Surfing User Declaration and Disclaimer

Welcome to use Surfing. Before using this project, please carefully read and understand the following statements and disclaimers. By using this project, you agree to accept the following terms and conditions. Hereinafter referred to as **Surfing**.

## Disclaimer

1. **This project is an open-source project for learning and research purposes only and does not provide any form of guarantee. Users must bear full responsibility for the risks and consequences of using this project.**

2. **This project is only for the convenience of simplifying the installation and configuration of Surfing for Clash services in the Android Magisk environment. It does not make any guarantees about the functionality and performance of Surfing. The developer of this project is not responsible for any problems or losses.**

3. **The use of this projects Surfing module may violate the laws and regulations of your region or the terms of service of service providers. You need to bear the risks of using this project on your own. The developer of this project is not responsible for your actions or the consequences of use.**

4. **The developer of this project is not responsible for any direct or indirect losses or damages resulting from the use of this project, including but not limited to data loss, device damage, service interruption, personal privacy leaks, etc.**

## Instructions for Use

1. **Before using the Surfing module, please make sure you have carefully read and understood the usage instructions and related documents of Clash and Magisk and comply with their rules and terms.**

2. **Before using this project, back up your device data and related settings to prevent unexpected situations. The developer of this project is not responsible for your data loss or damage.**

3. **Please comply with local laws and regulations and respect the legitimate rights and interests of other users when using this project. It is forbidden to use this project for illegal, abusive, or infringing activities.**

4. **If you encounter any problems or have any suggestions when using this project, you are welcome to provide feedback to the developer of this project, but the developer is not obligated to resolve issues or respond to feedback.**

Please decide whether to use the Surfing module only after clearly understanding and accepting the above statements and disclaimers. If you do not agree or cannot accept the above terms, please stop using this project immediately.

## Applicable Law

**During the use of this project, you must comply with the laws and regulations of your region. In case of any disputes, interpretation and resolution should be carried out in accordance with local laws and regulations.**

## Installation

- Download the module zip file from the [Release](https://github.com/GitMetaio/Surfing/releases) page and install it via Magisk Manager, KernelSU Manager, or APatch.
- Version changes: [📲log](changelog.md)

## Uninstall

- Uninstall this module directly from **Magisk Manager / KernelSU Manager / APatch**  
  [👉🏻 Force Remove Script](https://github.com/GitMetaio/Surfing/blob/main/uninstall.sh#L3-L4)

> Uninstalling this module via the manager will remove all related service data, including Web and SurfingTile tile app data.

## Group Telegram

<a href="https://t.me/Surfingbox">
  <img src="./folder/IMG_20260218_112257.jpg" alt="Group" width="100">
</a>

## Wiki

<details>
<summary>1. FirstTime Use</summary>

- After the module is installed for the first time, **please first** add your subscription URL in  
  `/data/adb/box_bll/clash/config.yaml`, or do it via the Web Desktop App  
  (**Note: SurfingTile must be invoked and Root permission is required**), then manually reboot your device once.
- After rebooting, toggle the module switch once, open the **Web App** on your desktop, and you can start using it.
- Due to network issues, not all **rules**/**subscriptions** may download automatically; please manually refresh them in the panel.
- If subscriptions fail to load, try switching the **Ua** in the configuration file.
- If the above fails, ensure your network environment is normal.

- Web App:
    - Can be used via Menu → Config Override → Fill in subscription
    - Used for portable browsing and managing backend routing data

<img src="./folder/app.png" alt="App UI" width="300">

> If the panel content is displayed abnormally or cannot be displayed,  
> please update the `com.google.android.webview` component via Google Play Store.

</details>

#

<details>
<summary>2. Controlling Operation</summary>

- You can control start/stop via **WiFi SSID**.
- You can control service using the module toggle switch  
  `Changes take effect in real time, no reboot required`
- You can add the module's control tile to the system status bar  
  `If SurfingTile is already installed`

</details>

#

<details>
<summary>3. Routing Rules</summary>

- GitHub Actions builds automatically  
  All routing rules use online subscriptions to ensure they are always up-to-date

> Automatically updates every 24 hours

</details>

#

<details>
<summary>4. Future Updates</summary>

- If you are using all default configurations, updates will be seamless.
- Supports online updates from the client; reboot is not required, but still recommended.
- During updates, configuration files will be backed up to:
   - `config.yaml.bak`
- User configuration files will be backed up to:
   - `box.config.bak`
- Subscription URLs will be automatically extracted and backed up to:
   - `proxies/subscribe_urls_backup.txt`
   - The backup will be automatically restored into the new configuration, suitable for default configuration usage.

> Ps: Mainly follows upstream updates and pushes some configuration adjustments.

</details>

#

<details>
<summary>5. Usage Issues</summary>

### Proxy Specific Apps (Blacklist / Whitelist)

- To proxy all apps except certain ones, open `/data/adb/box_bll/scripts/box.config`,  
  set `proxy_mode` to `blacklist` (default), and add elements to the `user_packages_list` array.  
  The element format is `id:package_name`, separated by spaces.  
  These apps will **not** be proxied.  
  Example: `user_packages_list=("id:package_name" "id:package_name")`

- To proxy only specific apps, open `/data/adb/box_bll/scripts/box.config`,  
  set `proxy_mode` to `whitelist`, and add elements to the `user_packages_list` array.  
  The element format is `id:package_name`, separated by spaces.  
  Only these apps will be proxied.  
  Example: `user_packages_list=("id:package_name" "id:package_name")`

Android user group IDs:

| User Type       | ID  |
| --------------- | --- |
| Owner           | 0   |
| Phone Clone     | 10  |
| Multiple Apps   | 999 |

> You can usually find all user group IDs and app package names under `/data/user/`.

### Tun Mode
- Disabled by default
- When using blacklist/whitelist, exclude the corresponding package names

> Can be enabled or disabled manually via configuration if needed.

### Routing Rules
- Optimized for Mainland China
- Meets most daily usage requirements

> With increasingly robust routing rules, blacklist/whitelist is becoming less necessary.

### Panel Management
- Magisk font modules

> May affect proper display of panel fonts.

### LAN Sharing
- Enable hotspot to allow other devices to connect
- Tun Gateway: `172.20.0.1`

> To access the backend console from other devices:  
> `http://<CurrentWiFi>/<TunGateway>:9090/ui`

### Host File
- No need to mount: just delete the file
- To remount: create a new one in the **etc folder**
- All changes take effect immediately
- During update/installation, you can use volume keys Up(**Mount**) / Down(**Unmount**) to choose

> Local IP redirection for domains, forced binding

</details>

#

<details>
<summary>6. SurfingTile</summary>

### APP Service
### 📱 Device Requirements
> Supports Android 10+

- Must run in **system space** and require **Root** permission
- For **KSU** users, you need to install the **"Meta Module"** to obtain mount permissions
- The tile works entirely based on the **Clash API**, please check if the API settings are correct
  - **Path:** → Home Settings → More Settings → Port Settings

### Hidden Easter Egg
> Long press the home icon to toggle **Gold Privilege**

- Preview
  ![App Interface](folder/IMG_20260813_032529.jpg)

</details>

---

<a href="./LICENSE">
    <img alt="License" src="https://img.shields.io/github/license/GitMetaio/Surfing.svg">
</a>

## Acknowledgements

<div align="center">
  <a href="https://github.com/CHIZI-0618">
    <img src="https://github.com/CHIZI-0618.png" width="100" height="100" alt="CHIZI-0618">
    <br>
    <strong>CHIZI-0618</strong>
  </a>
</div>

<div align="center">
  <p> > Thanks for providing valuable foundation for the implementation of this project. < </p>
</div>