local a = os.clock()
local z1 = require "zzz.zi_1"
local z2 = require "zzz.zi_2"
local z3 = require "zzz.zi_3"
local z4 = require "zzz.zi_4"
local z5 = require "zzz.zi_5"
local z6 = require "zzz.zi_6"
local z7 = require "zzz.zi_7"
local z8 = require "zzz.zi_8"
local z9 = require "zzz.zi_9"
local z10 = require "zzz.zi_10"
local z11 = require "zzz.zi_11"
local z12 = require "zzz.zi_12"
local z13 = require "zzz.zi_13"
local z14 = require "zzz.zi_14"
local z15 = require "zzz.zi_15"
local z16 = require "zzz.zi_16"
local z17 = require "zzz.zi_17"
local z18 = require "zzz.zi_18"
local z19 = require "zzz.zi_19"
local z20 = require "zzz.zi_20"
local b = os.clock()
print("LOAD-TEST",b-a)

local tt = {"123","456"}

local a = os.clock()
for i=1,10000000 do
    local v= tt[1]
end
local b = os.clock()
print("A-TEST",b-a)

local a = os.clock()
local v
for i=1,10000000 do
    v= z14["22233334455678"]
end
local b = os.clock()
print("B-TEST",b-a)

local a = os.clock()
local v
for i=1,10000000 do
    v= z19["2223333444455577799"]
end
local b = os.clock()
print("C-TEST",b-a)