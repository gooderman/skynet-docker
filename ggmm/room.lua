local skynet = require "skynet"
local util = require 'util'
------------------------------------------------------------
local roomid = 0
local ownerid = 0
local agents = {}
local users = {}
local args = {}
local readys = {}
local cards = {}

-------------------------------------------
local mjlib = nil
local mjcmd = nil
--logic
local function __setReady(userid,flag)
	readys[userid] = flag
end
local function __isReady(userid)
	return readys[userid]
end
local function __fapai()
	cards  = mjlib.gencards()
end

-------------------------------------------
local CMD = {}
--commond
--create init
--room = {owner = userid,args = args,user}
--args = {renshu,wanfa}
function CMD.init(info)
	roomid = info.id
	ownerid = info.ownerid
	args = info.args
	args.id = roomid
	args.ownerid = ownerid
	args.addr = skynet.self()

	if(args.wanfa==1) then
		mjcmd = require "mj_heshun_dianhu.lib"
		mjlib = require "mj_heshun_dianhu.base"
	elseif(args.wanfa==2) then
		mjcmd = require "mj_heshun_suanfen.lib"
		mjlib = require "mj_heshun_suafen.base"	
	end
	return true
end
--user get
function CMD.getinfo()
	return args
end
--user join
function CMD.join(agent,userinfo)
	for i,u in ipairs(users) do
		if(u.user.id==userinfo.id) then

			users[i].user.online = true

			users[i].agent=agent
			return 0,args
		end
	end
	if(#users<args.renshu) then
		__setReady(userinfo.id,false)
		userinfo.chair = #users+1
		userinfo.online = true
		userinfo.ting = false
		userinfo.hu = false
		util.dump(userinfo,"CMD.join userinfo")
		table.insert(users,{user=userinfo,agent=agent})

		skynet.send(agent,'lua','ntf_join',userinfo)
		
		return 0,args
	else
		return -1
	end
end
--user quit or dismiss by owner
function CMD.quit(agent,userid)
	for i,u in ipairs(users) do
		if(u.user.id==userid) then
			skynet.error('room CMD.quit',userid)
			
			u.agent = nil
			u.online = false
			
			__setReady(userid,nil)

			if(ownerid==userid) then
				skynet.call(agent,'lua','ntf_roomdismiss')
				skynet.call('.roommgr','lua','ntf_roomdismiss',roomid)
				skynet.timeout(10,function()
					skynet.exit()
				end)
			end
			break
		end
	end
end

function CMD.ready(agent,userid)
	for i,u in ipairs(users) do
		if(u.user.id==userid) then
			skynet.error('room CMD.ready',userid)
			__setReady(userid,true)
			break
		end
	end
	local n = args.renshu
	local m = 0
	for i,u in ipairs(users) do
		if(u.agent and __isReady(u.user.id)) then
			m = m + 1
		end
	end
	if(n==m) then
		__fapai()
	end
end
--
function CMD.enter(agent,userinfo)
end
--
function CMD.exit(agent)
end

function CMD.close()
	skynet.exit()
end

-------------------------------------------
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




