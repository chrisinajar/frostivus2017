
--[[

  * Move the cart in straight lines in a random order between locations going from left to right then right to left
  |0--------5|
  |1--------6|
  |2--------7|
  |3--------8|
  |4--------9|
  Ex. 0 to 7 7 to 4 4 to 8 and so on 
  * Show progress bar for number of presents found vs how many need to be found
  * Flying cart gives vision
  * Have horde spawns and creep camps
  * Have some creeps (always visible with low health and movement speed) steal presents
]]

PhaseTwo = PhaseTwo or {}

local FinishedEvent = Event()

Debug.EnabledModules['phases:two'] = true

function PhaseTwo:Prepare(callback)
  local allPlayers = {}
  local function addToList (list, id)
    list[id] = true
  end
  each(partial(addToList, allPlayers), PlayerResource:GetAllTeamPlayerIDs())
  local spawnPoint = Entities:FindAllByName("trigger_act_2_path_0")
  if #spawnPoint < 1 then
    error("Failed to find player spawn point for act 2")
  end
  spawnPoint = spawnPoint[1]:GetAbsOrigin()
  for playerId,_ in pairs(allPlayers) do
    local hero = PlayerResource:GetSelectedHeroEntity(playerId)
    if not hero then
      error("Could not find hero for player " .. playerId)
    end
    FindClearSpaceForUnit(hero, spawnPoint, true)
    hero:SetDayTimeVisionRange(600)
    hero:SetNightTimeVisionRange(600)  
    hero:SetRespawnPosition(spawnPoint)
  end
end

function PhaseTwo:Start(callback)
  FinishedEvent.once(callback)
  DebugPrint("Starting Phase 2: Present Search")
  -- phase Two uses the director
  HordeDirector:Resume()

  self.Waypoints = {
    Trigger = self:MakeWaypointTriggerList({
      "trigger_act_2_path_0",
      "trigger_act_2_path_1",
      "trigger_act_2_path_2",
      "trigger_act_2_path_3",
      "trigger_act_2_path_4",
      "trigger_act_2_path_5",
      "trigger_act_2_path_6",
      "trigger_act_2_path_7",
      "trigger_act_2_path_8",
      "trigger_act_2_path_9",
      "trigger_act_2_path_10",
      "trigger_act_2_path_11"

    }),
    currentIndex = 1
  }

  self.CampLocation = {
    Trigger = self:MakeWaypointTriggerList({
      "trigger_act_2_camp_0",
      "trigger_act_2_camp_1"--[[,
      "trigger_act_2_camp_2",
      "trigger_act_2_camp_3",
      "trigger_act_2_camp_4",
      "trigger_act_2_camp_5",
      "trigger_act_2_camp_6",
      "trigger_act_2_camp_7",
      "trigger_act_2_camp_8",
      "trigger_act_2_camp_9",
      "trigger_act_2_camp_10",
      "trigger_act_2_camp_11",
      "trigger_act_2_camp_12",
      "trigger_act_2_camp_13"]]
    }),
    currentIndex = 1
  }
  for i = 1,#self.CampLocation.Trigger do
    DebugPrint('Creating a present')
    self:SpawnPresent(self.CampLocation.Trigger[i]:GetAbsOrigin())
  end
  self:SpawnPresent(self.Waypoints.Trigger[1]:GetAbsOrigin())
  self.SpawnPosition = self:GetCurrentWaypointTrigger():GetAbsOrigin()

  self.Cart = self:SpawnCart()
  --self.Cart.Handle:FindAbilityByName("santa_sled_move"):CastAbility()
--[[
  self.totalPathLength = self:CalculateMoveDistance(nil)
  assert(self.totalPathLength > 1, "totalPathLength must be larger than 1")
  self.pathLenghtLeft = self.totalPathLength
  self.distanceMoved = 0 --self.totalPathLength - self.pathLenghtLeft
]]

  DebugPrint("Finished Initializing Phase 2")
--[[
  DebugPrint("Creating DebugOverlay for Phase 2")

  self:AddDebugOverlayEntry("totalPathLength", "total path lenght", self.totalPathLength)
  self:AddDebugOverlayEntry("distanceMoved", "distance sled moved", self.totalPathLength - self.pathLenghtLeft)
  self:AddDebugOverlayEntry("pathLenghtLeft", "distance left to move", self.pathLenghtLeft)
  self:AddDebugOverlayEntry("currentTrigger", "current targeted trigger", self:GetCurrentWaypointTrigger():GetName())
  self:AddDebugOverlayEntry("projectileVelocity", "projectile velocity", Vector(0))
  self:AddDebugOverlayEntry("projectilePosition", "projectile position", Vector(0))
  self:AddDebugOverlayEntry("cartSpeed", "cart movement speed", 0)
  self:AddDebugOverlayEntry("unitsCapturing", "units capturing", 0)

  DebugPrint("Finished Creating DebugOverlay for Phase 2")
]]
  DebugPrint("Starting Timers for Phase 2")
