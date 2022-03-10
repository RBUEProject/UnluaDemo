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

local UI_ChatFrame_C = Class()

function UI_ChatFrame_C:Event_UpdateNewMessage(InText)
    local UCLass = UE4.UClass.Load('/Game/UI/UI_ChatLine.UI_ChatLine')
    if UCLass == nil then
        return
    end
    local child = UE4.UWidgetBlueprintLibrary.Create(self, UCLass, nullptr)
    child.txtMessage:SetText(InText)
    self.MessageContainer:AddChild(child)
end

--function UI_ChatFrame_C:Initialize(Initializer)
--end

--function UI_ChatFrame_C:PreConstruct(IsDesignTime)
--end

function UI_ChatFrame_C:Construct()
    self.btnSend.OnPressed:Add(self, UI_ChatFrame_C.OnClickSend)
    self.txtMessageInput.OnTextCommitted:Add(self, UI_ChatFrame_C.OnTextCommit)
end

function UI_ChatFrame_C:OnTextCommit(Text, Type)
    if Type == 1 then
        self:OnClickSend()
    end
end

function UI_ChatFrame_C:OnClickSend()
    local Controller = self:GetOwningPlayer()
    Controller:Event_AddChatInfo(Controller.PlayerInfo.Name, self.txtMessageInput:GetText())
    self.txtMessageInput:SetText('')
end

--function UI_ChatFrame_C:Tick(MyGeometry, InDeltaTime)
--end

return UI_ChatFrame_C
