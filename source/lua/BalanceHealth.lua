Log("Loading modified BalanceHealth.lua for NS2 Balance Beta mod.")

-- Changes:
-- Reduced mine HP from 40 to 30 (for a total of 50 eHP once you include armor).

-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--        
-- lua\BalanceHealth.lua        
--        
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)            
--        
-- ========= For more information, visit us at http://www.unknownworlds.com =====================        

--Time interval allowed for healing to be clamped
kHealingClampInterval = 1
kHealingClampMaxHPAmount = 0.14
kHealingClampReductionScalar = 0.34

-- HEALTH AND ARMOR        
kMarineHealth = 100    kMarineArmor = 30    kMarinePointValue = 5
kJetpackHealth = 100    kJetpackArmor = 30    kJetpackPointValue = 10
kExosuitHealth = 100    kExosuitArmor = 320    kExosuitPointValue = 20

--Medpack
kMedpackHeal = 25
kMedpackPickupDelay = 0.45
kMarineRegenerationHeal = 25 --Amount of hp per second

kLayMinesPointValue = 2
kGrenadeLauncherPointValue = 10
kShotgunPointValue = 10
kHeavyMachineGunValue = 15
kFlamethrowerPointValue = 7

kMinigunPointValue = 10
kRailgunPointValue = 10
        
kSkulkHealth = 75    kSkulkArmor = 10    kSkulkPointValue = 5    kSkulkHealthPerBioMass = 3
kGorgeHealth = 160   kGorgeArmor = 75    kGorgePointValue = 7    kGorgeHealthPerBioMass = 2
kLerkHealth = 180    kLerkArmor = 30     kLerkPointValue = 15    kLerkHealthPerBioMass = 2
kFadeHealth = 250    kFadeArmor = 80     kFadePointValue = 20    kFadeHealthPerBioMass = 5
kOnosHealth = 700    kOnosArmor = 450    kOnosPointValue = 30    kOnosHealtPerBioMass = 50

kMarineWeaponHealth = 400
        
kEggHealth = 350    kEggArmor = 0    kEggPointValue = 1

kBabblerHealth = 12    kBabblerArmor = 0    kBabblerPointValue = 0
kBabblerHealthPerBioMass = 1.25

kBabblerEggHealth = 200    kBabblerEggArmor = 0    kBabblerEggPointValue = 0
kMatureBabblerEggHealth = 300 kMatureBabblerEggArmor = 0

        
kArmorPerUpgradeLevel = 20
kExosuitArmorPerUpgradeLevel = 30
kArmorHealScalar = 1 -- 0.75

kParasitePlayerPointValue = 1
kBuildPointValue = 5
kRecyclePaybackScalar = 0.75

kCarapaceHealReductionPerLevel = 0.0

kSkulkArmorFullyUpgradedAmount = 25
kGorgeArmorFullyUpgradedAmount = 100
kLerkArmorFullyUpgradedAmount = 50
kFadeArmorFullyUpgradedAmount = 120
kOnosArmorFullyUpgradedAmount = 650

kBalanceOffInfestationHurtPercentPerSecond = 0.02
kMinOffInfestationHurtPerSecond = 20

-- used for structures
kStartHealthScalar = 0.3

kArmoryHealth = 1500    kArmoryArmor = 200    kArmoryPointValue = 5
kAdvancedArmoryHealth = 3000    kAdvancedArmoryArmor = 500    kAdvancedArmoryPointValue = 10
kCommandStationHealth = 3000    kCommandStationArmor = 1500    kCommandStationPointValue = 20
kObservatoryHealth = 700    kObservatoryArmor = 500    kObservatoryPointValue = 10
kPhaseGateHealth = 1500    kPhaseGateArmor = 800    kPhaseGatePointValue = 10
kRoboticsFactoryHealth = 2500    kRoboticsFactoryArmor = 400    kRoboticsFactoryPointValue = 5
kARCRoboticsFactoryHealth = 2800    kARCRoboticsFactoryArmor = 600    kARCRoboticsFactoryPointValue = 7
kPrototypeLabHealth = 3000    kPrototypeLabArmor = 500    kPrototypeLabPointValue = 20
kInfantryPortalHealth = 1525    kInfantryPortalArmor = 500    kInfantryPortalPointValue = 10
kArmsLabHealth = 1650    kArmsLabArmor = 500    kArmsLabPointValue = 15
kSentryBatteryHealth = 600    kSentryBatteryArmor = 200    kSentryBatteryPointValue = 5

