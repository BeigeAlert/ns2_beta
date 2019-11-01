Log("Loading modified MaturityMixin.lua for NS2 Balance Beta mod.")

-- Changes:
-- Added a method to add X amount of maturity (for heal spray adding maturity)

-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\MaturityMixin.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
--    Responsible for letting alien structures become maturity. Determine "Mature Fraction" which
--    increases over time, 0.0 - 1.0.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

MaturityMixin = CreateMixin(MaturityMixin)
MaturityMixin.type = "Maturity"

kMaturityLevel = enum({ 'Newborn', 'Grown', 'Mature' })

-- 1 minute until structure is fully grown
local kDefaultMaturityRate = 60

MaturityMixin.networkVars =
{
    maturityFraction = "float (0 to 1 by 0.01)" -- gets only update once per second to keep network traffic low
}

MaturityMixin.expectedMixins =
{
    Live = "MaturityMixin will adjust max health/armor over time.",
}

MaturityMixin.optionalCallbacks = 
{
    GetMaturityRate = "Return individual maturity rate in seconds.",
    GetMatureMaxHealth = "Return individual maturity health.",
    GetMatureMaxArmor = "Return individual maturity armor.",
    OnMaturityComplete = "Callback once 100% maturity has been reached."
}

local function GetMaturityRate(self)

    if self.GetMaturityRate then
        return (self:GetMaturityRate())
    end
    
    return kDefaultMaturityRate
    
end

function MaturityMixin:__initmixin()
    
    PROFILE("MaturityMixin:__initmixin")

    self.maturityFraction = 0
    
    if Server then

        self._maturityFraction = 0 -- server only maturity faction that get updated every tick
        self.maturityHealth = 0
        self.maturityArmor = 0
        self.timeMaturityLastUpdate = 0
        self.updateMaturity = true

        if self.startsMature then
            self:SetMature()
        end
        
    end

    if HasMixin(self, "Model") then
        self:AddTimedCallback(MaturityMixin.OnMaturityUpdate, 0.1)
    end
    
end

function MaturityMixin:OnConstructionComplete()
    self.updateMaturity = true
end

function MaturityMixin:OnKill()
    self.updateMaturity = false
end

function MaturityMixin:GetIsMature()
    return self:GetMaturityFraction() == 1
end

function MaturityMixin:GetMaturityFraction()
    return Server and self._maturityFraction or self.maturityFraction
end

function MaturityMixin:GetMaturityLevel()
    local maturityFraction = self:GetMaturityFraction()

    if maturityFraction < 0.5 then
        return kMaturityLevel.Newborn
    elseif maturityFraction < 1 then
        return kMaturityLevel.Grown
    else
        return kMaturityLevel.Mature
    end
end

if Server then

    local function GetMaturityHealth(self, fraction)

        local maxHealth = LookupTechData(self:GetTechId(), kTechDataMaxHealth, 100)
        -- use 1.5 times normal health as default
        local maturityHealth = maxHealth * 1.5

        if self.GetMatureMaxHealth then
            maturityHealth = self:GetMatureMaxHealth()
        end

        local newMatureHealth = (maturityHealth - maxHealth) * self:GetMaturityFraction()
        -- Health is a interger value so we have to make sure the delta is always an int as well to not loose data
        local healthDelta = math.floor(newMatureHealth - self.maturityHealth)

        self.maturityHealth = self.maturityHealth + healthDelta

        return self:GetMaxHealth() + healthDelta

    end

    local function GetMaturityArmor(self, fraction)

        local maxArmor = LookupTechData(self:GetTechId(), kTechDataMaxArmor, 0)
        -- use 1.5 times normal armor as default
        local maturityArmor = maxArmor * 1.5

        if self.GetMatureMaxArmor then
            maturityArmor = self:GetMatureMaxArmor()
        end

        local newMatureArmor = (maturityArmor - maxArmor) * fraction
        -- Armor is a interger value so we have to make sure the delta is always an int as well to not loose data
        local armorDelta = math.floor(newMatureArmor - self.maturityArmor)

        self.maturityArmor = self.maturityArmor + armorDelta
        return self:GetMaxArmor() + armorDelta

    end

    function MaturityMixin:UpdateMaturity(forceUpdate)

        local fraction = self._maturityFraction
        if not forceUpdate and self.maturityFraction == fraction then return end

        self.maturityFraction = fraction

        -- health/armor fractions are maintained by using "Adjust" functions
        local newMaxHealth = GetMaturityHealth(self, fraction)
        self:AdjustMaxHealth(newMaxHealth)

        local newMaxArmor = GetMaturityArmor(self, fraction)
        self:AdjustMaxArmor(newMaxArmor)

    end


    function MaturityMixin:OnMaturityUpdate(deltaTime)
        
        PROFILE("MaturityMixin:OnMaturityUpdate")
        
        local updateRate = GetMaturityRate(self)
        
        local mistMultiplier = ConditionalValue(HasMixin(self, "Catalyst") and self:GetIsCatalysted(), kNutrientMistMaturitySpeedup, 0)
        local rate = ( (not HasMixin(self, "Construct") or self:GetIsBuilt()) and 1 or 0 ) + mistMultiplier

        self._maturityFraction = math.min(self._maturityFraction + deltaTime * (1 / updateRate) * rate, 1)
        
        local isMature = self._maturityFraction == 1
        
        -- to prevent too much network spam from happening we update only every second the max health
        if self.maturityFraction ~= self._maturityFraction and (isMature or self.timeMaturityLastUpdate + 1 < Shared.GetTime()) then

            if isMature and self.OnMaturityCompletethen then
                self:OnMaturityComplete()
            end

            self:UpdateMaturity()
            self.timeMaturityLastUpdate = Shared.GetTime()
            
        end
        
        return true
        
    end

    -- For testing.
    function MaturityMixin:SetMature()
        self.maturityFraction = 0.99
    end

    function MaturityMixin:ResetMaturity()

        self.maturityHealth = 0
        self.maturityArmor = 0
        self.maturityFraction = 0
        self._maturityFraction = 0
        self.updateMaturity = true

    end
    
    -- Add some maturity to this object, measured in seconds
    function MaturityMixin:AddMaturity(amount)
        
        -- Misnomer... NOT a rate, but 1/rate... grrr
        local secondsToMature = self:GetMaturityRate()
        local fractionalChange = amount / secondsToMature
        
        local maturityFractionBefore = self._maturityFraction
        self._maturityFraction = Clamp(self._maturityFraction + fractionalChange, 0, 1)
    
        -- Don't update if it didn't change (eg already full).
        if maturityFractionBefore ~= self._maturityFraction then
    
            -- update immediately, despite the update throttle, since this is likely the result of a
            -- player's actions.
            self:UpdateMaturity()
            self.timeMaturityLastUpdate = Shared.GetTime()
            
        end
    end

end

if Client then
    function MaturityMixin:OnMaturityUpdate()

        PROFILE("MaturityMixin:OnMaturityUpdate")

        -- TODO: maturity effects, shaders
        local model = self:GetRenderModel()
        if model then
            local fraction = self:GetMaturityFraction()
            model:SetMaterialParameter("maturity", fraction)
        end

        return kUpdateIntervalLow

    end
end
