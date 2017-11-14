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
  end
end
