LinkLuaModifier("santa_sled_santa_armour_modifier", "abilities/santa_sled_santa_armour.lua", LUA_MODIFIER_MOTION_NONE) --- PERTH VIPPITY PARTIENCE

santa_sled_santa_armour = class(AbilityBaseClass)

function santa_sled_santa_armour:GetIntrinsicModifierName()
  return "santa_sled_santa_armour_modifier"
end

santa_sled_santa_armour_modifier = class(ModifierBaseClass)

function santa_sled_santa_armour_modifier:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
    MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
    MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE
  }
end

function santa_sled_santa_armour_modifier:IsHidden()
  return true
end

function santa_sled_santa_armour_modifier:IsPurgable()
  return false
end

function santa_sled_santa_armour_modifier:IsPurgeException()
  return false
end

function santa_sled_santa_armour_modifier:GetAbsoluteNoDamageMagical(keys)
  return 1
end

function santa_sled_santa_armour_modifier:GetAbsoluteNoDamagePhysical(keys)
  return 1
end

function santa_sled_santa_armour_modifier:GetAbsoluteNoDamagePure(keys)
  return 1
end
