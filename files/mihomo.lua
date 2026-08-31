--[[
  UzumakiClash - Master Controller Bridge
  Repo: https://github.com/jahid421/UzumakiClash-Openwrt
  Developer: Jahid Hasan Shuvo (@crazy_boy_jahid)
--]]

module("luci.controller.mihomo", package.seeall)

function index()
    -- Main Template Route
    entry({"admin", "services", "mihomo"}, template("mihomo/main"), _("UzumakiClash 🌀"), 60).dependent = false
    
    -- Root-Privileged API Route (Bypasses all uhttpd sandbox jails)
    entry({"admin", "services", "mihomo", "api"}, call("action_api"), nil).leaf = true
    entry({"admin", "services", "mihomo", "cfg"}, call("action_cfg"), nil).leaf = true
    entry({"admin", "services", "mihomo", "sub"}, call("action_sub"), nil).leaf = true
end

-- ১. পিওর রুট এপিআই গেটওয়ে (100% Accurate Status, Start & Stop)
function action_api()
    local http = require "luci.http"
    local sys  = require "luci.sys"
    local action = http.formvalue("action")
    local ip = http.formvalue("ip")
    
    http.prepare_content("application/json")
    
    -- প্রসেস চেক করার পিওর লিনাক্স নেটিভ ট্র্যাকিং
    local pid = sys.exec("pidof mihomo | awk '{print $1}'"):gsub("\n", "")
    local running = (pid ~= "")
    
    if action == "status" then
        local mem = "0 kB"
        if running then
            mem = sys.exec("awk '/VmRSS/{print $2}' /proc/" .. pid .. "/status 2>/dev/null"):gsub("\n", "") .. " kB"
        end
        local tp = sys.exec("[ -f /etc/mihomo/transparent ] && cat /etc/mihomo/transparent || echo 0"):gsub("\n", "")
        local enabled = sys.exec("[ -f /etc/mihomo/enabled ] && cat /etc/mihomo/enabled || echo 1"):gsub("\n", "")
        
        http.write(string.format('{"running":%s,"pid":"%s","memory":"%s","transparent":%s,"enabled":%s}', 
            tostring(running), pid, mem, tp:trim(), enabled:gsub("\n", "")))
            
    elseif action == "start" then
        sys.exec("echo 1 > /etc/mihomo/enabled")
        sys.exec("echo 1 > /etc/mihomo/transparent")
        sys.exec("/etc/init.d/mihomo restart >/dev/null 2>&1")
        http.write('{"ok":true}')
        
    elseif action == "stop" then
        sys.exec("echo 0 > /etc/mihomo/enabled")
        sys.exec("echo 0 > /etc/mihomo/transparent")
        sys.exec("/etc/init.d/mihomo stop >/dev/null 2>&1")
        http.write('{"ok":true}')
        
    elseif action == "restart" then
        sys.exec("/etc/init.d/mihomo restart >/dev/null 2>&1")
        http.write('{"ok":true}')
        
    elseif action == "enable_tp" then
        sys.exec("echo 1 > /etc/mihomo/transparent")
        sys.exec("nft -f /etc/mihomo/nft.conf >/dev/null 2>&1")
        http.write('{"ok":true}')
        
    elseif action == "disable_tp" then
        sys.exec("echo 0 > /etc/mihomo/transparent")
        sys.exec("nft delete table ip uzumaki >/dev/null 2>&1")
        http.write('{"ok":true}')
        
    elseif action == "add_acl_bypass" then
        if ip and ip ~= "" then
            sys.exec("nft add element ip uzumaki acl_bypass { " .. ip .. " } 2>/dev/null")
            http.write(string.format('{"ok":true,"ip":"%s"}', ip))
        else
            http.write('{"ok":false,"error":"no_ip"}')
        end
        
    elseif action == "flush_fakeip" then
        sys.exec("curl -s -X POST 'http://127.0.0.1:9595/cache/fakeip/flush' -H 'Authorization: Bearer flclash123' >/dev/null 2>&1")
        http.write('{"ok":true}')
        
    elseif action == "update_geo" then
        sys.exec("(cd /etc/mihomo && curl -sL -o geoip.dat 'https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip-lite.dat' && curl -sL -o geosite.dat 'https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat' && curl -sL -o Country.mmdb 'https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/country-lite.mmdb') &")
        http.write('{"ok":true,"message":"Updating in background"}')
    end
end

