Log("Loading modified BalanceMisc.lua for NS2 Balance Beta mod.")

-- Changes:
-- Changed weapon expiration time from 25 -> 16 seconds.
-- Changed crag, shift, and shade supply cost from 25 -> 20.

-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\BalanceMisc.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

kAlienStructureMoveSpeed = 1.5
kShiftStructurespeedScalar = 1

kPoisonDamageThreshhold = 5

kSpawnBlockRange = 5

kInfestationBuildModifier = 0.75

-- Time spawning alien player must be in egg before hatching
kAlienSpawnTime = 2
kInitialMACs = 0
-- Construct at a slower rate than players
kMACConstructEfficacy = .3
kFlamethrowerAltTechResearchCost = 20
kDefaultFov = 90
kEmbryoFov = 100
kSkulkFov = 105
kGorgeFov = 95
kLerkFov = 100
kFadeFov = 90
kOnosFov = 90
kExoFov = 95

kNanoArmorHealPerSecond = 0.5

kResearchMod = 1

kMinSupportedRTs = 0
kRTsPerTechpoint = 3

kEMPBlastEnergyDamage = 50

kEnzymeAttackSpeed = 1.25
kElectrifiedAttackSpeed = 0.8
kElectrifiedDuration = 5

kHallucinationHealthFraction = 0.20
kHallucinationArmorFraction = 0
kHallucinationMaxHealth = 700

-- set to -1 for no time limit
kParasiteDuration = 44

-- increases max speed by 1.5 m/s
kCelerityAddSpeed = 1.5

-- crush extra damage
kAlienCrushDamagePercentByLevel = 0.07  --Max 21%

-- Increases the delay between alien attacks by the given value in percentage while using the Focus upgrade.
kFocusAttackSlowAtMax = 0.33
kFocusDamageBonusAtMax = 0.33

kStabFocusDamageBonusAtMax = kFocusDamageBonusAtMax -- anticipating this will need tweaking later

-- special case for gorge spit
kSpitFocusAttackSlowAtMax = 0
kSpitFocusDamageBonusAtMax = 0.33

kHydrasPerHive = 3
kClogsPerHive = 10
kNumWebsPerGorge = 3
kCystInfestDuration = 37.5

kSentriesPerBattery = 3

kStructureCircleRange = 4
kInfantryPortalAttachRange = 10
kArmoryWeaponAttachRange = 10
kArmoryDroppedWeaponAttachRange = 4
-- Minimum distance that initial IP spawns away from team location
kInfantryPortalMinSpawnDistance = 4
kSecondInitialInfantryPortalMinPlayerCount = 9

kItemStayTime = 30    -- NS1
kWeaponStayTime = 16
kWeaponDropRateLimit = 0.4

-- For power points
kMarineRepairHealthPerSecond = 600
-- The base weapons need to cost a small amount otherwise they can
-- be spammed.
kRifleCost = 0
kPistolCost = 0
kAxeCost = 0
kInitialDrifters = 0
kSkulkCost = 0

kMACSpeedAmount = .5
-- How close should MACs/Drifters fly to operate on target
kCommandStationEngagementDistance = 4
kInfantryPortalEngagementDistance = 2
kArmoryEngagementDistance = 3
kArmsLabEngagementDistance = 3
kExtractorEngagementDistance = 2
kObservatoryEngagementDistance = 1
kPhaseGateEngagementDistance = 2
kRoboticsFactorEngagementDistance = 5
kARCEngagementDistance = 2
kSentryEngagementDistance = 2
kPlayerEngagementDistance = 1
kExoEngagementDistance = 1.5
kOnosEngagementDistance = 2
kLerkSporeShootRange = 10

-- entrance and exit
kNumGorgeTunnels = 2

kTunnelCollapseWarningDuration = 5.0
kTunnelCollapseDPS = 10

-- maturation time for alien buildings
kHiveMaturationTime = 220
kHarvesterMaturationTime = 150
kWhipMaturationTime = 120
kCragMaturationTime = 120
kShiftMaturationTime = 90
kShadeMaturationTime = 120
kVeilMaturationTime = 60
kSpurMaturationTime = 60
kShellMaturationTime = 60
kCystMaturationTime = 20
kHydraMaturationTime = 140
kBabblerEggMaturationTime = 20
kTunnelEntranceMaturationTime = 135

kNutrientMistMaturitySpeedup = 2
kNutrientMistAutobuildMultiplier = 1

kMinBuildTimePerHealSpray = 0.9
kMaxBuildTimePerHealSpray = 1.8

-- Marine buy costs
kFlamethrowerAltCost = 25

-- Scanner sweep
kScanDuration = 10
kScanRadius = 20

-- Distress Beacon (NS1 range: 25)
kDistressBeaconRange = 40
kDistressBeaconTime = 3

kEnergizeRange = 17
-- per stack
kEnergizeEnergyIncrease = .25
kStructureEnergyPerEnergize = 0.15
kPlayerEnergyPerEnergize = 15
kEnergizeUpdateRate = 1

kEchoRange = 8

kSprayDouseOnFireChance = 2

-- Players get energy back at this rate when on fire
kOnFireEnergyRecuperationScalar = 1

-- Players get energy back at this rate when electrified
kElectrifiedEnergyRecuperationScalar = .7

