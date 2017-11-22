local str = 
[[
.package {
 type 0 : integer
 session 1 : integer
 ud 2 : string
}

.User {
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

.Player {
     id 0 : integer
     name 1 : string
     gender 3 : integer
     headimg 4 : string
     chair 5 : integer
     online 6 : boolean
     ready 7: boolean
     ting 8 : boolean
     hu 9 : boolean
}

.RoomArgs {
     renshu 0 : integer
     jushu 1 : integer
}

.Room {
     id 0 : integer
     owner 1 : integer
     type 2 : integer
     args 3 : RoomArgs
}

.Cards {
     chair 0 : integer
     out 1 : *integer #drop
     hand 2 : *integer #have
     chi1 3 : *integer #zuo chi
     chi2 4 : *integer #zhong chi
     chi3 5 : *integer #you chi
     peng 6 : *integer 
     gang1 7 : *integer #ming gang
     gang2 8 : *integer #xu gang
     gang3 9 : *integer #an gang
     hu 10 : integer #hu
     zimo 11 : integer #zimo
}

.Score {
     jushu 0 : integer
     chair 1 : integer
     score 2 : integer
     type 3 : integer
     total 4 : integer
}

.GameState {
    state 0 : integer
    jushu 1 : integer
    banker 2 : integer #庄家
    cards 3 : *Cards #玩家的牌
    cardnumb 4 : integer #剩余未翻的牌
    winner 5 : *integer
    score 6 : *Score
}

.GameInfo {
    rooom 0 : Room
    player 1 : *Player
    state 2 : GameState
}

.Ting{
    card 0 : integer
    hu 1 : *integer
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
     user 0 : User
 }
 response {
    state 0 : integer
    user 1 : User
 }
}

kickoff 4 {
 request {
 }
 response {
 }
}

getroom 100 {
 request {
    userid 0 : integer
 }
 response {
    state 0 : integer
    room 1 : Room
 }
}

newroom 101 {
 request {
    type 0 : integer
    renshu 1 : integer
    jushu 2 : integer
    wanfa 3 : integer
 }
 response {
    state 0 : integer
    room 1 : Room
 }
}

enterroom 102 {
 request {
    roomid 0 : integer
 }
 response {
    state 0 : integer
 }
}

joinroom 103 {
 request {
    roomid 0 : integer
 }
 response {
    state 0 : integer
 }
}

joinroom_ntf 104 {
 request {
    player 0 : Player
 }
 response {
    state 0 : integer
 }
}

online_ntf 105 {
 request {
    chair 0 : integer
    online 1 : boolean
 }
 response {

 }
}


gameinfo_ntf 201 {
 request {
    game 0 : GameInfo
 }
 response {
    state 0 : integer
 }
}

ready 202 {
 request {
    ready 0 : integer
 }
 response {
    chair 0 : integer
    ready 1 : boolean
 }
}

gamestart_ntf 203 {
 request {
    game 0 : GameInfo
 }
 response {

 }
}

chi_tip 204 {
 request {

 }
 response {
    state 0 : integer
    from 1 : integer 
    to 2 : integer
    cards 3 : integer
 }
}

chi 205 {
 request {
    cards 0 : *integer
 }
 response {
    state 0 : integer
 }
}

chi_ntf 206 {
 request {
 }
 response {
    state 0 : integer
    type 1 : integer #左中右
    from 2 : integer 
    to 3 : integer
    cards 4 : *integer
 }
}

peng_tip 207 {
 request {

 }
 response {
    state 0 : integer
    from 1 : integer 
    to 2 : integer
    cards 3 : integer
 }
}

peng 208 {
 request {
    cards 0: *integer
 }
 response {
    state 0 : integer
 }
}

peng_ntf 209 {
 request {

 }
 response {
    state 0 : integer
    from 1 : integer 
    to 2 : integer    
    cards 3 : *integer
 }
}

gang_tip 210 {
 request {

 }
 response {
    state 0 : integer
    type 1 : integer #ming xu an
    from 2 : integer
    cards 3 : integer
 }
}

gang 211 {
 request {
    cards 0: *integer
 }
 response {
    state 0 : integer
 }
}

gang_ntf 212 {
 request {
 }
 response {
    state 0 : integer
    type 1 : integer #ming xu an
    from 2 : integer 
    to 3 : integer    
    cards 4 : *integer
 }
}

chu 213 {
 request {
    cards 0 : integer
 }
 response {
    state 0 : integer
 }
}

chu_ntf 214 {
 request {

 }
 response {
    state 0 : integer
    from 1 : integer   
    cards 2 : integer
 }
}

ting 215 {
 request {
    card 0 : integer
 }
 response {
    state 0 : integer
    from 1 : integer   
    card 2 : integer
 }
}

hu 216 {
 request {
 }
 response {
    state 0 : integer
    from 1 : integer
 }
}

getcard 217 {
 request {
 }
 response {
    state 0 : integer
    from 1 : integer
    card 2 : integer
    ting 3 : *Ting
    hu 4 : integer
 }
}




]]

return str

---------------------------



