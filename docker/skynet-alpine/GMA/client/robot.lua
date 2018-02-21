local skynet = require "skynet"
local socket = require "skynet.socket"
local crypt = require "skynet.crypt"
local util = require "util"
local cjson = require "cjson"

local roomtype = 10
local uid,roomid,renshu,jushu = ...
uid = tostring(uid)
roomid = tonumber(roomid)
renshu = tonumber(renshu)
jushu = tonumber(jushu)
local rsp_get_roomid

local ___user = nil
local ___chair = 0
local ___game = nil
local ___cards = nil

local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local sp
local host
local send_request
local decode_msg

local fd = nil
local sid = 1

local function send_package(fd, pack)
	local package = string.pack(">s2", pack)
	socket.write(fd, package)
	sid = sid+1
end

local function unpack_package(text)
	local size = #text
	if size < 2 then
		return nil, text
	end
	local s = text:byte(1) * 256 + text:byte(2)
	if size < s+2 then
		return nil, text
	end

	return text:sub(3,2+s), text:sub(3+s)
end

local function recv_package(last)
	local result
	result, last = unpack_package(last)
	if result then
		return result, last
	end
	local r = socket.read(fd)
	if not r then
		return nil, last
	end
	if r == "" then
		error "Server closed"
	end
	return unpack_package(last .. r)
end
local last = ""
local function dispatch_package()
	while true do
		local v
		v, last = recv_package(last)
		if not v then
			break
		end
		return v
	end
end
local CMD = {}
local RMD = {}
local GCMD = {}
local RGCMD = {}
--接收
RMD.auth = function(data)
	local pack = send_request("auth",{key=crypt.base64encode(data.key)},sid,'auth')
	send_package(fd,pack)
	CMD.login()
end
RMD.login = function(data)
	-- util.dump(data,'RMD.login')
	if(data.state==0) then
		___user = data.user
		if(roomid==0) then
			CMD.newroom()
		else
			CMD.joinroom()
			GCMD.ready()
		end
	end
end
RMD.newroom = function(data)
	-- util.dump(data,'RMD.login')
	if(data.state==0) then
		roomid = data.room.id
		if(rsp_get_roomid) then
			rsp_get_roomid(true,roomid)
		end
		CMD.joinroom()
		GCMD.ready()
	end
end
RMD.datadn = function(data)
	local t = data.type
	local cmd = data.cmd
	local data = sp:decode(cmd,data.data)
	util.dump(data,'cmd-'..cmd,6)
	if(RGCMD[cmd]) then
		RGCMD[cmd](data)
	end
end

---发送
CMD.heartbeat = function()
	local pack = send_request("heartbeat",{},sid,"heartbeat")
	send_package(fd,pack)
end

CMD.login = function()
	local req = {
		user ={
			openid = uid,
			name = "user"..uid,
			gender = math.random(1,2),
			headimg  = "http://user_head.jpg",
			platform  = "ios",
			os  = 'ios11.0',
			device = 'iphone-x',
			uuid ='',
		}
	}
	local pack = send_request("login",req,sid,"login")
	send_package(fd,pack)
end

CMD.newroom = function()
	local req = {
		type = roomtype,
		args = cjson.encode({
			renshu = renshu,
			jushu = jushu,
			wanfa = 1,
			ting = true,
			bao = true,
			gangf = true,
		})
	}
	local pack = send_request("newroom",req,sid,"newroom")
	send_package(fd,pack)
end
CMD.joinroom = function()
	local req = {
		roomid = roomid
	}
	local pack = send_request("joinroom",req,sid,"joinroom")
	send_package(fd,pack)
end
CMD.joinroom = function()
	local req = {
		roomid = roomid
	}
	local pack = send_request("joinroom",req,sid,"joinroom")
	send_package(fd,pack)
end
CMD.dataup = function(cmd,data)
	local req = {
		type = roomtype,
		cmd = cmd
	}
	req.data = sp:encode(cmd,data)
	local pack = send_request("dataup",req,sid,"dataup")
	send_package(fd,pack)
end
--------------------------
GCMD.ready = function()
	CMD.dataup('ready_req',{ready=1})
end
GCMD.chu_req = function(card)
	CMD.dataup('chu_req',{card=card})
end
GCMD.pass_req = function()
	CMD.dataup('pass_req',{})
end
GCMD.ting_req = function(isting,card)
	CMD.dataup('ting_req',{isting=isting,card=card})
end

