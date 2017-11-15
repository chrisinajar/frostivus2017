modifier_forest_fog = class(ModifierBaseClass)

function modifier_forest_fog:OnCreated()
  print("Forest fog added")
end

function modifier_forest_fog:OnDestroy()
  print("Forest fog removed")
end

function modifier_forest_fog:IsPurgable()
  return false
end

function modifier_forest_fog:IsPurgeException()
  return false
end

function modifier_forest_fog:RemoveOnDeath()
  return false
end

function modifier_forest_fog:IsDebuff()
  return true
end

function modifier_forest_fog:GetTexture()
  return "night_stalker_darkness"
end

function modifier_forest_fog:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_FIXED_DAY_VISION,
    MODIFIER_PROPERTY_FIXED_NIGHT_VISION
  }
end

function modifier_forest_fog:GetFixedDayVision(keys)
  return 600
end

function modifier_forest_fog:GetFixedNightVision(keys)
  return 600
end
