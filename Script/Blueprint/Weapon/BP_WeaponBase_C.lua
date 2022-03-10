--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

require "UnLua"

local BP_WeaponBase_C = Class()

--function BP_WeaponBase_C:Initialize(Initializer)
--end

function BP_WeaponBase_C:UserConstructionScript()
    self.IsFiring = false
    self.WeaponTraceDistance = 100000.0
    self.MuzzleSocketName = nil
end

function BP_WeaponBase_C:StartFire()
    if self.IsFiring then
        return
    end
    self.IsFiring = true;
    self:FireAmmunition()
end

function BP_WeaponBase_C:StopFire()
    if not self.IsFiring then
        return
    end
    self.IsFiring = false;
end

function BP_WeaponBase_C:FireAmmunition()
    self:ProjectileFire()
end

function BP_WeaponBase_C:ProjectileFire()
    self:SpawnProjectile()
end

function BP_WeaponBase_C:SpawnProjectile()
    return nil
end

function BP_WeaponBase_C:GetFireInfo()
    local TraceStart, TraceDirection = UE4.UBPI_Interfaces_C.GetWeaponTraceInfo(self.Instigator)

    local Translation = self.SkeletalMesh:GetSocketLocation(self.MuzzleSocketName)
    TraceStart = Translation
    local Delta = TraceDirection * self.WeaponTraceDistance
    local TraceEnd = TraceStart + Delta

    local HitResult = UE4.FHitResult()
    local bResult = UE4.UKismetSystemLibrary.LineTraceSingle(self, TraceStart, TraceEnd, UE4.ETraceTypeQuery.Weapon, false, nil, UE4.EDrawDebugTrace.ForDuration, HitResult, true)
	
    local Rotation
    if bResult then
        local ImpactPoint = HitResult.ImpactPoint
		Rotation = UE4.UKismetMathLibrary.FindLookAtRotation(Translation, ImpactPoint)
    else
        Rotation = UE4.UKismetMathLibrary.FindLookAtRotation(Translation, TraceEnd)
    end
    local Transform = UE4.FTransform(Rotation:ToQuat(), Translation)
	return Transform
end



--function BP_WeaponBase_C:ReceiveBeginPlay()
--end

--function BP_WeaponBase_C:ReceiveEndPlay()
--end

-- function BP_WeaponBase_C:ReceiveTick(DeltaSeconds)
-- end

--function BP_WeaponBase_C:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
--end

--function BP_WeaponBase_C:ReceiveActorBeginOverlap(OtherActor)
--end

--function BP_WeaponBase_C:ReceiveActorEndOverlap(OtherActor)
--end

return BP_WeaponBase_C
