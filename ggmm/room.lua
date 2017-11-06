local skynet = require "skynet"
local util = require 'util'

local majiang
------------------------------------------------------------
------------------------------------------------------------
-- 0 --空牌
-- 1-9 --万
-- 10-18 --条
-- 19-27 --筒
-- 28-35 --东南西北中发白
local function parse(id)
	if(id>=1 and id<=9) then
		return 1,id
	elseif(id>=10 and id<=18) then
		return 2,id-9
	elseif(id>=19 and id<=27) then
		return 3,id-18
	elseif(id>=28 and id<=35) then
		return 4,id-27
	else
		return 0,0	
	end
end
local function tongji(tb)
	local r={}
	r[0]={}
	r[1]={}
	r[2]={}
	r[3]={}
	r[4]={}
	for _,id in ipairs(tb) do
		local tp,idx = parse(id)
		if(tp and idx) then
			table.insert(r[tp],idx)
		end
	end
	for i=0,4 do 
		if(#r[i]>=2) then
			table.sort(r[i],function(a,b)
				return a<b
			end)
		end
	end
	return r
end
local function tb2str(tb)
	local s=''
	for _,id in ipairs(tb) do
		s=s..id
	end
	return s
end
local function test()
	local t={
		1,2,3,4,5,
		10,11,15,
		19,20,21,
		28,29,30
	}
	local tb = tongji(t)
	for tp,tt in pairs(tb) do
		print(tp,tb2str(tt))
	end
end
------------------------
-- 	1(1)
-- 2(-1,1)
-- 3(-1)
-- 	4(1,2)
-- 5(-1,1)
-- 6(-1)
-- 	7(1,2)
-- 8(-1,1)
-- 9(-1)
-- 	10(1,2)
-- 11(-1,1)
-- 12(-1)
-- 	13(1,2)
-- 14(-1,1)
------------------------
local function check(t,id)
	local tp,idx = parse(id)
	table.insert(t[tp],idx)
	if(#t[tp]>2) then
		table.sort(t[tp],function(a,b)
			return a<b
		end)
	end
end
------------------------
local function loop()
	test()
	local ttt ={
		"1",
		--2
		"11",
		"23",
		--3
		"123",
		--4
		"1122",
		"1234",
		--5
		"11234",
		"23456",
		--6
		"123456",
		--7
		"1234567",
		"1122345",
		"1357988"
		--8
	}
	while true do
		local ta = skynet.now()
		local r = skynet.call(majiang,'lua','get',1,ttt)
		local tb = skynet.now()
		skynet.error("call majiang 1 tm =",(tb-ta)*10)
		util.dump(r,'call majiang 1')
		local r = skynet.call(majiang,'lua','get',1,'1234567')
		util.dump(r,'call majiang 2')
		skynet.sleep(5000)
		-- skynet.send(majiang,'lua','test')
		-- skynet.sleep(100)
	end
end
------------------------------------------------------------
------------------------------------------------------------
local owner = {}
local agents = {}
local info = {}
local CMD = {}
--create init 
function CMD.init(owner,args)
end
--user join
function CMD.join(userinfo)
end
--user quit or dismiss by owner
function CMD.quit(userid)
end
--
function CMD.enter(userid)
end
--
function CMD.exit(userid)
end

local PCMD = {}

function PCMD.chupai()
end
function PCMD.chi()
end
function PCMD.peng()
end
function PCMD.gang()
end
function PCMD.ting()
end
function PCMD.hu()
end

skynet.start(function()
	
	majiang = skynet.queryservice('majiang')
	
	-- skynet.fork(loop)

	skynet.dispatch('lua',function(session, source, cmd,...)
		if(CMD[cmd]) then
			local ff = CMD[cmd]
			if(type(ff)=='function') then
				return skynet.retpack(ff(...))
			end
		elseif(PCMD[cmd]) then
			local ff = PCMD[cmd]
			if(type(ff)=='function') then
				return skynet.retpack(ff(...))
			end
		end
	end)
end)




