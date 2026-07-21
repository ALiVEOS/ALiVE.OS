// NEO_fnc_supportSetTargetPos
// #630 Shared "set the support target at a world position" logic, factored out of fn_radioMapEvent
// so BOTH the map-click AND the additive grid-entry field feed the identical marker/ring/confirm flow.
// Params: 0: _pos <ARRAY> world position [x,y(,z)]
// Author: Jman
params ["_pos"];

private ["_display", "_lb", "_marker", "_objectLb"];
_display = findDisplay 655555;
_lb = _display displayCtrl 655565;
_objectLb = _display displayCtrl 655580;
_marker = NEO_radioLogic getVariable "NEO_supportMarker";

// place the marker at the target without recentring the map - keep the player's pan/zoom
_marker setMarkerPosLocal _pos;
_marker setMarkerAlphaLocal 1;

switch (toUpper (_lb lbText (lbCurSel _lb))) do
{
    case "TRANSPORT" :
    {
        _marker setMarkerTextLocal "Transport";
        _marker setMarkerTypeLocal "hd_Pickup";

        [[], 0] call NEO_fnc_supportDrawRing; // transport has no area of influence

        uinamespace setVariable ["NEO_transportMarkerCreated", _marker];
        [] call NEO_fnc_transportConfirmButtonEnable;
    };

    case "CAS" :
    {
        _marker setMarkerTextLocal "CAS";
        _marker setMarkerTypeLocal "hd_Destroy";

        // area-of-influence ring at the CAS engagement radius (slider 655592)
        [_pos, sliderPosition (_display displayCtrl 655592), "ColorBlue"] call NEO_fnc_supportDrawRing;

        uinamespace setVariable ["NEO_casMarkerCreated", _marker];
        [] call NEO_fnc_casConfirmButtonEnable;
    };

    case "ARTY" :
    {
        _marker setMarkerTextLocal "STRIKE";
        _marker setMarkerTypeLocal "hd_Objective";
        _marker setMarkerColorLocal "ColorOrange";

        // area-of-influence ring at the dispersion / beaten zone (slider 655609); 0 = pinpoint
        [_pos, sliderPosition (_display displayCtrl 655609), "ColorOrange"] call NEO_fnc_supportDrawRing;

        uinamespace setVariable ["NEO_artyMarkerCreated", _marker];
        [] call NEO_fnc_artyConfirmButtonEnable;
    };
};

if (ctrlEnabled _objectLb) then {

    private ["_transportArray","_transportUnitLb","_chopper","_nearestObjects"];
    _transportArray = NEO_radioLogic getVariable [format ["NEO_radioTrasportArray_%1", playerSide], []];
    _transportUnitLb = _display displayCtrl 655568;

    if (!isNil {NEO_radioLogic getVariable "NEO_radioTalkWithPilot"}) then {
        _chopper = NEO_radioLogic getVariable "NEO_radioTalkWithPilot";
    }
    else {
        _chopper = _transportArray select (lbCurSel _transportUnitLb) select 0;
    };

    lbClear _objectLb;

    _nearestObjects = nearestObjects [_pos, [], 100];
    {
        if ( count (getArray (configFile >> "CfgVehicles" >> typeOf _x >> "slingLoadCargoMemoryPoints")) > 0  && ([_x] call ALiVE_fnc_getObjectWeight < [(configFile >> "CfgVehicles" >> typeOf _chopper >> "slingLoadMaxCargoMass")] call ALiVE_fnc_getConfigValue)) then {
            private ["_idx"];
            _idx = _objectLb lbAdd (getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName"));
            _objectLb lbSetData [_idx, str(getpos _x)];
        };
    } forEach _nearestObjects;

    // only auto-select when there IS cargo; lbSetCurSel 0 on an empty list fires LBSelChanged
    // with empty lbData, and parseSimpleArray "" throws a format error
    if (lbSize _objectLb > 0) then {
        _objectLb lbSetCurSel 0;
    };
};
