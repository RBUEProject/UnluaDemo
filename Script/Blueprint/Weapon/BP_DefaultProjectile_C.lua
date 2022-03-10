--
-- DESCRIPTION
--
-- @COMPANY www.ngcod.com
-- @AUTHOR 天空游荡的鱼
-- QQ:708888157
--
-- @DATE ${date} ${time}
--

require "UnLua"

-- local BP_DefaultProjectile_C = Class("Blueprint.Weapon.BP_ProjectileBase_C")
local BP_DefaultProjectile_C = Class()

function BP_DefaultProjectile_C:Initialize(Initializer)
	if Initializer then
		self.BaseColor = Initializer[0]
	end
end

function BP_DefaultProjectile_C:UserConstructionScript()
	self.Damage = 100
    self.Sphere.OnComponentHit:Add(self, BP_DefaultProjectile_C.OnComponentHit_Sphere)
end

function BP_DefaultProjectile_C:OnComponentHit_Sphere(HitComponent, OtherActor, OtherComp, NormalImpulse, Hit)
	local Character = OtherActor
	if Character == self.Instigator then
		return
	end
	if Character then
		local Controller = self.Instigator:GetController()
		UE4.UGameplayStatics.ApplyDamage(Character, self.Damage, Controller, self.Instigator, self.DamageType)
	end
	self:K2_DestroyActor()
end

function BP_DefaultProjectile_C:ReceiveBeginPlay()
	if self.BaseColor ~= nil then
		self.Color = self.BaseColor
	end
	
	local MID = self.StaticMesh:CreateDynamicMaterialInstance(0)
	if MID then
		MID:SetVectorParameterValue("BaseColor", self.Color)
	end
end

--function BP_DefaultProjectile_C:ReceiveEndPlay()
--end

-- function BP_DefaultProjectile_C:ReceiveTick(DeltaSeconds)
-- end

--function BP_DefaultProjectile_C:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
--end

--function BP_DefaultProjectile_C:ReceiveActorBeginOverlap(OtherActor)
--end

--function BP_DefaultProjectile_C:ReceiveActorEndOverlap(OtherActor)
--end

return BP_DefaultProjectile_C
