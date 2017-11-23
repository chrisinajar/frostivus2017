santa_act3_throw_right = class({})

--------------------------------------------------------------------------------

function santa_act3_throw_right:OnSpellStart()
	local caster = self:GetCaster()

	caster:RemoveGesture( ACT_DOTA_CAST_ABILITY_1 )
	caster:StartGestureWithPlaybackRate( ACT_DOTA_CAST_ABILITY_1, 1.3)
	--caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)

	Timers:CreateTimer(1.4, function ()
		local cartPos = caster:GetAbsOrigin()
		local throwPos = santa_act3_throw_right:GlobalVectorFromLocal(Vector(100, -600, 0), caster)
		local newItem = CreateItem("item_present_for_search", caster, caster)--"item_present_for_search", nil, nil)

		if not newItem then
		DebugPrint('Failed to find item: ' .. itemName)
		return
		end
		newItem:SetPurchaseTime(0)
		newItem.firstPickedUp = false

		CreateItemOnPositionSync(cartPos, newItem)
		newItem:LaunchLoot(false, 300, 1.0, throwPos)

		Timers:CreateTimer(1.1, function ()
			-- check if safe to destroy
			if IsValidEntity(newItem) then
			  if newItem:GetContainer() ~= nil then
			    newItem:GetContainer():RemoveSelf()
			  end
			end
		end)
	end)
end

-- Converts a vector local to an entity into a world space vector.
--
-- Example: Get a vector 32 units in front of a player.
-- GlobalVectorFromLocal(Vector(32, 0, 0), myPlayerEntity)
--
function santa_act3_throw_right:GlobalVectorFromLocal(localVec, entity)
 
	-- Here RotatePosition() converts the local space vector into a world space offset from the entity
	-- by rotating it by the entity orentation.
	local offset = RotatePosition(Vector(0, 0, 0), entity:GetAngles(), localVec)
 
	return entity:GetOrigin() + offset
 
end
