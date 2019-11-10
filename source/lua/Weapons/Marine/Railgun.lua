Log("Loading modified Railgun.lua for NS2 Balance Beta mod.")

-- Changes:
-- Both railguns can be fired simultaneously now.
-- Changed how damage works with railguns:
--      Can be rapid fired with a rapid cooldown, for normal-type damage, with a damage depending on
--          how long it was charged for.  Does not penetrate targets.
--      Can also be charged up for a longer time to penetrate targets for a heavy-type damage.

-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\Weapons\Marine\Railgun.lua
--
--    Created by:   Brian Cronin (brianc@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/BulletsMixin.lua")
Script.Load("lua/Weapons/Marine/ExoWeaponSlotMixin.lua")
Script.Load("lua/TechMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/AchievementGiverMixin.lua")
Script.Load("lua/EffectsMixin.lua")
Script.Load("lua/Weapons/ClientWeaponEffectsMixin.lua")

class 'Railgun' (Entity)

Railgun.kMapName = "railgun"

Railgun.kRange = 400
Railgun.kBulletSize = 0.3

-- Time between shooting and being able to start charging again.
Railgun.kCooldownTime = 0.3

-- Time it takes to perform a max-power charged shot.
-- Maaaax powwerrrrrrr
-- He's the man whose name you'd love to touch...
-- But you mustn't touch
-- His name sounds good in your ear
-- But when you say it, you mustn't fear...
-- 'cause his name can be said by anyone...
Railgun.kChargeTimeForMaxPower = 1.0

-- Extra time after reaching max power before the shot is forced to be released.
Railgun.kForceFireTime = 0.5

Railgun.kMinPowerDamage = 25
Railgun.kMaxPowerDamage = 60

Railgun.kTapShotDamageType = kDamageType.Normal
Railgun.kChargedShotDamageType = kDamageType.Heavy

Railgun.kChargedShotChargeThreshold = 0.75 -- shot is "charged" when @ 75% charge or higher.

Railgun.kFireAnimationLength = 1.5 -- from art asset.

local kChargeSound = PrecacheAsset("sound/NS2.fev/marine/heavy/railgun_charge")

PrecacheAsset("cinematics/vfx_materials/alien_frag.surface_shader")
PrecacheAsset("cinematics/vfx_materials/decals/railgun_hole.surface_shader")

local networkVars =
{
    timeChargeStarted = "time",
    railgunAttacking = "boolean",
    lockCharging = "boolean",
    timeOfLastShot = "time"
}

AddMixinNetworkVars(TechMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(ExoWeaponSlotMixin, networkVars)

function Railgun:OnCreate()

    Entity.OnCreate(self)
    
    InitMixin(self, TechMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, BulletsMixin)
    InitMixin(self, ExoWeaponSlotMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, AchievementGiverMixin)
    InitMixin(self, EffectsMixin)
    
    self.timeChargeStarted = 0
    self.railgunAttacking = false
    self.lockCharging = false
    self.timeOfLastShot = 0
    self.damageType = Railgun.kTapShotDamageType
    
    if Client then
    
        InitMixin(self, ClientWeaponEffectsMixin)
        self.chargeSound = Client.CreateSoundEffect(Shared.GetSoundIndex(kChargeSound))
        self.chargeSound:SetParent(self:GetId())
        
    end

end

function Railgun:OnDestroy()

    Entity.OnDestroy(self)
    
    if self.chargeSound then
    
        Client.DestroySoundEffect(self.chargeSound)
        self.chargeSound = nil
        
    end
    
    if self.chargeDisplayUI then
    
        Client.DestroyGUIView(self.chargeDisplayUI)
        self.chargeDisplayUI = nil
        
    end
    
end

function Railgun:OnPrimaryAttack(player)
    
    if self.timeOfLastShot + Railgun.kCooldownTime <= Shared.GetTime() then

        if not self.railgunAttacking then
            self.timeChargeStarted = Shared.GetTime()
        end
        self.railgunAttacking = true
        
    end
    
end

function Railgun:GetIsThrusterAllowed()
    return not self.railgunAttacking
end

function Railgun:GetWeight()
    return kRailgunWeight
end

function Railgun:OnPrimaryAttackEnd(player)
    self.railgunAttacking = false
end

function Railgun:GetBarrelPoint()

    local player = self:GetParent()
    if player then
    
        if player:GetIsLocalPlayer() then
        
            local origin = player:GetEyePos()
            local viewCoords = player:GetViewCoords()
            
            if self:GetIsLeftSlot() then
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * 0.65 + viewCoords.yAxis * -0.19
            else
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * -0.65 + viewCoords.yAxis * -0.19
            end    
        
        else
    
            local origin = player:GetEyePos()
            local viewCoords = player:GetViewCoords()
            
            if self:GetIsLeftSlot() then
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * 0.35 + viewCoords.yAxis * -0.15
            else
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * -0.35 + viewCoords.yAxis * -0.15
            end
            
        end    
        
    end
    
    return (self:GetOrigin())
    
end

function Railgun:GetTracerEffectName()
    return kRailgunTracerEffectName
end

function Railgun:GetTracerResidueEffectName()
    return kRailgunTracerResidueEffectName
end

function Railgun:GetTracerEffectFrequency()
    return 1
end

function Railgun:GetDeathIconIndex()
    return kDeathMessageIcon.Railgun
end

function Railgun:GetChargeAmount()
    return self.railgunAttacking and math.min(1, (Shared.GetTime() - self.timeChargeStarted) / Railgun.kChargeTimeForMaxPower) or 0
end

local function TriggerSteamEffect(self, player)

    if self:GetIsLeftSlot() then
        player:TriggerEffects("railgun_steam_left")
    elseif self:GetIsRightSlot() then
        player:TriggerEffects("railgun_steam_right")
    end
    
end

function Railgun:GetIsAffectedByWeaponUpgrades()
    return true
end

function Railgun:GetDamageType()
    return self.damageType
end

local function ExecuteShot(self, startPoint, endPoint, player)

    -- Filter ourself out of the trace so that we don't hit ourselves.
    local filter = EntityFilterTwo(player, self)
    local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterAllButIsa("Tunnel"))
    local hitPointOffset = trace.normal * 0.3
    local direction = (endPoint - startPoint):GetUnit()
    
    local chargeDuration = Shared.GetTime() - self.timeChargeStarted
    local chargeFraction = Clamp(chargeDuration / Railgun.kChargeTimeForMaxPower, 0, 1)
    
    local damage = chargeFraction * (Railgun.kMaxPowerDamage - Railgun.kMinPowerDamage) + Railgun.kMinPowerDamage
    local chargedShot
    if chargeFraction >= Railgun.kChargedShotChargeThreshold then
        self.damageType = Railgun.kChargedShotDamageType
        chargedShot = true
    else
        self.damageType = Railgun.kTapShotDamageType
        chargedShot = false
    end
    
    local extents = GetDirectedExtentsForDiameter(direction, Railgun.kBulletSize)
    local maxTargetsHit = chargedShot and 20 or 1
    if trace.fraction < 1 then
        
        -- 20 traces should be enough...
        local hitEntities = {}
        for i = 1, 20 do
    
            if maxTargetsHit <= 0 then -- hit enough targets.
                break
            end
            
            local capsuleTrace = Shared.TraceBox(extents, startPoint, trace.endPoint, CollisionRep.Damage, PhysicsMask.Bullets, filter)
            if capsuleTrace.entity then
            
                if not table.find(hitEntities, capsuleTrace.entity) then
                
                    table.insert(hitEntities, capsuleTrace.entity)
                    self:DoDamage(damage, capsuleTrace.entity, capsuleTrace.endPoint + hitPointOffset, direction, capsuleTrace.surface, false, false)
    
                    maxTargetsHit = maxTargetsHit - 1
                
                end
                
            end    
                
            if (capsuleTrace.endPoint - trace.endPoint):GetLength() <= extents.x then
                break
            end
            
            -- use new start point
            startPoint = Vector(capsuleTrace.endPoint) + direction * extents.x * 3
        
        end
    
        -- Only show weapon tracer and steam effects if shot was a "charged shot".
        if chargedShot then
            self:DoDamage(0, nil, trace.endPoint + hitPointOffset, direction, trace.surface, false, true)
            if Client then
                TriggerFirstPersonTracer(self, trace.endPoint)
                TriggerSteamEffect(self, player)
            end
        end
    
    end
    
end

function Railgun:LockGun()
    self.timeOfLastShot = Shared.GetTime()
end

local function Shoot(self, leftSide)

    local player = self:GetParent()
    
    -- We can get a shoot tag even when the clip is empty if the frame rate is low
    -- and the animation loops before we have time to change the state.
    if player then
    
        player:TriggerEffects("railgun_attack")
        
        local viewAngles = player:GetViewAngles()
        local shootCoords = viewAngles:GetCoords()
        
        local startPoint = player:GetEyePos()
        
        local spreadDirection = CalculateSpread(shootCoords, 0, NetworkRandom)
        
        local endPoint = startPoint + spreadDirection * Railgun.kRange
        ExecuteShot(self, startPoint, endPoint, player)
        
        self:LockGun()
        self.lockCharging = true
        
    end
    
end

if Server then

    function Railgun:OnParentKilled(attacker, doer, point, direction)
    end
    
    -- 
    -- The Railgun explodes players. We must bypass the ragdoll here.
    -- 
    function Railgun:OnDamageDone(doer, target)
    
        if doer == self then
        
            if target:isa("Player") and not target:GetIsAlive() then
                target:SetBypassRagdoll(true)
            end
            
        end
        
    end
    
end

function Railgun:ProcessMoveOnWeapon(player, input)

    if self.railgunAttacking then
    
        if (Shared.GetTime() - self.timeChargeStarted) >= Railgun.kChargeTimeForMaxPower + Railgun.kForceFireTime then
            self.railgunAttacking = false
        end
        
    end
    
end

function Railgun:OnUpdateRender()

    PROFILE("Railgun:OnUpdateRender")
    
    local chargeAmount = self:GetChargeAmount()
    local parent = self:GetParent()
    if parent and parent:GetIsLocalPlayer() then
    
        local viewModel = parent:GetViewModelEntity()
        if viewModel and viewModel:GetRenderModel() then
        
            viewModel:InstanceMaterials()
            local renderModel = viewModel:GetRenderModel()
            renderModel:SetMaterialParameter("chargeAmount" .. self:GetExoWeaponSlotName(), chargeAmount)
            renderModel:SetMaterialParameter("timeSinceLastShot" .. self:GetExoWeaponSlotName(), Shared.GetTime() - self.timeOfLastShot)
            
        end
        
        local chargeDisplayUI = self.chargeDisplayUI
        if not chargeDisplayUI then
        
            chargeDisplayUI = Client.CreateGUIView(246, 256)
            chargeDisplayUI:Load("lua/GUI" .. self:GetExoWeaponSlotName():gsub("^%l", string.upper) .. "RailgunDisplay.lua")
            chargeDisplayUI:SetTargetTexture("*exo_railgun_" .. self:GetExoWeaponSlotName())
            self.chargeDisplayUI = chargeDisplayUI
            
        end
        
        chargeDisplayUI:SetGlobal("chargeAmount" .. self:GetExoWeaponSlotName(), chargeAmount)
        chargeDisplayUI:SetGlobal("timeSinceLastShot" .. self:GetExoWeaponSlotName(), Shared.GetTime() - self.timeOfLastShot)
        
    else
    
        if self.chargeDisplayUI then
        
            Client.DestroyGUIView(self.chargeDisplayUI)
            self.chargeDisplayUI = nil
            
        end
        
    end
    
    if self.chargeSound then
    
        local playing = self.chargeSound:GetIsPlaying()
        if not playing and chargeAmount > 0 then
            self.chargeSound:Start()
        elseif playing and chargeAmount <= 0 then
            self.chargeSound:Stop()
        end
        
        self.chargeSound:SetParameter("charge", chargeAmount, 1)
        
    end
    
end

function Railgun:OnTag(tagName)

    PROFILE("Railgun:OnTag")
    
    if self:GetIsLeftSlot() then
    
        if tagName == "l_shoot" then
            Shoot(self, true)
        elseif tagName == "l_shoot_end" then
            self.lockCharging = false
        end
        
    elseif not self:GetIsLeftSlot() then
    
        if tagName == "r_shoot" then
            Shoot(self, false)
        elseif tagName == "r_shoot_end" then
            self.lockCharging = false
        end
        
    end
    
end

function Railgun:OnUpdateAnimationInput(modelMixin)

    local activity = "none"
    if self.railgunAttacking then
        activity = "primary"
    end
    modelMixin:SetAnimationInput("activity_" .. self:GetExoWeaponSlotName(), activity)
    
    -- TODO set this once.  We're calculating it every frame here so the balance team can tweak the
    -- values on-the-fly.
    modelMixin:SetAnimationInput("fire_speed", Railgun.kFireAnimationLength / Railgun.kCooldownTime)
    
end

function Railgun:UpdateViewModelPoseParameters(viewModel)

    local chargeParam = "charge_" .. (self:GetIsLeftSlot() and "l" or "r")
    local chargeAmount = self:GetChargeAmount()
    viewModel:SetPoseParam(chargeParam, chargeAmount)
    
end

if Client then

    local kRailgunMuzzleEffectRate = 0.5
    local kAttachPoints = { [ExoWeaponHolder.kSlotNames.Left] = "fxnode_l_railgun_muzzle", [ExoWeaponHolder.kSlotNames.Right] = "fxnode_r_railgun_muzzle" }
    local kMuzzleEffectName = PrecacheAsset("cinematics/marine/railgun/muzzle_flash.cinematic")

    function Railgun:OnClientPrimaryAttackEnd()
    
        local parent = self:GetParent()
        
        if parent then
            CreateMuzzleCinematic(self, kMuzzleEffectName, kMuzzleEffectName, kAttachPoints[self:GetExoWeaponSlot()] , parent)
        end
        
    end
    
    function Railgun:GetSecondaryAttacking()
        return false
    end
    
    function Railgun:GetIsActive()
        return true
    end    
    
    function Railgun:GetPrimaryAttacking()
        return self.railgunAttacking
    end
    
    function Railgun:OnProcessMove(input)
    
        Entity.OnProcessMove(self, input)
        
        local player = self:GetParent()
        
        if player then
    
            -- trace and highlight first target
            local filter = EntityFilterAllButMixin("RailgunTarget")
            local startPoint = player:GetEyePos()
            local endPoint = startPoint + player:GetViewCoords().zAxis * Railgun.kRange
            local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterAllButIsa("Tunnel"))
            local direction = (endPoint - startPoint):GetUnit()
            
            local extents = GetDirectedExtentsForDiameter(direction, Railgun.kBulletSize)
            
            self.railgunTargetId = nil
            
            if trace.fraction < 1 then

                for i = 1, 20 do
                
                    local capsuleTrace = Shared.TraceBox(extents, startPoint, trace.endPoint, CollisionRep.Damage, PhysicsMask.Bullets, filter)
                    if capsuleTrace.entity then
                    
                        capsuleTrace.entity:SetRailgunTarget()
                        self.railgunTargetId = capsuleTrace.entity:GetId()
                        break
                        
                    end    
                
                end
            
            end
        
        end
    
    end
    
    function Railgun:GetTargetId()
        return self.railgunTargetId
    end
    
end

Shared.LinkClassToMap("Railgun", Railgun.kMapName, networkVars)