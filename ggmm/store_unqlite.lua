local skynet = require "skynet"
require "skynet.manager"	-- import skynet.register
local unqlite = require("unqlite")
local db = nil

local util = require 'util'

local command = {}

function command.init()

	db = unqlite.open(skynet.getenv("UNQLITE_DB_FILE"))
	print("db: unqlite.open=",db)
	print("db: GET------------------------")
	print("Eason=",command.GET('Eason'))
	print("Jack=",command.GET('Jack'))
	print("db: GET_N------------------------")
	util.dump(command.GET_N({"Jeep","Lisa"}),"GET_N")

	print("db: SET------------------------")
	print("Eason=",command.SET('Eason','__eason'))
	print("Jack=",command.SET('Jack','__jack'))
	print("db: SET_N------------------------")
	command.SET_N({Jeep='__jeep',Lisa='__lisa'})

	----------------------------------------------
	print("db: SET_N S",skynet.now()/100)
	for i=1,500000 do
		command.SET('Eason','__eason')
		command.SET('Jack','__jack')
	end
	print("db: SET_N E",skynet.now()/100)
	----------------------------------------------
	print("db: SET_N S2",skynet.now()/100)
	unqlite.begin(db)
	for i=1,500000 do
		command.SET('Eason','__eason')
		command.SET('Jack','__jack')
	end
	unqlite.commit(db)
	print("db: SET_N E2",skynet.now()/100)
	----------------------------------------------
	print("db: SET_N S3",skynet.now()/100)

	for i=1,100 do
		unqlite.begin(db)
		command.SET('Eason','__eason')
		command.SET('Jack','__jack')
		unqlite.commit(db)
	end
	print("db: SET_N E3",skynet.now()/100)
	----------------------------------------------
end

function command.GET(key)
	return unqlite.fetch(db, key)
end

function command.SET(key, value)
	return unqlite.store(db, key, value)
end

function command.GET_N(tb)
	local r={}
	if(tb and #tb>0) then
		for _,k in pairs(tb) do
			r[k]=unqlite.fetch(db, k)
		end
	end
	return r
end

function command.SET_N(tb)
	if(tb) then
		unqlite.begin(db)
		for k,v in pairs(tb) do
			unqlite.store(db, k, v)
		end
		unqlite.commit(db)
	end
end

skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[string.upper(cmd)]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)
	skynet.register ".store_unqlite"
	command.init()
end)
