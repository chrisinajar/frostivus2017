HordeDirector = HordeDirector or class({})

PHASE_BUILD_UP = 1
PHASE_PEAK = 2
PHASE_REST = 3
PHASE_WRAP = 4

function HordeDirector:Init()
  DebugPrint('Init hero director')
  PlayerResource:GetAllTeamPlayerIDs():each(function (playerID)
    DebugPrint('Initializing player watcher for player ' .. playerID)
    local watcher = PlayerWatcher()
    watcher:Init(playerID)
  end)
end

function HordeDirector:EnterNextPhase()
  self.currentPhase = self.currentPhase + 1
  if self.currentPhase == PHASE_WRAP then
    self.currentPhase = PHASE_BUILD_UP
  end

  if self.currentPhase == PHASE_BUILD_UP then
    HordeDirector:StartBuildUp()
  else if self.currentPhase == PHASE_PEAK then
    HordeDirector:StartPeak()
  else if self.currentPhase == PHASE_REST then
    HordeDirector:StartRest()
  end
end

function HordeDirector:StartBuildUp()
end

function HordeDirector:StartPeak()
end

function HordeDirector:StartRest()
end
