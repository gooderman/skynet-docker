proj = "./ggmm/"
root = "./skynet/"
package = "./deps/skynet_package/"
thread = 8
harbor = 0
luaservice = root.."service/?.lua;" ..package.."service/?.lua;" ..proj.."?.lua;" ..proj.."?/main.lua;" ..proj..'client/'.."?.lua;"
lualoader = root.."lualib/loader.lua"
cpath = root.."cservice/?.so"
lua_path = root.."lualib/?.lua;"  ..root.."lualib/?/init.lua;"  ..root.."lualib/skynet/?.lua;"  ..package.."lualib/?.lua;"..proj.."?.lua;" ..proj.."?/main.lua;"
lua_cpath = root.."luaclib/?.so"
start = "main_test"
GAME_LISTEN_PORT = 8888
LOGIN_WEB_PORT = 8080
SQLITE_DB_FILE = proj .. "sqlite.db"
UNQLITE_DB_FILE = proj .. "unqlite.db"
RECORD_SAVE_PATH = proj .. "save_record"
