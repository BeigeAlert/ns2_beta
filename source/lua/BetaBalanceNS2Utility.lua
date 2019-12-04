-- Here's what I did: Copy+pasted CheckMeleeCapsule and renamed it CheckMeleeCapsuleHelper and made
-- it a local function.  Made a slight modification to it to differentiate between glancing blows.
-- Then added CheckMeleeCapsule function back in that first tries CheckMeleeCapsuleHelper without
-- glancing hits, then, if it misses, tries with the glancing hits.  Appears the same from an
-- external point of view, except that an extra return value "wasGlancing" is returned at the end.


local function IsPossibleMeleeTarget(player, target, teamNumber)
    
    if target and HasMixin(target, "Live") and target:GetCanTakeDamage() and target:GetIsAlive() then
        
        if HasMixin(target, "Team") and teamNumber == target:GetTeamNumber() then
            return true
        end
    
    end
    
    return false

end

--[[
 * Priority function for melee target.
 *
 * Returns newTarget it it is a better target, otherwise target.
 *
 * Default priority: closest enemy player, otherwise closest enemy melee target
--]]
local function IsBetterMeleeTarget(weapon, player, newTarget, target)
    
    local teamNumber = GetEnemyTeamNumber(player:GetTeamNumber())
    
    if IsPossibleMeleeTarget(player, newTarget, teamNumber) then
        
        if not target or (not target:isa("Player") and newTarget:isa("Player")) then
            return true
        end
    
    end
    
    return false

end

-- melee targets must be in front of the player
local function IsNotBehind(fromPoint, hitPoint, forwardDirection)
    
    local startPoint = fromPoint + forwardDirection * 0.1
    
    local toHitPoint = hitPoint - startPoint
    toHitPoint:Normalize()
    
    return forwardDirection:DotProduct(toHitPoint) > 0

end

-- The order in which we do the traces - middle first, the corners last.
local kTraceOrder = { 4, 1, 3, 5, 7, 0, 2, 6, 8 }
--[[
 * Checks if a melee capsule would hit anything. Does not actually carry
 * out any attack or inflict any damage.
 *
 * Target prio algorithm:
 * First, a small box (the size of a rifle but or a skulks head) is moved along the view-axis, colliding
 * with everything. The endpoint of this trace is the attackEndPoind
 *
 * Second, a new trace to the attackEndPoint using the full size of the melee box is done. This trace
 * is done WITHOUT REGARD FOR GEOMETRY, and uses an entity-filter that tracks targets as they come,
 * and prioritizes them.
 *
 * Basically, inside the range to the attackEndPoint, the attacker chooses the "best" target freely.
--]]
--[[
 * Bullets are small and will hit exactly where you looked.
 * Melee, however, is different. We select targets from a volume, and we expect the melee'er to be able
 * to basically select the "best" target from that volume.
 * Right now, the Trace methods available is limited (spheres or world-axis aligned boxes), so we have to
 * compensate by doing multiple traces.
 * We specify the size of the width and base height and its range.
 * Then we split the space into 9 parts and trace/select all of them, choose the "best" target. If no good target is found,
 * we use the middle trace for effects.
--]]
local function CheckMeleeCapsuleHelper(weapon, player, damage, range, optionalCoords, traceRealAttack, scale, priorityFunc, filter, mask, glancing)
    
    scale = scale or 1
    
    local eyePoint = player:GetEyePos()
    
    -- if not teamNumber then
    --     teamNumber = GetEnemyTeamNumber( player:GetTeamNumber() )
    -- end
    
    mask = mask or PhysicsMask.Melee
    
    local coords = optionalCoords or player:GetViewAngles():GetCoords()
    local axis = coords.zAxis
    local forwardDirection = Vector(coords.zAxis)
    forwardDirection.y = 0
    
    if forwardDirection:GetLength() ~= 0 then
        forwardDirection:Normalize()
    end
    
    local width, height
    if glancing then
        -- glancing should only ever be true if the weapon has provided a GetGlancingMeleeBase method.
        assert(weapon.GetMeleeBase)
        width, height = weapon:GetGlancingMeleeBase()
    else
        width, height = weapon:GetMeleeBase()
    end
    
    width = scale * width
    height = scale * height
    
    --[[
    if Client then
        Client.DebugCapsule(eyePoint, eyePoint + axis * range, width, 0, 3)
    end
   --]]
    
    -- extents defines a world-axis aligned box, so x and z must be the same.
    local extents = Vector(width / 6, height / 6, width / 6)
    if not filter then
        filter = EntityFilterOne(player)
    end
    local middleTrace,middleStart
    local target,endPoint,surface,startPoint
    
    if not priorityFunc then
        priorityFunc = IsBetterMeleeTarget
    end
    
    local selectedTrace
    
    for _, pointIndex in ipairs(kTraceOrder) do
        
        local dx = pointIndex % 3 - 1
        local dy = math.floor(pointIndex / 3) - 1
        local point = eyePoint + coords.xAxis * (dx * width / 3) + coords.yAxis * (dy * height / 3)
        local trace, sp, ep = TraceMeleeBox(weapon, point, axis, extents, range, mask, filter)
        
        if dx == 0 and dy == 0 then
            middleTrace, middleStart = trace, sp
            selectedTrace = trace
        end
        
        if trace.entity and priorityFunc(weapon, player, trace.entity, target) and IsNotBehind(eyePoint, trace.endPoint, forwardDirection) then
            
            selectedTrace = trace
            target = trace.entity
            startPoint = sp
            endPoint = trace.endPoint
            surface = trace.surface
            
            surface = GetIsAlienUnit(target) and "organic" or "metal"
            if GetAreEnemies(player, target) then
                if target:isa("Alien") then
                    surface = "organic"
                elseif target:isa("Marine") then
                    surface = "flesh"
                else
                    
                    if HasMixin(target, "Team") then
                        if target:GetTeamType() == kAlienTeamType then
                            surface = "organic"
                        else
                            surface = "metal"
                        end
                    
                    end
                
                end
            end
        end
    
    end
    
    -- if we have not found a target, we use the middleTrace to possibly bite a wall (or when cheats are on, teammates)
    target = target or middleTrace.entity
    endPoint = endPoint or middleTrace.endPoint
    surface = surface or middleTrace.surface
    startPoint = startPoint or middleStart
    
    local direction = target and (endPoint - startPoint):GetUnit() or coords.zAxis
    return target ~= nil or middleTrace.fraction < 1, target, endPoint, direction, surface, startPoint, selectedTrace

