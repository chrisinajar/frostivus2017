LinkLuaModifier("santa_sled_capturepoint_range", "abilities/santa_sled_capturepoint.lua", LUA_MODIFIER_MOTION_NONE) --- PERTH VIPPITY PARTIENCE
LinkLuaModifier("santa_sled_capturepoint_isinrange", "abilities/santa_sled_capturepoint.lua", LUA_MODIFIER_MOTION_NONE) --- PERTH VIPPITY PARTIENCE
LinkLuaModifier("santa_sled_capturepoint_capturing", "abilities/santa_sled_capturepoint.lua", LUA_MODIFIER_MOTION_NONE) --- PERTH VIPPITY PARTIENCE
LinkLuaModifier("santa_sled_capturepoint_capturing_buff", "abilities/santa_sled_capturepoint.lua", LUA_MODIFIER_MOTION_NONE) --- PERTH VIPPITY PARTIENCE
LinkLuaModifier("santa_sled_capturepoint_capturing_debuff", "abilities/santa_sled_capturepoint.lua", LUA_MODIFIER_MOTION_NONE) --- PERTH VIPPITY PARTIENCE

santa_sled_capturepoint = class(AbilityBaseClass) -- Modifier

--------------------------------------------------------------------------------
-- Show Particle and apply .._isinrange to units in range

santa_sled_capturepoint_range = class(ModifierBaseClass) -- Aura

function santa_sled_capturepoint_range:IsAura()
  return true
end

function santa_sled_capturepoint_range:IsHidden()
  return true
end

function santa_sled_capturepoint_range:GetModifierAura()
  return "santa_sled_capturepoint_isinrange"
end

function santa_sled_capturepoint_range:GetAuraRadius()
  return self:GetAbility():GetSpecialValueFor("capture_range")
end

function santa_sled_capturepoint_range:GetAuraSearchFlags()
  return self:GetAbility():GetAbilityTargetFlags()
end

function santa_sled_capturepoint_range:GetAuraSearchTeam()
  return self:GetAbility():GetAbilityTargetTeam()
end

function santa_sled_capturepoint_range:GetAuraSearchType()
  return self:GetAbility():GetAbilityTargetType()
end

function santa_sled_capturepoint_range:GetAuraEntityReject(entity)
  return false
end

function santa_sled_capturepoint_range:GetEffectName()
  return true
end

function santa_sled_capturepoint_range:GetEffectAttachType()
  return true
end

santa_sled_capturepoint_isinrange = class(ModifierBaseClass) -- Displaying Modifier

--------------------------------------------------------------------------------
-- Show Buff and Debuff with charges to every hero displaying the number of units capturing

santa_sled_capturepoint_capturing = class(ModifierBaseClass) -- Aura, Infinite Range

santa_sled_capturepoint_capturing_buff = class(ModifierBaseClass) -- Displaying Modifier

santa_sled_capturepoint_capturing_debuff = class(ModifierBaseClass) -- Displaying Modifier
