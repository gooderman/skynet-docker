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
    print(string.format("55-55 ===== %d",nn))
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
    print(string.format("66-66 ===== %d",nn))
    -- dump(rr,"f6")
    return filter(rr)
end


local function f8()
    local t=__t6
    --3
    local r={}
    for k in pairs(t) do
        --2
        for _,k2 in pairs(t2) do
            r[k..k2]=1
        end
    end
    local rr,nn = f_repeat(r)
    print(string.format("88-88 ===== %d",nn))
    -- dump(rr,"f8")
    return filter(rr)
end

local function f9()
    local t=__t6
    --3
    local r={}
    for k1 in pairs(t) do
        --3
        for _,k2 in pairs(t3) do
            r[k1..k2]=0
        end
    end
    local rr,nn = f_repeat(r)
    print(string.format("99-99 ===== %d",nn))
    -- dump(rr,"f9")
    return filter(rr)
end

local function f11()
    local t=__t9
    --3
    local r={}
    for k1 in pairs(t) do
        --2
        for _,k2 in pairs(t2) do
            r[k1..k2]=1
        end
    end
    local rr,nn = f_repeat(r)
    print(string.format("11-11 ===== %d",nn))
    return filter(rr)
end

local function f12()
    local t=__t9
    --3
    local r={}
    for k1 in pairs(t) do
        --3
        for _,k2 in pairs(t3) do
            r[k1..k2]=0
        end
    end
    local rr,nn = f_repeat(r)
    print(string.format("12-12 ===== %d",nn))
    -- dump(rr,"f9")
    return filter(rr)
end


local function f14()
    local t=__t12
    --3
    local r={}
    for k1 in pairs(t) do
        for _,k2 in pairs(t2) do
            r[k1..k2]=1
        end
    end
    local rr,nn = f_repeat(r)
    print(string.format("14-14 ===== %d",nn))
    return filter(rr)
end

--------------------------------------------------------
local function f15()
    local t=__t12
    --3
    local r={}
    for k1 in pairs(t) do
        --3
        for _,k2 in pairs(t3) do
            r[k1..k2]=0
        end
    end
    local rr,nn = f_repeat(r)
    print(string.format("15-15 ===== %d",nn))
    return filter(rr)
end

local function f17()
    local t=__t15
    --3
    local r={}
    for k1 in pairs(t) do
        --2
        for _,k2 in pairs(t2) do
            r[k1..k2]=1
        end
    end
    local rr,nn = f_repeat(r)
    print(string.format("17-17 ===== %d",nn))
    return filter(rr)
end

--------------------------------------------------------
local function f18()
    local t=__t15
    --3
    local r={}
    for k1 in pairs(t) do
        --3
        for _,k2 in pairs(t3) do
            r[k1..k2]=0
        end
    end
    local rr,nn = f_repeat(r)
    print(string.format("18-18 ===== %d",nn))
    return filter(rr)
end

local function f20()
    local t=__t18
    --3
    local r={}
    for k1 in pairs(t) do
        --2
        for _,k2 in pairs(t2) do
            r[k1..k2]=1
        end
    end
    local rr,nn = f_repeat(r)
    print(string.format("20-20 ===== %d",nn))
    -- dump(rr,"f9")
    return filter(rr)
end

--需要的奖牌
__t2 = f2() 
__t3 = f3()

__t5 = f5()
__t6 = f6()

__t8 = f8()
__t9 = f9()

__t11 = f11()
__t12 = f12()

__t14 = f14()
__t15 = f15()

__t17 = f17()
__t18 = f18()

__t20 = f20()

function tabletofile(tb,path)
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
            line = string.format("[\"%s\"] = %s,\n",k,ttss)
        elseif(type(v)=='number') then
            line = string.format("[\"%s\"] = %d,\n",k,v)
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
local path = ...
path = path..'/zzz/'
os.execute("mkdir " .. path)
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
    [15]=__t15,
    [17]=__t17,
    [18]=__t18,
    [20]=__t20,
}


for k,v in pairs(tb) do
    if(v) then
        print("tablefofile",k)
        local ppp = string.format("zi_%d.lua",k)
        ppp = path..ppp
        os.execute("rm -f "..ppp)
        tabletofile(v,ppp) 
    end
end    
-- tabletofile(__t4,path..'__t4.lua')
-- tabletofile(__t5,path..'__t5.lua')
-- tabletofile(__t6,path..'__t6.lua')
-- tabletofile(__t7,path..'__t7.lua')
-- tabletofile(__t8,path..'__t8.lua')
-- tabletofile(__t9,path..'__t9.lua')
-- tabletofile(__t10,path..'__t10.lua')
-- tabletofile(__t11,path..'__t11.lua')
-- tabletofile(__t12,path..'__t12.lua')
-- tabletofile(__t12,path..'__t12.lua')
-- tabletofile(__t12,path..'__t12.lua')
-- tabletofile(__t12,path..'__t12.lua')
-- tabletofile(__t12,path..'__t12.lua')
-- tabletofile(__t12,path..'__t12.lua')
-- tabletofile(__t12,path..'__t12.lua')
-- tabletofile(__t12,path..'__t12.lua')
-- tabletofile(__t20,path..'__t20.lua')
return tb


-- zipai_gen()
-- fengpai_gen()

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