--[[
  self.DebugOverlayUpdateTimer = Timers:CreateTimer(function()
    if self.Cart.Handle:IsNull() then
      return
    end
    self.pathLenghtLeft = self:CalculateMoveDistance(self.Cart.Handle:GetAbsOrigin())
    self.distanceMoved = self.totalPathLength - self.pathLenghtLeft
    self:UpdateProgressbar(self.distanceMoved / self.totalPathLength)
    self:UpdateDebugOverlayEntry("distanceMoved", self.totalPathLength - self.pathLenghtLeft)
    self:UpdateDebugOverlayEntry("pathLenghtLeft", self.pathLenghtLeft)
    self:UpdateDebugOverlayEntry("projectilePosition", self.Cart.Handle.ProjectilePosition)
    self:UpdateDebugOverlayEntry("cartSpeed", (self.Cart.Handle.Speed or 0))
    self:UpdateDebugOverlayEntry("unitsCapturing", self.Cart.Handle.StackCount)
    DebugOverlay:UpdateDisplay()
    return 1
  end)
]]
  self:SetCartTarget(self:GetCurrentWaypointTrigger():GetAbsOrigin())
  self.MainTimer = Timers:CreateTimer(function()
    if self.Cart.Handle:IsPositionInRange(self:GetCurrentWaypointTrigger():GetAbsOrigin(), (self.Cart.Handle.Speed or 0) + 100) then
      self:IncrementWaypointTriggerIndex()
      if self:IsRideDone() then
        DebugPrint("Ride is done, finishing up Phase 2")
        FinishedEvent.broadcast({}) -- we're done
        self:CleanUp()
        return
      else
        DebugPrint("Cart has reached Waypoint " ..   self.Waypoints.currentIndex ..". Targeting new Waypoint " ..   self.Waypoints.currentIndex + 1)
        --self:UpdateDebugOverlayEntry("currentTrigger", self:GetCurrentWaypointTrigger():GetName())
        self:SetCartTarget(self:GetCurrentWaypointTrigger():GetAbsOrigin())
        return 0.5
      end
    end
    return 2
  end)
end

function PhaseTwo:AddDebugOverlayEntry(name, display, value)
  DebugOverlay:AddEntry("Phase_forest", {
    Name = "Phase_forest" .. name,
    DisplayName = display,
    Value = value
  })
end

function PhaseTwo:UpdateDebugOverlayEntry(name, value)
  DebugOverlay:Update("Phase_forest" .. name, { Value = value })
end

function PhaseTwo:MakeWaypointTriggerList(TriggerNames)
  DebugPrint("Making Waypoint TriggerList")
  local TriggerList = {}
  for i,waypointName in ipairs(TriggerNames) do
    TriggerList[i] = Entities:FindByName(nil, waypointName)
    assert(TriggerList[i], "Couldn't find a Trigger with Name '" .. waypointName .. "'")
  end
  return TriggerList
end


function PhaseTwo:SpawnPresent(pos)
  local newItem = CreateItem("item_present_for_search", nil, nil)--"item_present_for_search", nil, nil)

  if not newItem then
    DebugPrint('Failed to find item: ' .. itemName)
    return
  end
  newItem:SetPurchaseTime(0)
  newItem.firstPickedUp = false

  CreateItemOnPositionSync(pos, newItem)
  return
end

function PhaseTwo:SpawnCart()
  local santa = CreateUnitByName("npc_dota_search_santa", self.SpawnPosition, false, nil, nil, DOTA_TEAM_GOODGUYS) --spawn santa ready for his sled
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

function PhaseTwo:IsRideDone()
  return self:GetCurrentWaypointTrigger() == nil
end

function PhaseTwo:GetCurrentWaypointTrigger()
  return self.Waypoints.Trigger[self.Waypoints.currentIndex]
end

function PhaseTwo:IncrementWaypointTriggerIndex()
  if (self.Waypoints.currentIndex < 6) then
    self.Waypoints.currentIndex = 5 + math.random(6)
  else
    self.Waypoints.currentIndex = math.random(6)-1
  end
end

function PhaseTwo:SetCartTarget(targetPosition)
  DebugPrint("Updating Carts TargetPosition to " .. targetPosition.x .. ", " .. targetPosition.y)
  self.Cart.ProjectileTarget:SetAbsOrigin(targetPosition)
  self.Cart.Handle:SetThink(function() self.Cart.Handle:MoveToPosition(targetPosition)end)
end

function PhaseTwo:CleanUp()
  self.Cart.Handle:ForceKill(false)
  Timers:RemoveTimer("Phase2MainTimer")
end

function PhaseTwo:ThrowPresent(targetPosition)
end

function PhaseTwo:MakeProgressBar(text)
end

function PhaseTwo:UpdateProgressbar(percentage)
end
