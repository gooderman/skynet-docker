local str = 
[[
.package {
 type 0 : integer
 session 1 : integer
 ud 2 : string
}

.Player {
     id 0 : integer
     openid 1 : string
     name 2 : string
     gender 3 : integer
     headimg 4 : string
     platform 5 : string
     os 6 : string
     device 7 : string
     uuid 8 : string
     createtime 9 : integer
}

login 1 {
 request {
     player 0 : Player
 }
 response {
    result 0 : integer
    player 1 : Player
 }
}

heartup 2 {
 request {
 }
 response {
    id 0 : integer
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

auth 5 {
    request {
        key 0 : string
    }
    response {
        key 0 : string
    }
   }
]]

return str

---------------------------



