HordeDirector = HordeDirector or class({})

PHASE_BUILD_UP = 1
PHASE_PEAK = 2
PHASE_REST = 3
PHASE_WRAP = 4

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
  self.specialUnitQueue = {}
  self.specialUnitsAlive = 0
  self.specialUnitsByType = {}
  self.specialUnitTimeout = 0

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
    if not self.disabled then
      self.timeInWave = self.timeInWave + 1
    end
    if self.specialUnitTimeout > 0 then
      self.specialUnitTimeout = self.specialUnitTimeout - 1
    end
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

function HordeDirector:ForcePeak ()
  self.isForcePeak = true
  if self.currentPhase ~= PHASE_PEAK then
    self.currentPhase = PHASE_PEAK
    self:StartPeak()
  end
end

function HordeDirector:EndPeak ()
  if not self.isForcePeak then
    return
  end
  self.isForcePeak = false
end

function HordeDirector:SpawnSpecialUnit ()
  local unit = HordeSpawner:ChooseSpecialUnit()
  self:ScheduleSpecialUnit(unit)
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
    if self.disabled then
      desiredStress = 0
      return 1
    end
    local maxRate = 26 - (StorylineManager.currentState * 6)
    if RandomInt(1, maxRate) == 1 then
      self:SpawnSpecialUnit()
    end
    desiredStress = math.min(1, desiredStress + 0.01)
    DesiredStressEvent.broadcast(desiredStress)
    if self.timeInWave > MAX_WAVE_TIME then
      self:EnterNextPhase()
      return
    end

    return 1
  end)
end

function HordeDirector:StartPeak()
  DebugPrint('Entering peak phase')
  DesiredStressEvent.broadcast(1.1) -- force impossible stress at peak
  local inPeak = true
  local wasForced = self.isForcePeak
  local endTime = PEAK_TIME
  if wasForced then
    endTime = 1
  end
  Timers:CreateTimer(endTime, function()
    -- end peak on a timer
    if self.isForcePeak then
      return 1
    end
    inPeak = false
    HordeDirector:EnterNextPhase()
  end)
  Timers:CreateTimer(function()
    if not inPeak then
      return
    end
    self:SpawnSpecialUnit()

    return RandomInt(4, 7)
  end)
end

function HordeDirector:StartRest()
  DesiredStressEvent.broadcast(-1)
  DebugPrint('Entering rest phase')

  Timers:CreateTimer(REST_TIME, function()
  	if HordeDirector.timeInWave > MIN_WAVE_TIME then
  		HordeDirector.StartNextWave()
  	end
    HordeDirector:EnterNextPhase()
  end)
end

function HordeDirector:StartNextWave()
  DebugPrint('Starting next wave!')
  HordeDirector.timeInWave = 0
  HordeDirector.wave = HordeDirector.wave + 1
  WaveEvent.broadcast(HordeDirector.wave)
  return
end

function HordeDirector:ScheduleSpecialUnit(unitName, location, ...)
  local callback = ({...})[1]
  if not callback then
    callback = noop
  end
  if type(location) == "function" then
    callback = location
    location = nil
  end

  DebugPrint('Spawning special unit ' .. unitName)
  if not self:ShouldSpawnSpecialUnit(unitName) then
    table.insert(self.specialUnitQueue, { unitName, location })
    self:ResetSpecialUnitTimer()
    return
  end
  local function done (unit)
    if unit then
      unit:OnDeath(function()
        self.specialUnitsAlive = self.specialUnitsAlive - 1
        self.specialUnitsByType[unitName] = self.specialUnitsByType[unitName] - 1
      end)
      callback(unit)
      return unit
    else
      self.specialUnitsAlive = self.specialUnitsAlive - 1
      self.specialUnitsByType[unitName] = self.specialUnitsByType[unitName] - 1
    end
  end
  -- it was easy to write, not sure if we need it though
  -- disable timeout for now
  -- self:specialUnitTimeout = 5

  if not self.specialUnitsByType[unitName] then
    self.specialUnitsByType[unitName] = 1
  else
    self.specialUnitsByType[unitName] = self.specialUnitsByType[unitName] + 1
  end
  self.specialUnitsAlive = self.specialUnitsAlive + 1

  if location then
    -- this unit is not bound to players
    -- probably based on a storyline objective
    local unit = CreateUnitByName(unitName, location, true, nil, nil, DOTA_TEAM_NEUTRALS)
    return done(unit)
  end

  HordeSpawner:BestPlayerForUnit(unitName):ScheduleUnitSpawn(unitName, done)
end

function HordeDirector:ShouldSpawnSpecialUnit (unitName)
  return self.specialUnitsAlive < MAX_SPECIAL_UNITS and (not self.specialUnitsByType[unitName] or self.specialUnitsByType[unitName] < MAX_SPECIAL_UNITS_EACH)
end

function HordeDirector:ResetSpecialUnitTimer()
  if self.specialUnitTimerIsRunning then
    return
  end
  self.specialUnitTimerIsRunning = true
  Timers:CreateTimer(1, function()
    if self.specialUnitTimeout > 0 then
      return self.specialUnitTimeout
    end
    local unitQueue = self.specialUnitQueue
    self.specialUnitQueue = {}
    for _,unit in ipairs(unitQueue) do
      self:ScheduleSpecialUnit(unit[1], unit[2])
    end
    if #self.specialUnitQueue > 0 then
      return #self.specialUnitQueue
    end
    -- else we stop the loop
    self.specialUnitTimerIsRunning = false
  end)
end

function HordeDirector:ClearQueue()
  self.specialUnitQueue = {}
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
