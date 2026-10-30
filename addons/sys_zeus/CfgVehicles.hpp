// Plain Zeus modules: placed by a Zeus only (scope 1, scopeCurator 2), never in Eden. Each one
// runs ALiVE_fnc_zeusModule on the Zeus's machine, which reads ALiVE_zeusAction to know what
// was placed. Modules that work on a unit are dropped onto it (curatorCanAttach).
class CfgVehicles {
    class Logic;
    class Module_F : Logic
    {
        class AttributesBase { class Edit; class Combo; class ModuleDescription; };
    };
    class ModuleAliveBase : Module_F
    {
        class AttributesBase : AttributesBase { class ALiVE_ModuleSubTitle; };
        class ModuleDescription;
    };

    class ALiVE_ModuleZeusBase : ModuleAliveBase
    {
        scope = 1;
        scopeCurator = 0;
        function = "ALiVE_fnc_zeusModule";
        functionPriority = 1;
        // runs on every machine and goes on only on the one where the module is local, the placing
        // Zeus's: at 0 it ran on the server alone, so on a dedicated server nothing happened
        isGlobal = 1;
        isDisposable = 1;
        curatorCanAttach = 0;
        author = MODULE_AUTHOR;
        icon = "x\alive\addons\main\icon_requires_alive.paa";
        picture = "x\alive\addons\main\icon_requires_alive.paa";
        ALiVE_zeusAction = "";
    };

    class ALiVE_ModuleZeusSave : ALiVE_ModuleZeusBase
    {
        scopeCurator = 2;
        displayName = "$STR_ALIVE_ZEUS_SAVE";
        ALiVE_zeusAction = "save";
        icon = "x\alive\addons\sys_data\icon_sys_data.paa";
        picture = "x\alive\addons\sys_data\icon_sys_data.paa";
    };

    class ALiVE_ModuleZeusDebug : ALiVE_ModuleZeusBase
    {
        scopeCurator = 2;
        displayName = "$STR_ALIVE_ZEUS_DEBUG";
        ALiVE_zeusAction = "debug";
        icon = "x\alive\addons\sys_profile\icon_sys_profile.paa";
        picture = "x\alive\addons\sys_profile\icon_sys_profile.paa";
    };

    class ALiVE_ModuleZeusSpotReport : ALiVE_ModuleZeusBase
    {
        scopeCurator = 2;
        displayName = "$STR_ALIVE_ZEUS_SPOTREPORT";
        ALiVE_zeusAction = "spotReport";
        icon = "x\alive\addons\mil_c2istar\icon_mil_C2.paa";
        picture = "x\alive\addons\mil_c2istar\icon_mil_C2.paa";
    };

    class ALiVE_ModuleZeusHandGroup : ALiVE_ModuleZeusBase
    {
        scopeCurator = 2;
        curatorCanAttach = 1;
        displayName = "$STR_ALIVE_ZEUS_HANDGROUP";
        ALiVE_zeusAction = "handGroup";
        icon = "x\alive\addons\mil_opcom\icon_mil_OPCOM.paa";
        picture = "x\alive\addons\mil_opcom\icon_mil_OPCOM.paa";
    };

    class ALiVE_ModuleZeusBomber : ALiVE_ModuleZeusBase
    {
        scopeCurator = 2;
        displayName = "$STR_ALIVE_ZEUS_BOMBER";
        ALiVE_zeusAction = "bomber";
        icon = "x\alive\addons\mil_ied\icon_mil_ied.paa";
        picture = "x\alive\addons\mil_ied\icon_mil_ied.paa";
    };

    class ALiVE_ModuleZeusConvertBomber : ALiVE_ModuleZeusBase
    {
        scopeCurator = 2;
        curatorCanAttach = 1;
        displayName = "$STR_ALIVE_ZEUS_CONVERTBOMBER";
        ALiVE_zeusAction = "convertBomber";
        icon = "x\alive\addons\mil_ied\icon_mil_ied.paa";
        picture = "x\alive\addons\mil_ied\icon_mil_ied.paa";
    };

    class ALiVE_ModuleZeusCarBomb : ALiVE_ModuleZeusBase
    {
        scopeCurator = 2;
        curatorCanAttach = 1;
        displayName = "$STR_ALIVE_ZEUS_CARBOMB";
        ALiVE_zeusAction = "carBomb";
        icon = "x\alive\addons\mil_ied\icon_mil_ied.paa";
        picture = "x\alive\addons\mil_ied\icon_mil_ied.paa";
    };

