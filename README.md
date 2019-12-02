# NS2 Balance Beta
**SteamWorks Mod ID**: *718da717*

This mod contains various balance changes based on various ideas of the NS2 balance team.

Join the official ns2 discord server (discord.gg/ns2) to leave feedback!


## Full Changelog:
- Marine
    - Shotgun
        - Reverted to build 326-behavior.
            - 17 pellets, each deal 10 damage.
            - Divided into 4 rings of 4 pellets each, +1 pellet in the middle.
            - Pellet sizes are all 16mm.
            - No Damage Falloff.
    - HMG
        - Reload time is now 3.5 seconds (down from 5 seconds)
    - Mines
        - Mines can now be properly killed during their arming period when first deployed. In this case, they do not explode or deal               damage.
        - Marines now keep unused mines when they die and receive them back when they respawn (like hand grenades).
        - Health changed to 40 (up from 30)
        - Lerk spikes deal 2x damage to mines (Damage: 5 -> 10).
        - Mines now award 5 score points when killed by an alien.
    - Hand Grenades
        - Removed lengthy deploy animation so grenades are now thrown much faster. (quickthrow and regular throw)
    - Exosuit
        - Reduced opacity of "scanlines" UI texture to be less obstructive (25% of original value).
        - Exos are now free to fire their weapons while thrusters are being used.
        - Thrusters can now be toggled on and off freely without waiting for maximum charge between use.
            - Thruster fuel now has a 0.75 second cooldown before recharging after last use.
        - Exosuits now "self-repair" when out of combat at a rate of 10 armor/second.
        - Alien Vampirism no longer has any effect when used against exos.
        - Railgun
            - Both railguns can fire simultaneously now.
            - Full-charge duration is now 1 second
            - Cooldown between shots is now 0.3 seconds.
            - Anything short of a full-charge shot no longer penetrates targets.
            - Shots with 75% power and above now convert to "heavy" damage type (double damage to armor), 74% power and below charge                   shots are regular damage.
            - Distortion tracer effect and steam effects no longer play if the shot didn't deal heavy damage (75% charge).
            - Damage ramps up from 25 to 50 as you charge.
        - Minigun
            - Damage type is now "heavy" (double damage to armor).
            - Damage: 10 -> 6
            - Overheat animation sped up such that the time out of combat now matches up exactly with the heat meter for that weapon (before, the overheat animation would finish well-after the heat meter was empty).
    - Misc
        - Marine dropped weapon decay timer is now 16 seconds (down from 25)
        - Nanoshield duration is now 3 seconds when used on players (down from 5) -Nanoshield used on structures remains unchanged at 5           seconds.
- Alien
    - Skulk
        - Model size decreased by 10% (90% original size).
        - Skulk sneak speed reduced to 4.0 (down from 4.785)
        - Skulks now only recieve a speed boost from a consecutive jump.
        
    - Gorge
        - Heal spray
            - Now also adds maturity to alien structures and speeds up player evolutions while they are embryos.
        - Hydra
            - Hydras are now extremely accurate. Accuracy tapers off starting at 8 meters up to the maximum degredation                               at 12 meters. Inaccuracy ramps between 0 and 8 degrees.
            - Hydras can now shoot back from the last spot they were hit, so if you can hit them, they can hit you.
            - Damage reduced to 5 (down from 15)
        - Web
            - Now break on contact.
            - Snare now reduces movement speed by 66% and tapers off gradually over 2.5 seconds (up from 1.5 seconds)
            - Webs now turn invisible, only fading into view at 5 meters or closer.
            - No longer parasite marines.
            - No longer appears in the kill-feed.
    - Lerk
        - Projectile size is now 60mm (up from 45mm)
    - Fade
        - Stab
            - Stab now deals 2x damage to structures (equivilent to skulk structure DPS).
            - Fades can now blink, jump and move freely while performing stab.
        - Fades now only receive speed bonuses from consecutive blinks when using celerity.
    - Vampirism
        - Skulks now recover 14% health per bite (down from 20%)
        - Vampirism no longer has any effect when used against Exosuits.
    - Misc
        - Maturity information is now visible in the nameplate for alien structures.
        - Crag, Shade, and Shift supply cost: 25 -> 20.
