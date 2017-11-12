function SelfDestruct( event )
	-- Variables
	local caster = event.caster
	local ability = event.ability
	local self_damage = caster.GetHealth() * 2
	local damageType = ability:GetAbilityDamageType()
	DebugPrint('Self Destruct')
	-- Self damage
	ApplyDamage({ victim = caster, attacker = caster, damage = self_damage,	damage_type = damageType, damage_flags = DOTA_DAMAGE_FLAG_NONE })
end