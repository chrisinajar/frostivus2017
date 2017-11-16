LinkLuaModifier('modifier_act2_auto_present', 'modifiers/modifier_act2_auto_present.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_act2_auto_present_runner', 'modifiers/modifier_act2_auto_present.lua', LUA_MODIFIER_MOTION_NONE)

modifier_act2_auto_present = class(ModifierBaseClass)

function modifier_act2_auto_present:IsHidden()
  return true
end
function modifier_act2_auto_present:IsPurgable()
  return false
end

--------------------------------------------------------------------
--aura
if IsServer() then

function modifier_act2_auto_present:IsAura()
  return true
end

function modifier_act2_auto_present:GetAuraSearchType()
  return DOTA_UNIT_TARGET_HERO
end

function modifier_act2_auto_present:GetAuraSearchTeam()
  return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_act2_auto_present:GetAuraRadius()
  return AUTO_PRESENT_RADIUS
end

function modifier_act2_auto_present:GetModifierAura()
  return "modifier_act2_auto_present_runner"
end

end

modifier_act2_auto_present_runner = class(ModifierBaseClass)

function modifier_act2_auto_present_runner:OnCreated()
  self:CheckPresents()
  self:StartIntervalThink(1)
end

function modifier_act2_auto_present_runner:OnIntervalThink()
  self:CheckPresents()
end

function modifier_act2_auto_present_runner:CheckPresents()
  local hero = self:GetParent()
  if not hero then
    return
  end
  if hero:HasItemInInventory("item_present_for_search") then
    for i = 0,5 do
      local itemHandle = hero:GetItemInSlot(i)
      if itemHandle ~= nil and itemHandle:GetName() == "item_present_for_search" then
        local count = itemHandle:GetCurrentCharges()
        hero:RemoveItem(itemHandle)
        PhaseTwo:PresentsTurnedIn(count)
      end
    end
  end
end

modifier_act2_auto_present_runner.OnRefresh = modifier_act2_auto_present_runner.OnCreated

function modifier_act2_auto_present_runner:IsHidden()
  return true
end
function modifier_act2_auto_present_runner:IsPurgable()
  return false
end
