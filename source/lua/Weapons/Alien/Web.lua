Log("Loading modified Web.lua for NS2 Balance Beta mod.")

-- Changes:
-- Webs have a new shader that makes them invisible over a certain distance.  Shader inputs are
--      updated here so that aliens can always see webs, but marines cannot.


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

class 'Web' (Entity)

Web.kMapName = "web"

Web.kRootModelName = PrecacheAsset("models/alien/gorge/web_helper.model")
Web.kModelName = PrecacheAsset("models/alien/gorge/web.model")
local kAnimationGraph = PrecacheAsset("models/alien/gorge/web.animation_graph")

local networkVars =
{
    length = "float",
    variant = "enum kGorgeVariant"
}

Web.kZeroVisDistance = 5.0
Web.kFullVisDistance = 2.5

AddMixinNetworkVars(TechMixin, networkVars)
AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
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
    self:SetUpdates(self.enemiesInRange)

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

function Web:OnInitialized()

    self:SetModel(Web.kModelName, kAnimationGraph)
    
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.WebsGroup)  
  
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

if Client then

    function Web:OnUpdateRender()
    
        -- If we're not an enemy, (eg we're an alien or a spectator), we should be able to see webs
        -- at all times.  Otherwise, webs sort of fade in or out depending on distance.  Set the
        -- shader inputs for that here.  Ideally this would just happen whenever the player changes
        -- teams but... we don't have an easy way of detecting that in this engine... :(
        local player = Client.GetLocalPlayer()
        if not player then
            return
        end
        
        local renderModel = self:GetRenderModel()
        if not renderModel then
            return
        end
        
        local isMarine = GetIsMarineUnit(player)
        if isMarine then
            renderModel:SetMaterialParameter("noVisDist", Web.kZeroVisDistance)
            renderModel:SetMaterialParameter("fullVisDist", Web.kFullVisDistance)
        else
            renderModel:SetMaterialParameter("noVisDist", -1)
            renderModel:SetMaterialParameter("fullVisDist", 0)
        end
    
    end

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
                
                --FIXME Web seems to not have Owner applied, because this is running in ProcessMove
                --  Owner only accessible on ServerVM ...
                if HasMixin( fromPlayer, "ParasiteAble" ) and HasMixin( self, "Owner" ) then
                    --TODO Modify ParasiteMixin to specify a duration
                    local WebOwner = self:GetOwner() or nil
                    fromPlayer:SetParasited( WebOwner, kWebbedParasiteDuration )
                end
                
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

end

Shared.LinkClassToMap("Web", Web.kMapName, networkVars)
