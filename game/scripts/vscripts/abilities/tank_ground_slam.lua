tank_ground_slam = class({})

--------------------------------------------------------------------------------
function tank_ground_slam:OnAbilityPhaseStart()
	self:GetCaster():RemoveGesture( ACT_DOTA_CAST_ABILITY_1 )
	self:GetCaster():StartGestureWithPlaybackRate( ACT_DOTA_CAST_ABILITY_1, 1.5/self:GetCastPoint())
	self.position = self:GetCursorPosition()
	self.radius = self:GetSpecialValueFor("stun_radius")
	self.warningFX = ParticleManager:CreateParticle("particles/econ/generic/generic_aoe_shockwave_1/generic_aoe_shockwave_1.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(self.warningFX, 0, self.position)
	ParticleManager:SetParticleControl(self.warningFX, 2, Vector(self:GetCastPoint()*3,0,1))
	ParticleManager:SetParticleControl(self.warningFX, 1, Vector(self.radius,0,0))
	ParticleManager:SetParticleControl(self.warningFX, 3, Vector(255,0,0))
	ParticleManager:SetParticleControl(self.warningFX, 4, Vector(0,0,0))
	return true
end

function tank_ground_slam:OnAbilityPhaseInterrupted()
	self:GetCaster():RemoveGesture( ACT_DOTA_CAST_ABILITY_1 )
	ParticleManager:ReleaseParticleIndex( self.warningFX )
end


function tank_ground_slam:OnSpellStart()
	local caster = self:GetCaster()

	caster:Interrupt()
	caster:Stop()
	local duration = self:GetSpecialValueFor("stun_duration")
	local damage = self:GetSpecialValueFor("damage")

	local targets = FindUnitsInRadius( caster:GetTeamNumber(), self.position, caster, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
	ParticleManager:ReleaseParticleIndex( self.warningFX )
	for _, target in pairs( targets ) do
		target:AddNewModifier(target, self, "modifier_stunned", {duration = duration})
		ApplyDamage({
		  victim = target,
		  attacker = self:GetCaster(),
		  damage = damage,
		  ability = self,
		  damage_type = self:GetAbilityDamageType()
		})
	end

	stunFX = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_split_earth.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(stunFX, 0, self.position)
	ParticleManager:SetParticleControl(stunFX, 2, self.position)
	ParticleManager:SetParticleControl(stunFX, 1, Vector(self.radius,0,0))
	ParticleManager:ReleaseParticleIndex( stunFX )
	EmitSoundOnLocationWithCaster(self.position, "n_creep_Ursa.Clap", caster)

end
