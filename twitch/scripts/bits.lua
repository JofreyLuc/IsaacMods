local Bits = RegisterMod("Bits", 1)
local BitsItem = Isaac.GetItemIdByName("Bits")
local BitsCostume = Isaac.GetCostumeIdByPath("gfx/Characters/bits.anm2")

local timesGot = 0
local rngInit = true
local updateTimesGot = false

local game = Game()
local rng = RNG()

local spawnDebug = true


function Bits:onUpdate()

  local player = Isaac.GetPlayer(0)
  local room = game:GetRoom()

  if rngInit then
    rng:SetSeed(room:GetDecorationSeed(), 1)
    rngInit = false
  end

  -- Debug : spawns the pickup in the first room
  if spawnDebug then
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, BitsItem, Vector(320,300), Vector(0,0), nil)
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, BitsItem, Vector(200,300), Vector(0,0), nil)
    spawnDebug = false
  end

  if updateTimesGot then
    timesGot = player:GetCollectibleNum(BitsItem)
    updateTimesGot = false
  end

  -- Optimization
  if not player:HasCollectible(BitsItem) then return end

  -- True each time the item has been taken
  if player:GetCollectibleNum(BitsItem) > timesGot then
    Bits:randomCoins(rng:RandomFloat(), room, player)
    player:AddCacheFlags(CacheFlag.CACHE_LUCK + CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
    player:AddNullCostume(BitsCostume)
    timesGot = timesGot + 1
  end

end

-- Manages the coins spawn
function Bits:randomCoins(alea, room, player)
  if alea < 0.05 then
    -- 5 dimes
    Bits:spawnXCoins(5, CoinSubType.COIN_DIME, room, player)
  elseif alea < 0.25 then
    -- 3-10 pennies + 1-3 nickels
    coins = rng:RandomInt(7)
    Bits:spawnXCoins(3 + coins, CoinSubType.COIN_PENNY, room, player)
    coins = rng:RandomInt(2)
    Bits:spawnXCoins(1 + coins, CoinSubType.COIN_NICKEL, room, player)
  elseif alea < 0.45 then
    -- 3-6 pennies + 1 dime
    coins = rng:RandomInt(3)
    Bits:spawnXCoins(3 + coins, CoinSubType.COIN_PENNY, room, player)
    Bits:spawnXCoins(1, CoinSubType.COIN_DIME, room, player)
  elseif alea < 0.65 then
    -- 4-20 pennies
    coins = rng:RandomInt(16)
    Bits:spawnXCoins(4 + coins, CoinSubType.COIN_PENNY, room, player)
  elseif alea < 0.85 then
    -- 1 penny + 1 nickel + 1 dime
    Bits:spawnXCoins(1, CoinSubType.COIN_NICKEL, room, player)
    Bits:spawnXCoins(1, CoinSubType.COIN_PENNY, room, player)
    Bits:spawnXCoins(1, CoinSubType.COIN_DIME, room, player)
  else
    -- 1 penny
    Bits:spawnXCoins(1, CoinSubType.COIN_PENNY, room, player)
  end
end

-- Spawns X coinType centered around the player
function Bits:spawnXCoins(x, coinType, room, player)
  for i = 1, x do
    local nextPos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, coinType, nextPos, Vector(0,0), nil)
  end
end

function Bits:onStartUp()
  updateTimesGot = true
end

function Bits:cache(playerEntity, cacheFlag)
  -- Luck +1
  if playerEntity:HasCollectible(BitsItem) then
    if cacheFlag == CacheFlag.CACHE_LUCK then
      playerEntity.Luck = playerEntity.Luck + timesGot + 1
    end
  end
end

Bits:AddCallback(ModCallbacks.MC_POST_UPDATE, Bits.onUpdate)
Bits:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Bits.onStartUp)
Bits:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Bits.cache)
