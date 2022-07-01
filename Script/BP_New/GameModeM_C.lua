

require "UnLua"

local GameModeM_C = Class()

PlayerMaxLife = 500

function GameModeM_C:ReceiveBeginPlay()
    self.MonsterClass = UE4.UClass.Load("/Game/Blueprint/Monster/BP_MonsterCharacter.BP_MonsterCharacter")
    self.OriginLocation = UE4.FVector(450,420,108)
    self.MonsterLocation = UE4.FVector()

    UE4.UKismetSystemLibrary.K2_SetTimerDelegate({self, GameModeM_C.OnTimerGenMonster}, 2, true)
end

function GameModeM_C:Event_AddPlayerInfo(PlayerInfo)
    --初始化生命
    PlayerInfo.Life = PlayerMaxLife
    PlayerInfo.MaxLife = PlayerMaxLife
    local index = self.PlayerInfoList:Add(PlayerInfo)
    local playerController = self.PlayerList:GetRef(index)
    playerController.PlayerInfo = PlayerInfo

    self:SpawnPlayerAndControl(PlayerInfo, playerController)
end

function GameModeM_C:SpawnPlayerAndControl(PlayerInfo, playerController)
    local World = self:GetWorld()
    if not World then
        return
    end

    local PlayerStart = nil 
    local PlayerClass = nil
    
    PlayerClass = UE4.UClass.Load("/Game/BP_New/BP_player_M.BP_player_M")
    if PlayerInfo.Team == 0 then
        PlayerStart = self:FindPlayerStart(playerController, "Red")
    else
        PlayerStart = self:FindPlayerStart(playerController, "Blue")
    end

    local Color = nil
    local Player = nil
    local BaseColor = {}
    BaseColor[0] = PlayerInfo.Prof
    Player = World:SpawnActor(PlayerClass, PlayerStart:GetTransform(), UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, self, self, nil, BaseColor)

    Player.PlayerInfo = PlayerInfo
    playerController:Possess(Player)
    GameMgr:ShowGameInfo()
end

ID = 100
function GameModeM_C:K2_PostLogin(NewPlayer)
    if self:HasAuthority() then
        ID = ID + 1
        NewPlayer.IDX = ID
        self.PlayerList:Add(NewPlayer)
        if NewPlayer.ControlledPawn ~= nil then
            NewPlayer.ControlledPawn:DestoryActor()
        end
        NewPlayer:Event_ShowScoreUI()
    end
end

function GameModeM_C:K2_OnLogout(ExitingController)
    local PlayerList = self.PlayerList:ToTable()
    for index, value in ipairs(PlayerList) do
        if ExitingController == value then
            self.PlayerList:Remove(index)
            self.PlayerInfoList:Remove(index)
        end
    end
    self:UpdateAllPlayer()
end

function GameModeM_C:Reborn(PlayerInfo)
    local TablePlayer = self.PlayerInfoList:ToTable()
    local index = self:GetIndex(TablePlayer, PlayerInfo.Name)
    if index == -1 then
        return
    end
    --初始化生命
    local tempPlayerInfo = self.PlayerInfoList:GetRef(index)
    tempPlayerInfo.Life = PlayerMaxLife
    tempPlayerInfo.MaxLife = PlayerMaxLife

    local PlayerController = self.PlayerList:GetRef(index)
    self:SpawnPlayerAndControl(PlayerInfo, PlayerController)
end

function GameModeM_C:OnTimerGenMonster()
    if GameMgr.IsPause then
        return
    end
    local PlayerCharacter = UE4.UGameplayStatics.GetPlayerCharacter(self, 0)
    if PlayerCharacter == nil then
        return
    end
    if GameMgr.CurrentGenNum ~= GameMgr.MaxNum then
        UE4.UNavigationSystemV1.K2_GetRandomReachablePointInRadius(self, self.OriginLocation, self.MonsterLocation, 2000)
        local PlayerLocation = PlayerCharacter:K2_GetActorLocation()
        local Rot = UE4.UKismetMathLibrary.FindLookAtRotation(self.MonsterLocation, PlayerLocation)
        UE4.UAIBlueprintHelperLibrary.SpawnAIFromClass(self, self.MonsterClass, nil, self.MonsterLocation, Rot)
        GameMgr.CurrentGenNum = GameMgr.CurrentGenNum + 1
        GameMgr.CurrentNum = GameMgr.CurrentNum + 1
    end
end

function GameModeM_C:NotifyEnemyDie(Name)
    self:AddScore(Name)
    GameMgr.CurrentNum = GameMgr.CurrentNum - 1
    if GameMgr.CurrentNum == 0 then
        if GameMgr.Wave % 10 == 0 then
            self.IsPause = true
            local instance = UE4.UGameplayStatics.GetGameInstance(self)
            if GameMgr.Wave < GameMgr.MaxWave then
                instance:NotifyNextLevel()
                return
            end
            --通知C++
        else
            GameMgr.CurrentGenNum = 0
            GameMgr.Wave = GameMgr.Wave + 1
        end
        
    end
    print("Current Wave:" .. GameMgr.Wave .. ", Current Monster:" .. GameMgr.CurrentNum)
end

function GameModeM_C:Hurt(KilledName, InstigatorName, Damage)

    local TablePlayer = self.PlayerInfoList:ToTable()
    local index = self:GetIndex(TablePlayer, KilledName)
    if index == -1 then
        return
    end
    local PlayerInfo = self.PlayerInfoList:GetRef(index)
    PlayerInfo.Life = math.max(PlayerInfo.Life - Damage, 0)

    if PlayerInfo.Life <= 0 then
        self:NotifyPlayerDie(KilledName, InstigatorName)
    end
    local PlayerList = self.PlayerList:ToTable()
    for index, value in ipairs(PlayerList) do
        value:Hurt(KilledName, InstigatorName, PlayerInfo.Life)
    end
end

function GameModeM_C:NotifyPlayerDie(KilledName, InstigatorName)
    self:AddScore(InstigatorName)
    local TablePlayer = self.PlayerInfoList:ToTable()
    local index = self:GetIndex(TablePlayer, KilledName)
    if index == -1 then
        return
    end

    local PlayerController = self.PlayerList:GetRef(index)
    PlayerController:Event_ShowDeathUI(TablePlayer[index], InstigatorName)
end

function GameModeM_C:AddScore(InPlayerName)
    local TablePlayer = self.PlayerInfoList:ToTable()
    local index = self:GetIndex(TablePlayer, InPlayerName)
    if index == -1 then
        print("没找到Index")
        return
    end

    local PlayerInfo = self.PlayerInfoList:GetRef(index)
    PlayerInfo.Score = PlayerInfo.Score + 1
    self:UpdateAllPlayer()
end

function GameModeM_C:GetIndex(TablePlayer, InPlayerName)
    for index, value in ipairs(TablePlayer) do
        if value.Name == InPlayerName then
            return index
        end
    end
    return -1
end

function GameModeM_C:UpdateAllPlayer()
    local PlayerList = self.PlayerList:ToTable()
    for index, value in ipairs(PlayerList) do
        value:Event_UpdateSelf(self.PlayerInfoList)
    end
end

--function GameModeM_C:UserConstructionScript()
--end

--function GameModeM_C:ReceiveBeginPlay()
--end

--function GameModeM_C:ReceiveEndPlay()
--end

-- function GameModeM_C:ReceiveTick(DeltaSeconds)
-- end

--function GameModeM_C:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
--end

--function GameModeM_C:ReceiveActorBeginOverlap(OtherActor)
--end

--function GameModeM_C:ReceiveActorEndOverlap(OtherActor)
--end

return GameModeM_C
