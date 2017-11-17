LinkLuaModifier("modifier_kicker_kick_movement", "abilities/kicker_kick.lua", LUA_MODIFIER_MOTION_BOTH)

kicker_kick = class(AbilityBaseClass) -- Modifier

function kicker_kick:OnSpellStart()
  local caster = self:GetCaster()
  local target = self:GetCursorTarget()
  
  target:AddNewModifier(caster, self, "modifier_kicker_kick_movement", {duration = self:GetSpecialValueFor("air_time")+0.1})
  EmitSoundOn("Hero_Tusk.WalrusKick.Target", target)
end


modifier_kicker_kick_movement = class(ModifierBaseClass)

if IsServer() then
	function modifier_kicker_kick_movement:OnCreated()
		if not self:ApplyHorizontalMotionController() then
			self:Destroy()
		end
		if not self:ApplyVerticalMotionController() then
			self:Destroy()
		end
		self.distance = self:GetAbility():GetSpecialValueFor("push_length")
		self.airTime = self:GetAbility():GetSpecialValueFor("air_time")
		self.speed = self.distance / self.airTime
		self.direction = (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
		self.initHeight = GetGroundHeight(self:GetParent():GetAbsOrigin(), self:GetParent())
		self.distanceTravelled = 0
	end
	
	
	function modifier_kicker_kick_movement:UpdateHorizontalMotion( me, dt )
		local parent = self:GetParent()
		if self.distance > self.distanceTravelled and self:GetParent():IsAlive() then
			parent:SetAbsOrigin(parent:GetAbsOrigin() + self.direction * self.speed*dt)
			self.distanceTravelled = self.distanceTravelled + self.speed*dt
		else
			parent:InterruptMotionControllers(true)
			self:Destroy()
		end       
	end

	function modifier_kicker_kick_movement:UpdateVerticalMotion( me, dt )
		local parent = self:GetParent()
		local position = parent:GetAbsOrigin()
		position.z = math.max(self.initHeight + -2*self.distanceTravelled^2/625 + 8*self.distanceTravelled/5, self.initHeight)
		parent:SetAbsOrigin( position )      
	end
end


function modifier_kicker_kick_movement:IsHidden()
	return true
end

function modifier_kicker_kick_movement:GetEffectName()
	return "particles/units/heroes/hero_tusk/tusk_walruskick_tgt.vpcf"
end

function modifier_kicker_kick_movement:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true}
end

