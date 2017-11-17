evil_wisp_moon_rain = class({})

function evil_wisp_moon_rain:OnSpellStart()
    local caster = self:GetCaster()

    self.duration = self:GetSpecialValueFor("duration")
    local searchRadius = self:GetCastRange(caster:GetAbsOrigin(), caster)
    local beamRadius = self:GetSpecialValueFor("beam_radius")
    local beamDamage = self:GetSpecialValueFor("beam_damage")
    local beamDelay = self:GetSpecialValueFor("beam_delay")

    self:SetLevel(4)

    caster:AddNewModifier(caster, self, "modifier_stunned", {duration = self.duration})
    self.internalTimer = 0
    self.distance = 150
    if self:GetLevel() == 1 then -- random moon beam spam
        self:PhaseOne(beamDelay, beamRadius, beamDamage)
    elseif self:GetLevel() == 2 then -- moon beam waves
        self:PhaseTwo(beamDelay, beamRadius, beamDamage)
    elseif self:GetLevel() == 3 then -- moon beam whirlies
        self:PhaseThree(beamDelay, beamRadius, beamDamage)
    elseif self:GetLevel() == 4 then -- two random previous moonbeam effects together
        local baseChance = 33
        if RollPercentage(33) then
            self:PhaseOne(beamDelay, beamRadius, beamDamage, true)
            if RollPercentage(50) then
                self:PhaseThree(beamDelay, beamRadius, beamDamage, true)
            else
                self:PhaseTwo(beamDelay, beamRadius, beamDamage, true)
            end
        elseif RollPercentage(33) then
            self:PhaseTwo(beamDelay, beamRadius, beamDamage, true)
            if RollPercentage(50) then
                self:PhaseOne(beamDelay, beamRadius, beamDamage, true)
            else
                self:PhaseThree(beamDelay, beamRadius, beamDamage, true)
            end
        else
            self:PhaseThree(beamDelay, beamRadius, beamDamage, true)
            if RollPercentage(50) then
                self:PhaseTwo(beamDelay, beamRadius, beamDamage, true)
            else
                self:PhaseOne(beamDelay, beamRadius, beamDamage, true)
            end
        end
    end
end

function evil_wisp_moon_rain:PhaseOne(beamDelay, beamRadius, beamDamage, bPhase4)
    local caster = self:GetCaster()
    local tick = self:GetSpecialValueFor("phase_1_tick_time")
    local searchRadius = self:GetCastRange(caster:GetAbsOrigin(), caster)
    if bPhase4 then tick = self:GetSpecialValueFor("phase_4_tick_time") end

    Timers:CreateTimer(tick, function()
        local position = caster:GetAbsOrigin() + RandomVector( RandomInt(150, searchRadius) )
        self:LaunchBeam(position, beamDelay, beamRadius, beamDamage)

        self.internalTimer = self.internalTimer + tick
        if self.internalTimer < self.duration then return tick end
    end)
end

function evil_wisp_moon_rain:PhaseTwo(beamDelay, beamRadius, beamDamage, bPhase4)
    local caster = self:GetCaster()
    local tick = self:GetSpecialValueFor("phase_2_tick_time")
    if bPhase4 then tick = self:GetSpecialValueFor("phase_4_tick_time") end
    local waveDistance = self:GetSpecialValueFor("phase_2_distance")
    local waveGap = self:GetSpecialValueFor("phase_2_gap_width")

    local initFwd = caster:GetForwardVector()
    local beamCount = 1

    Timers:CreateTimer(tick, function()
        for i = 1, 4 do
            local fwdVector = RotateVector2D(initFwd, ToRadians( 90 * (i-1) ) ):Normalized()
            local perpVec = GetPerpendicularVector(fwdVector):Normalized()

            for i = 1, beamCount do
                position = caster:GetAbsOrigin() + (fwdVector * self.distance) + (perpVec * (waveGap + beamRadius) * (i-(beamCount % 2)) * (-1)^i)
                self:LaunchBeam(position, beamDelay, beamRadius, beamDamage)
            end
        end
        beamCount = beamCount + 1
        self.internalTimer = self.internalTimer + tick
        self.distance = self.distance + waveGap + beamRadius
        if self.distance > waveDistance then
            initFwd = RandomVector(1):Normalized()
            self.distance = 150
            beamCount = 1
        end
        if self.internalTimer < self.duration then return tick end
    end)
end

function evil_wisp_moon_rain:PhaseThree(beamDelay, beamRadius, beamDamage, bPhase4)
    local caster = self:GetCaster()
    local tick = self:GetSpecialValueFor("phase_3_tick_time")
    if bPhase4 then tick = self:GetSpecialValueFor("phase_4_tick_time") end
    local angVel = self:GetSpecialValueFor("phase_3_ang_vel")
    local waveDistance = self:GetSpecialValueFor("phase_2_distance")
    local waveGap = self:GetSpecialValueFor("phase_2_gap_width")

    local initFwd = caster:GetForwardVector()
    local beamCount = 1

    Timers:CreateTimer(tick, function()
        for i = 1, 4 do
            local fwdVector = RotateVector2D(initFwd, ToRadians( 90 * (i-1) ) ):Normalized()
            local perpVec = GetPerpendicularVector(fwdVector):Normalized()

            for i = 1, beamCount do
                position = caster:GetAbsOrigin() + (fwdVector * waveGap * i)
                self:LaunchBeam(position, beamDelay, beamRadius, beamDamage)
            end
        end
        if beamCount < math.ceil(waveDistance/waveGap) then

            beamCount = beamCount + 1
        end
        initFwd = RotateVector2D(initFwd, ToRadians( angVel ) )
        self.internalTimer = self.internalTimer + tick
        if self.internalTimer < self.duration then return tick end
    end)
end

function evil_wisp_moon_rain:LaunchBeam(position, beamDelay, beamRadius, beamDamage)
    local caster = self:GetCaster()
    local warning = ParticleManager:CreateParticle("particles/act_4/io_moon_strike_team.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(warning, 0, position)
    ParticleManager:SetParticleControl(warning, 1, Vector(beamRadius,1,1) )
    EmitSoundOn("Hero_Invoker.SunStrike.Charge", caster)
    Timers:CreateTimer(beamDelay, function()
        EmitSoundOn("Hero_Invoker.SunStrike.Ignite", caster)
        ParticleManager:DestroyParticle(warning, false)
        ParticleManager:ReleaseParticleIndex(warning)
        local impact = ParticleManager:CreateParticle("particles/act_4/io_moon_strike.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(impact, 0, position)
        ParticleManager:SetParticleControl(impact, 1, Vector(beamRadius,1,1) )
        ParticleManager:ReleaseParticleIndex(impact)

        local impactTargets = FindUnitsInRadius(caster:GetTeamNumber(), position, nil, beamRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
        for _, impactTarget in ipairs(impactTargets) do
            ApplyDamage({victim = impactTarget, attacker = caster, ability = self, damage = beamDamage, damage_type = self:GetAbilityDamageType()})
        end
    end)
end




function RotateVector2D(vector, theta)
    local xp = vector.x*math.cos(theta)-vector.y*math.sin(theta)
    local yp = vector.x*math.sin(theta)+vector.y*math.cos(theta)
    return Vector(xp,yp,vector.z):Normalized()
end

function ToRadians(degrees)
    return degrees * math.pi / 180
end

function GetPerpendicularVector(vector)
    return Vector(vector.y, -vector.x)
end
