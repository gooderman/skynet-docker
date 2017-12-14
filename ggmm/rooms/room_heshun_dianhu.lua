local skynet = require "skynet"
local cjson = require "cjson"
local util = require 'util'
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local ___sp = nil
local ___sptp = 10
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
--      user  0 : UserBase
--      chair 1 : integer
--      online 2 : boolean
--      ready 3: boolean
--      ting 4 : boolean
--      hu 5 : boolean
-- }
local ___dismiss_vote={}
-- {
-- 	time #remaintime
-- 	chair #sender
-- 	agree 
--  dismiss
--  time_start
--  time_end
-- }
-----------------------
local ___roomid = 0
local ___owner = 0
local ___args = {}
local ___argstr = ""
-- .RoomArgs {
--      renshu 0 : integer
--      jushu 1 : integer
--      wanfa 2 :integer
-- }
local ___self = 0
local ___cards = {}
local ___cardidx = 0

-------------------------------------------
local ___mjlib = {}
local ___mjcmd = {}
--logic
local function ___fapai()
	___cards  = ___mjlib.gencards()

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
	___sp = sprotoloader.load(___sptp)
	___roominfo = {
		id = 0,
		owner = 0,
		type = 0,
		args = ___argstr
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
		player = {},
		state = ___gamestate
	}
end

local function ___data_ntf(agent,cmd,con)
	local data = ___sp:encode(cmd,con)
	skynet.send(agent,'lua','data_ntf',___sptp,cmd,data)
end
local function ___ntf(agent,cmd,con)
	skynet.send(agent,'lua',cmd,con)
end

--cmd from agent
local GCMD = {}
-------------------------------------------
---cmd from roommgr
local CMD = {}
--commond
--create init
--room = {owner = userid,args = args,user}
--args = {renshu,jushu,wanfa}
function CMD.init(info)	
	___roominfo = info
	___roomid = info.id
	___owner = info.owner
	___args = cjson.decode(info.args)
	___argstr = info.args
	___self = skynet.self()

	___mjcmd = require "mj_heshun_dianhu.lib"
	___mjlib = require "mj_heshun_dianhu.base"
	return true
end
--user get
function CMD.getinfo()
	return ___roominfo
end
--user join
function CMD.join(agent,user)
	for i,u in ipairs(___players) do
		local uuu = u.info.user
		local info = u.info
		if(uuu.id==user.id) then
			info.online = true
			u.agent=agent
