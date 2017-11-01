santa_sled_move = class(AbilityBaseClass)

function santa_sled_move:OnSpellStart()
  local caster = self:GetCaster()
  self:CreateProjectile(caster.ProjectileSpawnLocation)
end

function santa_sled_move:CreateProjectile(vSourceLoc)
  local caster = self:GetCaster()
  ProjectileManager:CreateTrackingProjectile({
    Target = caster.ProjectileTarget,
    Source = caster,
    Ability = self,
    EffectName = "particles/econ/items/mirana/mirana_crescent_arrow/mirana_spell_crescent_arrow.vpcf",
    iMoveSpeed = caster.BaseSpeed,
    vSourceLoc = vSourceLoc,                          -- Optional (HOW)
    bDrawsOnMinimap = false,                          -- Optional
    bDodgeable = true,                                -- Optional
    bIsAttack = false,                                -- Optional
    bVisibleToEnemies = true,                         -- Optional
    bReplaceExisting = true,                          -- Optional
    flExpireTime = GameRules:GetGameTime() + 3600,    -- Optional but recommended
    bProvidesVision = true,                           -- Optional
    iVisionRadius = 400,                              -- Optional
    iVisionTeamNumber = DOTA_TEAM_GOODGUYS            -- Optional
  })
end

function santa_sled_move:OnProjectileThink_ExtraData(vLocation, keys)
  for k,v in pairs(keys) do
    print(k, tostring(v))
  end
  local caster = self:GetCaster()
  local distance = (caster.ProjectileTarget:GetAbsOrigin() - vLocation):Length2D()
  --print(vLocation)
  caster.ProjectilePosition = vLocation

  -- Update Position
  caster:SetOrigin(GetGroundPosition(vLocation, caster))

  -- TODO: Fix Santa's ForwardVector

  -- Make sure the Projectile doesn't hit it's Target
  local speed = caster.Speed or caster.BaseSpeed
  if distance <= 200 then
    --print("Reducing Movement Speed")
    speed = speed * (distance / 250)
  end
  if speed < caster.BaseSpeed then speed = caster.BaseSpeed end
  ProjectileManager:ChangeTrackingProjectileSpeed(self, speed)
end

function santa_sled_move:OnProjectileHit(hTarget, vLocation)
  print("Creating new Projectile")
  self:CreateProjectile(vLocation)
end
