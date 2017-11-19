-- https://github.com/chrisinajar/frostivus2017/issues/9
--[[
Standard payload rules, the more heroes that are near the cart the faster it goes. Certain enemies will count against the heroes, but not all, such that the cart goes slower or even backwards.

  * Use any model for the payload cart for now, it'll be replaced later
  * Move the cart in straight lines from each of a number of zones payload_1, payload_2,...
  * Show progress bar (add up the distance between all points and store it, keep track of current distance)
  * Positive aura coming from cart that applies modifier on the heroes to let them know when they're in range to help push the cart
  * Show positive/negative debuff on cart of how many heroes / special creeps are helping or hurting
  * Show particle circle indiating range
]]

PhaseThree = PhaseThree or {}

local FinishedEvent = Event()
Debug.EnabledModules['phases:three'] = true

function PhaseThree:GetSpawnPoint()
  if not self.heroSpawnPos then
    local spawnPoint = Entities:FindByName(nil, "trigger_act_3_path_0")
    assert(spawnPoint, "Failed to find player spawn point for act 3")
    self.heroSpawnPos = spawnPoint:GetAbsOrigin()
  end
  return self.heroSpawnPos
end

function PhaseThree:Prepare()
  local tankSpawn = Entities:FindAllByName("trigger_act_3_tank_spawn")
  if #tankSpawn < 1 then
    error("Failed to find tank spawn for act 3")
  end
  self.tankSpawn = tankSpawn[1]:GetAbsOrigin()
end

function PhaseThree:Start(callback)
  Quests:NextAct({
    nextAct = 3
  })

  FinishedEvent.once(callback)
  DebugPrint("Starting Phase 3: Payload")
  -- phase three uses the director
  HordeDirector:Resume()

  self.Waypoints = {
    Trigger = self:MakeWaypointTriggerList({
      "trigger_act_3_path_0",
      "trigger_act_3_path_1",
      "trigger_act_3_path_2",
      "trigger_act_3_path_3",
      "trigger_act_3_path_4",
      "trigger_act_3_path_5",
      "trigger_act_3_path_6",
      "trigger_act_3_path_7"
    }),
    currentIndex = 1,
    tankIndex = 6,
    tankSpawned = false,
    tankDied = false
  }

  self.SpawnPosition = self:GetCurrentWaypointTrigger():GetAbsOrigin()
  self.SantaSpawnPosition = self.SpawnPosition

  self.Cart = self:SpawnCart()
  self.Cart.Handle:FindAbilityByName("santa_sled_move"):CastAbility()

  self.totalPathLength = self:CalculateMoveDistance(nil)
  assert(self.totalPathLength > 1, "totalPathLength must be larger than 1")
  self.pathLenghtLeft = self.totalPathLength
  self.distanceMoved = 0 --self.totalPathLength - self.pathLenghtLeft

  DebugPrint("Finished Initializing Phase 3")
  DebugPrint("Creating DebugOverlay for Phase 3")

  self:AddDebugOverlayEntry("totalPathLength", "total path lenght", self.totalPathLength)
  self:AddDebugOverlayEntry("distanceMoved", "distance sled moved", self.totalPathLength - self.pathLenghtLeft)
  self:AddDebugOverlayEntry("pathLenghtLeft", "distance left to move", self.pathLenghtLeft)
  self:AddDebugOverlayEntry("currentTrigger", "current targeted trigger", self:GetCurrentWaypointTrigger():GetName())
  self:AddDebugOverlayEntry("projectileVelocity", "projectile velocity", Vector(0))
  self:AddDebugOverlayEntry("projectilePosition", "projectile position", Vector(0))
  self:AddDebugOverlayEntry("cartSpeed", "cart movement speed", 0)
  self:AddDebugOverlayEntry("unitsCapturing", "units capturing", 0)

  DebugPrint("Finished Creating DebugOverlay for Phase 3")
  DebugPrint("Starting Timers for Phase 3")

  self.DebugOverlayUpdateTimer = Timers:CreateTimer(function()
    if self.Cart.Handle:IsNull() then
      return
    end
    self.pathLenghtLeft = self:CalculateMoveDistance(self.Cart.Handle:GetAbsOrigin())
    self.distanceMoved = self.totalPathLength - self.pathLenghtLeft
    self:UpdateProgressbar(self.distanceMoved / self.totalPathLength)
    self:UpdateDebugOverlayEntry("distanceMoved", self.distanceMoved)
    self:UpdateDebugOverlayEntry("pathLenghtLeft", self.pathLenghtLeft)
    self:UpdateDebugOverlayEntry("projectilePosition", self.Cart.Handle.ProjectilePosition)
    self:UpdateDebugOverlayEntry("cartSpeed", (self:GetCartSpeed()))
    self:UpdateDebugOverlayEntry("unitsCapturing", self.Cart.Handle.StackCount)
    DebugOverlay:UpdateDisplay()
    return 1
  end)

  self:SetCartTarget(self:GetCurrentWaypointTrigger():GetAbsOrigin())
  self.MainTimer = Timers:CreateTimer(function()
    if self.Cart.Handle:IsPositionInRange(self:GetCurrentWaypointTrigger():GetAbsOrigin(), (self:GetCartSpeed()) + 100) then
      self:IncrementWaypointTriggerIndex()
      if self:IsRideDone() then
        DebugPrint("Ride is done, finishing up Phase 3")
        FinishedEvent.broadcast({}) -- we're done
        self:CleanUp()
        return
      else
        DebugPrint("Cart has reached Waypoint " ..   self.Waypoints.currentIndex - 1 ..". Targeting new Waypoint " ..   self.Waypoints.currentIndex)
        self:UpdateDebugOverlayEntry("currentTrigger", self:GetCurrentWaypointTrigger():GetName())
        self:SetCartTarget(self:GetCurrentWaypointTrigger():GetAbsOrigin())
        return 0.5
      end
    end
    return 2
  end)
