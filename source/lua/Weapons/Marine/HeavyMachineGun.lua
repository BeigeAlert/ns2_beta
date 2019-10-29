Log("Loading modified HeavyMachineGun.lua for NS2 Balance Beta mod.")

-- Changes:
-- Changed HMG reload speed.

Script.Load("lua/Weapons/Marine/ClipWeapon.lua")
Script.Load("lua/PickupableWeaponMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/Weapons/ClientWeaponEffectsMixin.lua")
Script.Load("lua/HMGVariantMixin.lua")

class 'HeavyMachineGun' (ClipWeapon)

HeavyMachineGun.kMapName = "hmg"

HeavyMachineGun.kModelName = PrecacheAsset("models/marine/hmg/hmg.model")
local kViewModels = GenerateMarineViewModelPaths("hmg")

local kIdleChangeThrottle = 0.25

HeavyMachineGun.kReloadAnimationLength = 5.0 -- from art asset.
HeavyMachineGun.kReloadLength = 2.25 -- desired reload time.

-- Sounds
local kNumberOfVariants = 3
local kLoopingSounds = {}
local kEndSounds = {}
local kSingleShotSounds = {}
for i=0,3 do
    for j=0,2 do
        table.insert(kLoopingSounds, "sound/NS2.fev/marine/hmg/hmg_fire_loop_w"..i.."_"..j)
    end
    table.insert(kEndSounds, "sound/NS2.fev/marine/hmg/hmg_fire_loop_end_w"..i)
    table.insert(kSingleShotSounds, "sound/NS2.fev/marine/hmg/hmg_fire_loop_end_w"..i)
end
for k, v in ipairs(kLoopingSounds) do PrecacheAsset(v) end
for k, v in ipairs(kEndSounds) do PrecacheAsset(v) end
for k, v in ipairs(kSingleShotSounds) do PrecacheAsset(v) end

local kLoopingShellCinematic = PrecacheAsset("cinematics/marine/rifle/shell_looping.cinematic")
local kLoopingShellCinematicFirstPerson = PrecacheAsset("cinematics/marine/hmg/shell_looping_1p.cinematic")
local kShellEjectAttachPoint = "fxnode_hmgcasing"
local kMuzzleCinematic =  PrecacheAsset("cinematics/marine/hmg/muzzle_flash.cinematic")

local kHandPositionAttachPointName = "fxnode_hand"

local networkVars =
{
    soundType = "integer (1 to 12)",
    shooting = "boolean",
}
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(HMGVariantMixin, networkVars)

local kMuzzleEffect = PrecacheAsset("cinematics/marine/rifle/muzzle_flash.cinematic")
local kMuzzleAttachPoint = "fxnode_hmgmuzzle"

local function DestroyMuzzleEffect(self)

    if self.muzzleCinematic then
        Client.DestroyCinematic(self.muzzleCinematic)
    end

    self.muzzleCinematic = nil
    self.activeCinematicName = nil

end

local function DestroyShellEffect(self)

    if self.shellsCinematic then
        Client.DestroyCinematic(self.shellsCinematic)
    end

    self.shellsCinematic = nil

end

local function CreateMuzzleEffect(self)

    local player = self:GetParent()

    if player then

        local cinematicName = kMuzzleCinematic
        self.activeCinematicName = cinematicName
        self.muzzleCinematic = CreateMuzzleCinematic(self, cinematicName, cinematicName, kMuzzleAttachPoint, nil, Cinematic.Repeat_Endless)
        self.firstPersonLoaded = player:GetIsLocalPlayer() and player:GetIsFirstPerson()

    end

end

