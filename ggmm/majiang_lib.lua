local skynet = require "skynet"
local util = require 'util'

local mj = {}
------------------------------------------------------------
------------------------------------------------------------
-- 0 --空牌
-- 1-9 --万
-- 10-18 --条
-- 19-27 --筒
-- 28-35 --东南西北中发白
local map=
{
	1,2,3,4,5,6,7,8,9,
	1,2,3,4,5,6,7,8,9,
	1,2,3,4,5,6,7,8,9,
	1,2,3,4,5,6,7
}
local function parse(id)
	if(id<1 or id>35) then
		return 0,0
	end	
	return math.ceil(id/9),map[id]
	-- if(id>=1 and id<=9) then
	-- 	return 1,id
	-- elseif(id>=10 and id<=18) then
	-- 	return 2,id-9
	-- elseif(id>=19 and id<=27) then
	-- 	return 3,id-18
	-- elseif(id>=28 and id<=35) then
	-- 	return 4,id-27
	-- else
	-- 	return 0,0	
	-- end
end
local function combine(tp,id)
	return (tp-1)*9+id
end
local function tongji(tb)
	local r={}
	r[0]={}
	r[1]={}
	r[2]={}
	r[3]={}
	r[4]={}
	if(#tb>=2) then
		table.sort(tb,function(a,b)
			return a<b
		end)
	end
	for _,id in ipairs(tb) do
		local tp,idx = parse(id)
		if(tp and idx) then
			table.insert(r[tp],idx)
		end
	end
	return r,{#r[1],#r[2],#r[3],#r[4]}
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
		skynet.error(tp,tb2str(tt))
	end
end
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
local function sub(t,tp,id)
	local id = combine(tp,id)
	for i,v in ipairs(t) do
		if(id==v) then
			table.remove(t,i)
			return true
		end
	end
end
local function add(t,tp,id)
	local id = combine(tp,id)
	table.insert(t,id)
end
------------------------
--解析牌
mj.parse = parse
mj.combine = combine
--统计分类
mj.tongji = tongji
--转换字窜
mj.tb2str = tb2str
--插入
mj.check = check
mj.sub = sub
mj.add = add
return mj


