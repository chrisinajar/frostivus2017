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

function PhaseThree:Start(callback)
  FinishedEvent.once(callback)

  self.Waypoints = {
    Triggers = self:MakeWaypointTriggerList({
      "trigger_act_3_path_0",
      "trigger_act_3_path_1",
      "trigger_act_3_path_2",
      "trigger_act_3_path_3",
      "trigger_act_3_path_4",
      "trigger_act_3_path_5",
      "trigger_act_3_path_6",
      "trigger_act_3_path_7"
    }),
    currentIndex = nil
  }

  self.Cart = self:SpawnCart()

  self.distanceMoved = 0
  self.distanceToMove = self:CalculateMoveDistance()

  Timers:CreateTimer(function()
    if self:IsRideDone() then
      FinishedEvent.broadcast({}) -- we're done
      self:CleanUp()
      return
    elseif IsInTrigger(self.Cart.handle, self:GetCurrentWaypointTrigger()) then
      self.Waypoints.currentIndex = self.Waypoints.currentIndex + 1
      return 0
    else
      self:MoveCart(self:GetCurrentWaypointTrigger():GetAbsOrigin())
    end
    return 2
  end)
end

function PhaseThree:MakeWaypointTriggerList(TriggerNames)
  local TriggerList = {}
  for i,waypointName in ipairs(TriggerNames) do
    TriggerList[i] = Entities:FindByName(nil, waypointName)
  end
  return TriggerList
end

function PhaseThree:SpawnCart()
  local handle = CreateUnitByName("npc_dota_santa_sled")
  return {
    Handle = handle,
    Projectile = ProjectileManager:CreateLinearProjectile({
      Ability = handle:FindAbilityByName("santa_sled_capturepoint"),
      EffectName = nil, -- no effect
      vSpawnOrigin = handle:GetAbsOrigin(),
      fDistance = 100000000000, -- to infinty and beyond
      fStartRadius = 64, --not sure what this means
      fEndRadius = 64, -- neither
      Source = handle,
      bHasFrontalCone = false,
      bReplaceExisting = false, -- how does it know what the exsiting one is? is it bound to the ability?
      iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
      iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
      iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
      fExpireTime = GameRules:GetGameTime() + 3600, -- expires after an hour
      bDeleteOnHit = false,
      vVelocity = 0, -- move only when told
      bProvidesVision = false,
      --iVisionRadius = 1000, -- obsolete
      --iVisionTeamNumber = handle:GetTeamNumber() -- obsolete
    }),
  }
end

function PhaseThree:CalculateMoveDistance()
  local distanceToMove = 0
  local distance = 0
  local lastWaypointPosition = nil
  local currentWaypointPosition = nil

  for k,Waypoint in pairs(self.Waypoints.Triggers) do
    if not lastWaypointPosition then
      lastWaypointPosition = Waypoint:GetAbsOrigin()
    else
      currentWaypointPosition = Waypoint:GetAbsOrigin()
      distance = (lastWaypointPosition + currentWaypointPosition):Length2D()
      distanceToMove = distanceToMove + distance
      lastWaypointPosition = currentWaypointPosition
    end
  end

  return distanceToMove
end

-- Return false when sled ride is done
function PhaseThree:IsRideDone()
  return self:GetCurrentWaypointTrigger() ~= nil
end

function PhaseThree:GetCurrentWaypointTrigger()
  self.Waypoints.Triggers[self.Waypoints.currentIndex]
return

function PhaseThree:MoveCart(targetPosition)
  --[[ExecuteOrderFromTable({
    UnitIndex = self.Cart.handle:entindex(),
    OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
    Position = targetPosition, --Optional.  Only used when targeting the ground
  })]]
  local direction = ProjectileManager:GetLinearProjectileLocation(self.Cart.Projectile) + targetPosition
  local speed = 500 -- static for now; aura should handle unit counting
  --speed = (number of friendlies - number of enemies) * unitcountmultiplier
  ProjectileManager:UpdateLinearProjectileDirection(self.Cart.Projectile, direction, speed)
end

function PhaseThree:CleanUp()
  self.Cart.Handle:ForceKill(false)
  ProjectileManager:DestroyLinearProjectile(self.Cart.Projectile)
end

function PhaseThree:ThrowPresent(targetPosition)
end

function PhaseThree:MakeProgressBar(text, maxValue, startValue)
end

function PhaseThree:UpdateProgressbar(value, isRelative)
end
