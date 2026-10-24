// ALiVE's own map pins for places on the map, in the same look as the task pins (mil_c2istar
// CfgMarkers.hpp): Arma's own icon in white on the NATO frame of a side (blue box BLUFOR, red diamond
// OPFOR, green square Independent, purple box Civilian), one class per side: alive_pin_<key>_<w|e|i|c>.
// color[] is white and the marker is made with colour "Default", so Arma does not tint it. Scope 1: ALiVE
// places these itself, they are not in the marker list. Used when the player has ALiVE pins on in Map pins
// and markers and Tidy map labels on: rally points (sup_group_manager), FOBs (sup_fob), and the tablet's
// picks and an informant's marks (mil_c2istar); ALiVE_fnc_mapPins "pinType" picks the side.
// alive_pin_disc only gives the map label layer the size of a unit pin: the layer draws that pin itself
// from data\pins\alive_frame_<side>.paa tinted by side and alive_glyph_<kind>.paa (ALiVE_fnc_mapPinsLayout).
class CfgMarkers
{
    class alive_pin_rally_w
    {
        scope = 1;
        name = "rally (BLUFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_rally_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_rally_e
    {
        scope = 1;
        name = "rally (OPFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_rally_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_rally_i
    {
        scope = 1;
        name = "rally (Independent)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_rally_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_rally_c
    {
        scope = 1;
        name = "rally (Civilian)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_rally_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_fob_w
    {
        scope = 1;
        name = "fob (BLUFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_fob_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_fob_e
    {
        scope = 1;
        name = "fob (OPFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_fob_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_fob_i
    {
        scope = 1;
        name = "fob (Independent)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_fob_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_fob_c
    {
        scope = 1;
        name = "fob (Civilian)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_fob_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_destination_w
    {
        scope = 1;
        name = "destination (BLUFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_destination_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_destination_e
    {
        scope = 1;
        name = "destination (OPFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_destination_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_destination_i
    {
        scope = 1;
        name = "destination (Independent)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_destination_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_destination_c
    {
        scope = 1;
        name = "destination (Civilian)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_destination_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_pickup_w
    {
        scope = 1;
        name = "pickup (BLUFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_pickup_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_pickup_e
    {
        scope = 1;
        name = "pickup (OPFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_pickup_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_pickup_i
    {
        scope = 1;
        name = "pickup (Independent)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_pickup_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_pickup_c
    {
        scope = 1;
        name = "pickup (Civilian)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_pickup_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_routeend_w
    {
        scope = 1;
        name = "routeEnd (BLUFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_routeend_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_routeend_e
    {
        scope = 1;
        name = "routeEnd (OPFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_routeend_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_routeend_i
    {
        scope = 1;
        name = "routeEnd (Independent)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_routeend_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_routeend_c
    {
        scope = 1;
        name = "routeEnd (Civilian)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_routeend_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_supplyrequest_w
    {
        scope = 1;
        name = "supplyRequest (BLUFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_supplyrequest_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_supplyrequest_e
    {
        scope = 1;
        name = "supplyRequest (OPFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_supplyrequest_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_supplyrequest_i
    {
        scope = 1;
        name = "supplyRequest (Independent)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_supplyrequest_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_supplyrequest_c
    {
        scope = 1;
        name = "supplyRequest (Civilian)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_supplyrequest_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_striketarget_w
    {
        scope = 1;
        name = "strikeTarget (BLUFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_striketarget_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_striketarget_e
    {
        scope = 1;
        name = "strikeTarget (OPFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_striketarget_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_striketarget_i
    {
        scope = 1;
        name = "strikeTarget (Independent)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_striketarget_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_striketarget_c
    {
        scope = 1;
        name = "strikeTarget (Civilian)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_striketarget_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_report_w
    {
        scope = 1;
        name = "report (BLUFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_report_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_report_e
    {
        scope = 1;
        name = "report (OPFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_report_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_report_i
    {
        scope = 1;
        name = "report (Independent)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_report_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_report_c
    {
        scope = 1;
        name = "report (Civilian)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_report_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_civilian_w
    {
        scope = 1;
        name = "civilian (BLUFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_civilian_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_civilian_e
    {
        scope = 1;
        name = "civilian (OPFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_civilian_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_civilian_i
    {
        scope = 1;
        name = "civilian (Independent)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_civilian_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_civilian_c
    {
        scope = 1;
        name = "civilian (Civilian)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_civilian_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_threat_w
    {
        scope = 1;
        name = "threat (BLUFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_threat_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_threat_e
    {
        scope = 1;
        name = "threat (OPFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_threat_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_threat_i
    {
        scope = 1;
        name = "threat (Independent)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_threat_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_threat_c
    {
        scope = 1;
        name = "threat (Civilian)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_threat_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_installation_w
    {
        scope = 1;
        name = "installation (BLUFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_installation_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_installation_e
    {
        scope = 1;
        name = "installation (OPFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_installation_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_installation_i
    {
        scope = 1;
        name = "installation (Independent)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_installation_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_installation_c
    {
        scope = 1;
        name = "installation (Civilian)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_installation_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_ambush_w
    {
        scope = 1;
        name = "ambush (BLUFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_ambush_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_ambush_e
    {
        scope = 1;
        name = "ambush (OPFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_ambush_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_ambush_i
    {
        scope = 1;
        name = "ambush (Independent)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_ambush_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_ambush_c
    {
        scope = 1;
        name = "ambush (Civilian)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_ambush_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_unknowncontact_w
    {
        scope = 1;
        name = "unknownContact (BLUFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_unknowncontact_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_unknowncontact_e
    {
        scope = 1;
        name = "unknownContact (OPFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_unknowncontact_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_unknowncontact_i
    {
        scope = 1;
        name = "unknownContact (Independent)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_unknowncontact_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_unknowncontact_c
    {
        scope = 1;
        name = "unknownContact (Civilian)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_unknowncontact_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_radiation_w
    {
        scope = 1;
        name = "radiation (BLUFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_radiation_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_radiation_e
    {
        scope = 1;
        name = "radiation (OPFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_radiation_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_radiation_i
    {
        scope = 1;
        name = "radiation (Independent)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_radiation_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_radiation_c
    {
        scope = 1;
        name = "radiation (Civilian)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_radiation_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_objective_w
    {
        scope = 1;
        name = "objective (BLUFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_objective_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_objective_e
    {
        scope = 1;
        name = "objective (OPFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_objective_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_objective_i
    {
        scope = 1;
        name = "objective (Independent)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_objective_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_objective_c
    {
        scope = 1;
        name = "objective (Civilian)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_objective_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_hvt_w
    {
        scope = 1;
        name = "hvt (BLUFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_hvt_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_hvt_e
    {
        scope = 1;
        name = "hvt (OPFOR)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_hvt_e.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_hvt_i
    {
        scope = 1;
        name = "hvt (Independent)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_hvt_i.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_hvt_c
    {
        scope = 1;
        name = "hvt (Civilian)";
        icon = "\x\alive\addons\main\data\pins\alive_pin_hvt_c.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_disc
    {
        scope = 1;
        name = "Unit pin";
        icon = "\x\alive\addons\main\data\pins\alive_frame_w.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
};
