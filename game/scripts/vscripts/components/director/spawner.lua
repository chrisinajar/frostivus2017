
HordeSpawner = HordeSpawner or class({})

Debug.EnabledModules['director:spawner'] = true

-- number of creeps per wave
HORDE_MIN_WAVE = 1
HORDE_MAX_WAVE = 20

-- per-act special units
SpecialCreeps = {
  [1] = {
    "npc_dota_horde_special_2",
    "npc_dota_horde_special_3",
    "npc_dota_horde_special_5",
    "npc_dota_horde_special_6",
    "npc_dota_horde_special_7",
  	"npc_dota_horde_special_10"
  },
  [2] = {
    "npc_dota_horde_special_2_act2",
    "npc_dota_horde_special_3_act2",
    "npc_dota_horde_special_5_act2",
    "npc_dota_horde_special_6_act2",
    "npc_dota_horde_special_7_act2",
    "npc_dota_horde_special_10_act2"
  },
  [3] = {
    "npc_dota_horde_special_2_act3",
    "npc_dota_horde_special_3_act3",
    "npc_dota_horde_special_5_act3",
    "npc_dota_horde_special_6_act3",
    "npc_dota_horde_special_7_act3",
    "npc_dota_horde_special_10_act3"
  },
  [4] = {
    "npc_dota_horde_special_2_act3",
    "npc_dota_horde_special_3_act3",
    "npc_dota_horde_special_5_act3",
    "npc_dota_horde_special_6_act3",
    "npc_dota_horde_special_7_act3",
    "npc_dota_horde_special_10_act3"
  },
}
-- basic waves
WaveData = {
  {
    horde = "npc_dota_horde_basic_1"
  },
  {
    horde = "npc_dota_horde_basic_2"
  },
  {
    horde = "npc_dota_horde_basic_3"
  },
  {
    horde = "npc_dota_horde_basic_4"
  },
  {
    horde = "npc_dota_horde_basic_5"
  },
  {
    horde = "npc_dota_horde_basic_6"
  },
  {
    horde = "npc_dota_horde_basic_7"
  },
  {
    horde = "npc_dota_horde_basic_8"
  },
  {
    horde = "npc_dota_horde_basic_9"
  },
  {
    horde = "npc_dota_horde_basic_10"
  },
  {
    horde = "npc_dota_horde_basic_11"
  },
  {
    horde = "npc_dota_horde_basic_12"
  },
  {
    horde = "npc_dota_horde_basic_13"
  },
  {
    horde = "npc_dota_horde_basic_14"
  },
  {
    horde = "npc_dota_horde_basic_15"
  },
  {
    horde = "npc_dota_horde_basic_16"
  },
  {
    horde = "npc_dota_horde_basic_17"
  },
  {
    horde = "npc_dota_horde_basic_18"
  },
  {
    horde = "npc_dota_horde_basic_19"
  },
  {
    horde = "npc_dota_horde_basic_20"
  }
}

function HordeSpawner:Init()
end

function HordeSpawner:CreateHorde(wave, intensity)
  wave = math.min(wave, #WaveData)
  local count = math.max(HORDE_MIN_WAVE, math.ceil((intensity / 100) * HORDE_MAX_WAVE))
  local unit = WaveData[wave].horde
  local unittable = {}
  for i = 1,count do
    unittable[i] = unit
  end
--[[
  local unit = WaveData[wave].horde
  local unittable = {}
  for i = 1,count do
    unittable[i] = unit
  end
  ]]
  DebugPrint(count .. ' units to spawn')
  --DebugPrintTable(unittable)

  --[[
  intensity is from 1 - 100
  1 is the minimum number of he weakest units
  100 is the maximum number of the strongest units
  ]]

  -- do things?

  return unittable
end

function HordeSpawner:ChooseSpecialUnit()
  --[[
  eventually we can do logic based on how the players are doing
  to select targeted special units
  ]]
  local act = StorylineManager.currentState
  local choices = SpecialCreeps[act]
  local index = RandomInt(1, #choices)
  return choices[index]
end

function HordeSpawner:BestPlayerForUnit(unitName)
  local leastStress = 1.1
  local result = nil
  for _,watcher in ipairs(HordeDirector.watchers) do
    if watcher.stressLevel < leastStress then
      result = watcher
      leastStress = watcher.stressLevel
    end
  end

  return result
end
