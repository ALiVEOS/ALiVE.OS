class CfgGroups
{
    class Empty
    {
        side = 8;
        name = "Compositions";
        class Military_Jungle
        {
            name = "$STR_ALIVE_COMP_VN_MilitaryJungle";
            #include "military\jungle.hpp"
        };
    };

    // Single boat groups
    class East
    {
        class VN_PAVN
        {
            class vn_o_group_boats
            {
                name = "Single Boat Groups";
                class vn_o_group_boat_03
                {
                    name = $STR_VN_O_GROUP_BOAT_NVA_01;
                    faction = "O_PAVN";
                    icon = "\A3\ui_f\data\map\markers\nato\o_naval.paa";
                    rarityGroup = 0.5;
                    side = 0;
                    class Unit0
                    {
                        side = 0;
                        vehicle = "vn_o_boat_03_02";
                        rank = "CAPTAIN";
                        position[] = {0,0,0};
                    };
                };
                class vn_o_group_boat_04
                {
                    name = $STR_VN_O_GROUP_BOAT_NVA_01;
                    faction = "O_PAVN";
                    icon = "\A3\ui_f\data\map\markers\nato\o_naval.paa";
                    rarityGroup = 0.5;
                    side = 0;
                    class Unit0
                    {
                        side = 0;
                        vehicle = "vn_o_boat_04_02";
                        rank = "CAPTAIN";
                        position[] = {0,0,0};
                    };
                };
            };
        };
        class VN_VC
        {
            class vn_o_group_boats_vcmf
            {
                name = "Single Boat Groups";
                class vn_o_group_boat_vcmf_07
                {
                    name = $STR_VN_O_GROUP_BOAT_VCMF_01;
                    faction = "O_VC";
                    icon = "\A3\ui_f\data\map\markers\nato\o_naval.paa";
                    rarityGroup = 0.5;
                    side = 0;
                    class Unit0
                    {
                        side = 0;
                        vehicle = "vn_o_boat_01_mg_00";
                        rank = "CAPTAIN";
                        position[] = {0,0,0};
                    };
                };
                class vn_o_group_boat_vcmf_08
                {
                    name = $STR_VN_O_GROUP_BOAT_VCMF_01;
                    faction = "O_VC";
                    icon = "\A3\ui_f\data\map\markers\nato\o_naval.paa";
                    rarityGroup = 0.5;
                    side = 0;
                    class Unit0
                    {
                        side = 0;
                        vehicle = "vn_o_boat_02_mg_00";
                        rank = "CAPTAIN";
                        position[] = {0,0,0};
                    };
                };
            };
        };
    };

    class West
    {
        class VN_MACV
        {
            class vn_b_group_boats
            {
                name = "Single Boat Groups";
                class vn_b_group_boat_03
                {
                    name = $STR_VN_B_GROUP_BOAT_01;
                    faction = "B_MACV";
                    icon = "\A3\ui_f\data\map\markers\nato\b_naval.paa";
                    rarityGroup = 0.5;
                    side = 1;
                    class Unit0
                    {
                        side = 1;
                        vehicle = "vn_b_boat_06_02";
                        rank = "CAPTAIN";
                        position[] = {0,0,0};
                    };
                };
                class vn_b_group_boat_04
                {
                    name = $STR_VN_B_GROUP_BOAT_01;
                    faction = "B_MACV";
                    icon = "\A3\ui_f\data\map\markers\nato\b_naval.paa";
                    rarityGroup = 0.5;
                    side = 1;
                    class Unit0
                    {
                        side = 1;
                        vehicle = "vn_b_boat_05_02";
                        rank = "CAPTAIN";
                        position[] = {0,0,0};
                    };
                };
            };
        };
    };

};


