
require "UnLua"

local BP_PlayerController_M_C = Class()

function BP_PlayerController_M_C:ReceiveBeginPlay()
    self.ControlRot = UE4.FRotator()
    self.ForwardVec = UE4.FVector()
    self.RightVec = UE4.FVector()
    -- if self:HasAuthority() then
    --     self.PlayerInfo = UE4.UGameplayStatics.GetGameInstance(self).PlayerInfo
    --     print('地图名称:'  .. PlayerInfo.Name)
    -- end
end

function BP_PlayerController_M_C:MoveForward(AxisValue)
    if self.Pawn then
        local Rotation = self:GetControlRotation(self.ControlRot)
        Rotation:Set(0, Rotation.Yaw, 0)
        local Direction = Rotation:ToVector(self.MoveForwardVec)
        self.Pawn:AddMovementInput(Direction, AxisValue)
    end
end

function BP_PlayerController_M_C:MoveRight(AxisValue)
    if self.Pawn then
        local Rotation = self:GetControlRotation(self.ControlRot)
        Rotation:Set(0, Rotation.Yaw, 0)
        local Direction = Rotation:GetRightVector(self.RightVec)
        self.Pawn:AddMovementInput(Direction, AxisValue)
    end
    
end

function BP_PlayerController_M_C:Turn(AxisValue)
    self:AddYawInput(AxisValue)
end

function BP_PlayerController_M_C:LookUp(AxisValue)
    self:AddPitchInput(AxisValue)
end

function BP_PlayerController_M_C:Fire_Pressed()
    if not self.Pawn then
        return
    end
    self:Fire()
end

function BP_PlayerController_M_C:Fire()
    if not self.Pawn then
        return
    end
    local Dir = self:GetDirInfo()
    self.Pawn:Fire(Dir)
end

function BP_PlayerController_M_C:Event_UpdatePlayerInfo1()
    local GameMode = UE4.UGameplayStatics.GetGameMode(self)
    if GameMode then
        GameMode:Event_UpdatePlayerInfo(self.PlayerInfo)
    end
end

function BP_PlayerController_M_C:Event_KillMonster()
    local GameMode = UE4.UGameplayStatics.GetGameMode(self)
    if GameMode then
        GameMode:NotifyEnemyDie(self.PlayerInfo.Name)
    end
end

function BP_PlayerController_M_C:Event_KillPlayer(KilledName, InstigatorName)
    local GameMode = UE4.UGameplayStatics.GetGameMode(self)
    if GameMode then
        GameMode:NotifyPlayerDie(KilledName, InstigatorName)
    end
end

function BP_PlayerController_M_C:GetDirInfo()
    local ViewportSize = UE4.UWidgetLayoutLibrary.GetViewportSize(self)
    ViewportSize.X = 0.5 * ViewportSize.X
    ViewportSize.Y = 0.5 * ViewportSize.Y

    local WorldLoc = UE4.FVector()
    local WorldDir = UE4.FVector()
    self:DeprojectScreenPositionToWorld(ViewportSize.X, ViewportSize.Y, WorldLoc, WorldDir)
    return WorldDir
end

---
---SC[RunOnOwningClient]
---更新所有玩家的分数
---
function BP_PlayerController_M_C:Event_UpdateSelf_RPC(PlayerInfos)
    self.UIGameScore:UpdateInfo(PlayerInfos)
end

---
--- SC[RunOnOwningClient]
--- 显示分数UI
---
function BP_PlayerController_M_C:Event_ShowScoreUI_RPC()
    self.bShowMouseCursor = true
    local UCLass = UE4.UClass.Load('/Game/UI/UI_GameScore.UI_GameScore')
    if UCLass == nil then
        return
    end
    local child = UE4.UWidgetBlueprintLibrary.Create(self, UCLass, nullptr)
    if child ~= nil then
        self.UIGameScore = child
        child:AddToViewport()
        UE4.UWidgetBlueprintLibrary.SetInputMode_GameAndUIEx(self, child)

        local GameInstance = UE4.UGameplayStatics.GetGameInstance(self)
        self.PlayerInfo = GameInstance.PlayerInfo
        self:Event_AddPlayerInfo(self.PlayerInfo)
    end
end

---
--- CS[RunOnServer]
--- 将客户端的PlayerInfo传输给服务器
---
function BP_PlayerController_M_C:Event_AddPlayerInfo_RPC(PlayerInfo)
    local GameMode = UE4.UGameplayStatics.GetGameMode(self)
    if GameMode then
        GameMode:Event_AddPlayerInfo(PlayerInfo)
    end
end

---
--- CS[RunOnServer]
--- 同步攻击者和受击者
---
function BP_PlayerController_M_C:Event_Hurt_RPC(KilledName, InstigatorName, Damage)
    local GameMode = UE4.UGameplayStatics.GetGameMode(self)
    if GameMode then
        GameMode:Hurt(KilledName, InstigatorName, Damage)
    end
end

---
--- SC[RunOnOwningClient]
--- 同步谁受到攻击到客户端
---
function BP_PlayerController_M_C:Hurt_RPC(Name, InstigatorName, NewLife)
    local class = UE4.UClass.Load('/Game/BP_New/BP_player_M.BP_player_M')
    local results = UE4.TArray(UE4.AActor)
    UE4.UGameplayStatics.GetAllActorsOfClass(self, class, results)
    local pawns = results:ToTable()
    for index, value in ipairs(pawns) do
        local Pawn = value
        if Pawn.PlayerInfo.Name == Name then
            local HPBar = Pawn.HPBar:GetUserWidgetObject()
            local percent = 1.0
            percent = NewLife / Pawn.PlayerInfo.MaxLife
            HPBar.hpBar:SetPercent(percent)

            if NewLife <= 0 then
                Pawn:Died()
            end
        end
    end
end

---
--- SC[RunOnOwningClient]
--- 服务器通知客户端显示死亡界面
---
function BP_PlayerController_M_C:Event_ShowDeathUI_RPC(PlayerInfo, Killer)
    local UCLass = UE4.UClass.Load('/Game/UI/RebornUI.RebornUI')
    if UCLass == nil then
        return
    end
    local child = UE4.UWidgetBlueprintLibrary.Create(self, UCLass, nullptr)
    if child ~= nil then
        child:AddtoViewport()
    end
    child:Update(PlayerInfo, Killer)
end

--- 这里不能重写蓝图的方法，蓝图中申明了是OnServer的方法
--- 由客户端界面直接出发Event_Reborn，获取不到GameMode(GameMode只存在于服务端)
function BP_PlayerController_M_C:K2_Reborn()
    local GameMode = UE4.UGameplayStatics.GetGameMode(self)
    if GameMode then
        GameMode:Reborn(self.PlayerInfo)
    end
end

function BP_PlayerController_M_C:K2_Hurt(InKilledName, InInstigatorName)
    self:Hurt(InKilledName)
end

return BP_PlayerController_M_C
