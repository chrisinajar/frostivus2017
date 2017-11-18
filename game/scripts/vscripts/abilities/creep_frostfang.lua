creep_frostfang = class( AbilityBaseClass )

LinkLuaModifier( "modifier_creep_frostfang", "abilities/creep_frostfang.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_creep_frostfang_debuff", "abilities/creep_frostfang.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function creep_frostfang:GetIntrinsicModifierName()
	return "modifier_creep_frostfang"
end

--------------------------------------------------------------------------------

modifier_creep_frostfang = class( ModifierBaseClass )

--------------------------------------------------------------------------------

function modifier_creep_frostfang:IsHidden()
	return true
end

function modifier_creep_frostfang:IsDebuff()
	return false
end

function modifier_creep_frostfang:IsPurgable()
	return false
end

function modifier_creep_frostfang:GetAttributes()
	return bit.bor( MODIFIER_ATTRIBUTE_PERMANENT, MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE )
end

--------------------------------------------------------------------------------

if IsServer() then
	function modifier_creep_frostfang:DeclareFunctions()
		local funcs = {
			MODIFIER_EVENT_ON_ATTACK_LANDED,
		}

		return funcs
	end

--------------------------------------------------------------------------------

	function modifier_creep_frostfang:OnAttackLanded( event )
		local parent = self:GetParent()

		if event.attacker == parent then
			local spell = self:GetAbility()

			event.target:AddNewModifier( parent, spell, "modifier_creep_frostfang_debuff", {
				duration = spell:GetSpecialValueFor( "duration" ),
			} )

			-- being more specific with allowed targets may be necesseray later
			-- but eh
		end
	end
end

--------------------------------------------------------------------------------

modifier_creep_frostfang_debuff = class( ModifierBaseClass )

--------------------------------------------------------------------------------

function modifier_creep_frostfang_debuff:IsHidden()
	return false
end

function modifier_creep_frostfang_debuff:IsDebuff()
	return true
end

function modifier_creep_frostfang_debuff:IsPurgable()
	return true
end

--------------------------------------------------------------------------------

function modifier_creep_frostfang_debuff:GetEffectName()
	return "particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_debuff.vpcf"
end

function modifier_creep_frostfang_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_iceblast.vpcf"
end

function modifier_creep_frostfang_debuff:StatusEffectPriority()
	return 5
end

--------------------------------------------------------------------------------

function modifier_creep_frostfang_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DISABLE_HEALING,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_creep_frostfang_debuff:GetDisableHealing( event )
	return 1
end

function modifier_creep_frostfang_debuff:RemoveOnDeath()
  return true
end
