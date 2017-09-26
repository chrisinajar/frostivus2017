HordeDirector = HordeDirector or class({})

PHASE_BUILD_UP = 1
PHASE_PEAK = 2
PHASE_REST = 3
PHASE_WRAP = 4

function HordeDirector:Init()
  DebugPrint('Init hero director')

  self.watchers = {}
  self.currentPhase = 0

  PlayerResource:GetAllTeamPlayerIDs():each(function (playerID)
    DebugPrint('Initializing player watcher for player ' .. playerID)
    local watcher = PlayerWatcher()
    watcher:Init(playerID)
    table.insert(self.watchers, watcher)
  end)

  PeakStressEvent.listen(partial(HordeDirector.OnPeakStress, self))

  -- start horde director
  HordeSpawner:Init()
  self:EnterNextPhase()
end

function HordeDirector:OnPeakStress (watcher)
  DebugPrint('A player just entered peak stress!')
  if self:AllPlayersInPeakStress() then
    if self.currentPhase == PHASE_BUILD_UP then
      self:EnterNextPhase()
    end
  end
end

function HordeDirector:AllPlayersInPeakStress ()
  for _,watcher in ipairs(self.watchers) do
    if not watcher:IsPeakStress() then
      return false
    end
  end
  return true
end

function HordeDirector:EnterNextPhase()
  self.currentPhase = self.currentPhase + 1
  if self.currentPhase == PHASE_WRAP then
    self.currentPhase = PHASE_BUILD_UP
  end

  if self.currentPhase == PHASE_BUILD_UP then
    self:StartBuildUp()
  elseif self.currentPhase == PHASE_PEAK then
    self:StartPeak()
  elseif self.currentPhase == PHASE_REST then
    self:StartRest()
  end
end

function HordeDirector:StartBuildUp()
  DebugPrint('Entering start up phase')
end

function HordeDirector:StartPeak()
  DebugPrint('Entering peak phase')
end

function HordeDirector:StartRest()
  DebugPrint('Entering rest phase')
end
