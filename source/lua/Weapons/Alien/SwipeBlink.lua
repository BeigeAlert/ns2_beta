-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\Alien\SwipeBlink.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com)
--
-- Swipe/blink - Left-click to attack, right click to show ghost. When ghost is showing,
-- right click again to go there. Left-click to cancel. Attacking many times in a row will create
-- a cool visual "chain" of attacks, showing the more flavorful animations in sequence.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/Blink.lua")

class 'SwipeBlink' (Blink)
SwipeBlink.kMapName = "swipe"

local networkVars =
{
}

-- Make sure to keep damage vs. structures less then Skulk
SwipeBlink.kSwipeEnergyCost = kSwipeEnergyCost
SwipeBlink.kDamage = kSwipeDamage
SwipeBlink.kRange = 1.6

local kAnimationGraph = PrecacheAsset("models/alien/fade/fade_view.animation_graph")
local kAttackDuration = Shared.GetAnimationLength("models/alien/fade/fade_view.model", "swipe_attack")

function SwipeBlink:OnCreate()

    Blink.OnCreate(self)
    
    self.lastSwipedEntityId = Entity.invalidId
    self.primaryAttacking = false

end

function SwipeBlink:GetAnimationGraphName()
    return kAnimationGraph
end

function SwipeBlink:GetEnergyCost()
    return SwipeBlink.kSwipeEnergyCost
end

function SwipeBlink:GetHUDSlot()
    return 1
end

function SwipeBlink:GetPrimaryAttackRequiresPress()
    return false
end

function SwipeBlink:GetMeleeBase()
    -- Width of box, height of box
    return .7, 1.2
    
end

function SwipeBlink:GetDeathIconIndex()
    return kDeathMessageIcon.Swipe
end

function SwipeBlink:GetVampiricLeechScalar()
    return kSwipeVampirismScalar
end

function SwipeBlink:GetSecondaryTechId()
    return kTechId.Blink
end

function SwipeBlink:GetBlinkAllowed()
    return true
end

function SwipeBlink:OnPrimaryAttack(player)
    local notBlinking = not self:GetIsBlinking()
    local hasEnergy = player:GetEnergy() >= self:GetEnergyCost()
    local cooledDown = (not self.nextAttackTime) or (Shared.GetTime() >= self.nextAttackTime)
    if notBlinking and hasEnergy and cooledDown then
        self.primaryAttacking = true
    else
        self.primaryAttacking = false
    end
    
end

function SwipeBlink:OnPrimaryAttackEnd()
    
    Blink.OnPrimaryAttackEnd(self)
    
    self.primaryAttacking = false
    
end

function SwipeBlink:OnHolster(player)

    Blink.OnHolster(self, player)
    
    self.primaryAttacking = false
    
end

function SwipeBlink:GetIsAffectedByFocus()
    return self.primaryAttacking
end

function SwipeBlink:GetAttackAnimationDuration()
    return kAttackDuration
end

function SwipeBlink:OnTag(tagName)

    PROFILE("SwipeBlink:OnTag")
    
    if tagName == "hit" then
    
        local stabWep = self:GetParent():GetWeapon(StabBlink.kMapName)
        if stabWep and stabWep.stabbing then
            -- player is using stab and has switched to swipe really fast, but the attack the "hit"
            -- tag is from is still a stab, and thus should do stab damage.
            stabWep:DoAttack()
        else
            self:TriggerEffects("swipe_attack")    
            self:PerformMeleeAttack()
        
            local player = self:GetParent()
            if player then
            
                self:OnAttack(player)
            
            end
        end
    
    end

end

function SwipeBlink:PerformMeleeAttack()

    local player = self:GetParent()
    if player then    
        AttackMeleeCapsule(self, player, SwipeBlink.kDamage, SwipeBlink.kRange, nil, false, EntityFilterOneAndIsa(player, "Babbler"))
    end
    
end

function SwipeBlink:OnUpdateAnimationInput(modelMixin)

    PROFILE("SwipeBlink:OnUpdateAnimationInput")

    Blink.OnUpdateAnimationInput(self, modelMixin)
    
    modelMixin:SetAnimationInput("ability", "swipe")
    
    local activityString = (self.primaryAttacking and "primary") or "none"
    modelMixin:SetAnimationInput("activity", activityString)
    
end

Shared.LinkClassToMap("SwipeBlink", SwipeBlink.kMapName, networkVars)