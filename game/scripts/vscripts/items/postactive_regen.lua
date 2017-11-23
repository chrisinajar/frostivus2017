LinkLuaModifier("modifier_item_postactive_regen", "items/postactive_regen.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_bonus", "modifiers/modifier_generic_bonus.lua", LUA_MODIFIER_MOTION_NONE)

item_regen_crystal = class(ItemBaseClass)

function item_regen_crystal:GetIntrinsicModifierName()
  return "modifier_generic_bonus"
end

function item_regen_crystal:OnSpellStart()
  local caster = self:GetCaster()
  caster:AddNewModifier(caster, self, 'modifier_item_postactive_regen', {
    duration = self:GetSpecialValueFor("duration")
  })
end

item_regen_crystal_2 = class(item_regen_crystal)
item_regen_crystal_3 = class(item_regen_crystal)

------------------------------------------------------------------------------------------

modifier_item_postactive_regen = class(ModifierBaseClass)

function modifier_item_postactive_regen:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
  }
end

function modifier_item_postactive_regen:GetModifierConstantHealthRegen()
  return self:GetAbility():GetSpecialValueFor("active_health_regen")
end
