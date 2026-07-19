// remember the player's map pan + zoom so re-opening the tablet returns to it
private _saveMap = (findDisplay 655555) displayCtrl 655560;
if (!isNull _saveMap) then {
    private _cp = ctrlPosition _saveMap;
    uinamespace setVariable ["NEO_radioMapScale", ctrlMapScale _saveMap];
    uinamespace setVariable ["NEO_radioMapCenter", _saveMap ctrlMapScreenToWorld [(_cp select 0) + (_cp select 2) / 2, (_cp select 1) + (_cp select 3) / 2]];
};

if (!isNil { NEO_radioLogic getVariable "NEO_radioTalkWithPilot" }) then
{
    NEO_radioLogic setVariable ["NEO_radioTalkWithPilot", nil];
};

if (!isNil { NEO_radioLogic getVariable "NEO_radioTalkWithArty" }) then
{
    NEO_radioLogic setVariable ["NEO_radioTalkWithArty", nil];
};

if (!isNil { uinamespace getVariable "NEO_radioCurrentAction" }) then
{
    uinamespace setVariable ["NEO_radioCurrentAction", nil];
};

if (!isNil { uinamespace getVariable "NEO_radioCbVehicle" }) then
{
    uinamespace setVariable ["NEO_radioCbVehicle", nil];
};

{
    _x setMarkerAlphaLocal 0;
} forEach (NEO_radioLogic getVariable "NEO_supportArtyMarkers");

(NEO_radioLogic getVariable "NEO_supportMarker") setMarkerAlphaLocal 0;
[[], 0] call NEO_fnc_supportDrawRing; // hide the area-of-influence ring

showGPS true;
