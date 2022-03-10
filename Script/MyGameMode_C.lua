--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

require "UnLua"

local MyGameMode_C = Class()

--function MyGameMode_C:Initialize(Initializer)
--end

--function MyGameMode_C:UserConstructionScript()
--end


function MyGameMode_C:ReceiveBeginPlay()
    self.MonsterClass = UE4.UClass.Load("/Game/Blueprint/Monster/BP_MonsterCharacter.BP_MonsterCharacter")
    self.MaxNum = 3
    self.CurrentNum = 0
    self.CurrentGenNum = 0
    self.Wave = 1
    self.OriginLocation = UE4.FVector(450,420,108)
    self.MonsterLocation = UE4.FVector()

    -- if self:HasAuthority() then
    --     self.MapName = UE4.UGameplayStatics.GetGameInstance(self).MapName
    -- end
    UE4.UKismetSystemLibrary.K2_SetTimerDelegate({self, MyGameMode_C.OnTimerGenMonster}, 2, true)
    print("MyGameMode_C:ReceiveBeginPlay")
end

function MyGameMode_C:K2_PostLogin(NewPlayer)
    print("MyGameMode_C:K2_PostLogin")
    if self:HasAuthority() then
        self.PlayerList:Add(NewPlayer)
        if NewPlayer.ControlledPawn ~= nil then
            NewPlayer.ControlledPawn:DestoryActor()
        end
        
        local World = self:GetWorld()
        if not World then
            return
        end
        local PlayerClass = UE4.UClass.Load("/Game/Blueprint/BP_player.BP_player")
        local Player = World:SpawnActor(PlayerClass, self:GetTransform(), UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, self, self)
        NewPlayer:Possess(Player)
    end
end

function MyGameMode_C:OnTimerGenMonster()
    if GameMgr.IsPause then
        return
    end
    local PlayerCharacter = UE4.UGameplayStatics.GetPlayerCharacter(self, 0)
    if GameMgr.CurrentGenNum ~= GameMgr.MaxNum then
        UE4.UNavigationSystemV1.K2_GetRandomReachablePointInRadius(self, self.OriginLocation, self.MonsterLocation, 2000)
        local PlayerLocation = PlayerCharacter:K2_GetActorLocation()
        local Rot = UE4.UKismetMathLibrary.FindLookAtRotation(self.MonsterLocation, PlayerLocation)
        UE4.UAIBlueprintHelperLibrary.SpawnAIFromClass(self, self.MonsterClass, nil, self.MonsterLocation, Rot)
        GameMgr.CurrentGenNum = GameMgr.CurrentGenNum + 1
        GameMgr.CurrentNum = GameMgr.CurrentNum + 1
    end
end

function MyGameMode_C:NotifyEnemyDied()
    self.CurrentNum = self.CurrentNum - 1
    if self.CurrentNum == 0 then
        if GameMgr.Wave % 10 == 0 then
            self.IsPause = true
            local instance = UE4.UGameplayStatics.GetGameInstance(self)
            instance:NotifyNextLevel()
            --通知C++
        else
            GameMgr.CurrentGenNum = 0
            GameMgr.Wave = GameMgr.Wave + 1
        end
        
    end
    print("Current Wave:" .. GameMgr.Wave .. ", Current Monster:" .. GameMgr.CurrentNum)
end

--function MyGameMode_C:ReceiveEndPlay()
--end

-- function MyGameMode_C:ReceiveTick(DeltaSeconds)
-- end

--function MyGameMode_C:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
--end

--function MyGameMode_C:ReceiveActorBeginOverlap(OtherActor)
--end

--function MyGameMode_C:ReceiveActorEndOverlap(OtherActor)
--end

return MyGameMode_C
