local util = require("util")
local dump = util.dump

local function sort(s)
    local n = string.len(s)
    local tb = {}
    for i=1,n do
        table.insert(tb,string.sub(s,i,i))
    end
    table.sort(tb, function(a,b) return string.byte(a)<string.byte(b) end)
    local r = ""
    for i=1,n do
        r = r..tb[i]
    end
    return r
end

local function ck4(s)
    local n = string.len(s)
    local tb = {}
    for i=1,n do
        table.insert(tb,string.sub(s,i,i))
    end
    table.sort(tb, function(a,b) return string.byte(a)<string.byte(b) end)
    local r = ""
    for i=1,n do
        r = r..tb[i]
    end
    local cktb={ '111(1+)','222(2+)','333(3+)','444(4+)','555(5+)','666(6+)','777(7+)','888(8+)','999(9+)','aaa(a+)','bbb(b+)'}
    for _,v in ipairs(cktb) do
        if(string.find(r,v)) then
            return false,v
        end
    end
    return true,r
end

local function ck5(s)
    local n = string.len(s)
    local tb = {}
    for i=1,n do
        table.insert(tb,string.sub(s,i,i))
    end
    table.sort(tb, function(a,b) return string.byte(a)<string.byte(b) end)
    local r = ""
    for i=1,n do
        r = r..tb[i]
    end
    local cktb={ '1111(1+)','2222(2+)','3333(3+)','4444(4+)','5555(5+)','6666(6+)','7777(7+)','8888(8+)','9999(9+)','aaaa(a+)','bbbb(b+)'}
    for _,v in ipairs(cktb) do
        if(string.find(r,v)) then
            return false,v
        end
    end
    return true,r
end

local ck = ck5

-- print("function ck",ck('386222223'))

local function filter(rr)
    return rr
end

local t1 = {
    1,2,3,4,5,6,7,8,9
}
local t2 = {
    11,22,33,44,55,66,77,88,99
}
local t3 = {
    111,222,333,444,555,666,777,888,999,
    123,234,345,456,567,678,789
}

local function f_repeat(r)
    local rr = {}
    local nn = 0
    for k,v in pairs(r) do
        local f,rs =  ck(k)
        if(f) then
            if(not rr[rs]) then
                rr[rs] = v
                nn = nn + 1
            end
        end
    end
    return rr,nn
end

__t2={}
__t3={}
__t5={}
__t6={}
__t8={}
__t9={}
__t11={}
__t12={}
__t14={}
__t15={}
__t17={}
__t18={}
__t20={}

local function f2()
    local r={}
    for _,k1 in pairs(t2) do
        r[tostring(k1)]=1
    end
    -- dump(r,"22-22")
    return filter(r)
end

local function f3()
    local r={}
    for _,k1 in pairs(t3) do
        r[tostring(k1)]=0
    end
    return filter(r)
end
local function f5()
    local r={}
    for _,k1 in pairs(t3) do
        for _,k2 in pairs(t2) do
            r[k1..k2]=1
        end
    end
    local rr,nn = f_repeat(r)
    print(string.format("55 ===== %d",nn))
    -- dump(rr,"f5")
    return filter(rr)
end
local function f6()
    local r={}
    --3
    for _,k1 in pairs(t3) do
        --3
        for _,k2 in pairs(t3) do
            r[k1..k2]=0
        end
    end
    local rr,nn = f_repeat(r)
    print(string.format("66 ===== %d",nn))
    -- dump(rr,"f6")
    return filter(rr)
end

local function fn(n,v,o1,o2)
    local r={}
    for k1 in pairs(o1) do
        for _,k2 in pairs(o2) do
            r[k1..k2]=v
        end
    end
    local rr,nn = f_repeat(r)
    print(string.format(string.rep(""..n,2).." ===== %d",nn))
    return filter(rr)
end

local function f8()
    -- dump(__t6)
    return fn(8,1,__t6,t2)
end

local function f9()
    return fn(9,0,__t6,t3)
end

local function f11()
    return fn(11,1,__t9,t2)
end

local function f12()
    return fn(12,0,__t9,t3)
end

local function f14()
    return fn(14,1,__t12,t2)
end

--------------------------------------------------------
local function f15()
    return fn(15,0,__t12,t3)
end

local function f17()
    return fn(17,1,__t15,t2)
end
--------------------------------------------------------
local function f18()
    return fn(18,0,__t15,t3)
end
local function f20()
    return fn(20,1,__t18,t2)
end

