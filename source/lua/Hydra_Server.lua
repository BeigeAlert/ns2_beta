Log("Loading modified Hydra_Server.lua for NS2 Balance Beta mod.")

-- Changes:
-- Made hydras perfectly accurate (removed spread code).
-- Made GetBarrelPoint() return the last location the hydra was hit at.

-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\Hydra_Server.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- Creepy plant turret the Gorge can create.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Hydra.kUpdateInterval = .5

function Hydra:OnKill(attacker, doer, point, direction)

    ScriptActor.OnKill(self, attacker, doer, point, direction)
    
    local team = self:GetTeam()
    if team then
        team:UpdateClientOwnedStructures(self:GetId())
    end

end

function Hydra:GetDistanceToTarget(target)
    return ((target:GetEngagementPoint() - self:GetModelOrigin()):GetLength())
end

function Hydra:OnTakeDamage(damage, attacker, doer, point, direction, damageType, preventAlert)
    self.lastHitLocation = point
end

function Hydra:CreateSpikeProjectile()

    local barrelPos = self:GetBarrelPoint()
    local targetPos = self.target:GetEngagementPoint()
    local trace = Shared.TraceRay(barrelPos, targetPos, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOneAndIsa(self, "Hydra"))
    
    -- DEBUG
    Debug_VisualizeTrace(barrelPos, trace, 1)
    if trace.fraction == 1 then
        Log("miss")
    else
        Log("hit")
    end
    
    
    if trace.fraction >= 1 then
        return -- hit nothing
    end
    
    -- Disable friendly fire.
    if trace.entity and not GetAreEnemies(trace.entity, self) then
        return -- hit a friendly unit.
    end
    
    local surface
    if not trace.entity then
        surface = trace.surface
    end
    
    self:DoDamage(Hydra.kDamage, trace.entity, trace.endPoint, GetNormalizedVector(targetPos - barrelPos), surface, false, true)

end

function Hydra:GetRateOfFire()
    return Hydra.kRateOfFire
end

-- No changes (incorporating a change to a local function).
function Hydra:AttackTarget()

    self:TriggerUncloak()

    self:CreateSpikeProjectile()
    self:TriggerEffects("hydra_attack")


    self.timeOfNextFire = Shared.GetTime() + self:GetRateOfFire()

end

function Hydra:OnOwnerChanged(_, newOwner)

    self.hydraParentId = Entity.invalidId
    if newOwner ~= nil then
        self.hydraParentId = newOwner:GetId()
    end
    
end

function Hydra:OnUpdate(deltaTime)

    PROFILE("Hydra:OnUpdate")
    
    ScriptActor.OnUpdate(self, deltaTime)
    
    if not self.timeLastUpdate then
        self.timeLastUpdate = Shared.GetTime()
    end
    
    if self.timeLastUpdate + Hydra.kUpdateInterval < Shared.GetTime() then
    
        if GetIsUnitActive(self) and not self:GetIsOnFire() then
            self.target = self.targetSelector:AcquireTarget()

            -- Check for obstacles between the origin and barrel point of the hydra so it doesn't shoot while sticking through walls
            self.attacking = self.target and not GetWallBetween(self:GetBarrelPoint(), self:GetOrigin(), self) and not GetIsPointInsideClogs(self:GetBarrelPoint())

            if self.attacking and (not self.timeOfNextFire or Shared.GetTime() > self.timeOfNextFire) then
                self:AttackTarget()
            elseif not self.target then
                -- Play alert animation if marines nearby and we're not targeting (ARCs?)
                if not self.timeLastAlertCheck or Shared.GetTime() > self.timeLastAlertCheck + Hydra.kAlertCheckInterval then
                
                    self.alerting = false
                    
                    if self:GetIsEnemyNearby() then
                    
                        self.alerting = true
                        self.timeLastAlertCheck = Shared.GetTime()
                        
                    end
                    
                end
            end

        else
            self.attacking = false
        end
        
        self.timeLastUpdate = Shared.GetTime()
        
    end
    
end

function Hydra:GetIsEnemyNearby()

    local enemyPlayers = GetEntitiesForTeam("Player", GetEnemyTeamNumber(self:GetTeamNumber()))
    
    for _, player in ipairs(enemyPlayers) do
    
        if player:GetIsVisible() and not player:isa("Commander") then
        
            local dist = self:GetDistanceToTarget(player)
            if dist < Hydra.kRange then
                return true
            end
            
        end
        
    end
    
    return false
    
end
