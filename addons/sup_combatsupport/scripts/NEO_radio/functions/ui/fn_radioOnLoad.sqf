#include "macro.sqf"

if (isNil { NEO_radioLogic getVariable "NEO_supportMarker" }) then
{
    private ["_marker"];
    _marker = createMarkerLocal ["NEO_supportMarker", [100, 1000, 0]];
    _marker setMarkerAlphaLocal 0;
    NEO_radioLogic setVariable ["NEO_supportMarker", _marker];

    private ["_markerArtyMin", "_markerArtyMax"];
    _markerArtyMin = createMarkerLocal ["NEO_supportMarkerArtyMin", [100, 1000, 0]];
    _markerArtyMin setMarkerAlphaLocal 0;
    _markerArtyMax = createMarkerLocal ["NEO_supportMarkerArtyMax", [100, 1000, 0]];
    _markerArtyMax setMarkerAlphaLocal 0;
    NEO_radioLogic setVariable ["NEO_supportArtyMarkers", [_markerArtyMin, _markerArtyMax]];
};

// target-centred area-of-influence ring (CAS radius / arty dispersion). Separate guard
// so it is created even in a session where the support marker already existed.
if (isNil { NEO_radioLogic getVariable "NEO_supportMarkerRing" }) then
{
    private _markerRing = createMarkerLocal ["NEO_supportMarkerRing", [100, 1000, 0]];
    _markerRing setMarkerShapeLocal "ELLIPSE";
    _markerRing setMarkerBrushLocal "Border";
    _markerRing setMarkerAlphaLocal 0;
    NEO_radioLogic setVariable ["NEO_supportMarkerRing", _markerRing];
};

//Display
private ["_display", "_map", "_abort", "_suppListBox", "_unit", "_action","_available", "_transportArray", "_casArray", "_artyArray"];

disableSerialization;

_suppListBox = SR_getControl(SR_Main_Display,SR_Support_List);
_translist = SR_getControl(SR_Main_Display,SR_Transport_List);
_artylist = SR_getControl(SR_Main_Display,SR_Arty_List);
_map = SR_getControl(SR_Main_Display,SR_Map);
_abort = SR_getControl(SR_Main_Display,SR_ABORT_BTN);
_unit = player;
// the ACE interaction entry opens the dialog without setting the action first
// (only the tablet's own actions do), which left _action undefined and threw
// building the menu below. Default to the general menu when nothing set it.
_action = uinamespace getVariable ["NEO_radioCurrentAction", "radio"];

// #698 fresh dialog: no unit is selected yet, so map-click target placement is unarmed.
uinamespace setVariable ["NEO_radioMapClickArmed", false];

// #698 terrain mode: the config map is the satellite variant, so only schematic mode needs a swap
// on open. Restore the saved pan/zoom either way. (The terrain button sits clear of the map, so it
// does not depend on the map being recreated.)
private _savedView = [];
if ((uinamespace getVariable ["NEO_radioMapScale", 0]) > 0) then {
    _savedView = [uinamespace getVariable ["NEO_radioMapScale", 0.16], uinamespace getVariable ["NEO_radioMapCenter", [0,0,0]]];
};
if !(uinamespace getVariable ["NEO_radioTerrainMode", true]) then {
    [false, _savedView] call NEO_fnc_radioSetTerrainMode;
} else {
    if !(_savedView isEqualTo []) then {
        (_savedView) params ["_vs", "_vc"];
        [(findDisplay 655555) displayCtrl 655560, _vs, _vc] call NEO_fnc_mapRestoreView;
    };
};

private ["_available", "_transportArray", "_casArray", "_artyArray"];

_available = [];
_transportArray = NEO_radioLogic getVariable [format ["NEO_radioTrasportArray_%1", playerSide], []];
_casArray = NEO_radioLogic getVariable [format ["NEO_radioCasArray_%1", playerSide], []];

  	    _has_SPE_leFH18 = false;
  	    {
  	    	if(_x select 1 == "SPE_leFH18") then {
  	    		_has_SPE_leFH18 = true;
  	    	}
  	    } forEach SUP_ARTYARRAYS;
  
        _artyArray = []; 
        _artyArray append (NEO_radioLogic getVariable [format ["NEO_radioArtyArray_%1", playerSide], []]);
 
	      if (_has_SPE_leFH18) then { 
	      	if (playerSide != WEST) then {
	        _artyArray append (NEO_radioLogic getVariable [format ["NEO_radioArtyArray_%1", WEST], []]);
	        };
	      };

