LinkLuaModifier("modifier_santa_sled_capturepoint", "abilities/santa_sled_capturepoint.lua", LUA_MODIFIER_MOTION_NONE) --- PERTH VIPPITY PARTIENCE
LinkLuaModifier("modifier_santa_sled_capturepoint_aura", "abilities/santa_sled_capturepoint.lua", LUA_MODIFIER_MOTION_NONE) --- PERTH VIPPITY PARTIENCE

santa_sled_capturepoint = class(AbilityBaseClass) -- Modifier

function santa_sled_capturepoint:GetIntrinsicModifierName()
  return "modifier_santa_sled_capturepoint"
end


modifier_santa_sled_capturepoint = class(ModifierBaseClass)

function modifier_santa_sled_capturepoint:IsHidden()
  return false
end

function modifier_santa_sled_capturepoint:GetEffectName()
  return "particle/indicators/big_green_circle.vpcf"
end

function modifier_santa_sled_capturepoint:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_santa_sled_capturepoint:OnCreated(keys)
  local caster = self:GetCaster()
  caster.Speed = caster.BaseSpeed
  self:SetStackCount(0)

  if IsServer() then
    self:StartIntervalThink(1)
  end
end

function modifier_santa_sled_capturepoint:OnIntervalThink()
  local caster = self:GetCaster()
  local speedPerUnit = self:GetAbility():GetSpecialValueFor("movement_buff_per_unit")
  local units = FindUnitsInRadius(
    caster:GetTeamNumber(),
    caster:GetAbsOrigin(),
    nil,
    self:GetAuraRadius(),
    self:GetAuraSearchTeam(),
    self:GetAuraSearchType(),
    self:GetAuraSearchFlags(),
    FIND_ANY_ORDER,
    false)

  caster.StackCount = #units
  caster.Speed = caster.BaseSpeed + caster.StackCount * speedPerUnit
  self:SetStackCount(caster.StackCount)
end

function modifier_santa_sled_capturepoint:IsAura()
  return true
end

function modifier_santa_sled_capturepoint:GetModifierAura()
  return "modifier_santa_sled_capturepoint_aura"
end

function modifier_santa_sled_capturepoint:GetAuraRadius()
  return self:GetAbility():GetSpecialValueFor("capture_range")
end

function modifier_santa_sled_capturepoint:GetAuraSearchTeam()
  return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_santa_sled_capturepoint:GetAuraSearchType()
  return DOTA_UNIT_TARGET_HERO
end

function modifier_santa_sled_capturepoint:GetAuraSearchFlags()
  return DOTA_UNIT_TARGET_FLAG_NONE
end

modifier_santa_sled_capturepoint_aura = class(ModifierBaseClass)

function modifier_santa_sled_capturepoint_aura:OnCreated(keys)
  print(self:GetParent():GetName() .. " is capturing")
end

function modifier_santa_sled_capturepoint_aura:OnRefresh(keys)
  self:SetStackCount(self:GetCaster().StackCount)
end
