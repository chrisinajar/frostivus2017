evil_wisp_egg = class(AbilityBaseClass)

function evil_wisp_egg:OnSpellStart()
	local caster = self:GetCaster()
	local dummy = CreateUnitByName("npc_dota_dummy", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeam())

	dummy:SetBaseMaxHealth( self:GetSpecialValueFor("egg_hits") )
	dummy:SetMaxHealth( self:GetSpecialValueFor("egg_hits") )
	dummy:SetHealth( self:GetSpecialValueFor("egg_hits") )

	caster:AddNewModifier(caster, self, "modifier_evil_wisp_egg_hide", {duration = self:GetSpecialValueFor("egg_duration")})
	dummy:AddNewModifier(caster, self, "modifier_evil_wisp_egg_egg", {duration = self:GetSpecialValueFor("egg_duration")})

	EmitSoundOn("Hero_Phoenix.SuperNova.Cast", caster)
	EmitSoundOn("Hero_Phoenix.SuperNova.Begin", caster)
end

function evil_wisp_egg:StunWinner(bEggKilled)
	local caster = self:GetCaster()

	local FX = "particles/act_4/io_dwarf_reborn.vpcf"
	if bEggKilled then FX = "particles/act_4/io_dwarf_death.vpcf" end
	local eggFX = ParticleManager:CreateParticle(FX, PATTACH_POINT_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(eggFX)

	if bEggKilled then
		caster:AddNewModifier(caster, self, "modifier_evil_wisp_egg_stun", {duration = self:GetSpecialValueFor("egg_self_stun_duration")})
		EmitSoundOn("Hero_Phoenix.SuperNova.Explode", caster)
	else
		EmitSoundOn("Hero_Phoenix.SuperNova.Death", caster)
		local stunTargets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
		local stunDuration = self:GetSpecialValueFor("egg_enemy_stun_duration")

		for _, stunTarget in ipairs(stunTargets) do
			stunTarget:AddNewModifier(caster, self, "modifier_evil_wisp_egg_stun", {duration = stunDuration})
		end
	end
end

modifier_evil_wisp_egg_stun = class(ModifierBaseClass)
LinkLuaModifier("modifier_evil_wisp_egg_stun", "abilities/evil_wisp/evil_wisp_egg.lua", 0)

function modifier_evil_wisp_egg_stun:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_evil_wisp_egg_stun:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_evil_wisp_egg_stun:CheckState()
	local state = { [MODIFIER_STATE_STUNNED] = true}
	return state
end

function modifier_evil_wisp_egg_stun:IsPurgable()
	return true
end

function modifier_evil_wisp_egg_stun:IsStunDebuff()
	return true
end

function modifier_evil_wisp_egg_stun:IsPurgeException()
	return true
end

modifier_evil_wisp_egg_hide = class(ModifierBaseClass)
LinkLuaModifier("modifier_evil_wisp_egg_hide", "abilities/evil_wisp/evil_wisp_egg.lua", 0)

if IsServer() then
	function modifier_evil_wisp_egg_hide:OnCreated()
		self:GetParent():AddNoDraw()
	end

	function modifier_evil_wisp_egg_hide:OnDestroy()
		self:GetParent():RemoveNoDraw()
	end
end

function modifier_evil_wisp_egg_hide:IsHidden()
	return true
end

function modifier_evil_wisp_egg_hide:CheckState()
	return {
				[MODIFIER_STATE_STUNNED] = true,
				[MODIFIER_STATE_INVISIBLE] = true,
				[MODIFIER_STATE_INVULNERABLE] = true,
				[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
				[MODIFIER_STATE_NO_HEALTH_BAR] = true,
				[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			}
end

modifier_evil_wisp_egg_egg = class(ModifierBaseClass)
LinkLuaModifier("modifier_evil_wisp_egg_egg", "abilities/evil_wisp/evil_wisp_egg.lua", 0)

if IsServer() then
	function modifier_evil_wisp_egg_egg:OnCreated()
		self.internalHP = self:GetParent():GetMaxHealth()
		self:SetStackCount(0)

    self.tick = self:GetSpecialValueFor("tick_interval")
    self.damage_tick = self:GetSpecialValueFor("damage_per_tick")
    self.damage_radius = self:GetSpecialValueFor("damage_radius")

    if IsServer() then self:StartIntervalThink(self.tick) end
	end

  function modifier_evil_wisp_egg_egg:OnIntervalThink()
    local caster = self:GetCaster()
    local heroes = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetOrigin(), caster, self.damage_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
		for _,hero in pairs( heroes ) do
			ApplyDamage({victim = hero, attacker = self:GetCaster(), damage = self.damage_tick, ability = self:GetAbility(), damage_type = self:GetAbility:GetAbilityDamageType()})
		end
  end

	function modifier_evil_wisp_egg_egg:OnDestroy()
		self:GetParent():Kill(self:GetAbility(), self:GetCaster())
		self:GetCaster():RemoveModifierByName("modifier_evil_wisp_egg_hide")
		self:GetAbility():StunWinner( self:GetStackCount() == 1 )
	end
end

function modifier_evil_wisp_egg_egg:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_MODEL_CHANGE, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_evil_wisp_egg_egg:OnTakeDamage(params)
	if params.unit == self:GetParent() then
		self.internalHP = self.internalHP - 1
		if self.internalHP > 0 then
			print(self.internalHP)
			params.unit:SetHealth( self.internalHP )
		else
			self:SetStackCount(1)
			params.unit:Kill(params.inflictor, params.attacker)
		end
	end
end

function modifier_evil_wisp_egg_egg:GetModifierModelChange()
	return "models/heroes/phoenix/phoenix_egg.vmdl"
end

function modifier_evil_wisp_egg_egg:GetModifierIncomingDamage_Percentage()
	return -1000
end

function modifier_evil_wisp_egg_egg:GetModifierModelChange()
	return "models/heroes/phoenix/phoenix_egg.vmdl"
end

function modifier_evil_wisp_egg_egg:GetEffectName()
	return "particles/act_4/io_dwarf_egg.vpcf"
end
