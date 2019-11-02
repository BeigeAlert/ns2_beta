Log("Loading modified Balance.lua for NS2 Balance Beta mod.")

-- Changes:
-- Nano shield time _just for players_ reduced to 3 seconds from 5.
-- Changed minigun damage type to heavy.
-- Changed minigun damage amount from 10 to 6.
-- Increased lerk spikes size from 45mm to 60mm.
-- Set webbed duration to 2.5 from 1.5

-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Balance.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/BalanceHealth.lua")
Script.Load("lua/BalanceMisc.lua")

kTransformResourcesTime = 15
kTransformResourcesCost = 15
kTransformResourcesRate = 1

-- commander has  to stay in command structure for the first kCommanderMinTime seconds of each round
kCommanderMinTime = 30

kAutoBuildRate = 0.5

-- setting to true will prevent any placement and construction of marine structures on infested areas
kPreventMarineStructuresOnInfestation = false
kCorrodeMarineStructureArmorOnInfestation = true

kInfestationCorrodeDamagePerSecond = 30

kMaxSupply = 200
kSupplyPerTechpoint = 100

-- used as fallback
kDefaultBuildTime = 8

-- MARINE COSTS
kCommandStationCost = 15

kExtractorCost = 10

kExtractorArmorCost = 5
kExtractorArmorResearchTime = 20

kInfantryPortalCost = 20

kArmoryCost = 10
kArmsLabCost = 15

kAdvancedArmoryUpgradeCost = 25
kPrototypeLabCost = 35

kSentryCost = 5
kPowerNodeCost = 0

kMACCost = 5
kMineCost = 10
kDropMineCost = 15
kMineResearchCost  = 10
kTechEMPResearchCost = 0
kTechMACSpeedResearchCost = 10

kWelderTechResearchTime = 15

kGrenadeTechResearchCost = 10
kGrenadeTechResearchTime = 45

kShotgunCost = 20
kShotgunDropCost = 20
kShotgunTechResearchCost = 20
kHeavyRifleTechResearchCost = 30
kHeavyMachineGunDropCost = 20
kHeavyMachineGunTechResearchCost = 20

kClusterGrenadeCost = 2
kGasGrenadeCost = 2
kPulseGrenadeCost = 2

kGrenadeLauncherCost = 20
kGrenadeLauncherDropCost = 20
kGrenadeLauncherTechResearchCost = 15
kDetonationTimeTechResearchCost = 15

kAdvancedWeaponryResearchCost = 10

kFlamethrowerCost = 20
kFlamethrowerDropCost = 20
kFlamethrowerTechResearchCost = 20

kRoboticsFactoryCost = 10
kUpgradeRoboticsFactoryCost = 5
kUpgradeRoboticsFactoryTime = 20
kARCCost = 15
kARCSplashTechResearchCost = 15
kARCArmorTechResearchCost = 15
kWelderTechResearchCost = 0
kWelderCost = 2
kWelderDropCost = 3

kPulseGrenadeDamageRadius = 3
kPulseGrenadeEnergyDamageRadius = 10
kPulseGrenadeDamage = 50
kPulseGrenadeEnergyDamage = 0
kPulseGrenadeDamageType = kDamageType.Normal

kClusterGrenadeDamageRadius = 10
kClusterGrenadeDamage = 55
kClusterFragmentDamageRadius = 6
kClusterFragmentDamage = 20
kClusterGrenadeDamageType = kDamageType.ClusterFlame

kNerveGasDamagePerSecond = 50
kNerveGasDamageType = kDamageType.NerveGas

kJetpackCost = 15
kJetpackDropCost = 15
kJetpackTechResearchCost = 25
kJetpackFuelTechResearchCost = 15
kJetpackArmorTechResearchCost = 15

kExosuitTechResearchCost = 20
kExosuitLockdownTechResearchCost = 20

kExosuitCost = 40
kExosuitDropCost = 50
kClawRailgunExosuitCost = 40
kDualExosuitCost = 55
kDualRailgunExosuitCost = 55

kUpgradeToDualMinigunCost = 20
kUpgradeToDualRailgunCost = 20

kDualMinigunTechResearchCost = 30
kClawRailgunTechResearchCost = 30
kDualRailgunTechResearchCost = 30

kCatPackTechResearchCost = 15
kWeapons1ResearchCost = 20
kWeapons2ResearchCost = 30
kWeapons3ResearchCost = 40

