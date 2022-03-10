--
-- DESCRIPTION
--
-- @COMPANY www.ngcod.com
-- @AUTHOR 天空游荡的鱼
-- QQ:708888157
--
-- @DATE ${date} ${time}
--

require "UnLua"

local UI_GameScore_C = Class()

function UI_GameScore_C:UpdateInfo(InPlayerInfos)
    self.MessageContainer:ClearChildren()
    local PlayerInfos = InPlayerInfos:ToTable()
    for index, value in ipairs(PlayerInfos) do
        local UCLass = UE4.UClass.Load('/Game/UI/UI_ScoreLine.UI_ScoreLine')
        local child = UE4.UWidgetBlueprintLibrary.Create(self, UCLass, nullptr)
        local slot = self.MessageContainer:AddChild(child)
        local Margin = UE4.FMargin()
        Margin.Left = 2
        Margin.Top = 2
        Margin.Right = 2
        slot:SetPadding(Margin)
        child:UpdateInfo(value)
    end
end

return UI_GameScore_C
