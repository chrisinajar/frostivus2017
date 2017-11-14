local Boss = class({})

function Spawn (entityKeyValues) --luacheck: ignore Spawn
  local Boss = Boss()
  Boss:Init(thisEntity)
end

PhaseEnums = {
	[1] = 100
	[2] = 75
	[3] = 50
	[4] = 25
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
  
  self.phase = 1
  

  Timers:CreateTimer(1, function()
    return self:Think()
  end)
end

function Boss:Think()
  if self.entity:IsNull() or not self.entity:IsAlive() then
    return
  end
  if self.entity:GetHealthPercent() < PhaseEnums[self.phase + 1] and self.phase < 3 then
	Boss:GoToNexPhase()
  end
  if self.moonbeam:IsFullyCastable() then
	Boss:MoonBeam()
  end
  if self.moonrain:IsFullyCastable() then
	Boss:MoonRain()
  end
  if self.omni:IsFullyCastable() then
	Boss:OmniParty()
  end
  if self.egg:IsFullyCastable() and self.phase >= 3 and self.entity:GetHealthPercent() < PhaseEnums[self.phase] then
	Boss:Egg()
  end
  return 1
end

function Boss:GoToNexPhase()
	self.phase = self.phase + 1
	for _, ability in ipairs(self.abilityList) do
		ability:SetLevel(self.phase)
	end
end

function Boss:MoonBeam()
  ExecuteOrderFromTable({
	UnitIndex = thisEntity:entindex(),
	OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
	AbilityIndex = thisEntity.moonbeam:entindex()
  })
  return self.moonbeam:GetCastPoint() + 0.1
end

function Boss:MoonRain()
	local target = self:NearestEnemyHeroInRange( 9999 )
	if target then
		ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
			TargetIndex = target:entindex(),
			AbilityIndex = thisEntity.thread:entindex()
		})
	end
  return self.moonrain:GetCastPoint() + 0.1
end

function Boss:OmniParty()
  return self.omni:GetCastPoint() + 0.1
end

function Boss:Egg()
   ExecuteOrderFromTable({
	UnitIndex = thisEntity:entindex(),
	OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
	AbilityIndex = thisEntity.egg:entindex()
  })
  return self.egg:GetCastPoint() + 0.1
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

