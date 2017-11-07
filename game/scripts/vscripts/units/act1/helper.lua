
local Helper = class({})

function Spawn (entityKeyValues) --luacheck: ignore Spawn
  local helper = Helper()
  helper:Init(thisEntity)
end

function Helper:Init(entity)
  -- thisEntity
  local santa = Entities:FindAllByName("trigger_act_1_santa")
  if #santa < 1 then
    error("Failed to find act one helper target to repair")
  end

  self.santa = santa[1]:GetAbsOrigin()
  self.entity = entity
  self.repair = self.entity:FindAbilityByName("act1_helper_repair")


  Timers:CreateTimer(1, function()
    return self:Think()
  end)
end

function Helper:Think()
  if self.entity:IsNull() or not self.entity:IsAlive() then
    return
  end
  if self.entity:IsIdle() and not self.entity:IsChanneling() then
    self:RepairSleigh()
    return 2
  end

  return 1
end

function Helper:RepairSleigh()
  if not self.hasWalked or (self.entity:GetAbsOrigin() - self.santa):Length() > 500 then
    self.hasWalked = true
    local direction = RandomVector(1):Normalized()

    self.repairSpot = self.santa + (direction * 300)

    ExecuteOrderFromTable({
      UnitIndex = self.entity:entindex(),
      OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
      Position = self.repairSpot + (direction * 20), --Optional.  Only used when targeting the ground
      Queue = 0 --Optional.  Used for queueing up abilities
    })
    return
  end
  ExecuteOrderFromTable({
    UnitIndex = self.entity:entindex(),
    AbilityIndex = self.repair:entindex(),
    OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
    Position = self.repairSpot,
    Queue = 0 --Optional.  Used for queueing up abilities
  })
  self.hasWalked = false

end

