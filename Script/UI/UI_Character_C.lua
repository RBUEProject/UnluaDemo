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

local UI_Character_C = Class()

--function UI_Character_C:Initialize(Initializer)
--end

--function UI_Character_C:PreConstruct(IsDesignTime)
--end

function UI_Character_C:Construct()
    local Material = nil
    local texture = nil
    local Normal = self.btnCharacter.WidgetStyle.Normal
    Material = UE4.UWidgetBlueprintLibrary.GetBrushResourceAsMaterial(Normal)
    if self.TextID == 0 then
        texture = UE4.UObject.Load('/Game/UI/RT/RTT_Character.RTT_Character')
    elseif self.TextID == 1 then
        texture = UE4.UObject.Load('/Game/UI/RT/RTT_Character_2.RTT_Character_2')
    else
        texture = UE4.UObject.Load('/Game/UI/RT/RTT_Character_3.RTT_Character_3')
    end
    Material = UE4.UKismetMaterialLibrary.CreateDynamicMaterialInstance(self, Material)
    Material:SetTextureParameterValue('MainTex', texture)

    UE4.UWidgetBlueprintLibrary.SetBrushResourceToMaterial(Normal, Material)
    UE4.UWidgetBlueprintLibrary.SetBrushResourceToMaterial(self.btnCharacter.WidgetStyle.Hovered, Material)
    UE4.UWidgetBlueprintLibrary.SetBrushResourceToMaterial(self.btnCharacter.WidgetStyle.Pressed, Material)
end

--function UI_Character_C:Tick(MyGeometry, InDeltaTime)
--end

return UI_Character_C
