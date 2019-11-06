Log("Loading modified Web.lua for NS2 Balance Beta mod.")

-- Changes:
-- Webs have a new shader that makes them invisible over a certain distance.  Shader inputs are
--      updated here so that aliens can always see webs, but marines cannot.
-- Removed web parasite effect.
-- Removed web from the killfeed.

-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\Alien\Web.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- Spit attack on primary.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/TechMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/OwnerMixin.lua")
Script.Load("lua/ClogFallMixin.lua")
Script.Load("lua/Mixins/BaseModelMixin.lua")
Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/EffectsMixin.lua")
Script.Load("lua/CloakableMixin.lua")

class 'Web' (Entity)

Web.kMapName = "web"

Web.kRootModelName = PrecacheAsset("models/alien/gorge/web_helper.model")
Web.kModelName = PrecacheAsset("models/alien/gorge/web.model")
local kAnimationGraph = PrecacheAsset("models/alien/gorge/web.animation_graph")

local kEnemyDetectInterval = 0.2

local networkVars =
{
    length = "float",
    variant = "enum kGorgeVariant"
}

Web.kZeroVisDistance = 5.0
Web.kFullVisDistance = 2.5
Web.kDistortionIntensity = 0.0625

local kWebDistortMaterial = PrecacheAsset("models/alien/gorge/web_distort.material")

AddMixinNetworkVars(TechMixin, networkVars)
AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(CloakableMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)

PrecacheAsset("models/alien/gorge/web.surface_shader")
local kWebMaterial = PrecacheAsset("models/alien/gorge/web.material")
local kWebWidth = 0.1

function EntityFilterNonWebables()
    return function(test) return not HasMixin(test, "Webable") end
end

function Web:SpaceClearForEntity(_)
    return true
end

local function CheckWebablesInRange(self)

    local webables = GetEntitiesWithMixinForTeamWithinRange("Webable", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), self.checkRadius)
    self.enemiesInRange = #webables > 0
    self:SetUpdates(self.enemiesInRange or not self.fullyCloaked)

    return true

end

function Web:OnCreate()

    Entity.OnCreate(self)
    
    InitMixin(self, TechMixin)
    InitMixin(self, EffectsMixin)
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, CloakableMixin)
    InitMixin(self, LOSMixin)

    InitMixin(self, ClogFallMixin)
    
    if Server then
    
        InitMixin(self, InvalidOriginMixin)    
        InitMixin(self, OwnerMixin)
        
        self:AddTimedCallback(CheckWebablesInRange, 0.3) --FIXME Should be moved to trigger or collision as this prevents melee capsule trace from hitting webs
        
        self.triggerSpawnEffect = false
        
    end
    
    self.variant = kGorgeVariant.normal

    self:SetUpdates(true, kDefaultUpdateRate)
    self:SetRelevancyDistance(kMaxRelevancyDistance)
    
end

local function GetAreEnemiesInRange(self)
    
    PROFILE("Web:GetAreEnemiesInRange")
    
    -- Since it's a web, it's not just one point we need to check around, it's a radius around a
    -- line, so kind of a pill-shape.  First, gather entities with a range of the middle that fully
    -- encompasses all entities within the pill shape, then do more fine-grained checks to see if
    -- they're actually in-range.
    local midPoint = (self:GetOrigin() + self.endPoint) * 0.5
    local broadRange = self.length * 0.5 + self.kFullVisDistance
    local ents = GetEntitiesForTeamWithinRange("Player", GetEnemyTeamNumber(self:GetTeamNumber()), midPoint, broadRange)
    if #ents == 0 then
        return false
    end
    
    -- Get the distance between the web line segment and each entity.
    local webVector = (self.endPoint - self:GetOrigin()) / self.length
    local rangeSq = self.kFullVisDistance * self.kFullVisDistance
    for i=1, #ents do
        local ent = ents[i]
        local entPos = ent:GetOrigin()
        local t = Clamp(webVector:DotProduct(entPos - self:GetOrigin()), 0, self.length)
        local nearestPos = webVector * t + self:GetOrigin()
        local distSq = (entPos - nearestPos):GetLengthSquared()
        
        if distSq <= rangeSq then
            return true
        end
        
    end
    
    return false

end

local function ScanForNearbyEnemies(self)
    
    PROFILE("Web:ScanForNearbyEnemies")
    
    if GetAreEnemiesInRange(self) then
    
        self:TriggerUncloak()
    
    end
    
    return (self:GetIsAlive()) -- stop callback when dead.
    
end

function Web:OnInitialized()

    self:SetModel(Web.kModelName, kAnimationGraph)
    
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.WebsGroup)
    
    if Server then
        
        self:AddTimedCallback(ScanForNearbyEnemies, kEnemyDetectInterval)
        
    end
  
end

if Server then

    function Web:SetEndPoint(endPoint)
    
        self.endPoint = Vector(endPoint)
        self.length = Clamp((self:GetOrigin() - self.endPoint):GetLength(), kMinWebLength, kMaxWebLength)
        
        local coords = Coords.GetIdentity()
        coords.origin = self:GetOrigin()
        coords.zAxis = GetNormalizedVector(self:GetOrigin() - self.endPoint)
        coords.xAxis = coords.zAxis:GetPerpendicular()
        coords.yAxis = coords.zAxis:CrossProduct(coords.xAxis)
        
        self:SetCoords(coords)
        
        self.checkRadius = (self:GetOrigin() - self.endPoint):GetLength() * .5 + 1
        
    end

