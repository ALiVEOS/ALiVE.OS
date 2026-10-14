// Guerrilla (Jungle), 14 Oct 2026: the Viet Cong and PAVN compositions of the Military (Jungle) set, so an
// insurgent commander on a jungle terrain gets them rather than the base game's Tanoa guerrilla set.
// Regenerate with build/composition_tools/genvnguerrilla.py rather than editing by hand.
class CheckpointsBarricadesLarge
    {
    	name = $STR_ALIVE_COMP_VN_CheckpointsBarricadesLarge;
    };
class CheckpointsBarricadesMedium
    {
    	name = $STR_ALIVE_COMP_VN_CheckpointsBarricadesMedium;
        class CheckpointsMedium_BambooGate_O_VC
        {
            name = "Bamboo Gate [O_VC]";
            icon = \vn\objects_f_vietnam\flags\vn_flag_01_vc_co.paa;
            size = 8;
            class Object0	{side = 8; vehicle = "Land_vn_bamboofence_01_s_8m_f"; rank = ""; position[] = {-8.5,0,0}; dir = 0;};
            class Object1	{side = 8; vehicle = "Land_vn_bamboofence_01_s_8m_f"; rank = ""; position[] = {8.5,0,0}; dir = 0;};
            class Object2	{side = 8; vehicle = "Land_vn_o_shelter_06"; rank = ""; position[] = {-7,-4,0}; dir = 0;};
            class Object3	{side = 8; vehicle = "Land_vn_sandbagbarricade_01_half_f"; rank = ""; position[] = {6,-3,0}; dir = 0;};
            class Object4	{side = 8; vehicle = "vn_o_vc_static_pk_high"; rank = ""; position[] = {6,-6.5,0}; dir = 180;};
            class Object5	{side = 8; vehicle = "Land_vn_fence_punji_02_10"; rank = ""; position[] = {0,6,0}; dir = 0;};
        };
    };
class CheckpointsBarricadesSmall
    {
    	//WEST
    	name = $STR_ALIVE_COMP_VN_CheckpointsBarricadesSmall;
        class CheckpointsSmall_PunjiRoadblock_O_VC
        {
            name = "Punji Roadblock [O_VC]";
            icon = \vn\objects_f_vietnam\flags\vn_flag_01_vc_co.paa;
            size = 8;
            class Object0	{side = 8; vehicle = "Land_vn_fence_punji_01_10"; rank = ""; position[] = {0,0,0}; dir = 0;};
            class Object1	{side = 8; vehicle = "Land_vn_czechhedgehog_01_f"; rank = ""; position[] = {-7,3,0}; dir = 15;};
            class Object2	{side = 8; vehicle = "Land_vn_czechhedgehog_01_f"; rank = ""; position[] = {7,3,0}; dir = -10;};
            class Object3	{side = 8; vehicle = "Land_vn_sandbagbarricade_01_half_f"; rank = ""; position[] = {-3,-4,0}; dir = 0;};
            class Object4	{side = 8; vehicle = "Land_vn_sandbagbarricade_01_half_f"; rank = ""; position[] = {3,-4,0}; dir = 0;};
            class Object5	{side = 8; vehicle = "vn_o_vc_static_pk_high"; rank = ""; position[] = {0,-6,0}; dir = 180;};
        };
        class CheckpointsSmall_FoliageAmbush_O_VC
        {
            name = "Ambush Point [O_VC]";
            icon = \vn\objects_f_vietnam\flags\vn_flag_01_vc_co.paa;
            size = 8;
            class Object0	{side = 8; vehicle = "Land_vn_o_wallfoliage_01"; rank = ""; position[] = {8,-5,0}; dir = 0;};
            class Object1	{side = 8; vehicle = "Land_vn_o_wallfoliage_01"; rank = ""; position[] = {8,0,0}; dir = 0;};
            class Object2	{side = 8; vehicle = "Land_vn_o_wallfoliage_01"; rank = ""; position[] = {8,5,0}; dir = 0;};
            class Object3	{side = 8; vehicle = "vn_o_vc_static_dshkm_high_01"; rank = ""; position[] = {10.5,0,0}; dir = 270;};
            class Object4	{side = 8; vehicle = "Land_vn_o_trapdoor_01"; rank = ""; position[] = {13,6,0}; dir = 0;};
            class Object5	{side = 8; vehicle = "Land_vn_fence_punji_02_05"; rank = ""; position[] = {4,-9,0}; dir = 0;};
        };
    };
