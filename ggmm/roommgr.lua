-- local skynet = require "skynet"
local skynet = require "manager"
local util = require "util"
local rooms={}
local roomaddr={}
local roomuser={}

local CMD = {}
local roomid = 100000
function CMD.gen_roomid()
	roomid = roomid+1
	return roomid
end
function CMD.newroom(agent,user,args)
	local roomid = CMD.gen_roomid()
	local info = {id = roomid,owner = user.id,args = args,user=user,agent=agent}
	local addr = skynet.newservice("room")
	skynet.call(addr,'lua','init',info)
	info.addr = addr
	rooms[roomid] = info
	roomaddr[addr] = roomid
	roomuser[user.id] = roomid
	return 0,roomid,args
end

function CMD.addroom(agent,roomid)
	rooms[roomid] = true
end	
function CMD.findroom(agent,roomid)
	return rooms[roomid]
end
function CMD.delroom(agent,roomid)
	rooms[roomid] = nil
end
function CMD.joinroom(agent,user,roomid)
	local room = rooms[roomid]
	if not room  then
		return -1
	else
		local st,info = skynet.call(room.addr,'lua','join',agent,user)
		return st,info
	end
	return -10
end	
function CMD.getroom(agent,user)
	local roomid = roomuser[user.id]
	if(not roomid) then
		return -1
	end
	local room = rooms[roomid]
	if not room  then
		return -1
	end
	local info = skynet.call(room.addr,'lua','getinfo',agent,user)
	if(info) then
		return 0,info
	end
	return -1
end


skynet.start(function()
	skynet.dispatch('lua',function(session, source, cmd,...)
		if(CMD[cmd]) then
			local ff = CMD[cmd]
			if(type(ff)=='function') then
				return skynet.retpack(ff(source,...))
			end
		end
	end)
	skynet.register(".roommgr")
end)
