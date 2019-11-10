-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\WebableMixin.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

WebableMixin = CreateMixin( WebableMixin )
WebableMixin.type = "Webable"

WebableMixin.optionalCallbacks =
{
    OnWebbed = "Called when entity is being webbed.",
    OnWebbedEnd = "Called when entity leaves webbed state."
}

WebableMixin.networkVars =
{
    webbed = "boolean",
    timeWebEnds = "private time"
}

function WebableMixin:__initmixin()
    
    PROFILE("WebableMixin:__initmixin")
    
    if Server then
        self.webbed = false
        self.timeWebEnds = 0
    end
    
end

function WebableMixin:ModifyMaxSpeed(maxSpeedTable)

    if self.webbed then
    
        local slowDown = kWebSlowVelocityScalar
        
        if self.GetWebSlowdownScalar then
            slowDown = self:GetWebSlowdownScalar() or 1
        end
        
        -- Taper off the slowdown over the amount of time the entity has been webbed.
        local now = Shared.GetTime()
        local timeRemaining = self.timeWebEnds - now
        local timeFraction = Clamp(timeRemaining / kWebbedDuration, 0, 1)
        slowDown = 1 - (1 - slowDown) * timeFraction
    
        maxSpeedTable.maxSpeed = maxSpeedTable.maxSpeed * slowDown
    end

end

function WebableMixin:GetIsWebbed()
    return self.webbed
end    

function WebableMixin:SetWebbed(duration)

    local oldTimeWebEnds = self.timeWebEnds or Shared.GetTime()
    local newTimeWebEnds = Shared.GetTime() + duration

    if newTimeWebEnds - oldTimeWebEnds > 0.2 then
        self:TriggerEffects("webbed")
    end

    self.timeWebEnds = Shared.GetTime() + duration
    if not self.webbed and self.OnWebbed then
        self:OnWebbed()
    end

    self.webbed = true
    
    if self:isa("Player") then
        
        local slowdown = kWebSlowVelocityScalar
        
        if self.GetWebSlowdownScalar then
            slowdown = self:GetWebSlowdownScalar() or 1
        end
        
        local velocity = self:GetVelocity()
        velocity.x = velocity.x * slowdown
        velocity.z = velocity.z * slowdown
        if velocity.y < 0 then -- Only slow down the fall, not jumping
            velocity.y = math.min(1, velocity.y * slowdown) --?? Examine for falling and not adjust?
        end
        self:SetVelocity(velocity)
        
    end
    
end

local function SharedUpdate(self)

    local wasWebbed = self.webbed
    self.webbed = self.timeWebEnds > Shared.GetTime()
    
    if wasWebbed and not self.webbed and self.OnWebbedEnd then
        self:OnWebbedEnd()
    end
    
end

if Server then

    function WebableMixin:OnUpdate(deltaTime)
        PROFILE("WebableMixin:OnUpdate")
        SharedUpdate(self)
    end
    
end

function WebableMixin:OnProcessMove(input)

    SharedUpdate(self)
    
    for _, web in ipairs(GetEntitiesForTeamWithinRange("Web", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), kMaxWebLength * 2)) do
        web:UpdateWebOnProcessMove(self)
    end
    
end

function WebableMixin:OnUpdateAnimationInput(modelMixin)
    modelMixin:SetAnimationInput("webbed", self.webbed)
end

function WebableMixin:OnUpdateRender()

    -- TODO: custom material?

end
