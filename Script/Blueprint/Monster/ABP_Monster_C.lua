--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

require "UnLua"

local ABP_Monster_C = Class()

--function ABP_Monster_C:Initialize(Initializer)
--end

-- function ABP_Monster_C:BlueprintInitializeAnimation()
    
-- end

function ABP_Monster_C:BlueprintBeginPlay()
    print("Monster Anim Receive Begin Play")
    self.Pawn = self:TryGetPawnOwner()
    self.Velocity = UE4.FVector()
end

function ABP_Monster_C:BlueprintUpdateAnimation(DeltaTimeX)
    local Pawn = self:TryGetPawnOwner(self.Pawn)
    if not Pawn then
        return
    end
    local Vel = Pawn:GetVelocity(self.Velocity)
    if not Vel then
        return
    end

    local Character = Pawn:Cast(UE4.ABP_CharacterBase_C)
	if Character then
		if Character.IsDead and not self.IsDead then
			self.IsDead = true
			self.AnimIndex = UE4.UKismetMathLibrary.RandomIntegerInRange(0, 2)
		end
	end
	local Speed = Vel:Size()
	self.Speed = Speed
end

-- function ABP_Monster_C:BlueprintPostEvaluateAnimation()
-- end

return ABP_Monster_C