end


function CheckMeleeCapsule(weapon, player, damage, range, optionalCoords, traceRealAttack, scale, priorityFunc, filter, mask)
    
    local didHit, target, endPoint, direction, surface, startPoint, trace = CheckMeleeCapsuleHelper(weapon, player, damage, range, optionalCoords, traceRealAttack, scale, priorityFunc, filter, mask, false)
    
    if not weapon.GetGlancingMeleeBase or (didHit and target ~= nil) then
        -- Either the weapon hasn't been configured for "glancing" blows, or we hit something other than the environment.
        -- Return what we got.
        return didHit, target, endPoint, direction, surface, startPoint, trace, false -- last param = glancing
    end
    
    -- Weapon has been configured for "glancing" blows, run that now.
    didHit, target, endPoint, direction, surface, startPoint, trace = CheckMeleeCapsuleHelper(weapon, player, damage, range, optionalCoords, traceRealAttack, scale, priorityFunc, filter, mask, true)
    
    return didHit, target, endPoint, direction, surface, startPoint, trace, true -- last param = glancing

end

-- Pretty much the same as the old AttackMeleeCapsule, but with damage modified if the attack was
-- "glancing"
function AttackMeleeCapsule(weapon, player, damage, range, optionalCoords, altMode, filter)
    
    local targets = {}
    local didHit, target, endPoint, direction, surface, startPoint, trace, wasGlancing
    
    if not filter then
        filter = EntityFilterTwo(player, weapon)
    end
    
    -- loop upto 20 times just to go through any soft targets.
    -- Stops as soon as nothing is hit or a non-soft target is hit
    for i = 1, 20 do
        
        local traceFilter = function(test)
            return EntityFilterList(targets)(test) or filter(test)
        end
        
        -- Enable tracing on this capsule check, last argument.
        didHit, target, endPoint, direction, surface, startPoint, trace, wasGlancing = CheckMeleeCapsule(weapon, player, damage, range, optionalCoords, true, 1, nil, traceFilter)
        local alreadyHitTarget = target ~= nil and table.icontains(targets, target)
        
        if didHit and not alreadyHitTarget then
            local realDamageAmount
            if weapon.GetGlancingDamage and wasGlancing then
                realDamageAmount = weapon:GetGlancingDamage()
    
                -- fuckkk this is bad code... but I really don't see a better way of doing this
                -- without breaking mod compatibility...  Sorry for whoever (if anybody) ends up
                -- untangling this mess.  This variable _lastDamageWasGlancing is only used here and
                -- in DamageMixin.lua.
                if target then
                    target._lastDamageWasGlancing = true
                end
                
            else
                realDamageAmount = damage
                if target then
                    target._lastDamageWasGlancing = false
                end
            end
            weapon:DoDamage(realDamageAmount, target, endPoint, direction, surface, altMode)
        end
        
        if target and not alreadyHitTarget then
            table.insert(targets, target)
        end
        
        if not target or not HasMixin(target, "SoftTarget") then
            break
        end
    
    end
    
    HandleHitregAnalysis(player, startPoint, endPoint, trace)
    
    return didHit, targets[#targets], endPoint, surface
    
end

