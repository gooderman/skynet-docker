local skynet = require "skynet"
require "manager"
local socket = require "socket"
local proxy = require "socket_proxy"
local util = require "util"
require "functions"

local CMD = import(".lib",...) 

skynet.start(function()

	-- local ta = skynet.now()		
	-- builder.new("majiang", {zipai = zipai, fengpai = fengpai})
	-- local tb = skynet.now()
	-- skynet.error("majiang builder end",(tb-ta)*10)
	-- zipai = nil
	-- fengpai = nil
	-- skynet.fork(testA)
	-- skynet.fork(test7D)
	skynet.fork(CMD.test)
	skynet.dispatch('lua',function(session, source, cmd, ...)
		if(CMD[cmd]) then
			local ff = CMD[cmd]
			if(ff) then
				return skynet.retpack(ff(...))
			end
		end
	end)
	skynet.register ".majiang"
end)
