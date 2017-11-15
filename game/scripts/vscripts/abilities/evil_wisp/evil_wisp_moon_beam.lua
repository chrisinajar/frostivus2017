evil_wisp_moon_beam = class({})


function evil_wisp_moon_beam:OnSpellStart()
	local caster = self:GetCaster()
	
	-- special value init
	local targetCount = self:GetSpecialValueFor("target_count")
	local searchRadius = self:GetCastRange(caster:GetAbsOrigin(), caster)
	local beamRadius = self:GetSpecialValueFor("beam_radius")
	local beamDamage = self:GetSpecialValueFor("beam_damage")
	local beamDelay = self:GetSpecialValueFor("beam_delay")
	
	local possibleTargets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, searchRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
	if #possibleTargets == 0 then 
		self:EndCooldown()
		return
	end
	
	for i = 1, targetCount do
		if possibleTargets[i] then
			local position = possibleTargets[i]:GetAbsOrigin()
			Timers:CreateTimer(0.2*i, function() self:LaunchBeam(position, beamDelay, beamRadius, beamDamage) end)
		end
	end
end

function evil_wisp_moon_beam:LaunchBeam(position, beamDelay, beamRadius, beamDamage)
	local caster = self:GetCaster()
	local warning = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_sun_strike_team.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(warning, 0, position)
	ParticleManager:SetParticleControl(warning, 1, Vector(beamRadius,1,1) )
	EmitSoundOn("Hero_Invoker.SunStrike.Charge", caster)
	Timers:CreateTimer(beamDelay, function()
		EmitSoundOn("Hero_Invoker.SunStrike.Ignite", caster)
		ParticleManager:DestroyParticle(warning, false)
		ParticleManager:ReleaseParticleIndex(warning)
		local impact = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_sun_strike.vpcf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(impact, 0, position)
		ParticleManager:SetParticleControl(impact, 1, Vector(beamRadius,1,1) )
		ParticleManager:ReleaseParticleIndex(impact)
		
		local impactTargets = FindUnitsInRadius(caster:GetTeamNumber(), position, nil, beamRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
		for _, impactTarget in ipairs(impactTargets) do
			ApplyDamage({victim = impactTarget, attacker = caster, ability = self, damage = beamDamage, damage_type = self:GetAbilityDamageType()})
		end
	end)
end