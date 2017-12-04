local common = require "protos.common"
local str = 
[[

#.RoomArgs {
#    renshu 0 : integer
#    jushu 1 : integer
#    wanfa 2 :integer
#}

.Room {
    id 0 : integer
    owner 1 : integer
    type 2 : integer
    args 3 : string
}

.Player {
     user  0 : UserBase
     chair 1 : integer
     online 2 : boolean
     ready 3: boolean
     ting 4 : boolean
     hu 5 : boolean
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
    rooom 0 : RoomBase
    player 1 : *Player
    state 2 : GameState
}

.Ting{
    card 0 : integer
    hu 1 : *integer
    score 2 :*integer
}

.joinroom_ntf {
    player 0 : Player
}

.online_ntf {
    chair 0 : integer
    online 1 : boolean
}

.gameinfo_ntf {
    game 0 : GameInfo
}

.ready_req {
    ready 0 : integer
}

.ready_ntf {
    chair 0 : integer
    ready 1 : boolean
}

.gamestart_ntf {
    game 0 : GameInfo
}

.chi_tip {
    from 0 : integer 
    to 1 : integer
    cards 2 : integer
}

.chi_req {
    cards 0 : *integer
}

.chi_ntf {
    state 0 : integer
    type 1 : integer #左中右
    from 2 : integer 
    to 3 : integer
    cards 4 : *integer
}

.peng_tip {
    from 0 : integer 
    to 1 : integer
    cards 2 : integer
}

.peng_req {
    cards 0: *integer
}

.peng_ntf {
    state 0 : integer
    from 1 : integer 
    to 2 : integer    
    cards 3 : *integer
}

.gang_tip {
    type 0 : integer #ming xu an
    from 1 : integer
    cards 2 : integer
}

.gang_req {
    cards 0: *integer
}

.gang_ntf {
    state 0 : integer
    type 1 : integer #ming xu an
    from 2 : integer 
    to 3 : integer    
    cards 4 : *integer
}

.chu_tip {
    chair 0 : integer   
    ting 1 : *Ting
}

.chu_req {
    card 0 : integer
}

.chu_ntf {
    chair 0 : integer   
    card 1 : integer
}

.ting_tip {
    chair 0 : integer
    ting 1 : *Ting
}

.ting_req {
    card 0 : integer
}

.ting_ntf {
    chair 0: integer
}

.hu_tip {
    from 0 : integer
    card 1 : integer
    zimo 2 : integer
}

.hu_req {
    hu 0: integer
}

.hu_ntf {
    chair 0 :integer
    from 1 : integer
    card 2 : integer
    zimo 3 : integer
}

.getcard_ntf {
    chair 0 :integer
    card 1 : integer
}

.quit_req {
    chair 0 :integer
}

.quit_req_ntf {
    chair 0 :integer
    agree 1 :*integer
    disagree 2 :*integer
}

]]

return common..str

---------------------------






