// ALiVE's own map pins for places on the map, drawn in the same hand as the task pins (mil_c2istar
// CfgMarkers.hpp): the picture on a cream disc in its own colours. color[] is white and the marker is
// made with colour "Default", so Arma does not tint it. Scope 1: ALiVE places these itself, they are
// not in the marker list. Used for rally points (sup_group_manager) and FOBs (sup_fob) when the
// player has Task Pins and Tidy map labels on.
class CfgMarkers
{
    class alive_pin_rally
    {
        scope = 1;
        name = "Rally Point";
        icon = "\x\alive\addons\main\data\pins\alive_pin_rally.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
    class alive_pin_fob
    {
        scope = 1;
        name = "FOB";
        icon = "\x\alive\addons\main\data\pins\alive_pin_fob.paa";
        color[] = {1,1,1,1};
        size = 40;
        shadow = 0;
        showEditorMarkerColor = 0;
    };
};
