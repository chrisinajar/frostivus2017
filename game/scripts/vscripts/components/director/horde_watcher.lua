Debug.EnabledModules['director:horde_watcher'] = true

HordeWatcher = HordeWatcher or class({})

function HordeWatcher:Init(unit, target)
  self.unit = unit
  self.target = target
  self.canBeGC = false

  -- force creeps to be alive for at least 5 seconds before considering them for garbage collection
  Timers:CreateTimer(5, function()
    self.canBeGC = true
  end)

  unit:OnDeath(function()
    self:OnDeath()
  end)

  Timers:CreateTimer(function ()
    return self:Think()
  end)

  for abilityIndex = 0, self.unit:GetAbilityCount() - 1 do
    local ability = self.unit:GetAbilityByIndex(abilityIndex)
    if ability then
      ability:SetLevel(StorylineManager.currentState)
    end
  end
end

function HordeWatcher:Think()
  if not self.unit or not self.unit:IsAlive() then
    -- we died, disappear
    return
  end
  if self.unit:IsIdle() then
    local sirenSong = self.unit:FindAbilityByName('creep_siren_song')
    if sirenSong and sirenSong:IsCooldownReady() then
      -- force siren song to always use instantly
      ExecuteOrderFromTable({
        UnitIndex = self.unit:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        -- Position = self.unit:GetAbsOrigin(), --Optional.  Only used when targeting the ground
        AbilityIndex = sirenSong:entindex(),
        Queue = 0 --Optional.  Used for queueing up abilities
      })
    else
      -- keep A walking towards target
      ExecuteOrderFromTable({
        UnitIndex = self.unit:entindex(),
        OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
        Position = self.target:GetAbsOrigin(), --Optional.  Only used when targeting the ground
        Queue = 0 --Optional.  Used for queueing up abilities
      })
    end
  end

  if self.canBeGC and not self.unit:HasModifier('modifier_is_near_player') then
    -- DebugPrint('This unit is lost and pointless...')
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
  local unit = self.unit
  Timers:CreateTimer(5, function()
    if not unit:IsNull() then
      unit:Destroy()
    end
  end)
  self.unit = nil
end
