tank_earthquake = class({})

--------------------------------------------------------------------------------
function tank_earthquake:OnAbilityPhaseStart()
	self.warningFX = ParticleManager:CreateParticle("particles/econ/generic/generic_aoe_shockwave_1/generic_aoe_shockwave_1.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(thinker, 0, position)
	ParticleManager:SetParticleControl(thinker, 2, Vector(self:GetCastPoint(),0,1))
	ParticleManager:SetParticleControl(thinker, 1, Vector(radius,0,0))
	ParticleManager:SetParticleControl(thinker, 3, Vector(255,0,0))
	ParticleManager:SetParticleControl(thinker, 4, Vector(0,0,0))
	return true
end

function tank_earthquake:OnAbilityPhaseInterrupted()
	ParticleManager:ReleaseParticleIndex( self.warningFX )
end


function tank_earthquake:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local duration = self:GetSpecialValueFor("stun_duration")
	local radius = self:GetSpecialValueFor("stun_radius")
	local damage = self:GetSpecialValueFor("damage")
	
	local targets = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetOrigin(), caster, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
	ParticleManager:ReleaseParticleIndex( self.warningFX )
	for _, target in pairs( targets ) do
		target:AddNewModifier(target, self, "modifier_stunned", {duration = duration})
		ApplyDamage({victim = hero, attacker = self:GetCaster(), damage = damage, ability = self:GetAbility(), damage_type = self:GetAbility():GetAbilityDamageType()})
	end
	
	stunFX = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_split_earth.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(stunFX, 0, position)
	ParticleManager:SetParticleControl(stunFX, 2, position)
	ParticleManager:SetParticleControl(stunFX, 1, Vector(radius,0,0))
	ParticleManager:ReleaseParticleIndex( stunFX )
	EmitSoundOnLocationWithCaster(position, "n_creep_Ursa.Clap", caster)
end
