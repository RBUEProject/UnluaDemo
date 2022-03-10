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

--路径+名字，用点号隔开
local BP_player_C = Class("BP_CharacterBase_C")

local Lerp = UE4.UKismetMathLibrary.Lerp
function BP_player_C:Initialize(Initializer)
	self.Super.Initialize(self, Initializer)
	self.Life = 10000
end

--function BP_player_C:UserConstructionScript()
--end

function BP_player_C:ReceiveBeginPlay()
    print("BP_player_C:ReceiveBeginPlay")
    self.Super.ReceiveBeginPlay(self)
    self.DefaultFOV = self.Camera.FieldOfView
	local InterpFloats = self.ZoomInOut.TheTimeline.InterpFloats
	local FloatTrack = InterpFloats:GetRef(1)
	FloatTrack.InterpFunc:Bind(self, BP_player_C.OnZoomInOutUpdate)
end

function BP_player_C:OnZoomInOutUpdate(Alpha)
    local FOV = Lerp(self.DefaultFOV, 120, Alpha)
    print(Alpha)
	self.Camera:SetFieldOfView(FOV)
end

function BP_player_C:UpdateAiming(IsAiming)
    if IsAiming then
        self.ZoomInOut:Play()
    else
        self.ZoomInOut:Reverse()
    end
end

function BP_player_C:GetWeaponTraceInfo()
    local TraceLocation = self.Camera:K2_GetComponentLocation()
	local TraceDirection = self.Camera:GetForwardVector()
	return TraceLocation, TraceDirection
end

function BP_player_C:SpawnWeapon()
    print("child spwan weapon")
	local World = self:GetWorld()
	if not World then
		return
	end
	local WeaponClass = UE4.UClass.Load("/Game/Blueprint/Weapon/BP_DefaultWeapon.BP_DefaultWeapon")
	local NewWeapon = World:SpawnActor(WeaponClass, self:GetTransform(), UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, self, self, "Blueprint.Weapon.BP_DefaultWeapon_C")
	return NewWeapon
end
--function BP_player_C:ReceiveEndPlay()
--end

-- function BP_player_C:ReceiveTick(DeltaSeconds)
-- end

--function BP_player_C:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
--end

--function BP_player_C:ReceiveActorBeginOverlap(OtherActor)
--end

--function BP_player_C:ReceiveActorEndOverlap(OtherActor)
--end

function BP_player_C:Log(title, t)
	print("----------------------------------------------------")
	print("---Title:" .. title)
	print("---" .. tostring(t))
	for k, v in pairs(t) do
		print("Key=" .. tostring(k) .. " type=" .. type(v) .. " Value=" .. tostring(v))
	end
	print("----------------------------------------------------")
	print("")
end
return BP_player_C
