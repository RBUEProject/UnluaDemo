--
-- DESCRIPTION
--
-- @COMPANY ngcod.com
-- @AUTHOR LV 天空游荡的鱼
-- QQ:708888157
-- @DATE ${date} ${time}
--

require "UnLua"

local BP_Weapon_C = Class()

--function BP_Weapon_C:Initialize(Initializer)
--end

function BP_Weapon_C:UserConstructionScript()
    self.WeaponTraceDistance = 100000.0
    self.MuzzleSocketName = "Muzzle"
    self.ProjectileClass = UE4.UClass.Load("/Game/Blueprint/Weapon/BP_DefaultProjectile.BP_DefaultProjectile")
    self.World = self:GetWorld()
    self.PrimaryActorTick.bCanEverTick = true
end

function BP_Weapon_C:ReceiveBeginPlay()
    self.PrimaryActorTick.bCanEverTick = true
end

function BP_Weapon_C:ReceiveTick(DeltaSeconds)
    if self.Instigator then
        local controller = self.Instigator:GetController()
        local controller0 = UE4.UGameplayStatics.GetPlayerController(self.Instigator, 0)

        if controller == nil or controller0 == nil then
            return
        end
        if controller.PlayerInfo.Status == controller0.PlayerInfo.Status then
            self:GetFireInfo()
        end
    end
end

function BP_Weapon_C:Event_Fire(Dir)
    self:SpawnProjectile(Dir)
end

function BP_Weapon_C:SpawnProjectile(Dir)
    if self.ProjectileClass then
        local Transform = self:GetFireInfo(Dir)
		local R = UE4.UKismetMathLibrary.RandomFloat()
		local G = UE4.UKismetMathLibrary.RandomFloat()
		local B = UE4.UKismetMathLibrary.RandomFloat()
		local BaseColor = {}
		BaseColor[0] = UE4.FLinearColor(R, G, B, 1.0)
		local Projectile = self.World:SpawnActor(self.ProjectileClass, Transform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, self, self.Instigator, "Blueprint.Weapon.BP_DefaultProjectile_C", BaseColor)
	end
end

function BP_Weapon_C:GetFireInfo(Dir)
    local Transform = UE4.FTransform()
    local Camera = self.Instigator.Camera
    if Camera == nil then 
        return Transform
    end

    local TraceStart = Camera:K2_GetComponentLocation()
    local Translation = self.SkeletalMesh:GetSocketLocation(self.MuzzleSocketName)
    TraceStart = Translation

    local controller = UE4.UGameplayStatics.GetPlayerController(self.Instigator, 0)
    if Dir == nil then
        local ViewportSize = UE4.UWidgetLayoutLibrary.GetViewportSize(self.Instigator)
        ViewportSize.X = 0.5 * ViewportSize.X
        ViewportSize.Y = 0.5 * ViewportSize.Y
        
        local WorldLoc = UE4.FVector()
        local WorldDir = UE4.FVector()
        controller:DeprojectScreenPositionToWorld(ViewportSize.X, ViewportSize.Y, WorldLoc, WorldDir)
        Dir = WorldDir
    end
    
    local Delta = Dir * self.WeaponTraceDistance
    local TraceEnd = TraceStart + Delta

    local HitResult = UE4.FHitResult()
    local bResult = UE4.UKismetSystemLibrary.LineTraceSingle(self, TraceStart, TraceEnd, UE4.ETraceTypeQuery.Weapon, false, nil, UE4.EDrawDebugTrace.ForOneFrame, HitResult, true)
	
    local Rotation
    if bResult then
        TraceEnd = HitResult.ImpactPoint
    else
        TraceEnd = HitResult.TraceEnd
    end
    Rotation = UE4.UKismetMathLibrary.FindLookAtRotation(Translation, TraceEnd)

    self:UpdateCross(controller, TraceEnd)
    local Transform = UE4.FTransform(Rotation:ToQuat(), Translation)
	return Transform
end

function BP_Weapon_C:UpdateCross(controller, TraceEnd)
    if controller == nil then
        return
    end
    local hudClass = controller:GetHUD()
    if hudClass == nil then
        return
    end
    if hudClass.HUD == nil then
        return
    end
    local ViewportPos = UE4.FVector2D()
    controller:ProjectWorldLocationToScreen(TraceEnd, ViewportPos, fasle)
    ViewportPos.X = ViewportPos.X - 8
    ViewportPos.Y = ViewportPos.Y - 8
    controller:GetHUD().HUD:SetPositionInViewport(ViewportPos)
end

return BP_Weapon_C
