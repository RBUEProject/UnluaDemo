--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

require "UnLua"

local MyFirst_C = Class()

--function MyFirst_C:Initialize(Initializer)
--end

--function MyFirst_C:PreConstruct(IsDesignTime)
--end

function MyFirst_C:Construct()
    print('Hello UnLua:' .. UE4.UMyLuaUtils.GetInt() .. ". Title-" .. self.Title)

    --添加按钮事件
    self.btnTest.OnPressed:Add(self, MyFirst_C.OnClickTest)

    --调用蓝图中自定义事件
    --self:ShowButton()

    --播放UMG中定义的UI动画
    self:PlayAnimation(self.AnimShowButton, 0, 1)
end

--访问C++中的属性
function MyFirst_C:OnClickTest()
    local World = self:GetWorld()
	if not World then
		return
	end
	local ActorClass = UE4.UClass.Load("/Game/NewBlueprint.NewBlueprint")
    local Actor = World:SpawnActor(ActorClass, FVector(), UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, self, self, "")
    self.Actor = Actor
    Actor:GetIndex()
    local a = 1
    a = 2

    print("MyBaseActor'Name is " .. self.Actor.Name)
end

--function MyFirst_C:Tick(MyGeometry, InDeltaTime)
--end

return MyFirst_C
