Log("Loading modified Minigun.lua for NS2 Balance Beta mod.")

-- Changes:
-- Changed the heat and cooldown rates to be members of Minigun so they can be edited on the fly.
-- Moved spin-up and spin-down sounds into OnTag and made them activate with animation tags, rather
--      than when the user tries to start/stop attacking to sync up with the visuals correctly
--      (otherwise, overheating can cause the visuals to not sync up correctly).
-- Overheating exo weapons' cooldown duration is now directly tied to the animation-length, not the
--      heat meter (since the animation was the limiting factor before anyways).  Now, the miniguns
--      can be fired again as soon as the overheat animation finishes... which defaults to being
--      longer than it takes for the heat to reach 0 anyways.

-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\Weapons\Marine\Minigun.lua
--
--    Created by:   Brian Cronin (brianc@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/BulletsMixin.lua")
Script.Load("lua/Weapons/Marine/ExoWeaponSlotMixin.lua")
Script.Load("lua/TechMixin.lua")
Script.Load("lua/Weapons/ClientWeaponEffectsMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/AchievementGiverMixin.lua")

class 'Minigun' (Entity)

Minigun.kMapName = "minigun"

local kSpinUpSoundNames = { [ExoWeaponHolder.kSlotNames.Left] = PrecacheAsset("sound/NS2.fev/marine/heavy/spin_up_2"),
                            [ExoWeaponHolder.kSlotNames.Right] = PrecacheAsset("sound/NS2.fev/marine/heavy/spin_up") }

local kSpinDownSoundNames = { [ExoWeaponHolder.kSlotNames.Left] = PrecacheAsset("sound/NS2.fev/marine/heavy/spin_down_2"),
                              [ExoWeaponHolder.kSlotNames.Right] = PrecacheAsset("sound/NS2.fev/marine/heavy/spin_down") }

local kSpinSoundNames = { [ExoWeaponHolder.kSlotNames.Left] = PrecacheAsset("sound/NS2.fev/marine/heavy/spin_2"),
                          [ExoWeaponHolder.kSlotNames.Right] = PrecacheAsset("sound/NS2.fev/marine/heavy/spin") }

local kSpinTailSoundNames = { [ExoWeaponHolder.kSlotNames.Left] = PrecacheAsset("sound/NS2.fev/marine/heavy/tail_2"),
                              [ExoWeaponHolder.kSlotNames.Right] = PrecacheAsset("sound/NS2.fev/marine/heavy/tail") }

--local kHeatUISoundName = PrecacheAsset("sound/NS2.fev/marine/heavy/heat_UI")
local kOverheatedSoundName = PrecacheAsset("sound/NS2.fev/marine/heavy/overheated")

PrecacheAsset("shaders/ExoMinigunView.surface_shader")

local kOverheatEffect = PrecacheAsset("cinematics/marine/minigun/overheat.cinematic")

-- Trigger on the client based on the "shooting" variable below.
local kShellsCinematics = { [ExoWeaponHolder.kSlotNames.Left] = PrecacheAsset("cinematics/marine/minigun/mm_left_shell.cinematic"),
                            [ExoWeaponHolder.kSlotNames.Right] = PrecacheAsset("cinematics/marine/minigun/mm_shell.cinematic") }
local kShellsAttachPoints = { [ExoWeaponHolder.kSlotNames.Left] = "Exosuit_LElbow",
                              [ExoWeaponHolder.kSlotNames.Right] = "Exosuit_RElbow" }

local kMinigunRange = 400
local kMinigunSpread = Math.Radians(5)


local kBulletSize = 0.03

Minigun.kHeatUpRate = 0.3
Minigun.kCoolDownRate = 0.4

Minigun.kOverheatAnimationBaseLength = 1.1666666269302368 -- from the art asset.
Minigun.kOverheatDuration = 2.0 -- desired overheat length.

-- Scale down the heat UI  so we avoid some aliasing artifacts.  Since the GUIView textures don't
-- generate miplevels, we need to be careful about how high we set the resolution of these things.
local heatUIScaleFactor = 0.25

local networkVars =
{
    minigunAttacking = "private boolean",
    shooting = "boolean",
    heatAmount = "float (0 to 1 by 0.01)",
    overheated = "private boolean",
    spinSoundId = "entityid",
    --heatUISoundId = "private entityid"
}

AddMixinNetworkVars(TechMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(ExoWeaponSlotMixin, networkVars)

function Minigun:OnCreate()

    Entity.OnCreate(self)
    
    InitMixin(self, TechMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, BulletsMixin)
    InitMixin(self, ExoWeaponSlotMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, AchievementGiverMixin)

    self.minigunAttacking = false
    self.shooting = false
    self.heatAmount = 0
    self.overheated = false
    
    if Client then
        InitMixin(self, ClientWeaponEffectsMixin)
    end
    
end

function Minigun:OnInitialized()

    if Client then
    
        local attachPointName = kShellsAttachPoints[self:GetExoWeaponSlot()]
        local cinematicName = kShellsCinematics[self:GetExoWeaponSlot()]
        if attachPointName and cinematicName then
        
            self.shellsCinematic = Client.CreateCinematic(RenderScene.Zone_Default)
            self.shellsCinematic:SetCinematic(cinematicName)
            self.shellsCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
            self.shellsCinematic:SetParent(self:GetParent())
            self.shellsCinematic:SetCoords(Coords.GetIdentity())
            self.shellsCinematic:SetAttachPoint(self:GetParent():GetAttachPointIndex(attachPointName))
            self.shellsCinematic:SetIsActive(false)
            
        end
        
    end
    
end

function Minigun:OnDestroy()

    Entity.OnDestroy(self)
    
    if self.shellsCinematic then
    
        Client.DestroyCinematic(self.shellsCinematic)
        self.shellsCinematic = nil
        
    end
    
    if self.heatDisplayUI then
    
        Client.DestroyGUIView(self.heatDisplayUI)
        self.heatDisplayUI = nil
        
    end
    
end

function Minigun:GetIsThrusterAllowed()
    return true
end

function Minigun:OnWeaponSlotAssigned(slot)

    assert(Server)
    
    self.spinSound = Server.CreateEntity(SoundEffect.kMapName)
    self.spinSound:SetAsset(kSpinSoundNames[slot])
    self.spinSound:SetParent(self)
    self.spinSoundId = self.spinSound:GetId()
    
    --[[
    self.heatUISound = Server.CreateEntity(SoundEffect.kMapName)
    self.heatUISound:SetAsset(kHeatUISoundName)
    self.heatUISound:SetParent(self)
    self.heatUISound:Start()
    self.heatUISoundId = self.heatUISound:GetId()
    --]]
end

function Minigun:ConstrainMoveVelocity(moveVelocity)

    if self.minigunAttacking then
    
        moveVelocity.x = moveVelocity.x / 3
        moveVelocity.z = moveVelocity.z / 3
        
    end
    
end

function Minigun:OnPrimaryAttack(player)
    self.minigunAttacking = true
end

function Minigun:OnPrimaryAttackEnd(player)

    if self.minigunAttacking then
    
        if Server then
        
            if self.shooting then
                StartSoundEffectOnEntity(kSpinTailSoundNames[self:GetExoWeaponSlot()], self)
            end
            
            if self.spinSound:GetIsPlaying() then
                self.spinSound:Stop()
            end
            
        end
        
        self.shooting = false
        
    end
    
    self.minigunAttacking = false
    
end

function Minigun:GetBarrelPoint()

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
    
    return self:GetOrigin()
    
end

function Minigun:GetTracerEffectName()
    return kMinigunTracerEffectName
end

function Minigun:GetTracerEffectFrequency()
    return 1
end

function Minigun:GetIsAffectedByWeaponUpgrades()
    return true
end 

function Minigun:GetDeathIconIndex()
    return kDeathMessageIcon.Minigun
end

function Minigun:GetWeight()
    return kMinigunWeight
end

-- TODO: we should use clip weapons provided functionality here (or create a more general solution which distincts between melee, hitscan and projectile only)!
local function Shoot(self, leftSide)

    local player = self:GetParent()
    
    -- We can get a shoot tag even when the clip is empty if the frame rate is low
    -- and the animation loops before we have time to change the state.
    if self.minigunAttacking and not self.overheated and player then
    
        if Server and not self.spinSound:GetIsPlaying() then
            self.spinSound:Start()
        end    
    
        local viewAngles = player:GetViewAngles()
        local shootCoords = viewAngles:GetCoords()
        
        -- Filter ourself out of the trace so that we don't hit ourselves.
        local filter = EntityFilterTwo(player, self)
        local startPoint = player:GetEyePos()
        
        local spreadDirection = CalculateSpread(shootCoords, kMinigunSpread, NetworkRandom)
        
        local range = kMinigunRange
        
        local endPoint = startPoint + spreadDirection * range
        
        local targets, trace, hitPoints = GetBulletTargets(startPoint, endPoint, spreadDirection, kBulletSize, filter) 
        
        local direction = (trace.endPoint - startPoint):GetUnit()
        local hitOffset = direction * kHitEffectOffset
        local impactPoint = trace.endPoint - hitOffset
        local surfaceName = trace.surface
        local effectFrequency = self:GetTracerEffectFrequency()
        local showTracer = (math.random() < effectFrequency)
        
        local numTargets = #targets
        
        if numTargets == 0 then
            self:ApplyBulletGameplayEffects(player, nil, impactPoint, direction, 0, trace.surface, showTracer)
        end
        
        if Client and showTracer then
            TriggerFirstPersonTracer(self, trace.endPoint)
        end
        
        for i = 1, numTargets do

            local target = targets[i]
            local hitPoint = hitPoints[i]

            self:ApplyBulletGameplayEffects(player, target, hitPoint - hitOffset, direction, kMinigunDamage, "", showTracer and i == numTargets)
            
            local client = Server and player:GetClient() or Client
            if not Shared.GetIsRunningPrediction() and client.hitRegEnabled then
                RegisterHitEvent(player, bullet, startPoint, trace, damage)
            end
        
        end
        
        self.shooting = true
        
    end
    
end

local function UpdateOverheated(self, player)

    if not self.overheated and self.heatAmount == 1 then
    
        self.overheated = true
        self:OnPrimaryAttackEnd(player)
        
        if self:GetIsLeftSlot() then
            player:TriggerEffects("minigun_overheated_left")
        elseif self:GetIsRightSlot() then    
            player:TriggerEffects("minigun_overheated_right")
        end    
        
        StartSoundEffectForPlayer(kOverheatedSoundName, player)
        
    end
    
end

function Minigun:AddHeat(amount)
    self.heatAmount = self.heatAmount + amount
end

function Minigun:ProcessMoveOnWeapon(player, input)

    local dt = input.time
    local addAmount = self.shooting and (dt * Minigun.kHeatUpRate) or -(dt * Minigun.kCoolDownRate)
    self.heatAmount = math.min(1, math.max(0, self.heatAmount + addAmount))
    
    UpdateOverheated(self, player)  
    
    if Client and not Shared.GetIsRunningPrediction() then
    
        local spinSound = Shared.GetEntity(self.spinSoundId)
        spinSound:SetParameter("heat", self.heatAmount, 1)
        
        --[[
        if player:GetIsLocalPlayer() then
        
            local heatUISound = Shared.GetEntity(self.heatUISoundId)
            if heatUISound then
                heatUISound:SetParameter("heat", self.heatAmount, 1)
            end
            
        end
        --]]
    end
    
end

function Minigun:OnUpdateRender()

    PROFILE("Minigun:OnUpdateRender")

    local parent = self:GetParent()
    if parent and parent:GetIsLocalPlayer() then
    
        local viewModel = parent:GetViewModelEntity()
        if viewModel and viewModel:GetRenderModel() then
        
            viewModel:InstanceMaterials()
            viewModel:GetRenderModel():SetMaterialParameter("heatAmount" .. self:GetExoWeaponSlotName(), self.heatAmount)
            
        end
        
        local heatDisplayUI = self.heatDisplayUI
        if not heatDisplayUI then
        
            heatDisplayUI = Client.CreateGUIView(242 * heatUIScaleFactor, 720 * heatUIScaleFactor)
            
            heatDisplayUI:Load("lua/GUI" .. self:GetExoWeaponSlotName():gsub("^%l", string.upper) .. "MinigunDisplay.lua")
            heatDisplayUI:SetTargetTexture("*exo_minigun_" .. self:GetExoWeaponSlotName())
            self.heatDisplayUI = heatDisplayUI
            heatDisplayUI:SetGlobal("scaleFactor", heatUIScaleFactor)
        end
        
        heatDisplayUI:SetGlobal("heatAmount" .. self:GetExoWeaponSlotName(), self.heatAmount)
        
    else
    
        if self.heatDisplayUI then
        
            Client.DestroyGUIView(self.heatDisplayUI)
            self.heatDisplayUI = nil
            
        end
        
    end
    
    if self.shellsCinematic then
        self.shellsCinematic:SetIsActive(self.shooting)
    end
    
end

if Server then

    function Minigun:OnParentKilled(attacker, doer, point, direction)
    
        self.spinSound:Stop()
        --self.heatUISound:Stop()
        self.shooting = false
        
    end
    
end

function Minigun:OnTag(tagName)
    
    PROFILE("Minigun:OnTag")
    
    if self:GetIsLeftSlot() and tagName == "l_shoot" then
        Shoot(self, true)
    elseif not self:GetIsLeftSlot() and tagName == "r_shoot" then
        Shoot(self, false)
    end
    
    -- Play spin-up sound.
    if Server then
        if self:GetIsLeftSlot() and tagName == "left_minigun_attack_start" then
            StartSoundEffectOnEntity(kSpinUpSoundNames[ExoWeaponHolder.kSlotNames.Left], self)
        elseif self:GetIsRightSlot() and tagName == "right_minigun_attack_start" then
            StartSoundEffectOnEntity(kSpinUpSoundNames[ExoWeaponHolder.kSlotNames.Right], self)
        end
    end
    
    -- Play spin-down sound.
    if Server then
        if self:GetIsLeftSlot() and tagName == "left_minigun_attack_end" then
            StartSoundEffectOnEntity(kSpinDownSoundNames[ExoWeaponHolder.kSlotNames.Left], self)
        elseif self:GetIsRightSlot() and tagName == "right_minigun_attack_end" then
            StartSoundEffectOnEntity(kSpinDownSoundNames[ExoWeaponHolder.kSlotNames.Right], self)
        end
    end
    
    -- Stop being overheated when the animation finishes.
    if Server then
        if self:GetIsLeftSlot() and tagName == "left_overheat_end" or
           self:GetIsRightSlot() and tagName == "right_overheat_end" then
            
            self.overheated = false
        end
    end

end

function Minigun:OnUpdateAnimationInput(modelMixin)

    local activity = "none"
    if self.overheated then
        -- Trigger the overheat animation, but only once so we don't accidentally play it twice in a row.
        activity = "overheat"
    elseif self.minigunAttacking --[=[and not self.overheated--]=] then
        activity = "primary"
    end
    
    modelMixin:SetAnimationInput("activity_" .. self:GetExoWeaponSlotName(), activity)
    
    -- TODO calculate this once, and hard-code it in.  Updated every frame for now so balance team
    -- can make adjustments on-the-fly.
    modelMixin:SetAnimationInput("overheat_speed", Minigun.kOverheatAnimationBaseLength / Minigun.kOverheatDuration)
    
end

if Client then

    local kMinigunMuzzleEffectRate = 0.15
    local kAttachPoints = { [ExoWeaponHolder.kSlotNames.Left] = "fxnode_l_minigun_muzzle", [ExoWeaponHolder.kSlotNames.Right] = "fxnode_r_minigun_muzzle" }
    local kMuzzleEffectName =  { 
        [ExoWeaponHolder.kSlotNames.Left] = PrecacheAsset("cinematics/marine/minigun/muzzle_flash_left.cinematic"), 
        [ExoWeaponHolder.kSlotNames.Right] = PrecacheAsset("cinematics/marine/minigun/muzzle_flash.cinematic") 
    }

    function Minigun:GetIsActive()
        return true
    end
    
    function Minigun:GetPrimaryEffectRate()
        return kMinigunMuzzleEffectRate
    end
    
    function Minigun:GetPrimaryAttacking()
        return self.shooting
    end
    
    function Minigun:GetSecondaryAttacking()
        return false
    end
    
    function Minigun:OnClientPrimaryAttacking()
    
        local parent = self:GetParent()
        
        if parent then
            CreateMuzzleCinematic(self, 
                kMuzzleEffectName[self:GetExoWeaponSlot()], 
                kMuzzleEffectName[self:GetExoWeaponSlot()], 
                kAttachPoints[self:GetExoWeaponSlot()], 
                parent)
        end
    
    end
    
end

Shared.LinkClassToMap("Minigun", Minigun.kMapName, networkVars)