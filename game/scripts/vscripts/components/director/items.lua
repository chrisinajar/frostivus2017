
-- Taken from bb template
if CreepItemDrop == nil then
    DebugPrint ( '[creeps/item_drop] creating new CreepItemDrop object' )
    CreepItemDrop = class({})
end

--item power level defines what items drop at given time
local ItemPowerLevel = 1.0

--define how often items drop from creeps. min = 0 (0%), max = 1 (100%)
--local DROP_CHANCE = 0.25

-- The C initial chance parameter for the pseudo-random distribution function
-- Set for average chance of 25%. Functions for calculation and a bunch of pre-calculated values can be found here:
-- https://gaming.stackexchange.com/questions/161430/calculating-the-constant-c-in-dota-2-pseudo-random-distribution
PRD_C = 0.084744091852316990275274806

--creep properties enumerations
local NAME_ENUM = 1
local FROM_ENUM = 2
local TO_ENUM = 3
local RARITY_ENUM = 4

--defines items drop levels.
--item will start dropping, between FROM and TO itemPowerLevel.
-- RARITY is used to define how likely the item is to drop in comparison with other items.
-- the higher the value, the less likely the item is to drop
--for negative values:
--  *FROM -> any level smaller or equal than TO will have a chance to drop the item.
--  *TO   -> any level larger or equal than FROM will have  a chance to drop the item.
--  *FROM and TO -> item will drop at any level.
--  *RARITY -> item will not drop.
--it is possible to define the same item twice, for maximum flexibility
ItemPowerTable = {
  --NAME                      FROM    TO      RARITY
  { "item_tango_single",      0,      3,        1},
  { "item_tango",             2,      10,       1},
  { "item_clarity",           2,      20,      10},
  { "item_flask",             2,      20,      10},
  { "item_enchanted_mango",   3,      20,      10},
  { "item_stout_shield",      2,      5,       1},
  { "item_gauntlets",         2,      5,       1},
  { "item_slippers",          2,      5,       1},
  { "item_mantle",            2,      5,       1},
  { "item_ring_of_basilius",  4,      8,       10},
  { "item_boots",             3,      4,       1},
  { "item_boots",             3,      8,       10},
  { "item_wraith_band",       4,      10,      1},
  { "item_bracer",            4,      10,      1},
  { "item_null_talisman",     4,      10,      1},
  { "item_ring_of_aquila",    4,      10,      1},
  { "item_arcane_boots",      8,      20,      10},
  { "item_tranquil_boots",    8,      20,      10},
  { "item_phase_boots",       8,      20,      10},
  { "item_helm_of_iron_will", 8,      15,      1},
  { "item_armlet",            10,     20,      1},
  { "item_radiance",          1,     -1,       1},
}

function CreepItemDrop:CreateDrop (itemName, pos)
  local newItem = CreateItem(itemName, nil, nil)

  newItem:SetPurchaseTime(0)
  newItem.firstPickedUp = false

  CreateItemOnPositionSync(pos, newItem)
  newItem:LaunchLoot(false, 300, 0.75, pos + RandomVector(RandomFloat(50, 350)))

  Timers:CreateTimer(ITEM_DESPAWN_TIME, function ()
    -- check if safe to destroy
    if IsValidEntity(newItem) then
      if newItem:GetContainer() ~= nil then
        newItem:GetContainer():RemoveSelf()
      end
    end
  end)
end

function CreepItemDrop:DropItem (killedEntity, itemPowerLevel)
  if killedEntity then
    DebugPrint('Attempting an item drop!')
    killedEntity.Is_ItemDropEnabled = false
    local itemToDrop = CreepItemDrop:RandomDropItemName(itemPowerLevel)
    if itemToDrop ~= "" and itemToDrop ~= nil then
      CreepItemDrop:CreateDrop(itemToDrop, killedEntity:GetAbsOrigin())
    end
  end
end

local PRDCounter = 1
function CreepItemDrop:RandomDropItemName(itemPowerLevel)
  DebugPrint('Attempt item drop')
  --first we need to check against the drop percentage.
  if RandomFloat(0, 1) > math.min(1, PRD_C * PRDCounter) then
    -- Increment PRD counter if nothing was dropped
    PRDCounter = PRDCounter + 1
    return ""
  end

  --now iterate through item power table and see which items qualify for
  local totalChancePool = 0.0
  local filteredItemTable = {}

  for i=1, #ItemPowerTable do
    local from = ItemPowerTable[i][FROM_ENUM]
    local to = ItemPowerTable[i][TO_ENUM]
    local rarity = ItemPowerTable[i][RARITY_ENUM]

    if (from < 0 or (from >= 0 and itemPowerLevel >= from)) and (to < 0 or (to >= 0 and itemPowerLevel <= to)) and rarity > 0 then
      totalChancePool = totalChancePool + 1.0 / rarity
      filteredItemTable[#filteredItemTable + 1] = ItemPowerTable[i]
    end
  end

  local passedItemsCumulativeChance = 0.0
  local dropChance = RandomFloat(0, 1) * totalChancePool

  for i=1, #filteredItemTable do
    passedItemsCumulativeChance = passedItemsCumulativeChance + 1.0 / filteredItemTable[i][RARITY_ENUM]
    if passedItemsCumulativeChance >= dropChance then
      -- Reset PRD counter on successful drop roll
      PRDCounter = 1
      return filteredItemTable[i][NAME_ENUM]
    end
  end

  --in case some configuration was done wrong, return empty, itherwise this point should not be reached normally.
  return ""
end