RGCMD.gamestart_ntf = function(data)
	___game = data.game
	local player = data.game.player
	for _,v in pairs(player) do
		if(v.user.id==___user.id) then
			___chair = v.chair
			break
		end
	end	

	for _,v in pairs(data.game.state.cards) do
		if(v.chair==___chair) then
			___cards = v
			break
		end
	end	
	
	skynet.error('gamestart_ntf',___user.id,___chair,#___cards.hand)
end

RGCMD.getcard_ntf = function(data)
	if(data.chair==___chair) then
		table.insert(___cards.hand,data.card)
		skynet.error('getcard_ntf',___user.id,___chair,data.card)
	end
end
RGCMD.chu_tip = function(data)
	if(data.chair == ___chair) then
		local card = ___cards.hand[1]
		skynet.error('chu_req',___user.id,___chair,card)
		GCMD.chu_req(card)
	end
end
RGCMD.chu_ntf = function(data)
	if(data.chair == ___chair) then
		local card = data.card
		for k,c in ipairs(___cards.hand) do
			if (c==card) then
				table.remove(___cards.hand,k)
				skynet.error('chu_ntf',___user.id,___chair,card)
				break
			end
		end
	end
end
local opt_tps = {
	'出','吃L','吃M','吃R','碰','杠M','杠X','杠A','听','胡',
}
RGCMD.opt_tip = function(data)
	if(data.chair == ___chair) then
		-- data.from
		-- data.card
		local tps = data.types
		local card = data.card
		local ss = ""
		for _,v in ipairs(tps) do
			ss =  (opt_tps[v] or v) .. "-"
		end
		--0,1,2-3-4,5,6-7-8,9,10 出 左吃-中吃-右吃 碰 明杠-续杠-暗杠 听 胡
		skynet.error('opt_tip',___user.id,___chair,card,ss)
		GCMD.pass_req()
	end
end
RGCMD.opt_tip_self = function(data)
	if(data.chair == ___chair) then
    	-- data.chair
    	-- data.hu
    	-- data.gangxu
    	-- data.gangan
		local tps = data.types
		local ss = ""
		if(data.hu) then
			ss = ss .. "胡-"
		end
		if(data.gangxu and #data.gangxu>0) then
			ss = ss .. "杠X-"
		end
		if(data.gangan and #data.gangan>0) then
			ss = ss .. "杠A-"
		end
		--0,1,2-3-4,5,6-7-8,9,10 出 左吃-中吃-右吃 碰 明杠-续杠-暗杠 听 胡
		skynet.error('opt_tip_self',___user.id,___chair,card,ss)
		GCMD.pass_req()
	end
end
RGCMD.ting_tip = function(data)
	if(data.chair == ___chair) then
		local card = ___cards.hand[1]
		skynet.error('ting_req',___user.id,___chair,card)
		GCMD.ting_req(false,card)
	end
end

RGCMD.report_ntf = function(data)
	skynet.timeout(500, function()
		GCMD.ready()
	end)
end




--------------------------
local function loop_heartbeat()
	while(true) do
		CMD.heartbeat()
		skynet.sleep(800)
	end
end

local function loop()
	fd = socket.open(skynet.getenv('GAME_SERVER_IP'), skynet.getenv('GAME_LISTEN_PORT'))
	skynet.error('socket open ',fd,skynet.getenv('GAME_SERVER_IP'))
	if(not fd) then
		return
	end
	-- socket.start(fd)
	while(true) do
		local p = dispatch_package()
		if p then
			local cmd , data = decode_msg(p,string.len(p))
			if(cmd~='heartbeat') then
				util.dump(data,'dispatch_package '..cmd)
				if(RMD[cmd]) then
					RMD[cmd](data)
				end
			end
			if(cmd=='auth') then
				skynet.fork(loop_heartbeat)
			end
		end
		skynet.sleep(10)
	end
end

skynet.start(function(v)
	skynet.error('robot start ====',uid,roomid,renshu)

	sp = sprotoloader.load(roomtype)
	host = sp:host('package')
	send_request = host:attach(sp)
	decode_msg = function(msg,sz)
		local tp,b,c,d,e = host:dispatch(msg)
		if(tp=='REQUEST')then
			-- tp,name,content,response,ud
			return b,c,d,e
		else
			-- tp,sid,content,ud
			--ud is name
			return d,c
		end
	end

	skynet.dispatch('lua', function(session, source, cmd,...)
		if(cmd=='getroomid') then
			if(roomid==0) then
				rsp_get_roomid = skynet.response()
			else
				skynet.retpack(roomid)
			end
		end
	end)
	skynet.fork(loop)
end)
