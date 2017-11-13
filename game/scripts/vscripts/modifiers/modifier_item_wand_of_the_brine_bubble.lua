
modifier_item_wand_of_the_brine_bubble = class(ModifierBaseClass)

--------------------------------------------------------------------------------

function modifier_item_wand_of_the_brine_bubble:GetTexture()
	return "item_wand_of_the_brine"
end

--------------------------------------------------------------------------------

function modifier_item_wand_of_the_brine_bubble:OnCreated( kv )
  self.bubble_regen = self:GetAbility():GetSpecialValueFor( "bubble_regen" )

	if IsServer() then
		self.nFXIndex = ParticleManager:CreateParticle( "particles/act_2/wand_of_the_brine_bubble.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControlEnt( self.nFXIndex, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
		ParticleManager:SetParticleControl( self.nFXIndex, 1, Vector( 2.5, 2.5, 2.5 ) ) -- target model scale
		--ParticleManager:SetParticleControlEnt( self.nFXIndex, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetOrigin(), true )
		--ParticleManager:SetParticleControlEnt( self.nFXIndex, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetParent():GetOrigin(), true )
		--ParticleManager:SetParticleControlEnt( self.nFXIndex, 4, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetOrigin(), true )
	end
end

--------------------------------------------------------------------------------

function modifier_item_wand_of_the_brine_bubble:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
  }
end

--------------------------------------------------------------------------------

function modifier_item_wand_of_the_brine_bubble:GetModifierConstantHealthRegen(keys)
	return self.bubble_regen
end

--------------------------------------------------------------------------------

function modifier_item_wand_of_the_brine_bubble:CheckState()
	local state = {}
	if IsServer()  then
		state[ MODIFIER_STATE_STUNNED]  = true
		state[ MODIFIER_STATE_ROOTED ] = true
		state[ MODIFIER_STATE_DISARMED] = true
		state[ MODIFIER_STATE_OUT_OF_GAME ] = true
		state[ MODIFIER_STATE_MAGIC_IMMUNE ] = true
		state[ MODIFIER_STATE_INVULNERABLE ] = true
		state[ MODIFIER_STATE_OUT_OF_GAME ] = true
		state[ MODIFIER_STATE_UNSELECTABLE ] = true
	end

	return state
end

--------------------------------------------------------------------------------

function modifier_item_wand_of_the_brine_bubble:OnDestroy()
	if IsServer()  then
		ParticleManager:DestroyParticle( self.nFXIndex, false )
	end
end

--------------------------------------------------------------------------------

