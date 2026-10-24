// One task type per C2ISTAR task, showing Arma's own icon for that kind of task (the same one as its map
// pin), so the task list and the on-screen task pin tint it by task state like Arma's own types. The
// icons are the game's, not copies. Used by ALiVE_fnc_taskHandlerClient (setSimpleTaskType) when the
// player has ALiVE pins on in Map pins and markers.
class CfgTaskTypes
{
    class alive_pin_aiddelivery
    {
        displayName = "Aid Delivery";
        icon = "\A3\ui_f\data\map\vehicleicons\iconparachute_ca.paa";
        icon3D = "\A3\ui_f\data\map\vehicleicons\iconparachute_ca.paa";
    };
    class alive_pin_medicaloutreach
    {
        displayName = "Medical Outreach";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\heal_ca.paa";
        icon3D = "\A3\ui_f\data\igui\cfg\simpleTasks\types\heal_ca.paa";
    };
    class alive_pin_marketreopening
    {
        displayName = "Market Reopening";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\container_ca.paa";
        icon3D = "\A3\ui_f\data\igui\cfg\simpleTasks\types\container_ca.paa";
    };
    class alive_pin_securecommunityevent
    {
        displayName = "Secure Community Event";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\meet_ca.paa";
        icon3D = "\A3\ui_f\data\igui\cfg\simpleTasks\types\meet_ca.paa";
    };
    class alive_pin_meetlocalleader
    {
        displayName = "Meet Local Leader";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\talk_ca.paa";
        icon3D = "\A3\ui_f\data\igui\cfg\simpleTasks\types\talk_ca.paa";
    };
    class alive_pin_repaircriticalservice
    {
        displayName = "Repair Critical Service";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\repair_ca.paa";
        icon3D = "\A3\ui_f\data\igui\cfg\simpleTasks\types\repair_ca.paa";
    };
    class alive_pin_checkpointpartnership
    {
        displayName = "Checkpoint Partnership";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\documents_ca.paa";
        icon3D = "\A3\ui_f\data\igui\cfg\simpleTasks\types\documents_ca.paa";
    };
    class alive_pin_civassault
    {
        displayName = "Civilian Assault";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\danger_ca.paa";
        icon3D = "\A3\ui_f\data\igui\cfg\simpleTasks\types\danger_ca.paa";
    };
    class alive_pin_informantexfiltration
    {
        displayName = "Informant Exfiltration";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\exit_ca.paa";
        icon3D = "\A3\ui_f\data\igui\cfg\simpleTasks\types\exit_ca.paa";
    };
    class alive_pin_vipescort
    {
        displayName = "VIP Escort";
        icon = "\A3\ui_f\data\map\vehicleicons\iconmancommander_ca.paa";
        icon3D = "\A3\ui_f\data\map\vehicleicons\iconmancommander_ca.paa";
    };
    class alive_pin_rescue
    {
        displayName = "Rescue";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\help_ca.paa";
        icon3D = "\A3\ui_f\data\igui\cfg\simpleTasks\types\help_ca.paa";
    };
    class alive_pin_csar
    {
        displayName = "Combat Search and Rescue";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\heli_ca.paa";
        icon3D = "\A3\ui_f\data\igui\cfg\simpleTasks\types\heli_ca.paa";
    };
    class alive_pin_transportinsertion
    {
        displayName = "Transport Insertion";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\land_ca.paa";
        icon3D = "\A3\ui_f\data\igui\cfg\simpleTasks\types\land_ca.paa";
    };
    class alive_pin_supplyconvoy
    {
        displayName = "Supply Convoy";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\truck_ca.paa";
        icon3D = "\A3\ui_f\data\igui\cfg\simpleTasks\types\truck_ca.paa";
    };
    class alive_pin_protectconvoy
    {
        displayName = "Protect Convoy";
        icon = "\A3\ui_f\data\map\vehicleicons\icontruck_ca.paa";
        icon3D = "\A3\ui_f\data\map\vehicleicons\icontruck_ca.paa";
    };
    class alive_pin_assassination
    {
        displayName = "Assassination";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\kill_ca.paa";
        icon3D = "\A3\ui_f\data\igui\cfg\simpleTasks\types\kill_ca.paa";
    };
    class alive_pin_destroyvehicles
    {
        displayName = "Destroy Vehicles";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\destroy_ca.paa";
        icon3D = "\A3\ui_f\data\igui\cfg\simpleTasks\types\destroy_ca.paa";
    };
    class alive_pin_destroyinfantry
    {
        displayName = "Destroy Infantry";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\rifle_ca.paa";
        icon3D = "\A3\ui_f\data\igui\cfg\simpleTasks\types\rifle_ca.paa";
    };
    class alive_pin_destroybuilding
    {
        displayName = "Destroy Building";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\mine_ca.paa";
        icon3D = "\A3\ui_f\data\igui\cfg\simpleTasks\types\mine_ca.paa";
    };
    class alive_pin_sabotagebuilding
    {
        displayName = "Sabotage Building";
        icon = "\A3\ui_f\data\map\vehicleicons\iconexplosivegp_ca.paa";
        icon3D = "\A3\ui_f\data\map\vehicleicons\iconexplosivegp_ca.paa";
    };
    class alive_pin_removeied
    {
        displayName = "Remove IED";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\search_ca.paa";
        icon3D = "\A3\ui_f\data\igui\cfg\simpleTasks\types\search_ca.paa";
    };
    class alive_pin_insurgencydestroyassets
    {
        displayName = "Destroy Insurgent Assets";
        icon = "\A3\ui_f\data\map\vehicleicons\iconcratewpns_ca.paa";
        icon3D = "\A3\ui_f\data\map\vehicleicons\iconcratewpns_ca.paa";
    };
    class alive_pin_insurgencypatrol
    {
        displayName = "Insurgency Patrol";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\walk_ca.paa";
        icon3D = "\A3\ui_f\data\igui\cfg\simpleTasks\types\walk_ca.paa";
    };
    class alive_pin_cas
    {
        displayName = "Close Air Support";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\plane_ca.paa";
        icon3D = "\A3\ui_f\data\igui\cfg\simpleTasks\types\plane_ca.paa";
    };
    class alive_pin_sead
    {
        displayName = "Suppress Air Defences";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\target_ca.paa";
        icon3D = "\A3\ui_f\data\igui\cfg\simpleTasks\types\target_ca.paa";
    };
    class alive_pin_dca
    {
        displayName = "Defensive Counter Air";
        icon = "\A3\ui_f\data\map\vehicleicons\iconstaticaa_ca.paa";
        icon3D = "\A3\ui_f\data\map\vehicleicons\iconstaticaa_ca.paa";
    };
    class alive_pin_oca
    {
        displayName = "Offensive Counter Air";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\takeoff_ca.paa";
        icon3D = "\A3\ui_f\data\igui\cfg\simpleTasks\types\takeoff_ca.paa";
    };
    class alive_pin_laze
    {
        displayName = "Laze Target";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\navigate_ca.paa";
        icon3D = "\A3\ui_f\data\igui\cfg\simpleTasks\types\navigate_ca.paa";
    };
    class alive_pin_reconobjective
    {
        displayName = "Recon Objective";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\scout_ca.paa";
        icon3D = "\A3\ui_f\data\igui\cfg\simpleTasks\types\scout_ca.paa";
    };
    class alive_pin_wiretap
    {
        displayName = "Wiretap";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\listen_ca.paa";
        icon3D = "\A3\ui_f\data\igui\cfg\simpleTasks\types\listen_ca.paa";
    };
    class alive_pin_captureobjective
    {
        displayName = "Capture Objective";
        icon = "\A3\ui_f\data\map\markers\military\objective_ca.paa";
        icon3D = "\A3\ui_f\data\map\markers\military\objective_ca.paa";
    };
    class alive_pin_milassault
    {
        displayName = "Assault";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\attack_ca.paa";
        icon3D = "\A3\ui_f\data\igui\cfg\simpleTasks\types\attack_ca.paa";
    };
    class alive_pin_mildefence
    {
        displayName = "Defence";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\defend_ca.paa";
        icon3D = "\A3\ui_f\data\igui\cfg\simpleTasks\types\defend_ca.paa";
    };
};