//Available Supports
if (count _transportArray > 0) then { _available pushback (["TRANSPORT", "\a3\Ui_f\data\GUI\Cfg\CommunicationMenu\transport_ca.paa"]) };
if (count _casArray > 0) then { _available pushback (["CAS", "\a3\Ui_f\data\GUI\Cfg\CommunicationMenu\cas_ca.paa"]) };
// Ground transport (#690), from the radio or Talk To Driver
private _groundArray = NEO_radioLogic getVariable [format ["NEO_radioGroundArray_%1", playerSide], []];
if (count _groundArray > 0 && {_action in ["radio", "talkground"]}) then { _available pushback (["GROUND", "\a3\Ui_f\data\GUI\Cfg\CommunicationMenu\supplydrop_ca.paa"]) };
// the AI Commander's guns (F509) give the radio an Artillery entry of their own; talking to one
// battery never offers them
if ((count _artyArray > 0 && (_action == "radio" || _action == "talkarty")) || {_action == "radio" && {["available"] call NEO_fnc_artyCmdrBoard}}) then { _available pushback (["ARTY", "\a3\Ui_f\data\GUI\Cfg\CommunicationMenu\artillery_ca.paa"]) };
//Support ListBox


lbClear _suppListBox;
{
    private _row = _suppListBox lbAdd format["%1", (_x select 0)];
    _suppListBox lbSetPicture [_row, (_x select 1)];
    _suppListBox lbSetData [_row, (_x select 0)];
} forEach _available;

 lbSort _suppListBox;

// The list is sorted, so a support type's row depends on which types the mission has. Rows are
// found by their token, never by a fixed number (a fourth type, or a mission without CAS, moves them).
private _fnc_rowOf = {
    params ["_token"];
    private _row = -1;
    for "_i" from 0 to (lbSize 655565) - 1 do { if (lbData [655565, _i] == _token) exitWith { _row = _i } };
    _row
};
private _fnc_keepOnly = {
    params ["_token"];
    for "_i" from (lbSize 655565) - 1 to 0 step -1 do { if (lbData [655565, _i] != _token) then { lbDelete [655565, _i] } };
};

//Display Event Handlers
_suppListBox ctrlSetEventHandler ["LBSelChanged", "_this call NEO_fnc_radioLbSelChanged"];
_abort ctrlSetEventHandler ["ButtonClick", "closeDialog 0;"];

// #630 pressing Enter in the grid field submits it, same as clicking Set (28 = Return, 156 = numpad Enter)
((findDisplay 655555) displayCtrl 655636) ctrlAddEventHandler ["KeyDown", "if ((_this select 1) in [28, 156]) exitWith { [] call NEO_fnc_radioGridSetButton; true }; false"];

switch (_action) do
{
    case "talk" :
    {
        ["TRANSPORT"] call _fnc_keepOnly;

        [] spawn
        {
            lbSetCurSel [655565, 0];
            waituntil { lbSize 655568 > 0 };
            lbSetCurSel [655568, 0];
        };
    };

    // Talk To Driver: the ground transport page, on the vehicle talked to
    case "talkground" :
    {
        ["GROUND"] call _fnc_keepOnly;

        [] spawn
        {
            lbSetCurSel [655565, 0];
            // stop waiting if the tablet is closed first
            waituntil { isNull findDisplay 655555 || {lbSize 655568 > 0} };
            if (isNull findDisplay 655555) exitWith {};
            private _vehicle = NEO_radioLogic getVariable ["NEO_radioTalkWithDriver", objNull];
            private _row = (NEO_radioLogic getVariable [format ["NEO_radioGroundArray_%1", playerSide], []]) findIf { (_x select 0) == _vehicle };
            lbSetCurSel [655568, _row max 0];
        };
    };

    case "talkarty" :
    {
        NEO_radioLogic setVariable ["NEO_radioTalkWithArty", vehicle cursorTarget];

        ["ARTY"] call _fnc_keepOnly;

        [] spawn
        {
            lbSetCurSel [655565, 0];
            waituntil { lbSize 655594 > 0 };
            lbSetCurSel [655594, 0];;
        };
    };

    case "radio" :
    {
        if (count _available > 0 && count _available < 2) then
        {
            [] spawn { lbSetCurSel [655565, 0] };
        }
        else
        {
            private ["_count", "_sup", "_index", "_obj"];
            _count = 0;
            _sup = 0;
            _index = [0, 0];
            _obj = objNull;

            {
                _obj = _x select 0;

                if ((_obj getVariable "NEO_radioTrasportUnitStatus") == "SMOKECONF") then
                {
                    _index = [["TRANSPORT"] call _fnc_rowOf, _forEachIndex];
                    _sup = _translist;
                    _count = _count + 1;
                };
            } forEach _transportArray;

            {
                _obj = _x select 0;

                if ((_obj getVariable "NEO_radioArtyUnitStatus") == "RESPONSE") then
                {
                    _index = [["ARTY"] call _fnc_rowOf, _forEachIndex];
                    _sup = _artylist;
                    _count = _count + 1;
                };
            } forEach _artyArray;

            if (_count > 0) then
            {
                [_index, _sup] spawn
                {
                    lbSetCurSel [655565, (_this select 0) select 0];
                    waituntil { lbSize (_this select 1) > 0 };
                    lbSetCurSel [(_this select 1), (_this select 0) select 1];
                };
            };
        };
    };
};

