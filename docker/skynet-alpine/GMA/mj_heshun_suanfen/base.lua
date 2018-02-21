local skynet = require "skynet"
local util = require 'util'

local mj = {}
------------------------------------------------------------
------------------------------------------------------------
-- 0 --空牌
-- 1-9 --万
-- 10-18 --条
-- 19-27 --筒
-- 28-29 --东南
-- 30,31 --西北
-- 32,33,34 --中发白
local map=
{
	1,2,3,4,5,6,7,8,9,
	1,2,3,4,5,6,7,8,9,
	1,2,3,4,5,6,7,8,9,
	1,2,
	1,2,
	1,2,3
}
local map_t=
{
	1,1,1,1,1,1,1,1,1,
	2,2,2,2,2,2,2,2,2,
	3,3,3,3,3,3,3,3,3,
	4,4,
	5,5,
	6,6,6
}
local map_id=
{
	1-1,
	10-1,
	19-1,
	28-1,
	30-1,
	32-1
}
map_id[0]=0
local function parse(id)
	if(id<1 or id>34) then
		return 0,0
	end	
	return map_t[id],map[id]
end
local function combine(tp,id)
	return map_id[tp]+id
end
local function tongji(tb)
	local b = {
		1,10,100,
		1000,10000,100000,
		1000000,10000000,100000000
	}
	local r={0,0,0,0,0,0}
	local rc = {0,0,0,0,0,0}
	-- if(#tb>=2) then
	-- 	table.sort(tb,function(a,b)
	-- 		return a<b
	-- 	end)
	-- end
	for _,id in ipairs(tb) do
		local tp,idx = parse(id)
		if(tp>0 and idx) then
			r[tp] = r[tp] + b[idx]
			rc[tp] = rc[tp] + 1
		end
	end
	return r,rc
end

local function sub(t,id)
	for i,v in ipairs(t) do
		if(id==v) then
			table.remove(t,i)
			return true
		end
	end
end
local function add(t,id)
	table.insert(t,id)
end

local function test()
	local t={
		1,2,3,4,5,
		10,11,15,
		19,20,21,
		28,29,30
	}
	local tb = tongji(t)
	util.dump(tb)
end
------------------------
------------------------
--解析牌
mj.parse = parse
mj.combine = combine
--统计分类
mj.tongji = tongji
--插入
mj.sub = sub
mj.add = add
return mj