end

function PhaseThree:GetCartSpeed()
  if self.Cart.Handle.IsStopped then
    return 0
  end
  return self.Cart.Handle.Speed or 0
end

function PhaseThree:AddDebugOverlayEntry(name, display, value)
  DebugOverlay:AddEntry("Phase_payload", {
    Name = "Phase_payload" .. name,
    DisplayName = display,
    Value = value
  })
end

function PhaseThree:UpdateDebugOverlayEntry(name, value)
  DebugOverlay:Update("Phase_payload" .. name, { Value = value })
end

function PhaseThree:MakeWaypointTriggerList(TriggerNames)
  DebugPrint("Making Waypoint TriggerList")
  local TriggerList = {}
  for i,waypointName in ipairs(TriggerNames) do
    TriggerList[i] = Entities:FindByName(nil, waypointName)
    assert(TriggerList[i], "Couldn't find a Trigger with Name '" .. waypointName .. "'")
  end
  return TriggerList
end

function PhaseThree:SpawnCart()
  local santa = CreateUnitByName("npc_dota_payload_santa", self.SantaSpawnPosition, false, nil, nil, DOTA_TEAM_GOODGUYS) --spawn santa ready for his sled
  assert(santa, "Failed to spawn santa")
  local projectileTarget = CreateUnitByName("npc_dota_target_marker", self.SpawnPosition, false, nil, nil, DOTA_TEAM_GOODGUYS)
  assert(projectileTarget, "Failed to spawn ProjectileTarget")
  santa.ProjectileTarget = projectileTarget
  santa.ProjectileSpawnLocation = self.SpawnPosition

  return {
    ProjectileTarget = projectileTarget,
    Handle = santa,
  }
end

function PhaseThree:CalculateMoveDistance(startPosition)
  local distanceToMove = 0
  local distance = 0
  local lastWaypointPosition = startPosition or self.Waypoints.Trigger[1]:GetAbsOrigin()
  local currentWaypointPosition = nil

  for i,Waypoint in ipairs(self.Waypoints.Trigger) do
    if i >= self.Waypoints.currentIndex then
      -- if we're on 1 headed to 2, then this doesn't run for 1
      -- it does run for 2
      currentWaypointPosition = Waypoint:GetAbsOrigin()
      distance = (lastWaypointPosition - currentWaypointPosition):Length2D()
      distanceToMove = distanceToMove + distance
      lastWaypointPosition = currentWaypointPosition
    end
  end

  return distanceToMove
end

function PhaseThree:IsRideDone()
  return self:GetCurrentWaypointTrigger() == nil
end

function PhaseThree:GetCurrentWaypointTrigger()
  return self.Waypoints.Trigger[self.Waypoints.currentIndex]
end

function PhaseThree:IncrementWaypointTriggerIndex()
  self.Waypoints.currentIndex = self.Waypoints.currentIndex + 1

  if self.Waypoints.currentIndex == self.Waypoints.tankIndex and not self.Waypoints.tankSpawned then
    self.Waypoints.tankSpawned = true
    self.tankUnit = HordeDirector:ScheduleSpecialUnit("npc_dota_horde_special_4_act3", self.tankSpawn)
    self.Cart.Handle.IsStopped = true
    self.tankUnit:OnDeath(function ()
      self.Waypoints.tankDied = true
      self.Cart.Handle.IsStopped = false

      self.tankUnit:OnDeath(function()
        TankCreepItemDrop:DropItem(self.tankUnit, 1)
      end)
    end)
  end
end

function PhaseThree:SetCartTarget(targetPosition)
  DebugPrint("Updating Carts TargetPosition to " .. targetPosition.x .. ", " .. targetPosition.y)
  self.Cart.ProjectileTarget:SetAbsOrigin(targetPosition)
end

function PhaseThree:CleanUp()
  self.Cart.Handle:ForceKill(false)
  Timers:RemoveTimer("Phase3MainTimer")
end

function PhaseThree:ThrowPresent(targetPosition)
end

function PhaseThree:MakeProgressBar(text)
end

function PhaseThree:UpdateProgressbar(percentage)
  Quests:UpdateProgress(percentage * 100)
end
