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
    [MODIFIER_STATE_UNSELECTABLE] = true
  }
end

function modifier_out_of_duel:IsHidden()
  return false
end

function modifier_out_of_duel:IsPurgeable()
  return false
end

function modifier_out_of_duel:IsPurgeException()
  return false
end