function tabletofile(tb,path,keytp)
    local file = io.open(path,'w+b')
    local sss = "local t={\n"
    local i=0
    for k,v in pairs(tb) do
        local line = ""
        if(type(v)=='table') then
            local ttss = "{"
            local dot = ''
            for _,numb in ipairs(v) do
                ttss = ttss..dot..numb
                dot=','
            end
            ttss = ttss.."}"
            if(keytp==1) then
                line = string.format("[%s] = %s,\n",k,ttss)
            else
                line = string.format("[\"%s\"] = %s,\n",k,ttss)
            end
        elseif(type(v)=='number') then
            -- line = string.format("[\"%s\"] = %d,\n",k,v)
            if(keytp==1) then
                line = string.format("[%s] = %d,\n",k,v)
            else
                line = string.format("[\"%s\"] = %d,\n",k,v)
            end
        end
        sss = sss .. line
        i=1+1
        if(i>5000) then
            i=0
            file:write(sss)
            sss=""
        end
    end

    sss = sss .. "\n}\n"
    sss = sss .. "return t"
    file:write(sss)
    io.close(file)
end



local PATH = ""

local BB = {
    1,10,100,
    1000,10000,100000,
    1000000,10000000,100000000
}

local function out_file(inputs,outfile)
    __t2={}
    __t3={}
    __t5={}
    __t6={}
    __t8={}
    __t9={}
    __t11={}
    __t12={}
    __t14={}
    __t15={}
    __t17={}
    __t18={}
    __t20={}

    ---输入参数
    t1 = inputs[1]
    t2 = inputs[2]
    t3 = inputs[3]

    __t2 = f2() 
    __t3 = f3()

    __t5 = f5()
    __t6 = f6()
    
    __t8 = f8()
    __t9 = f9()
    
    __t11 = f11()
    __t12 = f12()

    __t14 = f14()
    -- __t15 = f15()

    -- __t17 = f17()
    -- __t18 = f18()

    -- __t20 = f20()


    local tb = {
        [2]=__t2,
        [3]=__t3,
        [5]=__t5,
        [6]=__t6,
        [8]=__t8,
        [9]=__t9,
        [11]=__t11,
        [12]=__t12,
        [14]=__t14,
        -- [15]=__t15,
        -- [17]=__t17,
        -- [18]=__t18,
        -- [20]=__t20,
    }
    --合并
    local vvv = {}
    for k,v in pairs(tb) do
        if(v) then
            for kk,vv in pairs(v) do
                local len = kk:len()
                local ii = 0
                --转为数字
                for i=1,len do
                    local v = kk:byte(i)-0x30
                    ii = ii+BB[v]
                end
                vvv[ii] = vv
            end
        end
    end

    local ppp = PATH..outfile
    print("tablefofile",ppp,"\n")
    os.execute("rm -f "..ppp)
    tabletofile(vvv,ppp,1) 
end

local pai_A = 
{
    --万条筒
    ["A_wtt.lua"]={
        {1,2,3,4,5,6,7,8,9},
        {11,22,33,44,55,66,77,88,99},
        {111,222,333,444,555,666,777,888,999, 123,234,345,456,567,678,789}
    },
    --东西南北中发白
    ["A_zi.lua"]={
        {1,2,3,4, 5,6,7},
        {11,22,33,44, 55,66,77},
        {111,222,333,444, 555,666,777}
    }
}

local pai_B = 
{
    --万条筒
    ["B_wtt.lua"]={
        {1,2,3,4,5,6,7,8,9},
        {11,22,33,44,55,66,77,88,99},
        {111,222,333,444,555,666,777,888,999, 123,234,345,456,567,678,789}
    },
    --东南飞(一条)
    ["B_zi_dn.lua"]={
        {1,2,3},
        {11,22},
        {111,222,123}
    },
    --西北转(一筒)
    ["B_zi_xb.lua"]={
        {1,2,3},
        {11,22},
        {111,222,123}
    },
    --中发白
    ["B_zi_zfb.lua"]={
        {1,2,3},
        {11,22,33},
        {111,222,333,123}
    }
}

PATH = ...
PATH = PATH..'/gen/'
os.execute("rm -rf " .. PATH)
os.execute("mkdir " .. PATH)

for k,v in pairs(pai_A) do
    out_file(v,k)
end
for k,v in pairs(pai_B) do
    out_file(v,k)
end
return true

--[[
1.基本组合2张，3张
2.其他组合张数范围为： 3*n 3*n+2 (2,3, 5,6, 8,9, 11,12, 14）
3.每种数量组合，生成数据
3.转为数字输出
]]--

-- 分组：
-- 列出所有 成打（2，3）的牌
-- eg：
-- 3*n | 3*n+2
-- 2,[11,22,33,44,55,66,77,88,99]--9

-- 3,[111,222,333,444,555,666,777,888,999,123,234,345,456,567,678,789]--16
-- 5,[3+2] C(16,1) * C(9,1)

-- 6,[3+3] C(16,2)
-- 8,[3+3+2] = [6+2] C(16,2)* C(9,1)

-- 9,[3+3+3] = [6+3] C(16,3)
-- 11,[3+3+3+2] = [9+2] C(16,3)* C(9,1)

-- 12,[3+3+3+3+3] = [9+3] C(16,4)
-- 14,[3+3+3+3+3+2] = [12+2] C(16,4) * C(9,1)


