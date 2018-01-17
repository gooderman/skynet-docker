local skynet = require "skynet"
local cjson = require "cjson"
local util = require 'util'
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local DISMISS_WAIT_TIME = 30000
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
local ___dismiss_vote=nil
-- {
-- 	time #remaintime
-- 	chair #sender
-- 	agree 
--  dismiss
--  time_start
--  time_end
-- }

local ___playernum = function() end
local ___playeradd = function(u) end
local ___playerdel = function(i) end
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
local ___cards = {} --所有的牌
local ___cardidx = 0 --发牌索引
local ___costep = nil --step线程

local ___optchair = 0 --操作人
local ___optidx = 0
local ___opttype = 0 --操作类型 hu chi peng gang
local ___optvalue = 0 --操作牌
local ___optrec = {} --操作记录

-- {
-- 	opt = opt, --操作
-- 	idx = idx, --索引
-- 	data = data --协议数据
-- }
local ___optrsp = {} --一人出牌以后，其他人截胡吃碰杠堆栈--
local ___optrec = {} --最后下发的cpg消息，保存待重发时使用。下发给___optcpg栈顶玩家

-------------------------------------------
local ___mjlib = {}
local ___mjcmd = {}
--先声明后面重新定义
--0,1,2-3-4,5,6-7-8,9,10 出 左吃-中吃-右吃 碰 明杠-续杠-暗杠 听 胡
local ___OPT_TP_PASS = 0 
local ___OPT_TP_CHU = 1 
local ___OPT_TP_CHI_L = 2
local ___OPT_TP_CHI_M = 3
local ___OPT_TP_CHI_R = 4
local ___OPT_TP_PENG = 5
local ___OPT_TP_GANG_1 = 6 
local ___OPT_TP_GANG_2 = 7
local ___OPT_TP_GANG_3 = 8
local ___OPT_TP_TING = 9
local ___OPT_TP_HU = 10
local ___OPT_TP_READY = 100

local ___ST_IDLE = 0
local ___ST_WAIT_READY = 1
local ___ST_FAPAI = 2
local ___ST_WAIT_CHU = 3
local ___ST_WAIT_TING = 4
local ___ST_WAIT_GANG_2 = 5
local ___ST_WAIT_GANG_3 = 6
local ___ST_WAIT_CPG = 7
local ___ST_WAIT_HU = 8
local ___ST_WAIT_HUGANG = 9 --自己起牌后判断

local ___optmap = {} --操作顺序映射
local ___ckhu = function() end
local ___ckting = function() end
local ___fapai = function() end
local ___onepai = function() end
local ___step_st = ___ST_IDLE
local ___step_info = {}
local ___stepover = function() end
local ___step = function() end
local ___steprecover = function() end --重入状态补发
local ___setst = function() end
local ___start = function() end
local ___stop = function() ___costep = nil end
local ___hu = function() end
local ___huang = function() end
local ___optrsp_add = function() end
local ___optget = function() end
local ___optgetcpg = function() end
local ___optclean = function() end
local ___emptyfunc = function() end

local ___do_opt = function() end

-------------------------------------------
local function __init()
	___sp = sprotoloader.load(___sptp)
	___roominfo = ___sp:default("RoomBase")
	___gamestate = ___sp:default("GameState")
	___gamestate.state = 0
	___gamestate.banker = 1
    ------------------------
    ___gamestate.optchair = 0
    ___gamestateopttype = 0
    ___gamestate.optparam = {}
    ------------------------
	___gameinfo = {
		room = ___roominfo,
		player = {},
		state = ___gamestate
	}
end

local function ___playernum()
	local n = 0
	for _,p in pairs(___players) do
		if(p) then
			n=n+1
		end
	end
	return n
end
local function ___playeradd(u)
	local n = ___playernum()
	local m = ___args.renshu
	if(n>=m) then
		return false,'exceed1'
	end
	for i=1,m do
		if(not ___players[i]) then
			___players[i] = u
			u.info.chair = i
			return true,i
		end
	end
	return false,'exceed2'
end
local function ___playerdel(i)
	for i=1,m do
		___players[i] = nil
	end	
end

local function ___data_ntf(agent,cmd,con)
	if(not agent) then
		return
	end
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

	--启动打牌线程
	___start()
	return true
end
--user get
function CMD.getinfo()
	return ___roominfo
end
--user join
function CMD.join(agent,user)
	for i,u in pairs(___players) do
		local uuu = u.info.user
		local info = u.info
		if(uuu.id==user.id) then
			info.online = true
			u.agent=agent

			-- util.dump(___players,'CMD.join',6)
			------------------------------------------------------
			skynet.fork(function()
				GCMD.online_ntf(agent,info.chair,true)
			end)
			skynet.fork(function()
				local players = {}
				for i,u in pairs(___players) do
					players[i] = u.info
				end
				___gameinfo.player = players
				GCMD.gameinfo_ntf(agent,___gameinfo)
				------------------------------------------
				if(___dismiss_vote) then
					GCMD.dismiss_vote_ntf(___dismiss_vote)
				end
				------------------------------------------
			end)			
			------------------------------------------------------				
			return 0,___roominfo,___self
		end
	end
	if(___playernum()<___args.renshu) then
		local info={}
		info.user=user
		info.chair = 0
		info.ready = false
		info.online = true
		info.ting = false
		info.hu = false
		local flag,param = ___playeradd({info=info,agent=agent})		
		------------------------------------------------------
		--通知
		skynet.fork(function()
			GCMD.joinroom_ntf(agent,info)
		end)
		skynet.fork(function()				
			local players = {}
			for i,u in pairs(___players) do
				players[i] = u.info
			end
			___gameinfo.player = players

			GCMD.gameinfo_ntf(agent,___gameinfo)
			------------------------------------------
			if(___dismiss_vote) then
				GCMD.dismiss_vote_ntf(___dismiss_vote)
			end
			------------------------------------------
		end)
		------------------------------------------------------	
		return 0,___roominfo,___self
	else
		return -1
	end
