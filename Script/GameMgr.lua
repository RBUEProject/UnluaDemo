GameMgr = {}


function GameMgr:ShowGameInfo()
    print('')
    print('--------------------------------------------------')
    print('Use UnLua develop a LAN TPS game')
    return ''
end

function GameMgr:Init()
    GameMgr.MAX_PLAYER_COUNT = 2
    GameMgr.Name = "www.ngcod.com"
    GameMgr.IsPause = false
    GameMgr.CurrentGenNum = 0
    GameMgr.CurrentNum = 0
    GameMgr.Wave = 1
    GameMgr.MaxWave = 100
    GameMgr.MaxNum = 1
end

meta = {}
-- meta.__index = function()
--     return 1
-- end

NewTable = {}

-- meta.__newindex = function(T, K ,V)
--     print("__newindex. ")
-- end

meta.__call = function()
    print("__call is called")
    return {Name="LV"}
end

meta.__tostring = function()
    return "haha, i'm Game Mgr"
end
meta.TestMetaA= function(s)
    print("Test A")
    return s.Name
end

setmetatable(GameMgr, meta)
function GameMgr.GotoNextLevel()
    print("Goto Next Level")
    GameMgr.Wave = GameMgr.Wave + 1
    GameMgr.IsPause = false
end

function GameMgr.TestAddMul()
    A = {}
    A.Count = 100
    local result = AddMul(1, 2, 3, 4, 5, A)
    print("Result " .. result.Result .. ". Num " .. result.Num)
end

function GameMgr.TestClosure()
    local intValue = 0
    return function() 
        intValue = intValue + 1
        return intValue
    end
end


-- : 定义的函数，有一个隐含参数，叫self
-- ：调用方法，会传入self，作为第一个参数
-- .定义的函数，没有self
-- .调用， 没有self
function GameMgr.TestA(param1, param2)
    GameMgr.msgA = "MsgA:" .. tostring(self) .. " Param1=" .. tostring(param1) .. ", param2="..param2
end

function GameMgr:TestB( param1, param2)
    GameMgr.msgB = "MsgB:" .. tostring(self) .. " Param1=" .. param1 .. ", param2="..tostring(param2)
end

