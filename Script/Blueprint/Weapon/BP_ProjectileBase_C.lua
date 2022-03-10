--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

require "UnLua"

local BP_ProjectileBase_C = Class()

--function BP_ProjectileBase_C:Initialize(Initializer)
--end

function BP_ProjectileBase_C:UserConstructionScript()
    self.Damage = 100
    self.Sphere.OnComponentHit:Add(self, BP_ProjectileBase_C.OnComponentHit_Sphere)
end

function BP_ProjectileBase_C:OnComponentHit_Sphere(HitComponent, OtherActor, OtherComp, NormalImpulse, Hit)
	local Character = OtherActor:Cast(UE4.ABP_CharacterBase_C)
	if Character then
		local Controller = self.Instigator:GetController()
		UE4.UGameplayStatics.ApplyDamage(Character, self.Damage, Controller, self.Instigator, self.DamageType)
	end
	self:K2_DestroyActor()
end

function BP_ProjectileBase_C:ReceiveBeginPlay()
	self:SetLifeSpan(2.0)
end

--function BP_ProjectileBase_C:ReceiveEndPlay()
--end

-- function BP_ProjectileBase_C:ReceiveTick(DeltaSeconds)
-- end

--function BP_ProjectileBase_C:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
--end

--function BP_ProjectileBase_C:ReceiveActorBeginOverlap(OtherActor)
--end

--function BP_ProjectileBase_C:ReceiveActorEndOverlap(OtherActor)
--end

return BP_ProjectileBase_C