end
function CMD.agent_closed(agent,userid)
	for i,u in pairs(___players) do
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
	-- util.dump(___players,'CMD.agent_closed',6)
end
function CMD.close()
	skynet.call('.roommgr','lua','ntf_dismiss',___roomid)
	___stop()
	skynet.exit()
end
function CMD.dismiss()
	skynet.call('.roommgr','lua','ntf_dismiss',___roomid)
	for i,u in pairs(___players) do
		local _agent = u.agent
		___ntf(_agent,'dismiss_ntf')
	end
	skynet.timeout(10,function()
		___stop()
		skynet.exit()
	end)
end
function CMD.agentquit(agent,uid)
	skynet.call('.roommgr','lua','ntf_quit',uid)
	___ntf(agent,'quit_ntf')
end
-------------------------------------------
--online_ntf
function GCMD.online_ntf(agent,chair,online)
	local cmd = 'online_ntf'
	for i,u in pairs(___players) do
		local _agent = u.agent
		if(_agent and _agent~=agent) then
			___data_ntf(_agent,cmd,{chair = chair, online = online})				
		end
	end
end
--joinroom_ntf
function GCMD.joinroom_ntf(agent,info)
	local cmd = 'joinroom_ntf'
	for i,u in pairs(___players) do
		local _agent = u.agent
		if(_agent and _agent~=agent) then
			___data_ntf(_agent,cmd,{player = info})				
		end
	end
end
--ready_ntf
function GCMD.ready_ntf(agent,id)
	local cmd = 'ready_ntf'
	for i,u in pairs(___players) do
		local _agent = u.agent
		if(_agent) then
			___data_ntf(_agent,cmd,{chair = id})				
		end
	end
end
--quit_ntf
function GCMD.quit_ntf(agent,chair)
	local cmd = 'quit_ntf'
	for i,u in pairs(___players) do
		___data_ntf(u.agent,cmd,{chair = chair})
	end
end
--dismiss_ntf
function GCMD.dismiss_ntf(chair)
	local cmd = 'dismiss_ntf'
	for i,u in pairs(___players) do
		___data_ntf(u.agent,cmd,{chair = chair})
	end
end
--dismiss_vote_ntf
function GCMD.dismiss_vote_ntf(vote)
	local cmd = 'dismiss_vote_ntf'
	local time = vote.time_end - vote.time_start
	for i,u in pairs(___players) do
		___data_ntf(u.agent,cmd,{chair = vote.chair,agree=vote.agree,dismiss=vote.dismiss,time = time})
	end
end
--gameinfo_ntf
function GCMD.gameinfo_ntf(agent,gameinfo)
	local cmd = 'gameinfo_ntf'
	for i,u in pairs(___players) do
		local _agent = u.agent
		if(_agent==agent) then
			___data_ntf(agent,cmd,{game = gameinfo})
			break				
		end
	end
end
--gamestart_ntf
function GCMD.gamestart_ntf(gameinfo)
	local cmd = 'gamestart_ntf'
	for i,u in pairs(___players) do
		___data_ntf(u.agent,cmd,{game = gameinfo})
	end
end

-------------------------------------------
--ready
function GCMD.ready_req(agent,data)
	if(___gamestate.state==1) then
		return
	end
	local chair
	for i,u in pairs(___players) do
		if(u.agent==agent) then
			u.info.ready = true
			chair = u.info.chair
			skynet.error('room GCMD.ready_req',u.info.user.id,chair)
			break
		end
	end
	if(not chair) then
		return
	end
	-- skynet.error('room GCMD.ready to ntf')
	GCMD.ready_ntf(agent,chair)
	___optrsp_add(___OPT_TP_READY,chair,data)
end
--quit req
function GCMD.quit_req(agent,data)
	local chair
	local idx
	local uid
	for i,u in pairs(___players) do
		if(u.agent==agent) then
			local uuu = u.info.user
			chair = u.info.chair
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
			skynet.error('room GCMD.quit_req to dismiss_ntf')
			GCMD.dismiss_ntf(chair)
			CMD.dismiss()
		else
			skynet.error('room GCMD.quit_req to quit_ntf')
			GCMD.quit_ntf(agent,chair)	
			CMD.agentquit(agent,uid)
			___playerdel(idx)
		end
	else
		if(___dismiss_vote) then
			GCMD.dismiss_vote_ntf(___dismiss_vote)
			return
		end
		local isbegan = not ___dismiss_vote
		___dismiss_vote = ___dismiss_vote or {}
		local vote = ___dismiss_vote
		vote.agree = vote.agree or {}
		vote.dismiss = 0
		vote.time_start = vote.time_start or os.time()
		vote.time_end = vote.time_end or os.time() + DISMISS_WAIT_TIME
		vote.time = vote.time_end - vote.time_start
		if(not vote.chair) then
			vote.chair = chair
		end
		vote.agree[chair]=1
		skynet.error('room GCMD.quit_req to dismiss_vote_ntf',vote.time)
		GCMD.dismiss_vote_ntf(vote)
		if(isbegan) then
			local time = vote.time_start
			local tt = vote.time/10
			skynet.timeout(tt,function()
				if(___dismiss_vote and ___dismiss_vote.time_start==time) then
					skynet.error('room GCMD.quit_req timeout to dismiss_ntf')
					GCMD.dismiss_ntf(chair)
					CMD.dismiss()
				else

				end
			end)
		end
	end
