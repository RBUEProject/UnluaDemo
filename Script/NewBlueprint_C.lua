--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

require "UnLua"

local NewBlueprint_C = Class()

--function NewBlueprint_C:Initialize(Initializer)
--end

--function NewBlueprint_C:UserConstructionScript()
--end

---注释掉BeginPlay，让蓝图的事件可以生效
--function NewBlueprint_C:ReceiveBeginPlay()
    -- local tempCurve = UE4.UObject.Load("/Game/CUR_Test.CUR_Test")
    -- self.Curve = tempCurve
    -- self.timer = 0
    -- local min, max = tempCurve:GetTimeRange()
    -- self.minTimer = min
    -- self.maxTimer = max
--end

---实现C++中定义的BlueprintImplementable方法
function NewBlueprint_C:LuaImp()
    print("this is a function implements C++")
end

---实现C++中定义的BlueprintNativeEvent
-- function NewBlueprint_C:LuaNative()
--     print("Native Event")
-- end

---实现蓝图中的自定义事件
function NewBlueprint_C:BP_EventTest()
    print("BP_EventTest")
end

--function NewBlueprint_C:ReceiveEndPlay()
--end

function NewBlueprint_C:ReceiveTick(DeltaSeconds)
    --self.timer = self.timer + DeltaSeconds
    --print("Index:" .. self.Curve:GetFloatValue(self.timer))
end

--function NewBlueprint_C:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
--end

--function NewBlueprint_C:ReceiveActorBeginOverlap(OtherActor)
--end

--function NewBlueprint_C:ReceiveActorEndOverlap(OtherActor)
--end

return NewBlueprint_C
