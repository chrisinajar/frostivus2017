Debug.EnabledModules['phases:bossfight'] = true

BossFight = BossFight or {}

local FinishedEvent = Event()

function BossFight:GetSpawnPoint()
  if not self.heroSpawnPos then
    local spawnPoint = Entities:FindByName(nil, "trigger_act_4_santa")
    assert(spawnPoint, "Failed to find player spawn point for act 4")
    self.heroSpawnPos = spawnPoint:GetAbsOrigin()
  end
  return self.heroSpawnPos
end

function BossFight:Prepare()
  DebugPrint('Preparing for boss fight...')
  local allPlayers = {}
  local function addToList (list, id)
    list[id] = true
  end
  each(partial(addToList, allPlayers), PlayerResource:GetAllTeamPlayerIDs())

  self.zone = ZoneControl:CreateZone("trigger_act_4_zone", {
    mode = ZONE_CONTROL_EXCLUSIVE_IN,
    players = allPlayers
  })
  FinishedEvent.once(function ()
    self.zone.disable()
  end)
end

function BossFight:Start(callback)
  Quests:NextAct({
    nextAct = 4
  })
  FinishedEvent.once(callback)
  HordeDirector:Pause()

  local spawnPoint = Entities:FindAllByName("trigger_act_4_evil_wisp")
  if #spawnPoint < 1 then
    error("Failed to find evil wisp spawn point")
  end

  spawnPoint = spawnPoint[1]:GetAbsOrigin()

  CustomGameEventManager:Send_ServerToAllClients("toggle_boss_bar", {
    showBossBar = true
  })
  self.boss = CreateUnitByName("npc_dota_evil_wisp", spawnPoint, true, nil, nil, DOTA_TEAM_BADGUYS)
  Timers:CreateTimer(function()
    CustomGameEventManager:Send_ServerToAllClients("update_boss_bar", {
      bossHP = self.boss:GetHealth(),
      bossMaxHP = self.boss:GetMaxHealth()
    })
    return .1
  end)
  self.boss:OnDeath(FinishedEvent.broadcast)
end
