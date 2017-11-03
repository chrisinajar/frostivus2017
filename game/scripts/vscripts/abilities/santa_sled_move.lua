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
    EffectName = "",
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
  -- TODO: Make turns smoother
  --print(keys)
  for k,v in pairs(keys) do
    print(k, tostring(v))
  end

  local caster = self:GetCaster()
  local targetPosition = caster.ProjectileTarget:GetAbsOrigin()
  local distance = (targetPosition - vLocation):Length2D()
  --print(vLocation)
  caster.ProjectilePosition = vLocation

  -- Update Position
  caster:SetOrigin(GetGroundPosition(vLocation, caster))

  -- Fix Santa's ForwardVector
  local forwardVector = caster:GetForwardVector()
  local targetDirection = (targetPosition - vLocation):Normalized()
  --local smoothed = Vector(0)
  --smoothed.x = (targetDirection.x - forwardVector.x) / 100
  --smoothed.y = (targetDirection.y - forwardVector.y) / 100
  --smoothed.z = (targetDirection.z - forwardVector.z) / 100
  --print("old", forwardVector)
  --print("target", targetDirection)
  --print("diff", targetDirection - forwardVector)
  --print("smoothed", smoothed)
  caster:SetForwardVector(targetDirection)

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