end
--dismiss_vote_req
function GCMD.dismiss_vote_req(agent,data)
	local chair
	for i,u in pairs(___players) do
		if(u.agent==agent) then
			local uuu = u.info.user
			chair = u.info.chair
			skynet.error('room GCMD.dismiss_vote_req',uuu.id,chair,___gamestate.state)
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
		if(data.agree==1) then
			vote.agree[chair]=1
		else	
			vote.agree[chair]=2
		end
		--自己取消
		if(data.agree==2 and vote.chair == chair) then
			skynet.error('room GCMD.dismiss_vote_req cancel by self')
			vote.dismiss = 2
			GCMD.dismiss_vote_ntf(vote)
			___dismiss_vote = nil
			return 
		end
		local n = ___playernum()
		local yes = 0
		local no = 0
		for c,ag in pairs(vote.agree) do
			if(ag==1) then
				yes = yes + 1
			elseif(ag==2) then
				no = no + 1	
			end
		end
		if(yes>n/2) then
			vote.dismiss = 1
		elseif(no>=n/2) then
			vote.dismiss = 2
		end

		GCMD.dismiss_vote_ntf(vote)
		if(vote.dismiss>0) then
			___dismiss_vote = nil
			if(vote.dismiss==1) then
				skynet.error('room GCMD.dismiss_vote_req to agree')
				GCMD.dismiss_ntf(chair)
				CMD.dismiss()
			else
				skynet.error('room GCMD.dismiss_vote_req to reject')	
			end
		end
	end
end
-------------------------------------------
-------------------------------------------
-------------------------------------------
--chu_tip
function GCMD.chu_tip(idx,cards)
	local cmd = 'chu_tip'
	for i,u in pairs(___players) do
		___data_ntf(u.agent,cmd,{chair = idx,cards={}})
	end
end
--chu_req
function GCMD.chu_req(agent,data)
	for i,u in pairs(___players) do
		if(u.agent==agent) then
			___optrsp_add(___OPT_TP_CHU,i,data)
			skynet.error('room GCMD.chu_req',u.info.id,i)
			break
		end
	end
end
--chu_ntf
function GCMD.chu_ntf(idx,card)
	local cmd = 'chu_ntf'
	for i,u in pairs(___players) do
		___data_ntf(u.agent,cmd,{chair=idx,card=card})
	end	
end
-----------------------
--ting_tip
function GCMD.ting_tip(idx,ting)
	local u = ___players[idx]
	local cmd = 'ting_tip'
	if(u and u.agent) then
		___data_ntf(u.agent,cmd,{chair = idx,ting=ting})
	end
end
--ting_req
function GCMD.ting_req(agent,data)	
	for i,u in pairs(___players) do
		if(u.agent==agent) then
			___optrsp_add(___OPT_TP_TING,i,data)
			skynet.error('room GCMD.ting_req',u.info.id,i)
			break
		end
	end
end
--ting_ntf
function GCMD.ting_ntf(idx,card)
	local cmd = 'ting_ntf'
	for i,u in pairs(___players) do
		___data_ntf(u.agent,cmd,{chair=idx,card=card})
	end	
end
-----------------------
--hu_tip
function GCMD.hu_tip(from,to,card,zimo)
end
--hu_req
function GCMD.hu_req(agent,data)
	for i,u in pairs(___players) do
		if(u.agent==agent) then
			___optrsp_add(___OPT_TP_HU,i,data)
			skynet.error('room GCMD.hu_req',u.info.id,i)
			break
		end
	end	
end
--hu_ntf
function GCMD.hu_ntf(idx,from,card,zimo)
	local cmd = 'hu_ntf'
	for i,u in pairs(___players) do
		___data_ntf(u.agent,cmd,{chair=idx,from=from, card=card, zimo=zimo})
	end	
end
--huang_ntf
function GCMD.huang_ntf()
	local cmd = 'huang_ntf'
	for i,u in pairs(___players) do
		___data_ntf(u.agent,cmd,{})
	end	
end
-----------------------
--chi_tip
function GCMD.chi_tip(idx,type,from,card)
end
--chi_req
function GCMD.chi_req(agent,data)
	for i,u in pairs(___players) do
		if(u.agent==agent) then
			___optrsp_add(data.type,i,data)
			skynet.error('room GCMD.chi_req',u.info.id,i)
			break
		end
	end		
end
--chi_ntf
function GCMD.chi_ntf(idx,type,from,card)
	local cmd = 'chi_ntf'
	for i,u in pairs(___players) do
		___data_ntf(u.agent,cmd,{state = 0, chair=idx,type=type, from=from, card=card})
	end	
end
-----------------------
--peng_tip
function GCMD.peng_tip(idx,type,from,card)
end
--peng_req
function GCMD.peng_req(agent,data)
	for i,u in pairs(___players) do
		if(u.agent==agent) then
			___optrsp_add(___OPT_TP_PENG,i,data)
			skynet.error('room GCMD.peng_req',u.info.id,i)
			break
		end
	end
end
--peng_ntf
function GCMD.peng_ntf(idx,type,from,card)
	local cmd = 'peng_ntf'
	for i,u in pairs(___players) do
		___data_ntf(u.agent,cmd,{state = 0, chair=idx,from=from, card=card})
	end
