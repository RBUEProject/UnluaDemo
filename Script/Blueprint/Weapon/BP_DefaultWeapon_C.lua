--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

require "UnLua"

local BP_DefaultWeapon_C = Class("Blueprint.Weapon.BP_WeaponBase_C")

--function BP_DefaultWeapon_C:Initialize(Initializer)
--end

function BP_DefaultWeapon_C:UserConstructionScript()
    self.Super.UserConstructionScript(self)
    self.MuzzleSocketName = "Muzzle"
    self.ProjectileClass = UE4.UClass.Load("/Game/Blueprint/Weapon/BP_DefaultProjectile.BP_DefaultProjectile")
    self.World = self:GetWorld()
end

function BP_DefaultWeapon_C:ReceiveBeginPlay()
    print("BP_DefaultWeapon_C:ReceiveBeginPlay")
end

function BP_DefaultWeapon_C:SpawnProjectile()
    if self.ProjectileClass then
		local Transform = self:GetFireInfo()
		local R = UE4.UKismetMathLibrary.RandomFloat()
		local G = UE4.UKismetMathLibrary.RandomFloat()
		local B = UE4.UKismetMathLibrary.RandomFloat()
		local BaseColor = {}
		BaseColor[0] = UE4.FLinearColor(R, G, B, 1.0)
		local Projectile = self.World:SpawnActor(self.ProjectileClass, Transform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, self, self.Instigator, "Blueprint.Weapon.BP_DefaultProjectile_C", BaseColor)
	end
end

--function BP_DefaultWeapon_C:ReceiveEndPlay()
--end

-- function BP_DefaultWeapon_C:ReceiveTick(DeltaSeconds)
-- end

--function BP_DefaultWeapon_C:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
--end

--function BP_DefaultWeapon_C:ReceiveActorBeginOverlap(OtherActor)
--end

--function BP_DefaultWeapon_C:ReceiveActorEndOverlap(OtherActor)
--end

return BP_DefaultWeapon_C
