
local Helper = class({})

function Spawn (entityKeyValues) --luacheck: ignore Spawn
  local helper = Helper()
  helper:Init(thisEntity)
end

function Helper:Init(entity)
  -- thisEntity
  local santa = Entities:FindAllByName("trigger_act_1_sleigh")
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
  if not self.entity:IsAlive() or self.entity:IsNull() then
    return
  end
  if self.entity:IsIdle() then
    self:RepairSleigh()
    return 2
  end

  return 1
end

function Helper:RepairSleigh()
  ExecuteOrderFromTable({
    UnitIndex = self.entity:entindex(),
    AbilityIndex = self.repair:entindex(),
    OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
    Position = self.santa, --Optional.  Only used when targeting the ground
    Queue = 0 --Optional.  Used for queueing up abilities
  })
end