end

function Web:GetIsFlameAble()
    return true
end

function Web:OverrideCheckVision()
    return false
end

function Web:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    -- webs can't be destroyed with bullet weapons
    if doer ~= nil and not (doer:isa("Axe") or doer:isa("Grenade") or doer:isa("ClusterGrenade") or doer:isa("Flamethrower") or damageType == kDamageType.Flame) then
        damageTable.damage = 0
    end

end

if Server then

    function Web:GetDestroyOnKill()
        return true
    end

    function Web:OnKill()
        self:TriggerEffects("death")
    end

    function Web:SetVariant(gorgeVariant)
        self.variant = gorgeVariant
    end

end

local function TriggerWebDestroyEffects(self)

    local startPoint = self:GetOrigin()
    local zAxis = -self:GetCoords().zAxis
    local coords = self:GetCoords()
    
    for i = 1, 20 do

        local effectPoint = startPoint + zAxis * 0.36 * i
        
        if (effectPoint - startPoint):GetLength() >= self.length then
            break
        end
        
        coords.origin = effectPoint

        self:TriggerEffects("web_destroy", { effecthostcoords = coords })    
    
    end

end

function Web:OnDestroy()

    Entity.OnDestroy(self)
    
    -- TODO
    -- Shouldn't this be in OnKill, not OnDestroy???
    if Server then
        TriggerWebDestroyEffects(self)
    end

end

function Web:GetDistortMaterialName()
    return kWebDistortMaterial
end

if Client then
    
    function Web:OnUpdateRender()
        
        -- TODO these values should be baked into the shader, but they're exposed and set here every
        -- frame so that balance team can tweak values as they please.
        if self.distortMaterial then
            self.distortMaterial:SetParameter("noVisDist", Web.kZeroVisDistance)
            self.distortMaterial:SetParameter("fullVisDist", Web.kFullVisDistance)
            self.distortMaterial:SetParameter("distortionIntensity", Web.kDistortionIntensity)
        end
        
    end
    
end

function Web:GetIsCamouflaged()
    return true
end

local function GetDistance(self, fromPlayer)

    local tranformCoords = self:GetCoords():GetInverse()
    local relativePoint = tranformCoords:TransformPoint(fromPlayer:GetOrigin())    

    return math.abs(relativePoint.x), relativePoint.y

end

local function CheckForIntersection(self, fromPlayer)

    if not self.endPoint then
        self.endPoint = self:GetOrigin() + self.length * self:GetCoords().zAxis
    end
    
    if fromPlayer then
    
        -- need to manually check for intersection here since the local players physics are invisible and normal traces would fail
        local playerOrigin = fromPlayer:GetOrigin()
        local extents = fromPlayer:GetExtents()
        local fromWebVec = playerOrigin - self:GetOrigin()
        local webDirection = -self:GetCoords().zAxis
        local dotProduct = webDirection:DotProduct(fromWebVec)

        local minDistance = - extents.z
        local maxDistance = self.length + extents.z
        
        if dotProduct >= minDistance and dotProduct < maxDistance then
        
            local horizontalDistance, verticalDistance = GetDistance(self, fromPlayer)
            
            local horizontalOk = horizontalDistance <= extents.z
            local verticalOk = verticalDistance >= 0 and verticalDistance <= extents.y * 2         

            --DebugPrint("horizontalDistance %s  verticalDistance %s", ToString(horizontalDistance), ToString(verticalDistance))

            if horizontalOk and verticalOk then
              
                fromPlayer:SetWebbed(kWebbedDuration)
                
                if Server and fromPlayer:isa("Exo") then
                    DestroyEntity(self)
                end
          
            end
        
        end
    
    elseif Server then
    
        local trace = Shared.TraceRay(self:GetOrigin(), self.endPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterNonWebables())
        if trace.entity and not trace.entity:isa("Player") then
            trace.entity:SetWebbed(kWebbedDuration)
            -- DestroyEntity(self)
        end    
    
    end

end 

-- TODO: somehow the pose params dont work here when using clientmodelmixin. should figure out why this is broken and switch to clientmodelmixin
function Web:OnUpdatePoseParameters()
    self:SetPoseParam("scale", self.length)    
end

-- called by the players so they can predict the web effect
function Web:UpdateWebOnProcessMove(fromPlayer)
    CheckForIntersection(self, fromPlayer)
end

if Server then

    local function TriggerWebSpawnEffects(self)

        local startPoint = self:GetOrigin()
        local zAxis = -self:GetCoords().zAxis
        
        for i = 1, 20 do

            local effectPoint = startPoint + zAxis * 0.36 * i
            
            if (effectPoint - startPoint):GetLength() >= self.length then
                break
            end

            self:TriggerEffects("web_create", { effecthostcoords = Coords.GetTranslation(effectPoint) })    
        
        end
    
    end

    -- OnUpdate is only called when entities are in interest range, players are ignored here since they need to predict the effect
    function Web:OnUpdate(deltaTime)

        if self.enemiesInRange then        
            CheckForIntersection(self)
        end
        
        if not self.triggerSpawnEffect then
            TriggerWebSpawnEffects(self)
            self.triggerSpawnEffect = true
        end

    end
    
    function Web:GetSendDeathMessageOverride()
        return false
    end

end

Shared.LinkClassToMap("Web", Web.kMapName, networkVars)
