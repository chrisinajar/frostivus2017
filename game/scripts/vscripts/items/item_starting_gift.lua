item_starting_gift = class(ItemBaseClass)

--------------------------------------------------------------------------------

function item_starting_gift:OnSpellStart()
	local caster = self:GetCaster()
	caster:RemoveItem(self)

	caster:AddItemByName("item_boots")

	if RollPercentage(50) then
		caster:AddItemByName("item_flask")
	else
		caster:AddItemByName("item_tango")
	end

	if RollPercentage(50) then
		caster:AddItemByName("item_clarity")
		caster:AddItemByName("item_faerie_fire")
	else
		caster:AddItemByName("item_enchanted_mango")
	end

	if caster:GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH then
		caster:AddItemByName("item_bracer")
	elseif caster:GetPrimaryAttribute() == DOTA_ATTRIBUTE_AGILITY then
		caster:AddItemByName("item_wraith_band")
	elseif caster:GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT then
		caster:AddItemByName("item_null_talisman")
	end

	local randomInt = RandomInt(1,100)
	if randomInt < 20 then
		caster:AddItemByName("item_orb_of_venom")
	elseif randomInt < 40 then
		caster:AddItemByName("item_blight_stone")
	elseif randomInt < 60 then
		caster:AddItemByName("item_infused_raindrop")
	elseif randomInt < 80 then
		caster:AddItemByName("item_ring_of_regen")
	else
		caster:AddItemByName("item_wind_lace")
	end

end
