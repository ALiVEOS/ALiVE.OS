private ["_display", "_lb", "_map", "_button", "_pos", "_marker","_objectLb"];
_display = findDisplay 655555;
_lb = _display displayCtrl 655565;
_objectLb = _display displayCtrl 655580;
_map = _this select 0;
_button = _this select 1; if (_button == 1) exitWith {};
_pos = _map ctrlMapScreenToWorld [_this select 2, _this select 3];
_marker = NEO_radioLogic getVariable "NEO_supportMarker";

ctrlMapAnimClear _map;
_map ctrlMapAnimAdd [0.5, ctrlMapScale _map, _pos];
ctrlMapAnimCommit _map;

_marker setMarkerPosLocal _pos;
_marker setMarkerAlphaLocal 1;

switch (toUpper (_lb lbText (lbCurSel _lb))) do
{
    case "TRANSPORT" :
    {
        _marker setMarkerTextLocal "Transport";
        _marker setMarkerTypeLocal "hd_Pickup";

        uinamespace setVariable ["NEO_transportMarkerCreated", _marker];
        [] call NEO_fnc_transportConfirmButtonEnable;
    };

    case "CAS" :
    {
        _marker setMarkerTextLocal "CAS";
        _marker setMarkerTypeLocal "hd_Destroy";

        uinamespace setVariable ["NEO_casMarkerCreated", _marker];
        [] call NEO_fnc_casConfirmButtonEnable;
    };

    case "ARTY" :
    {
        _marker setMarkerTextLocal "STRIKE";
        _marker setMarkerTypeLocal "hd_Destroy";

        uinamespace setVariable ["NEO_artyMarkerCreated", _marker];
        [] call NEO_fnc_artyConfirmButtonEnable;
    };
};

if (ctrlEnabled _objectLb) then {

    private ["_transportArray","_transportUnitLb","_chopper","_nearestObjects"];
    _transportArray = NEO_radioLogic getVariable format ["NEO_radioTrasportArray_%1", playerSide];
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

    _objectLb lbSetCurSel 0;
};
