
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
PRD_C = 0.000356

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
  { "item_tango_single",         0,      3,       1},
  { "item_tango",                2,     10,       1},
  { "item_clarity",              2,     10,       5},
  { "item_flask",                2,     10,      10},
  { "item_enchanted_mango",      0,     10,      10},
  { "item_tango",               11,     20,       5},
  { "item_clarity",             11,     20,      10},
  { "item_flask",               11,     20,      15},
  { "item_enchanted_mango",     11,     20,      15},
  --ACT 1, PART 1
  { "item_magic_wand",           0,      5,       3},
  { "item_ring_of_basilius",     0,      5,       3}, --avoid multiples
  { "item_wraith_band",          0,      5,       1},
  { "item_bracer",               0,      5,       1},
  { "item_null_talisman",        0,      5,       1},
  { "item_cloak",                0,      5,       1},
  { "item_headdress",            0,      5,       1},
  { "item_chainmail",            0,      5,       1},
  { "item_blades_of_attack",     0,      5,       1},
  { "item_belt_of_strength",     0,      5,       1},
  { "item_boots_of_elves",       0,      5,       1},
  { "item_robe",                 0,      5,       1},
  { "item_soul_ring",            0,      5,       1},
  --ACT 1, PART 2
  { "item_buckler",              3,      8,       3}, --avoid multiples
  { "item_void_stone",           3,      8,       1},
  { "item_ring_of_health",       3,      8,       1}
  { "item_ring_of_aquila",       3,      8,       3}, --avoid multiples
  { "item_helm_of_iron_will",    5,     11,       5}, --just because it's really good
  { "item_medallion_of_courage", 3,      8,       1},
  { "item_aether_lens",          3,      8,       1}, --probably pretty good
  { "item_ghost",                3,      8,       7}, --prevent ghost spam
  { "item_force_staff",          3,      8,       1},
  --ACT 2, PART 1
  { "item_vitality_booster",     8,     13,       1},
  { "item_energy_booster",       8,     13,       1},
  { "item_lesser_crit",          8,     13,       1},
  { "item_sange",                8,     13,       1},
  { "item_yasha",                8,     13,       1},
  { "item_trident",              8,     13,       3}, --no idea how good this is
  { "item_ancient_janggo",       8,     13,       5}, --avoid multiples
  { "item_dragon_lance",         8,     13,       3}, --probably pretty good
  { "item_platemail",            8,     13,       1},
  { "item_lifesteal",            8,     13,       1},
  { "item_blade_mail",           8,     13,       3},
  { "item_mask_of_madness",      8,     13,       3},
  { "item_ultimate_orb",         8,     13,       2}, --attempt at preventing ez skadi
  { "item_arcane_boots",         8,     13,       7}, --people have boots
  { "item_tranquil_boots",       8,     13,       7}, --people have boots
  { "item_phase_boots",          8,     13,       7}, --people have boots
  { "item_power_treads",         8,     13,       7}, --people have boots
  { "item_vanguard",             8,     13,       5}, --just because it's really good
  { "item_armlet",               8,     13,       3}, --probably pretty good
  { "item_veil_of_discord",     11,     16,       3}, --probably pretty good
  --ACT 2, PART 2
  { "item_point_booster",       11,     16,       1},
  { "item_mekansm",             11,     16,       3}, --avoid multiples
  { "item_vladmir",             11,     16,       3}, --avoid multiples
  { "item_solar_crest",         11,     16,       1},
  { "item_desolator",           11,     16,       1},
  { "item_hood_of_defiance",    11,     16,       1},
  { "item_pipe",                11,     16,       3}, --avoid multiples
  { "item_basher",              11,     16,       1},
  { "item_diffusal_blade",      11,     16,       1},
  { "item_heavens_halberd",     11,     16,       1},
  { "item_echo_sabre",          11,     16,       1},
  { "item_orchid",              11,     16,       1},
  { "item_crimson_guard",       11,     16,       5}, --just because it's really good
  { "item_maelstrom",           11,     16,       3}, --just because it's really good
  { "item_cyclone",             11,     16,       1},
  { "item_rod_of_atos",         11,     16,       1}, --do we even want this in?
  --BAUMI'S FAVORITE(A2P2)
  { "item_lotus_orb",           11,     16,       3},
  --ACT 3, PART 1
  { "item_hurricane_pike",      17,     22,       1},
  { "item_black_king_bar",      17,     22,       2}, --might actually want to make it rarer or not drop at all
  { "item_ultimate_scepter",    17,     22,       1}, --avoid multiples, but some people really want this
  { "item_sphere",              17,     22,       1},
  { "item_ethereal_blade",      17,     22,       1},
  { "item_radiance",            17,     22,       10},
  { "item_shivas_guard",        17,     22,       4},
  { "item_sheepstick",          17,     22,       1},
  { "item_refresher",           17,     22,       1},
  { "item_monkey_king_bar",     17,     22,       1},
  { "item_manta",               17,     22,       1},
  { "item_butterfly",           17,     22,       1},
  --ACT 3, PART 2
  { "item_heart",               23,     -1,       10}, -- heart and radiance are insane in this type of game
  { "item_skadi",               23,     -1,       1},
  { "item_assault",             23,     -1,       1},
  { "item_greater_crit",        23,     -1,       1},
  { "item_bloodthorn",          23,     -1,       1},
  { "item_satanic",             23,     -1,       1},
  { "item_mjollnir",            23,     -1,       1},
  { "item_octarine_core",       23,     -1,       1},
  { "item_bfury",               23,     -1,       1},
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
