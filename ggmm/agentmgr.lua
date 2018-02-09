-- local skynet = require "skynet"
local skynet = require "manager"
local util = require "util"
local ___agents={}
local ___uids = {}
local function agent_count()
	local ct = 0
	for k,_ in pairs(___agents) do
		ct = ct + 1
	end
	return ct
end
skynet.start(function()

	skynet.info_func(function()
		return {agent_count = agent_count()}
	end)
	
	skynet.dispatch('lua',function(session, source, cmd,...)
		if(cmd=='add') then
			local fd,addr,ip = ...
			skynet.error("add agent",fd,addr,ip)
			local agent = skynet.newservice('agent')
			local msg = skynet.call(agent,'lua','init',fd,addr,ip)
			util.dump(msg,"add agent init",3)
			___agents[fd] = agent

		elseif(cmd=='reg') then
			local fd, uid = ...
			skynet.error("reg agent",fd,uid)
			local ofd = ___uids[uid]
			if(ofd) then
				local oaddr = ___agents[ofd]
				if(oaddr) then
					skynet.send(oaddr,'lua','replaced')
				end
				___agents[ofd] = nil
			end
			___uids[uid] = fd
			skynet.retpack({ret = true})	
		elseif(cmd=='agent-closed') then
			local fd = ...
			skynet.error('agent-closed 1')
			local addr = ___agents[fd]
			if(addr) then
				skynet.error('agent-closed 2',fd,addr)
			end
			for uid,ffdd in pairs(___uids) do
				if(fd==ffdd) then
					skynet.error('agent-closed 3',uid)
					___uids[uid] = nil
					break
				end
			end
			___agents[fd] = nil
		end
	end)
	skynet.register(".agentmgr")
end)
