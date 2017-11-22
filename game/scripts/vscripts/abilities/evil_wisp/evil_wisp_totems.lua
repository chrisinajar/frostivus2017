evil_wisp_totems = class({})

function evil_wisp_totems:OnSpellStart()
	local caster = self:GetCaster()
	if self.totems and #self.totems > 0 then
		for index, totem in ipairs(self.totems) do
			self:ClearTotem(totem)
		end
	end
	self.totems = {}
	local totemCount = self:GetSpecialValueFor("totems")
	local distance = self:GetSpecialValueFor("totem_distance")
	print(totemCount, "ok")
	for i = 1, totemCount do
		self:CreateTotem( caster:GetAbsOrigin() + RandomVector(distance) )	
	end
end

function evil_wisp_totems:ClearTotem(totem)
	if not totem:IsNull() then
		totem:Destroy()
	end
	self.totems[index] = nil
end

function evil_wisp_totems:CreateTotem(position)
	local caster = self:GetCaster()
	local totem = CreateUnitByName("npc_dota_dummy", position, true, nil, nil, caster:GetTeam())

	totem:SetBaseMaxHealth( self:GetSpecialValueFor("totem_hits") )
	totem:SetMaxHealth( self:GetSpecialValueFor("totem_hits") )
	totem:SetHealth( self:GetSpecialValueFor("totem_hits") )
	
	local modifier = totem:AddNewModifier(caster, self, "modifier_evil_wisp_totems_dummy_link", {duration = self:GetSpecialValueFor("duration")})
	print( modifier, "??" )
	table.insert(self.totems, totem)
end

modifier_evil_wisp_totems_dummy_link = class({})
LinkLuaModifier("modifier_evil_wisp_totems_dummy_link", "abilities/evil_wisp/evil_wisp_totems", 0)

if IsServer() then
	function modifier_evil_wisp_totems_dummy_link:OnCreated()
		self.internalHP = self:GetParent():GetMaxHealth()
		self:StartIntervalThink(0.5)
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local FX = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_tether_agh.vpcf", PATTACH_POINT_FOLLOW, parent)
		ParticleManager:SetParticleControlEnt(FX, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(FX, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		self:AddParticle(FX, false, false, 0, false, false)
	end
	
	function modifier_evil_wisp_totems_dummy_link:OnIntervalThink()
		local caster = self:GetCaster()
		local totem = self:GetParent()
		local unitsInLine = FindUnitsInLine(caster:GetTeam(), totem:GetAbsOrigin(), caster:GetAbsOrigin(), nil, 24, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0)
		local stunDuration = self:GetAbility():GetSpecialValueFor("stun_duration")
		for _, unit in ipairs(unitsInLine) do
			if not unit:HasModifier("modifier_evil_wisp_totem_stun") then
				unit:AddNewModifier(caster, self:GetAbility(), "modifier_evil_wisp_totem_stun", {duration = stunDuration})
			end
		end
	end

	function modifier_evil_wisp_totems_dummy_link:OnDestroy()
		print("!")
		self:GetParent():Kill(self:GetAbility(), self:GetCaster())
		self:GetAbility():ClearTotem(self:GetParent())
	end
end

function modifier_evil_wisp_totems_dummy_link:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_MODEL_CHANGE, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_evil_wisp_totems_dummy_link:OnTakeDamage(params)
	if params.unit == self:GetParent() then
		self.internalHP = self.internalHP - 1
		if self.internalHP > 0 then
			params.unit:SetHealth( self.internalHP )
		else

			params.unit:Kill(params.inflictor, params.attacker)
		end
	end
end

function modifier_evil_wisp_totems_dummy_link:GetModifierModelChange()
	return "models/heroes/undying/undying_tower.vmdl"
end

function modifier_evil_wisp_totems_dummy_link:GetModifierIncomingDamage_Percentage()
	return -1000
end

function modifier_evil_wisp_totems_dummy_link:GetEffectName()
	return "particles/units/heroes/hero_undying/undying_tombstone_ambient.vpcf"
end


modifier_evil_wisp_totem_stun = class(ModifierBaseClass)
LinkLuaModifier("modifier_evil_wisp_totem_stun", "abilities/evil_wisp/evil_wisp_totems.lua", 0)

function modifier_evil_wisp_totem_stun:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_evil_wisp_totem_stun:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_evil_wisp_totem_stun:CheckState()
	local state = { [MODIFIER_STATE_STUNNED] = true}
	return state
end

function modifier_evil_wisp_totem_stun:IsPurgable()
	return true
end

function modifier_evil_wisp_totem_stun:IsStunDebuff()
	return true
end

function modifier_evil_wisp_totem_stun:IsPurgeException()
	return true
end
