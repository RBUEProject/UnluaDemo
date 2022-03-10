--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

require "UnLua"

local UI_Lobby_C = Class()

--function UI_Lobby_C:Initialize(Initializer)
--end

--function UI_Lobby_C:PreConstruct(IsDesignTime)
--end

function UI_Lobby_C:Construct()
    local GameInstance = UE4.UGameplayStatics.GetGameInstance(self)
    if GameInstance.PlayerInfo.Status == "Server" then
        self.txtReadyText:SetText('开始')
    else
        self.txtReadyText:SetText('准备')
    end

    self.txtMapName:SetText(GameInstance.MapName)
    self.btnLeave.OnPressed:Add(self, UI_Lobby_C.OnClickLeave)
    self.btnReady.OnPressed:Add(self, UI_Lobby_C.OnClickReady)

    -- UE4.UKismetSystemLibrary.K2_SetTimerDelegate({self, UI_Lobby_C.Event_UpdatePlayerList}, 2, true)
end

function UI_Lobby_C:OnClickLeave()
    local Controller = self:GetOwningPlayer()
    Controller:Event_LeaveRoom()
end

function UI_Lobby_C:OnClickReady()
    -- 去准备
    if self.Status == 0 then
        local Controller = self:GetOwningPlayer()
        Controller.PlayerInfo.Ready = true
        Controller:Event_UpdatePlayerInfo(Controller.PlayerInfo)
        return
    end

    -- 取消准备
    if self.Status == 1 then
        local Controller = self:GetOwningPlayer()
        Controller.PlayerInfo.Ready = false
        Controller:Event_UpdatePlayerInfo(Controller.PlayerInfo)
        return
    end

    if self.Status == 4 then
        local GameMode = UE4.UGameplayStatics.GetGameMode(self)
        if GameMode == nil then
            return
        end
        local PlayerList = GameMode.PlayerList:ToTable()
        for index, value in ipairs(PlayerList) do
            value:Event_ShowLoading()
        end
        GameMode:Event_Start()
    end
end

function UI_Lobby_C:Event_UpdateInfo(PlayerInfos, MaxPlayer, MapName)
    self:Event_UpdatePlayerList(PlayerInfos)
    self:Event_UpdateReady(MaxPlayer, PlayerInfos)
    self.txtMapName:SetText(MapName)
end

function UI_Lobby_C:Event_UpdatePlayerList(PlayerInfoList)
    self.PlayerInfoComtainer:ClearChildren()
    local PlayerInfos = PlayerInfoList:ToTable()
    for index, value in ipairs(PlayerInfos) do
        local UCLass = UE4.UClass.Load('/Game/UI/UI_PlayerList.UI_PlayerList')
        local child = UE4.UWidgetBlueprintLibrary.Create(self, UCLass, nullptr)
        self.PlayerInfoComtainer:AddChild(child)
        child:UpdateInfo(index, value)
    end
end

function UI_Lobby_C:Event_UpdateReady(MaxPlayer, PlayerInfoList)
    local Controller = self:GetOwningPlayer()
    local Status = Controller.PlayerInfo.Status
    if Status == "Server" then
        if PlayerInfoList:Length() == MaxPlayer then
            if self:CheckAllReady(PlayerInfoList) then
                self.txtReadyText:SetText("开始游戏")
                self.Status = 4
            else
                self.txtReadyText:SetText("玩家准备中")
                self.Status = 3
            end
        else
            self.txtReadyText:SetText("等待玩家")
            self.Status = 2
        end
    else
        if Controller.PlayerInfo.Ready then
            self.txtReadyText:SetText("取消准备")
            self.Status = 1
        else
            self.txtReadyText:SetText("准备")
            self.Status = 0
        end
    end
end

function UI_Lobby_C:CheckAllReady(PlayerInfoList)
    local PlayerInfos = PlayerInfoList:ToTable()
    for index, value in ipairs(PlayerInfos) do
        if value.Status ~= "Server" and not value.Ready then
            return false
        end
    end
    return true
end

--function UI_Lobby_C:Tick(MyGeometry, InDeltaTime)
--end

return UI_Lobby_C