-- 5000/1000 is good average (is like 7,000 health from NS1)
kHiveHealth = 4000    kHiveArmor = 750    kHivePointValue = 30
kBioMassUpgradePointValue = 10 kUgradedHivePointValue = 5
kMatureHiveHealth = 6000 kMatureHiveArmor = 1400
        
kDrifterHealth = 300    kDrifterArmor = 20    kDrifterPointValue = 5
kMACHealth = 300    kMACArmor = 50    kMACPointValue = 2
kMineHealth = 30    kMineArmor = 5    kMinePointValue = 5
        
kExtractorHealth = 2400 kExtractorArmor = 1050 kExtractorPointValue = 15
kExtractorArmorAddAmount = 700 -- not used

-- (2500 = NS1)
kHarvesterHealth = 2000 kHarvesterArmor = 200 kHarvesterPointValue = 15
kMatureHarvesterHealth = 2300 kMatureHarvesterArmor = 320

kSentryHealth = 500    kSentryArmor = 100    kSentryPointValue = 2
kARCHealth = 2600    kARCArmor = 400    kARCPointValue = 5
kARCDeployedHealth = 2600    kARCDeployedArmor = 0
        
kShellHealth = 600     kShellArmor = 150     kShellPointValue = 12
kMatureShellHealth = 700     kMatureShellArmor = 200

kCragHealth = 480    kCragArmor = 160    kCragPointValue = 10
kMatureCragHealth = 560    kMatureCragArmor = 272    kMatureCragPointValue = 10
        
kWhipHealth = 650    kWhipArmor = 175    kWhipPointValue = 10
kMatureWhipHealth = 720    kMatureWhipArmor = 240    kMatureWhipPointValue = 10
        
kSpurHealth = 800     kSpurArmor = 50     kSpurPointValue = 12
kMatureSpurHealth = 900  kMatureSpurArmor = 100  kMatureSpurPointValue = 12

kShiftHealth = 600    kShiftArmor = 60    kShiftPointValue = 10
kMatureShiftHealth = 880    kMatureShiftArmor = 120    kMatureShiftPointValue = 10

kVeilHealth = 900     kVeilArmor = 0     kVeilPointValue = 12
kMatureVeilHealth = 1100     kMatureVeilArmor = 0     kVeilPointValue = 12

kShadeHealth = 600    kShadeArmor = 0    kShadePointValue = 10
kMatureShadeHealth = 1200    kMatureShadeArmor = 0    kMatureShadePointValue = 10

kHydraHealth = 125    kHydraArmor = 5    kHydraPointValue = 2
kMatureHydraHealth = 160   kMatureHydraArmor = 20    kMatureHydraPointValue = 2
kHydraHealthPerBioMass = 16

kClogHealth = 250  kClogArmor = 0 kClogPointValue = 0
kClogHealthPerBioMass = 4

kWebHealth = 25

kCystHealth = 50    kCystArmor = 1
kMatureCystHealth = 300    kMatureCystArmor = 1    kCystPointValue = 1
kMinMatureCystHealth = 200 kMinCystScalingDistance = 48 kMaxCystScalingDistance = 168

kBoneWallHealth = 100 kBoneWallArmor = 0    kBoneWallHealthPerBioMass = 100
kContaminationHealth = 1000 kContaminationArmor = 0    kContaminationPointValue = 2

kPowerPointHealth = 2000    kPowerPointArmor = 1000    kPowerPointPointValue = 10
kDoorHealth = 2000    kDoorArmor = 1000    kDoorPointValue = 0

kTunnelEntranceHealth = 1000   kTunnelEntranceArmor = 100    kTunnelEntrancePointValue = 5
kMatureTunnelEntranceHealth = 1250    kMatureTunnelEntranceArmor = 200

kInfestedTunnelEntranceHealth = 1250    kInfestedTunnelEntranceArmor = 200
kMatureInfestedTunnelEntranceHealth = 1400    kMatureInfestedTunnelEntranceArmor = 250

kTunnelStartingHealthScalar = 0.18 --Percentage of kTunnelEntranceHealth & kTunnelEntranceArmor newly placed Tunnel has

