local skynet = require "skynet"
local util = require 'util'
------------------------------------------------------------
local roomid = 0
local owner = 0
local agents = {}
local users = {}
local args = {}
local CMD = {}
--create init
--room = {owner = userid,args = args,user}
--args = {renshu,wanfa}
function CMD.init(info)
	roomid = info.id
	owner = info.owner
	args = info.args
	table.insert(users,{user=info.user,agent=info.agent})
	args.id = roomid
	args.owner = owner
	args.addr = skynet.self()

	return true
end
--user get
function CMD.getinfo()
	return args
end
--user join
function CMD.join(useraddr,userinfo)
	for i,u in ipairs(users) do
		if(u.user.id==userinfo.id) then
			users[i].user=userinfo
			users[i].agent=useraddr
			skynet.timeout(10,function()
				skynet.call(useraddr,'lua','ntf_gameready')
			end)
			return 0,args
		end
	end
	if(#users<args.renshu) then
		table.insert(users,{user=userinfo,agent=useraddr})
		return 0,args
	else
		return -1
	end
end
--user quit or dismiss by owner
function CMD.quit(userid)
	for i,u in ipairs(users) do
		if(u.user.id==userid) then
			skynet.error('room CMD.quit',userid)
			u.agent = nil
			break
		end
	end
end
--
function CMD.enter(useraddr,userinfo)
end
--
function CMD.exit(useraddr)
end

function CMD.close()
	skynet.exit()
end

local PCMD = {}

function PCMD.chupai(addr,pai)
end
function PCMD.chi(addr)
end
function PCMD.peng(addr)
end
function PCMD.gang(addr)
end
function PCMD.ting(addr)
end
function PCMD.hu(addr)
end

skynet.start(function()
	
	-- skynet.fork(test)

	skynet.dispatch('lua',function(session, source, cmd,...)
		if(CMD[cmd]) then
			local ff = CMD[cmd]
			if(type(ff)=='function') then
				return skynet.retpack(ff(...))
			end
		elseif(PCMD[cmd]) then
			local ff = PCMD[cmd]
			if(type(ff)=='function') then
				return skynet.retpack(ff(source,...))
			end
		end
	end)
end)