    class ALiVE_ModuleZeusIED : ALiVE_ModuleZeusBase
    {
        scopeCurator = 2;
        displayName = "$STR_ALIVE_ZEUS_IED";
        ALiVE_zeusAction = "ied";
        icon = "x\alive\addons\mil_ied\icon_mil_ied.paa";
        picture = "x\alive\addons\mil_ied\icon_mil_ied.paa";
    };

    class ALiVE_ModuleZeusIEDAmbush : ALiVE_ModuleZeusBase
    {
        scopeCurator = 2;
        displayName = "$STR_ALIVE_ZEUS_IEDAMBUSH";
        ALiVE_zeusAction = "iedAmbush";
        icon = "x\alive\addons\mil_ied\icon_mil_ied.paa";
        picture = "x\alive\addons\mil_ied\icon_mil_ied.paa";
    };

    class ALiVE_ModuleZeusSpawnGroup : ALiVE_ModuleZeusBase
    {
        scopeCurator = 2;
        displayName = "$STR_ALIVE_ZEUS_SPAWNGROUP";
        ALiVE_zeusAction = "spawnGroup";
        icon = "x\alive\addons\sys_profile\icon_sys_profile.paa";
        picture = "x\alive\addons\sys_profile\icon_sys_profile.paa";
    };

    class ALiVE_ModuleZeusRemoveGroup : ALiVE_ModuleZeusBase
    {
        scopeCurator = 2;
        curatorCanAttach = 1;
        displayName = "$STR_ALIVE_ZEUS_REMOVEGROUP";
        ALiVE_zeusAction = "removeGroup";
        icon = "x\alive\addons\sys_profile\icon_sys_profile.paa";
        picture = "x\alive\addons\sys_profile\icon_sys_profile.paa";
    };

    class ALiVE_ModuleZeusObjective : ALiVE_ModuleZeusBase
    {
        scopeCurator = 2;
        displayName = "$STR_ALIVE_ZEUS_OBJECTIVE";
        ALiVE_zeusAction = "objective";
        icon = "x\alive\addons\mil_opcom\icon_mil_OPCOM.paa";
        picture = "x\alive\addons\mil_opcom\icon_mil_OPCOM.paa";
    };

    class ALiVE_ModuleZeusRevealInstallations : ALiVE_ModuleZeusBase
    {
        scopeCurator = 2;
        displayName = "$STR_ALIVE_ZEUS_REVEAL";
        ALiVE_zeusAction = "reveal";
        icon = "x\alive\addons\mil_opcom\icon_mil_OPCOM.paa";
        picture = "x\alive\addons\mil_opcom\icon_mil_OPCOM.paa";
    };

    class ALiVE_ModuleZeusCreateTask : ALiVE_ModuleZeusBase
    {
        scopeCurator = 2;
        displayName = "$STR_ALIVE_ZEUS_CREATETASK";
        ALiVE_zeusAction = "createTask";
        icon = "x\alive\addons\mil_c2istar\icon_mil_C2.paa";
        picture = "x\alive\addons\mil_c2istar\icon_mil_C2.paa";
    };

    class ALiVE_ModuleZeusCloseTask : ALiVE_ModuleZeusBase
    {
        scopeCurator = 2;
        curatorCanAttach = 1;
        displayName = "$STR_ALIVE_ZEUS_CLOSETASK";
        ALiVE_zeusAction = "closeTask";
        icon = "x\alive\addons\mil_c2istar\icon_mil_C2.paa";
        picture = "x\alive\addons\mil_c2istar\icon_mil_C2.paa";
    };

    class ALiVE_ModuleZeusAirStrike : ALiVE_ModuleZeusBase
    {
        scopeCurator = 2;
        displayName = "$STR_ALIVE_ZEUS_AIRSTRIKE";
        ALiVE_zeusAction = "airStrike";
        icon = "x\alive\addons\mil_ato\icon_mil_ATO.paa";
        picture = "x\alive\addons\mil_ato\icon_mil_ATO.paa";
    };

    class ALiVE_ModuleZeusResupply : ALiVE_ModuleZeusBase
    {
        scopeCurator = 2;
        displayName = "$STR_ALIVE_ZEUS_RESUPPLY";
        ALiVE_zeusAction = "resupply";
        icon = "x\alive\addons\mil_logistics\icon_mil_ML.paa";
        picture = "x\alive\addons\mil_logistics\icon_mil_ML.paa";
    };

