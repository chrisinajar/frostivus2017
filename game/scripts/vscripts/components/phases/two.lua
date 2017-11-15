
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

  self.playerList = allPlayers
  local spawnPoint = Entities:FindAllByName("trigger_act_2_santa")
  if #spawnPoint < 1 then
    error("Failed to find player spawn point for act 2")
  end

  self.heroSpawnPos = spawnPoint[1]:GetAbsOrigin()
  self.SpawnPosition = self.heroSpawnPos
  for playerId,_ in pairs(allPlayers) do
    local hero = PlayerResource:GetSelectedHeroEntity(playerId)
    if not hero then
      error("Could not find hero for player " .. playerId)
    end
    -- Strong dispel buffs and debuffs
    hero:Purge(true, true, false, true, true)
    FindClearSpaceForUnit(hero, self.heroSpawnPos, true)
    hero:SetDayTimeVisionRange(600)
    hero:SetNightTimeVisionRange(600)
    hero:SetRespawnPosition(self.heroSpawnPos)
    hero:RespawnHero(false, false)
  end

  self.PresentsToPickUp = NUMBER_PRESENTS_REQUIRED

  GameEvents:OnItemPickedUp(function (keys)
    local player = PlayerResource:GetPlayer(keys.PlayerID)
    local itemname = keys.itemname
    local itemEntity = EntIndexToHScript(keys.ItemEntityIndex)
    DebugPrint(itemname)
    if itemname == "item_present_for_search" then
      self.PresentsToPickUp = self.PresentsToPickUp - 1;
      Quests:ModifyProgress(1)
      if self.PresentsToPickUp <= 0 then
        DebugPrint("All presents found, finishing up Phase 2")
        FinishedEvent.broadcast({}) -- we're done
        self:CleanUp()
      end
    end
  end)

end

function PhaseTwo:Start(callback)
  Quests:NextAct({
    nextAct = 2,
    maxProgress = NUMBER_PRESENTS_REQUIRED
  })
  FinishedEvent.once(callback)
  self.isRunning = true
  DebugPrint("Starting Phase 2: Present Search")
  -- phase Two uses the director
  HordeDirector:Resume()

  self.Waypoints = {
    Trigger = self:MakeWaypointTriggerMap({
      "trigger_act_2_santa",
      "trigger_act_2_path_1_1_1",
      "trigger_act_2_path_1_1_2",
      "trigger_act_2_path_1_2_1",
      "trigger_act_2_path_1_2_2",
      "trigger_act_2_path_2_1_1",
      "trigger_act_2_path_2_1_2",
      "trigger_act_2_path_2_1_3",
      "trigger_act_2_path_2_2_1",
      "trigger_act_2_path_2_2_2",
      "trigger_act_2_path_3_1_1",
      "trigger_act_2_path_3_1_2",
      "trigger_act_2_path_3_2_1",
      "trigger_act_2_path_3_2_2",
      "trigger_act_2_path_3_2_3",
      "trigger_act_2_path_4_1_1",
      "trigger_act_2_path_4_1_2"
    }),
    currentIndexName = "trigger_act_2_santa",
    currentIndex = 0,
    currentOption = 1,
    currentStep = 1,
  }

  self.CampLocation = {
    Trigger = self:MakeWaypointTriggerList({
      "trigger_act_2_camp_0",
      "trigger_act_2_camp_1",
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
      "trigger_act_2_camp_13"
    }),
    presentIndex = {
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0
    }
  }
  local spawnPresentsNum = 0
  while spawnPresentsNum < NUMBER_PRESENTS_SPAWNED do
    local tospawnIt = math.random(14)
    if self.CampLocation.presentIndex[tospawnIt] == 0 then
      self:SpawnPresent(self.CampLocation.Trigger[tospawnIt]:GetAbsOrigin())
      self.CampLocation.presentIndex[tospawnIt] = 1
      spawnPresentsNum = spawnPresentsNum + 1
      DebugPrint('Creating a present')
    end
  end
  --[[
  for i = 1,#self.CampLocation.Trigger do
    DebugPrint('Creating a present')
    self:SpawnPresent(self.CampLocation.Trigger[i]:GetAbsOrigin())
  end
  ]]

  self.Cart = self:SpawnCart()

  DebugPrint("Finished Initializing Phase 2")

  DebugPrint("Starting Timers for Phase 2")

  self:IncrementWaypointTriggerIndex()
  self:SetCartTarget(self:GetCurrentWaypointTrigger():GetAbsOrigin())
  self.MainTimer = Timers:CreateTimer(function()
    if not self.isRunning then
      return
    end
    if self.Cart.Handle:IsPositionInRange(self:GetCurrentWaypointTrigger():GetAbsOrigin(), (self.Cart.Handle.Speed or 0) + 100) then
      self:IncrementWaypointTriggerIndex()
      if self:IsRideDone() then
        DebugPrint("All presents found, finishing up Phase 2")
        -- FinishedEvent.broadcast({}) -- we're done
        -- lost the game
        StorylineManager:Defeat("Failed to find the presents in time")
        self:CleanUp()
        return
      else
        DebugPrint("Cart has reached Waypoint " ..   self.Waypoints.currentIndex ..". Targeting new Waypoint " ..   self.Waypoints.currentIndex + 1)

        self:SetCartTarget(self:GetCurrentWaypointTrigger():GetAbsOrigin())
        return 0.5
      end
    end
    return 2
  end)