local function CreateShellCinematic(self)

    local parent = self:GetParent()

    if parent and Client.GetLocalPlayer() == parent then
        self.loadedFirstPersonShellEffect = true
    else
        self.loadedFirstPersonShellEffect = false
    end

    if self.loadedFirstPersonShellEffect then
        self.shellsCinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
        self.shellsCinematic:SetCinematic(kLoopingShellCinematicFirstPerson)
    else
        self.shellsCinematic = Client.CreateCinematic(RenderScene.Zone_Default)
        self.shellsCinematic:SetCinematic(kLoopingShellCinematic)
    end

    self.shellsCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)

    if self.loadedFirstPersonShellEffect then
        self.shellsCinematic:SetParent(parent:GetViewModelEntity())
    else
        self.shellsCinematic:SetParent(self)
    end

    self.shellsCinematic:SetCoords(Coords.GetIdentity())

    if self.loadedFirstPersonShellEffect then
        self.shellsCinematic:SetAttachPoint(parent:GetViewModelEntity():GetAttachPointIndex(kShellEjectAttachPoint))
    else
        self.shellsCinematic:SetAttachPoint(self:GetAttachPointIndex(kShellEjectAttachPoint))
    end

    self.shellsCinematic:SetIsActive(false)

end

-- Don't inherit this from Rifle. We are going to initialise mixins our own way
function HeavyMachineGun:OnCreate()

    ClipWeapon.OnCreate(self)

    InitMixin(self, PickupableWeaponMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, HMGVariantMixin)

    if Client then
        InitMixin(self, ClientWeaponEffectsMixin)
    elseif Server then
        self.soundVariant = Shared.GetRandomInt(1, kNumberOfVariants)
        self.soundType = self.soundVariant
    end
    
    self.nextIdleChange = 0
    self.idleName = "idle"

end

function HeavyMachineGun:OnDestroy()

    ClipWeapon.OnDestroy(self)

    DestroyMuzzleEffect(self)
    DestroyShellEffect(self)

end

function HeavyMachineGun:GetPickupOrigin()
    return self:GetCoords():TransformPoint(Vector(0.13956764340400696, 0.08423030376434326, -0.1180378794670105))
end

local function UpdateSoundType(self, player)

    local upgradeLevel = 0

    if player.GetWeaponUpgradeLevel then
        upgradeLevel = player:GetWeaponUpgradeLevel()
    end

    self.soundType = self.soundVariant + upgradeLevel * kNumberOfVariants

end

function HeavyMachineGun:OnPrimaryAttack(player)

    if not self:GetIsReloading() then

        if Server then
            UpdateSoundType(self, player)
        end

        ClipWeapon.OnPrimaryAttack(self, player)

    end

end

function HeavyMachineGun:GetMaxClips()
    return kHeavyMachineGunClipNum
end

function HeavyMachineGun:OnHolster(player)

    DestroyMuzzleEffect(self)
    DestroyShellEffect(self)
    ClipWeapon.OnHolster(self, player)

end

function HeavyMachineGun:OnHolsterClient()

    DestroyMuzzleEffect(self)
    DestroyShellEffect(self)
    ClipWeapon.OnHolsterClient(self)

end

function HeavyMachineGun:GetAnimationGraphName()
    return HMGVariantMixin.kHMGAnimationGraph
end

function HeavyMachineGun:GetViewModelName(sex, variant)
    return kViewModels[sex][variant]
end

function HeavyMachineGun:GetDeathIconIndex()

    return kDeathMessageIcon.HeavyMachineGun

end

function HeavyMachineGun:GetHUDSlot()
    return kPrimaryWeaponSlot
end

function HeavyMachineGun:GetClipSize()
    return kHeavyMachineGunClipSize
end

function HeavyMachineGun:GetSpread()
    return kHeavyMachineGunSpread
end

function HeavyMachineGun:GetBulletDamage(target, endPoint)
    return kHeavyMachineGunDamage
end

function HeavyMachineGun:GetRange()
    return kHeavyMachineGunRange
end

function HeavyMachineGun:GetWeight()
    return kHeavyMachineGunWeight
end

function HeavyMachineGun:GetDamageType()
    return kHeavyMachineGunDamageType
end

function HeavyMachineGun:GetHasSecondary()
    return false
end

local kCoordsAdjust
function HeavyMachineGun:OnAdjustModelCoords(modelCoords)
    
    if self:GetWeaponWorldState() then
        return modelCoords -- Change nothing, let it tumble around as usual.
    else
        -- Need to adjust the orientation of the HMG so the marine grips it in the correct place.
        if not kCoordsAdjust then
            local model = Shared.GetModel(self.modelIndex)
            local attachPointIndex = model:GetAttachPointIndex(kHandPositionAttachPointName)
            if attachPointIndex > -1 and model ~= nil then
                local attachPointExists = model:GetAttachPointExists(attachPointIndex)
                if attachPointExists then
                    local poses = PosesArray()
                    model:GetReferencePose(poses)
                    local boneCoords = CoordsArray()
                    model:GetBoneCoords(poses, boneCoords)
                    kCoordsAdjust = model:GetAttachPointCoords(attachPointIndex, boneCoords):GetInverse()
                end
            end
        end
        
        return modelCoords * kCoordsAdjust
        
    end
    
