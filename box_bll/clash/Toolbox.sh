#!/system/bin/sh
trap cleanup INT TERM EXIT
cleanup() {
  echo -e "\n脚本已退出，正在清理..."
  trap - INT TERM EXIT
  pkill -P $$ 2>/dev/null
  kill $(jobs -p) 2>/dev/null
  exit 0
}
if [ "$(id -u)" -ne 0 ]; then
    echo "请设置以 Root 用户运行"
    exit 1
fi

if [ -f "config.env" ]; then
    source config.env
else
    echo "↴"
    echo "Warn：配置文件 config.env 已创建"
    echo 'GITHUB_TOKEN=你的个人令牌' > config.env
    echo "      请打开并配置你的个人令牌，以免受速率限制！"
    sleep 1
    source config.env
fi

SURFING_PATH="/data/adb/modules/Surfing"
MODULE_PROP="${SURFING_PATH}/module.prop"
GXSURFING_PATH="/data/adb/modules_update/Surfing"
NET_PATH="/data/misc/net"
CTR_PATH="/data/misc/net/rt_tables"
BOX_PATH="/data/adb/box_bll/scripts/box.config"
CONFIG_PATH="/data/adb/box_bll/clash/config.yaml"
CORE_PATH="/data/adb/box_bll/bin/clash"
VAR_PATH="/data/adb/box_bll/variab"
BASEE_URL="https://github.com/MetaCubeX/mihomo/releases/download/"
RELEASE_PATH="mihomo-android-arm64-v8"
BASE_URL="https://api.github.com/repos/MetaCubeX/mihomo/releases/latest"
PANEL_DIR="/data/adb/box_bll/clash/Web"
META_DIR="${PANEL_DIR}/Meta"
CHANGELOG_URL="https://raw.githubusercontent.com/GitMetaio/Surfing/main/changelog.md"
META_URL="https://github.com/metacubex/metacubexd/archive/gh-pages.zip"
METAA_URL="https://api.github.com/repos/metacubex/metacubexd/releases/latest"
YACD_DIR="${PANEL_DIR}/Yacd"
YACD_URL="https://github.com/MetaCubeX/yacd/archive/gh-pages.zip"
YACDD_URL="https://api.github.com/repos/MetaCubeX/Yacd-meta/releases/latest"
ZASH_DIR="${PANEL_DIR}/Zash"
ZASH_URL="https://github.com/Zephyruso/zashboard/releases/latest/download/dist.zip"
ZASHD_URL="https://api.github.com/repos/Zephyruso/zashboard/releases/latest"
BACKUP_FILE="/data/adb/box_bll/clash/proxies/subscribe_urls_backup.txt"
TEMP_FILE="/data/local/tmp/Surfing_update.zip"
TEMP_DIR="/data/local/tmp/Surfing_update"
DB_PATH="/data/adb/box_bll/clash/cache.db"
SERVICE_SCRIPT="/data/adb/box_bll/scripts/box.service"
CLASH_RELOAD_URL="http://127.0.0.1:9090/configs"
CLASH_RELOAD_PATH="/data/adb/box_bll/clash/config.yaml"
GEOIP_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
GEOSITE_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"
GEODATA_URL="https://api.github.com/repos/Loyalsoldier/v2ray-rules-dat/releases/latest"
GEOIP_PATH="/data/adb/box_bll/clash/GeoIP.dat"
GEOSITE_PATH="/data/adb/box_bll/clash/GeoSite.dat"
GIT_URL="https://api.github.com/repos/GitMetaio/Surfing/releases/latest"

SAVE_DIR="/data/adb/box_bll/clash/rules/规则审查"

rules=(
"广告拦截_Domain.yaml https://anti-ad.net/clash.yaml"
"WebRTC_Classical.yaml https://raw.githubusercontent.com/GitMetaio/Surfing/refs/heads/rm/Home/rules/WebRTC.list"
"CN_IPCIDR.yaml https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geoip/cn.yaml"
"CN_Domain.yaml https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/cn.yaml"
"XiaoHongShu_Domain.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/XiaoHongShu/XiaoHongShu_OCD_Domain.yaml"
"XiaoHongShu_IPCIDR.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/XiaoHongShu/XiaoHongShu_OCD_IP.yaml"
"DouYin_Domain.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/DouYin/DouYin_OCD_Domain.yaml"
"DouYin_IPCIDR.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/DouYin/DouYin_OCD_IP.yaml"
"BiliBili_Domain.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/BiliBili/BiliBili_OCD_Domain.yaml"
"BiliBili_IPCIDR.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/BiliBili/BiliBili_OCD_IP.yaml"
"Steam_Domain.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/Steam/Steam_OCD_Domain.yaml"
"Steam_IPCIDR.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/Steam/Steam_OCD_IP.yaml"
"TikTok_Domain.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/TikTok/TikTok_OCD_Domain.yaml"
"TikTok_IPCIDR.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/TikTok/TikTok_OCD_IP.yaml"
"Spotify_Domain.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/Spotify/Spotify_OCD_Domain.yaml"
"Spotify_IPCIDR.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/Spotify/Spotify_OCD_IP.yaml"
"Facebook_Domain.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/Facebook/Facebook_OCD_Domain.yaml"
"Facebook_IPCIDR.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/Facebook/Facebook_OCD_IP.yaml"
"Telegram_Domain.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/Telegram/Telegram_OCD_Domain.yaml"
"Telegram_IPCIDR.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/Telegram/Telegram_OCD_IP.yaml"
"YouTube_Domain.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/YouTube/YouTube_OCD_Domain.yaml"
"YouTube_IPCIDR.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/YouTube/YouTube_OCD_IP.yaml"
"Google_Domain.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/Google/Google_OCD_Domain.yaml"
"Google_IPCIDR.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/Google/Google_OCD_IP.yaml"
"GoogleFCM_Domain.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/GoogleFCM/GoogleFCM_OCD_Domain.yaml"
"GoogleFCM_IPCIDR.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/GoogleFCM/GoogleFCM_OCD_IP.yaml"
"Microsoft_Domain.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/Microsoft/Microsoft_OCD_Domain.yaml"
"Microsoft_IPCIDR.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/Microsoft/Microsoft_OCD_IP.yaml"
"Apple_Domain.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/Apple/Apple_OCD_Domain.yaml"
"Apple_IPCIDR.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/Apple/Apple_OCD_IP.yaml"
"OpenAI_Domain.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/OpenAI/OpenAI_OCD_Domain.yaml"
"OpenAI_IPCIDR.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/OpenAI/OpenAI_OCD_IP.yaml"
"Netflix_Domain.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/Netflix/Netflix_OCD_Domain.yaml"
"Netflix_IPCIDR.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/Netflix/Netflix_OCD_IP.yaml"
"Discord_Domain.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/Discord/Discord_OCD_Domain.yaml"
"Discord_IPCIDR.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/Discord/Discord_OCD_IP.yaml"
"GitHub_Domain.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/GitHub/GitHub_OCD_Domain.yaml"
"GitHub_IPCIDR.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/GitHub/GitHub_OCD_IP.yaml"
"Twitter_Domain.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/Twitter/Twitter_OCD_Domain.yaml"
"Twitter_IPCIDR.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/Twitter/Twitter_OCD_IP.yaml"
"LAN_Domain.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/Lan/Lan_OCD_Domain.yaml"
"LAN_IPCIDR.yaml https://raw.githubusercontent.com/GitMetaio/rule/refs/heads/master/rule/Clash/Lan/Lan_OCD_IP.yaml"
)

