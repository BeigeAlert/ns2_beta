Log("Loading modified Shotgun.lua for NS2 Balance Beta mod.")

-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\Shotgun.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Balance.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/Weapons/Marine/ClipWeapon.lua")
Script.Load("lua/PickupableWeaponMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/AchievementGiverMixin.lua")
Script.Load("lua/Hitreg.lua")
Script.Load("lua/ShotgunVariantMixin.lua")

class 'Shotgun' (ClipWeapon)

Shotgun.kMapName = "shotgun"

local networkVars =
{
    emptyPoseParam = "private float (0 to 1 by 0.01)",
    timeAttackStarted = "time",
}

AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(ShotgunVariantMixin, networkVars)

-- higher numbers reduces the spread
Shotgun.kStartOffset = 0.1
Shotgun.kBulletSize = 0.016 -- not used... leave in just in case some mod uses it.

Shotgun.kDamageFalloffStart = 8 -- in meters, full damage closer than this.
Shotgun.kDamageFalloffEnd = 12 -- in meters, minimum damage further than this, gradient between start/end.
Shotgun.kDamageFalloffReductionFactor = 0.8 -- 20% reduction

local kBulletsPerShot = 0 -- calculated from rings.
Shotgun.kSpreadVectors = {}
Shotgun.kShotgunRings =
{
    { pelletCount = 1, distance = 0.0, pelletSize = 0.045, pelletDamage = 12.67 },
    { pelletCount = 5, distance = 0.5, pelletSize = 0.045, pelletDamage = 12.67 },
    { pelletCount = 7, distance = 1.5, pelletSize = 0.065, pelletDamage = 7.85 },
    
    -- Extras in case balance team wants to add more rings.  Pellet counts init to 0, so doesn't
    -- hurt to have them here.
    { pelletCount = 0, distance = 1.5, pelletSize = 0.065, pelletDamage = 7.85 },
    { pelletCount = 0, distance = 1.5, pelletSize = 0.065, pelletDamage = 7.85 },
    { pelletCount = 0, distance = 1.5, pelletSize = 0.065, pelletDamage = 7.85 },
}

local kTotalDamage = 0
for i=1, #Shotgun.kShotgunRings do
    local ring = Shotgun.kShotgunRings[i]
    kTotalDamage = kTotalDamage + ring.pelletCount * ring.pelletDamage
end

local kRingFieldNames = {"pelletCount", "distance", "pelletSize", "pelletDamage"}
local function GetAreSpreadVectorsOutdated()
    
    -- Check kShotgunSpreadDistance constant
    if kShotgunSpreadDistance ~= Shotgun.__lastKShotgunSpreadDistance then
        return true
    end
    
    -- Check the rings table.
    if Shotgun.__lastKShotgunRings == nil then
        return true -- not cached yet.
    end
    for i=1, #Shotgun.kShotgunRings do
        local ring = Shotgun.kShotgunRings[i]
        local lastRing = Shotgun.__lastKShotgunRings[i]
        for j=1, #kRingFieldNames do
            local ringFieldName = kRingFieldNames[j]
            if ring[ringFieldName] ~= lastRing[ringFieldName] then
                return true
            end
        end
    end

end

local function UpdateCachedLastValues()

    Shotgun.__lastKShotgunSpreadDistance = kShotgunSpreadDistance
    Shotgun.__lastKShotgunRings = Shotgun.__lastKShotgunRings or {} -- create if missing.
    for i=1, #Shotgun.kShotgunRings do
        Shotgun.__lastKShotgunRings[i] = Shotgun.__lastKShotgunRings[i] or {} -- create if missing.
        local ring = Shotgun.kShotgunRings[i]
        local lastRing = Shotgun.__lastKShotgunRings[i]
        for j=1, #kRingFieldNames do
            local ringFieldName = kRingFieldNames[j]
            lastRing[ringFieldName] = ring[ringFieldName]
        end
    end

end

function Shotgun._RecalculateSpreadVectors()
    
    PROFILE("Shotgun._RecalculateSpreadVectors")
    
    -- Only recalculate if we really need to.  Allow this to be lazily called from wherever
    -- Shotgun.kSpreadVectors is used, to ensure it's up-to-date.
    if not GetAreSpreadVectorsOutdated() then
        return
    end
    
    UpdateCachedLastValues() -- update cached values so we can detect changes.
    
    Shotgun.kSpreadVectors = {} -- reset
    kBulletsPerShot = 0
    
    local circle = math.pi * 2.0

    for _, ring in ipairs(Shotgun.kShotgunRings) do

        local radiansPer = circle / ring.pelletCount
        kBulletsPerShot = kBulletsPerShot + ring.pelletCount
        for pellet = 1, ring.pelletCount do

            local theta = radiansPer * (pellet - 1)
            local x = math.cos(theta) * ring.distance
            local y = math.sin(theta) * ring.distance
            table.insert(Shotgun.kSpreadVectors, { vector = GetNormalizedVector(Vector(x, y, kShotgunSpreadDistance)), size = ring.pelletSize, damage = ring.pelletDamage})

        end

    end
    
