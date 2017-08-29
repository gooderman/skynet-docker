local skynet = require "skynet"
require "skynet.manager"	-- import skynet.register
local conf={
	host = "127.0.0.1",
	port = 6379,
	db = 0

}
local sqlite3 = require "lsqlite3"
local db = nil

local util = require 'util'

local command = {}

function command.init()

	print("sqlite3.complete",sqlite3.complete)
	print("sqlite3.lversion",sqlite3.lversion())

	-- local db = sqlite3.open_memory()
	local db = sqlite3.open(skynet.getenv("SQLITE_DB_FILE"))
	local hastable=false
	for row in db:nrows("SELECT count(*) AS numb FROM sqlite_master WHERE type='table' AND name='test'") do
		if(row.numb>0) then
			hastable = true
		end
	end
	db:exec[[
	DROP TABLE user;
	]]
	db:exec[[
		CREATE TABLE IF NOT EXISTS user (id INTEGER PRIMARY KEY, name NOT NULL, age INTEGER,intro);

		INSERT INTO user VALUES (NULL, 'Lisa',10,'Hello Lisa');
		INSERT INTO user VALUES (NULL, 'Jeep',20,'Hello Jeep');
		INSERT INTO user VALUES (NULL, 'Eason',20,'Hello Eason');
		INSERT INTO user VALUES (NULL, 'Ken',22,'Hello Ken');
		]]

	db:exec[[
	DELETE FROM user WHERE name like '%en';
	INSERT INTO user VALUES (NULL, 'King',22,'Hello King');
	]]
	print("db: rows------------------------")
	for row in db:rows("SELECT * FROM user") do
		print(row[1], row[2],row[3],row[4])
	end
	print("db: nrows------------------------")
	for row in db:nrows("SELECT * FROM user") do
		print(row.id, row.name,row.age,row.intro)
	end
	print("db: urows------------------------")
	for id,name,age,intro in db:urows("SELECT * FROM user") do
		print(id, name,age,intro)
	end
end

function command.GET(key)
	return db:get(key)
end

function command.SET(key, value)
	local last = db:get(key)
	db:set(key, value)
	return last
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
	skynet.register ".store_sqlite"
	command.init()
end)
