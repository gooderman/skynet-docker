local skynet = require "skynet"

local auth
local agentMgr
local watchDog
local store
skynet.start(function()
	skynet.newservice("debug_console",8000)
	store_sqlite = skynet.uniqueservice("store_sqlite")
	-- store = skynet.uniqueservice("store")
	auth = skynet.uniqueservice("auth")
	agentMgr = skynet.uniqueservice("agentmgr")
	watchDog = skynet.uniqueservice("watchdog")
	skynet.newservice("httplistener", skynet.getenv("LOGIN_WEB_PORT"))
end)
