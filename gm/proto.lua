local sprotoparser = require "sprotoparser"
local proto = {}
local str = 
[[
.package {
	type 0 : integer
	session 1 : integer
	ud 2 : string
}

.Player {
	openid 0 : string
	imgurl 1 : string
	gender 2 : integer
}

login 1 {
	request {
		openid 0 : string
	}
	response {
		player 0 : Player
	}
}

heartup 2 {
	request {
	}
	response {
	}
}

heartdown 3 {
	request {
	}
	response {
	}
}

kickoff 4 {
	request {
	}
	response {
	}
}


]]



proto.c2s = sprotoparser.parse(str)

proto.s2c = sprotoparser.parse(str)

return proto
