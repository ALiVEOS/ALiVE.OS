// One map marker per C2ISTAR task: the coloured pin on its cream disc, drawn in its own colours. color[]
// is white and the marker is made with colour "Default", so Arma does not tint it. Scope 2 with their own
// marker class puts them in an "ALiVE task pins" group in Eden and in the in-game map's marker list, so a
// mission maker can place them by hand (Jman 23 Oct). Used by ALiVE_fnc_taskCreateMarker when the player's
// Task Pins option is on.
class CfgMarkerClasses
{
    class ALiVE_TaskPins
    {
        displayName = "ALiVE Task Pins";
    };
};
class CfgMarkers
{
    class alive_pin_aiddelivery
    {
        scope = 2;
        name = "Aid Delivery";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_aiddelivery.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_medicaloutreach
    {
        scope = 2;
        name = "Medical Outreach";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_medicaloutreach.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_marketreopening
    {
        scope = 2;
        name = "Market Reopening";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_marketreopening.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_securecommunityevent
    {
        scope = 2;
        name = "Secure Community Event";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_securecommunityevent.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_meetlocalleader
    {
        scope = 2;
        name = "Meet Local Leader";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_meetlocalleader.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_repaircriticalservice
    {
        scope = 2;
        name = "Repair Critical Service";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_repaircriticalservice.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_checkpointpartnership
    {
        scope = 2;
        name = "Checkpoint Partnership";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_checkpointpartnership.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_civassault
    {
        scope = 2;
        name = "Civilian Assault";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_civassault.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_informantexfiltration
    {
        scope = 2;
        name = "Informant Exfiltration";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_informantexfiltration.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_vipescort
    {
        scope = 2;
        name = "VIP Escort";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_vipescort.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_rescue
    {
        scope = 2;
        name = "Rescue";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_rescue.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_csar
    {
        scope = 2;
        name = "Combat Search and Rescue";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_csar.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_transportinsertion
    {
        scope = 2;
        name = "Transport Insertion";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_transportinsertion.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_supplyconvoy
    {
        scope = 2;
        name = "Supply Convoy";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_supplyconvoy.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_protectconvoy
    {
        scope = 2;
        name = "Protect Convoy";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_protectconvoy.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_assassination
    {
        scope = 2;
        name = "Assassination";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_assassination.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_destroyvehicles
    {
        scope = 2;
        name = "Destroy Vehicles";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_destroyvehicles.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_destroyinfantry
    {
        scope = 2;
        name = "Destroy Infantry";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_destroyinfantry.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_destroybuilding
    {
        scope = 2;
        name = "Destroy Building";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_destroybuilding.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_sabotagebuilding
    {
        scope = 2;
        name = "Sabotage Building";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_sabotagebuilding.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_removeied
    {
        scope = 2;
        name = "Remove IED";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_removeied.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_insurgencydestroyassets
    {
        scope = 2;
        name = "Destroy Insurgent Assets";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_insurgencydestroyassets.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_insurgencypatrol
    {
        scope = 2;
        name = "Insurgency Patrol";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_insurgencypatrol.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_cas
    {
        scope = 2;
        name = "Close Air Support";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_cas.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_sead
    {
        scope = 2;
        name = "Suppress Air Defences";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_sead.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_dca
    {
        scope = 2;
        name = "Defensive Counter Air";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_dca.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_oca
    {
        scope = 2;
        name = "Offensive Counter Air";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_oca.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_laze
    {
        scope = 2;
        name = "Laze Target";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_laze.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_reconobjective
    {
        scope = 2;
        name = "Recon Objective";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_reconobjective.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_wiretap
    {
        scope = 2;
        name = "Wiretap";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_wiretap.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_captureobjective
    {
        scope = 2;
        name = "Capture Objective";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_captureobjective.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_milassault
    {
        scope = 2;
        name = "Assault";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_milassault.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_mildefence
    {
        scope = 2;
        name = "Defence";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_mildefence.paa";
        color[] = {1,1,1,1};
        size = 32;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
};
