# NS2 Balance Beta
**SteamWorks Mod ID**: *718da717*

This mod contains various balance changes based on various ideas of the NS2 balance team.

Join the official ns2 discord server (discord.gg/ns2) to leave feedback!

## November 5, 2019 Initial Release
- Marine
    - Shotgun
        - Damage: 170 -> 130 total
            - Inner shots (middle + middle ring) damage 12.57 each pellet, w/ pellet size of 45mm (up from 16mm)
            - Outer ring damage 7.70 damage each pellet, w/ pellet size of 65mm (up from 32mm)
        - Fire rate: 1.13 -> 1.48 shots/sec
        - Removed damage falloff (compared to live via extension)
    - HMG
        - Reload time: 5 -> 3.5 seconds.
    - Mines
        - Mines can now be killed before they are "active".  In this case, they do not explode.
        - Marines keep unused mines when they die and receive them back when they respawn (like hand grenades).
        - HP: 50 -> 40
        - Lerk spikes deal 2x damage to mines (Damage: 5 -> 10).
    - Hand Grenades
        - Deploy animation can be skipped so grenades can be switched to and thrown much faster.
    - Exosuit
        - Reduced opacity of "scanlines" texture to about 25% of original value.
        - Exosuits now "self-repair" when out of combat at a rate of 10 armor/second.
        - Railgun
            - Both railguns can fire simultaneously now.
            - Full-charge duration now 1.5 seconds.
            - Cooldown between shots is now 0.3 seconds.
            - Anything short of a full-charge shot no longer penetrates targets.
            - Full-charge shots are "heavy" damage type (double damage to armor), non-full-charge shots are regular damage.
            - Damage ramps up from 15 to 50 as you charge.
        - Minigun
            - Damage type is now "heavy" (double damage to armor).
            - Damage: 10 -> 6
            - Overheat animation sped up such that the time out of combat now matches up exactly with the heat meter for that weapon (before, the overheat animation would finish well-after the heat meter was empty).
    - Misc
        - Weapon decay timer: 25 -> 16 seconds.
        - Nanoshield duration: 5 -> 3 seconds for players (structures remain at 5 seconds).
- Alien
    - Skulk
        - Model size decreased by 10% (90% original size).
    - Gorge
        - Heal spray
            - Now adds maturity to alien structures and speeds up player evolution.
        - Hydra
            - Hydras are now just about 100% accurate.
            - Hydras can now shoot back from the last spot they were hit, so if you can hit them, they can hit you.
            - Damage: 15 -> 10
        - Web
            - Webs now cloak, and are impossible to spot unless you get close
                - Webs visible no further than 5m.
                - De-cloak when marines get close (~2.5m)
            - Webs no longer parasite marines.
            - Slow duration: 1.5s -> 2.5s
            - Webs no longer appear in the kill-feed.
    - Lerk
        - Projectile size: 45mm -> 60mm.  Should be easier to hit marines now.
    - Fade
        - Stab
            - Stab now deals 2x damage to structures.
            - Fades can now blink and jump while performing stab.
        - Fades no longer receive speed bonuses from successive blinks without celerity.
    - Vampirism
        - Skulks health % recovered: 20% -> 14%
    - Regeneration
        - Now uses EHP (effective HP) calculations (armor counts as 2 hp) when healing (so armor takes 2x as long to heal).
        - No longer stops when in combat.
    - Misc
        - Maturity information is now visible in the nameplate for alien structures.
        - Crag, Shade, and Shift supply cost: 25 -> 20.