kArmor1ResearchCost = 20
kArmor2ResearchCost = 30
kArmor3ResearchCost = 40
kNanoArmorResearchCost = 20

kRifleUpgradeTechResearchCost = 10

kObservatoryCost = 10
kPhaseGateCost = 15
kPhaseTechResearchCost = 10
kReversePGCooldown = 5

kResearchBioMassOneCost = 15
kBioMassOneTime = 25
kResearchBioMassTwoCost = 20
kBioMassTwoTime = 40
kResearchBioMassThreeCost = 40
kBioMassThreeTime = 60
kResearchBioMassFourCost = 100
kBioMassFourTime = 80

kHiveCost = 40

kHarvesterCost = 8

kShellCost = 15
kCragCost = 13

kSpurCost = 15
kShiftCost = 13

kVeilCost = 15
kShadeCost = 13

kWhipCost = 13
kEvolveBombardCost = 5

kGorgeCost = 10
kGorgeEggCost = 15
kLerkCost = 21
kLerkEggCost = 30
kFadeCost = 37
kFadeEggCost = 70
kOnosCost = 62
kOnosEggCost = 100

kSkulkUpgradeCost = 0
kGorgeUpgradeCost = 1
kLerkUpgradeCost = 3
kFadeUpgradeCost = 5
kOnosUpgradeCost = 8

kHydraCost = 0
kClogCost = 0
kGorgeTunnelCost = 3
kGorgeTunnelBuildTime = 18.5

kEnzymeCloudDuration = 3

kCrushCost = 0
kCarapaceCost = 0
kRegenerationCost = 0

kCamouflageCost = 0
kAuraCost = 0
kFocusCost = 0

kSilenceCost = 0
kAdrenalineCost = 0
kCelerityCost = 0

kPlayingTeamInitialTeamRes = 60
kMaxTeamResources = 200

kMarineInitialIndivRes = 15
kAlienInitialIndivRes = 12
kCommanderInitialIndivRes = 0
kMaxPersonalResources = 100

kResourceTowerResourceInterval = 6
kTeamResourcePerTick = 1

kPlayerResPerInterval = 0.125 -- was 1.25, but players now also get res while dead

kKillTeamReward = 0
kPersonalResPerKill = 0

-- MARINE DAMAGE
kRifleDamage = 10
kRifleDamageType = kDamageType.Normal
kRifleClipSize = 50

kHeavyRifleCost = 30

kHeavyRifleDamage = 10
kHeavyRifleDamageType = kDamageType.Puncture
kHeavyRifleClipSize = 75

kHeavyMachineGunCost = 20

kHeavyMachineGunDamage = 8
kHeavyMachineGunDamageType = kDamageType.MachineGun
kHeavyMachineGunClipSize = 125
kHeavyMachineGunClipNum = 4
kHeavyMachineGunRange = 100
kHeavyMachineGunSecondaryRange = 1.1
kHeavyMachineGunSpread = Math.Radians(4)

kRifleMeleeDamage = 10
kRifleMeleeDamageType = kDamageType.Normal

-- 10 bullets per second
kPistolRateOfFire = 0.1
kPistolDamage = 25
kPistolDamageType = kDamageType.Light
kPistolClipSize = 10
-- not used yet
kPistolMinFireDelay = 0.1

kPistolAltDamage = 40


kWelderDamagePerSecond = 30
kWelderDamageType = kDamageType.Flame
kWelderFireDelay = 0.2

kSelfWeldAmount = 5
kPlayerArmorWeldRate = 20

kAxeDamage = 25
kAxeDamageType = kDamageType.Structural


kGrenadeLauncherGrenadeDamage = 90
kGrenadeLauncherGrenadeDamageType = kDamageType.GrenadeLauncher
kGrenadeLauncherClipSize = 4
kGrenadeLauncherGrenadeDamageRadius = 4.8
kGrenadeLifetime = 2.0
kGrenadeUpgradedLifetime = 1.5

kShotgunFireRate = 0.88
kShotgunDamage = 11.33
kShotgunDamageType = kDamageType.Normal
kShotgunClipSize = 6
kShotgunBulletsPerShot = 13
kShotgunSpreadDistance = 10 --Gets used as z-axis value for spread vectors before normalization

kNadeLauncherClipSize = 4

kFlameRadius = 1.8

