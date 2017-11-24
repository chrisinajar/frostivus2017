LinkLuaModifier("modifier_item_part", "items/item_part_retrieval.lua", LUA_MODIFIER_MOTION_NONE)
item_part_retrieval = class(ItemBaseClass)

--------------------------------------------------------------------------------

function item_part_retrieval:GetBehavior()
	local behavior = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	return behavior
end

function item_part_retrieval:GetIntrinsicModifierName()
  return "modifier_item_part"
end


function item_part_retrieval:GetCooldown(nLevel)
	return 0.5
end

function item_part_retrieval:OnOwnerDied()
	local hCaster = self:GetCaster()
	local numberOfPresents = self:GetCurrentCharges()
	local pos = hCaster:GetAbsOrigin()
	local newItem = CreateItem("item_part_retrieval", nil, nil)--"item_present_for_search", nil, nil)

	if not newItem then
	DebugPrint('Failed to find item: ' .. itemName)
	return
	end
	newItem:SetPurchaseTime(0)
	newItem.firstPickedUp = false

	CreateItemOnPositionSync(pos, newItem)
	newItem:LaunchLoot(false, 300, 0.75, pos + RandomVector(RandomFloat(100, 150)))
	hCaster:RemoveItem(self)
end
--[[
function item_part_retrieval:OnUnequip() --Does not seem to work
	local hCaster = self:GetCaster()
	local numberOfPresents = self:GetCurrentCharges()
	local pos = hCaster:GetAbsOrigin()
	for i  = 1,numberOfPresents do
		PhaseTwo:SpawnPresent(pos,100)
	end
	hCaster:RemoveItem(self)
end
]]
function item_part_retrieval:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()
	local numberOfParts = self:GetCurrentCharges()
	if hTarget:GetUnitLabel() == "act_1_sleigh" then
		PhaseOne:PartTurnedIn(numberOfParts)
		hCaster:RemoveItem(self)
	end
end

modifier_item_part = class(ModifierBaseClass)
function modifier_item_part:OnCreated()
  self:SetStackCount(1)
  if IsServer() then self:StartIntervalThink(0.1) end
end

function modifier_item_part:OnIntervalThink()
  self:SetStackCount( self:GetAbility():GetCurrentCharges() )
end

function modifier_item_part:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
  }
  return funcs
end

function modifier_item_part:GetModifierMoveSpeedBonus_Percentage( params )
	return -20* self:GetStackCount()
end

