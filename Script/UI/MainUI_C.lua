--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

require "UnLua"

local MainUI_C = Class()
local TimerHandler = nil

-- function MainUI_C:TestCallable()
--     print("Main UI TestCallable")
-- end

function MainUI_C:TestImplementable()
    print("Main UI TestImplementable")
end

function MainUI_C:TestNativeEvent()
    print("Main UI TestNativeEvent")
   
end

function MainUI_C:MyDelegateLua()
    print("MyDelegateLua")
end

function MainUI_C:Initialize(Initializer)
    print("Main UI BeginPlay")
end

function MainUI_C:OnTimer()
    -- print("OnTimer")
end

function MainUI_C:Construct()
    print("Main UI Construct")
    self.btnAttack.OnPressed:Add(self, MainUI_C.OnPressAttack)
    TimerHandler = UE4.UKismetSystemLibrary.K2_SetTimerDelegate({self, MainUI_C.OnTimer}, 1, true)
end

function MainUI_C:OnPressAttack()

	MainUI_C:Log('TestLoadMap_C:' .. tostring(MainUI_C), MainUI_C)
	MainUI_C:Log('self:' .. tostring(self), self)

	local metatable = getmetatable(self)
	MainUI_C:Log('self 第一层metatable:' .. tostring(metatable), metatable)
	
	metatable = getmetatable(metatable)
	MainUI_C:Log('self 第二层metatable:' .. tostring(metatable), metatable)

	metatable = getmetatable(metatable)
	MainUI_C:Log('self 第三层metatable:' .. tostring(metatable), metatable)
	
    self:AddDelegate({self, MainUI_C.MyDelegateLua})
    self:CallDelegate()
    UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, TimerHandler)
    TimerHandler = nil
    -- self:TestCallable()
    -- UE4.UGameplayStatics.GetPlayerController(self, 0)
end

function MainUI_C:PreConstruct(IsDesignTime)
    print("Main UI PreConstruct")
end

function MainUI_C:Tick(MyGeometry, InDeltaTime)
    print("Main UI Tick")
end

function MainUI_C:Log(title, p)
	print("***********************************************")
	print("***" .. title)
	print("***type=" .. type(p))
	print("***********************************************")
	if type(p) == "table" then
		for key, value in pairs(p) do
			print("Key=" .. tostring(key) .. " Value=" .. tostring(value))
		end
	else
		print(p)
	end
	print("-----------------------------------------------")
	print("")
	print("")
	print("")
end

return MainUI_C