end	
-----------------------
--gang_tip
function GCMD.gang_tip(idx,type,from,card)
end
--gang_req
function GCMD.gang_req(agent,data)
	for i,u in pairs(___players) do
		if(u.agent==agent) then
			___optrsp_add(data.type,i,data)
			skynet.error('room GCMD.gang_req',u.info.id,i)
			break
		end
	end		
end
--gang_ntf
function GCMD.gang_ntf(idx,type,from,card)
	local cmd = 'gang_ntf'
	for i,u in pairs(___players) do
		if(idx==i) then
			___data_ntf(u.agent,cmd,{state = 0, chair=idx,type=type, from=from, card=card})
		else
			if(type==___OPT_TP_GANG_3) then
				___data_ntf(u.agent,cmd,{state = 0, chair=idx,type=type, from=from, card=0})
			else
				___data_ntf(u.agent,cmd,{state = 0, chair=idx,type=type, from=from, card=card})
			end
		end
	end	
end
-----------------------
--接牌操作提示
function GCMD.opt_tip(idx,data)
	local u = ___players[idx]
	local cmd = 'opt_tip'
	if(u and u.agent) then
		___data_ntf(u.agent,cmd,data)
	end	
end
--起牌操作提示
function GCMD.opt_tip_self(idx,data)
	local u = ___players[idx]
	local cmd = 'opt_tip_self'
	if(u and u.agent) then
		___data_ntf(u.agent,cmd,{chair = idx,hu=data.hu, gangxu=data.gangxu, gangan=data.gangan})
	end
end
-----------------------
--pass_ntf
function GCMD.pass_req(agent,data)
	for i,u in pairs(___players) do
		if(u.agent==agent) then
			___optrsp_add(___OPT_TP_PASS,i,data)
			skynet.error('room GCMD.pass_req',u.info.id,i)
			break
		end
	end		
end
--invalid_ntf
function GCMD.invalid_ntf(idx,type)
	local cmd = 'invalid_ntf'
	for i,u in pairs(___players) do
		if(idx==i) then
			___data_ntf(u.agent,cmd,{chair=idx,type=type})
			break
		end
	end	
end
-----------------------
-------------------------------------------
--getcard_ntf
function GCMD.getcard_ntf(idx,pai)
	local cmd = 'getcard_ntf'
	for i,u in pairs(___players) do
		local _agent = u.agent
		if(_agent) then
			if(idx==i) then
				___data_ntf(_agent,cmd,{chair = i,card=pai})
			else
				___data_ntf(_agent,cmd,{chair = i,card=0})
			end
		end
	end
end
-------------------------------------------
-------------------------------------------
-------------------------------------------
--cmd from agent client
function GCMD.dataup(agent,data)
	local findagent
	for i,u in pairs(___players) do
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
		if(rcmd) then
			local rdata = ___sp:encode(rcmd, result)
			return tp,rcmd,rdata
		end
	end
end

-------------------------------------------
-------------------------------------------
--logic
___optmap[2]={
	{2},
	{1},
}
___optmap[3]={
	{2,3},
	{3,1},
	{1,2},
}
___optmap[4]={
	{2,3,4},
	{3,4,1},
	{4,1,2},
	{1,2,3}
}

___ckhas = function(cards,pai)
	if(not cards) then
		return
	end
	for _,cd in pairs(cards) do
		if(pai==cd) then
			return true
		end
	end
end
___rmcard = function(cards,pai,n)
	local ct = n or 1
	local newcards={}
	for _,cd in ipairs(cards) do
		if(pai==cd and ct>0) then
			ct = ct - 1
		else
			table.insert(newcards,cd)
		end
	end
	return newcards
end
-- check is hu
-- true false
___ckhu = function(cards,pai,zimo)

	return ___mjcmd.hu(cards,pai,zimo)
end

