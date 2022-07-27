class CfgMagazines {
    class Handgrenade_stone;
    class ALiVE_Handgrenade_stone : Handgrenade_stone {
        author = Tupolov;
        ammo = ALiVE_Stone;
        displayName = "Stone (weapon)";
        displayNameShort = "Stone";
        picture = "\A3\EditorPreviews_F\Data\CfgVehicles\Land_Small_Stone_02_F.jpg";
        scope = 2;
        model = A3\Weapons_f\ammo\stone_3;
        descriptionShort = "A stone that can be used as a weapon that is thrown.";
    };
    class ALiVE_Handgrenade_can : ALiVE_Handgrenade_stone {
        ammo = ALiVE_Can;
        displayName = "Can (weapon)";
        model = "\A3\Structures_F\Items\Food\Can_Dented_F.p3d";
        picture = "\A3\EditorPreviews_F\Data\CfgVehicles\Land_Can_Dented_F.jpg";
        displayNameShort = "Can";
        descriptionShort = "A can that can be used as a weapon that is thrown.";

    };
    class ALiVE_Handgrenade_bottle : ALiVE_Handgrenade_stone {
        ammo = ALiVE_Bottle;
        displayName = "Bottle (weapon)";
        model = "\A3\Structures_F\Items\Food\BottlePlastic_V1_F.p3d";
        picture = "\x\alive\addons\amb_civ_population\data\ui\WaterBottle.paa";
        displayNameShort = "Bottle";
        descriptionShort = "A bottle that can be used as a weapon that is thrown.";
    };
};