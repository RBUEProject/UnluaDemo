--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

require "UnLua"

local BP_PlayerController_C = Class()

--function BP_PlayerController_C:Initialize(Initializer)
--end

--function BP_PlayerController_C:UserConstructionScript()
--end

function BP_PlayerController_C:ReceiveBeginPlay()
    self.ControlRot = UE4.FRotator()
    self.ForwardVec = UE4.FVector()
    self.RightVec = UE4.FVector()
end

--function BP_PlayerController_C:ReceiveEndPlay()
--end

-- function BP_PlayerController_C:ReceiveTick(DeltaSeconds)
-- end

--function BP_PlayerController_C:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
--end

--function BP_PlayerController_C:ReceiveActorBeginOverlap(OtherActor)
--end

--function BP_PlayerController_C:ReceiveActorEndOverlap(OtherActor)
--end
function BP_PlayerController_C:MoveForward(AxisValue)
    if self.Pawn then
        local Rotation = self:GetControlRotation(self.ControlRot)
        Rotation:Set(0, Rotation.Yaw, 0)
        local Direction = Rotation:ToVector(self.MoveForwardVec)
        self.Pawn:AddMovementInput(Direction, AxisValue)
    end
end

function BP_PlayerController_C:MoveRight(AxisValue)
    if self.Pawn then
        local Rotation = self:GetControlRotation(self.ControlRot)
        Rotation:Set(0, Rotation.Yaw, 0)
        local Direction = Rotation:GetRightVector(self.RightVec)
        self.Pawn:AddMovementInput(Direction, AxisValue)
    end
end

function BP_PlayerController_C:Turn(AxisValue)
    self:AddYawInput(AxisValue)
end

function BP_PlayerController_C:LookUp(AxisValue)
    self:AddPitchInput(AxisValue)
end

function BP_PlayerController_C:Fire_Pressed()
    if not self.Pawn then
        return
    end
    local MyInterface = UE4.UBPI_Interfaces_C
    if MyInterface then 
        MyInterface.StartFire(self.Pawn, true)
    end
end

function BP_PlayerController_C:Fire_Released()
    if not self.Pawn then
        return
    end
    local MyInterface = UE4.UBPI_Interfaces_C
    if MyInterface then 
        MyInterface.StopFire(self.Pawn, true)
    end
end

function BP_PlayerController_C:Aim_Pressed()
    if not self.Pawn then
        return
    end
    local MyInterface = UE4.UBPI_Interfaces_C
    if MyInterface then 
        MyInterface.UpdateAiming(self.Pawn, true)
    end
end

function BP_PlayerController_C:Aim_Released()
    if not self.Pawn then
        return
    end
    local MyInterface = UE4.UBPI_Interfaces_C
    if MyInterface then 
        MyInterface.UpdateAiming(self.Pawn, false)
    end
    --self.Pawn:UpdateAiming(false)
end

function BP_PlayerController_C:Event_AddPlayerInfo_RPC(PlayerInfo)
    local GameMode = UE4.UGameplayStatics.GetGameMode(self)
    if GameMode then
        GameMode:Event_AddPlayerInfo(PlayerInfo)
    end
end

function BP_PlayerController_C:Event_Init()
    local GameInstance = UE4.UGameplayStatics.GetGameInstance(self)
    self.PlayerInfo = GameInstance.PlayerInfo
    self:Event_AddPlayerInfo(self.PlayerInfo)
end

function BP_PlayerController_C:ShowChat()
    local UCLass = UE4.UClass.Load('/Game/UI/UIChat.UIChat')
    if UCLass == nil then
        return
    end
    local child = UE4.UWidgetBlueprintLibrary.Create(self, UCLass, nullptr)
    child:AddToViewport()
    self.UIChat = child
end

---
--- RPC
---
function BP_PlayerController_C:Event_UpateSelf_RPC(PlayerInfos, MapName, MaxPlayer)
    if self.UILobby ~= nil then
        self.UILobby:Event_UpdateInfo(PlayerInfos, MaxPlayer, MapName)
    end
end

function BP_PlayerController_C:Event_UpdatePlayerInfo_RPC(PlayerInfo)
    local GameMode = UE4.UGameplayStatics.GetGameMode(self)
    if GameMode then
        GameMode:Event_UpdatePlayerInfo(PlayerInfo)
    end
end

function BP_PlayerController_C:Event_UpdateAllPlayer_RPC()
    local GameMode = UE4.UGameplayStatics.GetGameMode(self)
    if GameMode then
        GameMode:UpdateAllPlayer()
    end
end

function BP_PlayerController_C:Event_ShowLobbyUI_RPC()
    print('LV::BP_PlayerController_C:Event_ShowLobbyUI_RPC')
    self.bShowMouseCursor = true
    local UCLass = UE4.UClass.Load('/Game/UI/UI_Lobby.UI_Lobby')
    if UCLass == nil then
        return
    end
    local child = UE4.UWidgetBlueprintLibrary.Create(self, UCLass, nullptr)
    child:AddToViewport()
    self.UILobby = child
    UE4.UWidgetBlueprintLibrary.SetInputMode_GameAndUIEx(self, child)

    self:ShowChat()
    self:Event_Init()
    self:Event_UpdateAllPlayer()
end

function BP_PlayerController_C:Event_AddChatInfo_RPC(Name, Message)
    local GameMode = UE4.UGameplayStatics.GetGameMode(self)
    if GameMode then
        GameMode:AddChatInfo(Name, Message)
    end
end

function BP_PlayerController_C:Event_NewMessage_RPC(Message)
    if self.UIChat ~= nil then
        self.UIChat.UI_ChatFrame:Event_UpdateNewMessage(Message)
    end
end

function BP_PlayerController_C:Event_showLoading_RPC()
    local UCLass = UE4.UClass.Load('/Game/UI/UI_Loading.UI_Loading')
    if UCLass == nil then
        return
    end
    local child = UE4.UWidgetBlueprintLibrary.Create(self, UCLass, nullptr)
    child:AddToViewport()
end

return BP_PlayerController_C
