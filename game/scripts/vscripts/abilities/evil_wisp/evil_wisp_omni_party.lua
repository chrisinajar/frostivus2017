evil_wisp_omni_party = class({})

function evil_wisp_omni_party:OnSpellStart()
	local caster = self:GetCaster()
	local safeZones = self:GetSpecialValueFor("safe_count") + RandomInt(0, self:GetSpecialValueFor("safe_variation"))
	
	local damage = self:GetSpecialValueFor("blast_damage")
	local duration = self:GetSpecialValueFor("blast_duration") + RandomInt(0, self:GetSpecialValueFor("blast_duration_variation"))
	local delay = self:GetSpecialValueFor("blast_interval")
	
	self.zoneTable = {}
	for i = 1, safeZones do
		local zoneInfo = {}
		zoneInfo.particle = ParticleManager:CreateParticle("particles/act_4/io_omni_circle.vpcf", PATTACH_WORLDORIGIN, nil)
		zoneInfo.position = caster:GetAbsOrigin() + RandomVector(RandomInt(300, self:GetSpecialValueFor("radius") ))
		zoneInfo.radius = self:GetSpecialValueFor("safe_radius") + RandomInt(0, self:GetSpecialValueFor("safe_radius_variation"))
		ParticleManager:SetParticleControl(zoneInfo.particle, 0, zoneInfo.position)
		ParticleManager:SetParticleControl(zoneInfo.particle, 1, Vector(zoneInfo.radius,1,1))
		table.insert(self.zoneTable, zoneInfo)
	end
	local warning = self:FireWarning()
	Timers:CreateTimer( delay, function()
		local heroes = HeroList:GetAllHeroes()
		
		local blastFX = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(blastFX, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(blastFX, 1, Vector(3000,0,0))
		ParticleManager:ReleaseParticleIndex(blastFX)
		for _, hero in ipairs(heroes) do
			if not hero:IsInvulnerable() and hero:IsAlive() and not self:IsHeroSafe(hero) then
				ApplyDamage({attacker = caster, victim = hero, damage = damage, damage_type = DAMAGE_TYPE_PURE, ability = self})
			end
		end
		
		EmitSoundOn("Hero_Crystal.CrystalNova", caster)
		
		if duration > 0 then
			duration = duration - delay
			ParticleManager:DestroyParticle(warning, false)
			ParticleManager:ReleaseParticleIndex(warning)
			warning = self:FireWarning()
			return delay
		else
			self:ClearSafeZones()
		end
	end)
end

function evil_wisp_omni_party:FireWarning()
	local warning = ParticleManager:CreateParticle("particles/act_4/io_moon_strike_team.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(warning, 0, self:GetCaster():GetAbsOrigin() )
	ParticleManager:SetParticleControl(warning, 1, Vector(3000,1,1) )
	EmitSoundOn("hero_Crystal.CrystalNovaCast", caster)
	return warning
end

function evil_wisp_omni_party:IsHeroSafe(hero)
	for _, zoneInfo in ipairs(self.zoneTable) do
		if (zoneInfo.position - hero:GetAbsOrigin()):Length2D() < zoneInfo.radius then
			return true
		end
	end
	return false
end

function evil_wisp_omni_party:ClearSafeZones()
	for _, zoneInfo in ipairs(self.zoneTable) do
		print(zoneInfo.particle)
		ParticleManager:DestroyParticle( zoneInfo.particle, false)
		ParticleManager:ReleaseParticleIndex( zoneInfo.particle )
	end
	self.zoneTable = {}
end