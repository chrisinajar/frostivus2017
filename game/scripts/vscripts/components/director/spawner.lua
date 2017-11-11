
HordeSpawner = HordeSpawner or class({})

Debug.EnabledModules['director:spawner'] = true

HORDE_MIN_WAVE = 1
HORDE_MAX_WAVE = 20

WaveData = {
  {
    {  "npc_dota_horde_basic"              , 40},
    {  "npc_dota_horde_special_7"          , 60}
  },
  {
    {  "npc_dota_horde_basic"              , 50},
    {  "npc_dota_horde_special_3"          , 50}
  },
  {
    {  "npc_dota_horde_basic"              , 50},
    {  "npc_dota_horde_special_2"          , 50}
  },
}

function HordeSpawner:Init()
end

function HordeSpawner:CreateHorde(wave, intensity)
  wave = math.min(wave, #WaveData)
  local count = math.max(HORDE_MIN_WAVE, math.ceil((intensity / 100) * HORDE_MAX_WAVE))
  local unittable = {}
  local iter = 1
  for j =  1, #WaveData[wave] do 
    local unit = WaveData[wave][j][1]
    for i = 1 , math.ceil(count * WaveData[wave][j][2]/100) do
      unittable[iter] = unit
      iter = iter+1;
    end
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
