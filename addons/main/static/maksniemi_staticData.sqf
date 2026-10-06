// ALiVE 3 index v3.1, made 2026-10-06 by the ALiVE web indexer, building positions measured
private["_worldName"];

_worldName = tolower(worldName);

["SETTING UP MAP: maksniemi (ALiVE 3 index v3.1, 2026-10-06)"] call ALiVE_fnc_dump;

ALiVE_indexVersion = ["3.1", "2026-10-06", "web", true];

ALIVE_Indexing_Blacklist = [];
ALIVE_militaryBuildingTypes = [];
ALIVE_militaryParkingBuildingTypes = [];
ALIVE_militarySupplyBuildingTypes = [];
ALIVE_militaryHQBuildingTypes = [];
ALIVE_militaryFieldworkBuildingTypes = [];
ALIVE_airBuildingTypes = [];
ALIVE_militaryAirBuildingTypes = [];
ALIVE_civilianAirBuildingTypes = [];
ALiVE_HeliBuildingTypes = [];
ALIVE_militaryHeliBuildingTypes = [];
ALIVE_civilianHeliBuildingTypes = [];
ALIVE_civilianSettlementBuildingTypes = [];
ALIVE_civilianHQBuildingTypes = [];
ALIVE_civilianPopulationBuildingTypes = [];
ALIVE_civilianPowerBuildingTypes = [];
ALIVE_civilianCommsBuildingTypes = [];
ALIVE_civilianMarineBuildingTypes = [];
ALIVE_civilianRailBuildingTypes = [];
ALIVE_civilianFuelBuildingTypes = [];
ALIVE_civilianConstructionBuildingTypes = [];

