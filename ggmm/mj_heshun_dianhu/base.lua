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
local score_map =
{
	1,2,3,4,5,6,7,8,9,
	1,2,3,4,5,6,7,8,9,
	1,2,3,4,5,6,7,8,9,
	10,10,10,10,10,10,10
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

local function tongji2(tb)
	local r = {}
	for _,id in ipairs(tb) do
		local ct = r[id] or 0
		r[id] = ct+1
	end
	return r
end
--0,1,2-3-4,5,6-7-8,9,10 出 左吃-中吃-右吃 碰 明杠-续杠-暗杠 听 胡
local function check_cpg(tb,pai)
	local rr = {}
	local r = tongji2(tb)
	if r[pai] then
		if(r[pai]==3) then
			rr[#rr+1] = 6
			rr[#rr+1] = 5
		elseif(r[pai]==2) then
			rr[#rr+1] = 5
		end
	end
	if(pai>27) then
		
	else
		--left chi
		local tp,idx = parse(pai)
		if(idx>=1 and idx<=7) then
			local a = r[pai+1]
			local b = r[pai+2]
			if(a and b) then
				rr[#rr+1] = 2
			end
		end	
		--mid chi
		if(idx>=2 and idx<=8) then	
			local a = r[pai-1]
			local b = r[pai+1]
			if(a and b) then
				rr[#rr+1] = 3
			end
		end
		--right chi
		if(idx>=3 and idx<=9) then
			local a = r[pai-2]
			local b = r[pai-1]
			if(a and b) then
				rr[#rr+1] = 4
			end
		end

	end
	if(#rr>0) then
		return rr
	end
end
--1,2-3-4,5,6-7-8,9,10 出 左吃-中吃-右吃 碰 明杠-续杠-暗杠 听 胡
local function check_gang(tb)
	local rr = {}
	local r = tongji2(tb)
	for id,ct in pairs(r) do
		if(ct==4) then
			rr[#rr+1] = id
		end
	end
	if(#rr>0) then
		return rr
	end
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
local function score(id,zimo)
	local sc = score_map[id] or 0
	if(zimo) then
		sc = sc * 2
	end
	return sc
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
mj.check_cpg = check_cpg
mj.check_gang = check_gang
mj.score = score
--插入
mj.sub = sub
mj.add = add

-- test()
return mj


