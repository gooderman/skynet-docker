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

.Room {
     id 0 : integer
     renshu 1 : integer
}

auth 1 {
    request {
        key 0 : string
    }
    response {
        key 0 : string
    }
   }


heartup 2 {
 request {
 }
 response {
    id 0 : integer
 }
}   

login 3 {
 request {
     player 0 : Player
 }
 response {
    state 0 : integer
    player 1 : Player
 }
}

kickoff 4 {
 request {
 }
 response {
 }
}

getroom 5 {
 request {
    userid 0 : integer
 }
 response {
    state 0 : integer
    room 1 : Room
 }
}

newroom 6 {
 request {
    type 0 : integer
    renshu 1 : integer
 }
 response {
    state 0 : integer
    room 1 : Room
 }
}

joinroom 7 {
 request {
    roomid 0 : integer
 }
 response {
    state 0 : integer
    room 1 : Room
 }
}

gameready 8 {
 request {
    ready 0 : integer
 }
 response {

 }
}



]]

return str

---------------------------



