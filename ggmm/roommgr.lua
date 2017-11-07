-- local skynet = require "skynet"
local skynet = require "manager"
local util = require "util"
local rooms={}
local roomaddr={}

local CMD = {}
local room_id = 10000
function CMD.gen_roomid(userid)
	roomid = roomid+1
	return roomid
end
function CMD.newroom(userid,args)
	local roomid = CMD.gen_roomid(userid)
	local room = {owner = userid,args = args,users={userid}}
	local addr = skynet.newservice("room")
	skynet.call(addr,'lua','init',room)
	room.addr = addr
	rooms[roomid] = room
	roomaddr[addr] = roomid
	return roomid,args
end	
function CMD.addroom(roomid)
	rooms[roomid] = true
end	
function CMD.findroom(roomid)
	return rooms[roomid]
end
function CMD.delroom(roomid)
	rooms[roomid] = nil
end
function CMD.joinroom(userid,roomid)
	local room = rooms[roomid]
	if not room  then
		return -1
	elseif not room.addr then
		return -2
	else
		local r,info = skynet.call(room.addr,'lua','join',userid)
		return r,info
	end
	return -10
end	

skynet.start(function()
	skynet.dispatch('lua',function(session, source, cmd,...)
		if(CMD[cmd]) then
			local ff = CMD[cmd]
			if(type(ff)=='function') then
				return skynet.retpack(ff(...))
			end
		end
	end)
	skynet.register(".roommgr")
end)
