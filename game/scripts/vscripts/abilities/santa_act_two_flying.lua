LinkLuaModifier("modifier_santa_act_two_flying", "abilities/santa_act_two_flying.lua", LUA_MODIFIER_MOTION_VERTICAL)

santa_act_two_flying = class(AbilityBaseClass)

function santa_act_two_flying:GetIntrinsicModifierName()
  return "modifier_santa_act_two_flying"
end

modifier_santa_act_two_flying = class(ModifierBaseClass)

function modifier_santa_act_two_flying:CheckState()
  return {
    [MODIFIER_STATE_INVISIBLE] = true,
    [MODIFIER_STATE_INVULNERABLE] = true,
    --[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
    [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    [MODIFIER_STATE_TRUESIGHT_IMMUNE] = true,
    [MODIFIER_STATE_MAGIC_IMMUNE] = true
  }
end


function modifier_santa_act_two_flying:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_VISUAL_Z_DELTA,
    MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
    MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
    MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
    MODIFIER_PROPERTY_MOVESPEED_LIMIT,
    MODIFIER_PROPERTY_MOVESPEED_MAX
  }
  return funcs
end

function modifier_santa_act_two_flying:GetModifierMoveSpeed_Absolute()
  return SLED_MOVE_SPEED or 0
end
function modifier_santa_act_two_flying:GetModifierMoveSpeed_AbsoluteMin()
  return SLED_MOVE_SPEED or 0
end
function modifier_santa_act_two_flying:GetModifierMoveSpeedOverride()
  return SLED_MOVE_SPEED or 0
end
function modifier_santa_act_two_flying:GetModifierMoveSpeed_Limit()
  return SLED_MOVE_SPEED or 0
end
function modifier_santa_act_two_flying:GetModifierMoveSpeed_Max()
  return SLED_MOVE_SPEED or 0
end

function modifier_santa_act_two_flying:GetVisualZDelta( params )
  return 400
end

function modifier_santa_act_two_flying:OnCreated()
    if IsServer() then
        self.nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/earthshaker/earthshaker_totem_ti6/earthshaker_totem_ti6_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())--PATTACH_OVERHEAD_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl( self.nFXIndex, 14, Vector(2, 2, 2 ) )
        ParticleManager:SetParticleControl( self.nFXIndex, 15, Vector(100, 100, 255 ) )
        self:AddParticle( self.nFXIndex, false, false, -1, false, false )
        self:StartIntervalThink( 0.5 )
    end
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
