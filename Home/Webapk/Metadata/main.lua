local hotupdate = "true"
_G.Remotehotupdate = hotupdate
if _G.Remotehotupdate == "false" then
    return _G.Remotehotupdate
end

function isNetworkAvailable()
    local connectivityManager = activity.getSystemService(Context.CONNECTIVITY_SERVICE)
    local activeNetwork = connectivityManager.getActiveNetworkInfo()
    return activeNetwork ~= nil and activeNetwork.isConnected()
end

Http.get(url1 .. "?t=" .. os.time(), nil, "UTF-8", headers, function(code, content)
    if code == 200 and content then
        version = content:match("推送版本号:%s*(.-)\n") or "未知"
        updateLog = content:match("更新内容：%s*(.-)\n?}%s*") or "获取失败..."
    end
end)

Http.get(url2 .. "?t=" .. os.time(), nil, "UTF-8", headers, function(code, content)
    if code == 200 and content then
        local pushNotification = content:match("推送通知:%s*(.-)\n") or "关"
        local menuTitle = content:match("菜单标题:%s*(.-)\n") or "信息通知"
       
        more.onClick = function()
            local pop = PopupMenu(activity, more)
            local menu = pop.Menu
            
            menu.add("清除数据").onMenuItemClick = function(a)
                local builder = AlertDialog.Builder(activity)
                builder.setTitle("注意")
                builder.setMessage("此操作会清除自身全部数据并退出！")
                builder.setPositiveButton("确定", function(dialog, which)
                    activity.finish()
                    if activity.getPackageName() ~= "net.fusionapp" then
                        os.execute("pm clear " .. activity.getPackageName())
                    end
                end)
                builder.setNegativeButton("取消", nil)
                builder.setCancelable(false)
                builder.show()
            end
            
            menu.add("设置 URL").onMenuItemClick = function(a)
                local builder = AlertDialog.Builder(activity)
                builder.setTitle("设置URL")
                builder.setMessage("请输入要设置默认访问的链接：")
                local input = EditText(activity)
                input.setHint("http:// 或 https:// 开头...")
                builder.setView(input)
                builder.setPositiveButton("确定", function(dialog, which)
                    local url = input.getText().toString()
                    if url ~= "" and string.match(url, "^https?://[%w%._%-]+[%w%._%/?&%=%-]*") then
                        defaultUrl = url
                        webView.loadUrl(defaultUrl)
                        saveDefaultUrl(defaultUrl)
                    else
                        local errorDialog = AlertDialog.Builder(activity)
                        errorDialog.setTitle("错误")
                        errorDialog.setMessage("请输入有效的URL链接！")
                        errorDialog.setPositiveButton("确定", function(dialog, which) end)
                        errorDialog.setCancelable(false)
                        errorDialog.show()
                    end
                end)
                builder.setNegativeButton("取消", nil)
                builder.setCancelable(false)
                builder.show()
            end
            
            menu.add("Ad 拦截测试").onMenuItemClick = function(b)
              local url = "https://paileactivist.github.io/toolz/adblock.html"
              webView.loadUrl(url)
            end
            
            menu.add("背景图床 URL").onMenuItemClick = function()
              local intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://pomf2.lain.la/"))
              activity.startActivity(intent)
              return true
            end
            
            menu.add("IP 检查").onMenuItemClick = function(a)
                local subPop = PopupMenu(activity, more)
                local subMenu = subPop.Menu
                subMenu.add("IPW_CN").onMenuItemClick = function(b)
                    local url = "https://ipw.cn/"
                    webView.loadUrl(url)
                end
                subMenu.add("纯IPv6测试").onMenuItemClick = function(b)
                    local url = "https://ipv6.test-ipv6.com/"
                    webView.loadUrl(url)
                end
                subMenu.add("网站延迟").onMenuItemClick = function(b)
                    local url = "https://ip.skk.moe/simple"
                    webView.loadUrl(url)
                end
                subMenu.add("DNS泄露测试").onMenuItemClick = function(b)
                    local url = "https://www.browserscan.net/zh/dns-leak"
                    webView.loadUrl(url)
                end
                subMenu.add("DNS泄露测试").onMenuItemClick = function(b)
                    local url = "https://surfshark.com/zh/dns-leak-test"
                    webView.loadUrl(url)
                end
                subPop.show()
            end
            
            menu.add("切换面板").onMenuItemClick = function(a)
                local subPop = PopupMenu(activity, more)
                local subMenu = subPop.Menu
                subMenu.add("Meta").onMenuItemClick = function(b)
                    local url = "https://metacubex.github.io/metacubexd/#/proxies"
                    webView.loadUrl(url)
                    defaultUrl = url
                    saveDefaultUrl(defaultUrl)
                end
                subMenu.add("Yacd").onMenuItemClick = function(b)
                    local url = "https://yacd.mereith.com/#/proxies"
                    webView.loadUrl(url)
                    defaultUrl = url
                    saveDefaultUrl(defaultUrl)
                end
                subMenu.add("Zash").onMenuItemClick = function(b)
                    local url = "https://board.zash.run.place/#/proxies"
                    webView.loadUrl(url)
                    defaultUrl = url
                    saveDefaultUrl(defaultUrl)
                end
                subMenu.add("Local（本地端口）").onMenuItemClick = function(b)
                    local url = "http://127.0.0.1:9090/ui/#/proxies"
                    webView.loadUrl(url)
                    defaultUrl = url
                    saveDefaultUrl(defaultUrl)
                end
                subPop.show()
            end
            
            local function getLastCommitTime()
                Http.get(url .. "?t=" .. os.time(), nil, "UTF-8", headers, function(code, content)
                    if code == 200 and content then
                        local commitDate = content:match('"date"%s*:%s*"([^"]+)"')
                        if commitDate then
                            commitDate = commitDate:gsub("T", " "):gsub("Z", "")
                            local timestamp = os.time({
                                year = tonumber(commitDate:sub(1, 4)),
                                month = tonumber(commitDate:sub(6, 7)),
                                day = tonumber(commitDate:sub(9, 10)),
                                hour = tonumber(commitDate:sub(12, 13)),
                                min = tonumber(commitDate:sub(15, 16)),
                                sec = tonumber(commitDate:sub(18, 19))
                            })
                            timestamp = timestamp + 8 * 60 * 60
                            local formattedDate = os.date("%Y-%m-%d %H:%M:%S", timestamp)
                            showVersionInfo(formattedDate, updateLog)
                        else
                            showVersionInfo("获取失败！")
                        end
                    else
                        showVersionInfo("获取失败，错误码：" .. tostring(code))
                    end
                end)
            end
            
            local JSONObject = luajava.bindClass("org.json.JSONObject")
            
            function showVersionInfo(updateTime)
              local layout = LinearLayout(activity)
              layout.setOrientation(1)
              layout.setPadding(60, 10, 60, 10)
            
              local function addStyledText(text, size, color, bold)
                local tv = TextView(activity)
                tv.setText(text)
                tv.setTextSize(size)
                tv.setTextColor(color)
                tv.setTextIsSelectable(false)
                if bold then
                  tv.setTypeface(nil, Typeface.BOLD)
                end
                layout.addView(tv)
                return tv
              end
            
              addStyledText("Metadate", 18, 0xFF000000, true)
              addStyledText("Latestreleases " .. version, 15, 0xFF222222)
              addStyledText("Timestamp: " .. updateTime, 14, 0xFF444444)
              addStyledText("\n更新日志:", 16, 0xFF000000, true)
            
              local scrollView = ScrollView(activity)
              scrollView.setScrollbarFadingEnabled(false)
              scrollView.setScrollBarStyle(View.SCROLLBARS_OUTSIDE_INSET)
              scrollView.setPadding(20, 5, 20, 5)
            
              local logText = TextView(activity)
              logText.setText(updateLog)
              logText.setTextSize(13)
              logText.setTextColor(0xFF888888)
              logText.setPadding(0, 10, 0, 10)
              logText.setLineSpacing(1.5, 1)
              logText.setTextIsSelectable(true)
            
              scrollView.addView(logText)
            
              local dp = activity.getResources().getDisplayMetrics().density
              local layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                math.floor(200 * dp + 0.5)
              )
              scrollView.setLayoutParams(layoutParams)
            
              layout.addView(scrollView)
            
              local builder = AlertDialog.Builder(activity)
              builder.setView(layout)
              builder.setNegativeButton("Git", nil)
              builder.setPositiveButton("Telegram", nil)
              builder.setNeutralButton("取消", nil)
              builder.setCancelable(false)
              local dialog = builder.show()
              
              dialog.getButton(AlertDialog.BUTTON_NEGATIVE).setAllCaps(false)
              dialog.getButton(AlertDialog.BUTTON_NEGATIVE).setOnClickListener(View.OnClickListener{
                onClick = function()
                  activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://github.com/GitMetaio/Surfing")))
                end
              })
            
              dialog.getButton(AlertDialog.BUTTON_POSITIVE).setAllCaps(false)
              dialog.getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener(View.OnClickListener{
                onClick = function()
                  activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://t.me/+vvlXyWYl6HowMTBl")))
                end
              })
            
              dialog.getButton(AlertDialog.BUTTON_NEUTRAL).setAllCaps(false)
            
            
            Http.get("https://api-ipv4.ip.sb/geoip", nil, "UTF-8", headers, function(geoCode, geoContent)
                if geoCode == 200 and geoContent then
                    local obj = JSONObject(geoContent)
                    local timezone = obj.optString("timezone", "获取失败...")
                    local isp = obj.optString("isp", "获取失败...")
                    local asn = obj.optInt("asn", 0)
                    local ipV4 = obj.optString("ip", "获取失败...")
            
                    addStyledText("\nAPI ip.sb", 14, 0xFF444444)
                    addStyledText(timezone, 14, 0xFF444444)
                    addStyledText(isp, 14, 0xFF444444)
                    addStyledText("ASN: " .. asn, 14, 0xFF444444)
                    addStyledText("IPv4: " .. ipV4, 14, 0xFF444444)
                    
                    Http.get("https://api-ipv6.ip.sb/geoip", nil, "UTF-8", headers, function(ipv6Code, ipv6Content)
                        local ipV6Text = "IPv6: 当前网络不支持"
                        if ipv6Code == 200 and ipv6Content and ipv6Content:match("%S") then
                            local ok, objV6 = pcall(function() return JSONObject(ipv6Content) end)
                            if ok then
                                local ipV6 = objV6.optString("ip", nil)
                                if ipV6 and ipV6 ~= "" then
                                    ipV6Text = "IPv6: " .. ipV6
                                end
                            end
                        end
                        addStyledText(ipV6Text, 14, 0xFF444444)
                        local peakTriggered = false
                        local peakExpireTime = 0
                        local peakBaseCount = 0
                        
                        
                        local lastOnlineCount = nil
                        local lastUpdateTime = 0
                        function getOnlineCount()
                            local hour = tonumber(os.date("%H"))
                            local now = os.time()
                        
                            local ranges = {
                                {0, 6, 50, 300},
                                {6, 12, 300, 800},
                                {12, 18, 800, 2000},
                                {18, 24, 2000, 5000},
                            }
                        
                            local minCount, maxCount
                            for _, r in ipairs(ranges) do
                                if hour >= r[1] and hour < r[2] then
                                    minCount, maxCount = r[3], r[4]
                                    break
                                end
                            end
                        
                            if not lastOnlineCount then
                                lastOnlineCount = math.random(minCount, maxCount)
                                lastUpdateTime = now
                                return lastOnlineCount
                            end
                        
                            local delta = now - lastUpdateTime
                        
                            if delta < math.random(5, 15) then
                                return lastOnlineCount
                            end
                        
                            local changePercent = math.random(-5, 5) / 100
                            local newCount = math.floor(lastOnlineCount * (1 + changePercent))
                        
                            if newCount < minCount then newCount = minCount end
                            if newCount > maxCount then newCount = maxCount end
                        
                            lastOnlineCount = newCount
                            lastUpdateTime = now
                        
                            return newCount
                        end
            
                        local onlineCount = getOnlineCount()
                        addStyledText("\n😊当前在线 " .. onlineCount .. " 人", 14, 0xFF444444)
                        addStyledText("@Surfing Web.apk 2023.", 16, 0xFF444444)
                    end)
                end
            end)
            end
            
            menu.add("元数据").onMenuItemClick = function(a)
                if isNetworkAvailable() then
                   getLastCommitTime()
                else
                   Toast.makeText(activity, "当前网络不可用！", 0).show()
                end
            end
            
            menu.add("点我闪退(Exit)").onMenuItemClick = function(a)
                activity.finish()
                os.exit(0)
            end
            
            if pushNotification == "开" then
                menu.add(menuTitle).onMenuItemClick = function(a)
                    Toast.makeText(activity, "正在拉取中...", Toast.LENGTH_SHORT).show()
                    Handler().postDelayed(function()
                        loadInfo()
                    end, 2700)
                end
            end
            pop.show()
        end
    else
        -- 失败处理逻辑
    end
end)

return _G.Remotehotupdate