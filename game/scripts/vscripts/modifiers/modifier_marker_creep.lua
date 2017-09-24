LinkLuaModifier('modifier_marker_creep', 'modifiers/modifier_marker_creep', LUA_MODIFIER_MOTION_NONE)

modifier_marker_creep = class(ModifierBaseClass)

function modifier_marker_creep:DeclareFunctions ()
  return {
    MODIFIER_PROPERTY_MOVESPEED_MAX
  }
end

function modifier_marker_creep:CheckState()
  return {
    [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
    [MODIFIER_STATE_UNSELECTABLE] = true,
    [MODIFIER_STATE_MAGIC_IMMUNE] = true,
    [MODIFIER_STATE_INVULNERABLE] = true,
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true
  }
end

function modifier_marker_creep:GetModifierMoveSpeed_Max()
  return 2000
end
