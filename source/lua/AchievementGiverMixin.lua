Log("Loading modified AchievementGiverMixin.lua for NS2 Balance Beta mod.")

-- Changes:
-- Don't give points for players that weld themselves (exo auto weld).

-- ======= Copyright (c) 2003-2016, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\AchievementGiverMixin.lua
--
--    Created by:   Sebastian Schuck (sebastian@naturalselection2.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

-- This mixin assigns event based achievements to the players
AchievementGiverMixin = CreateMixin(AchievementGiverMixin)
AchievementGiverMixin.type = "AchievementGiver"

function AchievementGiverMixin:__initmixin()
    
    PROFILE("AchievementGiverMixin:__initmixin")
    
    self.lastSneak = 0
    self.lastAttacks = {}
    self.weldedUnits = {}
end

if Server then

    function AchievementGiverMixin:PreUpdateMove(input, runningPrediction)
        if self.movementModiferState then
            self.lastSneak = Shared.GetTime()
        end
    end

    function AchievementGiverMixin:OnTaunt()
        if self.lastTimeKilled and self.lastTimeKilled + 5 > Shared.GetTime() then
            Server.SetAchievement(self:GetClient(), "Short_2_6")
        end
    end

    function AchievementGiverMixin:OnAddHealth()
        if self.GetClient and self:GetClient() and self:GetHealth() < 2 then
            Server.SetAchievement(self:GetClient(), "Short_2_4")
        end
    end

    function AchievementGiverMixin:OnCommanderStructureLogout(hive)
        self.commanderLogoutTime = Shared.GetTime()
    end

    function AchievementGiverMixin:SetGestationData(techIds, previousTechId, healthScalar, armorScalar)
        if techIds and self.GetClient and self:GetClient() then
            --lifeform counts as one tech
            if #techIds == 2 then
                Server.SetAchievement(self:GetClient(), "Short_1_13")
            elseif #techIds == 4 then
                Server.SetAchievement(self:GetClient(), "Short_1_14")
            end
        end
    end

    function AchievementGiverMixin:SetParasited(fromPlayer)
        if not fromPlayer then return end

        if self:isa("Player") and not self.parasited then
            fromPlayer:AddParsitedPlayers()
        end
    end

    function AchievementGiverMixin:OnWeldTarget(target)
        if not target then return end
        if self == target then return end

        local targetId = target:GetId()
        if not self.weldedUnits[targetId] then
            self.weldedUnits[targetId] = true

            if target:isa("PowerPoint") then
                self:AddWeldedPowerNodes()
            elseif target:isa("Player") then
                self:AddWeldedPlayers()
            end
        end
    end

    function AchievementGiverMixin:OnConstruct(builder, newFraction, oldFraction)
        if not (self:isa("Hive") or self:isa("Extractor")) then return end

        if not self.constructContributions then
            self.constructContributions = {}
            self.constructContributors = {}
        end

        if builder and GetAreFriends(self, builder) then
            local builderId = builder:GetId()

            if not self.constructContributions[builderId] then
                self.constructContributions[builderId] = 0
                table.insert(self.constructContributors, builderId)
            end

            self.constructContributions[builderId] = self.constructContributions[builderId] + (newFraction - oldFraction)
        end
    end

    function AchievementGiverMixin:OnConstructionComplete(builder)
        --reward if player contributed more than 33%
        if self.constructContributors then
            for i = 1, #self.constructContributors do
                local builderId = self.constructContributors[i]
                local constructionFraction = self.constructContributions[builderId]

                if constructionFraction > 0.33 then
                    local builder = Shared.GetEntity(builderId)
                    local client = builder and builder.GetClient and builder:GetClient()

                    if client then
                        if self:isa("Extractor") then
                            builder:AddBuildResTowers()
                        else -- Hive
                            Server.SetAchievement(client, "Short_1_7")
                        end
                    end
                end
            end

            self.constructContributors = nil
            self.constructContributions = nil
        end
    end

    function AchievementGiverMixin:OnTakeDamage(damage, attacker, doer, point, direction, damageType, preventAlert)
        if attacker and attacker:isa("Player") and GetAreEnemies(self, attacker) then
            if self:isa("Player") then
                attacker:AddPlayerDamageDealt(damage)

                if #self.lastAttacks == 5 then self.lastAttacks[5] = nil end
                table.insert(self.lastAttacks, 1, {attacker:GetId(), doer and doer.kMapName or ""})

            elseif HasMixin(self, "Construct") or HasMixin(self, "Research") then
                attacker:AddStructureDamageDealt(damage)
            end
        end
    end

    function AchievementGiverMixin:PreOnKill(attacker, doer, point, direction)
        if attacker and attacker.GetClient and attacker:GetClient() and GetAreEnemies(self, attacker) and not self.isHallucination then
            attacker.lastTimeKilled = Shared.GetTime()

            --check for lifeforms
            if self:isa("Skulk") then
                Server.SetAchievement(attacker:GetClient(), "Short_0_6")
            elseif self:isa("Gorge") then
                Server.SetAchievement(attacker:GetClient(), "Short_0_7")
            elseif self:isa("Lerk") then
                Server.SetAchievement(attacker:GetClient(), "Short_0_8")
            elseif self:isa("Fade") then
                Server.SetAchievement(attacker:GetClient(), "Short_0_9")
            elseif self:isa("Onos") then
                Server.SetAchievement(attacker:GetClient(), "Short_0_10")
            end

            --check for structures
            if self:isa("CommandStructure") then
                Server.SetAchievement(attacker:GetClient(), "Short_2_3")
            elseif self:isa("ResourceTower") then
                attacker:AddKilledResTowers()
            end

            --check for weapons
            if self:isa("Marine") then
                for i = 1, self:GetNumChildren() do
                    local child = self:GetChildAtIndex(i - 1)
                    if child:isa("Shotgun") then
                        Server.SetAchievement(attacker:GetClient(), "Short_1_8")
                    elseif child:isa("Flamethrower") then
                        Server.SetAchievement(attacker:GetClient(), "Short_1_9")
                    elseif child:isa("GrenadeLauncher") then
                        Server.SetAchievement(attacker:GetClient(), "Short_1_10")
                    end
                end
            elseif self:isa("Exo") then
                Server.SetAchievement(attacker:GetClient(), "Short_1_11")
            end

            if self.commanderLogoutTime and self.commanderLogoutTime + 10 > Shared.GetTime() then
                Server.SetAchievement(attacker:GetClient(), "Short_2_7")
            end

            if self.GetClient and self:GetClient() then
                --check for devs
                local userId = self:GetClient():GetUserId()
                if Badges_HasDevBadge(userId) then
                    Server.SetAchievement(attacker:GetClient(), "Short_2_5")
                end

                --check res structures in range of attacker
                local attackerTeam = attacker:GetTeamNumber()
                local resTower = GetEntitiesForTeamWithinRange("ResourceTower", attackerTeam, attacker:GetOrigin(), 5)
                if resTower and #resTower > 0 then
                    attacker:AddDefendedResTowers()
                else
                    -- check if target was in range of a res structure
                    resTower = GetEntitiesForTeamWithinRange("ResourceTower", attackerTeam, self:GetOrigin(), 5)
                    if resTower and #resTower > 0 then
                        attacker:AddDefendedResTowers()
                    end
                end

                --check health
                if attacker:isa("Alien") then
                    if attacker:GetHealthScalar() == 1 then
                        Server.SetAchievement(attacker:GetClient(), "Short_1_20")
                    end

                    if attacker.lastSneak + 2 > Shared.GetTime() and attacker:isa("Skulk") then
                        Server.SetAchievement(attacker:GetClient(), "Short_1_15")
                    end

                    local bites = 0
                    local parasites = 0
                    for _, data in ipairs(self.lastAttacks) do
                        if data[1] ~= attacker:GetId() then
                            bites = 0
                            break
                        end

                        if data[2] == "bite" then
                            bites = bites + 1
                        elseif data[2] == "parasite" then
                            parasites = parasites + 1
                        end
                    end

                    if bites == 2 and parasites == 1 then
                        Server.SetAchievement(attacker:GetClient(), "Short_1_19")
                    end
                end
            end

            --add ressource costs
            attacker:AddDestroyedRessources(LookupTechData(self:GetTechId(), kTechDataCostKey, 0))
        end
    end
end