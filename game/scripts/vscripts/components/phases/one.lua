PhaseOne = PhaseOne or {}

local FinishedEvent = Event()

--[[
TODO: Move code from init back into prepare
Teleport players as part of prepare after santa is spawned
remove init method and remove InitModule line calling it
]]

function PhaseOne:Init()
  local sleightrig = Entities:FindAllByName("trigger_act_1_santa")
  if #sleightrig < 1 then
    error("Failed to find act one sleigh repair spot")
  end
  local rosh_trig = Entities:FindAllByName("trigger_act_1_rosh_pos")
  if #rosh_trig < 1 then
    error("Failed to find act one rosh spot")
  end

  self.sleigh_pos = sleightrig[1]:GetAbsOrigin()
--[[
  self.rosh_sad = CreateUnitByName("npc_dota_santa_separate", rosh_trig[1]:GetAbsOrigin() , false, nil, nil, DOTA_TEAM_GOODGUYS)
  FindClearSpaceForUnit(self.rosh_sad,rosh_trig[1]:GetAbsOrigin(),true)
]]

  self.santa_sleigh_holder = CreateUnitByName("npc_dota_sleigh", self.sleigh_pos, false, nil, nil, DOTA_TEAM_GOODGUYS)

end

function PhaseOne:Prepare()
  local allPlayers = {}
  local function addToList (list, id)
    list[id] = true
  end
  each(partial(addToList, allPlayers), PlayerResource:GetAllTeamPlayerIDs())


  for playerId,_ in pairs(allPlayers) do
    local hero = PlayerResource:GetSelectedHeroEntity(playerId)
    if not hero then
      error("Could not find hero for player " .. playerId)
    else
      for i = 0,5 do
        local itemHandle = hero:GetItemInSlot(i)
        if itemHandle ~= nil then
          hero:RemoveItem(itemHandle)
        end
      end
	  hero:AddItem(CreateItem("item_starting_gift", hero, hero))
    end
  end
  local rosh_trig = Entities:FindAllByName("trigger_act_1_rosh_pos")
  self.rosh_sad = CreateUnitByName("npc_dota_santa_separate", rosh_trig[1]:GetAbsOrigin() , false, nil, nil, DOTA_TEAM_GOODGUYS)
  FindClearSpaceForUnit(self.rosh_sad,rosh_trig[1]:GetAbsOrigin(),true)

  self.zone = ZoneControl:CreateZone("trigger_act_1_zone", {
    mode = ZONE_CONTROL_EXCLUSIVE_IN,
    players = allPlayers
  })
  FinishedEvent.once(function ()
    self.zone.disable()
  end)
end

function PhaseOne:Start(callback)
  Quests:NextAct({
    nextAct = 1
  })
  FinishedEvent.once(function()
    self.running = false
    HordeDirector:Pause()
    callback()
  end)
  self.running = true
  self.repairRemaining = REPAIR_UNITS_REQUIRED
  self.examplePartCreated = false
  self.exampleTurnedIn = false
  self.hasRetrievedItemOne = false
  self.hasRetrievedItemTwo = false
  self.isRetrievingItemOne = false
  self.isRetrievingItemTwo = false
  -- phase one uses the director
  HordeDirector:Resume()

  -- do stuff?
  -- call FinishedEvent.broadcast({}) when we're done

  local spawnPoint = Entities:FindAllByName("trigger_act_1_helper_spawn")
  if #spawnPoint < 1 then
    error("Failed to find act one helper spawn point")
  end
  self.spawnPoint = spawnPoint[1]:GetAbsOrigin()

  self.santa_sleigh = CreateUnitByName("npc_dota_sleigh", self.sleigh_pos, false, nil, nil, DOTA_TEAM_GOODGUYS)
  self.santa_sleigh:OnDeath(function ()
    if self.running then
      GameRules:SetGameWinner(DOTA_TEAM_NEUTRALS)
    end
  end)

  FinishedEvent.once(function()
    if self.santa_sleigh and not self.santa_sleigh:IsNull() then
      self.santa_sleigh:Destroy()
    end
    if self.rosh_sad and not self.rosh_sad:IsNull() then
      self.rosh_sad:Destroy()
    end
    self.rosh_sad = nil
    self.santa_sleigh = nil
  end)
  for i = 1,MAX_HELPERS do
    self:SpawnHelper()
  end
  self.helpersAlive = MAX_HELPERS

end

function PhaseOne:PartTurnedIn()
  if not self.exampleTurnedIn then
    self.exampleTurnedIn = true
  else
    if self.isRetrievingItemOne and not self.hasRetrievedItemOne then
      self.hasRetrievedItemOne = true
      self.isRetrievingItemOne = false
      Timers:RemoveTimer(self.part1Timer)
    elseif self.isRetrievingItemTwo and not self.hasRetrievedItemTwo then
      self.hasRetrievedItemTwo = true
      self.isRetrievingItemTwo = false
      Timers:RemoveTimer(self.part2Timer)
    end 
  end
end


