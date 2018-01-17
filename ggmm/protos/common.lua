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

.UserBase {
     id 0 : integer
     # openid 1 : string
     name 2 : string
     gender 3 : integer
     headimg 4 : string
}

.RoomBase {
    id 0 : integer
    owner 1 : integer
    type 2 : integer
    args 3 : string
}

auth 1 {
    request {
        key 0 : string
    }
    response {
        key 0 : string
    }
   }

heartbeat 2 {
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

quit 4 {
 request {
 }
 response {
 }
}

dataup 5 {
 request {
    type 0 :integer #子协议分类
    cmd 1 :string #子协议命令
    data 2 :string #子协议内容
 }
 response {
    type 0 :integer #子协议分类
    cmd 1 :string #子协议命令
    data 2 :string #子协议内容
 }
}

datadn 6 {
 request {
    type 0 :integer #子协议分类
    cmd 1 :string #子协议命令
    data 2 :string #子协议内容
 }
 response {
 }
}

replaced 7 {
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
    room 1 : RoomBase
 }
}

newroom 101 {
 request {
    type 0 : integer
    args 1: string #jsonparam
 }
 response {
    state 0 : integer
    room 1 : RoomBase
 }
}

joinroom 102 {
 request {
    roomid 0 : integer
 }
 response {
    state 0 : integer
 }
}


]]

return str

---------------------------



