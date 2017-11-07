Debug.EnabledModules['phases:bossfight'] = true

BossFight = BossFight or {}

local FinishedEvent = Event()

function BossFight:Prepare()
  DebugPrint('Preparing for boss fight...')
  local allPlayers = {}
  local function addToList (list, id)
    list[id] = true
  end
  each(partial(addToList, allPlayers), PlayerResource:GetAllTeamPlayerIDs())

  local spawnPoint = Entities:FindAllByName("trigger_act_4_santa")
  if #spawnPoint < 1 then
    error("Failed to find player spawn point for boss fight")
  end
  spawnPoint = spawnPoint[1]:GetAbsOrigin()
  for playerId,_ in pairs(allPlayers) do
    local hero = PlayerResource:GetSelectedHeroEntity(playerId)
    if not hero then
      error("Could not find her for player " .. playerId)
    end
    FindClearSpaceForUnit(hero, spawnPoint, true)
    hero:SetRespawnPosition(spawnPoint)
  end

  self.zone = ZoneControl:CreateZone("trigger_act_4_zone", {
    mode = ZONE_CONTROL_EXCLUSIVE_IN,
    players = allPlayers
  })
  FinishedEvent.once(function ()
    self.zone.disable()
  end)
end

function BossFight:Start(callback)
  FinishedEvent.once(callback)
  HordeDirector:Pause()

  local spawnPoint = Entities:FindAllByName("trigger_act_4_evil_wisp")
  if #spawnPoint < 1 then
    error("Failed to find evil wisp spawn point")
  end

  spawnPoint = spawnPoint[1]:GetAbsOrigin()

  self.boss = CreateUnitByName("npc_dota_evil_wisp", spawnPoint, true, nil, nil, DOTA_TEAM_NEUTRALS)
  self.boss:OnDeath(FinishedEvent.broadcast)
end