end

function HeavyMachineGun:OnTag(tagName)

    PROFILE("HeavyMachineGun:OnTag")

    ClipWeapon.OnTag(self, tagName)

    --[=[
    if tagName == "hit" then

        self.shooting = false

        local player = self:GetParent()
        if player then
            self:PerformMeleeAttack(player)
        end

    end
    --]=]

end

function HeavyMachineGun:UseLandIntensity()
    return true
end

function HeavyMachineGun:GetIdleAnimations(index)
    local animations = {"idle", "idle2", "idle3", "idle4"}
    return animations[index]
end

function HeavyMachineGun:SetGunLoopParam(viewModel, paramName, rateOfChange)

    local current = viewModel:GetPoseParam(paramName)
    -- 0.5 instead of 1 as full arm_loop is intense.
    local new = Clamp(current + rateOfChange, 0, 0.5)
    viewModel:SetPoseParam(paramName, new)

end

function HeavyMachineGun:UpdateViewModelPoseParameters(viewModel)

    --viewModel:SetPoseParam("hide_gl", 1)
    --viewModel:SetPoseParam("gl_empty", 1)

    --local attacking = self:GetPrimaryAttacking()
    --local sign = (attacking and 1) or 0

    --self:SetGunLoopParam(viewModel, "arm_loop", sign)

end

local idleWeights =
{
    { name = "idle",  weight = 10 },
    { name = "idle2", weight = 1 },
    { name = "idle3", weight = 1 },
    { name = "idle4", weight = 3 },
}
local totalIdleWeight = 0.0
for i=1, #idleWeights do
    idleWeights[i].totalWeight = totalIdleWeight
    totalIdleWeight = totalIdleWeight + idleWeights[i].weight
end

