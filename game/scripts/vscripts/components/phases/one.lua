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
  self.rosh_sad = CreateUnitByName("npc_dota_santa_separate", rosh_trig[1]:GetAbsOrigin() , false, nil, nil, DOTA_TEAM_GOODGUYS)
  FindClearSpaceForUnit(self.rosh_sad,rosh_trig[1]:GetAbsOrigin(),true)

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
    HordeDirector:ScheduleSpecialUnit("npc_dota_horde_special_4", self.spawnPoint, function (unit)
      unit:OnDeath(callback)
    end)
  end)
  self.running = true
  self.repairRemaining = REPAIR_UNITS_REQUIRED
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
end

function PhaseOne:RepairInterval()
  if self.repairRemaining == 1 then
    FinishedEvent.broadcast({})
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

  FinishedEvent.once(function()
    if not helper:IsNull() then
      helper:Destroy()
    end
  end)

  return 30
end
