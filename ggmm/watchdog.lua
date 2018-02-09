local skynet = require "skynet"
local socket = require "socket"
local test={}
skynet.start(function()
	local auth = skynet.queryservice('auth')
	local agentMgr = skynet.queryservice('agentmgr')
	local id = assert(socket.listen("0.0.0.0", skynet.getenv('GAME_LISTEN_PORT')))
	socket.start(id, function (fd, addr)
		skynet.error(string.format("%s connected as %d" , addr, fd))
		skynet.send(auth,'lua','auth',fd,addr)
	end)
	skynet.dispatch('lua',function(session, source, cmd,fd, addr, ip,desc)
		if(cmd=='auth-succ') then
			skynet.error('auth-succ',fd,addr,desc)
			skynet.send(agentMgr,'lua','add',fd,addr,ip)
		elseif(cmd=='auth-fail') then
			skynet.error('auth-fail',fd,addr,desc)
		end
	end)
	-- test.testfunc()
end)
test.testfunc = function()
	local agentmgr = skynet.localname(".agentmgr")
	print(string.format("agentmgr is %d" , agentmgr))
	local store = skynet.localname(".store")
	print(string.format("store is %d" , store))
	local rst =  skynet.call(".store",'lua','GET','A')
	print(string.format("store call GET A is %s" , rst))
end

