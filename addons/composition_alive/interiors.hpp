// Small furniture sets that dress the insides of the AI Commander's insurgent installations (IED
// factory, weapons depot, recruitment HQ), one kind per class below, in four eras: Modern (base game),
// Vietnam (S.O.G. Prairie Fire), WW2 (Spearhead 1944) and Cold War (Global Mobilization); era says which,
// and a set whose classes aren't loaded is skipped. Laid out and checked for clashes on the test rig.
// A mission can add its own under missionConfigFile >> CfgGroups >> Empty >> ALiVE_Interiors.
class ALiVE_Interiors
{
    name = "ALiVE Insurgent Interiors";
    class Factory
    {
        name = "IED factory";
        class InsFactoryBench
        {
            name = "Bomb-making bench";
            era = "MODERN";
            side = 8;
            class Object0 {side = 8; vehicle = "Land_Workbench_01_F"; rank = ""; position[] = {0.000,0.000,0.000}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "Land_MetalWire_F"; rank = ""; position[] = {-0.500,-0.050,0.794}; dir = 10.0;};
            class Object2 {side = 8; vehicle = "Land_CarBattery_02_F"; rank = ""; position[] = {-0.150,0.050,0.817}; dir = 0.0;};
            class Object3 {side = 8; vehicle = "Land_MultiMeter_F"; rank = ""; position[] = {0.150,-0.100,0.830}; dir = 30.0;};
            class Object4 {side = 8; vehicle = "Land_Pliers_F"; rank = ""; position[] = {0.389,-0.040,0.869}; dir = 80.0;};
            class Object5 {side = 8; vehicle = "Land_Screwdriver_V2_F"; rank = ""; position[] = {0.472,0.083,0.913}; dir = 100.0;};
            class Object6 {side = 8; vehicle = "Land_DuctTape_F"; rank = ""; position[] = {0.600,-0.200,1.002}; dir = 0.0;};
            class Object7 {side = 8; vehicle = "Land_MobilePhone_old_F"; rank = ""; position[] = {-0.300,-0.200,0.780}; dir = 15.0;};
            class Object8 {side = 8; vehicle = "Land_MobilePhone_old_F"; rank = ""; position[] = {-0.200,-0.220,0.782}; dir = 40.0;};
            class Object9 {side = 8; vehicle = "Land_GasTank_01_khaki_F"; rank = ""; position[] = {0.750,-0.750,0.000}; dir = 0.0;};
            class Object10 {side = 8; vehicle = "Land_CanisterFuel_F"; rank = ""; position[] = {-0.700,-0.750,0.186}; dir = 20.0;};
        };
        class InsFactoryStore
        {
            name = "Fertiliser and fuel store";
            era = "MODERN";
            side = 8;
            class Object0 {side = 8; vehicle = "Land_Sacks_goods_F"; rank = ""; position[] = {0.000,0.300,0.025}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "Land_CanisterPlastic_F"; rank = ""; position[] = {-1.079,0.166,0.045}; dir = 0.0;};
            class Object2 {side = 8; vehicle = "Land_CanisterPlastic_F"; rank = ""; position[] = {-1.139,-0.410,0.045}; dir = 25.0;};
            class Object3 {side = 8; vehicle = "Land_CanisterFuel_F"; rank = ""; position[] = {-0.471,-0.643,0.186}; dir = 70.0;};
            class Object4 {side = 8; vehicle = "Land_MetalBarrel_F"; rank = ""; position[] = {1.169,0.188,0.000}; dir = 0.0;};
            class Object5 {side = 8; vehicle = "Land_Bucket_F"; rank = ""; position[] = {0.550,-0.700,0.000}; dir = 0.0;};
        };
        class InsFactoryWiring
        {
            name = "Wiring table";
            era = "MODERN";
            side = 8;
            class Object0 {side = 8; vehicle = "Land_CampingTable_F"; rank = ""; position[] = {0.000,0.000,0.000}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "Land_CampingChair_V2_F"; rank = ""; position[] = {0.000,-0.750,0.005}; dir = 180.0;};
            class Object2 {side = 8; vehicle = "Land_ExtensionCord_F"; rank = ""; position[] = {-0.450,0.050,0.829}; dir = 0.0;};
            class Object3 {side = 8; vehicle = "Land_MetalWire_F"; rank = ""; position[] = {0.098,0.129,0.828}; dir = 60.0;};
            class Object4 {side = 8; vehicle = "Land_Battery_F"; rank = ""; position[] = {0.216,-0.050,0.799}; dir = 0.0;};
            class Object5 {side = 8; vehicle = "Land_Battery_F"; rank = ""; position[] = {0.300,0.114,0.807}; dir = 30.0;};
            class Object6 {side = 8; vehicle = "Land_MobilePhone_old_F"; rank = ""; position[] = {0.400,-0.100,0.792}; dir = 10.0;};
            class Object7 {side = 8; vehicle = "Land_SatellitePhone_F"; rank = ""; position[] = {0.701,0.213,0.796}; dir = 200.0;};
            class Object8 {side = 8; vehicle = "Land_Pliers_F"; rank = ""; position[] = {-0.243,-0.364,0.793}; dir = 120.0;};
        };
        class InsVNFactoryBench
        {
            name = "Bomb-making table";
            era = "VIETNAM";
            side = 8;
            class Object0 {side = 8; vehicle = "Land_vn_woodentable_large_f"; rank = ""; position[] = {0.000,0.000,0.005}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "Land_vn_us_ammobox_small_01"; rank = ""; position[] = {-0.450,0.050,0.852}; dir = 10.0;};
            class Object2 {side = 8; vehicle = "Land_MetalWire_F"; rank = ""; position[] = {0.050,0.050,0.887}; dir = 30.0;};
            class Object3 {side = 8; vehicle = "Land_Pliers_F"; rank = ""; position[] = {0.369,-0.141,0.898}; dir = 80.0;};
            class Object4 {side = 8; vehicle = "Land_vn_candle_01"; rank = ""; position[] = {0.550,0.100,0.955}; dir = 0.0;};
            class Object5 {side = 8; vehicle = "vn_prop_60mm_crate_01"; rank = ""; position[] = {0.311,-1.319,0.000}; dir = 0.0;};
        };
        class InsVNFactoryStore
        {
            name = "Sacks and fuel";
            era = "VIETNAM";
            side = 8;
            class Object0 {side = 8; vehicle = "Land_vn_foodsacks_01_small_brown_f"; rank = ""; position[] = {0.000,0.300,0.016}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "Land_vn_sack_ep1"; rank = ""; position[] = {0.750,0.350,0.013}; dir = 20.0;};
            class Object2 {side = 8; vehicle = "Land_CanisterFuel_F"; rank = ""; position[] = {-0.750,0.200,0.186}; dir = 10.0;};
            class Object3 {side = 8; vehicle = "Land_vn_metalcrate"; rank = ""; position[] = {0.300,-0.600,0.000}; dir = 0.0;};
        };
        class InsVNFactoryWiring
        {
            name = "Wiring table";
            era = "VIETNAM";
            side = 8;
            class Object0 {side = 8; vehicle = "Land_vn_tablesmall_01_f"; rank = ""; position[] = {0.000,0.000,0.000}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "Land_vn_chair"; rank = ""; position[] = {0.000,-0.700,0.005}; dir = 180.0;};
            class Object2 {side = 8; vehicle = "vn_b_prop_telephone_01"; rank = ""; position[] = {-0.200,0.050,0.431}; dir = 0.0;};
            class Object3 {side = 8; vehicle = "Land_MetalWire_F"; rank = ""; position[] = {0.200,0.050,0.425}; dir = 40.0;};
            class Object4 {side = 8; vehicle = "Land_vn_candle_01"; rank = ""; position[] = {0.300,-0.150,0.000}; dir = 0.0;};
        };
        class InsWW2FactoryBench
        {
            name = "Demolition table";
            era = "WW2";
            side = 8;
            class Object0 {side = 8; vehicle = "SPE_DiningTable_01"; rank = ""; position[] = {0.000,0.000,0.000}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "SPE_US_TNT_half_pound"; rank = ""; position[] = {-0.400,0.050,0.672}; dir = 10.0;};
            class Object2 {side = 8; vehicle = "SPE_US_TNT_half_pound"; rank = ""; position[] = {-0.250,0.100,0.694}; dir = 40.0;};
            class Object3 {side = 8; vehicle = "Land_SPE_Ammocan_German"; rank = ""; position[] = {0.177,-0.022,0.761}; dir = 0.0;};
            class Object4 {side = 8; vehicle = "Land_SPE_Onion_Lamp"; rank = ""; position[] = {0.705,0.216,0.836}; dir = 0.0;};
            class Object5 {side = 8; vehicle = "Land_SPE_Jerrycan"; rank = ""; position[] = {1.420,0.000,0.003}; dir = 20.0;};
        };
        class InsWW2FactoryStore
        {
            name = "Sacks and fuel";
            era = "WW2";
            side = 8;
            class Object0 {side = 8; vehicle = "Land_Sacks_heap_F"; rank = ""; position[] = {0.000,0.300,0.051}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "Land_SPE_Fuel_Barrel_German"; rank = ""; position[] = {1.090,0.248,0.002}; dir = 0.0;};
            class Object2 {side = 8; vehicle = "Land_SPE_Jerrycan"; rank = ""; position[] = {-0.950,0.100,0.003}; dir = 10.0;};
            class Object3 {side = 8; vehicle = "Land_SPE_Jerrycan"; rank = ""; position[] = {-1.049,-0.417,0.003}; dir = 60.0;};
            class Object4 {side = 8; vehicle = "Land_SPE_Wooden_Barrel_02_Small_Brown"; rank = ""; position[] = {0.500,-0.650,0.000}; dir = 0.0;};
        };
        class InsWW2FactoryWiring
        {
            name = "Workshop table";
            era = "WW2";
            side = 8;
            class Object0 {side = 8; vehicle = "SPE_SideTable_01"; rank = ""; position[] = {0.000,0.000,0.001}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "SPE_DiningChair"; rank = ""; position[] = {0.000,-0.700,0.007}; dir = 180.0;};
            class Object2 {side = 8; vehicle = "Land_SPE_Ger_Lamp"; rank = ""; position[] = {-0.200,0.050,0.759}; dir = 0.0;};
            class Object3 {side = 8; vehicle = "Land_MetalWire_F"; rank = ""; position[] = {0.150,0.000,0.783}; dir = 30.0;};
        };
        class InsCWFactoryBench
        {
            name = "Bomb-making bench";
            era = "COLDWAR";
            side = 8;
            class Object0 {side = 8; vehicle = "Land_Workbench_01_F"; rank = ""; position[] = {0.000,0.000,0.000}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "Land_MetalWire_F"; rank = ""; position[] = {-0.500,-0.050,0.685}; dir = 10.0;};
            class Object2 {side = 8; vehicle = "Land_Battery_F"; rank = ""; position[] = {-0.150,0.050,0.787}; dir = 0.0;};
            class Object3 {side = 8; vehicle = "Land_Pliers_F"; rank = ""; position[] = {0.300,-0.050,0.921}; dir = 80.0;};
            class Object4 {side = 8; vehicle = "gm_jerrycan"; rank = ""; position[] = {-0.700,-0.750,0.000}; dir = 20.0;};
            class Object5 {side = 8; vehicle = "gm_barrel_rusty"; rank = ""; position[] = {0.800,-0.750,0.001}; dir = 0.0;};
        };
        class InsCWFactoryStore
        {
            name = "Sacks and fuel";
            era = "COLDWAR";
            side = 8;
            class Object0 {side = 8; vehicle = "Land_Sacks_goods_F"; rank = ""; position[] = {0.000,0.300,0.025}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "gm_barrel_rusty"; rank = ""; position[] = {1.199,0.181,0.001}; dir = 0.0;};
            class Object2 {side = 8; vehicle = "gm_jerrycan"; rank = ""; position[] = {-0.994,0.051,0.000}; dir = 10.0;};
            class Object3 {side = 8; vehicle = "gm_jerrycan"; rank = ""; position[] = {-1.048,-0.553,0.000}; dir = 60.0;};
        };
        class InsCWFactoryWiring
        {
            name = "Wiring table";
            era = "COLDWAR";
            side = 8;
            class Object0 {side = 8; vehicle = "gm_euro_furniture_table_06_random"; rank = ""; position[] = {0.000,0.000,0.000}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "Land_ChairWood_F"; rank = ""; position[] = {0.000,-0.700,0.000}; dir = 180.0;};
            class Object2 {side = 8; vehicle = "Land_MetalWire_F"; rank = ""; position[] = {-0.200,0.050,0.711}; dir = 20.0;};
            class Object3 {side = 8; vehicle = "Land_Battery_F"; rank = ""; position[] = {0.150,0.050,0.928}; dir = 0.0;};
            class Object4 {side = 8; vehicle = "Land_Pliers_F"; rank = ""; position[] = {0.350,-0.100,1.041}; dir = 120.0;};
        };
    };
    class Depot
    {
        name = "Weapons depot";
        class InsDepotCrates
        {
            name = "Weapon crate stack";
            era = "MODERN";
            side = 8;
            class Object0 {side = 8; vehicle = "Box_East_Wps_F"; rank = ""; position[] = {0.000,0.000,0.002}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "Box_East_Ammo_F"; rank = ""; position[] = {1.000,0.050,0.036}; dir = 5.0;};
            class Object2 {side = 8; vehicle = "Box_East_AmmoOrd_F"; rank = ""; position[] = {-0.950,0.000,0.036}; dir = 0.0;};
            class Object3 {side = 8; vehicle = "Box_East_Grenades_F"; rank = ""; position[] = {0.100,-0.700,0.036}; dir = 90.0;};
            class Object4 {side = 8; vehicle = "Land_Ammobox_rounds_F"; rank = ""; position[] = {0.900,-0.650,0.002}; dir = 20.0;};
            class Object5 {side = 8; vehicle = "Land_Ammobox_rounds_F"; rank = ""; position[] = {1.208,-0.804,0.002}; dir = 70.0;};
        };
        class InsDepotRack
        {
            name = "Rifle table and ammunition";
            era = "MODERN";
            side = 8;
            class Object0 {side = 8; vehicle = "Land_WoodenTable_large_F"; rank = ""; position[] = {0.000,0.000,0.005}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "Weapon_arifle_AKM_F"; rank = ""; position[] = {-0.400,0.000,0.890}; dir = 90.0;};
            class Object2 {side = 8; vehicle = "Weapon_arifle_AKS_F"; rank = ""; position[] = {0.300,0.050,0.916}; dir = 90.0;};
            class Object3 {side = 8; vehicle = "Land_Ammobox_rounds_F"; rank = ""; position[] = {0.572,0.186,0.002}; dir = 10.0;};
            class Object4 {side = 8; vehicle = "Land_Ammobox_rounds_F"; rank = ""; position[] = {-0.600,-0.150,0.002}; dir = 40.0;};
            class Object5 {side = 8; vehicle = "Box_Syndicate_Ammo_F"; rank = ""; position[] = {0.000,-1.371,0.000}; dir = 0.0;};
            class Object6 {side = 8; vehicle = "Box_Syndicate_Wps_F"; rank = ""; position[] = {1.300,0.100,0.005}; dir = 0.0;};
        };
        class InsDepotLaunchers
        {
            name = "Launcher and rocket pile";
            era = "MODERN";
            side = 8;
            class Object0 {side = 8; vehicle = "Box_East_WpsLaunch_F"; rank = ""; position[] = {0.000,0.300,0.003}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "Box_East_Ammo_F"; rank = ""; position[] = {0.100,-0.550,0.036}; dir = 0.0;};
            class Object2 {side = 8; vehicle = "Box_Syndicate_Wps_F"; rank = ""; position[] = {-1.000,0.100,0.005}; dir = 90.0;};
            class Object3 {side = 8; vehicle = "Weapon_launch_RPG7_F"; rank = ""; position[] = {0.100,-0.550,0.620}; dir = 10.0;};
        };
        class InsVNDepotCrates
        {
            name = "Weapons cache";
            era = "VIETNAM";
            side = 8;
            class Object0 {side = 8; vehicle = "Land_vn_pavn_weapons_cache"; rank = ""; position[] = {0.000,0.200,0.273}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "Land_vn_us_ammobox_small_01"; rank = ""; position[] = {-0.465,-0.847,0.000}; dir = 10.0;};
            class Object2 {side = 8; vehicle = "Land_vn_us_ammobox_small_03"; rank = ""; position[] = {0.300,-0.750,0.000}; dir = 70.0;};
            class Object3 {side = 8; vehicle = "vn_prop_81mm_crate_02"; rank = ""; position[] = {1.200,0.100,0.000}; dir = 0.0;};
        };
        class InsVNDepotTable
        {
            name = "Ammunition table";
            era = "VIETNAM";
            side = 8;
            class Object0 {side = 8; vehicle = "Land_vn_woodentable_small_f"; rank = ""; position[] = {0.000,0.000,0.005}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "Land_vn_us_ammobox_small_03"; rank = ""; position[] = {-0.150,0.000,0.858}; dir = 10.0;};
            class Object2 {side = 8; vehicle = "Land_vn_us_ammobox_small_01"; rank = ""; position[] = {0.398,0.079,0.878}; dir = 80.0;};
            class Object3 {side = 8; vehicle = "vn_prop_60mm_crate_01"; rank = ""; position[] = {0.000,-0.960,0.000}; dir = 0.0;};
            class Object4 {side = 8; vehicle = "Land_vn_woodencrate_01_f"; rank = ""; position[] = {1.100,0.000,0.003}; dir = 0.0;};
        };
        class InsVNDepotMortar
        {
            name = "Mortar rounds";
            era = "VIETNAM";
            side = 8;
            class Object0 {side = 8; vehicle = "vn_prop_81mm_crate_02"; rank = ""; position[] = {0.000,0.000,0.000}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "vn_prop_81mm_crate_02"; rank = ""; position[] = {0.000,0.550,0.000}; dir = 5.0;};
            class Object2 {side = 8; vehicle = "vn_prop_60mm_crate_01"; rank = ""; position[] = {0.900,0.200,0.000}; dir = 0.0;};
            class Object3 {side = 8; vehicle = "Land_vn_metalcrate"; rank = ""; position[] = {-0.900,0.200,0.000}; dir = 0.0;};
        };
        class InsWW2DepotCrates
        {
            name = "Weapon crates";
            era = "WW2";
            side = 8;
            class Object0 {side = 8; vehicle = "Land_SPE_Ammobox_German_04"; rank = ""; position[] = {0.000,0.000,0.000}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "Land_SPE_Ammobox_German_02"; rank = ""; position[] = {0.000,0.600,0.000}; dir = 5.0;};
            class Object2 {side = 8; vehicle = "Land_SPE_Ammocrate_US_02"; rank = ""; position[] = {0.900,0.200,0.000}; dir = 0.0;};
            class Object3 {side = 8; vehicle = "Land_SPE_Pak40Box_01"; rank = ""; position[] = {0.000,-0.600,-0.001}; dir = 0.0;};
            class Object4 {side = 8; vehicle = "Land_SPE_Ammobox_German_01"; rank = ""; position[] = {-0.950,0.100,0.000}; dir = 80.0;};
        };
        class InsWW2DepotTable
        {
            name = "Ammunition table";
            era = "WW2";
            side = 8;
            class Object0 {side = 8; vehicle = "SPE_DiningTable_01"; rank = ""; position[] = {0.000,0.000,0.000}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "Land_SPE_Ammocan_German"; rank = ""; position[] = {-0.300,0.000,0.660}; dir = 10.0;};
            class Object2 {side = 8; vehicle = "Land_SPE_Ammocan_German"; rank = ""; position[] = {0.299,0.074,0.770}; dir = 80.0;};
            class Object3 {side = 8; vehicle = "Land_SPE_Ammobox_German_04"; rank = ""; position[] = {0.000,-0.900,0.000}; dir = 0.0;};
            class Object4 {side = 8; vehicle = "Land_SPE_Ammocrate_US_01"; rank = ""; position[] = {1.359,0.114,0.000}; dir = 0.0;};
        };
        class InsWW2DepotPile
        {
            name = "Ammunition pile";
            era = "WW2";
            side = 8;
            class Object0 {side = 8; vehicle = "Land_SPE_Ammobox_German_02"; rank = ""; position[] = {0.000,0.000,0.000}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "Land_SPE_Ammobox_German_02"; rank = ""; position[] = {0.798,0.132,0.000}; dir = 10.0;};
            class Object2 {side = 8; vehicle = "Land_SPE_Ammocrate_US_01"; rank = ""; position[] = {-0.800,0.000,0.000}; dir = 0.0;};
            class Object3 {side = 8; vehicle = "SPE_BasicAmmunitionBox_GER"; rank = ""; position[] = {0.200,0.800,0.000}; dir = 0.0;};
        };
        class InsCWDepotCrates
        {
            name = "Ammunition crates";
            era = "COLDWAR";
            side = 8;
            class Object0 {side = 8; vehicle = "gm_ammobox_aluminium_02_empty"; rank = ""; position[] = {0.000,0.000,0.000}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "gm_ammobox_aluminium_06_empty"; rank = ""; position[] = {0.850,0.100,0.000}; dir = 0.0;};
            class Object2 {side = 8; vehicle = "gm_fortification_crate_02"; rank = ""; position[] = {-0.850,0.000,0.000}; dir = 0.0;};
            class Object3 {side = 8; vehicle = "gm_ammobox_aluminium_07_empty"; rank = ""; position[] = {0.100,-0.750,0.000}; dir = 90.0;};
        };
        class InsCWDepotTable
        {
            name = "Ammunition table";
            era = "COLDWAR";
            side = 8;
            class Object0 {side = 8; vehicle = "Land_WoodenTable_large_F"; rank = ""; position[] = {0.000,0.000,0.005}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "gm_ammobox_aluminium_07_empty"; rank = ""; position[] = {-0.300,0.000,0.748}; dir = 0.0;};
            class Object2 {side = 8; vehicle = "Land_Ammobox_rounds_F"; rank = ""; position[] = {0.350,0.050,1.001}; dir = 30.0;};
            class Object3 {side = 8; vehicle = "gm_ammobox_aluminium_04_empty"; rank = ""; position[] = {1.300,0.100,0.000}; dir = 0.0;};
        };
        class InsCWDepotPile
        {
            name = "Crate pile";
            era = "COLDWAR";
            side = 8;
            class Object0 {side = 8; vehicle = "gm_ammobox_pallet_01_empty"; rank = ""; position[] = {0.000,0.000,0.003}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "gm_fortification_crate_03"; rank = ""; position[] = {1.459,0.112,0.000}; dir = 90.0;};
            class Object2 {side = 8; vehicle = "gm_ammobox_aluminium_07_empty"; rank = ""; position[] = {0.000,-0.750,0.000}; dir = 0.0;};
        };
    };
    class HQ
    {
        name = "Recruitment HQ";
        class InsHQDesk
        {
            name = "Command desk";
            era = "MODERN";
            side = 8;
            class Object0 {side = 8; vehicle = "Land_TableDesk_F"; rank = ""; position[] = {0.000,0.000,0.013}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "Land_ChairWood_F"; rank = ""; position[] = {0.000,-0.700,0.000}; dir = 180.0;};
            class Object2 {side = 8; vehicle = "Land_MapBoard_F"; rank = ""; position[] = {0.300,1.000,0.011}; dir = 0.0;};
            class Object3 {side = 8; vehicle = "Land_PortableLongRangeRadio_F"; rank = ""; position[] = {-0.500,0.100,0.789}; dir = 0.0;};
            class Object4 {side = 8; vehicle = "Land_Map_unfolded_F"; rank = ""; position[] = {0.100,0.000,0.848}; dir = 0.0;};
            class Object5 {side = 8; vehicle = "Land_Notepad_F"; rank = ""; position[] = {0.550,-0.100,0.896}; dir = 20.0;};
            class Object6 {side = 8; vehicle = "Land_File1_F"; rank = ""; position[] = {0.600,0.150,0.912}; dir = 350.0;};
        };
        class InsHQSleeping
        {
            name = "Sleeping area";
            era = "MODERN";
            side = 8;
            class Object0 {side = 8; vehicle = "Land_Sleeping_bag_brown_F"; rank = ""; position[] = {-0.550,0.000,0.001}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "Land_Sleeping_bag_F"; rank = ""; position[] = {0.550,0.050,0.001}; dir = 5.0;};
            class Object2 {side = 8; vehicle = "Land_Sleeping_bag_folded_F"; rank = ""; position[] = {1.365,1.213,0.005}; dir = 0.0;};
            class Object3 {side = 8; vehicle = "Land_Canteen_F"; rank = ""; position[] = {-1.067,1.137,0.002}; dir = 0.0;};
            class Object4 {side = 8; vehicle = "Land_BottlePlastic_V1_F"; rank = ""; position[] = {0.033,1.187,0.000}; dir = 0.0;};
        };
        class InsHQRadio
        {
            name = "Radio table";
            era = "MODERN";
            side = 8;
            class Object0 {side = 8; vehicle = "Land_CampingTable_small_F"; rank = ""; position[] = {0.000,0.000,0.000}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "Land_CampingChair_V2_F"; rank = ""; position[] = {0.000,-0.690,0.005}; dir = 180.0;};
            class Object2 {side = 8; vehicle = "Land_Laptop_unfolded_F"; rank = ""; position[] = {-0.100,0.050,0.827}; dir = 0.0;};
            class Object3 {side = 8; vehicle = "Land_SatellitePhone_F"; rank = ""; position[] = {0.400,0.050,0.837}; dir = 30.0;};
            class Object4 {side = 8; vehicle = "Land_FMradio_F"; rank = ""; position[] = {0.229,-0.292,0.805}; dir = 340.0;};
            class Object5 {side = 8; vehicle = "Land_PortableLongRangeRadio_F"; rank = ""; position[] = {0.750,0.200,0.000}; dir = 0.0;};
        };
        class InsVNHQDesk
        {
            name = "Command desk";
            era = "VIETNAM";
            side = 8;
            class Object0 {side = 8; vehicle = "Land_vn_table_drawer"; rank = ""; position[] = {0.000,0.000,0.000}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "Land_vn_chair"; rank = ""; position[] = {0.000,-0.700,0.005}; dir = 180.0;};
            class Object2 {side = 8; vehicle = "vn_b_prop_typewriter_01"; rank = ""; position[] = {-0.300,0.050,0.658}; dir = 0.0;};
            class Object3 {side = 8; vehicle = "Land_vn_map_unfolded_f"; rank = ""; position[] = {0.250,0.000,0.715}; dir = 0.0;};
            class Object4 {side = 8; vehicle = "Land_vn_us_common_lantern_01"; rank = ""; position[] = {0.550,0.150,0.000}; dir = 0.0;};
            class Object5 {side = 8; vehicle = "Land_vn_b_prop_mapstand_01"; rank = ""; position[] = {0.200,1.000,0.077}; dir = 0.0;};
        };
        class InsVNHQSleeping
        {
            name = "Bedrolls and cot";
            era = "VIETNAM";
            side = 8;
            class Object0 {side = 8; vehicle = "vn_o_item_bedroll_01"; rank = ""; position[] = {-0.500,0.000,0.006}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "vn_o_item_bedroll_01"; rank = ""; position[] = {0.400,0.050,0.006}; dir = 5.0;};
            class Object2 {side = 8; vehicle = "Land_vn_foodsacks_01_small_brown_f"; rank = ""; position[] = {1.300,0.300,0.016}; dir = 0.0;};
            class Object3 {side = 8; vehicle = "Land_vn_waterbottle_01_full_f"; rank = ""; position[] = {-0.100,0.900,0.007}; dir = 0.0;};
        };
        class InsVNHQRadio
        {
            name = "Radio table";
            era = "VIETNAM";
            side = 8;
            class Object0 {side = 8; vehicle = "Land_vn_tablesmall_01_f"; rank = ""; position[] = {0.000,0.000,0.000}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "vn_bar_01_campchair_01"; rank = ""; position[] = {0.000,-0.700,0.001}; dir = 180.0;};
            class Object2 {side = 8; vehicle = "vn_o_prop_radio_m252b_01"; rank = ""; position[] = {-0.150,0.050,0.432}; dir = 0.0;};
            class Object3 {side = 8; vehicle = "vn_b_prop_telephone_01"; rank = ""; position[] = {0.300,0.000,0.000}; dir = 20.0;};
        };
        class InsWW2HQDesk
        {
            name = "Command desk";
            era = "WW2";
            side = 8;
            class Object0 {side = 8; vehicle = "SPE_Desk_01"; rank = ""; position[] = {0.000,0.000,0.008}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "SPE_DiningChair"; rank = ""; position[] = {0.000,-1.061,0.007}; dir = 180.0;};
            class Object2 {side = 8; vehicle = "Land_Map_unfolded_F"; rank = ""; position[] = {-0.200,0.000,0.956}; dir = 0.0;};
            class Object3 {side = 8; vehicle = "Land_File1_F"; rank = ""; position[] = {0.300,-0.050,1.030}; dir = 10.0;};
            class Object4 {side = 8; vehicle = "Land_SPE_Ger_Lamp"; rank = ""; position[] = {0.550,0.150,0.000}; dir = 0.0;};
            class Object5 {side = 8; vehicle = "Land_SPE_Cabinet"; rank = ""; position[] = {1.400,0.400,0.000}; dir = 0.0;};
        };
        class InsWW2HQSleeping
        {
            name = "Sleeping corner";
            era = "WW2";
            side = 8;
            class Object0 {side = 8; vehicle = "Land_Sleeping_bag_brown_F"; rank = ""; position[] = {-0.500,0.000,0.001}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "Land_Sleeping_bag_brown_F"; rank = ""; position[] = {0.580,0.054,0.001}; dir = 5.0;};
            class Object2 {side = 8; vehicle = "SPE_ChateauChair"; rank = ""; position[] = {1.725,1.095,0.012}; dir = 200.0;};
            class Object3 {side = 8; vehicle = "Land_SPE_Milk_Bottle"; rank = ""; position[] = {-0.100,1.100,0.001}; dir = 0.0;};
            class Object4 {side = 8; vehicle = "Land_SPE_Cider_Bottle_01"; rank = ""; position[] = {0.084,1.187,0.000}; dir = 0.0;};
        };
        class InsWW2HQRadio
        {
            name = "Radio table";
            era = "WW2";
            side = 8;
            class Object0 {side = 8; vehicle = "SPE_SideTable_01"; rank = ""; position[] = {0.000,0.000,0.001}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "SPE_DiningChair"; rank = ""; position[] = {0.000,-0.700,0.007}; dir = 180.0;};
            class Object2 {side = 8; vehicle = "Land_SPE_Onion_Lamp"; rank = ""; position[] = {0.100,0.050,0.822}; dir = 0.0;};
            class Object3 {side = 8; vehicle = "SPE_Radio_Ger"; rank = ""; position[] = {0.950,0.100,0.001}; dir = 270.0;};
        };
        class InsCWHQDesk
        {
            name = "Command desk";
            era = "COLDWAR";
            side = 8;
            class Object0 {side = 8; vehicle = "gm_euro_furniture_desk_01_random"; rank = ""; position[] = {0.000,0.000,0.000}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "Land_ChairWood_F"; rank = ""; position[] = {0.000,-0.700,0.000}; dir = 180.0;};
            class Object2 {side = 8; vehicle = "Land_Map_unfolded_F"; rank = ""; position[] = {-0.200,0.000,0.812}; dir = 0.0;};
            class Object3 {side = 8; vehicle = "Land_File1_F"; rank = ""; position[] = {0.300,-0.050,0.935}; dir = 10.0;};
            class Object4 {side = 8; vehicle = "Land_MapBoard_F"; rank = ""; position[] = {0.300,1.000,0.011}; dir = 0.0;};
        };
        class InsCWHQSleeping
        {
            name = "Sleeping area";
            era = "COLDWAR";
            side = 8;
            class Object0 {side = 8; vehicle = "Land_Sleeping_bag_brown_F"; rank = ""; position[] = {-0.550,0.000,0.001}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "Land_Sleeping_bag_brown_F"; rank = ""; position[] = {0.550,0.050,0.001}; dir = 5.0;};
            class Object2 {side = 8; vehicle = "Land_Canteen_F"; rank = ""; position[] = {-1.015,1.137,0.002}; dir = 0.0;};
            class Object3 {side = 8; vehicle = "gm_jerrycan"; rank = ""; position[] = {1.222,1.033,0.000}; dir = 0.0;};
        };
        class InsCWHQRadio
        {
            name = "Radio table";
            era = "COLDWAR";
            side = 8;
            class Object0 {side = 8; vehicle = "Land_WoodenTable_small_F"; rank = ""; position[] = {0.000,0.000,0.005}; dir = 0.0;};
            class Object1 {side = 8; vehicle = "Land_ChairWood_F"; rank = ""; position[] = {0.000,-0.970,0.000}; dir = 180.0;};
            class Object2 {side = 8; vehicle = "gm_r123m_table"; rank = ""; position[] = {-0.100,0.050,0.858}; dir = 0.0;};
            class Object3 {side = 8; vehicle = "Land_Notepad_F"; rank = ""; position[] = {0.300,-0.050,0.977}; dir = 20.0;};
        };
    };
};
