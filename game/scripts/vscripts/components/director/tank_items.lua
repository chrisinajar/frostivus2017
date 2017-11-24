
-- Taken from bb template
if TankCreepItemDrop == nil then
    DebugPrint ( '[creeps/item_drop] creating new TankCreepItemDrop object' )
    TankCreepItemDrop = class({})
end

--define how often items drop from creeps. min = 0 (0%), max = 1 (100%)
--local DROP_CHANCE = 0.25

-- The C initial chance parameter for the pseudo-random distribution function
-- Set for average chance of less than ???%. Functions for calculation and a bunch of pre-calculated values can be found here:
-- https://gaming.stackexchange.com/questions/161430/calculating-the-constant-c-in-dota-2-pseudo-random-distribution
--[[
function testPRD(prd) {
  var counter = 1;
  var truths = 0;
  var attempts = 0;

  for (var i = 0; i < 10000000; ++i) {
    random();
  }
  console.log(truths, attempts, Math.round(truths/attempts * 10000) / 100);

  function random() {
    attempts++;
    if (Math.random() < prd * counter) {
      counter = 1;
      truths++;
      return true;
    } else {
      counter++;
      return false;
    }
  }
}
]]
-- 100%
local PRD_C = 1.0

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
local ItemPowerTable = {
  --NAME                        FROM    TO      RARITY
  { "item_bogduggs_cudgel",     1,      1,      1},
  { "item_bogduggs_cudgel_2",   2,      2,      1},
  { "item_bogduggs_cudgel_3",   3,      3,      1},

  { "item_heart_transplant",    1,      1,      1},
  { "item_heart_transplant_2",  2,      2,      1},
  { "item_heart_transplant_3",  3,      3,      1},

  { "item_lucience",            1,      1,      1},
  { "item_lucience_2",          2,      2,      1},
  { "item_lucience_3",          3,      3,      1},

  { "item_ogre_seal_totem",     1,      1,      1},
  { "item_ogre_seal_totem_2",   2,      2,      1},
  { "item_ogre_seal_totem_3",   3,      3,      1},

  { "item_pull_staff",          1,      1,      1},
  { "item_pull_staff_2",        2,      2,      1},
  { "item_pull_staff_3",        3,      3,      1},

  { "item_regen_crystal",       1,      1,      1},
  { "item_regen_crystal_2",     2,      2,      1},
  { "item_regen_crystal_3",     3,      3,      1},

  { "item_siege_mode",          1,      1,      1},
  { "item_siege_mode_2",        2,      2,      1},
  { "item_siege_mode_3",        3,      3,      1},

  { "item_stoneskin",           1,      1,      1},
  { "item_stoneskin_2",         2,      2,      1},
  { "item_stoneskin_3",         3,      3,      1},

  { "item_wand_of_the_brine",       1,      1,      1},
  { "item_wand_of_the_brine_2",     2,      2,      1},
  { "item_wand_of_the_brine_3",     3,      3,      1},

  { "item_watchers_gaze",       1,      1,      1},
  { "item_watchers_gaze_2",     2,      2,      1},
  { "item_watchers_gaze_3",     3,      3,      1},
}

function TankCreepItemDrop:CreateDrop (itemName, pos)
  local newItem = CreateItem(itemName, nil, nil)

  if not newItem then
    DebugPrint('Failed to find item: ' .. itemName)
    return
  end

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

function TankCreepItemDrop:DropItem (killedEntity, itemPowerLevel)
  if killedEntity then
    DebugPrint('Attempting an item drop! ' .. tostring(itemPowerLevel))
    killedEntity.Is_ItemDropEnabled = false
    local itemToDrop = TankCreepItemDrop:RandomDropItemName(itemPowerLevel)
    if itemToDrop ~= "" and itemToDrop ~= nil then
      TankCreepItemDrop:CreateDrop(itemToDrop, killedEntity:GetAbsOrigin())
    end
  end
end

local PRDCounter = 1
function TankCreepItemDrop:RandomDropItemName(itemPowerLevel)
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