function PhaseOne:RepairInterval()
  if self.isFightingTank then
    return
  end
  if self.isRetrievingItemOne or self.isRetrievingItemTwo then
    return
  end
  if self.repairRemaining == 1 then
    FinishedEvent.broadcast({})
    return
  end
  if not self.examplePartCreated and self.repairRemaining <= REPAIR_UNITS_REQUIRED * (1 - (ITEM_ONE_RETRIEVAL_PERCENT-10) / 100) then
    local sleightrig = Entities:FindAllByName("trigger_act_1_santa")
    local partExamplePos = sleightrig[1]:GetAbsOrigin()
    local examplePart = CreateItem("item_part_retrieval", nil, nil)
    examplePart:SetPurchaseTime(0)
    examplePart.firstPickedUp = false
    CreateItemOnPositionSync(partExamplePos, examplePart)
    examplePart:LaunchLoot(false, 300, 0.75, partExamplePos + RandomVector(RandomFloat(200, 250)))
    self.examplePartCreated = true
    Notifications:TopToAll({text="A part popped loose! Return it to the sleigh.", duration=10.0})
  end


  if not self.hasRetrievedItemOne and self.repairRemaining <= REPAIR_UNITS_REQUIRED * (1 - ITEM_ONE_RETRIEVAL_PERCENT / 100) then
    self.isRetrievingItemOne = true
    Notifications:TopToAll({text="Repairs Halted: There is another missing part, go look it", duration=10.0})
    

    local trigName = "trigger_act_1_part_spawn_"..tostring(RandomInt(1, 3))
    print(trigName)
    local partSpawnPoint = Entities:FindAllByName(trigName)
    if #partSpawnPoint < 1 then
      error("Failed to find act one part spawn point")
    end
    local partPos = partSpawnPoint[1]:GetAbsOrigin()

    local newItem = CreateItem("item_part_retrieval", nil, nil)

    if not newItem then
    DebugPrint('Failed to find item: ' .. "item_part_retrieval")
    return
    end
    newItem:SetPurchaseTime(0)
    newItem.firstPickedUp = false

    CreateItemOnPositionSync(partPos, newItem)
    newItem:LaunchLoot(false, 100, 0.35, partPos + RandomVector(RandomFloat(20, 50)))
    self.part1Timer = Timers:CreateTimer(function()
      AddFOWViewer(self.santa_sleigh:GetTeamNumber(),partPos,400.0,1.5,true)
      return 1.0
    end)
    

  end
  if not self.hasRetrievedItemTwo and self.repairRemaining <= REPAIR_UNITS_REQUIRED * (1 - ITEM_TWO_RETRIEVAL_PERCENT / 100) then
    self.isRetrievingItemTwo = true
    Notifications:TopToAll({text="Repairs Halted: Go look for the last missing part", duration=10.0})
    local trigName = "trigger_act_1_part_spawn_"..tostring(RandomInt(1, 3))
    print(trigName)
    local partSpawnPoint = Entities:FindAllByName(trigName)
    if #partSpawnPoint < 1 then
      error("Failed to find act one part spawn point")
    end
    local partPos = partSpawnPoint[1]:GetAbsOrigin()

    local newItem = CreateItem("item_part_retrieval", nil, nil)

    if not newItem then
    DebugPrint('Failed to find item: ' .. "item_part_retrieval")
    return
    end
    newItem:SetPurchaseTime(0)
    newItem.firstPickedUp = false

    CreateItemOnPositionSync(partPos, newItem)
    self.part2Timer = Timers:CreateTimer(function()
      AddFOWViewer(self.santa_sleigh:GetTeamNumber(),partPos,400.0,1.5,true)
      return 1.0
    end)
    --newItem:LaunchLoot(false, 300, 0.75, partPos + RandomVector(RandomFloat(100, 150)))
  end


  if not self.hasKilledTank and self.repairRemaining <= REPAIR_UNITS_REQUIRED * (1 - TANK_PERCENT_SPAWN / 100) then
    HordeDirector:Pause()
    self.isFightingTank = true
    HordeDirector:ScheduleSpecialUnit("npc_dota_horde_special_4", self.spawnPoint, function (unit)
      unit:OnDeath(function()
        HordeDirector:Resume()
        self.isFightingTank = false
        self.hasKilledTank = true
        TankCreepItemDrop:DropItem(unit, 1)
      end)
    end)
  end

  self.repairRemaining = self.repairRemaining - 1
  Quests:ModifyProgress(1 / REPAIR_UNITS_REQUIRED * 100)
end

function PhaseOne:SpawnHelper()
  if not self.running then
    return
  end
  if self.santa_sleigh_holder and not self.santa_sleigh_holder:IsNull() then
      self.santa_sleigh_holder:Destroy()
      self.santa_sleigh_holder = nil
  end
  local helper = CreateUnitByName("npc_dota_act_1_helper", self.spawnPoint, true, nil, nil, DOTA_TEAM_GOODGUYS)

  helper:OnDeath(function ()
    self.helpersAlive = self.helpersAlive - 1
    if self.running and self.helpersAlive <=0 then
      GameRules:SetGameWinner(DOTA_TEAM_NEUTRALS)
    end
  end)

  FinishedEvent.once(function()
    if not helper:IsNull() then
      helper:Destroy()
    end
  end)

  return 30
end
