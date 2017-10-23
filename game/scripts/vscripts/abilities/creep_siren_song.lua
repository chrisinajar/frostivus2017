creep_siren_song = class( AbilityBaseClass )

LinkLuaModifier( "modifier_creep_siren_song", "abilities/creep_siren_song.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_creep_siren_song_debuff", "abilities/creep_siren_song.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function creep_siren_song:OnSpellStart()
	local caster = self:GetCaster()

	-- add the aura modifier
	caster:AddNewModifier( caster, self, "modifier_creep_siren_song", {
		duration = self:GetSpecialValueFor( "duration" )
	} )
end

--------------------------------------------------------------------------------

modifier_creep_siren_song = class( ModifierBaseClass )

--------------------------------------------------------------------------------

function modifier_creep_siren_song:IsHidden()
	return false
end

function modifier_creep_siren_song:IsDebuff()
	return false
end

function modifier_creep_siren_song:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

-- set up aura properties
function modifier_creep_siren_song:IsAura()
	return true
end

function modifier_creep_siren_song:GetModifierAura()
	return "modifier_creep_siren_song_debuff"
end

function modifier_creep_siren_song:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor( "radius" )
end

function modifier_creep_siren_song:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_creep_siren_song:GetAuraSearchType()
	return bit.bor( DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_CREEP )
end

function modifier_creep_siren_song:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

--------------------------------------------------------------------------------

if IsServer() then
	function modifier_creep_siren_song:OnCreated( event )
		local parent = self:GetParent()
		local originParent = parent:GetAbsOrigin()

		-- play the sound
		parent:EmitSound( "Hero_NagaSiren.SongOfTheSiren" )

		-- play the start up particle
		local part = ParticleManager:CreateParticle( "particles/units/heroes/hero_siren/naga_siren_siren_song_cast.vpcf", PATTACH_WORLDORIGIN, nil )
		ParticleManager:SetParticleControl( part, 0, originParent )
		ParticleManager:ReleaseParticleIndex( part )

		-- create the "effect active" particle
		-- doing it this way so we can set up a custom attach point
		self.partAura = ParticleManager:CreateParticle( "particles/units/heroes/hero_siren/naga_siren_song_aura.vpcf", PATTACH_POINT_FOLLOW, parent )
		ParticleManager:SetParticleControlEnt( self.partAura, 0, parent, PATTACH_POINT_FOLLOW, "attach_head", originParent, true )
	end

--------------------------------------------------------------------------------

	function modifier_creep_siren_song:OnDestroy()
		local parent = self:GetParent()
		local originParent = parent:GetAbsOrigin()

		-- stop the sound
		parent:StopSound( "Hero_NagaSiren.SongOfTheSiren" )

		-- delete the active particle
		ParticleManager:DestroyParticle( self.partAura, false )
		ParticleManager:ReleaseParticleIndex( self.partAura )

		-- create the end particle
		local part = ParticleManager:CreateParticle( "particles/units/heroes/hero_siren/naga_siren_siren_song_end.vpcf", PATTACH_WORLDORIGIN, nil )
		ParticleManager:SetParticleControl( part, 0, originParent )
		ParticleManager:ReleaseParticleIndex( part )
	end

--------------------------------------------------------------------------------

	function modifier_creep_siren_song:DeclareFunctions()
		local funcs = {
			MODIFIER_EVENT_ON_STATE_CHANGED,
		}

		return funcs
	end

--------------------------------------------------------------------------------

	function modifier_creep_siren_song:OnStateChanged( event )
		local parent = self:GetParent()

		if parent == event.unit then
			-- check if the caster is prevented from casting spells
			-- and if so, end the effect
			if parent:IsStunned() or parent:IsSilenced() or parent:IsHexed() then
				self:Destroy()
			end
		end
	end
end

--------------------------------------------------------------------------------

function modifier_creep_siren_song:CheckState()
	-- since this is a "moving channel", you can't really attack during a channel
	-- can you?
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
	}

	return state
end

--------------------------------------------------------------------------------

modifier_creep_siren_song_debuff = class( ModifierBaseClass )

--------------------------------------------------------------------------------

function modifier_creep_siren_song_debuff:IsHidden()
	return false
end

function modifier_creep_siren_song_debuff:IsDebuff()
	return true
end

function modifier_creep_siren_song_debuff:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_creep_siren_song_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_siren_song.vpcf"
end

function modifier_creep_siren_song_debuff:StatusEffectPriority()
	return 10
end

--------------------------------------------------------------------------------

if IsServer() then
	function modifier_creep_siren_song_debuff:OnCreated( event )
		local parent = self:GetParent()
		local originParent = parent:GetAbsOrigin()

		-- create the effect particle with custom attach point
		self.part = ParticleManager:CreateParticle( "particles/units/heroes/hero_siren/naga_siren_song_debuff.vpcf", PATTACH_POINT_FOLLOW, parent )
		ParticleManager:SetParticleControlEnt( self.part, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", originParent, true )
	end

--------------------------------------------------------------------------------

	function modifier_creep_siren_song_debuff:OnDestroy()
		local parent = self:GetParent()
		local originParent = parent:GetAbsOrigin()

		-- delete the effect particle
		ParticleManager:DestroyParticle( self.part, false )
		ParticleManager:ReleaseParticleIndex( self.part )
	end
end

--------------------------------------------------------------------------------

function modifier_creep_siren_song_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

--------------------------------------------------------------------------------

function modifier_creep_siren_song_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_creep_siren_song_debuff:GetOverrideAnimation( event )
	return ACT_DOTA_DISABLED
end