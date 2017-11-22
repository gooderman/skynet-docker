local skynet = require "skynet"
local util = require 'util'
------------------------------------------------------------
local roominfo = {}
-- .Room {
--      id 0 : integer
--      owner 1 : integer
--      type 2 : integer
--      args 3 : RoomArgs
-- }
local gamestate = {}
-- .GameState {
--     state 0 : integer
--     jushu 1 : integer
--     banker 2 : integer #庄家
--     cards 3 : *Cards(chair) #玩家的牌
--     cardnumb 4 : integer #剩余未翻的牌
--     winner 5 : *integer
--     score 6 : *Score
-- }
local gameinfo = {}
-- .GameInfo {
--     rooom 0 : Room
--     player 1 : *Player
--     state 2 : GameState
-- }
local players = {} --{Player,agent}
-- .Player {
--      id 0 : integer
--      name 1 : string
--      gender 3 : integer
--      headimg 4 : string
--      chair 5 : integer
--      online 6 : boolean
--      ready 7: integer
--      ting 8 : boolean
--      hu 9 : boolean
-- }
local roomid = 0
local owner = 0
local args = {}
local readys = {}
local cards = {}
local cardidx = 0

-------------------------------------------
local mjlib = {}
local mjcmd = {}
--logic
local function __fapai()
	cards  = mjlib.gencards()

	local n = #players

	local cds = {}
	for i=1,n do
		cds[i] = {}
	end
	for j=1,13 do
		for i=1,n do
			local idx = (j-1)*n+i
			cds[i][j] = cards[idx]
		end
	end
	cds[1][14] = cards[13*n+1]
	cardidx = 13*n+1+1

	gamestate.cardnumb = #cards - 13*n -1
	local banker = gamestate.banker
	local ii=1
	for i=banker,banker+n do
		local idx = math.fmod(i,n)
		if(idx==0) then idx=n end
		gamestate.cards[idx] = cds[ii]
		ii = ii+1
	end
end

local function __init()
	roominfo = {
		id = 0,
		owner = 0,
		type = 0,
		args = {}

	}
	gamestate = {
		state=0,
    	jushu=1,
    	maxjushu = 4,
    	banker=1,
    	cards={},
    	deskcards={},
    	winner={},
    	score={},
	}
	gameinfo = {
		room = roominfo,
		player = players,
		state = gamestate
	}
end

-------------------------------------------
local CMD = {}
--commond
--create init
--room = {owner = userid,args = args,user}
--args = {renshu,jushu,wanfa}
function CMD.init(info)	
	roominfo = info
	roomid = info.id
	owner = info.owner
	args = info.args
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
	return roominfo
end
--user join
function CMD.join(agent,userinfo)
	for i,u in ipairs(players) do
		if(u.user.id==userinfo.id) then
			u.user.online = true
			u.agent=agent
			return 0,roominfo
		end
	end
	if(#players<args.renshu) then
		userinfo.ready = false
		userinfo.chair = #players+1
		userinfo.online = true
		userinfo.ting = false
		userinfo.hu = false
		table.insert(players,{user=userinfo,agent=agent})
		util.dump(userinfo,"CMD.join userinfo")
		--通知
		for i=1,#players-1 do
			local user = players[i]
			local __agent = user.agent
			if(__agent) then
				skynet.send(__agent,'lua','ntf_join',userinfo)
			end
		end

		local __players = {}
		for i=1,#players do
			__players[#__players+1] = players[i].user
		end

		gameinfo.player = __players

		skynet.send(agent,'lua','ntf_gameinfo',gameinfo)
		
		return 0,args
	else
		return -1
	end
end
function CMD.close()
	skynet.exit()
end
-------------------------------------------
local GCMD = {}
--user quit or dismiss by owner
function GCMD.quit(agent,data)
	for i,u in ipairs(players) do
		if(u.user.id==userid) then
			skynet.error('room CMD.quit',userid)
			
			u.agent = nil
			u.user.online = false
			u.user.ready = false

			if(owner==userid) then
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

function GCMD.ready(agent,data)
	for i,u in ipairs(players) do
		if(u.agent==agent) then
			skynet.error('room CMD.ready',u.user.id)
			u.user.ready = true
			break
		end
	end
	local n = args.renshu
	local m = 0
	for i,u in ipairs(players) do
		if(u.agent and u.user.ready) then
			m = m + 1
		end
	end
	if(n==m) then
		__fapai()
		gamestate.state = 1
		for i,u in ipairs(players) do
			skynet.send(u.agent,'lua','ntf_gamestart',gameinfo)
		end
	end
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
	__init()
	skynet.dispatch('lua',function(session, source, cmd,...)
		if(CMD[cmd]) then
			local ff = CMD[cmd]
			if(type(ff)=='function') then
				return skynet.retpack(ff(...))
			end
		elseif(cmd=='gcmd') then
			local subcmd,data = ...
			if(GCMD[subcmd]) then
				local ff = GCMD[subcmd]
				if(type(ff)=='function') then
					return skynet.retpack(ff(source,data))
				end
			end
		elseif(PCMD[cmd]) then
			local ff = PCMD[cmd]
			if(type(ff)=='function') then
				return skynet.retpack(ff(source,...))
			end
		end
	end)
end)




