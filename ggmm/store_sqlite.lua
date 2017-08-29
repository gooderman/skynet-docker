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
		CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY, content);

		INSERT INTO test VALUES (NULL, 'Hello World');
		INSERT INTO test VALUES (NULL, 'Hello Lua');
		INSERT INTO test VALUES (NULL, 'Hello Sqlite3')
		]]

	db:exec[[
	DELETE FROM test WHERE content='Hello Lua';
	]]
	for row in db:nrows("SELECT * FROM test") do
		print(row.id, row.content)
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