    class ALiVE_ModuleZeusTownMood : ALiVE_ModuleZeusBase
    {
        scopeCurator = 2;
        displayName = "$STR_ALIVE_ZEUS_TOWNMOOD";
        ALiVE_zeusAction = "townMood";
        icon = "x\alive\addons\amb_civ_population\icon_civ_pop.paa";
        picture = "x\alive\addons\amb_civ_population\icon_civ_pop.paa";
    };

    class ALiVE_ModuleZeusTipOff : ALiVE_ModuleZeusBase
    {
        scopeCurator = 2;
        curatorCanAttach = 1;
        displayName = "$STR_ALIVE_ZEUS_TIPOFF";
        ALiVE_zeusAction = "tipOff";
        icon = "x\alive\addons\amb_civ_population\icon_civ_pop.paa";
        picture = "x\alive\addons\amb_civ_population\icon_civ_pop.paa";
    };

    class ALiVE_ModuleZeusAngryCrowd : ALiVE_ModuleZeusBase
    {
        scopeCurator = 2;
        displayName = "$STR_ALIVE_ZEUS_ANGRYCROWD";
        ALiVE_zeusAction = "angryCrowd";
        icon = "x\alive\addons\amb_civ_population\icon_civ_pop.paa";
        picture = "x\alive\addons\amb_civ_population\icon_civ_pop.paa";
    };

    class ALiVE_ModuleZeusCreateHub : ALiVE_ModuleZeusBase
    {
        scopeCurator = 2;
        curatorCanAttach = 1;
        displayName = "$STR_ALIVE_ZEUS_CREATEHUB";
        ALiVE_zeusAction = "createHub";
        icon = "x\alive\addons\sup_player_resupply\icon_sup_logistics_hub.paa";
        picture = "x\alive\addons\sup_player_resupply\icon_sup_logistics_hub.paa";
    };

    class ALiVE_ModuleZeusRemoveHub : ALiVE_ModuleZeusBase
    {
        scopeCurator = 2;
        curatorCanAttach = 1;
        displayName = "$STR_ALIVE_ZEUS_REMOVEHUB";
        ALiVE_zeusAction = "removeHub";
        icon = "x\alive\addons\sup_player_resupply\icon_sup_logistics_hub.paa";
        picture = "x\alive\addons\sup_player_resupply\icon_sup_logistics_hub.paa";
    };

    class ALiVE_ModuleZeusCreateFob : ALiVE_ModuleZeusBase
    {
        scopeCurator = 2;
        curatorCanAttach = 0;
        displayName = "$STR_ALIVE_ZEUS_CREATEFOB";
        ALiVE_zeusAction = "createFob";
        icon = "x\alive\addons\sup_fob\icon_sup_fob.paa";
        picture = "x\alive\addons\sup_fob\icon_sup_fob.paa";
    };

    class ALiVE_ModuleZeusRemoveFob : ALiVE_ModuleZeusBase
    {
        scopeCurator = 2;
        curatorCanAttach = 0;
        displayName = "$STR_ALIVE_ZEUS_REMOVEFOB";
        ALiVE_zeusAction = "removeFob";
        icon = "x\alive\addons\sup_fob\icon_sup_fob.paa";
        picture = "x\alive\addons\sup_fob\icon_sup_fob.paa";
    };

    class ALiVE_ModuleZeusCreateRally : ALiVE_ModuleZeusBase
    {
        scopeCurator = 2;
        curatorCanAttach = 1;
        displayName = "$STR_ALIVE_ZEUS_CREATERALLY";
        ALiVE_zeusAction = "createRally";
        icon = "x\alive\addons\sup_group_manager\icon_sup_rally.paa";
        picture = "x\alive\addons\sup_group_manager\icon_sup_rally.paa";
    };

    class ALiVE_ModuleZeusRemoveRally : ALiVE_ModuleZeusBase
    {
        scopeCurator = 2;
        curatorCanAttach = 1;
        displayName = "$STR_ALIVE_ZEUS_REMOVERALLY";
        ALiVE_zeusAction = "removeRally";
        icon = "x\alive\addons\sup_group_manager\icon_sup_rally.paa";
        picture = "x\alive\addons\sup_group_manager\icon_sup_rally.paa";
    };
};
