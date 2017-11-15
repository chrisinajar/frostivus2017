Wearables = Wearables or class({})



function Wearables:Init()
  self.UnitKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")
  GameEvents:OnNPCSpawned(function (event)
    local spawnedUnit = EntIndexToHScript( event.entindex )
    if not spawnedUnit or not IsValidEntity(spawnedUnit) then
      return
    end

    if spawnedUnit:IsCreature() then
      Wearables:AddWearablesToCreature(spawnedUnit)
    end
  end)
end

function Wearables:AddWearablesToCreature(creature)
  if self.UnitKV and self.UnitKV[creature:GetUnitName()] and self.UnitKV[creature:GetUnitName()]["Creature"] and self.UnitKV[creature:GetUnitName()]["Creature"]["AttachWearables"] then
    local wearableList = self.UnitKV[creature:GetUnitName()]["Creature"]["AttachWearables"]
    for _,v in pairs(wearableList) do
      SpawnEntityFromTableSynchronous("prop_dynamic", {model=v}):FollowEntity(creature, true)
    end
	if creature:GetModelName() == "models/courier/greevil/greevil.vmdl" then
		local name = creature:GetUnitName()
		local powerLevel = tonumber(name:sub(string.len(name) ) )
		MAX_POWER_LEVEL = 10
		MIN_SATURATION = 85
		SATURATION_SCALING = (255 - MIN_SATURATION) / MAX_POWER_LEVEL
		if powerLevel > MAX_POWER_LEVEL then
			MIN_SATURATION = MIN_SATURATION - ((MIN_SATURATION / MAX_POWER_LEVEL) * (powerLevel - MAX_POWER_LEVEL))
		end
		local maxSaturation = MIN_SATURATION + SATURATION_SCALING * powerLevel
		local minSaturation = math.max(MIN_SATURATION, maxSaturation - SATURATION_SCALING)
		creature:SetRenderColor( RandomInt(MIN_SATURATION, maxSaturation), RandomInt(MIN_SATURATION, maxSaturation), RandomInt(MIN_SATURATION, maxSaturation) )
	end
  end
end
