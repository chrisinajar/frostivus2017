creep_snow_cloak = class( AbilityBaseClass )

LinkLuaModifier( "modifier_creep_snow_cloak", "abilities/creep_snow_cloak.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function creep_snow_cloak:GetIntrinsicModifierName()
	return "modifier_creep_snow_cloak"
end

--------------------------------------------------------------------------------

modifier_creep_snow_cloak = class( ModifierBaseClass )

--------------------------------------------------------------------------------

function modifier_creep_snow_cloak:IsHidden()
	return true
end

function modifier_creep_snow_cloak:IsDebuff()
	return false
end

function modifier_creep_snow_cloak:IsPurgable()
	return false
end

function modifier_creep_snow_cloak:GetAttributes()
	return bit.bor( MODIFIER_ATTRIBUTE_PERMANENT, MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE )
end

--------------------------------------------------------------------------------

-- this is a bit nonsensical bit-by-bit so as a whole
-- basically, invisibility is controlled by MODIFIER_STATE_INVISIBLE
-- so what we're doing here is making it so that the modifier has a
-- "invisible" variable that controls that state

-- when the invisibility is broken, StartIntervalThink is called so OnIntervalThink
-- can restore it
function modifier_creep_snow_cloak:OnCreated( event )
	local spell = self:GetAbility()

	self.invisible = false

	self:StartIntervalThink( spell:GetSpecialValueFor( "fade_time" ) )
end

--------------------------------------------------------------------------------

function modifier_creep_snow_cloak:RemoveInvis( event )
	local spell = self:GetAbility()

	self.invisible = false

	self:StartIntervalThink( spell:GetSpecialValueFor( "fade_time" ) )
end

--------------------------------------------------------------------------------

function modifier_creep_snow_cloak:OnIntervalThink()
	self.invisible = true

	self:StartIntervalThink( -1 )
end

--------------------------------------------------------------------------------

function modifier_creep_snow_cloak:CheckState()
	local state = {
		[MODIFIER_STATE_INVISIBLE] = self.invisible
	}

	return state
end

--------------------------------------------------------------------------------

function modifier_creep_snow_cloak:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}

	return funcs
end

--------------------------------------------------------------------------------

-- this is purely for visuals ( the "half disappeared" effect )
function modifier_creep_snow_cloak:GetModifierInvisibilityLevel( event )
	return 0.4
end

--------------------------------------------------------------------------------

function modifier_creep_snow_cloak:OnAttack( event )
	local parent = self:GetParent()

	if parent == event.attacker then
		self:RemoveInvis()
	end
end

--------------------------------------------------------------------------------

function modifier_creep_snow_cloak:OnTakeDamage( event )
	local parent = self:GetParent()

	if parent == event.unit and event.damage > 0 then
		self:RemoveInvis()
	end
end