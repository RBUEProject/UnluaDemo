require "UnLua"

local BP_CharacterBase_C = Class()

function BP_CharacterBase_C:Initialize(Initializer)
    self.Life = 100
end

--function BP_CharacterBase_C:UserConstructionScript()
--end
function BP_CharacterBase_C:NotifyEnemyDied()
end

function BP_CharacterBase_C:ReceiveBeginPlay()
    print("BP_CharacterBase_C:ReceiveBeginPlay")
    local Weapon = self:SpawnWeapon()
    if Weapon then
        print("weapon is not nil")
        Weapon:K2_AttachToComponent(self.WeaponPoint, nil, UE4.EAttachmentRule.SnapToTarget,UE4.EAttachmentRule.SnapToTarget,UE4.EAttachmentRule.SnapToTarget)
        self.Weapon = Weapon
    end
end

function BP_CharacterBase_C:StartFire()
    if self.Weapon then
        print("BP_CharacterBase_C StartFire")
        self.Weapon:StartFire()
    end
end

function BP_CharacterBase_C:StopFire()
    if self.Weapon then
        self.Weapon:StopFire()
    end
end

function BP_CharacterBase_C:SpawnWeapon()
    return nil
end

--function BP_CharacterBase_C:ReceiveEndPlay()
--end

-- function BP_CharacterBase_C:ReceiveTick(DeltaSeconds)
-- end

function BP_CharacterBase_C:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
    if self.IsDead then
        return
    end
    self.Life = math.max(self.Life - Damage, 0)
    if self.Life <= 0 then
        self:Died()
        self.TimerDie = UE4.UKismetSystemLibrary.K2_SetTimerDelegate({self, BP_CharacterBase_C.Destory}, 5, true)
    end
end

function BP_CharacterBase_C:Died()
    self.IsDead = true
    self.CapsuleComponent:SetCollisionEnabled(UE4.ECollisionEnabled.NoCollision)
    local Controller = self:GetController()
    if Controller then
        Controller:UnPossess()
    end

    local MyInterface = UE4.UBPI_Interfaces_C
    local mode = UE4.UGameplayStatics.GetGameMode(self)
    MyInterface.NotifyEnemyDied(mode)
end

function BP_CharacterBase_C:Destory()
    if self.Weapon then
        self.Weapon:K2_DestroyActor()
    end
    self:K2_DestroyActor()
end
--function BP_CharacterBase_C:ReceiveActorBeginOverlap(OtherActor)
--end

--function BP_CharacterBase_C:ReceiveActorEndOverlap(OtherActor)
--end

return BP_CharacterBase_C
