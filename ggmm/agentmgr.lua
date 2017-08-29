-- local skynet = require "skynet"
local skynet = require "manager"
local util = require "util"
local agents={}
local store
skynet.start(function()
	skynet.dispatch('lua',function(session, source, cmd,fd,addr,ip)
		if(cmd=='add') then
			skynet.error("add agent",fd,addr,ip)
			local agent = skynet.newservice('agent')
			local msg = skynet.call(agent,'lua','init',fd,addr,ip)
			util.dump(msg,"add agent init",3)
			agents[fd] = agent
			
		elseif(cmd=='agent-closed') then
			skynet.error('agent-closed 1')
			local _addr = agents[fd]
			if(_addr) then
				skynet.error('agent-closed 2',fd,_addr)
			end
			for _fd,_addr in pairs(agents) do
				if(_addr==source) then
					skynet.error('agent-closed 3',_fd,_addr)
					agents[_fd] = nil
					break
				end
			end
			agents[fd] = nil
		end
	end)
	skynet.register(".agentmgr")
end)
