local skynet = require "skynet"
local socket = require "socket"
local proxy = require "socket_proxy"

local function read(fd)
	return skynet.tostring(proxy.read(fd))
end

skynet.start(function()
	skynet.dispatch('lua',function(session, source, cmd, fd,ip)
		if(cmd=='auth') then
			skynet.error('auth start',fd,ip)
			local addr = proxy.subscribe(fd)
			skynet.error('auth 1',addr)
			proxy.write(fd,'ping',4)
			local ok, s = pcall(read, fd)
			if not ok then
				skynet.error("auth fail read")
				skynet.send(source,'lua','auth-fail',nil,nil,ip,'read')
				return
			end
			if s == "pong" then
				skynet.send(source,'lua','auth-succ',fd,addr,ip,'pong')
			else
				proxy.close(fd)
				skynet.send(source,'lua','auth-fail',fd,addr,ip,'not pong')
			end
		end
	end)
end)
