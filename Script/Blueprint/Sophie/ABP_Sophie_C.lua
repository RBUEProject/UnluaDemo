--
-- DESCRIPTION
--
-- @COMPANY ngcod.com
-- @AUTHOR 天空游荡的鱼
-- QQ:708888157
--
-- @DATE 2021.12.28
--
--

require "UnLua"

local ABP_Sophie_C = Class()

--function ABP_Sophie_C:Initialize(Initializer)
--end

--function ABP_Sophie_C:BlueprintInitializeAnimation()
--end

function ABP_Sophie_C:BlueprintBeginPlay()
    self.Velocity = UE4.FVector()
	self.ForwardVec = UE4.FVector()
	self.RightVec = UE4.FVector()
	self.ControlRot = UE4.FRotator()
	self.Pawn = self:TryGetPawnOwner()
end

function ABP_Sophie_C:BlueprintUpdateAnimation(DeltaTimeX)
    local Pawn = self:TryGetPawnOwner(self.Pawn)
    if not Pawn then
        return
    end
    local Vel = Pawn:GetVelocity(self.Velocity)
    if not Vel then
        return
    end

	-- local Character = Pawn:Cast(UE4.ABP_Player_C)
	local Character = Pawn
	if Character then
		if Character.IsDead and not self.bDead then
			self.bDead = true
			self.DeathAnimIndex = UE4.UKismetMathLibrary.RandomIntegerInRange(0, 2)
		end
	end
	local Speed = Vel:Size()
	self.Speed = Speed
	if Speed > 0.0 then
		Vel:Normalize()
		local Rot = Pawn:GetControlRotation(self.ControlRot)
		Rot:Set(0, Rot.Yaw, 0)
		local ForwardVec = Rot:GetForwardVector(self.ForwardVec)
		local RightVec = Rot:GetRightVector(self.RightVec)
		local DP0 = Vel:Dot(RightVec)
		local DP1 = Vel:Dot(ForwardVec)
		local Angle = UE4.UKismetMathLibrary.Acos(DP1)
		if DP0 > 0.0 then
			self.Direction = Angle
		else
			self.Direction = -Angle
		end
        self.Direction = self.Direction * 180 / 3.1415926
	end
end

-- function ABP_Sophie_C:BlueprintPostEvaluateAnimation()
-- end

return ABP_Sophie_C