end
Shotgun._RecalculateSpreadVectors()

Shotgun.kDesiredTotalDamage = 140

Shotgun.kModelName = PrecacheAsset("models/marine/shotgun/shotgun.model")
local kViewModels = GenerateMarineViewModelPaths("shotgun")

local kShotgunFireAnimationLength = 0.8474577069282532 -- defined by art asset.
Shotgun.kFireDuration = kShotgunFireAnimationLength -- same duration for now.

local kMuzzleEffect = PrecacheAsset("cinematics/marine/shotgun/muzzle_flash.cinematic")
local kMuzzleAttachPoint = "fxnode_shotgunmuzzle"

function Shotgun:OnCreate()

    ClipWeapon.OnCreate(self)

    InitMixin(self, PickupableWeaponMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, AchievementGiverMixin)
    InitMixin(self, ShotgunVariantMixin)

    self.emptyPoseParam = 0

end

if Client then

    function Shotgun:OnInitialized()

        ClipWeapon.OnInitialized(self)

    end

end

function Shotgun:GetPrimaryMinFireDelay()
    return Shotgun.kFireDuration
end

function Shotgun:GetPickupOrigin()
    return self:GetCoords():TransformPoint(Vector(0.19319871068000793, 0.0, 0.04182741045951843))
end

function Shotgun:GetAnimationGraphName()
    return ShotgunVariantMixin.kShotgunAnimationGraph
end

function Shotgun:GetViewModelName(sex, variant)
    return kViewModels[sex][variant]
end

function Shotgun:GetDeathIconIndex()
    return kDeathMessageIcon.Shotgun
end

function Shotgun:GetHUDSlot()
    return kPrimaryWeaponSlot
end

function Shotgun:GetClipSize()
    return kShotgunClipSize
end

function Shotgun:GetBulletsPerShot()
    return kBulletsPerShot
end

function Shotgun:GetRange()
    return 100
end

-- Only play weapon effects every other bullet to avoid sonic overload
function Shotgun:GetTracerEffectFrequency()
    return 0.5
end

function Shotgun:GetBulletDamage()
    return 0 -- not used (just a required override of ClipWeapon).
end

function Shotgun:GetHasSecondary()
    return false
end

function Shotgun:GetPrimaryCanInterruptReload()
    return true
end

function Shotgun:GetWeight()
    return kShotgunWeight
end

function Shotgun:UpdateViewModelPoseParameters(viewModel)

    viewModel:SetPoseParam("empty", self.emptyPoseParam)
    
end

function Shotgun:OnUpdateAnimationInput(modelMixin)
    
    ClipWeapon.OnUpdateAnimationInput(self, modelMixin)
    
    -- TODO This is constantly recalculated for the benefit of the balance team so they can tweak it
    -- in real-time.  Eventually, this should just be computed once on load.
    local fireSpeedMult = kShotgunFireAnimationLength / math.max(Shotgun.kFireDuration, 0.01)
    modelMixin:SetAnimationInput("attack_mult", fireSpeedMult)
    
end

local function LoadBullet(self)

    if self.ammo > 0 and self.clip < self:GetClipSize() then

        self.clip = self.clip + 1
        self.ammo = self.ammo - 1

    end

end


function Shotgun:OnTag(tagName)

    PROFILE("Shotgun:OnTag")

    local continueReloading = false
    if self:GetIsReloading() and tagName == "reload_end" then

        continueReloading = true
        self.reloading = false

    end

    ClipWeapon.OnTag(self, tagName)

    if tagName == "load_shell" then
        LoadBullet(self)
    elseif tagName == "reload_shotgun_start" then
        self:TriggerEffects("shotgun_reload_start")
    elseif tagName == "reload_shotgun_shell" then
        self:TriggerEffects("shotgun_reload_shell")
    elseif tagName == "reload_shotgun_end" then
        self:TriggerEffects("shotgun_reload_end")
    end

    if continueReloading then

        local player = self:GetParent()
        if player then
            player:Reload()
        end

    end

end

-- used for last effect
function Shotgun:GetEffectParams(tableParams)
    tableParams[kEffectFilterEmpty] = self.clip == 1
end

