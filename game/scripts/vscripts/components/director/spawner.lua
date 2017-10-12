
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
