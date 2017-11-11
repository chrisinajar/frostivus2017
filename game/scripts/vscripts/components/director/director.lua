HordeDirector = HordeDirector or class({})

PHASE_BUILD_UP = 1
PHASE_PEAK = 2
PHASE_REST = 3
PHASE_WRAP = 4
MAX_BUILD_UP_TIME = 100
PEAK_TIME = 20
REST_TIME = 20

local PHASE_NAMES = {
  [PHASE_BUILD_UP] = "BUILD_UP",
  [PHASE_PEAK] = "PEAK",
  [PHASE_REST] = "REST",
  [PHASE_WRAP] = "INVALID"
}

local DesiredStressEvent = Event()
local WaveEvent = Event()
local PhaseChangeEvent = Event()

function HordeDirector:Init()
  if self.__has_init then
    return
  end
  self.__has_init = true

  self.disabled = true

  DebugPrint('Init hero director')

  DebugOverlay:AddEntry("root", {
    Name = "DirectorPhase",
    DisplayName = "Phase",
    Value = "N/A"
  })
  DebugOverlay:AddEntry("root", {
    Name = "DirectorDesiredStress",
    DisplayName = "Goal Stress",
    Value = "N/A"
  })
  DebugOverlay:AddEntry("root", {
    Name = "DirectorWave",
    DisplayName = "Wave",
    Value = 1
  })

  PhaseChangeEvent.listen(function (phase)
    DebugOverlay:Update("DirectorPhase", {
      Value = PHASE_NAMES[phase],
      forceUpdate = true
    })
  end)
  DesiredStressEvent.listen(function (stress)
    DebugOverlay:Update("DirectorDesiredStress", {
      Value = stress,
      forceUpdate = true
    })
  end)
  WaveEvent.listen(function (wave)
    DebugOverlay:Update("DirectorWave", {
      Value = wave,
      forceUpdate = true
    })
  end)

  self.watchers = {}
  self.currentPhase = 0
  self.wave = 1
  self.timeInWave = 0

  Timers:CreateTimer(1, function()
    self.timeInWave = self.timeInWave + 1
    DebugPrint('Time in Wave '..self.timeInWave)
    return 1
  end)

  local configuredHeroes = {}

  local function setupHeroWatcher (hero)
    local playerID = hero:GetPlayerID()
    if configuredHeroes[playerID] then
      DebugPrint('Tried to configure hero watcher twice for player ' .. playerID)
    end

    configuredHeroes[playerID] = true
    local watcher = PlayerWatcher()
    watcher:Init(hero, playerID)
    table.insert(self.watchers, watcher)

    DesiredStressEvent.listen(function (ds)
      watcher.desiredStress = ds
    end)
    WaveEvent.listen(function (wave)
      watcher.wave = wave
    end)
    watcher.wave = self.wave
  end

  PlayerResource:GetAllTeamPlayerIDs():each(function (playerID)
    DebugPrint('Initializing player watcher for player ' .. playerID)
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    if hero then
      setupHeroWatcher(hero)
    end
  end)

  GameEvents:OnHeroInGame(function(npc)
    setupHeroWatcher(npc)
  end)

  PeakStressEvent.listen(partial(HordeDirector.OnPeakStress, self))

  -- start horde director
  HordeSpawner:Init(self)
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

  PhaseChangeEvent.broadcast(self.currentPhase)
end

function HordeDirector:StartBuildUp()
  DebugPrint('Entering start up phase')
  local desiredStress = 0
  Timers:CreateTimer(1, function()
    if self.currentPhase ~= PHASE_BUILD_UP then
      return
    end
    desiredStress = math.min(1, desiredStress + 0.01)
    DesiredStressEvent.broadcast(desiredStress)

    if self.timeInWave > MAX_BUILD_UP_TIME then
      self:EnterNextPhase()
    end

    return 1
  end)
end

function HordeDirector:StartPeak()
  DebugPrint('Entering peak phase')
  DesiredStressEvent.broadcast(1.1) -- force impossible stress at peak
  Timers:CreateTimer(PEAK_TIME, function()
    -- end peak on a timer
    self:EnterNextPhase()
  end)
end

function HordeDirector:StartRest()
  DesiredStressEvent.broadcast(-1)
  DebugPrint('Entering rest phase')

  Timers:CreateTimer(REST_TIME, function()
  	DebugPrint('Starting next wave!')
  	self.timeInWave = 0
  	self.wave = self.wave + 1
  	WaveEvent.broadcast(self.wave)
    self:EnterNextPhase()
  end)
end

function HordeDirector:StartNextWave()
  DebugPrint('Starting next wave!')
  self.timeInWave = 0
  self.wave = self.wave + 1
  WaveEvent.broadcast(self.wave)
  return
end

function HordeDirector:Pause()
  self.disabled = true
end
function HordeDirector:Resume()
  self.disabled = false
end

function HordeDirector:IsDisabled()
  return self.disabled
end

function HordeDirector:ShouldSpawn(playerWatcher)
  return not self:IsDisabled()
end
