-- UzumakiClash LuCI Controller
module("luci.controller.uzumaki", package.seeall)

function index()
    if not nixio.fs.access("/etc/uzumaki/config.yaml") then
        return
    end
    
    local page = entry({"admin", "services", "uzumaki"},
        template("uzumaki/main"), _("UzumakiClash"), 30)
    page.dependent = true
    page.acl_depends = { "luci-app-uzumaki" }
    
    entry({"admin", "services", "uzumaki", "status"},
        call("action_status")).leaf = true
    entry({"admin", "services", "uzumaki", "restart"},
        call("action_restart")).leaf = true
    entry({"admin", "services", "uzumaki", "update_sub"},
        call("action_update_sub")).leaf = true
end

function action_status()
    local sys = require "luci.sys"
    local http = require "luci.http"
    
    local running = (sys.call("pidof uzumaki-core >/dev/null") == 0)
    local mem = "0"
    if running then
        mem = sys.exec("awk '/VmRSS/ {print $2}' /proc/$(pidof uzumaki-core)/status")
    end
    
    http.prepare_content("application/json")
    http.write_json({
        running = running,
        memory_kb = tonumber(mem) or 0,
        version = sys.exec("/usr/bin/uzumaki-core -v | head -1")
    })
end

function action_restart()
    luci.sys.call("/etc/init.d/uzumaki restart >/dev/null 2>&1 &")
    luci.http.prepare_content("application/json")
    luci.http.write_json({ success = true })
end

function action_update_sub()
    luci.sys.call("/usr/bin/uzumaki-sub update >/dev/null 2>&1 &")
    luci.http.prepare_content("application/json")
    luci.http.write_json({ success = true })
end
