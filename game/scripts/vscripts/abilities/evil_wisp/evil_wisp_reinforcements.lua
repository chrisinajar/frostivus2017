evil_wisp_reinforcements = class({})

function evil_wisp_reinforcements:OnSpellStart()
	local caster = self:GetCaster()
	
	local delay = self:GetSpecialValueFor("tank_spawn_delay")
	local tanks = self:GetSpecialValueFor("tanks_spawned")
	for i = 1, self:GetSpecialValueFor("special_spawns") do
		HordeDirector:SpawnSpecialUnit()
	end
	EmitSoundOn("Hero_Wisp.Relocate", caster)
	for i = 1, tanks do
		local spawnPos = caster:GetAbsOrigin() + RandomVector( RandomInt(500, 1200) )
		local tier = self:GetSpecialValueFor("tank_tier")
		
		local spawnFX = ParticleManager:CreateParticle("particles/econ/items/wisp/wisp_relocate_channel_ti7.vpcf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(spawnFX, 0, spawnPos)
		ParticleManager:SetParticleControl(spawnFX, 1, spawnPos)
		ParticleManager:SetParticleControl(spawnFX, 3, spawnPos)
		Timers:CreateTimer(delay + RandomFloat(0, 0.5), function()
			ParticleManager:DestroyParticle(spawnFX, false)
			ParticleManager:ReleaseParticleIndex(spawnFX)
			local tankName = "npc_dota_horde_special_4"
			if tier > 1 then
				tankName = tankName.."_act"..tier
			end
			local tank = CreateUnitByName(tankName, spawnPos, true, nil, nil, caster:GetTeamNumber())
			EmitSoundOn("Hero_Wisp.Return", tank)
			tank:AddNewModifier(caster, self, "modifier_evil_wisp_link", {duration = 30})
		end)
	end
	
	caster:AddNewModifier(caster, self, "modifier_evil_wisp_protected", {duration = 30}):SetStackCount(tanks)
end

modifier_evil_wisp_link = class({})
LinkLuaModifier("modifier_evil_wisp_link", "abilities/evil_wisp/evil_wisp_reinforcements", 0)

if IsServer() then
	function modifier_evil_wisp_link:OnCreated()
		local parent = self:GetParent()
		local caster = self:GetCaster()
		self.FX = ParticleManager:CreateParticle("particles/econ/items/wisp/wisp_tether_ti7.vpcf", PATTACH_POINT_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(self.FX, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.FX, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
	end
	
	function modifier_evil_wisp_link:OnDestroy()
		ParticleManager:DestroyParticle(self.FX, false)
		ParticleManager:ReleaseParticleIndex(self.FX)
		if self:GetCaster():HasModifier("modifier_evil_wisp_protected") then
			local modifier = self:GetCaster():FindModifierByName("modifier_evil_wisp_protected")
			local stacks = modifier:GetStackCount()
			if stacks == 1 then modifier:Destroy() else modifier:DecrementStackCount() end
		end
	end
end


modifier_evil_wisp_protected = class({})
LinkLuaModifier("modifier_evil_wisp_protected", "abilities/evil_wisp/evil_wisp_reinforcements", 0)

function modifier_evil_wisp_protected:GetEffectName()
	return "particles/neutral_fx/fortify_creeps.vpcf"
end

function modifier_evil_wisp_protected:OnStackCountChanged( oldStacks )
	if oldStacks == 1 then self:Destroy() end
end

function modifier_evil_wisp_protected:CheckState()
	return {[MODIFIER_STATE_INVULNERABLE] = true}
end

function modifier_evil_wisp_protected:DeclareFunctions()
	return {MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE}
end

function modifier_evil_wisp_protected:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_evil_wisp_protected:GetAbsoluteNoDamageMagical()
	return 1
end

function modifier_evil_wisp_protected:GetAbsoluteNoDamagePure()
	return 1
end