/*
    ALiVE armour sets: ALiVE's own vest and bullet values for other mods' kit.

    Each set applies only when any patch in anyPatches[] is loaded and
    its switch (setting, on by default) is on in the ALiVE Addon Options. The values feed ACE
    medical's armour-penetration wounds (ACE's default) at mission start; no
    other mod's class is redefined here, and engine damage stays as the mod
    ships it.

    Vests
      Each vest (CfgWeapons, ItemInfo type 701) gets a tier from the first name
      in its own class chain (itself, then its parents) that matches:
        1. webbing[]: exact class names, load-bearing kit with no plates;
        2. class Tiers >> <tier> >> prefixes[]: class-name prefixes, longest
           match wins (so rhs_6b23 is not taken for rhs_6b2).
      A tier is a cap on the armour ACE uses for each covered hitpoint. Values
      are only ever lowered, never raised, and a hitpoint the vest does not
      armour is left alone.
      Caps are chosen by the ACE armour level they land on (ACE body level =
      round((armour - 8) / 4), plate thickness 6 / 15 / 21 / 40 / 55):
        W 6  -> level 0, like no vest      S 12 -> level 1 (soft aramid)
        M 16 -> level 2 (older plates)     H 20 -> level 3 (modern plates,
                                                   vanilla V_PlateCarrier2)

    Ammo
      Bullets (simulation shotBullet) get the caliber of the nearest listed
      class in their chain, or keep their own when that is higher. A listed
      value of 0 stops the walk: that class and its children keep their own
      (RHS builds some unrelated rounds on rifle classes). Ball rounds
      take the caliber of the matching vanilla cartridge; enhanced and AP
      rounds keep their order above ball.

    Author: Jman
*/
class ALiVE_ArmourSets {
    class RHS {
        displayName = "RHS";
        // the set applies when any of these is loaded
        anyPatches[] = {"rhs_main","rhsusf_main","rhsgref_main","rhssaf_main"};
        // the RHS gear addons, to report RHS vests that no tier covers
        sourceAddons[] = {"rhs_c_troops","rhsusf_c_troops","rhsgref_c_troops","rhssaf_c_gear"};
        setting = "ALiVE_armour_rhs";
        ammoSetting = "ALiVE_armour_rhsAmmo";
        apsSetting = "ALiVE_armour_rhsAps";
        apsChargesSetting = "ALiVE_armour_rhsApsCharges";
        apsBases[] = {"rhs_t14_base","rhs_t15_base"};

        // torso hitpoints take the tier cap; the neck takes neckCap (or the
        // tier cap when that is lower)
        torsoHitpoints[] = {"HitChest","HitDiaphragm","HitAbdomen","HitPelvis"};
        neckHitpoints[] = {"HitNeck"};
        neckCap = 8;

        webbing[] = {"rhsgref_alice_webbing","rhsgref_chestrig","rhsgref_chicom"};
        webbingCap = 6;

        class Tiers {
            class H {
                cap = 20;
                prefixes[] = {"rhs_6b13","rhs_6b43","rhs_6b45","rhs_6sh117","rhsusf_iotv","rhsusf_spc","rhsusf_mbav"};
            };
            class M {
                cap = 16;
                prefixes[] = {"rhs_6b3","rhs_6b5","rhs_6b23","rhsgref_6b23","rhsgref_otv","rhssaf_vest_otv","rhssaf_vest_md98","rhssaf_vest_md99","rhssaf_vest_md12","rhsusf_plateframe"};
            };
            class S {
                cap = 12;
                prefixes[] = {"rhs_6b2","rhsgref_tacvest_erdl"};
            };
        };

        class Ammo {
            // 5.45x39 (vanilla B_545x39_Ball_F 0.6)
            rhs_B_545x39_Ball = 0.6;
            rhs_B_545x39_7N6_Ball = 0.6;
            rhs_B_545x39_7U1_Ball = 0.6;
            rhs_B_545x39_7N10_Ball = 0.75;
            // 5.56x45 (vanilla B_556x45_Ball 0.87)
            rhs_ammo_556x45_M855_Ball = 0.87;
            rhssaf_ammo_556x45_Ball_Tracer_Dim = 0.87;
            rhs_ammo_556x45_M193_Ball = 0.75;
            rhs_ammo_556x45_Mk262_Ball = 0.8;
            rhssaf_ammo_556x45_SPR = 0.8;
            rhs_ammo_556x45_Mk318_Ball = 0.9;
            rhssaf_ammo_556x45_SOST = 0.9;
            rhs_ammo_556x45_M855A1_Ball = 1.0;
            rhssaf_ammo_556x45_EPR = 1.0;
            rhs_ammo_556x45_M995_AP = 1.3;
            // 4.6x30 (MP7) inherits from M855A1 in RHS: keep its own
            rhs_ammo_46x30_FMJ = 0;
            rhs_ammo_46x30_JHP = 0;
            rhs_ammo_46x30_AP = 0;
            // 7.62x39 (vanilla B_762x39_Ball_F 1.2)
            rhs_B_762x39_Ball = 1.2;
            rhs_B_762x39_Tracer = 1.2;
            rhs_B_762x39_Ball_89 = 1.4;
            rhssaf_ammo_762x39_m82_api = 1.4;
            rhs_B_762x39_U_Ball = 0.8;
            // 7.62x51 (vanilla B_762x51_Ball 1.6)
            rhs_ammo_762x51_M80_Ball = 1.6;
            rhs_ammo_762x51_M62_tracer = 1.6;
            rhs_ammo_762x51_M118_Special_Ball = 1.6;
            rhs_ammo_762x51_Mk316_Special_Ball = 1.6;
            rhs_ammo_762x51_M80A1EPR_Ball = 1.9;
            rhs_ammo_762x51_M61_AP = 2.2;
            rhs_ammo_762x51_M993_Ball = 2.6;
            // 7.62x54R (vanilla B_762x54_Ball 1.8)
            rhs_B_762x54_Ball = 1.8;
            rhs_B_762x54_Ball_Tracer_Green = 1.8;
            rhs_B_762x54_7N1_Ball = 1.8;
            rhs_B_762x54_7N13_Ball = 2.0;
            rhs_B_762x54_7N14_Ball = 2.0;
            rhs_B_762x54_7N26_Ball = 2.1;
            rhs_B_762x54_7BZ3_Ball = 2.4;
            // 9x39
            rhs_B_9x39_SP5 = 1.0;
            rhs_B_9x39_SP6 = 1.6;
            // GREF older rifle cartridges
            rhs_ammo_762x63_M2B_ball = 1.8;
            rhs_ammo_762x63_M1T_tracer = 1.8;
            rhs_ammo_792x57_Ball = 1.8;
            rhs_ammo_75x55_Ball = 1.7;
            rhs_ammo_792x33_SmE_ball = 1.1;
        };
    };
};