ALiVE_mapCompositionType = "Woodland";

 if (tolower(_worldName) == "maksniemi") then {
    ALIVE_Indexing_Blacklist = ALIVE_Indexing_Blacklist + [
        "a3\map_tanoabuka\data\roaddecals\arrow_right.p3d",
        "a3\props_f_enoch\civilian\camping\woodentable_02_large_f.p3d",
        "a3\props_f_exp\industrial\heavyequipment\excavator_01_abandoned_f.p3d",
        "a3\structures_f\civ\accessories\timbers_f.p3d",
        "a3\structures_f\ind\shed\shed_big_f.p3d",
        "a3\structures_f_argo\commercial\billboards\billboard_02_carrental_f.p3d",
        "a3\structures_f_argo\commercial\billboards\billboard_02_chernarus_f.p3d",
        "a3\structures_f_argo\commercial\billboards\billboard_02_chevre2_f.p3d",
        "a3\structures_f_argo\commercial\billboards\billboard_02_ion_f.p3d",
        "a3\structures_f_argo\commercial\billboards\billboard_04_koke_redstone_f.p3d",
        "a3\structures_f_argo\commercial\billboards\billboard_04_supermarket_maskrtnik_f.p3d",
        "a3\structures_f_argo\walls\city\wallcity_01_pillar_grey_f.p3d",
        "a3\structures_f_argo\walls\net\netfence_02_m_gate_v2_closed_f.p3d",
        "a3\structures_f_enoch\civilian\camps\caravan_01_green_f.p3d",
        "a3\structures_f_enoch\civilian\constructions\scaffolding_new_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\tombstone_04_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\tombstone_05_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\tombstone_06_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\tombstone_08_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\tombstone_09_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\tombstone_10_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\tombstone_11_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\tombstone_13_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\tombstone_14_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\tombstone_16_f.p3d",
        "a3\structures_f_enoch\cultural\cemeteries\tombstone_17_f.p3d",
        "a3\structures_f_enoch\cultural\statues\monument_02_f.p3d",
        "a3\structures_f_enoch\cultural\statues\statue_03_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_cracks_01_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_cracks_02_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_cracks_03_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_cracks_04_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_cracks_05_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_patch_01_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_patch_03_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_patch_04_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_patch_05_f.p3d",
        "a3\structures_f_enoch\decals\horizontal\roads_patch_10_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberlog_01_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberlog_02_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberlog_03_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberlog_04_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberpile_02_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberpile_03_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberpile_04_f.p3d",
        "a3\structures_f_enoch\industrial\materials\timberpile_05_f.p3d",
        "a3\structures_f_enoch\infrastructure\bridges\bridge_asphalt_02_left_f.p3d",
        "a3\structures_f_enoch\infrastructure\bridges\bridge_asphalt_02_right_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_bridge_40_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_crossing_barrier_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_track_down_25_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_track_down_40_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_track_passing_25_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_track_up_25_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_track_up_40_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_tracke_25_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_tracke_40_f.p3d",
        "a3\structures_f_enoch\infrastructure\railways\rail_tracke_r25_5_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_01_l_5m_f.p3d",
        "a3\structures_f_enoch\walls\brick\brickwall_01_l_pole_f.p3d",
        "a3\structures_f_enoch\walls\net\gameprooffence_01_l_pole_f.p3d",
        "a3\structures_f_enoch\walls\net\netfence_03_m_3m_d_f.p3d",
        "a3\structures_f_enoch\walls\net\netfence_03_m_3m_f.p3d",
        "a3\structures_f_enoch\walls\net\netfence_03_m_3m_hole_f.p3d",
        "a3\structures_f_enoch\walls\net\netfence_03_m_pole_f.p3d",
        "a3\structures_f_enoch\walls\polewalls\polewall_02_3m_v1_f.p3d",
        "a3\structures_f_enoch\walls\polewalls\polewall_02_end_f.p3d",
        "a3\structures_f_enoch\walls\stone\mound03_8m_f.p3d",
        "a3\structures_f_enoch\walls\stone\mound04_8m_f.p3d",
        "a3\structures_f_enoch\walls\stone\stonewall_02_s_10m_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_03_s_5m_v1_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_03_s_5m_v2_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_03_s_d_5m_v1_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_03_s_gate_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_03_s_pole_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_04_s_5m_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_04_s_pole_f.p3d",
        "a3\structures_f_enoch\walls\wooden\woodenwall_05_m_4m_v1_f.p3d",
        "a3\structures_f_exp\civilian\accessories\clothesline_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_06_f.p3d",
        "a3\structures_f_exp\cultural\basaltruins\basaltwall_01_8m_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runway_01_centerline_10m_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runway_01_centerline_20m_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runway_01_centerline_5m_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runway_01_threshold_20m_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runwaydigit_0_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runwaydigit_1_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runwaydigit_2_f.p3d",
        "a3\structures_f_exp\infrastructure\runways\runwaydigit_9_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_03_f.p3d",
        "a3\structures_f_exp\walls\backalleys\backalley_01_l_gate_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_01_m_gate_v1_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_01_m_gate_v2_f.p3d",
        "a3\structures_f_exp\walls\pipe\pipefence_01_m_pole_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_4m_f.p3d",
        "a3\structures_f_exp\walls\wired\wiredfence_01_pole_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_02_s_2m_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_02_s_4m_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_02_s_gate_f.p3d",
        "a3\structures_f_exp\walls\wooden\woodenwall_02_s_pole_f.p3d",
        "a3\structures_f_heli\civ\constructions\gastank_01_khaki_f.p3d",
        "vt4_objects\decals\juoksurata\juoksurata.p3d",
        "vt4_objects\decals\kiitorata\kiitorata_main_40m.p3d",
        "vt4_objects\decals\kolmiot\isokolmio_tie.p3d",
        "vt4_objects\decals\kolmiot\pikkukolmio_tie.p3d",
        "vt4_objects\decals\nuolet\nuoli_eteen_oikea.p3d",
        "vt4_objects\decals\nuolet\nuoli_vasen.p3d",
        "vt4_objects\decals\parkkiruutu\parkkiruutu.p3d",
        "vt4_objects\decals\patches\asphaltpatch_01.p3d",
        "vt4_objects\decals\patches\asphaltpatch_02.p3d",
        "vt4_objects\decals\roads\levennys_alku\levennys_alku_1_1.p3d",
        "vt4_objects\decals\roads\levennys_alku\levennys_alku_1_2.p3d",
        "vt4_objects\decals\roads\levennys_alku\levennys_alku_1_3.p3d",
        "vt4_objects\decals\roads\levennys_alku\levennys_alku_1_4.p3d",
        "vt4_objects\decals\roads\levennys_alku\levennys_alku_2_1.p3d",
        "vt4_objects\decals\roads\levennys_alku\levennys_alku_2_2.p3d",
        "vt4_objects\decals\roads\levennys_alku\levennys_alku_2_3.p3d",
        "vt4_objects\decals\roads\levennys_alku\levennys_alku_3_1.p3d",
        "vt4_objects\decals\roads\levennys_alku\levennys_alku_3_2.p3d",
        "vt4_objects\decals\roads\levennys_alku\levennys_alku_3_3.p3d",
        "vt4_objects\decals\roads\levennys_alku\levennys_alku_3_4.p3d",
        "vt4_objects\decals\roads\maantie_levennys_alku\maantie_levennys_alku_1.p3d",
        "vt4_objects\decals\roads\maantie_levennys_alku\maantie_levennys_alku_2.p3d",
        "vt4_objects\decals\roads\maantie_levennys_alku\maantie_levennys_alku_3.p3d",
        "vt4_objects\decals\roads\maantie_levennys_alku\maantie_levennys_alku_4.p3d",
        "vt4_objects\decals\roads\motari_risteys\motari_risteys_1_1.p3d",
        "vt4_objects\decals\roads\motari_risteys\motari_risteys_1_2.p3d",
        "vt4_objects\decals\roads\motari_risteys\motari_risteys_1_3.p3d",
        "vt4_objects\decals\roads\motari_risteys\motari_risteys_1_4.p3d",
        "vt4_objects\decals\roads\motari_risteys\motari_risteys_2.p3d",
        "vt4_objects\decals\roads\motari_risteys\motari_risteys_2_merkit.p3d",
        "vt4_objects\decals\roads\motari_risteys\motari_risteys_3.p3d",
        "vt4_objects\decals\roads\motari_risteys\motari_risteys_3_merkit.p3d",
        "vt4_objects\decals\roads\motari_risteys\motari_risteys_4.p3d",
        "vt4_objects\decals\roads\ohituskaista_alku\ohituskaista_alku_1.p3d",
        "vt4_objects\decals\roads\ohituskaista_alku\ohituskaista_alku_2.p3d",
        "vt4_objects\decals\suojatie\suojatie.p3d",
        "vt4_objects\objects\aanivalli\aanivalli.p3d",
        "vt4_objects\objects\alikulut\alikulku_motari.p3d",
        "vt4_objects\objects\alikulut\alikulku_pieni.p3d",
        "vt4_objects\objects\alikulut\motari_alikulku_kaide_loppu_o_lc.p3d",
        "vt4_objects\objects\alikulut\motari_alikulku_kaide_loppu_v_lc.p3d",
        "vt4_objects\objects\alikulut\motari_alikulku_kaide_o_lc.p3d",
        "vt4_objects\objects\alikulut\motari_alikulku_kaide_v_lc.p3d",
        "vt4_objects\objects\alikulut\teboil_alikulku.p3d",
        "vt4_objects\objects\ampumataulu\ampumataulu.p3d",
        "vt4_objects\objects\isot_opasteet\opaste_karsikko_kemi_maksniemi.p3d",
        "vt4_objects\objects\isot_opasteet\opaste_maksniemi_oulu_karsikko.p3d",
        "vt4_objects\objects\junarata_sahkolinja\junarata_sahkolinja.p3d",
        "vt4_objects\objects\kaapeliaita\kaapeliaita_alku_lc.p3d",
        "vt4_objects\objects\kaapeliaita\kaapeliaita_heijastin_lc.p3d",
        "vt4_objects\objects\kaapeliaita\kaapeliaita_lc.p3d",
        "vt4_objects\objects\kalerv0\liikenteenjakaja_paksu.p3d",
        "vt4_objects\objects\kalerv0\sumupaalu.p3d",
        "vt4_objects\objects\katulamppu\puinen_katu_lamppu.p3d",
        "vt4_objects\objects\kyltit\katukyltit\aittasaarentie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\ankkuriniementie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\ervarstintie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\hallitie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\hietaperantie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\holstinharjuntie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\kaartotie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\kalasatamantie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\kantolanharju.p3d",
        "vt4_objects\objects\kyltit\katukyltit\karintie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\karsikontie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\katajatie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\kerolantie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\kiertotie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\kirkkotarhantie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\kirkkotie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\kitiniementie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\kortetie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\kuussaarentie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\lahdentie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\lahdepolku.p3d",
        "vt4_objects\objects\kyltit\katukyltit\lansirannantie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\lansitie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\lapintie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\loukkutie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\lukkarilantie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\luotsitie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\maksniementie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\marostenmaentie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\nenantie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\niemelantie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\ojanperantie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\paanuniementie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\palohovintie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\palokankaantie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\pappilantie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\pekkalantie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\poijutie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\postintie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\puntarniementie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\ruikkalantie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\rysatie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\saarenrannantie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\saarentie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\sankelantie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\saukkorannantie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\siikatie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\simonraitti.p3d",
        "vt4_objects\objects\kyltit\katukyltit\taavintie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\tervastie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\tiitontie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\tikkalantie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\torviaavantie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\toyryntie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\turskantie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\uimarannantie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\urheilutie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\vaajatie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\vakkalantie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\vanha_karsikontie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\veikontie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\viantienjoentie.p3d",
        "vt4_objects\objects\kyltit\katukyltit\ykskuusentie.p3d",
        "vt4_objects\objects\kyltit\kyltti.p3d",
        "vt4_objects\objects\kyltit\kyltti_kemi.p3d",
        "vt4_objects\objects\kyltit\kyltti_kemi20.p3d",
        "vt4_objects\objects\kyltit\kyltti_kemi_kunta.p3d",
        "vt4_objects\objects\kyltit\kyltti_kemi_kunta_sininen.p3d",
        "vt4_objects\objects\kyltit\kyltti_motari.p3d",
        "vt4_objects\objects\kyltit\kyltti_motari_loppu.p3d",
        "vt4_objects\objects\kyltit\kyltti_oulu.p3d",
        "vt4_objects\objects\kyltit\kyltti_oulu2.p3d",
        "vt4_objects\objects\kyltit\kyltti_simo_kunta.p3d",
        "vt4_objects\objects\kyltit\kyltti_simo_kunta_sininen.p3d",
        "vt4_objects\objects\kyltit\kyltti_sotilas_alue.p3d",
        "vt4_objects\objects\laavu\laavu.p3d",
        "vt4_objects\objects\mattoteline\mattoteline.p3d",
        "vt4_objects\objects\motari_aita\motari_aita.p3d",
        "vt4_objects\objects\motari_aita\motari_aita_heijastin.p3d",
        "vt4_objects\objects\motari_aita\motari_aita_heijastin_lc.p3d",
        "vt4_objects\objects\motari_aita\motari_aita_lc.p3d",
        "vt4_objects\objects\nopeusrajoitustaulu\kalerv0_nopeusrajoitukset\nopeusrajoitus_100.p3d",
        "vt4_objects\objects\nopeusrajoitustaulu\kalerv0_nopeusrajoitukset\nopeusrajoitus_30.p3d",
        "vt4_objects\objects\nopeusrajoitustaulu\kalerv0_nopeusrajoitukset\nopeusrajoitus_40.p3d",
        "vt4_objects\objects\nopeusrajoitustaulu\kalerv0_nopeusrajoitukset\nopeusrajoitus_60.p3d",
        "vt4_objects\objects\nopeusrajoitustaulu\kalerv0_nopeusrajoitukset\nopeusrajoitus_80.p3d",
        "vt4_objects\objects\nopeusrajoitustaulu\nopeusrajoitustaulu_100.p3d",
        "vt4_objects\objects\postilaatikot\keltainen_postilaatikko.p3d",
        "vt4_objects\objects\postilaatikot\punainen_postilaatikko.p3d",
        "vt4_objects\objects\postilaatikot\sininen_postilaatikko.p3d",
        "vt4_objects\objects\postilaatikot\vihrea_postilaatikko.p3d",
        "vt4_objects\objects\riistaaita\riistaaita.p3d",
        "vt4_objects\objects\riistaaita\riistaaita_d.p3d",
        "vt4_objects\objects\riistaaita\riistaaita_pole.p3d",
        "vt4_objects\objects\roskakori\roskakori_harmaa.p3d",
        "vt4_objects\objects\roskakori\roskakori_punainen.p3d",
        "vt4_objects\objects\roskakori\roskakori_sininen.p3d",
        "vt4_objects\objects\roskakori\roskakori_vihrea.p3d",
        "vt4_objects\objects\sahkolinja\lc\sahkolinja_kaapeli_20m_lc_f.p3d",
        "vt4_objects\objects\sahkolinja\lc\sahkolinja_kaapeli_30m_15_o_lc_f.p3d",
        "vt4_objects\objects\sahkolinja\lc\sahkolinja_kaapeli_30m_15_v_lc_f.p3d",
        "vt4_objects\objects\sahkolinja\lc\sahkolinja_kaapeli_30m_lc_f.p3d",
        "vt4_objects\objects\sahkolinja\lc\sahkolinja_kaapeli_40m_lc_f.p3d",
        "vt4_objects\objects\sahkolinja\lc\sahkolinja_kaapeli_50m_15_o_lc_f.p3d",
        "vt4_objects\objects\sahkolinja\lc\sahkolinja_kaapeli_50m_15_v_lc_f.p3d",
        "vt4_objects\objects\sahkolinja\lc\sahkolinja_kaapeli_50m_1_kaapeli_lc_f.p3d",
        "vt4_objects\objects\sahkolinja\lc\sahkolinja_kaapeli_50m_30_o_lc_f.p3d",
        "vt4_objects\objects\sahkolinja\lc\sahkolinja_kaapeli_50m_30_v_lc_f.p3d",
        "vt4_objects\objects\sahkolinja\lc\sahkolinja_kaapeli_50m_45_o_lc_f.p3d",
        "vt4_objects\objects\sahkolinja\lc\sahkolinja_kaapeli_50m_45_v_lc_f.p3d",
        "vt4_objects\objects\sahkolinja\lc\sahkolinja_kaapeli_50m_7_o_lc_f.p3d",
        "vt4_objects\objects\sahkolinja\lc\sahkolinja_kaapeli_50m_7_v_lc_f.p3d",
        "vt4_objects\objects\sahkolinja\lc\sahkolinja_kaapeli_50m_lc_f.p3d",
        "vt4_objects\objects\satamaopaste\satamaopaste.p3d",
        "vt4_objects\objects\teboil\kyltti\teboil_kyltti.p3d",
        "vt4_objects\objects\tiilitys\tiilitys.p3d",
        "vt4_objects\objects\tiilitys\tiilitys_leijuva.p3d",
        "vt4_objects\objects\voimalinja\voimalinja.p3d",
        "vt4_objects\objects\voimalinja\voimalinjakaapeli.p3d",
        "vt4_objects\objects\voimalinja\voimalinjakaapeli_7_o_lc_f.p3d"
    ];

    ALIVE_militaryBuildingTypes = ALIVE_militaryBuildingTypes + [
        "a3\structures_f\ind\airport\airport_tower_f.p3d",
        "a3\structures_f\mil\bunker\bunker_f.p3d",
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardhouse_02_grey_f.p3d",
        "a3\structures_f_enoch\military\barracks\guardtower_02_f.p3d",
        "a3\structures_f_enoch\military\radar\mobileradar_01_radar_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_hangar_left_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_terminal_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_camo_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_grey_f.p3d",
        "vt4_objects\objects\varuskunta_portti\varuskunta_portti.p3d"
    ];

    ALIVE_militaryParkingBuildingTypes = ALIVE_militaryParkingBuildingTypes + [
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_terminal_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_camo_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_grey_f.p3d"
    ];

    ALIVE_militarySupplyBuildingTypes = ALIVE_militarySupplyBuildingTypes + [
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_terminal_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_camo_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_grey_f.p3d"
    ];

    ALIVE_militaryHQBuildingTypes = ALIVE_militaryHQBuildingTypes + [
        "a3\structures_f\mil\offices\miloffices_v1_f.p3d",
        "a3\structures_f_enoch\military\barracks\barracks_06_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_terminal_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_camo_f.p3d",
        "a3\structures_f_exp\military\barracks_01\barracks_01_grey_f.p3d"
    ];

    ALIVE_militaryFieldworkBuildingTypes = ALIVE_militaryFieldworkBuildingTypes + [
        "a3\structures_f_enoch\military\barracks\guardtower_02_f.p3d"
    ];

    ALIVE_airBuildingTypes = ALIVE_airBuildingTypes + [
        "a3\structures_f\ind\airport\hangar_f.p3d",
        "a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_hangar_left_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_hangar_right_f.p3d"
    ];

    ALIVE_militaryAirBuildingTypes = ALIVE_militaryAirBuildingTypes + [
        "a3\structures_f\ind\airport\hangar_f.p3d",
        "a3\structures_f\mil\tenthangar\tenthangar_v1_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_01_hangar_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_hangar_left_f.p3d",
        "a3\structures_f_exp\infrastructure\airports\airport_02_hangar_right_f.p3d"
    ];

    ALIVE_civilianSettlementBuildingTypes = ALIVE_civilianSettlementBuildingTypes + [
        "a3\props_f_enoch\civilian\forest\deerstand_02_f.p3d",
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f\ind\reservoirtank\reservoirtower_f.p3d",
        "a3\structures_f\ind\shed\i_shed_ind_f.p3d",
        "a3\structures_f\ind\shed\u_shed_ind_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_grey_f.p3d",
        "a3\structures_f_enoch\civilian\camps\camp_house_01_brown_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1b01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w07_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w08_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w09_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w10_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w12_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w13_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w05_f.p3d",
        "a3\structures_f_enoch\civilian\sheds\shed_14_f.p3d",
        "a3\structures_f_enoch\commercial\villagestore_01\villagestore_01_f.p3d",
        "a3\structures_f_enoch\cultural\church_04\church_04_small_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_02_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_03_large_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_03_small_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_f.p3d",
        "a3\structures_f_enoch\industrial\farms\greenhouse_01_f.p3d",
        "a3\structures_f_enoch\industrial\garages\garagerow_01_small_f.p3d",
        "a3\structures_f_enoch\industrial\houses\factory_02_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_01_grey_f.p3d",
        "a3\structures_f_enoch\industrial\houses\workshop_02_grey_f.p3d",
        "a3\structures_f_enoch\industrial\sheds\industrialshed_01_f.p3d",
        "a3\structures_f_exp\civilian\garages\garageshelter_01_f.p3d",
        "a3\structures_f_exp\civilian\house_big_03\house_big_03_f.p3d",
        "a3\structures_f_exp\civilian\house_big_05\house_big_05_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_01_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_02_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_05_f.p3d",
        "a3\structures_f_exp\civilian\sheds\shed_07_f.p3d",
        "a3\structures_f_exp\commercial\warehouses\warehouse_03_f.p3d",
        "a3\structures_f_exp\cultural\church_01\church_01_f.p3d",
        "a3\structures_f_exp\industrial\port\warehouse_01_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_warehouse_f.p3d"
    ];

    ALIVE_civilianHQBuildingTypes = ALIVE_civilianHQBuildingTypes + [
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w05_f.p3d",
        "a3\structures_f_exp\civilian\house_big_03\house_big_03_f.p3d"
    ];

    ALIVE_civilianPopulationBuildingTypes = ALIVE_civilianPopulationBuildingTypes + [
        "a3\structures_f\civ\offices\offices_01_v1_f.p3d",
        "a3\structures_f_argo\industrial\agriculture\barn_01_grey_f.p3d",
        "a3\structures_f_enoch\civilian\camps\camp_house_01_brown_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1b01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w07_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w08_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w09_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w10_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w12_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_1w13_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2b04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w01_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w02_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w03_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w04_f.p3d",
        "a3\structures_f_enoch\civilian\houses\house_2w05_f.p3d",
        "a3\structures_f_enoch\commercial\villagestore_01\villagestore_01_f.p3d",
        "a3\structures_f_enoch\cultural\church_04\church_04_small_f.p3d",
        "a3\structures_f_exp\civilian\house_big_03\house_big_03_f.p3d",
        "a3\structures_f_exp\civilian\house_big_05\house_big_05_f.p3d",
        "a3\structures_f_exp\commercial\warehouses\warehouse_03_f.p3d",
        "a3\structures_f_exp\cultural\church_01\church_01_f.p3d"
    ];

    ALIVE_civilianPowerBuildingTypes = ALIVE_civilianPowerBuildingTypes + [
        "a3\structures_f\ind\dieselpowerplant\dp_smallfactory_f.p3d",
        "a3\structures_f\ind\solarpowerplant\spp_transformer_f.p3d"
    ];

    ALIVE_civilianCommsBuildingTypes = ALIVE_civilianCommsBuildingTypes + [
        "a3\structures_f\ind\transmitter_tower\tbox_f.p3d",
        "vt4_objects\objects\puhelinmasto\puhelinmasto.p3d"
    ];

    ALIVE_civilianMarineBuildingTypes = ALIVE_civilianMarineBuildingTypes + [
        "a3\structures_f\naval\piers\pier_small_f.p3d",
        "a3\structures_f_exp\industrial\port\warehouse_02_f.p3d",
        "a3\structures_f_exp\naval\piers\pierwooden_01_10m_norails_f.p3d"
    ];

    ALIVE_civilianFuelBuildingTypes = ALIVE_civilianFuelBuildingTypes + [
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_pump_f.p3d",
        "a3\structures_f_exp\commercial\fuelstation_01\fuelstation_01_roof_f.p3d",
        "a3\structures_f_exp\industrial\sugarcanefactory_01\scf_01_storagebin_small_f.p3d",
        "vt4_objects\objects\teboil\kylmaasema\kylmaasema.p3d",
        "vt4_objects\objects\teboil\lisaosa\lisaosa.p3d"
    ];

    ALIVE_civilianConstructionBuildingTypes = ALIVE_civilianConstructionBuildingTypes + [
        "a3\structures_f\ind\factory\factory_main_f.p3d",
        "a3\structures_f_enoch\industrial\farms\barn_04_f.p3d"
    ];

};
