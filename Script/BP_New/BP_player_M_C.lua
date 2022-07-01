

require "UnLua"

local BP_player_M_C = Class()

function BP_player_M_C:Initialize(Initializer)
    if Initializer then
        -- self.BaseColor = Initializer[0]
        self.InProf = Initializer[0]
    end
    self.bMySelf = true
end

function BP_player_M_C:ReceiveBeginPlay()
    self.Life = 500
    self.MaxLife = 500
    if self:HasAuthority() then
        local Weapon = self:SpawnWeapon()
        if Weapon then
            Weapon:K2_AttachToComponent(self.Mesh, "RightHandSocket", UE4.EAttachmentRule.SnapToTarget,UE4.EAttachmentRule.SnapToTarget,UE4.EAttachmentRule.SnapToTarget)
            self.Weapon = Weapon
        end
    end
    if self:HasAuthority() then
        if self.BaseColor ~= nil then
            self.Color = self.BaseColor
        end
        if self.InProf ~= nil then
            self.prof = self.InProf
        end
    end
    
    self.Mesh:SetAnimationMode(0)
    if self.prof == 1 then
        self:ChangeMesh('/Game/Role/Swat/Swat.Swat', '/Game/Blueprint/Swat/ABP_Swat.ABP_Swat')
    elseif self.prof == 2 then
        self:ChangeMesh('/Game/Role/Sophie/Sophie.Sophie', '/Game/Blueprint/Sophie/ABP_Sophie.ABP_Sophie')
    elseif self.prof == 3 then
        self:ChangeMesh('/Game/Role/Alex/Alex.Alex', '/Game/Blueprint/Alex/ABP_Alex.ABP_Alex')
    end
    -- local MID = self.Mesh:CreateDynamicMaterialInstance(0)
	-- if MID and self.Color then
	-- 	MID:SetVectorParameterValue("BodyColor", self.Color)
    -- end
    
    local HPBar = self.HPBar:GetUserWidgetObject()
    self.HPBar:SetVisibility(false)
    HPBar.hpBar:SetPercent(1)
    local Player0 = UE4.UGameplayStatics.GetPlayerCharacter(self, 0)
    if Player0 and Player0.PlayerInfo.Name ~= self.PlayerInfo.Name then
        self.bMySelf = false
        self.HPBar:SetVisibility(true)
        return
    end
end

function BP_player_M_C:ChangeMesh(strMesh, strAnim)
    local Mesh = UE4.UObject.Load(strMesh)
    self.Mesh:SetSkeletalMesh(Mesh)
    local AnimAsset = UE4.UClass.Load(strAnim)
    self.Mesh:SetAnimClass(AnimAsset)
end

function BP_player_M_C:SpawnWeapon()
    local World = self:GetWorld()
	if not World then
		return
	end
	local WeaponClass = UE4.UClass.Load("/Game/BP_New/Weapon/BP_Weapon.BP_Weapon")
	local NewWeapon = World:SpawnActor(WeaponClass, UE4.FTransform(), UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, self, self)
	return NewWeapon
end


function BP_player_M_C:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
    if self.IsDead then
        return
    end

    local Controller = self:GetController()
    if Controller.PlayerInfo.Team == InstigatedBy.PlayerInfo.Team then
       return
    end

    Controller:Event_Hurt(Controller.PlayerInfo.Name, InstigatedBy.PlayerInfo.Name, Damage)
end

function BP_player_M_C:Died()
    self.IsDead = true
    self.CapsuleComponent:SetCollisionEnabled(UE4.ECollisionEnabled.NoCollision)
    local Controller = self:GetController()
    if Controller then
        Controller:UnPossess()
    end
    self.TimerDie = UE4.UKismetSystemLibrary.K2_SetTimerDelegate({self, BP_player_M_C.Destory}, 15, true)
end

function BP_player_M_C:Destory()
    if self.Weapon then
        self.Weapon:K2_DestroyActor()
        self.Weapon = nil
    end
    self:K2_DestroyActor()
end

function BP_player_M_C:Fire_RPC(Dir)
    if self.Weapon == nil then
        return
    end
    self.Weapon:Event_Fire(Dir)
end

--function BP_player_M_C:ReceiveEndPlay()
--end

function BP_player_M_C:ReceiveTick(DeltaSeconds)
    if  self.bMySelf then
        return
    end

    if self.IsDead then
        self.HPBar:SetVisibility(false)
        return
    end

    local cameraLoc = UE4.UGameplayStatics.GetPlayerCameraManager(self, 0):GetCameraLocation()
    local hpLoc = self.HPBar:K2_GetComponentLocation()
    local rot = UE4.UKismetMathLibrary.FindLookAtRotation(hpLoc, cameraLoc)
    self.HPBar:K2_SetWorldRotation(rot)
end

--function BP_player_M_C:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
--end

--function BP_player_M_C:ReceiveActorBeginOverlap(OtherActor)
--end

--function BP_player_M_C:ReceiveActorEndOverlap(OtherActor)
--end

return BP_player_M_C
