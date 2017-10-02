LinkLuaModifier('modifier_marker_creep', 'modifiers/modifier_marker_creep', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_player_watcher', 'modifiers/modifier_player_watcher', LUA_MODIFIER_MOTION_NONE)

Debug.EnabledModules['director:player_watcher'] = true

PlayerWatcher = PlayerWatcher or class({})

PeakStressEvent = Event()

local MARKER_INTERVAL = 0.1
local THINK_INTERVAL = 2
local SPAWN_AS_HORDE = true

function PlayerWatcher:Init(hero, playerID)
  DebugPrint('Init player watcher for ' .. playerID)
  self.playerID = playerID
  self.debugGroupName = 'Player' .. playerID
  self.hero = hero
  self.lastHP = 1
  self.currentSpawnInterval = 5
  self.killedUnits = 0
  self.killedNearbyUnits = 0
  self.stressLevel = 0
  self.peakStress = 0
  self.nextJob = nil
  self.marker = CreateUnitByName("npc_dota_creep_marker", self.hero:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_NEUTRALS)
  self.marker:AddNewModifier(self.marker, nil, 'modifier_marker_creep', {})
  self.desiredIntensity = 10
  self.desiredStress = 0.2
  self.hordeAlive = 0
  self.wave = 1

  self.modifier = self.hero:AddNewModifier(self.hero, nil, 'modifier_player_watcher', {})

  local function addPlayerValue (name, value)
    DebugOverlay:AddEntry(self.debugGroupName, {
      Name = self.debugGroupName .. name,
      DisplayName = name,
      Value = value
    })
  end
  addPlayerValue("Stress", 0)
  addPlayerValue("Intensity", 0)


  Timers:CreateTimer(1, partial(self.Think, self))

  GameEvents:OnEntityKilled(function (keys)
    local killedUnit = EntIndexToHScript( keys.entindex_killed )
    if not killedUnit or killedUnit:GetTeam() == self.hero:GetTeam() then
      return
    end
    local location = killedUnit:GetAbsOrigin()
    local distance = (location - self.hero:GetAbsOrigin()):Length()
    if distance < 1000 then
      self:EntityKilledNearby(killedUnit, distance)
    end
  end)
end

function PlayerWatcher:IsPeakStress()
  return self.peakStress > 0
end

function PlayerWatcher:Think()
  local stressLevel = self:GetStressLevel()
  CustomNetTables:SetTableValue("info", "stressLevel", { value = stressLevel })

  if stressLevel == 1 then
    self.peakStress = 10

    if self.stressLevel < 1 then
      PeakStressEvent.broadcast(self)
    end
  else
    self.peakStress = math.max(0, self.peakStress - 1)
  end

  self.stressLevel = stressLevel

  DebugOverlay:Update(self.debugGroupName .. "Stress", {
    Value = self.stressLevel,
    forceUpdate = true
  })

  if self.hero:IsAlive() then
    if self.stressLevel > self.desiredStress and self.desiredIntensity > 0 then
      self.desiredIntensity = self.desiredIntensity - 1
    end
    if self.stressLevel < self.desiredStress and self.desiredIntensity < 100 then
      self.desiredIntensity = self.desiredIntensity + 1
    end
  end

  DebugOverlay:Update(self.debugGroupName .. "Intensity", {
    Value = self.desiredIntensity,
    forceUpdate = true
  })

  if self.stressLevel < self.desiredStress and not self.spawningHorde then
    DebugPrint('Lets spawn a group... ' .. self.stressLevel .. ' of target ' .. self.desiredStress)
    local horde = HordeSpawner:CreateHorde(self.wave, self.desiredIntensity)
    DebugPrintTable(horde)
    self:SpawnHorde(horde)
  end

  return THINK_INTERVAL
end

function PlayerWatcher:GetStressLevel()
  local stressLevel = 0
  if not self.hero:IsAlive() then
    return 1
  end

  local lastHP = self.lastHP
  local hpPercent = self.hero:GetHealth() / self.hero:GetMaxHealth()
  self.lastHP = (hpPercent + self.lastHP*2) / 3
  local hpDiff = (lastHP - self.lastHP) / THINK_INTERVAL

  local hpScale = math.min(1, hpDiff * 10)
  hpScale = math.max(0, hpDiff)

  -- DebugPrint('hp diff is ' .. hpScale)

  hpScale = hpScale + ((1 - hpPercent) / 2)

  -- DebugPrint('add in percentage ' .. hpScale)
  local nearbyUnits = FindUnitsInRadius(self.hero:GetTeam(), self.hero:GetAbsOrigin(), nil, 400,
    DOTA_UNIT_TARGET_TEAM_ENEMY, -- teamFilter
    DOTA_UNIT_TARGET_BASIC, -- int typeFilter
    DOTA_UNIT_TARGET_FLAG_NONE, -- int flagFilter,
    FIND_ANY_ORDER, -- int order,
    true -- bool canGrowCache
  )
  -- DebugPrint('kills... ' .. self.killedUnits .. ', ' .. self.killedNearbyUnits .. ', nearby ' .. #nearbyUnits)

  local stressLevel = hpScale * ((#nearbyUnits + 1) / (self.killedUnits + 1)) + (((self.killedUnits / 5) + (self.killedNearbyUnits / 3)) * math.max(0.2, 1-hpPercent)) + (1-hpPercent)/5
  stressLevel = math.min(1, stressLevel)

  stressLevel = math.ceil(((stressLevel + (self.stressLevel * 3)) / 4) * 100) / 100

  return stressLevel
end

function PlayerWatcher:EntityKilledNearby(unit, distance)
  self.killedUnits = self.killedUnits + 1
  local isNeaby = distance < 500
  if isNeaby then
    self.killedNearbyUnits = self.killedNearbyUnits + 1
  end

  Timers:CreateTimer(10, function()
    self.killedUnits = self.killedUnits - 1
    if isNeaby then
      self.killedNearbyUnits = self.killedNearbyUnits - 1
    end
  end)
end

function PlayerWatcher:SpawnUnit(unitName)
  self:ScheduleUnitSpawn(unitName, function (unit)
    -- rejoice?
  end)
end

function PlayerWatcher:SpawnHorde(unitTable)
  if self.spawningHorde then
    DebugPrint('Not spawning horde')
  end
  self.spawningHorde = true

  local function finished(units)
    DebugPrint('Just finished spawning the horde')
    Timers:CreateTimer(10, function()
      self.spawningHorde = false
    end)
  end

  if not SPAWN_AS_HORDE then
    local done = after(#unitTable, finished)
    for _,unit in ipairs(unitTable) do
      self:ScheduleUnitSpawn(unit, done)
    end
  else
    self:ScheduleHordeSpawn(unitTable, finished)
  end
end

function PlayerWatcher:ScheduleUnitSpawn(unitName, callback)
  self:FindSpawnPoint(function (location)
    DebugPrint('Spawning a creep at ...' .. tostring(location))
    self:SpawnUnitAt(unitName, location, callback)
  end)
end
function PlayerWatcher:ScheduleHordeSpawn(unitList, callback)
  self:FindSpawnPoint(function (location)
    DebugPrint('Spawning a horde at ...' .. tostring(location))
    local done = after(#unitList, callback)
    for _,unitName in ipairs(unitList) do
      self:SpawnUnitAt(unitName, location, done)
    end
  end)
end

function PlayerWatcher:SpawnUnitAt(unitName, location, callback)
  DebugPrint('Spawning unit ' .. unitName)
  CreateUnitByNameAsync(unitName, location, true, nil, nil, DOTA_TEAM_NEUTRALS, function (unit)
    local entIndex = unit:entindex()
    DebugPrint('unit has entid ' .. entIndex)
    local hordeWatcher = HordeWatcher()
    hordeWatcher:Init(unit, self.hero)
    self.hordeAlive = self.hordeAlive + 1
    unit:OnDeath(function ()
      DebugPrint('Horde unit died! ' .. unit:entindex())
      self.hordeAlive = self.hordeAlive - 1
    end)
    ExecuteOrderFromTable({
      UnitIndex = entIndex,
      OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
      Position = self.hero:GetAbsOrigin(), --Optional.  Only used when targeting the ground
      Queue = 0 --Optional.  Used for queueing up abilities
    })
    callback(unit)
  end)
end

function PlayerWatcher:FindSpawnPoint (callback)
  self.nextJob = {
    callback = callback,
    next = self.nextJob
  }
  self:StartJobQueue()
end

function PlayerWatcher:StartJobQueue()
  if not self.nextJob or self.isRunning then
    return
  end
  self.isRunning = true

  local function runJob (job)
    self:RunMarker(function (location)
      job.callback(location)
      self.nextJob = self.nextJob.next
      if self.nextJob then
        runJob(self.nextJob)
      else
        self.isRunning = false
      end
    end)
  end

  runJob(self.nextJob)
end

function PlayerWatcher:RunMarker (callback)
  local minRange = self.hero:GetCurrentVisionRange() + 200 -- just outside max vision

  DebugPrint('Range is ' .. minRange)

  local direction = RandomVector(1):Normalized()
  local spawnLocation = self.hero:GetAbsOrigin()
  spawnLocation.z = self.hero:GetAbsOrigin().z

  self.marker:SetAbsOrigin(spawnLocation)
  local firstRun = true
  local lastPosition = nil

  local function checkMarkerVisibility()
    local position = self.marker:GetAbsOrigin()
    if position == lastPosition then
      DebugPrint('Failed to find a spawn point in this direction, failing out and retrying')
      self:RunMarker(callback)
      return nil
    end
    if not firstRun then
      lastPosition = position
      if not self.hero:CanEntityBeSeenByMyTeam(self.marker) then
        local location = self.marker:GetAbsOrigin()
        if location == nil then
          return MARKER_INTERVAL
        end
        callback(location)
        return nil
      end
    end
    minRange = math.max(minRange / 2, 300)
    ExecuteOrderFromTable({
      UnitIndex = self.marker:entindex(),
      OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
      Position = self.marker:GetAbsOrigin() + (direction * minRange), --Optional.  Only used when targeting the ground
      Queue = 0 --Optional.  Used for queueing up abilities
    })
    firstRun = false
    return MARKER_INTERVAL
  end

  Timers:CreateTimer(0, checkMarkerVisibility)
end
