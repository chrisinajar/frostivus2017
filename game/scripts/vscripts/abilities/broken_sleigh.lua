LinkLuaModifier("modifier_broken_sleigh", "abilities/broken_sleigh.lua", LUA_MODIFIER_MOTION_NONE)

broken_sleigh = class(AbilityBaseClass)

function broken_sleigh:GetIntrinsicModifierName()
  return "modifier_broken_sleigh"
end

function broken_sleigh:OnUpgrade() 
    local hCaster = self:GetCaster()
    StartAnimation(hCaster,{duration=1200, activity=ACT_DOTA_DISABLED, rate=1.0})
end

modifier_broken_sleigh = class(ModifierBaseClass)

function modifier_broken_sleigh:CheckState()
  return {
    [MODIFIER_STATE_INVISIBLE] = true,
    [MODIFIER_STATE_INVULNERABLE] = true,
    [MODIFIER_STATE_UNSELECTABLE] = true,
    [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
    [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    [MODIFIER_STATE_TRUESIGHT_IMMUNE] = true,
    [MODIFIER_STATE_MAGIC_IMMUNE] = true
  }
end

function modifier_broken_sleigh:OnCreated()
  -- BUG: AddNoDraw() doesn't exist
  --self:GetCaster():AddNoDraw()
end

function modifier_broken_sleigh:IsHidden()
  return false
end

function modifier_broken_sleigh:IsPurgeable()
  return false
end

function modifier_broken_sleigh:IsPurgeException()
  return false
end
