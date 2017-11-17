local Sneak = class({})

function Spawn (entityKeyValues) --luacheck: ignore Spawn
  local Sneak = Sneak()
  Sneak:Init(thisEntity)
end

function Sneak:Init(entity)
  -- thisEntity
  self.entity = entity

  Timers:CreateTimer(1, function()
    return self:Think()
  end)
end

function Sneak:Think()
  if self.entity:IsNull() or not self.entity:IsAlive() then
    return
  end

  local target = self:FindWeakestHero()
  if not target then
    -- while idle the director will send us to the enemies
    return 1
  end
  -- once an enemy is in range, we take over and issue attack commands
  -- since the director doesn't do anything unless the unit is idle, this works

  ExecuteOrderFromTable({
    UnitIndex = self.entity:entindex(),
    OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
    TargetIndex = target:entindex(), --Optional.  Only used when targeting the ground
    Queue = 0 --Optional.  Used for queueing up abilities
  })
end

function Sneak:FindWeakestHero()
  local flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS
  local enemies = FindUnitsInRadius( self.entity:GetTeamNumber(), self.entity:GetAbsOrigin(), nil, 2000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flags, 0, false )

  local minHP = nil
  local target = nil

  for _,enemy in pairs(enemies) do
    local health = enemy:GetHealth()
    if enemy:IsAlive() and (not minHP or health < minHP) then
      minRange = health
      target = enemy
    end
  end
  return target
end