printc() {
  local newline=1
  if [ "$1" = "-n" ]; then
    newline=0
    shift
  fi
  local color="$1"
  shift
  local text="$*"
  local code
  case "$color" in
    red) code="\033[1;31m" ;;
    green) code="\033[1;32m" ;;
    yellow) code="\033[1;33m" ;;
    blue) code="\033[1;34m" ;;
    magenta) code="\033[1;35m" ;;
    cyan) code="\033[1;36m" ;;
    white) code="\033[1;37m" ;;
    *) code=""; text="$color $text" ;;
  esac
  if [ "$newline" -eq 1 ]; then
    echo -e "${code}${text}\033[0m"
  else
    echo -en "${code}${text}\033[0m"
  fi
}

download_rule() {
    local name="$1"
    local url="$2"
    local file_path="$SAVE_DIR/$name"

    mkdir -p "$SAVE_DIR"

    curl -s -o "$file_path" "$url" > /dev/null 2>&1

    if [ $? -ne 0 ]; then
        status_code=$?
        echo "下载失败: $name, 状态码: $status_code"
    fi
}

download_all_rules() {
    while true; do
        echo "↴" 
        echo "此为用于审查配置文件中引用的规则集 (y/n)"
        read confirm
        case "$confirm" in
            y|Y)
                echo "↴" 
                echo "正在下载规则文件..."
                echo "https://github.com/GitMetaio/rule"

                for rule in "${rules[@]}"; do
                    name=$(echo "$rule" | awk '{print $1}')
                    url=$(echo "$rule" | awk '{print $2}')
                    download_rule "$name" "$url"
                done

                echo "↴" 
                echo "所有规则下载完成"
                echo "↴" 
                echo "位于 /data/adb/box_bll/clash/rules/"
                break
                ;;
            n|N)
                echo "↴" 
                echo "操作已取消！"
                break
                ;;
            *)
                echo "↴" 
                echo "无效的输入！"
                ;;
        esac
    done
}

CURRENT_VERSION="v13.5.6"
UPDATE_LOG="更新日志: 
临时禁用核心更新..."

TOOLBOX_URL="https://raw.githubusercontent.com/GitMetaio/Surfing/main/box_bll/clash/Toolbox.sh"
TOOLBOX_FILE="/data/adb/box_bll/clash/Toolbox.sh"

get_remote_version() {
    remote_content=$(curl -s --connect-timeout 3 "$TOOLBOX_URL") || {
        echo "无法连接到 GitHub！"
        return 1
    }

    remote_version=$(echo "$remote_content" | grep -E -m1 '^CURRENT_VERSION="v[0-9]+(\.[0-9]+){1,2}"' | sed 's/^CURRENT_VERSION="//; s/"$//')

    [ -n "$remote_version" ] || {
        echo "无法获取远程版本信息！"
        return 1
    }
    
    echo "$remote_version"
}

check_version() {
    remote_version=$(get_remote_version) || return
    if [ "$remote_version" != "$CURRENT_VERSION" ]; then
        echo "↴" 
        printc green "GitHub Toolbox版本校验！"
        echo 
        echo -e "\033[1;33m当前版本: \033[1;32m$CURRENT_VERSION\033[0m"
        echo -e "\033[1;33m远程版本: \033[1;32m$remote_version\033[0m"
        echo 
        
        while true; do
            echo "是否同步更新脚本？(y/n)"
            read -r update_confirmation
            case "$update_confirmation" in
                [yY]) 
                    echo "↴" 
                    echo "正在从 GitHub 下载最新版本..."
                    if curl -sS -L -o "$TOOLBOX_FILE" "$TOOLBOX_URL"; then
                        chmod 0644 "$TOOLBOX_FILE"
                        echo "正在运行最新版本的脚本！"
                        trap - INT TERM EXIT
                        exec sh "$TOOLBOX_FILE"
                        exit 0
                    else
                        echo "下载失败，请检查网络连接是否能正常访问 GitHub！"
                        exit 1
                    fi
                    ;;
                [nN])
                    echo "↴" 
                    printc cyan "更新取消，继续使用当前脚本！"
                    break
                    ;;
                *) 
                    echo "↴"
                    echo "无效的输入！"
                    ;;
            esac
        done
    fi
}
check_version

