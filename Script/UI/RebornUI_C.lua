--
-- DESCRIPTION
--
-- @COMPANY ngcod.com
-- @AUTHOR 天空游荡的鱼
-- QQ:708888157
--
--

require "UnLua"

local RebornUI_C = Class()

--function RebornUI_C:Initialize(Initializer)
--end

--function RebornUI_C:PreConstruct(IsDesignTime)
--end

function RebornUI_C:Construct()
    self.btnReborn.OnPressed:Add(self, RebornUI_C.OnClickReborn)
    self.btnExit.OnPressed:Add(self, RebornUI_C.OnClickExit)
end

function RebornUI_C:OnClickReborn()
    local controller = self:GetOwningPlayer()
    if controller == nil then
        return
    end
    controller:Reborn()
    self:RemoveFromParent()
end

function RebornUI_C:OnClickExit()
    local Controller = self:GetOwningPlayer()
    Controller:Event_LeaveRoom()
end

function RebornUI_C:Update(PlayerInfo, Killer)
    self.txtMessage:SetText('你的总得分为:' .. tostring(PlayerInfo.Score) .. ', 你被' .. Killer .. '打败了')
end

return RebornUI_C
