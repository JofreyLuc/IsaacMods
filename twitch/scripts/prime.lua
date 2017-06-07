local Prime = RegisterMod("Prime", 1)
local PrimeItem = Isaac.GetItemIdByName("Prime")

local has = false
local rngInit = true

local game = Game()
local rng = RNG()

local spawnDebug = true


function Prime:onUpdate()

  local player = Isaac.GetPlayer(0)
  local room = game:GetRoom()

  if rngInit then
    rng:SetSeed(room:GetDecorationSeed(), 1)
    rngInit = false
  end

  -- Debug : spawns the pickup in the first room
  if spawnDebug then
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, PrimeItem, Vector(320,300), Vector(0,0), nil)
    spawnDebug = false
  end

  -- Item check
  if not has and player:HasCollectible(PrimeItem) then
    has = true
  end

end

function Prime:onNewFloor()
  -- Each floor : spawns 2 random trinkets
  if has then
    itemPool = game:GetItemPool()
    for i = 1, 2 do
      trink = itemPool:GetTrinket()
      Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, trink , Vector(213 * i,200), Vector(0,0), nil)
      itemPool:RemoveTrinket(trink)
    end
  end
end


Prime:AddCallback(ModCallbacks.MC_POST_UPDATE, Prime.onUpdate)
Prime:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Prime.onNewFloor)
