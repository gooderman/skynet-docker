-- local skynet = require "skynet"
local skynet = require "manager"
local cjson = require "cjson"
local util = require "util"
local roomtypes={
	[1] = 'common',
	[10] = 'room_heshun_dianhu',
	[11] = 'room_heshun_suanfen'
}
local rooms={}
--[[
id = roomid,
owner = user.id,
args = args,
user=user,
agent=agent,
addr=addr
]]--

local CMD = {}
local roomid = 100000
function CMD.gen_roomid()
	roomid = roomid+1
	return roomid
end

function CMD.newroom(agent,user,data)
	local name = roomtypes[data.type]
	if(not name) then
		return
	end
	local roomid = CMD.gen_roomid()
	local roominfo = {
		id = roomid,
		owner = user.id,
		type = data.type,
		args = data.args,
		user=user,
		agent=agent
	}
	local addr = skynet.newservice(name,'abc')
	roominfo.addr = addr
	skynet.call(addr,'lua','init',roominfo)
	rooms[roomid] = roominfo
	return 0,roominfo,addr
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
		local st,info,addr = skynet.call(room.addr,'lua','join',agent,user)
		return st,info,addr
	end
	return -10
end	
function CMD.getroom(agent,user)
	local roomid
	for _,room in pairs(rooms) do
		if(room.owner == user.id) then
			roomid = room.id
			break
		end
	end
	if(not roomid) then
		return -1
	end
	local room = rooms[roomid]
	if not room  then
		return -1
	end
	local info = skynet.call(room.addr,'lua','getinfo',agent,user)
	if(info) then
		return 0,info,room.addr
	end
	return -1
end


local NTF_CMD={}
function NTF_CMD.ntf_dismiss(src,roomid)
	rooms[roomid] = nil
end

skynet.start(function()
	skynet.dispatch('lua',function(session, source, cmd,...)
		if(CMD[cmd]) then
			local ff = CMD[cmd]
			if(type(ff)=='function') then
				return skynet.retpack(ff(source,...))
			end
		elseif(NTF_CMD[cmd]) then
			skynet.retpack(NTF_CMD[cmd]())			
		end
	end)
	skynet.register(".roommgr")
end)
