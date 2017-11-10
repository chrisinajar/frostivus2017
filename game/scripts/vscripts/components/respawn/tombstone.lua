TombstoneRespawn = TombstoneRespawn or class({})

function TombstoneRespawn:Init()
  GameEvents:OnEntityKilled(function (keys)
    local killedUnit = EntIndexToHScript(keys.entindex_killed)
    if not killedUnit or not IsValidEntity(killedUnit) then
      return
    end

    if killedUnit:IsRealHero() and not killedUnit:IsTempestDouble() and not killedUnit:IsReincarnating() then
      local tombstoneItem = CreateItem("item_tombstone", killedUnit, killedUnit)
      tombstoneItem:SetPurchaseTime(0)
      tombstoneItem:SetPurchaser(killedUnit)
      local tombstone = SpawnEntityFromTableSynchronous("dota_item_tombstone_drop", {})
      tombstone:SetContainedItem(tombstoneItem)
      tombstone:SetAngles(0, RandomFloat(0, 360), 0)
      FindClearSpaceForUnit(tombstone, killedUnit:GetAbsOrigin(), true)
    end
  end)
end
