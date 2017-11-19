
-- Taken from bb template
if CreepItemDrop == nil then
    DebugPrint ( '[creeps/item_drop] creating new CreepItemDrop object' )
    CreepItemDrop = class({})
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
-- 1.19%
PRD_C = 0.000222

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
  --NAME                        FROM    TO      RARITY
  --CONSUMABLES
  { "item_health_potion",        0,     -1,       1},
  { "item_mana_potion",          0,     -1,       2},
  { "item_enchanted_mango",      0,     10,      10},
  --ACT 1, PART 1
  { "item_ring_of_basilius",     1,      6,       9}, --avoid multiples
  { "item_wraith_band",          0,      5,       3},
  { "item_bracer",               0,      5,       3},
  { "item_null_talisman",        0,      5,       3},
  { "item_headdress",            0,      5,       3},
  { "item_chainmail",            0,      5,       3},
  { "item_blades_of_attack",     0,      5,       3},
  { "item_belt_of_strength",     1,      6,       3},
  { "item_boots_of_elves",       1,      6,       3},
  { "item_robe",                 1,      6,       3},
  { "item_soul_ring",            2,      7,       3},
  --ACT 1, PART 2
  { "item_buckler",              3,      8,       9}, --avoid multiples
  { "item_void_stone",           3,      8,       3},
  { "item_ring_of_health",       3,      8,       3},
  { "item_ring_of_aquila",       2,      7,       9}, --avoid multiples
  { "item_helm_of_iron_will",    5,     12,      15}, --just because it's really good
  { "item_medallion_of_courage", 4,      9,       3},
  { "item_aether_lens",          4,      9,       3}, --probably pretty good
  { "item_ghost",                3,     12,      21}, --prevent ghost spam
  { "item_force_staff",          3,      8,       3},
  --BOOTS
  { "item_arcane_boots",         6,      7,       1}, --people have boots
  { "item_tranquil_boots",       6,      7,       1}, --people have boots
  { "item_phase_boots",          6,      7,       1}, --people have boots
  { "item_power_treads",         6,      7,       1}, --people have boots
  --ACT 2, PART 1
  { "item_vitality_booster",     6,     13,       3},
  { "item_energy_booster",       5,     12,       3},
  { "item_lesser_crit",          7,     14,       3},
  { "item_sange",                6,     13,       3},
  { "item_yasha",                6,     13,       3},
  { "item_trident",              6,     13,       9}, --no idea how good this is
  { "item_ancient_janggo",       6,     13,      15}, --avoid multiples
  { "item_dragon_lance",         7,     14,       9}, --probably pretty good
  { "item_platemail",            6,     13,       3},
  { "item_lifesteal",            6,     13,       3},
  { "item_blade_mail",           8,     15,       9},
  { "item_mask_of_madness",      8,     15,       9},
  { "item_ultimate_orb",         6,     13,       6}, --attempt at preventing ez skadi
  { "item_vanguard",             8,     15,      15}, --just because it's really good
  { "item_armlet",               8,     15,       9}, --probably pretty good
  { "item_veil_of_discord",      6,     13,       9}, --probably pretty good
  --ACT 2, PART 2
  { "item_point_booster",       11,     18,       3},
  { "item_mekansm",             11,     18,       9}, --avoid multiples
  { "item_vladmir",             11,     18,       9}, --avoid multiples
  { "item_solar_crest",         10,     17,       3},
  { "item_desolator",           12,     19,       3},
  { "item_pipe",                13,     20,       9}, --avoid multiples
  { "item_basher",              11,     18,       3},
  { "item_diffusal_blade",      11,     18,       3},
  { "item_heavens_halberd",     13,     20,       3},
  { "item_echo_sabre",          11,     18,       3},
  { "item_orchid",              11,     18,       3},
  { "item_crimson_guard",       14,     21,      15}, --just because it's really good
  { "item_maelstrom",           13,     20,       9}, --just because it's really good
  { "item_cyclone",             10,     18,       3},
  { "item_rod_of_atos",         11,     18,       3}, --do we even want this in?
  --BAUMI'S FAVORITE(A2P2)
  { "item_lotus_orb",           11,     18,       3},
  --ACT 3, PART 1
  { "item_hurricane_pike",      15,     22,       3},
  { "item_black_king_bar",      15,     22,       6}, --might actually want to make it rarer or not drop at all
  { "item_ultimate_scepter",    14,     21,       3}, --avoid multiples, but some people really want this
  { "item_sphere",              15,     22,       3},
  { "item_ethereal_blade",      15,     22,       3},
  { "item_radiance",            17,     24,      30},
  { "item_shivas_guard",        17,     24,      12},
  { "item_sheepstick",          15,     22,       3},
  { "item_refresher",           16,     23,       3},
  { "item_monkey_king_bar",     15,     22,       3},
  { "item_manta",               16,     23,       3},
  { "item_butterfly",           16,     23,       3},
  --ACT 3, PART 2
  { "item_heart",               21,     -1,      30}, -- heart and radiance are insane in this type of game
  { "item_skadi",               20,     -1,       3},
  { "item_assault",             20,     -1,       3},
  { "item_greater_crit",        19,     -1,       3},
  { "item_bloodthorn",          20,     -1,       3},
  { "item_satanic",             20,     -1,       3},
  { "item_mjollnir",            20,     -1,       3},
  { "item_octarine_core",       20,     -1,       3},
  { "item_bfury",               20,     -1,       3},
}

function CreepItemDrop:CreateDrop (itemName, pos)
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

function CreepItemDrop:DropItem (killedEntity, itemPowerLevel)
  if killedEntity then
    DebugPrint('Attempting an item drop! ' .. tostring(itemPowerLevel))
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
