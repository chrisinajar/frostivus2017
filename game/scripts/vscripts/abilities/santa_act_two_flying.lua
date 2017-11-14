LinkLuaModifier("modifier_santa_act_two_flying", "abilities/santa_act_two_flying.lua", LUA_MODIFIER_MOTION_VERTICAL)

santa_act_two_flying = class(AbilityBaseClass)

function santa_act_two_flying:GetIntrinsicModifierName()
  return "modifier_santa_act_two_flying"
end

modifier_santa_act_two_flying = class(ModifierBaseClass)

function modifier_santa_act_two_flying:CheckState()
  return {
    [MODIFIER_STATE_INVISIBLE] = true,
    --[MODIFIER_STATE_INVULNERABLE] = true,
    --[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
    --[MODIFIER_STATE_NO_HEALTH_BAR] = true,
    [MODIFIER_STATE_TRUESIGHT_IMMUNE] = true
  }
end


function modifier_santa_act_two_flying:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_VISUAL_Z_DELTA
  }
  return funcs
end

function modifier_santa_act_two_flying:GetVisualZDelta( params )
  return 400
end

function modifier_santa_act_two_flying:OnCreated()
  -- BUG: AddNoDraw() doesn't exist
  --self:GetCaster():AddNoDraw()
end

function modifier_santa_act_two_flying:IsHidden()
  return false
end

function modifier_santa_act_two_flying:IsPurgeable()
  return false
end

function modifier_santa_act_two_flying:IsPurgeException()
  return false
end