kFlamethrowerDamage = 12
kFlamethrowerDamageRadius = kFlameRadius
kFlamethrowerConeWidth = 0.3
kFlameThrowerEnergyDamage = 1
kFlamethrowerDamageType = kDamageType.Flame
kFlamethrowerClipSize = 50
kFlamethrowerRange = 9

kBurnDamagePerSecond = 8
kFlamethrowerBurnDuration = 2.1
kFlamethrowerMaxBurnDuration = 6


-- affects dual minigun and dual railgun damage output
kExoDualMinigunModifier = 1
kExoDualRailgunModifier = 1

kMinigunDamage = 6
kMinigunDamageType = kDamageType.Heavy

kClawDamage = 50
kClawDamageType = kDamageType.Structural

kRailgunDamage = 10
kRailgunChargeDamage = 140
kRailgunDamageType = kDamageType.Structural

kMACAttackDamage = 5
kMACAttackDamageType = kDamageType.Normal
kMACAttackFireDelay = 0.6


kMineDamage = 150
kMineDamageType = kDamageType.Normal

kSentryAttackDamageType = kDamageType.Normal
kSentryAttackBaseROF = .15
kSentryAttackRandROF = 0.0
kSentryAttackBulletsPerSalvo = 1
kConfusedSentryBaseROF = 2.0

kSentryDamage = 5

kARCDamage = 530
kARCDamageType = kDamageType.Splash -- splash damage hits friendly arcs as well
kARCRange = 26
kARCMinRange = 7

local kDamagePerUpgradeScalar = 0.1
kWeapons1DamageScalar = 1 + kDamagePerUpgradeScalar
kWeapons2DamageScalar = 1 + kDamagePerUpgradeScalar * 2
kWeapons3DamageScalar = 1 + kDamagePerUpgradeScalar * 3

kNanoShieldDamageReductionDamage = 0.68


-- ALIEN DAMAGE

kAlienFocusUpgradeAttackDelay = 1 --FIXME Does not account for variable attack-rates
--(i.e. different attack rates of various alien abilities: Bite ~= Swipe)


kBiteDamage = 75
kBiteDamageType = kDamageType.Normal
kBiteEnergyCost = 5.85

kLeapEnergyCost = 45

kParasiteDamage = 10
kParasiteDamageType = kDamageType.Normal
kParasiteEnergyCost = 30

kXenocideDamage = 200
kXenocideDamageType = kDamageType.Normal
kXenocideRange = 14
kXenocideEnergyCost = 30

kGorgeArmorTunnelDamagePerSecond = 10

kSpitSpeed = 43
kSpitDamage = 30
kSpitDamageType = kDamageType.Normal
kSpitEnergyCost = 7

kBabblerPheromoneEnergyCost = 7
kBabblerDamage = 8
kBabblerExplosionRange = 4
kBabblerExplosionDamage = 16
kBabblerDamageType = kDamageType.Normal
kBabblerCost = 0

kBabblerEggBuildTime = 8
kNumBabblerEggsPerGorge = 1
kBabblerEggDamage = 15 -- per second
kBabblerEggDamageType = kDamageType.ArmorOnly
kBabblerEggDamageDuration = 3
kBabblerEggDamageRadius = 7
kBabblerEggDotInterval = 0.4

-- Also see kHealsprayHealStructureRate
kHealsprayDamage = 8
kHealsprayDamageType = kDamageType.Biological
kHealsprayFireDelay = 0.8
kHealsprayEnergyCost = 10
kHealsprayRadius = 3.5

kBileBombDamage = 55 -- per second
kBileBombDamageType = kDamageType.Corrode
kBileBombEnergyCost = 20
kBileBombDuration = 5
-- 200 inches in NS1 = 5 meters
kBileBombSplashRadius = 6
kBileBombDotInterval = 0.4

kWebBuildCost = 0
kWebbedDuration = 2.5
kWebbedParasiteDuration = 10
kWebSlowVelocityScalar = 0.75 --Note: Exos override this

kLerkBiteDamage = 60
kBitePoisonDamage = 6 -- per second
kPoisonBiteDuration = 6
kLerkBiteEnergyCost = 5
kLerkBiteDamageType = kDamageType.Normal

kUmbraEnergyCost = 27
kUmbraMaxRange = 17
kUmbraDuration = 2.5
kUmbraRadius = 4

