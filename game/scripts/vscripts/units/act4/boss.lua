local Boss = class({})

function Spawn (entityKeyValues) --luacheck: ignore Spawn
  local Boss = Boss()
  Boss:Init(thisEntity)
end

PhaseEnums = {
  [1] = 100,
  [2] = 75,
  [3] = 50,
  [4] = 25,
}

function Boss:Init(entity)
  -- thisEntity
  self.entity = entity
  self.abilityList = {}
  self.moonrain =  self.entity:FindAbilityByName("evil_wisp_moon_rain")
  table.insert(self.abilityList, self.moonrain)
  self.moonbeam = self.entity:FindAbilityByName("evil_wisp_moon_beam")
  table.insert(self.abilityList, self.moonbeam)
  self.omni = self.entity:FindAbilityByName("evil_wisp_omni_party")
  table.insert(self.abilityList, self.omni)
  self.egg = self.entity:FindAbilityByName("evil_wisp_egg")
  table.insert(self.abilityList, self.egg)
  self.stun = self.entity:FindAbilityByName("evil_wisp_psycho_blast")
  table.insert(self.abilityList, self.stun)
  self.reinforcements = self.entity:FindAbilityByName("evil_wisp_reinforcements")
  table.insert(self.abilityList, self.reinforcements)
  self.bond = self.entity:FindAbilityByName("evil_wisp_soul_bond")
  table.insert(self.abilityList, self.bond)
  self.totem = self.entity:FindAbilityByName("evil_wisp_totems")
  table.insert(self.abilityList, self.totem)
  self.kraken = self.entity:FindAbilityByName("evil_wisp_kraken")
  table.insert(self.abilityList, self.kraken)
  self.blink = self.entity:FindAbilityByName("evil_wisp_blink")
  table.insert(self.abilityList, self.blink)

  self.phase = 1


  Timers:CreateTimer(4, function()
    return self:Think()
  end)
end

function Boss:Think()
  if self.entity:IsNull() or not self.entity:IsAlive() then
    return
  end
  if self.entity:GetHealthPercent() < PhaseEnums[self.phase + 1] and self.phase < 3 then
    self.reinforcements:EndCooldown()
    self:GoToNextPhase()
    self:Reinforcements()
  end
  
  if not self.entity:IsInvulnerable() and RollPercentage(66) then
	if self.stun:IsFullyCastable() then
		local hasStunned = self:Stun()
		if hasStunned then return hasStunned end
	end
	if self.bond:IsFullyCastable() then
		local hasBonded = self:Bond()
		if hasBonded then return hasBonded end
	end
	if self.totem:IsFullyCastable() and RollPercentage(33) then
		return self:Totem()
	end
	if self.moonrain:IsFullyCastable() and RollPercentage(33) then
	  if self:MoonRain() then return self:MoonRain() end
    end
    if self.omni:IsFullyCastable() and RollPercentage(33) then
      return self:OmniParty()
    end
    if self.egg:IsFullyCastable() and self.phase >= 3 and self.entity:GetHealthPercent() < PhaseEnums[self.phase] then
      return self:Egg()
    end
  end
  if self.moonbeam:IsFullyCastable() then
    self:MoonBeam()
  end
  return self:Wander()
end

function Boss:GoToNextPhase()
  self.phase = self.phase + 1
  for _, ability in ipairs(self.abilityList) do
    ability:SetLevel(self.phase)
  end
end

function Boss:Wander()
  if self.blink:IsFullyCastable() and RollPercentage(50) then
	self.entity:Interrupt()
	self.entity:CastAbilityOnPosition(self.entity:GetAbsOrigin() + RandomVector( RandomInt( self.blink:GetSpecialValueFor("min_blink_range"), self.blink:GetSpecialValueFor("blink_range") ) ), self.blink, -1)
  else
	ExecuteOrderFromTable({
	  UnitIndex = self.entity:entindex(),
	  OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
	  Position = self.entity:GetAbsOrigin() + RandomVector(600),
    })
  end
  return 1
end

function Boss:MoonBeam()
  ExecuteOrderFromTable({
  UnitIndex = self.entity:entindex(),
  OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
  AbilityIndex = self.moonbeam:entindex()
  })
end

function Boss:MoonRain()
  local target = self:NearestEnemyHeroInRange( 9999 )
  if target then
    ExecuteOrderFromTable({
      UnitIndex = self.entity:entindex(),
      OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
      TargetIndex = target:entindex(),
      AbilityIndex = self.moonrain:entindex()
    })
  return self.moonrain:GetCastPoint() + 0.5
  end
end

function Boss:OmniParty()
  ExecuteOrderFromTable({
    UnitIndex = self.entity:entindex(),
    OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
    AbilityIndex = self.omni:entindex()
  })
  return self.omni:GetCastPoint() + 0.5
end

function Boss:Egg()
  ExecuteOrderFromTable({
    UnitIndex = self.entity:entindex(),
    OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
    AbilityIndex = self.egg:entindex()
  })
  return self.egg:GetCastPoint() + 0.5
end

function Boss:Bond()
  local target = self:NearestEnemyHeroInRange( self.stun:GetCastRange(self.entity:GetAbsOrigin(), self.entity) )
  if target then
	  ExecuteOrderFromTable({
		UnitIndex = self.entity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = target:entindex(),
		AbilityIndex = self.bond:entindex()
	  })
   return self.bond:GetCastPoint() + 0.5
   end
end

function Boss:Reinforcements()
  ExecuteOrderFromTable({
    UnitIndex = self.entity:entindex(),
    OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
    AbilityIndex = self.reinforcements:entindex()
  })
  return self.reinforcements:GetCastPoint() + 0.5
end

function Boss:Stun()
  local target = self:NearestEnemyHeroInRange( self.stun:GetCastRange() )
  print( target, self.stun:GetCastRange() )
  if target then
	  print("stunning")
	  ExecuteOrderFromTable({
		UnitIndex = self.entity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = target:entindex(),
		AbilityIndex = self.stun:entindex()
	  })
	  return self.stun:GetCastPoint() + 0.5
  end
end

function Boss:Totem()
  ExecuteOrderFromTable({
    UnitIndex = self.entity:entindex(),
    OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
    AbilityIndex = self.totem:entindex()
  })
  return self.totem:GetCastPoint() + 0.5
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
