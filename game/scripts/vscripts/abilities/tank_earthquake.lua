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
	
	local targets = 
	ParticleManager:ReleaseParticleIndex( self.warningFX )
end
