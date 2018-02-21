local common = require "protos.common"
local str = 
[[

#.RoomArgs {
#     renshu 0 : integer
#     jushu 1 : integer
#     wanfa 2 :integer
#     ting 3 : boolean ##报听
#     bao 4 : boolean ##点炮全包
#     gangf 5 : boolean ##杠就算分
#}

.Player {
     user  0 : UserBase
     chair 1 : integer
     online 2 : boolean
     ready 3: boolean
     autoplay 4: boolean
}
.OptCard {
    opt 0 : integer
    card 1 : integer 
    from 2 : integer
}
.Cards {
     chair 0 : integer
     out 1 : *integer #drop
     hand 2 : *integer #have
     opt 3 : *OptCard 
     ting 4 : boolean
     hu 5 : integer #hu
     zimo 6 : integer #zimo
}

.Score {
     jushu 0 : integer
     chair 1 : integer
     score 2 : integer
     type 3 : integer
     total 4 : integer
}

.GameState {
    state 0 : integer #012
    jushu 1 : integer
    banker 2 : integer #庄家
    cards 3 : *Cards #玩家的牌
    cardnumb 4 : integer #剩余未翻的牌
    optchair 5 : integer #操作玩家
    #winner 5 : *integer
    #score 6 : *Score
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
    card 1 : integer
    type 2 : integer
}

.chi_req {
    type  0 : integer ###
    cards 1 : *integer
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
    card 2 : integer
}

.peng_req {
    cards 0: *integer
}

.peng_ntf {
    state 0 : integer
    chair 1 : integer    
    from 2 : integer 
    card 3 : integer
}

.gang_tip {
    type 0 : integer #ming xu an
    from 1 : integer
    card 2 : integer
}

.gang_req {
    type 0 :integer #ming xu an
    card 1 : integer
}

.gang_ntf {
    state 0 : integer
    chair 1 : integer
    type 2 : integer #ming xu an
    from 3 : integer  
    card 4 : integer #暗杠hide
}

.chu_tip {
    chair 0 : integer
    cards 1 : *integer #suggest
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
    isting 0 :boolean
    card 1 : integer
}

.ting_ntf {
    chair 0: integer
    card 1 : integer
}

.hu_tip {
    from 0 : integer
    card 1 : integer
    zimo 2 : integer
}

.hu_req {
    ishu 0: boolean
}

.hu_ntf {
    chair 0 :integer
    from 1 : integer
    card 2 : integer
    zimo 3 : boolean
}
.huang_ntf {
}

.pass_req {
}

#接牌吃碰杠
.opt_tip {
    chair 0 :integer
    from 1 : integer
    card 2 : integer
    types 3 : *integer
}


#起牌后选项
.opt_tip_self {
    chair 0 :integer
    hu 1 : boolean
    gangxu 2: *integer
    gangan 3: *integer
}

.getcard_ntf {
    chair 0 :integer
    card 1 : integer
}

.invalid_ntf {
    chair 0 :integer
    type 1 : integer #opt type
    info 2 : string #reason
}

.ReportInfo {
    hucard 0 : integer
    iszm 1 : boolean
    is7d 2 : boolean
    is13y 3 : boolean
}

.Report {
    chair 0 : integer
    user  1 : UserBase
    hu    2 : boolean
    pao   3 : boolean #点炮
    score 4 : integer #总分
    param  5 : ReportInfo #和牌信息
    cards 6 : Cards #牌
    sumscore 7 : integer #总分
}

.FinalReport {
    chair 0 : integer
    user  1 : UserBase
    hu    2 : *boolean #每局胡牌
    pao   3 : *boolean #没局点炮牌
    score 4 : *integer #每局总分
    sumscore 5 : integer #最终分数
}

#结算
.report_ntf {
    hu   0 : boolean
    huang 1 : boolean
    info 2 : *Report
}

.final_report_ntf {
    info 0 : *FinalReport
}

.quit_req {

}

.quit_ntf {
    chair 0 : integer
}

.dismiss_vote_ntf {
    chair 0 :integer
    agree 1 :*integer
    dismiss 2:integer ##0 wait, 1 dismiss, 2 no dismiss 
    time 3:integer ##second
}

.dismiss_vote_req {
    agree 0 :integer
}

.dismiss_ntf {
    chair 0 :integer
}


]]

return common..str

---------------------------






