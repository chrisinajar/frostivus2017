LinkLuaModifier("modifier_not_of_this_world", "abilities/not_of_this_world.lua", LUA_MODIFIER_MOTION_NONE)

not_of_this_world = class(AbilityBaseClass)

function not_of_this_world:GetIntrinsicModifierName()
  return "modifier_not_of_this_world"
end

modifier_not_of_this_world = class(ModifierBaseClass)

function modifier_not_of_this_world:CheckState()
  return {
    [MODIFIER_STATE_INVISIBLE] = true,
    [MODIFIER_STATE_INVULNERABLE] = true,
    [MODIFIER_STATE_UNSELECTABLE] = true,
    [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
    [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    [MODIFIER_STATE_TRUESIGHT_IMMUNE] = true
  }
end

function modifier_not_of_this_world:OnCreated()
  -- BUG: AddNoDraw() doesn't exist
  --self:GetCaster():AddNoDraw()
end

function modifier_not_of_this_world:IsHidden()
  return false
end

function modifier_not_of_this_world:IsPurgeable()
  return false
end

function modifier_not_of_this_world:IsPurgeException()
  return false
end