end

function PhaseTwo:AddDebugOverlayEntry (name, display, value)
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

function PhaseTwo:MakeWaypointTriggerMap(TriggerNames)
  DebugPrint("Making Waypoint TriggerMap")
  local TriggerMap = {}
  for i,waypointName in ipairs(TriggerNames) do
    TriggerMap[waypointName] = Entities:FindByName(nil, waypointName)
    assert(TriggerMap[waypointName], "Couldn't find a Trigger with Name '" .. waypointName .. "'")
  end
  return TriggerMap
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
  return self.Waypoints.Trigger[self:WaypointName(self.Waypoints.currentIndex, self.Waypoints.currentOption, self.Waypoints.currentStep)]
end

function PhaseTwo:WaypointName(currentIndex, currentOption, currentStep)
  return "trigger_act_2_path_" .. tostring(currentIndex) .. "_" .. tostring(currentOption) .. "_" .. tostring(currentStep)
end

function PhaseTwo:IncrementWaypointTriggerIndex()
  local wp = self.Waypoints
  local nextStep = wp.Trigger[self:WaypointName(wp.currentIndex, wp.currentOption, wp.currentStep + 1)]
  if nextStep then
    self.Waypoints.currentStep = self.Waypoints.currentStep + 1
    return
  end
  self.Waypoints.currentIndex = self.Waypoints.currentIndex + 1
  local maxOptions = 1
  while wp.Trigger[self:WaypointName(wp.currentIndex, maxOptions + 1, 1)] do
    maxOptions = maxOptions + 1
  end
  self.Waypoints.currentOption = RandomInt(1, maxOptions)
  self.Waypoints.currentStep = 1
end

function PhaseTwo:SetCartTarget(targetPosition)
  DebugPrint("Updating Carts TargetPosition to " .. targetPosition.x .. ", " .. targetPosition.y)
  self.Cart.ProjectileTarget:SetAbsOrigin(targetPosition)
  self.Cart.Handle:SetThink(function() self.Cart.Handle:MoveToPosition(targetPosition)end)
end

function PhaseTwo:CleanUp()
  for playerId,_ in pairs(self.playerList) do
    local hero = PlayerResource:GetSelectedHeroEntity(playerId)
    if not hero then
      error("Could not find hero for player " .. playerId)
    end
    hero:SetDayTimeVisionRange(1800)
    hero:SetNightTimeVisionRange(1000)
    if hero:HasItemInInventory("item_present_for_search") then
      for i = 0,5 do
        local itemHandle = hero:GetItemInSlot(i)
        if itemHandle ~= nil then
          if itemHandle:GetName() == "item_present_for_search" then
            hero:RemoveItem(itemHandle)
          end
        end
      end
    end
  end

  if not self.Cart.Handle:IsNull() then
    self.Cart.Handle:Destroy()
  end
  self.isRunning = false
  Timers:RemoveTimer("Phase2MainTimer")
end

function PhaseTwo:ThrowPresent(targetPosition)
end

function PhaseTwo:MakeProgressBar(text)
end

function PhaseTwo:UpdateProgressbar(percentage)
end
