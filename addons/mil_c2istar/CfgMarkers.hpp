// One map marker per C2ISTAR task and side: Arma's own icon for that kind of task in white on the side's
// NATO frame (blue box BLUFOR, red diamond OPFOR, green square Independent, purple box Civilian),
// alive_pin_<task>_<w|e|i|c>. color[] is white and the marker is made with colour "Default", so Arma does
// not tint it. Scope 2 with their own marker class puts them in an "ALiVE task pins" group in Eden and in
// the in-game map's marker list, so a mission maker can place them by hand. Used by
// ALiVE_fnc_taskCreateMarker when the player has ALiVE pins on in Map pins and markers.
class CfgMarkerClasses
{
    class ALiVE_TaskPins
    {
        displayName = "ALiVE Task Pins";
    };
};
class CfgMarkers
{
    class alive_pin_aiddelivery_w
    {
        scope = 2;
        name = "AidDelivery (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_aiddelivery_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_aiddelivery_e
    {
        scope = 2;
        name = "AidDelivery (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_aiddelivery_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_aiddelivery_i
    {
        scope = 2;
        name = "AidDelivery (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_aiddelivery_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_aiddelivery_c
    {
        scope = 2;
        name = "AidDelivery (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_aiddelivery_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_medicaloutreach_w
    {
        scope = 2;
        name = "MedicalOutreach (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_medicaloutreach_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_medicaloutreach_e
    {
        scope = 2;
        name = "MedicalOutreach (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_medicaloutreach_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_medicaloutreach_i
    {
        scope = 2;
        name = "MedicalOutreach (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_medicaloutreach_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_medicaloutreach_c
    {
        scope = 2;
        name = "MedicalOutreach (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_medicaloutreach_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_marketreopening_w
    {
        scope = 2;
        name = "MarketReopening (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_marketreopening_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_marketreopening_e
    {
        scope = 2;
        name = "MarketReopening (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_marketreopening_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_marketreopening_i
    {
        scope = 2;
        name = "MarketReopening (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_marketreopening_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_marketreopening_c
    {
        scope = 2;
        name = "MarketReopening (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_marketreopening_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_securecommunityevent_w
    {
        scope = 2;
        name = "SecureCommunityEvent (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_securecommunityevent_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_securecommunityevent_e
    {
        scope = 2;
        name = "SecureCommunityEvent (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_securecommunityevent_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_securecommunityevent_i
    {
        scope = 2;
        name = "SecureCommunityEvent (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_securecommunityevent_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_securecommunityevent_c
    {
        scope = 2;
        name = "SecureCommunityEvent (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_securecommunityevent_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_meetlocalleader_w
    {
        scope = 2;
        name = "MeetLocalLeader (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_meetlocalleader_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_meetlocalleader_e
    {
        scope = 2;
        name = "MeetLocalLeader (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_meetlocalleader_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_meetlocalleader_i
    {
        scope = 2;
        name = "MeetLocalLeader (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_meetlocalleader_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_meetlocalleader_c
    {
        scope = 2;
        name = "MeetLocalLeader (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_meetlocalleader_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_repaircriticalservice_w
    {
        scope = 2;
        name = "RepairCriticalService (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_repaircriticalservice_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_repaircriticalservice_e
    {
        scope = 2;
        name = "RepairCriticalService (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_repaircriticalservice_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_repaircriticalservice_i
    {
        scope = 2;
        name = "RepairCriticalService (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_repaircriticalservice_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_repaircriticalservice_c
    {
        scope = 2;
        name = "RepairCriticalService (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_repaircriticalservice_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_checkpointpartnership_w
    {
        scope = 2;
        name = "CheckpointPartnership (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_checkpointpartnership_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_checkpointpartnership_e
    {
        scope = 2;
        name = "CheckpointPartnership (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_checkpointpartnership_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_checkpointpartnership_i
    {
        scope = 2;
        name = "CheckpointPartnership (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_checkpointpartnership_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_checkpointpartnership_c
    {
        scope = 2;
        name = "CheckpointPartnership (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_checkpointpartnership_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_civassault_w
    {
        scope = 2;
        name = "CivAssault (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_civassault_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_civassault_e
    {
        scope = 2;
        name = "CivAssault (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_civassault_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_civassault_i
    {
        scope = 2;
        name = "CivAssault (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_civassault_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_civassault_c
    {
        scope = 2;
        name = "CivAssault (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_civassault_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_informantexfiltration_w
    {
        scope = 2;
        name = "InformantExfiltration (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_informantexfiltration_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_informantexfiltration_e
    {
        scope = 2;
        name = "InformantExfiltration (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_informantexfiltration_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_informantexfiltration_i
    {
        scope = 2;
        name = "InformantExfiltration (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_informantexfiltration_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_informantexfiltration_c
    {
        scope = 2;
        name = "InformantExfiltration (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_informantexfiltration_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_vipescort_w
    {
        scope = 2;
        name = "VIPEscort (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_vipescort_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_vipescort_e
    {
        scope = 2;
        name = "VIPEscort (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_vipescort_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_vipescort_i
    {
        scope = 2;
        name = "VIPEscort (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_vipescort_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_vipescort_c
    {
        scope = 2;
        name = "VIPEscort (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_vipescort_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_rescue_w
    {
        scope = 2;
        name = "Rescue (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_rescue_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_rescue_e
    {
        scope = 2;
        name = "Rescue (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_rescue_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_rescue_i
    {
        scope = 2;
        name = "Rescue (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_rescue_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_rescue_c
    {
        scope = 2;
        name = "Rescue (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_rescue_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_csar_w
    {
        scope = 2;
        name = "CSAR (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_csar_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_csar_e
    {
        scope = 2;
        name = "CSAR (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_csar_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_csar_i
    {
        scope = 2;
        name = "CSAR (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_csar_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_csar_c
    {
        scope = 2;
        name = "CSAR (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_csar_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_transportinsertion_w
    {
        scope = 2;
        name = "TransportInsertion (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_transportinsertion_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_transportinsertion_e
    {
        scope = 2;
        name = "TransportInsertion (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_transportinsertion_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_transportinsertion_i
    {
        scope = 2;
        name = "TransportInsertion (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_transportinsertion_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_transportinsertion_c
    {
        scope = 2;
        name = "TransportInsertion (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_transportinsertion_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_supplyconvoy_w
    {
        scope = 2;
        name = "SupplyConvoy (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_supplyconvoy_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_supplyconvoy_e
    {
        scope = 2;
        name = "SupplyConvoy (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_supplyconvoy_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_supplyconvoy_i
    {
        scope = 2;
        name = "SupplyConvoy (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_supplyconvoy_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_supplyconvoy_c
    {
        scope = 2;
        name = "SupplyConvoy (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_supplyconvoy_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_protectconvoy_w
    {
        scope = 2;
        name = "ProtectConvoy (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_protectconvoy_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_protectconvoy_e
    {
        scope = 2;
        name = "ProtectConvoy (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_protectconvoy_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_protectconvoy_i
    {
        scope = 2;
        name = "ProtectConvoy (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_protectconvoy_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_protectconvoy_c
    {
        scope = 2;
        name = "ProtectConvoy (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_protectconvoy_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_assassination_w
    {
        scope = 2;
        name = "Assassination (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_assassination_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_assassination_e
    {
        scope = 2;
        name = "Assassination (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_assassination_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_assassination_i
    {
        scope = 2;
        name = "Assassination (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_assassination_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_assassination_c
    {
        scope = 2;
        name = "Assassination (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_assassination_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_destroyvehicles_w
    {
        scope = 2;
        name = "DestroyVehicles (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_destroyvehicles_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_destroyvehicles_e
    {
        scope = 2;
        name = "DestroyVehicles (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_destroyvehicles_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_destroyvehicles_i
    {
        scope = 2;
        name = "DestroyVehicles (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_destroyvehicles_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_destroyvehicles_c
    {
        scope = 2;
        name = "DestroyVehicles (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_destroyvehicles_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_destroyinfantry_w
    {
        scope = 2;
        name = "DestroyInfantry (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_destroyinfantry_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_destroyinfantry_e
    {
        scope = 2;
        name = "DestroyInfantry (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_destroyinfantry_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_destroyinfantry_i
    {
        scope = 2;
        name = "DestroyInfantry (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_destroyinfantry_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_destroyinfantry_c
    {
        scope = 2;
        name = "DestroyInfantry (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_destroyinfantry_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_destroybuilding_w
    {
        scope = 2;
        name = "DestroyBuilding (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_destroybuilding_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_destroybuilding_e
    {
        scope = 2;
        name = "DestroyBuilding (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_destroybuilding_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_destroybuilding_i
    {
        scope = 2;
        name = "DestroyBuilding (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_destroybuilding_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_destroybuilding_c
    {
        scope = 2;
        name = "DestroyBuilding (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_destroybuilding_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_sabotagebuilding_w
    {
        scope = 2;
        name = "SabotageBuilding (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_sabotagebuilding_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_sabotagebuilding_e
    {
        scope = 2;
        name = "SabotageBuilding (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_sabotagebuilding_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_sabotagebuilding_i
    {
        scope = 2;
        name = "SabotageBuilding (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_sabotagebuilding_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_sabotagebuilding_c
    {
        scope = 2;
        name = "SabotageBuilding (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_sabotagebuilding_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_removeied_w
    {
        scope = 2;
        name = "RemoveIED (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_removeied_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_removeied_e
    {
        scope = 2;
        name = "RemoveIED (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_removeied_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_removeied_i
    {
        scope = 2;
        name = "RemoveIED (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_removeied_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_removeied_c
    {
        scope = 2;
        name = "RemoveIED (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_removeied_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_insurgencydestroyassets_w
    {
        scope = 2;
        name = "InsurgencyDestroyAssets (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_insurgencydestroyassets_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_insurgencydestroyassets_e
    {
        scope = 2;
        name = "InsurgencyDestroyAssets (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_insurgencydestroyassets_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_insurgencydestroyassets_i
    {
        scope = 2;
        name = "InsurgencyDestroyAssets (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_insurgencydestroyassets_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_insurgencydestroyassets_c
    {
        scope = 2;
        name = "InsurgencyDestroyAssets (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_insurgencydestroyassets_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_insurgencypatrol_w
    {
        scope = 2;
        name = "InsurgencyPatrol (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_insurgencypatrol_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_insurgencypatrol_e
    {
        scope = 2;
        name = "InsurgencyPatrol (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_insurgencypatrol_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_insurgencypatrol_i
    {
        scope = 2;
        name = "InsurgencyPatrol (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_insurgencypatrol_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_insurgencypatrol_c
    {
        scope = 2;
        name = "InsurgencyPatrol (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_insurgencypatrol_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_cas_w
    {
        scope = 2;
        name = "CAS (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_cas_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_cas_e
    {
        scope = 2;
        name = "CAS (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_cas_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_cas_i
    {
        scope = 2;
        name = "CAS (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_cas_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_cas_c
    {
        scope = 2;
        name = "CAS (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_cas_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_sead_w
    {
        scope = 2;
        name = "SEAD (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_sead_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_sead_e
    {
        scope = 2;
        name = "SEAD (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_sead_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_sead_i
    {
        scope = 2;
        name = "SEAD (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_sead_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_sead_c
    {
        scope = 2;
        name = "SEAD (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_sead_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_dca_w
    {
        scope = 2;
        name = "DCA (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_dca_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_dca_e
    {
        scope = 2;
        name = "DCA (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_dca_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_dca_i
    {
        scope = 2;
        name = "DCA (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_dca_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_dca_c
    {
        scope = 2;
        name = "DCA (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_dca_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_oca_w
    {
        scope = 2;
        name = "OCA (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_oca_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_oca_e
    {
        scope = 2;
        name = "OCA (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_oca_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_oca_i
    {
        scope = 2;
        name = "OCA (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_oca_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_oca_c
    {
        scope = 2;
        name = "OCA (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_oca_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_laze_w
    {
        scope = 2;
        name = "Laze (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_laze_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_laze_e
    {
        scope = 2;
        name = "Laze (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_laze_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_laze_i
    {
        scope = 2;
        name = "Laze (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_laze_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_laze_c
    {
        scope = 2;
        name = "Laze (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_laze_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_reconobjective_w
    {
        scope = 2;
        name = "ReconObjective (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_reconobjective_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_reconobjective_e
    {
        scope = 2;
        name = "ReconObjective (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_reconobjective_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_reconobjective_i
    {
        scope = 2;
        name = "ReconObjective (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_reconobjective_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_reconobjective_c
    {
        scope = 2;
        name = "ReconObjective (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_reconobjective_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_wiretap_w
    {
        scope = 2;
        name = "Wiretap (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_wiretap_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_wiretap_e
    {
        scope = 2;
        name = "Wiretap (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_wiretap_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_wiretap_i
    {
        scope = 2;
        name = "Wiretap (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_wiretap_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_wiretap_c
    {
        scope = 2;
        name = "Wiretap (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_wiretap_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_captureobjective_w
    {
        scope = 2;
        name = "CaptureObjective (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_captureobjective_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_captureobjective_e
    {
        scope = 2;
        name = "CaptureObjective (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_captureobjective_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_captureobjective_i
    {
        scope = 2;
        name = "CaptureObjective (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_captureobjective_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_captureobjective_c
    {
        scope = 2;
        name = "CaptureObjective (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_captureobjective_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_milassault_w
    {
        scope = 2;
        name = "MilAssault (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_milassault_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_milassault_e
    {
        scope = 2;
        name = "MilAssault (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_milassault_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_milassault_i
    {
        scope = 2;
        name = "MilAssault (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_milassault_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_milassault_c
    {
        scope = 2;
        name = "MilAssault (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_milassault_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_mildefence_w
    {
        scope = 2;
        name = "MilDefence (BLUFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_mildefence_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_mildefence_e
    {
        scope = 2;
        name = "MilDefence (OPFOR)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_mildefence_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_mildefence_i
    {
        scope = 2;
        name = "MilDefence (Independent)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_mildefence_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
    class alive_pin_mildefence_c
    {
        scope = 2;
        name = "MilDefence (Civilian)";
        icon = "\x\alive\addons\mil_c2istar\data\pins\alive_pin_mildefence_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        markerClass = "ALiVE_TaskPins";
        showEditorMarkerColor = 0;
    };
};
