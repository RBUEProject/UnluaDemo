--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

require "UnLua"

local UI_ScoreLine_C = Class()

function UI_ScoreLine_C:UpdateInfo(PlayerInfo)
    self.PlayerInfo = PlayerInfo
    self.txtName:SetText(self.PlayerInfo.Name)
    self.txtScore:SetText(tostring(self.PlayerInfo.Score))
end

--function UI_ScoreLine_C:PreConstruct(IsDesignTime)
--end

-- function UI_ScoreLine_C:Construct()
-- end

--function UI_ScoreLine_C:Tick(MyGeometry, InDeltaTime)
--end

return UI_ScoreLine_C
