LinkLuaModifier('modifier_player_watcher', 'modifiers/modifier_player_watcher', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_is_near_player', 'modifiers/modifier_player_watcher', LUA_MODIFIER_MOTION_NONE)

modifier_player_watcher = class(ModifierBaseClass)

function modifier_player_watcher:IsHidden()
  return true
end

function modifier_player_watcher:IsPurgable()
  return false
end

function modifier_player_watcher:IsPermanent()
  return true
end

function modifier_player_watcher:RemoveOnDeath()
  return false
end

--------------------------------------------------------------------------
-- aura stuff

function modifier_player_watcher:IsAura()
  return true
end

function modifier_player_watcher:GetAuraSearchType()
  return DOTA_UNIT_TARGET_BASIC
end

function modifier_player_watcher:GetAuraSearchTeam()
  return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_player_watcher:GetAuraRadius()
  return 3000
end

function modifier_player_watcher:GetModifierAura()
  return "modifier_is_near_player"
end

-- function modifier_player_watcher:GetAuraEntityReject(entity)
--   self:SetStackCount(0)
--   return false
-- end

--------------------------------------------------------------------------

modifier_is_near_player = class(ModifierBaseClass)

function modifier_is_near_player:IsHidden()
  return true
end

function modifier_is_near_player:IsPurgable()
  return false
end
