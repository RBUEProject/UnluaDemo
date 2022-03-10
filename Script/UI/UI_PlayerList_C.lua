--
-- DESCRIPTION
--
-- @COMPANY ngcod.com
-- @AUTHOR 天空游荡的鱼
-- QQ:708888157
--
-- @DATE 2021.12.28
--

require "UnLua"

local UI_PlayerList_C = Class()

--function UI_PlayerList_C:Initialize(Initializer)
--end

--function UI_PlayerList_C:PreConstruct(IsDesignTime)
--end

function UI_PlayerList_C:Construct()
    self.btnKickout.OnPressed:Add(self, UI_PlayerList_C.OnClickKickout)
end

function UI_PlayerList_C:OnClickKickout()
    local GameMode = UE4.UGameplayStatics.GetGameMode(self)
    if GameMode ~= nil then
        GameMode:Event_KickoutPlayer(self.Index)
    end
end

function UI_PlayerList_C:UpdateInfo(InIndex, PlayerInfo)
    self.Index = InIndex
    self.PlayerInfo = PlayerInfo
    self.txtName:SetText(PlayerInfo.Name)
    if PlayerInfo.Status == "Server" then
        self.btnReady:SetVisibility(1)
        self.btnKickout:SetVisibility(1)
    elseif PlayerInfo.Ready then
        self.btnReady:SetVisibility(1)
    else
        self.btnReady:SetVisibility(0)
    end
end

--function UI_PlayerList_C:Tick(MyGeometry, InDeltaTime)
--end

return UI_PlayerList_C
