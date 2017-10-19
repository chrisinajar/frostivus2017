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
  -- PHASE_3_CAPTURE_RANGE

  Timers:CreateTimer(function()
    if not self:CheckSledPosition() then
      FinishedEvent.broadcast({}) -- we're done
      self:CleanUp()
      return
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
    handle,
    --buff,
    --debuff
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
function PhaseThree:CheckSledPosition()
  if IsInTrigger(self.Cart.handle, self:GetCurrentWaypointTrigger()) then
    self.Waypoints.currentIndex = self.Waypoints.currentIndex + 1
    if not self:GetCurrentWaypointTrigger() then return false end
    self:MoveCart(self:GetCurrentWaypointTrigger():GetAbsOrigin())
  end
  return true
end

function PhaseThree:GetCurrentWaypointTrigger()
  self.Waypoints.Triggers[self.Waypoints.currentIndex]
return

function PhaseThree:MoveCart(targetPosition)
  ExecuteOrderFromTable({
    UnitIndex = self.Cart.handle:entindex(),
    OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
    Position = targetPosition, --Optional.  Only used when targeting the ground
  })
end

function PhaseThree:CleanUp()
  self.Cart.handle:Kill()
end

function PhaseThree:ThrowPresent(targetPosition)
end

function PhaseThree:MakeProgressBar(text, maxValue, startValue)
end

function PhaseThree:UpdateProgressbar(value, isRelative)
end