-- ২. কনফিগ অপ্টিমাইজার ও ভ্যালিডেটর (Pure Lua YAML Parser)
function action_cfg()
    local http = require "luci.http"
    local fs = require "nixio.fs"
    local sys = require "luci.sys"
    
    if http.getenv("REQUEST_METHOD") == "POST" then
        local content = ""
        http.recv_fblocks(function(chunk)
            if chunk then content = content .. chunk end
        end)
        content = content:gsub("\r", "")
        
        -- ফিল্টার আউট ও গ্লোবাল কনফিগ মার্জিং লজিক
        local clean_lines = {}
        for line in content:gmatch("[^\n]+") do
            local is_global = line:match("^[a-zA-Z0-9_-]+:")
            local skip = false
            if is_global then
                local key = line:match("^([a-zA-Z0-9_-]+):")
                if key == "mixed-port" or key == "redir-port" or key == "tproxy-port" or 
                   key == "port" or key == "socks-port" or key == "allow-lan" or 
                   key == "bind-address" or key == "mode" or key == "log-level" or 
                   key == "ipv6" or key == "external-controller" or key == "external-ui" or 
                   key == "secret" or key == "dns" or key == "sniffer" or key == "profile" then
                    skip = true
                end
            end
            if not skip then
                table.insert(clean_lines, line)
            end
        end
        
        -- গেমিং ও সিস্টেম অপ্টিমাইজড কনফিগ ইনজেক্ট করা
        local template = [[mixed-port: 7890
redir-port: 7892
tproxy-port: 7893
allow-lan: true
bind-address: '*'
mode: rule
log-level: error
ipv6: false
external-controller: 0.0.0.0:9595
external-ui: /etc/mihomo/ui
secret: "flclash123"
tcp-concurrent: true
unified-delay: false
global-client-fingerprint: chrome

profile:
  store-selected: true
  store-fake-ip: true

dns:
  enable: true
  listen: 0.0.0.0:1053
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16
  fake-ip-filter:
    - '*.lan'
    - '*.local'
    - 'localhost'
    - '+.riotgames.com'
    - '+.playvalorant.com'
    - '+.pvp.net'
    - '+.leagueoflegends.com'
    - '+.vanguard.riotgames.com'
    - '+.steampowered.com'
    - '+.steamcommunity.com'
    - '+.steamstatic.com'
    - '+.epicgames.com'
    - '+.unrealengine.com'
    - '+.microsoft.com'
    - '+.windows.com'
    - '+.windowsupdate.com'
    - '+.msecnd.net'
    - '+.xboxlive.com'
    - '+.xbox.com'
    - '+.discord.gg'
    - '+.discord.media'
    - '+.discordapp.com'
    - '+.discordapp.net'
    - '+.speedtest.net'
    - 'fast.com'
    - '+.bd'
    - '+.bkash.com'
  nameserver: [1.1.1.1, 8.8.8.8, 1.0.0.1]
  proxy-server-nameserver: [1.1.1.1]
  respect-rules: true
]]

        local body = table.concat(clean_lines, "\n")
        
        -- Riot, Microsoft ও ডিসকর্ড ডাইরেক্ট গেমিং রুলস ইনজেক্ট করা
        body = body:gsub("rules:", "rules:\n  - IP-CIDR,127.0.0.0/8,DIRECT,no-resolve\n  - DOMAIN-KEYWORD,riotgames,DIRECT\n  - DOMAIN-KEYWORD,playvalorant,DIRECT\n  - DOMAIN-SUFFIX,pvp.net,DIRECT\n  - DOMAIN-KEYWORD,vanguard,DIRECT\n  - DOMAIN-KEYWORD,steam,DIRECT\n  - DOMAIN-KEYWORD,epicgames,DIRECT\n  - DOMAIN-KEYWORD,microsoft,DIRECT\n  - DOMAIN-KEYWORD,xbox,DIRECT\n  - DOMAIN-SUFFIX,microsoft.com,DIRECT\n  - DOMAIN-SUFFIX,windowsupdate.com,DIRECT\n  - DOMAIN-KEYWORD,discord,DIRECT\n  - DOMAIN-SUFFIX,bd,DIRECT\n  - DOMAIN-KEYWORD,bkash,DIRECT")
        
        local final_yaml = template .. "\n" .. body
        fs.writefile("/tmp/test_config.yaml", final_yaml)
        
        -- মিহোমো টেস্ট রান ভ্যালিডেশন
        local test_status = sys.call("/usr/bin/mihomo -d /etc/mihomo -f /tmp/test_config.yaml -t > /tmp/cfg_err.log 2>&1")
        if test_status == 0 then
            fs.writefile("/etc/mihomo/config.yaml", final_yaml)
            sys.exec("/etc/init.d/mihomo restart >/dev/null 2>&1")
            http.prepare_content("text/plain")
            http.write("SAVED")
        else
            local err = sys.exec("tail -n 2 /tmp/cfg_err.log"):gsub("\n", " ")
            http.prepare_content("text/plain")
            http.write("INVALID YAML: " .. err)
        end
    else
        -- GET Request: Serve config.yaml
        local content = fs.readfile("/etc/mihomo/config.yaml") or ""
        http.prepare_content("text/plain")
        http.write(content)
    end
end

-- ৩. সাবস্ক্রিপশন পার্সার (Base64 ডিকোড ও অপ্টিমাইজড ডাউনলোড)
function action_sub()
    local http = require "luci.http"
    local sys  = require "luci.sys"
    local fs   = require "nixio.fs"
    local url  = http.formvalue("url")
    
    http.prepare_content("text/plain")
    if not url or url == "" then
        http.write("NO_URL")
        return
    end
    
    local tmp_file = "/tmp/raw_sub.yaml"
    sys.exec("curl -sL -H 'User-Agent: ClashMeta/1.18.0' -o " .. tmp_file .. " " .. sys.unique_header(url))
    
    -- বেস৬৪ চেক এবং ডিকোড
    local raw_content = fs.readfile(tmp_file) or ""
    if not raw_content:find("^proxies:") and not raw_content:find("^proxy%-providers:") then
        -- সাব-কনভার্টার API ব্যাকআপ কল
        local sub_conv = "https://api.v1.mk/sub?target=clash&insert=true&emoji=true&list=true&url=" .. luci.util.urlencode(url)
        sys.exec("curl -sL -o " .. tmp_file .. " '" .. sub_conv .. "'")
    end
    
    local parsed_content = fs.readfile(tmp_file) or ""
    if parsed_content:find("^proxies:") or parsed_content:find("^proxy%-providers:") then
        -- সরাসরি আমাদের অপ্টিমাইজড cfg অ্যাকশনে পাঠিয়ে দেওয়া
        sys.exec("curl -s -X POST --data-binary @" .. tmp_file .. " 'http://localhost/cgi-bin/luci/admin/services/mihomo/cfg' -H 'Content-Type: text/plain' > /tmp/sub_result.log 2>&1")
        local res = fs.readfile("/tmp/sub_result.log") or ""
        http.write(res)
    else
        http.write("DOWNLOAD_OR_CONVERSION_FAILED")
    end
end
