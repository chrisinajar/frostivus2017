
HordeSpawner = HordeSpawner or class({})

Debug.EnabledModules['director:spawner'] = true

HORDE_MIN_WAVE = 1
HORDE_MAX_WAVE = 20

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
  DebugPrint(unittable)

  --[[
  intensity is from 1 - 100
  1 is the minimum number of he weakest units
  100 is the maximum number of the strongest units
  ]]

  -- do things?

  return unittable
end
