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

local UI_Start_C = Class()

function UI_Start_C:Initialize(Initializer)
    self.ProfData = {}
    self.ProfData[0] = {Mesh='/Game/Role/Swat/Swat.Swat', Anim='/Game/Blueprint/Swat/ABP_Swat.ABP_Swat', RTT='/Game/UI/RT/RTT_Character.RTT_Character', Prof=1}
    self.ProfData[1] = {Mesh='/Game/Role/Sophie/Sophie.Sophie', Anim='/Game/Blueprint/Sophie/ABP_Sophie.ABP_Sophie', RTT='/Game/UI/RT/RTT_Character_2.RTT_Character_2', Prof=2}
    self.ProfData[2] = {Mesh='/Game/Role/Alex/Alex.Alex', Anim='/Game/Blueprint/Alex/ABP_Alex.ABP_Alex', RTT='/Game/UI/RT/RTT_Character_3.RTT_Character_3', Prof=3}

    self.PreviewActorClass = "/Game/BP_New/Record3D_Swat.Record3D_Swat_C"
    self.PreviewWeaponClass = "/Game/BP_New/Weapon/BP_Weapon.BP_Weapon"
end

--function UI_Start_C:PreConstruct(IsDesignTime)
--end

function UI_Start_C:Construct()
    self.btnCreate.OnPressed:Add(self, UI_Start_C.OnClickCreate)
    self.btnJoin.OnPressed:Add(self, UI_Start_C.OnClickJoin)

    local GameInstance = UE4.UGameplayStatics.GetGameInstance(self)
    local World = GameInstance:GetWorld()
    if not World then
        return
    end
    local PlayerClass = nil
    PlayerClass = UE4.UClass.Load(self.PreviewActorClass)
    
    self:CreatePlayer(World, PlayerClass, UE4.FVector(5000000.0, -10000, 0), self.ProfData[0])
    self:CreatePlayer(World, PlayerClass, UE4.FVector(5000000.0, -20000, 0), self.ProfData[1])
    self:CreatePlayer(World, PlayerClass, UE4.FVector(5000000.0, -30000, 0), self.ProfData[2])

    self.UI_Character_0.btnCharacter.OnPressed:Add(self, UI_Start_C.OnClickCharacter0)
    self.UI_Character_1.btnCharacter.OnPressed:Add(self, UI_Start_C.OnClickCharacter1)
    self.UI_Character_2.btnCharacter.OnPressed:Add(self, UI_Start_C.OnClickCharacter2)
    self:OnClickCharacter0()

    self:Init()
    GameMgr:ShowGameInfo()
end

function UI_Start_C:CreatePlayer(TheWorld, PlayerClass, Translation, ProfData)
    local Transform = UE4.FTransform()
    Transform.Translation = Translation
    local Player = TheWorld:SpawnActor(PlayerClass, Transform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, self, self)
    if Player == nil then
        print('SpawnActor Failed!!!')
        return
    end

    Player.SkeletalMesh:SetAnimationMode(0)
    local Mesh = UE4.UObject.Load(ProfData.Mesh)
    Player.SkeletalMesh:SetSkeletalMesh(Mesh)
    local AnimAsset = UE4.UClass.Load(ProfData.Anim)
    Player.SkeletalMesh:SetAnimClass(AnimAsset)

    local texture = UE4.UObject.Load(ProfData.RTT)
    Player.SceneCapture.TextureTarget = texture

	local WeaponClass = UE4.UClass.Load(self.PreviewWeaponClass)
	local NewWeapon = TheWorld:SpawnActor(WeaponClass, UE4.FTransform(), UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, self, self)
    NewWeapon:K2_AttachToComponent(Player.SkeletalMesh, "RightHandSocket", UE4.EAttachmentRule.SnapToTarget,UE4.EAttachmentRule.SnapToTarget,UE4.EAttachmentRule.SnapToTarget)
end

function UI_Start_C:OnClickCharacter0()
    self.SelectedPorfIndex = 1
    self:SetSelectedVisibility(false)
    self.UI_Character_0.imgSelected:SetVisibility(0)
end

function UI_Start_C:OnClickCharacter1()
    self.SelectedPorfIndex = 2
    self:SetSelectedVisibility(false)
    self.UI_Character_1.imgSelected:SetVisibility(0)
end

function UI_Start_C:OnClickCharacter2()
    self.SelectedPorfIndex = 3
    self:SetSelectedVisibility(false)
    self.UI_Character_2.imgSelected:SetVisibility(0)
end

function UI_Start_C:SetSelectedVisibility(bShow)
    if bShow then
        self.UI_Character_0.imgSelected:SetVisibility(0)
        self.UI_Character_1.imgSelected:SetVisibility(0)
        self.UI_Character_2.imgSelected:SetVisibility(0)
    else
        self.UI_Character_0.imgSelected:SetVisibility(1)
        self.UI_Character_1.imgSelected:SetVisibility(1)
        self.UI_Character_2.imgSelected:SetVisibility(1)
    end
end

function UI_Start_C:Init()
    local GameInstance = UE4.UGameplayStatics.GetGameInstance(self)
    if not GameInstance then
        return
    end
    if GameInstance.PlayerInfo.Name ~= '' then
        self.txtPlayerName:SetText(GameInstance.PlayerInfo.Name)
    end
    self.ComboBoxTeam:SetSelectedIndex(GameInstance.PlayerInfo.Team)
    if GameInstance.PlayerInfo.Prof == 1 then
        self:OnClickCharacter0()
    elseif  GameInstance.PlayerInfo.Prof == 2 then
        self:OnClickCharacter1()
    elseif  GameInstance.PlayerInfo.Prof == 3 then
        self:OnClickCharacter2()
    end
end

function UI_Start_C:OnClickCreate()
    local GameInstance = UE4.UGameplayStatics.GetGameInstance(self)
    GameInstance.PlayerInfo.Status = 'Server'
    GameInstance.PlayerInfo.Name = self.txtPlayerName:GetText()
    local selectedIndex = self.ComboBoxTeam:GetSelectedIndex()
    GameInstance.PlayerInfo.Team = selectedIndex
    GameInstance.PlayerInfo.Prof = self.SelectedPorfIndex

    local UCLass = UE4.UClass.Load('/Game/UI/UI_CreateRoom.UI_CreateRoom')
    if UCLass == nil then
        return
    end
    local child = UE4.UWidgetBlueprintLibrary.Create(self, UCLass, nullptr)
    child:AddtoViewport()
    local Controller = self:GetOwningPlayer()
    UE4.UWidgetBlueprintLibrary.SetInputMode_GameAndUIEx(Controller)
    self:RemoveFromParent()
end

function UI_Start_C:OnClickJoin()
    local GameInstance = UE4.UGameplayStatics.GetGameInstance(self)
    GameInstance.PlayerInfo.Status = 'Client'
    GameInstance.PlayerInfo.Name = self.txtPlayerName:GetText()
    local selectedIndex = self.ComboBoxTeam:GetSelectedIndex()
    GameInstance.PlayerInfo.Team = selectedIndex
    GameInstance.PlayerInfo.Prof = self.SelectedPorfIndex

    local UCLass = UE4.UClass.Load('/Game/UI/UI_JoinRoom.UI_JoinRoom')
    if UCLass == nil then
        return
    end
    local child = UE4.UWidgetBlueprintLibrary.Create(self, UCLass, nullptr)
    child:AddtoViewport()
    self:RemoveFromParent()
end

return UI_Start_C