------------------------------------------------------
--通知
			skynet.fork(function()
				GCMD.online_ntf(agent,info.chair,true)
			end)
			skynet.fork(function()
				local players = {}
				for i=1,#___players do
					players[#players+1] = ___players[i].info
				end
				___gameinfo.player = players

				GCMD.gameinfo_ntf(agent,___gameinfo)
			end)			
------------------------------------------------------				
			return 0,___roominfo,___self
		end
	end
	local info={}
	info.user=user
	if(#___players<___args.renshu) then
		
		info.chair = #___players+1
		info.ready = false
		info.online = true
		info.ting = false
		info.hu = false
		
		table.insert(___players,{info=info,agent=agent})
		util.dump(info,"CMD.join user")		
------------------------------------------------------
--通知
		skynet.fork(function()
			GCMD.joinroom_ntf(agent,info)
		end)
		skynet.fork(function()				
			local players = {}
			for i=1,#___players do
				players[#players+1] = ___players[i].info
			end
			___gameinfo.player = players

			GCMD.gameinfo_ntf(agent,___gameinfo)
		end)
------------------------------------------------------	
		return 0,___roominfo,___self
	else
		return -1
	end
end

function CMD.agent_closed(agent,userid)
	for i,u in ipairs(___players) do
		local uuu = u.info.user
		local info = u.info
		if(uuu.id==userid) then
			skynet.error('room CMD.quit',userid)
			info.online = false
			info.ready = false
			u.agent = nil
----------------------------------
			skynet.fork(function()
				GCMD.online_ntf(agent,info.chair,false)
			end)
----------------------------------
			break
		end
	end
end

function CMD.close()
	skynet.call('.roommgr','lua','ntf_dismiss',___roomid)
	skynet.exit()
end

function CMD.dismiss()
	skynet.call('.roommgr','lua','ntf_dismiss',___roomid)
	for i=1,#___players-1 do
		___ntf(u.agent,'dismiss_ntf')
	end
	skynet.timeout(10,function()
		skynet.exit()
	end)
end
function CMD.agentquit(agent)
	___ntf(agent,'quit_ntf')
end
-------------------------------------------
--online_ntf
function GCMD.online_ntf(agent,chair,online)
	local cmd = 'online_ntf'
	for i=1,#___players-1 do
		local _agent = ___players[i].agent
		if(_agent and _agent~=agent) then
			___data_ntf(u.agent,cmd,{chair = chair, online = online})				
		end
	end
end
--joinroom_ntf
function GCMD.joinroom_ntf(agent,info)
	local cmd = 'joinroom_ntf'
	for i=1,#___players-1 do
		local _agent = ___players[i].agent
		if(_agent and _agent~=agent) then
			___data_ntf(u.agent,cmd,{player = info})				
		end
	end
end
--quit_ntf
function GCMD.quit_ntf(agent,chair)
	local cmd = 'quit_ntf'
	for i=1,#___players-1 do
		___data_ntf(u.agent,cmd,{chair = chair})
	end
end
--dismiss_ntf
function GCMD.dismiss_ntf(chair)
	local cmd = 'dismiss_ntf'
	for i=1,#___players-1 do
		___data_ntf(u.agent,cmd,{chair = chair})
	end
end
--dismiss_vote_ntf
function GCMD.dismiss_vote_ntf(vote)
	local cmd = 'dismiss_vote_ntf'
	local time = vote.time_end - vote.time_start
	for i=1,#___players-1 do
		___data_ntf(u.agent,cmd,{chair = vote.chair,agree=vote.agree,dismiss=vote.dismiss,time = time})
	end
end
--gameinfo_ntf
function GCMD.gameinfo_ntf(agent,gameinfo)
	local cmd = 'gameinfo_ntf'
	for i=1,#___players-1 do
		local _agent = ___players[i].agent
		if(_agent==agent) then
			___data_ntf(agent,cmd,{game = gameinfo})
			break				
		end
	end
end

-------------------------------------------
--ready
function GCMD.ready_req(agent,data)
	for i,u in ipairs(___players) do
		if(u.agent==agent) then
			skynet.error('room GCMD.ready_req',u.info.id)
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
		skynet.error('room GCMD.ready to start')
		___fapai()
		___gamestate.state = 1
	--------------------------------------------------
		local cmd = 'gamestart_ntf'
		local con = {game = ___gameinfo}
		for i,u in ipairs(___players) do
			___data_ntf(u.agent,cmd,con)
		end
	--------------------------------------------------	
	end
	return 'ready_ntf',{chair=0,ready=true}
end

--quit req
function GCMD.quit_req(agent,data)
	local chair
	local idx
	local uid
	for i,u in ipairs(___players) do
		if(u.agent==agent) then
			local uuu = u.info.user
			chair = u.chair
			idx = i
			uid = uuu.id
			skynet.error('room GCMD.quit_req',uuu.id)
			break
		end
	end
	if(not chair) then
		return
	end
	--未开始
	if(___gamestate.state==0) then
		--dismiss
		if(___owner==uid) then
			GCMD.dismiss_ntf(chair)
			CMD.dismiss()
		else
			GCMD.quit_ntf(agent,chair)	
			CMD.agentquit(agent)
			table.remove(___players,idx)
		end
	else
		___dismiss_vote = ___dismiss_vote or {}
		local vote = ___dismiss_vote
		vote.agree = vote.agree or {}
		vote.dismiss = 0
		if(not vote.chair) then
			vote.chair = chair
		else
			vote.agree[chair]=1
		end
		GCMD.dismiss_vote_ntf(vote)
	end
end

--dismiss_vote_req
function GCMD.dismiss_vote_req(agent,data)
	local chair
	for i,u in ipairs(___players) do
		if(u.agent==agent) then
			local uuu = u.info.user
			chair = u.chair
			skynet.error('room GCMD.dismiss_vote_req',uuu.id)
			break
		end
	end
	if(not chair) then
		return
	end
	--未开始
	if(___gamestate.state==0) then
		return
	end
	if(___dismiss_vote and ___dismiss_vote.chair) then
		local vote = ___dismiss_vote
		vote.agree = vote.agree or {}
		vote.dismiss = 0
		if(data.agree) then
			vote.agree[chair]=1
		else	
			vote.agree[chair]=2
		end
		--自己取消
		if(data.agree==2 and vote.chair == chair) then
			vote.dismiss = 2
			GCMD.dismiss_vote_ntf(vote)
			___dismiss_vote = nil
			return 
		end
		local n = #___players
		local yes = 0
		local no = 0
		for c,ag in pairs(vote.agree) do
			if(ag==1) then
				yes = yes + 1
			elseif(ag==2) then
				no = no + 1	
			end
		end
		if(yes>=n/2) then
			vote.dismiss = 1
		elseif(no>=n/2) then
			vote.dismiss = 2
		end

		GCMD.dismiss_vote_ntf(vote)
		if(vote.dismiss>0) then
			___dismiss_vote = nil
			if(vote.dismiss==1) then
				GCMD.dismiss_ntf(chair)
				CMD.dismiss()
			end
		end
	end
end

--cmd from agent client
function GCMD.dataup(agent,data)
	local findagent
	for i,u in ipairs(___players) do
		if(u.agent==agent) then
			findagent = agent
			-- skynet.error('room CMD.quit',userid)
			break
		end
	end
	if(not findagent) then
		skynet.error('room GCMD.dataup no agent')
		return
	end
	local tp,cmd,con = data.type,data.cmd,data.data
	local tb = ___sp:decode(cmd, con)
	-- util.dump(tb,"room GCMD.dataup")
	local func = GCMD[cmd]
	if(func) then
		local rcmd,result = func(agent,tb)
		local rdata = ___sp:encode(rcmd, result)
		return tp,rcmd,rdata
	end
end

-------------------------------------------

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
		end
	end)
end)




