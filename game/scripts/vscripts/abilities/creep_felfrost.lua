creep_felfrost = class( AbilityBaseClass )

LinkLuaModifier( "modifier_creep_felfrost", "abilities/creep_felfrost.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_felfrost", "modifiers/modifier_felfrost.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function creep_felfrost:GetIntrinsicModifierName()
	return "modifier_creep_felfrost"
end

--------------------------------------------------------------------------------

modifier_creep_felfrost = class( ModifierBaseClass )

--------------------------------------------------------------------------------

function modifier_creep_felfrost:IsHidden()
	return true
end

function modifier_creep_felfrost:IsDebuff()
	return false
end

function modifier_creep_felfrost:IsPurgable()
	return false
end

function modifier_creep_felfrost:GetAttributes()
	return bit.bor( MODIFIER_ATTRIBUTE_PERMANENT, MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE )
end

--------------------------------------------------------------------------------

if IsServer() then
	function modifier_creep_felfrost:DeclareFunctions()
		local funcs = {
			MODIFIER_EVENT_ON_ATTACK_LANDED,
		}

		return funcs
	end

--------------------------------------------------------------------------------

	function modifier_creep_felfrost:OnAttackLanded( event )
		local parent = self:GetParent()

		if event.attacker == parent then
			local spell = self:GetAbility()
			local target = event.target

			--if UnitFilter( target, DOTA_UNIT_TARGET_TEAM_ENEMY, bit.bor( DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_CREEP ), DOTA_UNIT_TARGET_FLAG_NONE, parent:GetTeamNumber() ) == UF_SUCCESS then
				local mod = target:AddNewModifier( parent, spell, "modifier_felfrost", {} )
        if not mod then
          return
        end
				mod:IncrementStackCount()
			--end
		end
	end
end
