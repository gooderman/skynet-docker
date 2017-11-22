local skynet = require "skynet"
local util = require 'util'

local mj = {}
------------------------------------------------------------
------------------------------------------------------------
-- 0 --空牌
-- 1-9 --万
-- 10-18 --条
-- 19-27 --筒
-- 28-34 --东南西北中发白
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
	local b = {
		1,10,100,
		1000,10000,100000,
		1000000,10000000,100000000
	}
	local r={0,0,0,0}
	local rc = {0,0,0,0}
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
------------------------
local function gencards()
	local r = {}
	for i=1,4 do
		for j=1,34 do
			table.insert(r,j)
		end
	end
	math.randomseed(os.time())
	local rr = {}
	local ct = #r
	while ct>0 do
		local i = math.random(1,ct)
		rr[#rr+1] = r[i]
		ct = ct - 1 
		table.remove(r,i)
	end
	return rr
end
------------------------
local function test()
	local t={
		1,2,3,4,5,
		10,11,15,
		19,20,21,
		28,29,30
	}
	local tb = tongji(t)
	util.dump(tb)
	local tb = gencards()
	util.dump(tb)
end
------------------------
--解析牌
mj.parse = parse
mj.combine = combine
--统计分类
mj.tongji = tongji
mj.gencards = gencards
--插入
mj.sub = sub
mj.add = add

-- test()
return mj