function HeavyMachineGun:OnUpdateAnimationInput(modelMixin)

    PROFILE("HeavyMachineGun:OnUpdateAnimationInput")

    ClipWeapon.OnUpdateAnimationInput(self, modelMixin)

    -- Randomize the idle animation used, based on a set of weights.
    local now = Shared.GetTime()
    if now >= self.nextIdleChange then
        
        self.nextIdleChange = now + kIdleChangeThrottle
        
        local idleWeight = math.random() * totalIdleWeight
        for i=#idleWeights, 1, -1 do
            if idleWeight >= idleWeights[i].totalWeight then
                self.idleName = idleWeights[i].name
                break
            end
        end
        
    end
    
    modelMixin:SetAnimationInput("idleName", self.idleName)
    
    
    -- Set reload_mult to the appropriate value to give us the correct reload time (also taking into
    -- account the catalyst_speed value.
    -- TODO This is constantly recalculated for the benefit of the balance team so they can tweak it
    -- in real-time.  Eventually, this should just be computed once on load.
    local reloadMultiplier = HeavyMachineGun.kReloadAnimationLength / HeavyMachineGun.kReloadLength
    if self.GetCatalystSpeedBase then
        reloadMultiplier = reloadMultiplier * self:GetCatalystSpeedBase()
    end
    local player = self:GetParent()
    if player then
        if player:GetHasCatPackBoost() then
            reloadMultiplier = reloadMultiplier * kCatPackWeaponSpeed
        end
    end
    modelMixin:SetAnimationInput("reload_mult", reloadMultiplier)
    
end

function HeavyMachineGun:GetAmmoPackMapName()
    return HeavyMachineGunAmmo.kMapName
end

if Client then

    function HeavyMachineGun:OnClientPrimaryAttackStart()

        local player = self:GetParent()

        StartSoundEffectAtOrigin(kSingleShotSounds[math.floor((self.soundType-1)/3) + 1], self:GetOrigin())

        Shared.PlaySound(self, kLoopingSounds[self.soundType])
        self.clientSoundTypePlaying = self.soundType

        if not self.muzzleCinematic then
            CreateMuzzleEffect(self)
        elseif player then

            local cinematicName = kMuzzleCinematic
            local useFirstPerson = player:GetIsLocalPlayer() and player:GetIsFirstPerson()

            if cinematicName ~= self.activeCinematicName or self.firstPersonLoaded ~= useFirstPerson then

                DestroyMuzzleEffect(self)
                CreateMuzzleEffect(self)

            end

        end

        -- CreateMuzzleCinematic() can return nil in case there is no parent or the parent is invisible (for alien commander for example)
        if self.muzzleCinematic then
            self.muzzleCinematic:SetIsVisible(true)
        end

        if player then

            local useFirstPerson = player == Client.GetLocalPlayer()

            if useFirstPerson ~= self.loadedFirstPersonShellEffect then
                DestroyShellEffect(self)
            end

            if not self.shellsCinematic then
                CreateShellCinematic(self)
            end

            self.shellsCinematic:SetIsActive(true)

        end

    end

    -- needed for first person muzzle effect since it is attached to the view model entity: view model entity gets cleaned up when the player changes (for example becoming a commander and logging out again)
    -- this results in viewmodel getting destroyed / recreated -> cinematic object gets destroyed which would result in an invalid handle.
    function HeavyMachineGun:OnParentChanged(oldParent, newParent)

        ClipWeapon.OnParentChanged(self, oldParent, newParent)
        DestroyMuzzleEffect(self)
        DestroyShellEffect(self)

    end

    function HeavyMachineGun:OnClientPrimaryAttackEnd()

        -- Just assume the looping sound is playing.
        Shared.StopSound(self, kLoopingSounds[self.clientSoundTypePlaying])
        --[[
        local player = self:GetParent()
        if player and player:GetIsLocalPlayer() then
            Shared.StopSound(self, kAttackSoundName)
        end
        --]]
        Shared.PlaySound(self, kEndSounds[math.floor((self.soundType-1)/3)+1])

        if self.muzzleCinematic and self.muzzleCinematic ~= Entity.invalidId then
            self.muzzleCinematic:SetIsVisible(false)
        end

        if self.shellsCinematic and self.shellsCinematic ~= Entity.invalidId then
            self.shellsCinematic:SetIsActive(false)
        end

    end

    function HeavyMachineGun:OnClientPrimaryAttacking(deltaTime)

        -- Update weapon sounds if the weapon upgrade level has changed
        if self.clientSoundTypePlaying and self.clientSoundTypePlaying ~= self.soundType then

            Shared.StopSound(self, kLoopingSounds[self.clientSoundTypePlaying])
            Shared.PlaySound(self, kLoopingSounds[self.soundType])
            self.clientSoundTypePlaying = self.soundType

        end

    end

    function HeavyMachineGun:GetPrimaryEffectRate()
        return 0.08
    end

    function HeavyMachineGun:GetTriggerPrimaryEffects()
        return not self:GetIsReloading() and self.shooting
    end

    function HeavyMachineGun:GetBarrelPoint()

        local player = self:GetParent()
        if player then

            local origin = player:GetEyePos()
            local viewCoords= player:GetViewCoords()

            return origin + viewCoords.zAxis * 0.65 + viewCoords.xAxis * -0.15 + viewCoords.yAxis * -0.2

        end

        return self:GetOrigin()

    end

    function HeavyMachineGun:GetUIDisplaySettings()
        return { xSize = 256, ySize = 160, script = "lua/GUIHeavyMachineGunDisplay.lua" }
    end

end

function HeavyMachineGun:ModifyDamageTaken(damageTable, attacker, doer, damageType)

    if damageType ~= kDamageType.Corrode then
        damageTable.damage = 0
    end

end

function HeavyMachineGun:GetCanTakeDamageOverride()
    return self:GetParent() == nil
end

if Server then

    function HeavyMachineGun:GetDestroyOnKill()
        return true
    end

    function HeavyMachineGun:GetSendDeathMessageOverride()
        return false
    end

end

Shared.LinkClassToMap("HeavyMachineGun", HeavyMachineGun.kMapName, networkVars)
