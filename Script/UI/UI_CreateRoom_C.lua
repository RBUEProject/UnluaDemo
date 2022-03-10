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

local UI_CreateRoom_C = Class()

--function UI_CreateRoom_C:Initialize(Initializer)
--end

--function UI_CreateRoom_C:PreConstruct(IsDesignTime)
--end

function UI_CreateRoom_C:Construct()
    self.btnCreate.OnPressed:Add(self, UI_CreateRoom_C.OnClickCreate)
end

function UI_CreateRoom_C:OnClickCreate()
    local GameInstance = UE4.UGameplayStatics.GetGameInstance(self)
    GameInstance.MapName = self.txtRoomName:GetText()
    GameInstance.MaxPlayer = GameMgr.MAX_PLAYER_COUNT
    local bUseLan = false
    local SelectedOption = self.ComboBoxNet:GetSelectedOption()
    if SelectedOption == "Lan" then
        bUseLan = true
    end

    -- local PlayerController = UE4.UGameplayStatics.GetPlayerController(self, 0)
    -- local SessionProxy = UE4.UCreateSessionCallbackProxy.CreateSession(self, PlayerController, GameInstance.MaxPlayer, bUseLan)
    -- SessionProxy.OnSuccess:Add(self, UI_CreateRoom_C.OnSuccess)
    -- SessionProxy.OnFailure = {self, UI_CreateRoom_C.OnFailure}
    self:CreateSession(GameInstance.MaxPlayer, bUseLan)
end

function UI_CreateRoom_C:OnSuccess()
    print('创建成功')
    UE4.UGameplayStatics.OpenLevel(self, '/Game/Maps/MapLobby', true, 'listen')
end

function UI_CreateRoom_C:OnFailure()
    print('创建失败')
end

--function UI_CreateRoom_C:Tick(MyGeometry, InDeltaTime)
--end

return UI_CreateRoom_C
