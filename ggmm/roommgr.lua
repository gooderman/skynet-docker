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
type = data.type
args = args,
user=user,
agent=agent,
addr=addr
]]--
local userroom={}
--[[
[userid]=roomid,
]]--

local CMD = {}
local roomid = 10000
function CMD.gen_roomid()
	while(true) do
		local id = 10000 + math.random(89999)
		if(not rooms[id]) then
			return id
		end
	end
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

	userroom[user.id] = roomid
	
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
		------------------------
		if(st==0) then
			userroom[user.id] = roomid
		end
		------------------------
		return st,info,addr
	end
	return -10
end	
function CMD.getroom(agent,user)
	local roomid
	-- for _,room in pairs(rooms) do
	-- 	if(room.owner == user.id) then
	-- 		roomid = room.id
	-- 		break
	-- 	end
	-- end
	-- if(not roomid) then
	-- 	return -1
	-- end
	---------------------------
	roomid = userroom[user.id]
	---------------------------
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

function CMD.roomcount()
	local ct = 0
	for k,_ in pairs(rooms) do
		if(k) then
			ct = ct + 1
		end
	end
	return ct
end


local NTF_CMD={}
function NTF_CMD.ntf_dismiss(roomid)
	rooms[roomid] = nil
	for uid,id in pairs(userroom) do
		if(id==roomid) then
			userroom[uid] = nil
		end
	end
end
function NTF_CMD.ntf_quit(uid)
	userroom[uid] = nil
end

skynet.start(function()

	skynet.info_func(function()
		return {room_count = CMD.roomcount()}
	end)
	
	skynet.dispatch('lua',function(session, source, cmd,...)
		if(CMD[cmd]) then
			local ff = CMD[cmd]
			if(type(ff)=='function') then
				return skynet.retpack(ff(source,...))
			end
		elseif(NTF_CMD[cmd]) then
			skynet.retpack(NTF_CMD[cmd](...))			
		end
	end)
	skynet.register(".roommgr")

	-- skynet.fork(function()
	-- 	while(true) do
	-- 		skynet.sleep(100)
	-- 		local id = CMD.gen_roomid()
	-- 		rooms[id] = 0
	-- 		skynet.error('CMD.gen_roomid =',id)
			
	-- 	end
	-- end)
end)
