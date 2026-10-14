// Guerrilla (Jungle), 14 Oct 2026: the Viet Cong and PAVN compositions of the Military (Jungle) set, so an
// insurgent commander on a jungle terrain gets them rather than the base game's Tanoa guerrilla set.
// Regenerate with build/composition_tools/genvnguerrilla.py rather than editing by hand.
class OutpostsLarge
    {
        name = $STR_ALIVE_COMP_VN_OutpostsLarge;
    };
class OutpostsMedium
    {
        name = $STR_ALIVE_COMP_VN_OutpostsMedium;
        class OutpostsMedium_FiringTrench_O_VC
        {
            name = "Firing Trench [O_VC]";
            icon = \vn\objects_f_vietnam\flags\vn_flag_01_vc_co.paa;
            size = 8;
            class Object0	{side = 8; vehicle = "Land_vn_o_trench_firing_01"; rank = ""; position[] = {0,0,0}; dir = 0;};
            class Object1	{side = 8; vehicle = "Land_vn_o_shelter_04"; rank = ""; position[] = {0,-11,0}; dir = 0;};
            class Object2	{side = 8; vehicle = "Land_vn_fence_punji_02_10"; rank = ""; position[] = {-6,12,0}; dir = 0;};
            class Object3	{side = 8; vehicle = "Land_vn_fence_punji_02_10"; rank = ""; position[] = {6,12,0}; dir = 0;};
            class Object4	{side = 8; vehicle = "Land_vn_o_wallfoliage_01"; rank = ""; position[] = {-16,3,0}; dir = 0;};
            class Object5	{side = 8; vehicle = "Land_vn_o_wallfoliage_01"; rank = ""; position[] = {17,3,0}; dir = 0;};
        };
        class OutpostsMedium_BambooCamp_O_VC
        {
            name = "Bamboo Camp [O_VC]";
            icon = \vn\objects_f_vietnam\flags\vn_flag_01_vc_co.paa;
            size = 8;
            class Object0	{side = 8; vehicle = "Land_vn_hut_03"; rank = ""; position[] = {0,0,0}; dir = 0;};
            class Object1	{side = 8; vehicle = "Land_vn_bamboofence_01_s_8m_f"; rank = ""; position[] = {-4.2,10,0}; dir = 0;};
            class Object2	{side = 8; vehicle = "Land_vn_bamboofence_01_s_8m_f"; rank = ""; position[] = {4.2,10,0}; dir = 0;};
            class Object3	{side = 8; vehicle = "Land_vn_bamboofence_01_s_8m_f"; rank = ""; position[] = {-8.6,6,0}; dir = 90;};
            class Object4	{side = 8; vehicle = "Land_vn_bamboofence_01_s_8m_f"; rank = ""; position[] = {8.6,6,0}; dir = 90;};
            class Object5	{side = 8; vehicle = "Land_vn_bamboofence_01_s_8m_f"; rank = ""; position[] = {-8.6,-2.2,0}; dir = 90;};
            class Object6	{side = 8; vehicle = "Land_vn_bamboofence_01_s_8m_f"; rank = ""; position[] = {8.6,-2.2,0}; dir = 90;};
            class Object7	{side = 8; vehicle = "Land_vn_o_shelter_06"; rank = ""; position[] = {5,-7,0}; dir = 0;};
            class Object8	{side = 8; vehicle = "Land_vn_o_tower_02"; rank = ""; position[] = {-6,-8,0}; dir = 0;};
        };
    };
class OutpostsSmall
    {
        name = $STR_ALIVE_COMP_VN_OutpostsSmall;
        class OutpostsSmall_BunkerPost_O_VC
        {
            name = "Bunker Post [O_VC]";
            icon = \vn\objects_f_vietnam\flags\vn_flag_01_vc_co.paa;
            size = 8;
            class Object0	{side = 8; vehicle = "Land_vn_o_bunker_02"; rank = ""; position[] = {0,0,0}; dir = 0;};
            class Object1	{side = 8; vehicle = "Land_vn_fence_punji_02_10"; rank = ""; position[] = {0,9,0}; dir = 0;};
            class Object2	{side = 8; vehicle = "Land_vn_fence_punji_02_05"; rank = ""; position[] = {-9.5,0,0}; dir = 90;};
            class Object3	{side = 8; vehicle = "Land_vn_o_wallfoliage_01"; rank = ""; position[] = {7,7,0}; dir = 30;};
            class Object4	{side = 8; vehicle = "Land_vn_o_wallfoliage_01"; rank = ""; position[] = {-7,7.5,0}; dir = -30;};
            class Object5	{side = 8; vehicle = "vn_o_vc_static_pk_high"; rank = ""; position[] = {3.5,-10.5,0}; dir = 180;};
            class Object6	{side = 8; vehicle = "Land_vn_foodsack_01_full_brown_f"; rank = ""; position[] = {-3,-9,0}; dir = 20;};
        };
        class OutpostsSmall_SniperTree_O_VC
        {
            name = "Sniper Tree Post [O_VC]";
            icon = \vn\objects_f_vietnam\flags\vn_flag_01_vc_co.paa;
            size = 8;
            class Object0	{side = 8; vehicle = "Land_vn_o_snipertree_04"; rank = ""; position[] = {0,0,0}; dir = 0;};
            class Object1	{side = 8; vehicle = "Land_vn_o_trapdoor_01"; rank = ""; position[] = {7,-6,0}; dir = 0;};
            class Object2	{side = 8; vehicle = "Land_vn_fence_punji_01_03"; rank = ""; position[] = {-6,8,0}; dir = 20;};
            class Object3	{side = 8; vehicle = "Land_vn_fence_punji_01_03"; rank = ""; position[] = {6,8,0}; dir = -20;};
            class Object4	{side = 8; vehicle = "Land_vn_o_wallfoliage_01"; rank = ""; position[] = {-5,-7,0}; dir = 90;};
        };
    };
