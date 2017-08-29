local skynet = require "skynet"

skynet.register_protocol {
	name = "text",
	id = skynet.PTYPE_TEXT,
	pack = function(text) return text end,
	unpack = function(buf, sz) return skynet.tostring(buf,sz) end,
}

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	pack = function(buf, sz) return buf, sz end,
}

local addr
local fd
local ip

local agentMgr

local function read()
	return skynet.tostring(skynet.rawcall(addr, "text", "R"))
end

local function write(msg, sz)
	skynet.send(addr, "client", msg, sz)
end
local function close()
	skynet.send(addr, "text", "K")
end

local function loop()
	while true do
		skynet.error('agent loop',fd,addr,ip)
		local ok, s = pcall(read)
		if not ok then
			skynet.error("agent fail read")
			skynet.send(agentMgr,'lua','agent-closed',fd)
			skynet.exit()
			return
		end
		write('rsp-'..s,4+string.len(s))
	end
end

skynet.start(function()
	skynet.dispatch('lua',function(session, source, cmd,_fd,_addr,_ip)
		if(cmd=='init') then
			agentMgr = source
			fd = _fd
			addr = _addr
			ip = _ip
			print('agent init',fd,addr,ip)
			skynet.fork(loop)
			-- error("fuckfuck")
			skynet.retpack({fd=fd,addr=addr,ip=ip})
		end
	end)
end)
