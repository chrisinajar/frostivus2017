LinkLuaModifier("santa_sled_santa_armour_modifier", "abilities/santa_sled_santa_armour.lua", LUA_MODIFIER_MOTION_NONE) --- PERTH VIPPITY PARTIENCE

santa_sled_santa_armour = class(AbilityBaseClass)

function santa_sled_santa_armour:GetIntrinsicModifierName()
  return "santa_sled_santa_armour_modifier"
end

santa_sled_santa_armour_modifier = class(ModifierBaseClass)

function santa_sled_santa_armour_modifier:DeclareFunctions()
  return { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE }
end

function santa_sled_santa_armour_modifier:GetModifierIncomingDamage_Percentage(keys)
  return -100
end
