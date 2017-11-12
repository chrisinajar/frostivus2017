
PassiveXP = PassiveXP or class({})

function PassiveXP:Init()
  self.seconds = 0
  self.minute = 1
  Timers:CreateTimer(1, function()
    self.seconds = self.seconds + 1
    if self.seconds >= 60 then
      self.minute = self.minute + 1
      self.seconds = self.seconds - 60
    end
    self:EverySecond()

    return 1
  end)
end

function PassiveXP:EverySecond()
  local allHeroes = map(partial(PlayerResource.GetSelectedHeroEntity, PlayerResource), PlayerResource:GetAllTeamPlayerIDs())
  local xpps = (1/600 * ((45 * self.minute * self.minute) + 67 * self.minute + 2450))

  allHeroes:each(function (hero)
    if hero:IsNull() then
      return
    end
    if hero:GetLevel() > 25 then
      return
    end
    hero:AddExperience(xpps, 0, false, false)
  end)
end
