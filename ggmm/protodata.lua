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
     ting 7 : boolean
     hu 8 : boolean
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
    curjushu 1 : integer
    banker 2 : integer #庄家
    cards 3 : *Cards(chair) #玩家的牌
    deskcards 4 : *integer #剩余未翻的牌
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
    intro 2 : string
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

gameinfo 8 {
 request {
    roomid 0 : integer
 }
 response {
    state 0 : integer
    game 1 : GameInfo
 }
}

gameready 9 {
 request {
    ready 0 : integer
 }
 response {
    chair 0 : integer
    ready 1 : integer
 }
}

gamestart 10 {
 request {
 }
 response {
    state 0 : integer
    game 1 : GameInfo
 }
}

chi_tip 11 {
 request {

 }
 response {
    state 0 : integer
    from 1 : integer 
    to 2 : integer
    cards 3 : integer
 }
}

chi 12 {
 request {
    cards 0 : *integer
 }
 response {
    state 0 : integer
 }
}

chi_ntf 13 {
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

peng_tip 14 {
 request {

 }
 response {
    state 0 : integer
    from 1 : integer 
    to 2 : integer
    cards 3 : integer
 }
}

peng 15 {
 request {
    cards 0: *integer
 }
 response {
    state 0 : integer
 }
}

peng_ntf 16 {
 request {

 }
 response {
    state 0 : integer
    from 1 : integer 
    to 2 : integer    
    cards 3 : *integer
 }
}

gang_tip 17 {
 request {

 }
 response {
    state 0 : integer
    type 1 : integer #ming xu an
    from 2 : integer
    cards 3 : integer
 }
}

gang 18 {
 request {
    cards 0: *integer
 }
 response {
    state 0 : integer
 }
}

gang_ntf 19 {
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

chu 20 {
 request {
    cards 0 : integer
 }
 response {
    state 0 : integer
 }
}

chu_ntf 21 {
 request {

 }
 response {
    state 0 : integer
    from 1 : integer   
    cards 2 : integer
 }
}

ting 22 {
 request {
    card 0 : integer
 }
 response {
    state 0 : integer
    from 1 : integer   
    card 2 : integer
 }
}

hu 23 {
 request {
 }
 response {
    state 0 : integer
    from 1 : integer
 }
}

getcard 24 {
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