kUmbraShotgunModifier = 0.8
kUmbraBulletModifier = 0.8
kUmbraMinigunModifier = 0.8
kUmbraRailgunModifier = 0.8
kUmbraGrenadeModifier = 0.8

kSpikeSpread = Math.Radians(3.6)
kSpikeSize = 0.060
kSpikeDamage = 5
kSpikeDamageType = kDamageType.Puncture
kSpikeEnergyCost = 1.4
kSpikesAttackDelay = 0.07
kSpikesRange = 50
kSpikesPerShot = 1

kSporesDamageType = kDamageType.Gas
kSporesDustDamagePerSecond = 15
kSporesDustFireDelay = 0.36
kSporesMaxRange = 17
kSporesDustEnergyCost = 27
kSporesDustCloudRadius = 4
kSporesDustCloudLifetime = 4

kSwipeDamageType = kDamageType.Puncture
kSwipeDamage = 37.5
kSwipeEnergyCost = 7
kMetabolizeEnergyCost = 25

kStabDamage = 160
kStabDamageType = kDamageType.Normal
kStabEnergyCost = 30

kStartBlinkEnergyCost = 14
kBlinkEnergyCost = 32
kHealthOnBlink = 0

kGoreDamage = 90
kGoreDamageType = kDamageType.Structural
kGoreEnergyCost = 10

kBoneShieldDamageReduction = 0.2 --80% for frontal, if it's on-screen(default fov) it's reduced
kBoneShieldCooldown = 16
kBoneShieldMinimumEnergyNeeded = 0
kBoneShieldMinimumFuel = 0.15
kBoneShieldMaxDuration = 8
kBoneShieldMoveFraction = 0.682 -- ~4.5 m/s
kBoneShieldInnateCombatRegenRate = 0
kBoneshieldPreventInnateRegen = true
kBoneShieldPreventEnergize = false
kBoneShieldPreventRecuperation = false

kStompEnergyCost = 30
kStompDamageType = kDamageType.Heavy
kStompDamage = 40
kStompRange = 12
kDisruptMarineTime = 2
kDisruptMarineTimeout = 4

kChargeDamage = 12

kDrifterAttackDamage = 5
kDrifterAttackDamageType = kDamageType.Normal
kDrifterAttackFireDelay = 0.6

kMelee1DamageScalar = 1.1
kMelee2DamageScalar = 1.2
kMelee3DamageScalar = 1.3

kWhipSlapDamage = 50
kWhipBombardDamage = 250
kWhipBombardDamageType = kDamageType.Corrode
kWhipBombardRadius = 6
kWhipBombardRange = 10
kWhipBombardROF = 6





-- SPAWN TIMES
kMarineRespawnTime = 9

kAlienSpawnTime = 10
kEggGenerationRate = 13
kAlienEggsPerHive = 2

-- delay of a single upgrade level after alien respawn
kUpgradeLevelDelayAtAlienRepawn = 4

-- BUILD/RESEARCH TIMES
kRecycleTime = 12
kConsumeTime = kRecycleTime
kArmoryBuildTime = 12
kAdvancedArmoryResearchTime = 90
kWeaponsModuleAddonTime = 40
kPrototypeLabBuildTime = 20
kArmsLabBuildTime = 17

kMACBuildTime = 5
kExtractorBuildTime = 11

kInfantryPortalBuildTime = 7

kShotgunTechResearchTime = 30
kHeavyRifleTechResearchTime = 60
kHeavyMachineGunTechResearchTime = 30
kGrenadeLauncherTechResearchTime = 20
kAdvancedWeaponryResearchTime = 35

kCommandStationBuildTime = 15

kSentryBatteryCost = 10
kSentryBatteryBuildTime = 5

kRoboticsFactoryBuildTime = 8
kARCBuildTime = 10
kARCSplashTechResearchTime = 30
kARCArmorTechResearchTime = 30

kNanoShieldDurationPlayers = 3
kNanoShieldDuration = 5
kSentryBuildTime = 3

kNanoShieldResearchCost = 15
kNanoSnieldResearchTime = 60

kMineResearchTime  = 20
kTechEMPResearchTime = 60
kTechMACSpeedResearchTime = 15

kJetpackTechResearchTime = 90
kJetpackFuelTechResearchTime = 60
kJetpackArmorTechResearchTime = 60
kExosuitTechResearchTime = 90
kExosuitLockdownTechResearchTime = 60
kExosuitUpgradeTechResearchTime = 60

