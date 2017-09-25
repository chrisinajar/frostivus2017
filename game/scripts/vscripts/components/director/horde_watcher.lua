
HordeWatcher = HordeWatcher or class({})

function HordeWatcher:Init(unit, target)
  self.unit = unit
  self.target = target

  unit:OnDeath(function()
    self:OnDeath()
  end)

  Timers:CreateTimer(function ()
    return self:Think()
  end)
end

function HordeWatcher:Think()
  if not self.unit or not self.unit:IsAlive() then
    -- we died, disappear
    return
  end
  if self.unit:IsIdle() then
    -- keep A walking towards target
    ExecuteOrderFromTable({
      UnitIndex = self.unit:entindex(),
      OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
      Position = self.target:GetAbsOrigin(), --Optional.  Only used when targeting the ground
      Queue = 0 --Optional.  Used for queueing up abilities
    })
  end

  if self.unit:HasModifier('modifier_is_near_player') then
    -- DebugPrint('This unit is still near a player!')
  else
    DebugPrint('This unit is lost and pointless...')
    if not self.target:CanEntityBeSeenByMyTeam(self.unit) then
      DebugPrint('destroying invisible pointless unit')
      self.unit:Destroy()
      return
    end
  end
  return 1
end

function HordeWatcher:OnDeath()
  -- do stuff on death?
  DebugPrint('')
  local unit = self.unit
  Timers:CreateTimer(5, function()
    if not unit:IsNull() then
      unit:Destroy()
    end
  end)
  self.unit = nil
end
