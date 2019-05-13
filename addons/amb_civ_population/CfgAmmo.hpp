class CfgAmmo {
    class GrenadeHand;
    class ALiVE_Stone : GrenadeHand {
        author = Tupolov;
        ace_frag_enabled = 0;
        ace_frag_skip = 1;
        ace_frag_force = 0;
        ace_grenades_flashbang = 0;
        ace_grenades_flashbangBangs = 0;
        simulation = "shotShell";
        hit = 1;
        indirectHit = 0.1;
        indirectHitRange = 1;
        dangerRadiusHit = 1;
        suppressionRadiusHit = 1;
        explosive = 0;
        typicalspeed = 22;
        model = \A3\Weapons_f\ammo\stone_3;
        deflecting = 0;
        cost = 1;
        effectsSmoke = EmptyEffect;
        grenadeFireSound[] = {};
        grenadeBurningSound[] = {};
        aiAmmoUsageFlags = "64 + 128 + 512";
        explosionEffectsRadius = 0;
        explosionTime = 0;
        timeToLive = 10;
        allowAgainstInfantry = 1;
        explosionSoundEffect = "";
        CraterEffects = "NoCrater";
        explosionEffects = "NoExplosion";
        CraterWaterEffects = "ImpactEffectsWaterExplosion";
        audibleFire = 0;
        soundHit[] = {"",0,0};
        soundHit1[] = {"",0,0,0};
        soundHit2[] = {"",0,0,0};
        soundHit3[] = {"",0,0,0};
        soundHit4[] = {"",0,0,0};
        SoundSetExplosion[] = {"","",""};
        smokeColor[] = {0,0,0,0};
        class HitEffects
        {
            hitWater = "EmptyEffect";
        };
        class CamShakeExplode
        {
            power = "0";
            duration = "0";
            frequency = 0;
            distance = "0";
        };
    };
    class ALiVE_Can : ALiVE_Stone {
        hit = 0.2;
        model = "\A3\Structures_F\Items\Food\Can_Dented_F.p3d";
    };
    class ALiVE_Bottle : ALiVE_Stone {
        hit = 0.75;
        model = "\A3\Structures_F\Items\Food\BottlePlastic_V1_F.p3d";
    };
};

