local skynet = require "skynet"

local auth
local agentMgr
local roomMgr
local watchDog
local store_redis
local store_sqlite
local store_unqlite
local store_mysql
local majiang
skynet.start(function()
	skynet.newservice("debug_console",8000)

	skynet.newservice("httplistener", skynet.getenv("LOGIN_WEB_PORT"))

	store_sqlite = skynet.uniqueservice("store_sqlite")
	-- store_unqlite = skynet.uniqueservice("store_unqlite")
	-- store_redis = skynet.uniqueservice("store_redis")
	-- store_mysql = skynet.uniqueservice("store_mysql")
	skynet.uniqueservice("protoloader")
	-- majiang = skynet.uniqueservice('mj_heshun_dianhu')
	-- majiang = skynet.uniqueservice('mj_heshun_suanfen')
	auth = skynet.uniqueservice("auth")
	agentMgr = skynet.uniqueservice("agentmgr")
	roomMgr = skynet.uniqueservice("roommgr")
	watchDog = skynet.uniqueservice("watchdog")
	-- skynet.newservice("room")

end)
