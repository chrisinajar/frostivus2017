-- LinkLuaModifier( "modifier_creep_frostfang", "abilities/creep_frostfang.lua", LUA_MODIFIER_MOTION_NONE )

act1_helper_repair = class(AbilityBaseClass)

function act1_helper_repair:GetChannelTime()
  return self:GetSpecialValueFor("channel_time")
end

if IsServer() then
  function act1_helper_repair:OnChannelFinish()
    DebugPrint('Repair interval!')
  end
end
