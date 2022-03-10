--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

require "UnLua"

local BP_MonsterController_C = Class()

--function BP_MonsterController_C:Initialize(Initializer)
--end

function BP_MonsterController_C:UserConstructionScript()
    self.BehaviorTree = LoadObject("/Game/Blueprint/Monster/BT_Monster.BT_Monster")
end

function BP_MonsterController_C:ReceiveBeginPlay()
    self:RunBehaviorTree(self.BehaviorTree)
end

--function BP_MonsterController_C:ReceiveEndPlay()
--end

-- function BP_MonsterController_C:ReceiveTick(DeltaSeconds)
-- end

--function BP_MonsterController_C:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
--end

--function BP_MonsterController_C:ReceiveActorBeginOverlap(OtherActor)
--end

--function BP_MonsterController_C:ReceiveActorEndOverlap(OtherActor)
--end

return BP_MonsterController_C
