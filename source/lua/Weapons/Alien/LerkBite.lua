-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\Alien\LerkBite.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- Bite is main attack, spikes is secondary.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/SpikesMixin.lua")
Script.Load("lua/Weapons/ClientWeaponEffectsMixin.lua")

PrecacheAsset("materials/effects/mesh_effects/view_blood.surface_shader")

-- kRange is now the range from eye to edge of attack range, ie its independent of the size of
-- the melee box, so for the skulk, it needs to increase to 1.2 to say at its previous range.
-- previously this value had an offset, which caused targets to be behind the melee attack (too close to the target and you missed)
local kRange = 1.5

local kStructureHitEffect = PrecacheAsset("cinematics/alien/lerk/bite_view_structure.cinematic")
local kMarineHitEffect = PrecacheAsset("cinematics/alien/lerk/bite_view_marine.cinematic")
local kRobotHitEffect = PrecacheAsset("cinematics/alien/lerk/bite_view_bmac.cinematic")

class 'LerkBite' (Ability)

LerkBite.kMapName = "lerkbite"

local kAnimationGraph = PrecacheAsset("models/alien/lerk/lerk_view.animation_graph")
local kViewBloodMaterial = PrecacheAsset("materials/effects/mesh_effects/view_blood.material")
local kViewOilMaterial = PrecacheAsset("materials/effects/mesh_effects/view_oil.material")
local attackEffectMaterial
local attackOilEffectMaterial
LerkBite.kAttackDuration = Shared.GetAnimationLength("models/alien/lerk/lerk_view.model", "bite")

if Client then
    attackEffectMaterial = Client.CreateRenderMaterial()
    attackEffectMaterial:SetMaterial(kViewBloodMaterial)
    attackOilEffectMaterial = Client.CreateRenderMaterial()
    attackOilEffectMaterial:SetMaterial(kViewOilMaterial)
end

local networkVars =
{
}

AddMixinNetworkVars(SpikesMixin, networkVars)

function LerkBite:OnCreate()

    Ability.OnCreate(self)
    
    InitMixin(self, SpikesMixin)
    
    self.primaryAttacking = false
    
    if Client then
        InitMixin(self, ClientWeaponEffectsMixin)
    end

end

function LerkBite:GetAnimationGraphName()
    return kAnimationGraph
end

function LerkBite:GetEnergyCost()
    return kLerkBiteEnergyCost
end

function LerkBite:GetHUDSlot()
    return 1
end

function LerkBite:GetSecondaryTechId()
    return kTechId.Spikes
end

function LerkBite:GetRange()
    return kRange
end

function LerkBite:GetDeathIconIndex()

    if self.primaryAttacking then
        return kDeathMessageIcon.LerkBite
    else
        return kDeathMessageIcon.Spikes
    end

end

function LerkBite:GetVampiricLeechScalar()
    if self.primaryAttacking then
        return kLerkBiteVampirismScalar
    else
        return kSpikesVampirismScalar
    end
end


function LerkBite:OnPrimaryAttack(player)
    local hasEnergy = player:GetEnergy() >= self:GetEnergyCost()
    local cooledDown = (not self.nextAttackTime) or (Shared.GetTime() >= self.nextAttackTime)
    if hasEnergy and cooledDown then
        self.primaryAttacking = true
    else
        self.primaryAttacking = false
    end
    
end

function LerkBite:OnPrimaryAttackEnd()
    
    Ability.OnPrimaryAttackEnd(self)
    
    self.primaryAttacking = false
    
end

function LerkBite:GetMeleeBase()
    -- Width of box, height of box
    return 0.9, 1.2
    
end

function LerkBite:GetMeleeOffset()
    return 0.0
end

function LerkBite:GetIsAffectedByFocus()
    return self.primaryAttacking
end

function LerkBite:GetAttackAnimationDuration()
    return self.kAttackDuration
end

function LerkBite:OnTag(tagName)

    PROFILE("LerkBite:OnTag")

    if tagName == "hit" then
    
        local player = self:GetParent()
        
        if player then  
        

            self:TriggerEffects("lerkbite_attack")
            self:OnAttack(player)
            
            self.spiked = false
        
            local didHit, target, endPoint, surface = AttackMeleeCapsule(self, player, kLerkBiteDamage, kRange, nil, false, EntityFilterOneAndIsa(player, "Babbler"))
            
            if didHit and target then
            
                if Server then
                    if not player.isHallucination and target:isa("Marine") and target:GetCanTakeDamage() then
                        target:SetPoisoned(player)
                    end
                elseif Client then
                    self:TriggerFirstPersonHitEffects(player, target)
                end
            
            end
            
            if target and HasMixin(target, "Live") and not target:GetIsAlive() then
                self:TriggerEffects("bite_kill")
            end
            
        end
        
    end
    
end

if Client then

    function LerkBite:TriggerFirstPersonHitEffects(player, target)
    
        if player == Client.GetLocalPlayer() and target then
        
            local cinematicName = kStructureHitEffect
            local doBloodEffect = false
            local isRobot = false
        
            if target:isa("Marine") then
                doBloodEffect = true
                isRobot = target.marineType == kMarineVariantBaseType.bigmac
                cinematicName = isRobot and kRobotHitEffect or kMarineHitEffect
            elseif target:isa("Exo") then
                doBloodEffect = true
                isRobot = true
                cinematicName = kRobotHitEffect
            elseif target:isa("MAC") then
                doBloodEffect = true
                isRobot = true
                cinematicName = kRobotHitEffect
            end
        
            if doBloodEffect then
                self:CreateBloodEffect(player, isRobot)
            end
        
            local cinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
            cinematic:SetCinematic(cinematicName)
    
        end

    end

    function LerkBite:CreateBloodEffect(player, useOil)
    
        if not Shared.GetIsRunningPrediction() then

            local model = player:GetViewModelEntity():GetRenderModel()

            model:RemoveMaterial(attackEffectMaterial)
            model:RemoveMaterial(attackOilEffectMaterial)
            local effectMaterial = useOil and attackOilEffectMaterial or attackEffectMaterial
            model:AddMaterial(effectMaterial)
            effectMaterial:SetParameter("attackTime", Shared.GetTime())

        end
        
    end

end

function LerkBite:OnUpdateAnimationInput(modelMixin)

    PROFILE("Spikes:OnUpdateAnimationInput")

    if not self:GetIsSecondaryBlocking() then
    
        modelMixin:SetAnimationInput("ability", "bite")

        local activityString = "none"
        if self.primaryAttacking then
            activityString = "primary"
        end        
        
        modelMixin:SetAnimationInput("activity", activityString)
    
    end
    
end

function LerkBite:GetDamageType()

    if self.spiked then
        return kSpikeDamageType
    else
        return kLerkBiteDamageType 
    end
    
end

Shared.LinkClassToMap("LerkBite", LerkBite.kMapName, networkVars)