kFlamethrowerTechResearchTime = 60

kDualMinigunTechResearchTime = 60
kClawRailgunTechResearchTime = 60
kDualRailgunTechResearchTime = 60
kCatPackTechResearchTime = 45

kObservatoryBuildTime = 15
kPhaseTechResearchTime = 45
kPhaseGateBuildTime = 12

kWeapons1ResearchTime = 60
kWeapons2ResearchTime = 90
kWeapons3ResearchTime = 120
kArmor1ResearchTime = 60
kArmor2ResearchTime = 90
kArmor3ResearchTime = 120

kNanoArmorResearchTime = 60

kHiveBuildTime = 180

kDrifterBuildTime = 4
kHarvesterBuildTime = 38

kShellBuildTime = 18
kCragBuildTime = 25

kWhipBuildTime = 20
kEvolveBombardResearchTime = 15

kSpurBuildTime = 16
kShiftBuildTime = 18

kVeilBuildTime = 14
kShadeBuildTime = 18
kEvolveHallucinationsResearchTime = 30

kHydraBuildTime = 8
kCystBuildTime = 3.33

kSkulkGestateTime = 3
kGorgeGestateTime = 7
kLerkGestateTime = 15
kFadeGestateTime = 25
kOnosGestateTime = 30

kEggGestateTime = 45

kEvolutionGestateTime = 3

-- alien ability research cost / time

kAlienBrainResearchCost = 35
kAlienBrainResearchTime = 90

kAlienMusclesResearchCost = 35
kAlienMusclesResearchTime = 90

kDefensivePostureResearchCost = 35
kDefensivePostureResearchTime = 90

kOffensivePostureResearchCost = 35
kOffensivePostureResearchTime = 90

kUpgradeSkulkResearchCost = 20
kUpgradeSkulkResearchTime = 90
kUpgradeGorgeResearchCost = 30
kUpgradeGorgeResearchTime = 90
kUpgradeLerkResearchCost = 35
kUpgradeLerkResearchTime = 90
kUpgradeFadeResearchCost = 35
kUpgradeFadeResearchTime = 120
kUpgradeOnosResearchCost = 35
kUpgradeOnosResearchTime = 120


kGorgeTunnelResearchCost = 15
kGorgeTunnelResearchTime = 40
kChargeResearchCost = 15
kChargeResearchTime = 40
kLeapResearchCost = 15
kLeapResearchTime = 40
kBileBombResearchCost = 15
kBileBombResearchTime = 40
kShadowStepResearchCost = 15
kShadowStepResearchTime = 40
kUmbraResearchCost = 20
kUmbraResearchTime = 45
kBoneShieldResearchCost = 20
kBoneShieldResearchTime = 40
kSporesResearchCost = 20
kSporesResearchTime = 60
kStompResearchCost = 35
kStompResearchTime = 90
kStabResearchCost = 25
kStabResearchTime = 60
kMetabolizeEnergyResearchCost = 20
kMetabolizeEnergyResearchTime = 40
kMetabolizeHealthResearchCost = 20
kMetabolizeHealthResearchTime = 45
kXenocideResearchCost = 25
kXenocideResearchTime = 60
kWebResearchCost = 10
kWebResearchTime = 60


kCommandStationInitialEnergy = 100  kCommandStationMaxEnergy = 250
kNanoShieldCost = 3
kNanoShieldCooldown = 10
kEMPCost = 50
kNanoShieldDamageReductionDamage = 0.68

kPowerSurgeResearchCost = 15
kPowerSurgeResearchTime = 45
kPowerSurgeCooldown = 4
kPowerSurgeDuration = 10
kPowerSurgeCost = 2

kPowerSurgeTriggerEMP = false
kPowerSurgeEMPDamage = 25
kPowerSurgeEMPDamageRadius = 6
kPowerSurgeEMPElectrifiedDuration = 6

kArmoryInitialEnergy = 100  kArmoryMaxEnergy = 150

kAdvancedMarineSupportResearchCost = 20
kAdvancedMarineSupportResearchTime = 60

kAmmoPackCost = 1
kMedPackCost = 1
kMedPackCooldown = 0
kCatPackCost = 1
kCatPackMoveAddSpeed = 1.125
kCatPackWeaponSpeed = 1.25
kCatPackDuration = 5
kCatPackPickupDelay = 4

