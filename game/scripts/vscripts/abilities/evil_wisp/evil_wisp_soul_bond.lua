evil_wisp_soul_bond = class({})

function evil_wisp_soul_bond:OnSpellStart()
	local caster = self:GetCaster()
	self.target = self:GetCursorTarget()

	local range = self:GetSpecialValueFor("tether_range")
	local ogDist = (caster:GetAbsOrigin() - self.target:GetAbsOrigin()):Length2D()
	local speed = (ogDist - range) / 0.5
	if ogDist > range then
		Timers:CreateTimer(function()
			local distance = (caster:GetAbsOrigin() - self.target:GetAbsOrigin()):Length2D()
			if distance <= range then
				FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
				caster:AddNewModifier(caster, self, "modifier_evil_wisp_soul_bond", {duration = self:GetSpecialValueFor("tether_duration")})
			else
				local direction = (self.target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
				caster:SetAbsOrigin(caster:GetAbsOrigin() + direction * speed * FrameTime())
				return FrameTime()
			end
		end)
	else
		caster:AddNewModifier(caster, self, "modifier_evil_wisp_soul_bond", {duration = self:GetSpecialValueFor("tether_duration")})
	end
end

modifier_evil_wisp_soul_bond = class({})
LinkLuaModifier("modifier_evil_wisp_soul_bond", "abilities/evil_wisp/evil_wisp_soul_bond", 0)

if IsServer() then
	function modifier_evil_wisp_soul_bond:OnCreated()
		local caster = self:GetCaster()
		self.target = self:GetAbility().target
		local FX = ParticleManager:CreateParticle("particles/units/heroes/hero_death_prophet/death_prophet_spiritsiphon.vpcf", PATTACH_POINT_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(FX, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(FX, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(FX, 5, Vector(self:GetDuration(), 0, 0))
		self:AddParticle(FX, false, false, 0, false, false)
		self:StartIntervalThink(0.2)
	end

	function modifier_evil_wisp_soul_bond:OnIntervalThink()
		local caster = self:GetCaster()
		local distance = (caster:GetAbsOrigin() - self.target:GetAbsOrigin()):Length2D()
		local range = self:GetAbility():GetSpecialValueFor("tether_range") + self:GetAbility():GetSpecialValueFor("break_buffer")
		if distance > range or self.target:IsNull() or not self.target:IsAlive() then
			self:Destroy()
		end
	end

  function modifier_evil_wisp_soul_bond:DeclareFunctions()
    return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
  end

  function modifier_evil_wisp_soul_bond:GetModifierTotalDamageOutgoing_Percentage(params)
    ApplyDamage({
      attacker = self:GetCaster(),
      victim = self.target,
      damage = params.damage,
      damage_type = params.damage_type,
      ability = self:GetAbility()
    })
    return -100
  end

end
