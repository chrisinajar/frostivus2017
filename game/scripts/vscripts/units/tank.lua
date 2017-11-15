local Boss = class({})

function Spawn (entityKeyValues) --luacheck: ignore Spawn
  local Boss = Boss()
  Boss:Init(thisEntity)
end

function Boss:Init(entity)
  -- thisEntity
  self.entity = entity
  
  self.slam =  self.entity:FindAbilityByName("evil_wisp_moon_rain")
  self.quake = self.entity:FindAbilityByName("evil_wisp_moon_beam")
  
  self.phase = 1
  

  Timers:CreateTimer(1, function()
    return self:Think()
  end)
end

function Boss:Think()
  if self.entity:IsNull() or not self.entity:IsAlive() then
    return
  end
  if self.slam:IsFullyCastable() and self.lastAction + 5 < GameRules:GetGameTime() then
	self:Slam()
  end
  if self.quake:IsFullyCastable()  and self.lastAction + 5 < GameRules:GetGameTime() then
	self:Quake()
  end
  return 1
end

function Boss:Slam()
  local target = self:NearestEnemyHeroInRange( 9999 )
  if target then
    ExecuteOrderFromTable({
    UnitIndex = self.entity:entindex(),
    OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
    Position = target:GetPosition(),
    AbilityIndex = self.slam:entindex()
    })
  end
  self.lastAction = GameRules:GetGameTime()
  return self.slam:GetCastPoint() + 0.1
end

function Boss:Quake()
  local target = self:NearestEnemyHeroInRange( 9999 )
  if target then
    ExecuteOrderFromTable({
      UnitIndex = self.entity:entindex(),
      OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
      Position = target:GetPosition(),
      AbilityIndex = self.quake:entindex()
    })
  end
  self.lastAction = GameRules:GetGameTime()
  return self.quake:GetCastPoint() + 0.1
end

function Boss:NearestEnemyHeroInRange( range )
  local flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS
  local enemies = FindUnitsInRadius( self.entity:GetTeamNumber(), self.entity:GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flags, 0, false )
  
  local minRange = range
  local target = nil
  
  for _,enemy in pairs(enemies) do
    local distanceToEnemy = (self.entity:GetAbsOrigin() - enemy:GetAbsOrigin()):Length2D()
    if enemy:IsAlive() and distanceToEnemy < minRange then
      minRange = distanceToEnemy
      target = enemy
    end
  end
  return target
end