-- .Ting{
--     card 0 : integer
--     hu 1 : *integer
--     score 2 :*integer
-- }
-- check is ting
-- return *Ting
___ckting = function(cards)

	---{ {out,hu},...}
	local ting = ___mjcmd.ting(cards)
	local r = {}
	if(ting) then
		for _,v in ipairs(ting) do
			r[v[1]] = r[v[1]] or {}
			table.insert(r[v[1]],v[2])
		end
		local rr = {}
		for id,v in pairs(r) do
			table.insert(rr,{card=id,hu=v})
		end
		if(#rr>0) then
			return rr
		end
	end
end
--cpg
--{opt,opt}
___ckcpg = function(cards,pai)

	return ___mjlib.check_cpg(cards,pai)
end
--gang
--{pai,pai}
___ckgangan = function(cards)

	return ___mjlib.check_gang(cards)
end
--xugang
--{pai,pai}
--需要全面检查
___ckgangxu = function(opts,card)
	for i,v in ipairs(opts) do
		if(v.opt==___OPT_TP_PENG and v.card==card) then
			return {v.card}
		end
	end
end

--开局发牌
___fapai = function()
	___cards  = ___mjlib.gencards()

	local n = ___playernum()

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
--发一张牌
___onepai = function(optidx)
	skynet.error('___onepai ', optidx)
	local pai = ___cards[___cardidx]
	___cardidx = ___cardidx + 1
	local t = ___gamestate.cards[optidx].hand
	table.insert(t,pai)
	return pai
end
--操作数据处理
___do_opt = function(optidx,from,type,card)
	local cards = ___gamestate.cards[optidx]
	local hand =  cards.hand
	local opt = cards.opt
	local out = cards.out

	local cards_from = ___gamestate.cards[from]
	local hand_from =  cards_from.hand
	local opt_from = cards_from.opt
	local out_from = cards_from.out
	if(type==___OPT_TP_CHU or type==___OPT_TP_TING) then
		cards.hand = ___rmcard(hand,card,1)
		table.insert(out,card)
		if(type==___OPT_TP_TING) then
			cards.ting = true
		end
	elseif(type==___OPT_TP_PENG) then
		cards_from.out = ___rmcard(out_from,card,1)
		cards.hand = ___rmcard(hand,card,2)
		local t = {
			opt = ___OPT_TP_PENG,
			card = card,
			from = from,
		}
		table.insert(opt,t)
	elseif(type==___OPT_TP_GANG_1) then
		cards_from.out = ___rmcard(out_from,card,1)
		cards.hand = ___rmcard(hand,card,3)
		local t = {
			opt = ___OPT_TP_GANG_1,
			card = card,
			from = from,
		}
		table.insert(opt,t)
	elseif(type==___OPT_TP_GANG_2) then
		cards.hand = ___rmcard(hand,card,1)
		for _,v in ipairs(opt) do
			if(v.opt==___OPT_TP_PENG and v.card == card) then
				v.opt = ___OPT_TP_GANG_2
				break
			end
		end
	elseif(type==___OPT_TP_GANG_3) then
		cards.hand = ___rmcard(hand,card,4)
		local t = {
			opt = ___OPT_TP_GANG_3,
			card = card,
			from = from,
		}
		table.insert(opt,t)
	elseif(type==___OPT_TP_HU) then
		cards.hu = card
	elseif(type==___OPT_TP_CHI_L) then
		cards_from.out = ___rmcard(out_from,card,1)
		cards.hand = ___rmcard(cards.hand,card+1,1)
		cards.hand = ___rmcard(cards.hand,card+2,1)
		local t = {
			opt = ___OPT_TP_CHI_L,
			card = card,
			from = from,
		}
		table.insert(opt,t)
	elseif(type==___OPT_TP_CHI_M) then
		cards_from.out = ___rmcard(out_from,card,1)
		cards.hand = ___rmcard(cards.hand,card-1,1)
		cards.hand = ___rmcard(cards.hand,card+1,1)
		local t = {
			opt = ___OPT_TP_CHI_M,
			card = card,
			from = from,
		}
		table.insert(opt,t)
	elseif(type==___OPT_TP_CHI_R) then
		cards_from.out = ___rmcard(out_from,card,1)
		cards.hand = ___rmcard(cards.hand,card-1,1)
		cards.hand = ___rmcard(cards.hand,card-2,1)
		local t = {
			opt = ___OPT_TP_CHI_R,
			card = card,
			from = from,
		}
		table.insert(opt,t)
	end	
end

___waitready = function()
	local nn = ___playernum()
	local m = ___args.renshu
	___setst(___ST_WAIT_READY)
	skynet.error('___waitready begin')
	while(true) do
		-- local ok,r = ___optget(___ST_WAIT_READY)		
		local n = 0
		for i,u in pairs(___players) do
			if(u.agent and u.info.ready) then
				n = n + 1
			end
		end
		if(m>0 and n<m) then
			skynet.wait()
		else
			skynet.error('___waitready to start')
			break
		end
		skynet.error('___waitready step')
	end
	skynet.error('___waitready end')
	___setst(___ST_FAPAI)
	___fapai()
	___gamestate.state = 1
	GCMD.gamestart_ntf(___gameinfo)
end

--打牌逻辑
----r 用户操作数组
----abc 用户顺序
----hh,gg,p,gg 用户可选操作
----return isopttype,isoptidx
--操作分类
--false 不需要操作
-- -1 等待操作
-- 0 过
-- 1 确认
___waitcpg = function(r,abc,hh,gg,pp,cc)

	for idx,opt in pairs(r) do
		if(hh[idx] and hh[idx]<0) then
			hh[idx] = (opt==___OPT_TP_HU) and 1 or 0
		end
		if(gg[idx] and gg[idx]<0) then
			gg[idx] = (opt==___OPT_TP_GANG_1) and 1 or 0
		end
		if(pp[idx] and pp[idx]<0) then
			pp[idx] = (opt==___OPT_TP_PENG) and 1 or 0
		end
		if(cc[idx] and cc[idx]<0) then
			cc[idx] = (opt>=___OPT_TP_CHI_L and opt<=___OPT_TP_CHI_R) and opt or 0
		end
	end
	--按照优先级次序判断
	local isoptidx = 0
	local isopttype = -1
	local ishh = false -- false,-1,0,1
	local isgg = false -- false,-1,0,1
	local ispp = false -- false,-1,0,1
	local iscc = false -- false,-1,0,1
	--这里用循环好控制，只一次
	--汇总玩家所有操作，确定谁操作
	--hu-gang-peng-chi顺序
	while(true) do
		--hu
		for _,idx in ipairs(abc) do
			if(hh[idx]) then
				if(hh[idx]<0) then
					ishh = -1
					break
				elseif(hh[idx]>0) then
					ishh = 1
					isoptidx = idx
					break
				end	
			end
		end
		if(ishh) then
			if(ishh==1) then
				isopttype = ___OPT_TP_HU
			end
			break
		end
		--gang
		for _,idx in ipairs(abc) do
			if(gg[idx]) then
				if(gg[idx]<0) then
					isgg = -1
					break
				elseif(gg[idx]>0) then
					isgg = 1
					isoptidx = idx
					break
				end	
			end
		end
		--有杠有碰只可能一家，按理说 没选杠时不应中断，应该继续判断有没有选碰
		--但是上面代码做了处理，只要选择一种操作，其他操作都pass掉，
		--即：假如选择碰，则设置pp=1 且 gg=0 isgg=false ，从而会继续判断碰。
		if(isgg) then
			if(isgg==1) then
				isopttype = ___OPT_TP_GANG_1
			end
			break
		end
		--peng
		for _,idx in ipairs(abc) do
			if(pp[idx]) then
				if(pp[idx]<0) then
					ispp = -1
					break
				elseif(pp[idx]>0) then
					ispp = 1
					isoptidx = idx
					break
				end	
			end
		end
		if(ispp) then
			if(ispp==1) then
				isopttype = ___OPT_TP_PENG
			end
			break
		end
		
		--chi
		for _,idx in ipairs(abc) do
			if(cc[idx]) then
				if(cc[idx]<0) then
					iscc = -1
					break
				elseif(cc[idx]>0) then
					iscc = cc[idx]
					isoptidx = idx
					break
				end	
			end
		end
		if(iscc) then
			if(iscc>0) then
				isopttype = iscc
			end
			break
		end

		break
	end
	return isopttype,isoptidx
end

--pai接牌
------不为空，先计算胡杠 再计算听出   自己起牌 和 接明杠
------为空，不计算胡杠 只计算听出  吃碰杠
--return 
-- {
-- 	hu,
-- 	huang,
-- 	outcard,
-- }
--计算起牌后操作
___step_self = function(pai)
		------------------先判断自己能否胡杠操作后循环判断------------------
		local cards = ___gamestate.cards[___optidx]
		local handcards =  cards.hand
		local optcards = cards.opt
		while(pai) do
			local hu = false
			local ting = false
			if(cards.ting) then
				hu = ___ckhu(handcards,pai,2)			
			end
			local xg = ___ckgangxu(optcards,pai)
			local ag = ___ckgangan(handcards)
			if not (hu or xg or ag) then
				break
			else
				local pdata = {}
				if(hu) then pdata.hu = true end
				if(xg) then pdata.gangxu = xg end
				if(ag) then pdata.gangan = ag end
				GCMD.opt_tip_self(___optidx,pdata)

				--wait...
				___setst(___ST_WAIT_HUGANG)
				___steprecover = function(idx)
					if(idx==___optidx) then
						GCMD.opt_tip_self(___optidx,pdata)
					end
				end
				while(true) do
					skynet.wait()
					local ok,data = ___optget(___ST_WAIT_HUGANG,___optidx)
					if(not ok) then
					else
						-- {hu = false, gang2 = false, gang3 = false, pass = true}
						if(data.hu) then
							return {hu = true}
						elseif(data.pass) then
							break
						else
							if(data.gang2) then
								if(___ckhas(xg,data.gang2)) then
									___do_opt(___optidx,___optidx,___OPT_TP_GANG_2,data.gang2)
									GCMD.gang_ntf(___optidx,___OPT_TP_GANG_2,___optidx,data.gang2)
								else
									--无效
									GCMD.invalid_ntf(___optidx)
								end
							elseif(data.gang3) then	
								if(___ckhas(ag,data.gang3)) then
									___do_opt(___optidx,___optidx,___OPT_TP_GANG_3,data.gang3)
									GCMD.gang_ntf(___optidx,___OPT_TP_GANG_3,___optidx,data.gang3)
								else
									--无效
									GCMD.invalid_ntf(___optidx)
								end
							end
							pai = ___onepai(___optidx)
							if(not pai) then
								--荒
								return {huang = true}
							else
								--通知发牌
								GCMD.getcard_ntf(___optidx,pai)
							end
						end
						break
					end	
				end
				___steprecover = ___emptyfunc
			end
		end
		------------------再判断听牌 并 出牌------------------
		local outcard
		local ting
		if(not cards.ting) then
			ting = ___ckting(handcards)
		end
		if(ting and #ting>0) then
			GCMD.ting_tip(___optidx,ting)
			--wait...
			___setst(___ST_WAIT_TING)
			___steprecover = function(idx)
				if(idx==___optidx) then
					GCMD.ting_tip(___optidx,ting)
				end
			end
			while(true) do
				skynet.wait()
				local ok,isting,chupai = ___optget(___ST_WAIT_TING,___optidx)
				if(ok) then
					if(isting) then
						--判断是否有效
						--有效听牌修改听牌状态
						local valid = false
						for _,v in ipairs(ting) do
							if(v.card == chupai) then
								valid = true
								break
							end
						end	
						if(valid) then
							___do_opt(___optidx,___optidx,___OPT_TP_TING,chupai)
							GCMD.chu_ntf(___optidx,chupai)
							GCMD.ting_ntf(___optidx,chupai)
							outcard = chupai
							break
						else
							--无效则
							GCMD.invalid_ntf(___optidx)
						end
					else
						--修改玩家出牌表
						--出牌通告
						___do_opt(___optidx,___optidx,___OPT_TP_CHU,chupai)
						GCMD.chu_ntf(___optidx,chupai)
						outcard = chupai
						break
					end
				end
			end
			___steprecover = ___emptyfunc
		else
			--提示出牌
			GCMD.chu_tip(___optidx)
			--wait...
			___setst(___ST_WAIT_CHU)
			___steprecover = function(idx)
				if(idx==___optidx) then
					GCMD.chu_tip(___optidx)
				end
			end
			while(true) do
				skynet.wait()
				local ok,chupai = ___optget(___ST_WAIT_CHU,___optidx)
				if(ok) then
					if(chupai) then
						--修改玩家出牌表
						--出牌通告
						-- table.insert(cards.out,chupai)
						___do_opt(___optidx,___optidx,___OPT_TP_CHU,chupai)
						GCMD.chu_ntf(___optidx,chupai)
						outcard = chupai
						break
					end
				end
			end
			___steprecover = ___emptyfunc
		end
		return {outcard=outcard}
end

___step = function()

	___waitready()

	local nn = ___playernum()
	--庄家
	___optidx =  ___gamestate.banker
	while(true) do
		--发牌
		local pai = ___onepai(___optidx)
		if(not pai) then
			--荒
			GCMD.huang_ntf()
			___stepover(false,true)
			return
		end
		--通知发牌
		GCMD.getcard_ntf(___optidx,pai)
		local cards = ___gamestate.cards[___optidx]
		local handcards =  cards.hand
		local optcards = cards.opt
		local outcard
		------------------先判断自己能否杠胡听-提示-并等待出牌------------------
		local data = ___step_self(pai)
		if(data.hu) then
			GCMD.hu_ntf(___optidx,___optidx,pai,true)
			___stepover(___optidx,false)
			return
		elseif(data.huang) then
			GCMD.huang_ntf()
			___stepover(false,true)
			return
		else
			outcard = data.outcard
		end
		------------------自己已经出牌，再计算别人能否胡吃碰杠------------------
		------------------别人吃碰杠以后循环处理------------------
		--1,2-3-4,5,6-7-8,9,10 出 左吃-中吃-右吃 碰 明杠-续杠-暗杠 听 胡
		-- if(outcard) then
		-- 循环处理直到无人吃碰杠
		while(outcard) do
			local r = {}
			local abc = ___optmap[nn][___optidx]
			--获取每个人可用操作
			local hasopt = false
			for _,idx in ipairs(abc) do
				r[idx] = {}
				local cards = ___gamestate.cards[idx]
				local hand = cards.hand
				if(cards.ting) then
					local canhu = ___ckhu(hand,outcard,1)
					if(canhu) then
						table.insert(r[idx],___OPT_TP_HU)
						hasopt = true
					end
				else
					local cpg = ___ckcpg(hand,outcard)
					if(cpg) then
						r[idx] = cpg
						hasopt = true
					end
				end
			end
			if(not hasopt) then
				--没人能吃碰杠--下一家
				___optidx = abc[1]
				break
			else	
				--操作分类
				--false 不需要操作
				-- -1 等待操作
				-- 0 过
				-- 1 确认
				local hh={false,false,false,false}
				local gg={false,false,false,false}
				local pp={false,false,false,false}
				local cc={false,false,false,false}
				for idx,t in ipairs(r) do
					for _, op in ipairs(t) do
						if(op==___OPT_TP_HU) then
							hh[idx] = -1
						elseif(op==___OPT_TP_GANG_1) then
							gg[idx] = -1
						elseif(op==___OPT_TP_PENG) then
							pp[idx] = -1
						elseif(op>=___OPT_TP_CHI_L and op<=___OPT_TP_CHI_R) then
							cc[idx] = -1		
						end
					end
				end
				--发送操作提示
				for idx,t in ipairs(r) do
					if(#t>0) then
						local data = {
							chair = idx,
							from = ___optidx,
							card = outcard,
							types = t,
						}
						GCMD.opt_tip(idx,data)
					end
				end
				--清除操作堆栈
				___optclean()
				--等待回复
				___setst(___ST_WAIT_CPG)
				___steprecover = function(idx)
					local t = r[idx]
					if(t and #t>0) then
						local data = {
							chair = idx,
							from = ___optidx,
							card = outcard,
							types = t,
						}
						GCMD.opt_tip(idx,data)
					end
				end
				while(true) do
					--每次取出来一个处理
					--发送提示胡吃碰杠 -----------记录状态重发
					skynet.wait()
					--取所有的操作汇总处理
					local ok,r = ___optgetcpg()
					if(not ok) then
					else	
						local isopttype = -1
						local isoptidx = 0
						isopttype, isoptidx = ___waitcpg(r,abc,hh,gg,pp,cc)
						--确定操作
						if(isopttype<0 or isoptidx<0) then
							--无法确定操作--循环等待
						else
							local pai
							if(isopttype==___OPT_TP_HU) then
								___do_opt(isoptidx,___optidx,___OPT_TP_HU,outcard)
								GCMD.hu_ntf(isoptidx,___optidx,pai,false)
								___stepover(isoptidx,true)
								return
							elseif(isopttype==___OPT_TP_GANG_1) then
								___do_opt(isoptidx,___optidx,isopttype,outcard)
								GCMD.gang_ntf(isoptidx,isopttype,___optidx,outcard)
								___optidx = isoptidx
								local pai = ___onepai(___optidx)
								if(not pai) then
									--荒
									GCMD.huang_ntf()
									___stepover(false,true)
									return
								end
								--通知发牌
								GCMD.getcard_ntf(___optidx,pai)
								--发牌
							elseif(isopttype==___OPT_TP_PENG) then
								___do_opt(isoptidx,___optidx,isopttype,outcard)
								GCMD.peng_ntf(isoptidx,isopttype,___optidx,outcard)
							elseif(isopttype>=___OPT_TP_CHI_L and isopttype<=___OPT_TP_CHI_R) then
								___do_opt(isoptidx,___optidx,isopttype,outcard)
								GCMD.chi_ntf(isoptidx,isopttype,___optidx,outcard)
							end
							local oldoptidx = ___optidx
							___optidx = isoptidx							
							local data = ___step_self(pai)
							if(data.hu) then
								GCMD.hu_ntf(___optidx,___optidx,pai,true)
								___stepover(___optidx,false)
								return
							elseif(data.huang) then
								GCMD.huang_ntf()
								___stepover(false,true)
								return
							else
								outcard = data.outcard
							end
							--这一轮吃碰杠结束继续判断
							break
						end
					end
				end
				___steprecover = ___emptyfunc
			end
		end

		___setst(___ST_FAPAI)

		--堆栈空-开始下一轮发牌
		return 1
	end
end
___setst = function(st)
	___step_st = st
	___step_info = debug.getinfo(2,'nSl')
end
--开始大牌
___start = function()
	___costep = skynet.fork(___step)
end
__restart = function()
	___costep = nil
	___costep = skynet.fork(___step)
end
--结局
___stepover = function(hu,huang)
	--重置恢复函数
	___steprecover = ___emptyfunc
	skynet.error('___stepover',hu,huang)
	__restart()
end
--其他玩家吃碰杠胡过
local ___cpgmap={}
___cpgmap[___OPT_TP_PASS]=1
___cpgmap[___OPT_TP_HU]=1
___cpgmap[___OPT_TP_CHI_L]=1
___cpgmap[___OPT_TP_CHI_M]=1
___cpgmap[___OPT_TP_CHI_R]=1
___cpgmap[___OPT_TP_PENG]=1
___cpgmap[___OPT_TP_GANG_1]=1
___cpgmap[___OPT_TP_GANG_2]=1
___cpgmap[___OPT_TP_GANG_3]=1
--只判断胡目前未使用
local ___humap={}
___humap[___OPT_TP_PASS]=1
___humap[___OPT_TP_HU]=1
--只判断出牌
local ___chumap={}
___chumap[___OPT_TP_CHU]=1
--判断出牌加是否听
local ___tingmap={}
___tingmap[___OPT_TP_TING]=1
--自己起牌后判断胡和杠和过
local ___hgmap={}
___hgmap[___OPT_TP_PASS]=1
___hgmap[___OPT_TP_HU]=1
___hgmap[___OPT_TP_GANG_2]=1
___hgmap[___OPT_TP_GANG_3]=1

local ___rdmap={}
___rdmap[___OPT_TP_READY]=1

--根据状态过滤接受到的信息
local ___filtermap = {
	[___ST_WAIT_READY] = ___rdmap,
	[___ST_WAIT_CHU] = ___chumap,
	[___ST_WAIT_TING] = ___tingmap,
	[___ST_WAIT_HU] = ___humap,
	[___ST_WAIT_CPG] = ___cpgmap,
	[___ST_WAIT_HUGANG] = ___hgmap,
}
--记录胡吃碰杠请求-过滤
___optrsp_add = function(opt,idx,data)
	--当前操作者___optidx 和 idx比较
	--决定是否接受
	local mapmap = ___filtermap[___step_st]
	if(not mapmap) then
		return
	end
	if(___optidx==idx and mapmap[opt]) then
		table.insert(___optrsp,{
			opt = opt,
			idx = idx,
			data = data
		})
	end		
	if(___costep) then
		skynet.wakeup(___costep)
	end
end
--获取操作记录
--type 类型
--idx获取指定的玩家，nil获取所有的
--noclean 不自动清除堆栈
___optget = function(type,idx,noclean)
	local map = ___filtermap[type]
	if(not map) then	
	 	assert(false,'___optget type=='..(type or 'nil'))	
	end
	local n = #___optrsp
	local r
	for i=n,1,-1 do
		local t = ___optrsp[i]
		if(map[t.opt] and idx==t.idx) then
			r = t
		end
	end
	if( not noclean) then
		___optclean()
	end
	if(not r) then
		return false
	end
	--根据协议返回
	local opt = r.opt
	if(type == ___ST_WAIT_CHU) then
		return true,r.card
	elseif(type == ___ST_WAIT_HU) then
		if(___OPT_TP_CHU == opt) then
			return true, false, r.card
		elseif(___OPT_TP_HU == opt) then
			return true, true, 0
		end
	elseif(type ==___ST_WAIT_TING) then
		return true,r.isting,r.card
	elseif(type ==___ST_WAIT_HUGANG) then
		if(___OPT_TP_PASS == opt) then
			return true, {hu = false, gang2 = false, gang3 = false, pass = true }
		elseif(___OPT_TP_HU == opt) then
			return true, {hu = true, gang2 = false, gang3 = false, pass = false }
		elseif(___OPT_TP_GANG_2 == opt) then
			return true, {hu = false, gang2 = data.card, gang3 = false, pass = false }	
		elseif(___OPT_TP_GANG_3 == opt) then
			return true, {hu = false, gang2 = false, gang3 = data.card, pass = false }						
		end
	elseif(type ==___ST_WAIT_READY) then
		if(___OPT_TP_READY == opt) then
			return true, {ready = true}
		end
	end
	return false
end
--获取胡吃碰刚记录
--{idx=opt}
___optgetcpg = function()
	local n = #___optrsp
	local r = {}
	for i=1,n do
		local t = ___optrsp[i]
		if(___cpgmap[t.opt]) then
			r[t.idx] = t.opt
		end
	end
	___optclean()
	if(#r>0) then
		return true,r
	end
	return false
end
--清除
___optclean = function()
	___optrsp={}
end

---
----一局流程完成
----大框架完成k
----数据操作处理
----待完成
--和牌和结束以后结算数据和流程处理
--数据剔除处理，别人的数据剔除后再发
-------------------------------------------
--测试到发牌出牌
-------------------------------------------
-------------------------------------------
skynet.start(function()
	
	-- skynet.fork(test)
	__init()
	skynet.info_func(function()
		return {st = ___step_st, line = ___step_info.currentline, func = ___step_info.name,roomid=___roomid,args = ___argstr}
	end)
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