function Shotgun:FirePrimary(player)

    local viewAngles = player:GetViewAngles()
    viewAngles.roll = NetworkRandom() * math.pi * 2

    local shootCoords = viewAngles:GetCoords()

    -- Filter ourself out of the trace so that we don't hit ourselves.
    local filter = EntityFilterTwo(player, self)
    local range = self:GetRange()
    
    -- Ensure spread vectors are up-to-date.
    Shotgun._RecalculateSpreadVectors()
    
    local numberBullets = self:GetBulletsPerShot()

    self:TriggerEffects("shotgun_attack_sound")
    self:TriggerEffects("shotgun_attack")
    
    local kDamageMult = Shotgun.kDesiredTotalDamage / kTotalDamage
    
    for bullet = 1, math.min(numberBullets, #self.kSpreadVectors) do

        if not self.kSpreadVectors[bullet] then
            break
        end

        local spreadVector = self.kSpreadVectors[bullet].vector
        local pelletSize = self.kSpreadVectors[bullet].size
        local spreadDamage = self.kSpreadVectors[bullet].damage * kDamageMult

        local spreadDirection = shootCoords:TransformVector(spreadVector)

        local startPoint = player:GetEyePos() + shootCoords.xAxis * spreadVector.x * self.kStartOffset + shootCoords.yAxis * spreadVector.y * self.kStartOffset

        local endPoint = player:GetEyePos() + spreadDirection * range

        local targets, trace, hitPoints = GetBulletTargets(startPoint, endPoint, spreadDirection, pelletSize, filter)

        HandleHitregAnalysis(player, startPoint, endPoint, trace)

        local direction = (trace.endPoint - startPoint):GetUnit()
        local hitOffset = direction * kHitEffectOffset
        local impactPoint = trace.endPoint - hitOffset
        local effectFrequency = self:GetTracerEffectFrequency()
        local showTracer = bullet % effectFrequency == 0

        local numTargets = #targets

        if numTargets == 0 then
            self:ApplyBulletGameplayEffects(player, nil, impactPoint, direction, 0, trace.surface, showTracer)
        end

        if Client and showTracer then
            TriggerFirstPersonTracer(self, impactPoint)
        end

        for i = 1, numTargets do

            local target = targets[i]
            local hitPoint = hitPoints[i]
            
            local thisTargetDamage = spreadDamage
            
            -- Apply a damage falloff for shotgun damage.
            if self.kDamageFalloffReductionFactor ~= 1.0 then
                local distance = (hitPoint - startPoint):GetLength()
                local falloffFactor = Clamp((distance - self.kDamageFalloffStart) / (self.kDamageFalloffEnd - self.kDamageFalloffStart), 0, 1)
                local nearDamage = thisTargetDamage
                local farDamage = thisTargetDamage * self.kDamageFalloffReductionFactor
                thisTargetDamage = nearDamage * (1.0 - falloffFactor) + farDamage * falloffFactor
            end
            
            self:ApplyBulletGameplayEffects(player, target, hitPoint - hitOffset, direction, thisTargetDamage, "", showTracer and i == numTargets)

            local client = Server and player:GetClient() or Client
            if not Shared.GetIsRunningPrediction() and client.hitRegEnabled then
                RegisterHitEvent(player, bullet, startPoint, trace, thisTargetDamage)
            end

        end

    end

end

function Shotgun:OnProcessMove(input)
    ClipWeapon.OnProcessMove(self, input)
    self.emptyPoseParam = Clamp(Slerp(self.emptyPoseParam, ConditionalValue(self.clip == 0, 1, 0), input.time * 1), 0, 1)
end

function Shotgun:GetAmmoPackMapName()
    return ShotgunAmmo.kMapName
end


if Client then

    function Shotgun:GetBarrelPoint()

        local player = self:GetParent()
        if player then

            local origin = player:GetEyePos()
            local viewCoords= player:GetViewCoords()

            return origin + viewCoords.zAxis * 0.4 + viewCoords.xAxis * -0.18 + viewCoords.yAxis * -0.2

        end

        return self:GetOrigin()

    end

    function Shotgun:GetUIDisplaySettings()
        return { xSize = 256, ySize = 128, script = "lua/GUIShotgunDisplay.lua", variant = self:GetShotgunVariant() }
    end

    function Shotgun:OnUpdateRender()

        ClipWeapon.OnUpdateRender( self )

        local parent = self:GetParent()
        if parent and parent:GetIsLocalPlayer() then
            local viewModel = parent:GetViewModelEntity()
            if viewModel and viewModel:GetRenderModel() then

                local clip = self:GetClip()
                local time = Shared.GetTime()

                if self.lightCount ~= clip and
                    not self.lightChangeTime or self.lightChangeTime + 0.15 < time
                then
                    self.lightCount = clip
                    self.lightChangeTime = time
                end

                viewModel:InstanceMaterials()
                viewModel:GetRenderModel():SetMaterialParameter("ammo", self.lightCount or 6 )

            end
        end
    end

end

function Shotgun:ModifyDamageTaken(damageTable, _, _, damageType)
    if damageType ~= kDamageType.Corrode then
        damageTable.damage = 0
    end
end

function Shotgun:GetCanTakeDamageOverride()
    return self:GetParent() == nil
end

function Shotgun:GetIdleAnimations(index)
    local animations = {"idle", "idle_check", "idle_clean"}
    return animations[index]
end

if Server then

    function Shotgun:GetDestroyOnKill()
        return true
    end

    function Shotgun:GetSendDeathMessageOverride()
        return false
    end

end

Shared.LinkClassToMap("Shotgun", Shotgun.kMapName, networkVars)