extract_subscribe_urls() {
  if [ -f "$CONFIG_PATH" ]; then
    echo "- 正在提取订阅地址..."
    awk '/proxy-providers:/,/^profile:/' "$CONFIG_PATH" | \
    grep -Eo "url: \".*\"" | \
    sed -E 's/url: "(.*)"/\1/' | \
    sed 's/&/\\&/g' > "$BACKUP_FILE"
    
    if [ -s "$BACKUP_FILE" ]; then
      echo "- 提取订阅地址已备份到："
      echo "- proxies/subscribe_urls_backup.txt"
    else
      echo "- 未找到目标 URL，请检查配置文件格式"
    fi
  else
    echo "- 配置文件不存在，无法提取订阅地址"
  fi
}
restore_subscribe_urls() {
    if [ -f "$BACKUP_FILE" ] && [ -s "$BACKUP_FILE" ]; then
        echo "正在恢复订阅地址..."
        awk -v backup="$BACKUP_FILE" '
            BEGIN {
                while ((getline url < backup) > 0) {
                    urls[++n] = url
                }
                close(backup)
                i = 0
            }
            /proxy-providers:/ { in_provider = 1 }
            in_provider && /url:/ {
                if (++i <= n) {
                    sub(/url: ".*"/, "url: \"" urls[i] "\"")
                }
            }
            /profile:/ { in_provider = 0 }
            { print }
        ' "$CONFIG_PATH" > "$CONFIG_PATH.tmp" && \
        mv "$CONFIG_PATH.tmp" "$CONFIG_PATH"

        echo "订阅地址已恢复至新配置中！"
    else
        echo "配置文件不存在，无法提取订阅地址"
    fi
}
reload_configuration1() {
       if [ ! -f "$MODULE_PROP" ]; then
          echo "↴" 
          echo "当前未安装模块！"
          return
       fi
       if [ -f "/data/adb/modules/Surfing/disable" ]; then
          echo "↴" 
          echo "服务未运行，重载操作失败！"
          return
       fi
          echo "↴"
          echo "正在重载 clash 配置..."
          curl -X PUT "$CLASH_RELOAD_URL" -d "{\"path\":\"$CLASH_RELOAD_PATH\"}"
       if [ $? -eq 0 ]; then
          echo "ok"
       else
          echo "重载失败！"
       fi
    }
update_module() {
    echo "↴"
    if [ -f "$MODULE_PROP" ]; then
        current_version=$(grep '^version=' "$MODULE_PROP" | cut -d'=' -f2)
        echo "当前模块版本号: $current_version"
    else
        current_version=""
        echo "当前设备没有安装 Surfing 模块"
        echo "↴"
    fi

    echo "正在获取服务器中..."
    module_release=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$GIT_URL")
    module_version=$(echo "$module_release" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    if [ -z "$module_version" ]; then
        echo "获取服务器失败！"
        echo "错误：API 速率受限 / 网络请求异常！"
        return
    fi
    echo "获取成功！"
    echo "当前最新版本号: $module_version"

    if [ -n "$current_version" ] && [ "$current_version" = "$module_version" ]; then
        return
    fi

    echo "↴"
    echo "正在获取更新日志..."
    echo
    changelog=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$CHANGELOG_URL")
    escaped_version=$(echo "$module_version" | sed 's/\./[.]/g')
    latest_changelog=$(echo "$changelog" | awk -v ver="$escaped_version" '
        /^# / {
            if ($0 ~ ("^# " ver)) {
                p=1
                next
            } else if ($0 ~ "^# v") {
                p=0
            }
        }
        p { print }
    ')
    echo "$latest_changelog"
    echo

    if [ -n "$current_version" ]; then
        echo "发现新版本：$module_version（当前：$current_version）"
        echo " ↳ 请手动至客户端操作"
    else
        echo "检测到新版本：$module_version（当前未安装）"
        echo " ↳ 请手动至客户端操作"
    fi
}
update_module

#————————————————————
GITHUB_REPO="GitMetaio/Surfing"
GIT_SCRIPTS_PATH="box_bll/scripts"
GIT_clash_PATH="box_bll/clash"
LOCAL_SCRIPTS_DIR="/data/adb/box_bll/scripts"
LOCAL_clash_DIR="/data/adb/box_bll/clash"
CONFIG_PATH="$LOCAL_clash_DIR/config.yaml"
BACKUP_FILE="$LOCAL_clash_DIR/subscribe_urls_backup.txt"
LOCAL_SHA_DIR="/data/adb/box_bll/variab/sha_cache"
FILES=(
    "$GIT_clash_PATH/config.yaml|$LOCAL_clash_DIR/config.yaml|backup"
    "$GIT_SCRIPTS_PATH/box.config|$LOCAL_SCRIPTS_DIR/box.config|backup"
    "$GIT_SCRIPTS_PATH/box.inotify|$LOCAL_SCRIPTS_DIR/box.inotify"
    "$GIT_SCRIPTS_PATH/box.service|$LOCAL_SCRIPTS_DIR/box.service"
    "$GIT_SCRIPTS_PATH/box.tproxy|$LOCAL_SCRIPTS_DIR/box.tproxy"
    "$GIT_SCRIPTS_PATH/ctr.inotify|$LOCAL_SCRIPTS_DIR/ctr.inotify"
    "$GIT_SCRIPTS_PATH/ctr.utils|$LOCAL_SCRIPTS_DIR/ctr.utils"
    "$GIT_SCRIPTS_PATH/net.inotify|$LOCAL_SCRIPTS_DIR/net.inotify"
    "$GIT_SCRIPTS_PATH/start.sh|$LOCAL_SCRIPTS_DIR/start.sh"
)

check_github_token() {
    if [[ "$GITHUB_TOKEN" != ghp_* ]]; then
        echo "警告：当前 GitHub token 为非法值"
        echo "      请正确配置你的个人令牌以免受速率限制！"
        token_invalid=true
        return 1
    fi
    response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/user")
    if echo "$response" | grep -q "Bad credentials"; then
        echo "错误：GitHub 令牌无效或已过期！"
        token_invalid=true
        return 1
    elif echo "$response" | grep -q "rate limit exceeded"; then
        rate_limit_exceeded=true
        return 2
    elif echo "$response" | grep -q "Not Found"; then
        echo "错误：GitHub 用户不存在或令牌权限不足！"
        token_invalid=true
        return 3
    else
        username=$(echo "$response" | grep '"login":' | head -1 | cut -d '"' -f4)
        email=$(echo "$response" | grep '"email":' | head -1 | cut -d '"' -f4)
        if [ -z "$email" ] || [ "$email" = "null" ]; then
            email_info="未提供公开邮箱"
        else
            email_info="$email"
        fi       
        echo "hi GitHub $username | $email_info ✓"
        return 0
    fi
}

get_file_commit_info() {
    file_path="$1"
    commit_info=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$GITHUB_REPO/commits?path=$file_path&per_page=1" | grep -m1 -E '"message":' | cut -d '"' -f4)
    echo "$commit_info"
}

get_file_commit_sha() {
    file_path="$1"

    api_response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" -w "\n%{http_code}" "https://api.github.com/repos/$GITHUB_REPO/commits?path=$file_path&per_page=1")

    http_status=$(echo "$api_response" | tail -1)
    api_content=$(echo "$api_response" | sed '$d')

    if [ "$http_status" = "403" ]; then
        rate_limit_exceeded=true
        return 2
    elif [ "$http_status" != "200" ]; then
        return 1
    fi

    latest_sha=$(echo "$api_content" | grep -m1 '"sha"' | cut -d '"' -f4)
    echo "$latest_sha"
}

backup_file() {
    local_file="$1"
    if [ -f "$local_file" ]; then
        backup_file="${local_file}.bak"
        cp "$local_file" "$backup_file"
        echo "↴"
        echo "备份已创建："
        echo "$backup_file"
    fi
}

reload_configuration() {
    echo "↴"
    echo "正在重载clash配置..."
    pid=$(pidof clash)
    if [ -n "$pid" ]; then
        kill -USR1 "$pid"
        echo "配置重载成功 ✓"
    else
        echo "clash进程未运行，跳过重载"
    fi
}

check_and_update_files() {
    sha_count=0
    for file_entry in "${FILES[@]}"; do
        IFS='|' read -r _ local_path _ <<< "$file_entry"
        local_sha_file="$LOCAL_SHA_DIR/$(basename "$local_path")_sha"
        
        if [ -f "$local_sha_file" ]; then
            sha_count=$((sha_count + 1))
        fi
    done
    if [ "$sha_count" -lt 9 ]; then
        echo "↴"
        echo "警告：检测到你是第一次获取"
        echo "      需执行遍历所有文件的更新，获取文件的Sha值缓存！"
    fi
    
    echo
    echo "↴"
    echo "正在获取 GitMetaio/Surfing 仓库最新提交："
    for file_entry in "${FILES[@]}"; do
        IFS='|' read -r file_path local_path need_backup <<< "$file_entry"
        local_sha_file="$LOCAL_SHA_DIR/$(basename "$local_path")_sha"
        latest_sha=$(get_file_commit_sha "$file_path")
        case $? in
            2) 
                rate_limit_exceeded=true
                return
                ;;
            1) 
                continue
                ;;
        esac

        if [ -f "$local_sha_file" ]; then
            current_sha=$(cat "$local_sha_file")
            if [ "$latest_sha" = "$current_sha" ]; then
                continue
            fi
        fi

        all_up_to_date=false

        echo "↴"
        echo "发现更新：$(basename "$local_path")"
        commit_info=$(get_file_commit_info "$file_path")
        echo "提交信息: $commit_info"
        echo "---------------------"
        while true; do
            echo "是否同步更新？(y/n/x)"
            read -r user_response
            case "$user_response" in
                y|Y)
                    if [ "$need_backup" = "backup" ]; then
                        backup_file "$local_path"
                        if [ "$local_path" = "$CONFIG_PATH" ]; then
                            extract_subscribe_urls
                        fi
                    fi
                    echo "↴"
                    echo "下载中..."
                    if curl -sS -L -o "$local_path" "https://raw.githubusercontent.com/$GITHUB_REPO/main/$file_path"; then
                        echo "$latest_sha" > "$local_sha_file"
                        echo "更新成功 √"

                        if [ "$local_path" = "$CONFIG_PATH" ]; then
                            restore_subscribe_urls
                            reload_configuration1
                        fi
                    else
                        net_error=true
                        echo "下载失败！"
                    fi
                    break
                    ;;
                n|N)
                    echo "跳过此次更新"
                    break
                    ;;
                x|X)
                    echo "终止此次后续文件的检查"
                    return
                    ;;
                *)
                    echo "无效的输入！"
                    ;;
            esac
        done
    done
}

