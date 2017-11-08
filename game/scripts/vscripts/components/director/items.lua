
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
  --SUPER EARLY
  { "item_stout_shield",         0,      3,       7},
  { "item_gauntlets",            0,      3,       2},
  { "item_slippers",             0,      3,       2},
  { "item_mantle",               0,      3,       2},
  --EARLY
  { "item_magic_wand",           2,      8,       3},
  { "item_ring_of_basilius",     2,      8,       3}, --avoid multiples
  { "item_boots",                2,      4,       1},
  { "item_boots",                5,      8,      10}, --each player only needs one
  { "item_wraith_band",          2,      8,       1},
  { "item_bracer",               2,      8,       1},
  { "item_null_talisman",        2,      8,       1},
  { "item_cloak",                2,      8,       1},
  { "item_headdress",            2,      8,       1},
  { "item_chainmail",            2,      8,       1},
  { "item_blades_of_attack",     2,      8,       1},
  { "item_belt_of_streangth",    2,      8,       1},
  { "item_boots_of_elves",       2,      8,       1},
  { "item_robe",                 2,      8,       1},
  { "item_gloves",               2,      8,       1},
  --ADV EARLY
  { "item_buckler",              5       8,       3}, --avoid multiples
  { "item_void_stone",           5       8,       1},
  { "item_ring_of_health",       5       8,       1},
  { "item_vitality_booster",     5       8,       1},
  { "item_energy_booster",       5       8,       1},
  { "item_point_booster",        5       8,       1},
  { "item_soul_ring",            5       8,       1},
  { "item_vitality_booster",     5       8,       1},
  { "item_ring_of_aquila",       5,      8,       3}, --avoid multiples
  { "item_helm_of_iron_will",    5,     10,       5}, --just because it's really good
  --SMALL
  { "item_medallion_of_courage", 9,     16,       1},
  { "item_ghost",                9,     16,       7}, --prevent ghost spam
  { "item_force_staff",          9,     16,       1},
  { "item_aether_lens",          9,     16,       3}, --probably pretty good
  { "item_lesser_crit",          9,     16,       1},
  { "item_sange",                9,     16,       1},
  { "item_yasha",                9,     16,       1},
  { "item_trident",              9,     16,       3}, --no idea how good this is
  { "item_ancient_janggo"        9,     16,       5}, --avoid multiples
  { "item_dragon_lance",         9,     16,       3}, --probably pretty good
  { "item_platemail",            9,     16,       1},
  { "item_lifesteal",            9,     16,       1},
  { "item_blade_mail",           9,     16,       3},
  { "item_mask_of_madness",      9,     16,       3},
  { "item_ultimate_orb",         9,     16,       2}, --attempt at preventing ez skadi
  { "item_arcane_boots",         9,     16,       8}, --people have boots
  { "item_tranquil_boots",       9,     16,       8}, --people have boots
  { "item_phase_boots",          9,     16,       8}, --people have boots
  { "item_power_treads",         9,     16,       8}, --people have boots
  --ADV SMALL
  { "item_vanguard",            12,     16,       5}, --just because it's really good
  { "item_armlet",              12,     16,       3}, --probably pretty good
  { "item_veil_of_discord",     12,     16,       3}, --probably pretty good
  { "item_mekansm",             12,     16,       3}, --avoid multiples
  { "item_vladmir",             12,     16,       3}, --avoid multiples
  --MEDIUM
  { "item_solar_crest",         17,     24,       1},
  { "item_desolator",           17,     24,       1},
  { "item_basher",              17,     24,       1},
  { "item_hurricane_pike",      17,     24,       1},
  { "item_black_king_bar",      17,     24,       2}, --might actually want to make it rarer or not drop at all
  { "item_heavens_halbeard",    17,     24,       1},
  { "item_cyclone",             17,     24,       1}, --do we even want this in?
  { "item_diffusal_blade",      17,     24,       1},
  { "item_echo_sabre",          17,     24,       1},
  { "item_orchid",              17,     24,       1},
  { "item_hood_of_defiance",    17,     24,       1},
  --BAUMI'S FAVORITE(MEDIUM)
  { "item_lotus_orb",           17,     24,       3},
  --ADV MEDIUM
  { "item_pipe",                20,     24,       1},
  { "item_ultimate_scepter",    20,     24,       1}, --avoid multiples, but some people really want this
  { "item_crimson_guard",       20,     24,       5}, --just because it's really good
  { "item_maelstrom",           20,     24,       3}, --just because it's really good
  { "item_sange_and_yasha",     20,     24,       3}, --TBH people already have this
  --GREAT
  { "item_heart",               25,     -1,       1},
  { "item_skadi",               25,     -1,       1},
  { "item_sheepstick",          25,     -1,       1},
  { "item_shivas_guard",        25,     -1,       1},
  { "item_assault",             25,     -1,       1},
  { "item_greater_crit",        25,     -1,       1},
  { "item_butterfly",           25,     -1,       1},
  { "item_bloodthorn",          25,     -1,       1},
  { "item_manta",               25,     -1,       1},
  { "item_satanic",             25,     -1,       1},
  { "item_mjollnir",            25,     -1,       1},
  { "item_monkey_king_bar",     25,     -1,       1},
  { "item_octarine_core",       25,     -1,       1},
  { "item_refresher",           25,     -1,       1},
  { "item_radiance",            25,     -1,       1},
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