-- Infestation
kStructureInfestationRadius = 2
kHiveInfestationRadius = 20
kInfestationRadius = 7.5
kGorgeInfestationLifetime = 60
kMarineInfestationSpeedScalar = .1

kDamageVelocityScalar = 2.5

-- Each upgrade costs this much extra evolution time
kUpgradeGestationTime = 2

-- Cyst parent ranges, how far a cyst can support another cyst
--
-- NOTE: I think the range is a bit long for kCystMaxParentRange, there will be gaps between the
-- infestation patches if the range is > kInfestationRadius * 1.75 (about).
--
kHiveCystParentRange = 31 -- distance from a hive a cyst can be connected
kCystMaxParentRange = 31 -- distance from a cyst another cyst can be placed
kCystRedeployRange = 7 -- distance from existing Cysts that will cause redeployment

-- Damage over time that all cysts take when not connected
kCystUnconnectedDamage = 20

-- Light shaking constants
kOnosLightDistance = 50
kOnosLightShakeDuration = .2
kLightShakeMaxYDiff = .05
kLightShakeBaseSpeed = 30
kLightShakeVariableSpeed = 30

-- Jetpack
kUpgradedJetpackUseFuelRate = .19
kJetpackingAccel = 0.8
kJetpackUseFuelRate = .21
kJetpackReplenishFuelRate = .11

-- Mines
kNumMines = 2
kMineActiveTime = 4
kMineAlertTime = 8
kMineDetonateRange = 5
kMineTriggerRange = 1.5

-- Onos
kGoreMarineFallTime = 1
kDisruptTime = 5

kEncrustMaxLevel = 5
kSpitObscureTime = 8
kGorgeCreateDistance = 6.5

kMaxTimeToSprintAfterAttack = .2

-- Welding variables
-- Also: MAC.kRepairHealthPerSecond
-- Also: Exo -> kArmorWeldRate
kWelderPowerRepairRate = 220
kBuilderPowerRepairRate = 220
kWelderSentryRepairRate = 150
kPlayerWeldRate = 30
kStructureWeldRate = 90
kDoorWeldTime = 15

kHatchCooldown = 4
kEggsPerHatch = 2

kAlienRegenerationTime = 2

kAlienInnateRegenerationPercentage  = 0.02
kAlienMinInnateRegeneration = 1
kAlienMaxInnateRegeneration = 20

-- used for regeneration upgrade
kAlienRegenerationPercentage = 0.08
kAlienMinRegeneration = 6
kAlienMaxRegeneration = 80

kOnFireHealingScalar = 0.5

-- timeout in seconds after an entity is flagged as "not in combat" if it didn't take or deal any damage
kCombatTimeOut = 3

-- when under fire self healing (innate healing or through upgrade) is multiplied with this value
kAlienRegenerationCombatModifier = 0

kCarapaceSpeedReduction = 0.0
kSkulkCarapaceSpeedReduction = 0 --0.08
kGorgeCarapaceSpeedReduction = 0 --0.08
kLerkCarapaceSpeedReduction = 0 --0.15
kFadeCarapaceSpeedReduction = 0 --0.15
kOnosCarapaceSpeedReduction = 0 --0.12

-- how much of the health points vamparism restores with each sucessfull attack
kBiteLeapVampirismScalar = 0.0667
kParasiteVampirismScalar = 0
kSpitVampirismScalar = 0.0267
kHealSprayVampirismScalar = 0
kLerkBiteVampirismScalar = 0.0267
kSpikesVampirismScalar = 0
kSwipeVampirismScalar = 0.0333
kStabVampirismScalar = 0.0667
kGoreVampirismScalar = 0.0183

-- Carries the umbra cloud for x additional seconds
kUmbraRetainTime = 2.5

kBellySlideCost = 20
kLerkFlapEnergyCost = 3
kFadeShadowStepCost = 11
kChargeEnergyCost = 20 -- per second


kAbilityMaxEnergy = 100
kAdrenalineAbilityMaxEnergy = 160

kPistolWeight = 0.0
kRifleWeight = 0.13
kHeavyRifleWeight = 0.25
kHeavyMachineGunWeight = 0.18
kGrenadeLauncherWeight = 0.15
kFlamethrowerWeight = 0.14
kShotgunWeight = 0.14

kJetpackWeightLiftForce = 0.13 --How much weight the jetpack lifts
kMinWeightJetpackFuelFactor = 0.8 --Min factor that gets applied on fuel usage of jetpack

kHandGrenadeWeight = 0.1
kLayMineWeight = 0.10

kClawWeight = 0.01
kMinigunWeight = 0.06
kRailgunWeight = 0.045

--McG: Below values are only applicable to dropped weapons, not player movement.
--this is also not accurate in the pure physics sense, it's just about how it feels in game.
kDefaultMarineWeaponMass = 16
kMarineWeaponTossImpulse = 72

kDropStructureEnergyCost = 15

kMinWebLength = 0.5
kMaxWebLength = 8

kMACSupply = 5
kArmorySupply = 5
kObservatorySupply = 25
kARCSupply = 25
kSentrySupply = 10
kSentryBatterySupply = 15
kRoboticsFactorySupply = 5
kInfantryPortalSupply = 0
kPhaseGateSupply = 0

kDrifterSupply = 5
kWhipSupply = 30
kCragSupply = 20
kShadeSupply = 20
kShiftSupply = 20
