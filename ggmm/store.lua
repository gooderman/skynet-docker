local skynet = require "skynet"
require "skynet.manager"	-- import skynet.register
local conf={
	host = "127.0.0.1",
	port = 6379,
	db = 0

}
local redis = require "db.redis"
local db = nil

local command = {}

function command.GET(key)
	return db:get(key)
end

function command.SET(key, value)
	local last = db:get(key)
	db:set(key, value)
	return last
end

skynet.start(function()
	
	skynet.timeout(10,function()
		skynet.error("reidis is ",db and "ok" or "fail")	
	end)
	skynet.error("reids start")
	db = redis.connect(conf)
	if db then
		skynet.error("reids connect succ")
		
		db:set("A", "hello")
		db:set("B", "world")

		skynet.error(db:get("A"))
		skynet.error(db:get("B"))
	else
		 skynet.error("reids connect fail")	
	end
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[string.upper(cmd)]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)
	skynet.register ".store"
end)
