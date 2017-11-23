local Tank = class({})

function Spawn (entityKeyValues) --luacheck: ignore Spawn
  local Tank = Tank()
  Tank:Init(thisEntity)
end

function Tank:Init(entity)
  -- thisEntity
  self.entity = entity
  self.lastAction = 0

  self.slam =  self.entity:FindAbilityByName("tank_ground_slam")
  self.quake = self.entity:FindAbilityByName("tank_earthquake")
  self.opposingTeam = self.entity:GetOpposingTeamNumber()
  self.phase = 1
  Timers:CreateTimer(1, function()
    AddFOWViewer(self.opposingTeam,self.entity:GetAbsOrigin(),400.0,1.5,true)
    return self:Think()
  end)
end

function Tank:Think()
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

function Tank:Slam()
  local target = self:NearestEnemyHeroInRange( 1800 )
  if target then
    ExecuteOrderFromTable({
    UnitIndex = self.entity:entindex(),
    OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
    Position = target:GetAbsOrigin(),
    AbilityIndex = self.slam:entindex()
    })
  end
  self.lastAction = GameRules:GetGameTime()
  return self.slam:GetCastPoint() + 0.1
end

function Tank:Quake()
  local target = self:NearestEnemyHeroInRange( 1800 )
  if target then
    ExecuteOrderFromTable({
      UnitIndex = self.entity:entindex(),
      OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
      Position = target:GetAbsOrigin(),
      AbilityIndex = self.quake:entindex()
    })
  end
  self.lastAction = GameRules:GetGameTime()
  return self.quake:GetCastPoint() + 0.1
end

function Tank:NearestEnemyHeroInRange( range )
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

