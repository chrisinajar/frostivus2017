
HordeSpawner = HordeSpawner or class({})

Debug.EnabledModules['director:spawner'] = true

function HordeSpawner:Init()
end

function HordeSpawner:CreateHorde(wave, intensity)
  return {
    "npc_dota_creep_badguys_melee_diretide",
    "npc_dota_creep_badguys_melee_diretide",
    "npc_dota_creep_badguys_melee_diretide"
  }
end
