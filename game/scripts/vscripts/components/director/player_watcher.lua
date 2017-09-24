LinkLuaModifier('modifier_marker_creep', 'modifiers/modifier_marker_creep', LUA_MODIFIER_MOTION_NONE)

PlayerWatcher = PlayerWatcher or class({})

function PlayerWatcher:Init(playerID)
  DebugPrint('Init player watcher for ' .. playerID)
  self.playerID = playerID
  self.hero = PlayerResource:GetSelectedHeroEntity(playerID)
  self.currentSpawnInterval = 10

  Timers:CreateTimer(1, function ()
    self:SpawnUnit()
  end)
end

function PlayerWatcher:SpawnUnit()
  self:FindSpawnPoint(function (location)
    DebugPrint('Spawning a creep at ...' .. tostring(location))
    DebugPrintTable(location)
    Timers:CreateTimer(RandomInt(self.currentSpawnInterval * 0.5, self.currentSpawnInterval * 1.5), function ()
      self:SpawnUnit()
    end)
  end)
end

function PlayerWatcher:FindSpawnPoint (callback)
  local minRange = self.hero:GetCurrentVisionRange() + 200 -- just outside max vision

  DebugPrint('Range is ' .. minRange)

  local direction = RandomVector(1):Normalized()
  local spawnLocation = self.hero:GetAbsOrigin() + (direction * minRange)
  spawnLocation.z = self.hero:GetAbsOrigin().z

  local marker = self:CreateSpawnMarker(spawnLocation)
  local firstRun = true

  local function checkMarkerVisibility()
    if not firstRun and not self.hero:CanEntityBeSeenByMyTeam(marker) then
      local location = marker:GetAbsOrigin()
      if location == nil then
        return 1
      end
      marker:Destroy()
      callback(location)
      return nil
    end
    firstRun = false
    ExecuteOrderFromTable({
      UnitIndex = marker:entindex(),
      OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
      Position = marker:GetAbsOrigin() + (direction * 1000), --Optional.  Only used when targeting the ground
      Queue = 0 --Optional.  Used for queueing up abilities
    })
    return 1
  end

  Timers:CreateTimer(0, checkMarkerVisibility)
end

function PlayerWatcher:CreateSpawnMarker(spawnLocation)
  local unit = CreateUnitByName("npc_dota_creep_marker", spawnLocation, true, nil, nil, DOTA_TEAM_NEUTRALS)

  unit:AddNewModifier(unit, nil, 'modifier_marker_creep', {})
  return unit
end