show_menu() {
  while true; do
    printc cyan "=========="
    echo -e "\033[1;33mVersion: \033[1;32m$CURRENT_VERSION\033[0m"
    printc yellow "$UPDATE_LOG"
    echo

    printc magenta "1. 重载配置"
    echo
    printc magenta "2. 清空数据库缓存"
    echo
    printc magenta "3. 更新控制台面板"
    echo
    printc magenta "4. 更新数据库"
    echo
    printc magenta "5. 更新核心"
    echo
    printc magenta "6. 少儿频道"
    echo
    printc magenta "7. 控制台面板入口"
    echo
    printc magenta "8. 整合客户端更新状态"
    echo
    printc magenta "9. 禁用/启用 更新模块"
    echo
    printc magenta "10. 检查仓库最新提交"
    echo
    printc magenta "11. 规则审查"
    echo
    printc magenta "12. 项目地址"
    echo
    printc magenta "13. 挂载 hosts"
    echo
    printc magenta "14. 一键卸载"
    echo
    printc magenta "15. Exit"
    echo
    printc -n blue "正在等待输出: "
    read -r choice
    case $choice in
      1) reload_configuration ;;
      2) clear_cache ;;
      3) update_web_panel ;;
      4) update_geo_database ;;
      5) update_core ;;
      6) open_telegram_group ;;
      7) show_web_panel_menu ;;
      8) integrate_magisk_update ;;
      9)
        if ! check_module_installed; then continue; fi
        check_update_status
        printc yellow "1. 禁用更新"
        printc yellow "2. 启用更新"
        printc yellow "3. 返回菜单"
        read -r update_choice
        case $update_choice in
          1) disable_updates ;;
          2) enable_updates ;;
          3) printc cyan "操作已取消！" ;;
          *) printc red "无效的输入！" ;;
        esac
        ;;
      10)
        echo "↴" 
        printc cyan "正在检查仓库更新..."
        all_up_to_date=true
        rate_limit_exceeded=false
        net_error=false
        token_invalid=false

        check_github_token || true
        [ ! -d "$LOCAL_SHA_DIR" ] && mkdir -p "$LOCAL_SHA_DIR"
        check_and_update_files

        echo
        if $net_error; then
          printc red "✗ 网络连接异常\n  请检查网络连接后重试！"
        elif $rate_limit_exceeded; then
          printc red "✗ GitHub API限制\n  当前IP请求次数过多，请更换IP或等待1小时后重试！"
        elif $token_invalid; then
          printc red "✗ 令牌验证失败\n  请检查GITHUB_TOKEN是否为有效值！"
        elif $all_up_to_date; then
          printc green "√ 所有文件均为最新版本"
        else
          printc green "√ 检测更新流程完成"
        fi
        echo
        printc cyan "检测已完毕..."
        ;;
      11) download_all_rules ;;
      12) open_project_page ;;
      13) mount_hosts ;;
      14) delete_files_and_dirs ;;
      15) exit 0 ;;
      *) printc red "无效的输入！" ;;
    esac
  done
}
mount_hosts() {
    local target_dir="/data/adb/box_bll/clash/etc"
    local hosts_path="$target_dir/hosts"
    local hosts_url="https://raw.githubusercontent.com/GitMetaio/Surfing/main/box_bll/clash/etc/hosts"
    echo "↴"
    echo "此操作将挂载远程 GitHub/Surfing/clash/etc/hosts 文件到本地，是否继续？(y/n)"
    read -r confirmation
    if [ "$confirmation" != "y" ] && [ "$confirmation" != "n" ]; then
        echo "↴"
        printc red "无效的输入！"
        return
    fi

    if [ "$confirmation" = "n" ]; then
        echo "↴"
        printc cyan "操作取消！"
        return
    fi

    if [ -f "$hosts_path" ]; then
        echo "↴"
        printc green "文件已存在，无需重复挂载"
    else
        echo "↴"
        printc cyan "文件不存在，正在从远程下载..."
        mkdir -p "$target_dir"
        if curl -fsSL "$hosts_url" -o "$hosts_path"; then
            echo "↴"
            printc green "文件已成功挂载到 $hosts_path"
        else
            echo "↴"
            printc red "下载失败，请检查网络连接或 URL 是否正确"
        fi
    fi
}
NO_UPDATE_ENABLED=true
ensure_var_path() {
    if [ ! -d "$VAR_PATH" ]; then
        mkdir -p "$VAR_PATH"
        if [ $? -ne 0 ]; then
            echo "操作失败，请检查权限！"
            exit 1
        fi
    fi
}
check_module_installed() {
    if [ ! -f "$MODULE_PROP" ]; then
        echo "↴" 
        echo "当前未安装模块！"
        return 1 
    fi
    return 0
}
check_update_status() {
    ensure_var_path
    UPDATE_STATUS_FILE="${VAR_PATH}/update_status"
    if [ -f "$UPDATE_STATUS_FILE" ]; then
        echo "↴" 
        echo "当前客户端状态：更新已禁用"
    else
        echo "↴" 
        echo "当前客户端状态：更新已启用"
    fi
}
disable_updates() {
    ensure_var_path
    UPDATE_STATUS_FILE="${VAR_PATH}/update_status"
    MODULE_PROP="${MODULE_PROP}"
    if grep -q "^updateJson=" "$MODULE_PROP"; then
        echo "↴" 
        echo "此操作会对该模块在客户端禁止检测更新，是否继续？(y/n)"
        read -r confirmation
        if [ "$confirmation" != "y" ]; then
            echo "↴"
            printc cyan "操作取消！"
            return
        fi
        updateJson_value=$(grep "^updateJson=" "$MODULE_PROP" | cut -d '=' -f 2-)
        echo "$updateJson_value" > "$UPDATE_STATUS_FILE"
        sed -i '/^updateJson=/d' "$MODULE_PROP"
        echo "↴"
        echo "更新检测已禁止✓"
    else
        echo "↴" 
        echo "当前已是禁用状态，无需操作。"
    fi
}
enable_updates() {
    ensure_var_path
    UPDATE_STATUS_FILE="${VAR_PATH}/update_status"
    MODULE_PROP="${MODULE_PROP}"
    if [ -f "$UPDATE_STATUS_FILE" ]; then
        echo "↴" 
        echo "此操作会恢复模块在客户端的检测更新，是否继续？(y/n)"
        read -r confirmation
        if [ "$confirmation" != "y" ];then
            echo "↴"
            printc cyan "操作取消！"
            return
        fi
        updateJson_value=$(cat "$UPDATE_STATUS_FILE")
        echo "updateJson=$updateJson_value" >> "$MODULE_PROP"
        rm -f "$UPDATE_STATUS_FILE"
        echo "↴"
        echo "更新检测已恢复✓"
    else
        echo "↴" 
        echo "当前已是启用状态，无需操作。"
    fi
}
integrate_magisk_update() {
    if [ "$NO_UPDATE_ENABLED" = "true" ]; then
        echo "↴"
        echo "当前选项是禁用状态，不允许执行该操作！"
        return
    fi
    
    if [ ! -f "$MODULE_PROP" ]; then
        echo "↴"
        echo "当前未安装模块！"
        return
    fi
    echo "↴"
    echo "如果你在客户端 安装/更新 模块，可进行整合刷新并更新状态 无需重启设备，是否整合？(y/n)"
    read -r confirmation
    if [ "$confirmation" != "y" ]; then
        echo "↴"
        printc cyan "操作取消！"
        return
    fi
    echo "↴"
    echo "正在检测当前状态..."
    for i in 1
    do
        sleep 1
    done

    if [ -d "$GXSURFING_PATH" ]; then
        echo "检测到 安装/更新 Surfing 模块，进行整合..."
        cp -rf "$GXSURFING_PATH"/* "$SURFING_PATH/"
        
        if [ -f "$SURFING_PATH/update" ]; then
            rm -f "$SURFING_PATH/update"
        fi

        rm -rf "$GXSURFING_PATH"
        echo "整合成功✓"
    else
        echo "没有检测到 安装/更新 Surfing 模块。"
    fi
}
clear_cache() {
    if [ ! -f "$MODULE_PROP" ]; then
        echo "↴" 
        echo "当前未安装模块！"
        return
    fi
    echo "↴"
    ensure_var_path
    CACHE_CLEAR_TIMESTAMP="${VAR_PATH}/last_cache_update" 
    if [ -f "$CACHE_CLEAR_TIMESTAMP" ]; then
        last_clear=$(date -d "@$(cat $CACHE_CLEAR_TIMESTAMP)" +"%Y-%m-%d %H:%M:%S")
        echo "距离上次清空缓存是: $last_clear" 
    fi
    echo "此操作会清空fake-ip映射及节点连接记忆，是否清除？(y/n)"
    read -r confirmation
    if [ "$confirmation" != "y" ]; then
        echo "↴"
        printc cyan "操作取消！"
        return
    fi
    echo "↴"
    if [ -f "$DB_PATH" ]; then
        rm "$DB_PATH"
        echo "已清空数据库缓存✓"
        touch "$DB_PATH"
    else
        echo "数据库文件不存在..."
        touch "$DB_PATH"
        echo "已创建新的空数据库文件"
    fi
    echo "重启模块服务中..."
    touch "$SURFING_PATH/disable"
    sleep 1.5
    rm -f "$SURFING_PATH/disable"
    sleep 1.5
    echo "ok"
    date +%s > "$CACHE_CLEAR_TIMESTAMP"
}
update_geo_database() {
    if [ "$NO_UPDATE_ENABLED" = "true" ]; then
        echo "↴"
        echo "当前选项是禁用状态，不允许执行该操作！"
        return
    fi
    
    if [ ! -f "$MODULE_PROP" ]; then
        echo "↴" 
        echo "当前未安装模块！"
        return
    fi
    echo "↴"  
    ensure_var_path
    GEO_DATABASE_VERSION_FILE="${VAR_PATH}/geo_database_update"
    if [ -f "$GEO_DATABASE_VERSION_FILE" ]; then
        last_version=$(cat "$GEO_DATABASE_VERSION_FILE")
        echo "距离上次更新的版本号是: $last_version"
    fi
    echo "正在获取服务器中..."
    geo_release=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$GEODATA_URL")
    geo_version=$(echo "$geo_release" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    if [ -z "$geo_version" ]; then
        echo "获取服务器失败！"
        echo "错误：API 速率受限 / 网络请求异常 ！"
        return
    fi       
    echo "获取成功！"
    echo "当前最新版本号: $geo_version"
    
    if [ "$last_version" = "$geo_version" ]; then
        echo "当前已是最新版本！"
        return
    fi
    echo "是否更新？(y/n)"
    read -r confirmation
    if [ "$confirmation" != "y" ]; then
        echo "↴"
        printc cyan "操作取消！"
        return
    fi
    echo "↴"
    if [ -f "/data/adb/box_bll/clash/geosite.dat" ]; then
        rm "/data/adb/box_bll/clash/geosite.dat"
    fi
    if [ -f "/data/adb/box_bll/clash/geoip.dat" ]; then
        rm "/data/adb/box_bll/clash/geoip.dat"
    fi
    echo "正在下载文件中..."
    curl -sS -o "$GEOIP_PATH" -L "$GEOIP_URL"
    if [ $? -ne 0 ]; then
        echo "下载 GeoIP.dat 失败！"
        return
    fi
    curl -sS -o "$GEOSITE_PATH" -L "$GEOSITE_URL"
    if [ $? -ne 0 ]; then
        echo "下载 GeoSite.dat 失败！"
        return
    fi
    echo "更新成功✓"
    chown root:net_admin "$GEOIP_PATH" "$GEOSITE_PATH"
    if [ $? -ne 0 ]; then
        echo "设置文件权限失败！"
        return
    fi
    echo "$geo_version" > "$GEO_DATABASE_VERSION_FILE"
}
show_web_panel_menu() {
    while true; do
        echo "↴"
        echo "选择图形面板："
        echo "1. HTTPS Gui Meta"
        echo "2. HTTPS Gui Yacd"
        echo "3. HTTPS Gui Zash"
        echo "4. 本地端口 >>> 127.0.0.1:9090/ui"
        printc green "5. 返回上一级菜单"
        read -r web_choice
        case $web_choice in
            1)
                echo "↴"
                echo "正在跳转到 Gui Meta..."
                am start -a android.intent.action.VIEW -d "https://metacubex.github.io/metacubexd"
                echo "ok"
                echo
                ;;
            2)
                echo "↴"
                echo "正在跳转到 Gui Yacd..."
                am start -a android.intent.action.VIEW -d "https://yacd.mereith.com/"
                echo "ok"
                echo
                ;;
            3)
                echo "↴"
                echo "正在跳转到 Gui Zash..."
                am start -a android.intent.action.VIEW -d "https://board.zash.run.place/"
                echo "ok"
                echo
                ;;
            4)
                echo "↴"
                echo "正在跳转到本地端口..."
                am start -a android.intent.action.VIEW -d "http://127.0.0.1:9090/ui/#/"
                echo "ok"
                echo
                ;;
            5)
                echo "↴"
                return
                ;;
            *)
                echo "↴"
                echo "无效的输入！"
               ;;
        esac
    done
}
open_telegram_group() {
    echo "↴"
    echo "正在跳转到 Surfing..."
    am start -a android.intent.action.VIEW -d "https://t.me/+vvlXyWYl6HowMTBl"
    echo "ok"
}
update_web_panel() {
    if [ ! -f "$MODULE_PROP" ]; then
        echo "↴" 
        echo "当前未安装模块！"
        return
    fi
    echo "↴"
    ensure_var_path
    WEB_PANEL_TIMESTAMP="${VAR_PATH}/last_web_panel_update"
    last_meta_version=""
    last_yacd_version=""
    last_zash_version=""
    if [ -f "$WEB_PANEL_TIMESTAMP" ]; then
        last_update=$(cat "$WEB_PANEL_TIMESTAMP")
        last_meta_version=$(echo $last_update | cut -d ' ' -f 1)
        last_yacd_version=$(echo $last_update | cut -d ' ' -f 2)
        last_zash_version=$(echo $last_update | cut -d ' ' -f 3)
        echo "距离上次更新的 Meta 版本号是: $last_meta_version"
        echo "距离上次更新的 Yacd 版本号是: $last_yacd_version"
        echo "距离上次更新的 Zash 版本号是: $last_zash_version"
    fi
    echo "正在获取服务器中..."
    meta_release=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$METAA_URL")
    meta_version=$(echo "$meta_release" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    yacd_release=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$YACDD_URL")
    yacd_version=$(echo "$yacd_release" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    zash_release=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$ZASHD_URL")
    zash_version=$(echo "$zash_release" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

    if [ -z "$meta_version" ] || [ -z "$yacd_version" ] || [ -z "$zash_version" ]; then
        echo "获取服务器失败！"
        echo "错误：API 速率受限 / 网络请求异常 ！"
        return
    fi  
    echo "获取成功！"   
    echo "Meta 当前最新版本号: $meta_version"
    echo "Yacd 当前最新版本号: $yacd_version"
    echo "Zash 当前最新版本号: $zash_version"

    meta_update_needed=false
    yacd_update_needed=false
    zash_update_needed=false

    if [ "$last_meta_version" != "$meta_version" ]; then
        meta_update_needed=true
    fi

    if [ "$last_yacd_version" != "$yacd_version" ]; then
        yacd_update_needed=true
    fi

    if [ "$last_zash_version" != "$zash_version" ]; then
        zash_update_needed=true
    fi

    if [ "$meta_update_needed" = false ] && [ "$yacd_update_needed" = false ] && [ "$zash_update_needed" = false ]; then
        echo "当前已是最新版本！"
        return
    fi

    echo "是否更新？(y/n)"
    read -r confirmation
    if [ "$confirmation" != "y" ]; then
        echo "↴"
        printc cyan "操作取消！"
        return
    fi    
    
    if [ "$meta_update_needed" = true ]; then
        echo "↴"
        echo "正在更新：Meta"
        new_install=false
        if [ ! -d "$META_DIR" ]; then
            echo "面板不存在，正在自动安装..."
            mkdir -p "$META_DIR"
            if [ $? -ne 0 ]; then
                echo "创建失败，请检查权限！"
                return
            fi
            new_install=true
        fi
        echo "正在拉取最新的代码..."
        curl -sS -L -o "$TEMP_FILE" "$META_URL"
        if [ $? -eq 0 ]; then
            echo "下载成功，正在效验文件..."
            if [ -s "$TEMP_FILE" ]; then
                echo "文件有效，开始进行$([ "$new_install" = true ] && echo "安装" || echo "更新")..."
                unzip -qo "$TEMP_FILE" -d "$TEMP_DIR"
                if [ $? -eq 0 ]; then
                    rm -rf "${META_DIR:?}"/*
                    if [ $? -ne 0 ]; then
                        echo "操作失败，请检查权限！"
                        return
                    fi
                    mv "$TEMP_DIR/metacubexd-gh-pages/"* "$META_DIR"
                    rm -rf "$TEMP_FILE" "$TEMP_DIR"
                    echo "$([ "$new_install" = true ] && echo "安装成功✓" || echo "更新成功✓")"
                    echo
                else
                    echo "解压失败，文件异常！"
                fi
            else
                echo "下载的文件为空或无效！"
            fi
        else
            echo "拉取下载失败！"
        fi   
    fi
    
    if [ "$yacd_update_needed" = true ]; then
        echo "↴"
        echo "正在更新：Yacd"
        new_install=false
        if [ ! -d "$YACD_DIR" ]; then
            echo "面板不存在，正在自动安装..."
            mkdir -p "$YACD_DIR"
            if [ $? -ne 0 ]; then
                echo "创建失败，请检查权限！"
                return
            fi
            new_install=true
        fi
        echo "正在拉取最新的面板代码..."
        curl -sS -L -o "$TEMP_FILE" "$YACD_URL"
        if [ $? -eq 0 ]; then
            echo "下载成功，正在效验文件..."
            if [ -s "$TEMP_FILE" ]; then
                echo "文件有效，开始进行$([ "$new_install" = true ] && echo "安装" || echo "更新")..."
                unzip -qo "$TEMP_FILE" -d "$TEMP_DIR"
                if [ $? -eq 0 ]; then
                    rm -rf "${YACD_DIR:?}"/*
                    if [ $? -ne 0 ]; then
                        echo "操作失败，请检查权限！"
                        return
                    fi
                    mv "$TEMP_DIR/Yacd-meta-gh-pages/"* "$YACD_DIR"
                    rm -rf "$TEMP_FILE" "$TEMP_DIR"
                    echo "$([ "$new_install" = true ] && echo "安装成功✓" || echo "更新成功✓")"
                    echo
                else
                    echo "解压失败，文件异常！"
                fi
            else
                echo "下载的文件为空或无效！"
            fi
        else
            echo "拉取下载失败！"
        fi 
    fi 
    
    if [ "$zash_update_needed" = true ]; then
        echo "↴"
        echo "正在更新：Zash"
        new_install=false
        if [ ! -d "$ZASH_DIR" ]; then
            echo "面板不存在，正在自动安装..."
            mkdir -p "$ZASH_DIR"
            if [ $? -ne 0 ]; then
                echo "创建失败，请检查权限！"
                return
            fi
            new_install=true
        fi
        echo "正在拉取最新的代码..."
        curl -sS -L -o "$TEMP_FILE" "$ZASH_URL"
        if [ $? -eq 0 ]; then
            echo "下载成功，正在效验文件..."
            if [ -s "$TEMP_FILE" ]; then
                echo "文件有效，开始进行$([ "$new_install" = true ] && echo "安装" || echo "更新")..."
                unzip -qo "$TEMP_FILE" -d "$TEMP_DIR"
                if [ $? -eq 0 ]; then
                    rm -rf "${ZASH_DIR:?}"/*
                    if [ $? -ne 0 ]; then
                        echo "操作失败，请检查权限！"
                        return
                    fi
                    mv "$TEMP_DIR/dist/"* "$ZASH_DIR"
                    rm -rf "$TEMP_FILE" "$TEMP_DIR"
                    echo "$([ "$new_install" = true ] && echo "安装成功✓" || echo "更新成功✓")"
                else
                    echo "解压失败，文件异常！"
                fi
            else
                echo "下载的文件为空或无效！"
            fi
        else
            echo "拉取下载失败！"
        fi 
    fi
    
    chown -R root:net_admin "$PANEL_DIR"
    find "$PANEL_DIR" -type d -exec chmod 0755 {} \;
    find "$PANEL_DIR" -type f -exec chmod 0666 {} \;
    if [ $? -ne 0 ]; then
        echo "设置文件权限失败！"
        return
    fi
    echo "$meta_version $yacd_version $zash_version" > "$WEB_PANEL_TIMESTAMP"
}
reload_configuration() {
    if [ ! -f "$MODULE_PROP" ]; then
        echo "↴" 
        echo "当前未安装模块！"
        return
    fi
    if [ -f "/data/adb/modules/Surfing/disable" ]; then
        echo "↴" 
        echo "服务未运行，重载操作失败！"
        return
    fi
    echo "↴"
    echo "正在重载 clash 配置..."
    curl -X PUT "$CLASH_RELOAD_URL" -d "{\"path\":\"$CLASH_RELOAD_PATH\"}"
    if [ $? -eq 0 ]; then
        echo "ok"
    else
        echo "重载失败！"
    fi
}
update_core() {
    if [ "$NO_UPDATE_ENABLED" = "true" ]; then
        echo "↴"
        echo "当前选项是禁用状态，不允许执行该操作！"
        return
    fi
    if [ ! -f "$MODULE_PROP" ]; then
        echo "↴" 
        echo "当前未安装模块！"
        return
    fi
    echo "↴"
    ensure_var_path
    CORE_TIMESTAMP="${VAR_PATH}/last_core_update"
    if [ -f "$CORE_TIMESTAMP" ]; then
        last_update=$(cat "$CORE_TIMESTAMP")
        echo "距离上次更新的版本号是: $last_update"
    else
        last_update=""
    fi
    echo "正在获取服务器中..."
    latest_release=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$BASE_URL")
    latest_version=$(echo "$latest_release" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    if [ -z "$latest_version" ]; then
        echo "获取服务器失败！"
        echo "错误：API 速率受限 / 网络请求异常 ！"
        return
    fi
    download_url="${BASEE_URL}${latest_version}/${RELEASE_PATH}-${latest_version}.gz"
    echo "获取成功！"
    echo "当前最新版本号: $latest_version"
    
    if [ "$last_update" = "$latest_version" ]; then
        echo "当前已是最新版本！"
        return
    fi
    echo "是否更新？(y/n)"
    read -r confirmation
    if [ "$confirmation" != "y" ]; then
        echo "↴"
        printc cyan "操作取消！"
        return
    fi
    echo "↴"
    echo "正在下载文件中..."
    curl -sS -L -o "$TEMP_FILE" "$download_url"
    if [ $? -ne 0 ]; then
        echo "下载失败，请检查网络连接是否能正常访问 GitHub！"
        exit 1
    fi
    file_size=$(stat -c%s "$TEMP_FILE")
    if [ "$file_size" -le 100 ]; then
        echo "下载的文件大小异常，停止更新！"
        exit 1
    fi
    echo "文件效验通过，开始进行更新..."
    mkdir -p "$TEMP_DIR"
    gunzip -c "$TEMP_FILE" > "$TEMP_DIR/clash"
    if [ $? -ne 0 ]; then
        echo "解压失败，文件异常！"
        exit 1
    fi
    chown root:net_admin "$TEMP_DIR/clash"
    chmod 0700 "$TEMP_DIR/clash"
    if [ -f "$CORE_PATH" ]; then
        mv "$CORE_PATH" "${CORE_PATH}.bak"
    fi
    mv "$TEMP_DIR/clash" "$CORE_PATH"
    rm -rf "$TEMP_FILE" "$TEMP_DIR"
    echo "更新成功✓"
    echo
    echo "重启模块服务中..."
    touch "${SURFING_PATH}disable"
    sleep 1.5
    rm -f "${SURFING_PATH}disable"
    sleep 1.5
    echo "ok"
    echo "$latest_version" > "$CORE_TIMESTAMP"
}
open_project_page() {
    echo "↴" 
    echo "正在打开项目地址..."
    if command -v xdg-open > /dev/null; then
        xdg-open "https://github.com/GitMetaio/Surfing"
    elif command -v am > /dev/null; then
        am start -a android.intent.action.VIEW -d "https://github.com/GitMetaio/Surfing"
    echo "ok" 
    else
        echo "无法打开浏览器，请手动访问以下地址："
        echo "https://github.com/GitMetaio/Surfing"
    fi
}
delete_files_and_dirs() {
    if [ ! -d "/data/adb/modules/Surfing/" ]; then
        echo "↴"
        echo "当前未安装模块！"
        return
    fi
    echo "↴"
    echo "警告：此操作将卸载删除 Surfing 模块，整体所有相关组件及数据，不可恢复！"
    echo
    while true; do
        echo "↴"
        printf "确定要继续吗？(y/n)："
        read confirm
        case "$confirm" in
            y|Y)
                break
                ;;
            n|N)
                echo "↴"
                echo "操作已取消！"
                return
                ;;
            *)
                echo "↴"
                echo "无效的输入！"
                echo
                ;;
        esac
    done
    while true; do
        echo "↴"
        printf "请输入'确认'以继续删除，直接回车取消："
        read input
        if [ "$input" = "确认" ]; then
            echo "↴"
            echo "正在停止服务..."
            /data/adb/box_bll/scripts/box.service stop > /dev/null 2>&1
            sleep 1.5
            for pid in $(pidof inotifyd); do
                if grep -qE "box.inotify|net.inotify|ctr.inotify" /proc/${pid}/cmdline; then
                    kill "$pid"
                fi
            done
            sleep 1
            echo "↴"
            echo "正在删除..."
            
            rm -rf "/data/adb/modules_update/Surfing" 2>/dev/null
            rm -rf "/data/adb/modules/Surfing" 2>/dev/null
            rm -f "/data/adb/service.d/Surfing_service.sh" 2>/dev/null
            rm -f "/data/adb/ksu/service.d/Surfing_service.sh" 2>/dev/null
            rm -rf "/data/adb/box_bll" 2>/dev/null
            
            rm -rf "/data/adb/modules/Surfingtile" 2>/dev/null
            
            APP_DIR=$(find /data/app -type d -name "*com.yadli.surfingtile*" 2>/dev/null | grep com.yadli.surfingtile)
            rm -rf "$APP_DIR" 2>/dev/null
            rm -rf "/data/user/0/com.yadli.surfingtile" 2>/dev/null
            rm -rf "/data/data/com.yadli.surfingtile" 2>/dev/null
            
            APP_DIR2=$(find /data/app -type d -name "*com.android64bit.web*" 2>/dev/null | grep com.android64bit.web)
            rm -rf "$APP_DIR2" 2>/dev/null
            rm -rf "/data/user/0/com.android64bit.web" 2>/dev/null
            rm -rf "/data/data/com.android64bit.web" 2>/dev/null
            
            echo "卸载完成！"
            return
        elif [ -z "$input" ]; then
            echo "↴"
            echo "操作已取消！"
            return
        else
            echo "↴"
            echo "无效的输入！"
            echo
        fi
    done
}
show_menu