//Hide GPS
showGPS false;

// keep the panel in step with each asset's status. The support FSMs flip it
// asynchronously (on mission, RTB, smoke requested, complete) and nothing
// refreshed the UI, so Confirm stayed active after firing and the transport
// smoke prompt never appeared. Refresh only when the SELECTED asset's status
// actually changes (not when the player switches assets, which already
// refreshes), so in-progress input is left alone.
[] spawn {
    private _lastUnit = objNull;
    private _lastStatus = "";
    private _lastCmdrKey = [];
    while { !isNull (findDisplay 655555) } do {
        uiSleep 1;
        private _disp = findDisplay 655555;
        if (!isNull _disp) then {
            private _supLb = _disp displayCtrl 655565;
            private _cfg = switch (toUpper (_supLb lbText (lbCurSel _supLb))) do {
                case "ARTY":      { [655594, "NEO_radioArtyArray", "NEO_radioArtyUnitStatus"] };
                case "CAS":       { [655582, "NEO_radioCasArray", "NEO_radioCasUnitStatus"] };
                case "TRANSPORT": { [655568, "NEO_radioTrasportArray", "NEO_radioTrasportUnitStatus"] };
                case "GROUND":    { [655568, "NEO_radioGroundArray", "NEO_radioGroundUnitStatus"] };
                default           { [] };
            };
            private _curUnit = objNull;
            private _curStatus = "";
            if !(_cfg isEqualTo []) then {
                _cfg params ["_ulbIdc", "_arrPrefix", "_statVar"];
                private _sel = lbCurSel (_disp displayCtrl _ulbIdc);
                // the Commander's guns row has no battery object: refresh Confirm when the board
                // changes or the 15 s wait after a request ends
                if (_ulbIdc == 655594 && {_sel >= 0} && {((_disp displayCtrl _ulbIdc) lbData _sel) == "CMDR"}) then {
                    private _key = [["board"] call NEO_fnc_artyCmdrBoard, floor ((time - (missionNamespace getVariable ["NEO_artyCmdrSentAt", -100])) / 15)];
                    if !(_key isEqualTo _lastCmdrKey) then { _lastCmdrKey = _key; [] call NEO_fnc_artyConfirmButtonEnable };
                };
                if (_sel >= 0) then {
                    private _arr = NEO_radioLogic getVariable [format ["%1_%2", _arrPrefix, playerSide], []];
                    if (_sel < count _arr) then {
                        _curUnit = _arr select _sel select 0;
                        _curStatus = _curUnit getVariable [_statVar, ""];
                    };
                };
            };
            if (!isNull _curUnit) then {
                if (_curUnit isEqualTo _lastUnit) then {
                    if (_curStatus != _lastStatus) then {
                        _lastStatus = _curStatus;
                        [lbCurSel _supLb] call NEO_fnc_radioRefreshUi;
                    };
                } else {
                    _lastUnit = _curUnit;
                    _lastStatus = _curStatus;
                };
            };
        };
    };
};
