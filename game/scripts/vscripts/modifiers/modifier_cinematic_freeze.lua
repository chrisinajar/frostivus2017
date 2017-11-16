LinkLuaModifier('modifier_cinematic_freeze', 'modifiers/modifier_cinematic_freeze.lua', LUA_MODIFIER_MOTION_NONE)

modifier_cinematic_freeze = class(ModifierBaseClass)

function modifier_cinematic_freeze:IsHidden()
  return true
end

function modifier_cinematic_freeze:IsPurgable()
  return false
end

function modifier_cinematic_freeze:IsPermanent()
  return true
end

function modifier_cinematic_freeze:RemoveOnDeath()
  return false
end

function modifier_cinematic_freeze:CheckState()
  return {
	[MODIFIER_STATE_STUNNED] = true,
	[MODIFIER_STATE_INVULNERABLE] = true,
	[MODIFIER_STATE_UNSELECTABLE] = true,
	[MODIFIER_STATE_FROZEN] = true,
	[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
  }
end

if IsServer() then
	function CDOTA_BaseNPC_Hero:FreezeHero(duration)
		self:AddNewModifier(self, nil, "modifier_cinematic_freeze", {duration = duration})
	end

	function CDOTA_BaseNPC_Hero:UnfreezeHero(duration)
		self:RemoveModifierByName("modifier_cinematic_freeze")
	end
end
