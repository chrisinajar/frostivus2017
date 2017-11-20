item_health_potion = class({})

--------------------------------------------------------------------------------

function item_health_potion:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_IMMEDIATE
end

--------------------------------------------------------------------------------

function item_health_potion:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		self.hp_restore_pct = self:GetSpecialValueFor( "hp_restore_pct" )
		caster:EmitSoundParams( "DOTA_Item.FaerieSpark.Activate", 0, 0.5, 0)

		if self:GetSpecialValueFor("affects_allies") == 1 then
			local Heroes = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetOrigin(), caster, self:GetSpecialValueFor("heal_radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, 0, false )
			for _,Hero in pairs( Heroes ) do
				self:HealHero(Hero)
			end
		else
			self:HealHero(caster)
		end

    self:Destroy()
	end
end

--------------------------------------------------------------------------------

function item_health_potion:HealHero(hero)
	hero:Heal( hero:GetMaxHealth() * self.hp_restore_pct / 100, self )

	local nFXIndex = ParticleManager:CreateParticle( "particles/items3_fx/fish_bones_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
end
