local skynet = require "skynet"
local util = require 'util'
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local ___sp = nil
------------------------------------------------------------
local ___roominfo = {}
-- .Room {
--      id 0 : integer
--      owner 1 : integer
--      type 2 : integer
--      args 3 : RoomArgs
-- }
local ___gamestate = {}
-- .GameState {
--     state 0 : integer
--     jushu 1 : integer
--     banker 2 : integer #庄家
--     cards 3 : *Cards(chair) #玩家的牌
--     cardnumb 4 : integer #剩余未翻的牌
--     winner 5 : *integer
--     score 6 : *Score
-- }
local ___gameinfo = {}
-- .GameInfo {
--     rooom 0 : Room
--     player 1 : *Player
--     state 2 : GameState
-- }
local ___players = {} --{info=Player,agent=agent}
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
local ___roomid = 0
local ___owner = 0
local ___args = {}
-- .RoomArgs {
--      renshu 0 : integer
--      jushu 1 : integer
--      wanfa 2 :integer
-- }
local ___self = 0
local ___cards = {}
local ___cardidx = 0

-------------------------------------------
local mjlib = {}
local mjcmd = {}
--logic
local function __fapai()
	___cards  = mjlib.gencards()

	local n = #___players

	local cds = {}
	for i=1,n do
		cds[i] = {}
	end

	___cardidx=1
	for j=1,13 do
		for i=1,n do
			cds[i][j] = ___cards[___cardidx]
			___cardidx = ___cardidx + 1
		end
	end
	cds[1][14] = ___cards[___cardidx]
	___cardidx = ___cardidx+1

	-- util.dump(cds,'cds',6)

	___gamestate.cardnumb = #___cards - ___cardidx + 1
	local banker = ___gamestate.banker
	local ii=1
	for i=banker,banker+n-1 do
		local idx = math.fmod(i,n)
		if(idx==0) then idx=n end

		local cards = ___sp:default("Cards")
		
		cards.chair = idx
		cards.hand=cds[ii]
		-- skynet.error("___gamestate.cards[idx]",idx)
		___gamestate.cards[idx] = cards
		ii = ii+1
	end
	-- util.dump(___gamestate.cards,'cds',6)
end

local function __init()
	___sp = sprotoloader.load(1)
	___roominfo = {
		id = 0,
		owner = 0,
		type = 0,
		args = ___args
	}
	___gamestate = {
		state=0,
    	jushu=1,
    	maxjushu = 4,
    	banker=2,
    	cards={},
    	deskcards={},
    	winner={},
    	score={},
	}
	___gameinfo = {
		room = ___roominfo,
		player = ___players,
		state = ___gamestate
	}
end

-------------------------------------------
local CMD = {}
--commond
--create init
--room = {owner = userid,args = args,user}
--args = {renshu,jushu,wanfa}
function CMD.init(info)	
	___roominfo = info
	___roomid = info.id
	___owner = info.owner
	___args = info.args
	___self = skynet.self()

	if(___args.wanfa==1) then
		mjcmd = require "mj_heshun_dianhu.lib"
		mjlib = require "mj_heshun_dianhu.base"
	elseif(___args.wanfa==2) then
		mjcmd = require "mj_heshun_suanfen.lib"
		mjlib = require "mj_heshun_suafen.base"	
	end
	return true
end
--user get
function CMD.getinfo()
	return ___roominfo
end
--user join
function CMD.join(agent,user)
	for i,u in ipairs(___players) do
		if(u.info.id==user.id) then
			u.info.online = true
			u.agent=agent
			return 0,___roominfo,___self
		end
	end
	if(#___players<___args.renshu) then
		user.ready = false
		user.chair = #___players+1
		user.online = true
		user.ting = false
		user.hu = false
		table.insert(___players,{info=user,agent=agent})
		util.dump(user,"CMD.join user")
		--通知
		for i=1,#___players-1 do
			local __agent = ___players[i].agent
			if(__agent) then
				skynet.send(__agent,'lua','ntf_join',user)
			end
		end

		local players = {}
		for i=1,#___players do
			players[#players+1] = ___players[i].info
		end

		___gameinfo.player = players

		skynet.send(agent,'lua','ntf_gameinfo',___gameinfo)
		
		return 0,___roominfo,___self
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
	for i,u in ipairs(___players) do
		if(u.info.id==userid) then
			skynet.error('room CMD.quit',userid)
			
			u.agent = nil
			u.info.online = false
			u.info.ready = false

			if(___owner==userid) then
				skynet.call(agent,'lua','ntf_roomdismiss')
				skynet.call('.roommgr','lua','ntf_roomdismiss',___roomid)
				skynet.timeout(10,function()
					skynet.exit()
				end)		
			end
			break
		end
	end
end

function GCMD.ready(agent,data)
	for i,u in ipairs(___players) do
		if(u.agent==agent) then
			skynet.error('room CMD.ready',u.info.id)
			u.info.ready = true
			break
		end
	end
	local n = ___args.renshu
	local m = 0
	for i,u in ipairs(___players) do
		if(u.agent and u.info.ready) then
			m = m + 1
		end
	end
	if(n==m) then
		skynet.error('room CMD.ready to start')
		__fapai()
		___gamestate.state = 1
		for i,u in ipairs(___players) do
			skynet.send(u.agent,'lua','ntf_gamestart',___gameinfo)
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




