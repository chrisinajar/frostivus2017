PhaseOne = PhaseOne or {}

local FinishedEvent = Event()

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
  FinishedEvent.once(function()
    self.running = false
    callback()
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

  local sleigh = Entities:FindAllByName("trigger_act_1_santa")
  if #sleigh < 1 then
    error("Failed to find act one sleigh repair spot")
  end
  local rosh_trig = Entities:FindAllByName("trigger_act_1_rosh_pos")
  if #rosh_trig < 1 then
    error("Failed to find act one rosh spot")
  end

  self.sleigh = sleigh[1]:GetAbsOrigin()
  self.rosh_sad = CreateUnitByName("npc_dota_santa_separate", rosh_trig[1]:GetAbsOrigin() , false, nil, nil, DOTA_TEAM_GOODGUYS)
  self.santa = CreateUnitByName("npc_dota_sleigh", self.sleigh, false, nil, nil, DOTA_TEAM_GOODGUYS)
  self.santa:OnDeath(function ()
    if self.running then
      GameRules:SetGameWinner(DOTA_TEAM_NEUTRALS)
    end
  end)
  FinishedEvent.once(function()
    if self.santa and not self.santa:IsNull() then
      self.santa:Destroy()
    end
    self.santa = nil
  end)
  Timers:CreateTimer(0, function()
    return self:SpawnHelper()
  end)
end

function PhaseOne:RepairInterval()
  if self.repairRemaining == 1 then
    FinishedEvent.broadcast({})
  end

  self.repairRemaining = self.repairRemaining - 1

end

function PhaseOne:SpawnHelper()
  if not self.running then
    return
  end

  local helper = CreateUnitByName("npc_dota_act_1_helper", self.spawnPoint, true, nil, nil, DOTA_TEAM_GOODGUYS)

  FinishedEvent.once(function()
    if not helper:IsNull() then
      helper:Destroy()
    end
  end)

  return 30
end
