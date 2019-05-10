class CfgMagazines {
    class Handgrenade_stone;
    class ALiVE_Handgrenade_stone : Handgrenade_stone {
        author = Tupolov;
        ammo = ALiVE_Stone;
        displayName = "Stone (ALiVE)";
        displayNameShort = "Stone";
        scope = 2;
        model = A3\Weapons_f\ammo\stone_3;
    };
    class ALiVE_Handgrenade_can : ALiVE_Handgrenade_stone {
        ammo = ALiVE_Can;
        displayName = "Can (ALiVE)";
        model = "\A3\Structures_F\Items\Food\Can_Dented_F.p3d";
        displayNameShort = "Can";
    };
    class ALiVE_Handgrenade_bottle : ALiVE_Handgrenade_stone {
        ammo = ALiVE_Bottle;
        displayName = "Bottle (ALiVE)";
        model = "\A3\Structures_F\Items\Food\BottlePlastic_V1_F.p3d";
        displayNameShort = "Bottle";
    };
};