kHiveInitialEnergy = 50  kHiveMaxEnergy = 200
kMatureHiveMaxEnergy = 250
kCystCost = 1
kCystCooldown = 0.0

kDrifterInitialEnergy = 50
kDrifterMaxEnergy = 200

kEnzymeCloudCost = 2
kHallucinationCloudCost = 2
kMucousMembraneCost = 2
kStormCost = 2

kMucousShieldCooldown = 5
kMucousShieldPercent = 0.2
kMucousShieldDuration = 5

kBabblerShieldPercent = 0.1
kSkulkBabblerShieldPercent = 0.28
kGorgeBabblerShieldPercent = 0.13
kLerkBabblerShieldPercent = 0.14
kFadeBabblerShieldPercent = 0.16
kBabblerShieldMaxAmount = 85

kHallucinationLifeTime = 30

-- only allow x% of affected players to create a hallucination
kPlayerHallucinationNumFraction = 0.34
-- cooldown per entity
kHallucinationCloudCooldown = 3
kDrifterAbilityCooldown = 0
kHallucinationCloudAbilityCooldown = 12
kMucousMembraneAbilityCooldown = 1
kEnzymeCloudAbilityCooldown = 1

kNutrientMistCost = 2
kNutrientMistCooldown = 2
-- Note: If kNutrientMistDuration changes, there is a tooltip that needs to be updated.
kNutrientMistDuration = 15

kRuptureCost = 3
kRuptureCooldown = 4
kRuptureParasiteTime = 10
kRuptureBurstTime = 1.25 --Time before rupture "pops"
kRuptureEffectTime = 1.5
kRuptureEffectDuration = 3
kRuptureEffectRadius = 8.7

kBoneWallCost = 3
kBoneWallCooldown = 10

kContaminationCost = 5
kContaminationCooldown = 6
kContaminationLifeSpan = 20
kContaminationBileInterval = 2
kContaminationBileSpewCount = 3


-- 100% + X (increases by 66%, which is 10 second reduction over 15 seconds)
kNutrientMistPercentageIncrease = 66
kNutrientMistMaturingIncrease = 66

kObservatoryInitialEnergy = 25  kObservatoryMaxEnergy = 100
kObservatoryScanCost = 3
kObservatoryDistressBeaconCost = 10

kMACInitialEnergy = 50  kMACMaxEnergy = 150
kDrifterCost = 8
kDrifterCooldown = 0
kDrifterHatchTime = 7

kDrifterBuildRate = 1.25

kTunnelEntranceCost = 6
kTunnelExitCost = 6
kTunnelRelocateCost = 6
kTunnelBuildTime = 18.5

kUpgradeInfestedTunnelEntranceCost = 6
kUpgradeInfestedTunnelEntranceResearchTime = 18.5

kCragInitialEnergy = 25  kCragMaxEnergy = 100 
kCragHealWaveCost = 3
kHealWaveCooldown = 6
kMatureCragMaxEnergy = 150

kHydraDamage = 15
kHydraAttackDamageType = kDamageType.Normal

kWhipInitialEnergy = 25  kWhipMaxEnergy = 100
kMatureWhipMaxEnergy = 150

kShiftInitialEnergy = 50  kShiftMaxEnergy = 150
kShiftHatchCost = 5
kShiftHatchRange = 11
kMatureShiftMaxEnergy = 200

kEchoHydraCost = 1
kEchoWhipCost = 2
kEchoTunnelCost = 5
kEchoCragCost = 1
kEchoShadeCost = 1
kEchoShiftCost = 1
kEchoVeilCost = 1
kEchoSpurCost = 1
kEchoShellCost = 1
kEchoHiveCost = 10
kEchoEggCost = 2
kEchoHarvesterCost = 2

kShadeInitialEnergy = 25  kShadeMaxEnergy = 100
kShadeInkCost = 3
kShadeInkCooldown = 16
kShadeInkDuration = 6.3
kMatureShadeMaxEnergy = 150

kEnergyUpdateRate = 0.5

-- This is for CragHive, ShadeHive and ShiftHive
kUpgradeHiveCost = 10
kUpgradeHiveResearchTime = 20

kHiveBiomass = 1

kCragBiomass = 0
kShadeBiomass = 0
kShiftBiomass = 0
kWhipBiomass = 0
kHarvesterBiomass = 0
kShellBiomass = 0
kVeilBiomass = 0
kSpurBiomass = 0
