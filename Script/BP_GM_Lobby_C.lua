require "UnLua"

local BP_GM_Lobby_C = Class()

function BP_GM_Lobby_C:ReceiveBeginPlay()
    if self:HasAuthority() then
        self:SetMapName()
    end
end

function BP_GM_Lobby_C:Event_UpdatePlayerInfo_RPC(PlayerInfo)
    self:UpdatePlayerInfoLocal(PlayerInfo)
    self:UpdateAllPlayer()
end

function BP_GM_Lobby_C:UpdatePlayerInfoLocal(PlayerInfo)
    local TablePlayer = self.PlayerInfoList:ToTable()
    for index, value in ipairs(TablePlayer) do
        if value.Name == PlayerInfo.Name then
            local PInfo = self.PlayerInfoList:GetRef(index)
            PInfo.Ready = PlayerInfo.Ready
            return
        end
    end
end

function BP_GM_Lobby_C:SetMapName()
    local GameInstance = UE4.UGameplayStatics.GetGameInstance(self)
    self.MapName = GameInstance.MapName
    self.MaxPlayer = GameInstance.MaxPlayer
end

function BP_GM_Lobby_C:UpdateAllPlayer_RPC()
    local PlayerList = self.PlayerList:ToTable()
    for index, value in ipairs(PlayerList) do
        value:Event_UpateSelf(self.PlayerInfoList, self.MapName, self.MaxPlayer)
    end
end
---
---不能定义pass by ref的参数。无法复制。
---
function BP_GM_Lobby_C:Event_AddPlayerInfo_RPC(PlayerInfo)
    print('LV:: GameMode Add Player Info. Prof=' .. tostring(PlayerInfo.Prof) .. ", Name=" .. PlayerInfo.Name) 
    local index = self.PlayerInfoList:Add(PlayerInfo)
    local playerController = self.PlayerList:GetRef(index)

    local World = self:GetWorld()
    if not World then
        return
    end

    local PlayerStart = nil 
    local PlayerClass = nil
    
    PlayerClass = UE4.UClass.Load("/Game/BP_New/BP_player_M.BP_player_M")
    -- PlayerClass = UE4.UClass.Load("/Game/Blueprint/BP_player.BP_player")
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

    -- if PlayerInfo.Prof == 1 then
    --     Color = UE4.FLinearColor(1.0, 0, 0, 1.0)
    --     -- Player = World:SpawnActor(PlayerClass, PlayerStart:GetTransform(), UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, self, self, nil, BaseColor)
    -- elseif PlayerInfo.Prof == 2 then
    --     Color = UE4.FLinearColor(0, 1.0, 0, 1.0)
    --     -- Player = World:SpawnActor(PlayerClass, PlayerStart:GetTransform(), UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, self, self, nil, BaseColor)
    -- elseif PlayerInfo.Prof == 3 then
    --     Color = UE4.FLinearColor(0, 0, 1.0, 1.0)
    --     -- Player = World:SpawnActor(PlayerClass, PlayerStart:GetTransform(), UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, self, self, nil, BaseColor)
    -- end
    
    -- local BaseColor = {}
    -- BaseColor[0] = Color
    -- BaseColor[1] = PlayerInfo.Prof
    -- Player = World:SpawnActor(PlayerClass, PlayerStart:GetTransform(), UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, self, self, nil, BaseColor)
    
    playerController:Possess(Player)
    GameMgr:ShowGameInfo()
end

function BP_GM_Lobby_C:K2_PostLogin(NewPlayer)
    if self:HasAuthority() then
        self:SetMapName()
        self.PlayerList:Add(NewPlayer)
        if NewPlayer.ControlledPawn ~= nil then
            NewPlayer.ControlledPawn:DestoryActor()
        end
        NewPlayer:Event_ShowLobbyUI()
    end
end

function BP_GM_Lobby_C:K2_OnLogout(ExitingController)
    local PlayerList = self.PlayerList:ToTable()
    for index, value in ipairs(PlayerList) do
        if ExitingController == value then
            self.PlayerList:Remove(index)
            self.PlayerInfoList:Remove(index)
        end
    end
    self:UpdateAllPlayer()
end

function BP_GM_Lobby_C:Event_KickoutPlayer(InIndex)
   if not self.PlayerList:IsValidIndex(InIndex) then
        return
   end
   self.PlayerList:Get(InIndex):Event_LeaveRoom()
end

function BP_GM_Lobby_C:AddChatInfo(Name, Message)
    local PlayerList = self.PlayerList:ToTable()
    for index, value in ipairs(PlayerList) do
        value:Event_NewMessage(Name .. ":" .. Message)
    end
 end

function BP_GM_Lobby_C:Event_Start()
    local MName = "MapGame01"
    local Cmd = "ServerTravel " .. MName
    local Controller = UE4.UGameplayStatics.GetPlayerController(self, 0)
    UE4.UKismetSystemLibrary.ExecuteConsoleCommand(self, Cmd, Controller)
end

return BP_GM_Lobby_C
