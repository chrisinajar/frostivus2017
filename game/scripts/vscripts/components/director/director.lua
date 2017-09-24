HordeDirector = HordeDirector or class({})

function HordeDirector:Init()
  DebugPrint('Init hero director')
  PlayerResource:GetAllTeamPlayerIDs():each(function (playerID)
    DebugPrint('Initializing player watcher for player ' .. playerID)
    local watcher = PlayerWatcher()
    watcher:Init(playerID)
  end)
end
