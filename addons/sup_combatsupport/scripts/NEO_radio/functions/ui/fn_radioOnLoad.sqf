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

// restore the player's last map pan + zoom (saved on close in fn_radioOnUnload)
// so re-opening the tablet returns to the same view, not the default centre.
// Do it on the map's first Draw (unscheduled, lands within a frame) instead of a
// timed spawn that visibly panned across about a second later.
if ((uinamespace getVariable ["NEO_radioMapScale", 0]) > 0) then {
    private _rMap = (findDisplay 655555) displayCtrl 655560;
    if (!isNull _rMap) then {
        _rMap setVariable ["NEO_mapRestored", false];
        _rMap ctrlAddEventHandler ["Draw", {
            params ["_ctrl"];
            if !(_ctrl getVariable ["NEO_mapRestored", false]) then {
                _ctrl setVariable ["NEO_mapRestored", true];
                ctrlMapAnimClear _ctrl;
                _ctrl ctrlMapAnimAdd [0, uinamespace getVariable ["NEO_radioMapScale", 0.16], uinamespace getVariable ["NEO_radioMapCenter", [0,0,0]]];
                ctrlMapAnimCommit _ctrl;
            };
        }];
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
if (count _artyArray > 0 && (_action == "radio" || _action == "talkarty")) then { _available pushback (["ARTY", "\a3\Ui_f\data\GUI\Cfg\CommunicationMenu\artillery_ca.paa"]) };
//Support ListBox


lbClear _suppListBox;
{
    _suppListBox lbAdd format["%1", (_x select 0)];
    _suppListBox lbSetPicture [_forEachIndex, (_x select 1)];
} forEach _available;

 lbSort _suppListBox;

//Display Event Handlers
_suppListBox ctrlSetEventHandler ["LBSelChanged", "_this call NEO_fnc_radioLbSelChanged"];
_abort ctrlSetEventHandler ["ButtonClick", "closeDialog 0;"];

switch (_action) do
{
    case "talk" :
    {
        if (count _casArray > 0) then {
            lbDelete [655565, 0];
        };
        if (count _artyArray > 0) then {
            lbDelete [655565, 2];
        };

        [] spawn
        {
            lbSetCurSel [655565, 1];
            waituntil { lbSize 655568 > 0 };
            lbSetCurSel [655568, 0];
        };
    };

    case "talkarty" :
    {
        NEO_radioLogic setVariable ["NEO_radioTalkWithArty", vehicle cursorTarget];

        if (count _casArray > 0) then {
            lbDelete [655565, 0];
        };
        if (count _transportArray > 0) then {
            lbDelete [655565, 1];
        };

        [] spawn
        {
            lbSetCurSel [655565, 2];
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
                    _index = [0, _forEachIndex];
                    _sup = _translist;
                    _count = _count + 1;
                };
            } forEach _transportArray;

            {
                _obj = _x select 0;

                if ((_obj getVariable "NEO_radioArtyUnitStatus") == "RESPONSE") then
                {
                    _index = [2, _forEachIndex];
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
    while { !isNull (findDisplay 655555) } do {
        uiSleep 1;
        private _disp = findDisplay 655555;
        if (!isNull _disp) then {
            private _supLb = _disp displayCtrl 655565;
            private _cfg = switch (toUpper (_supLb lbText (lbCurSel _supLb))) do {
                case "ARTY":      { [655594, "NEO_radioArtyArray", "NEO_radioArtyUnitStatus"] };
                case "CAS":       { [655582, "NEO_radioCasArray", "NEO_radioCasUnitStatus"] };
                case "TRANSPORT": { [655568, "NEO_radioTrasportArray", "NEO_radioTrasportUnitStatus"] };
                default           { [] };
            };
            private _curUnit = objNull;
            private _curStatus = "";
            if !(_cfg isEqualTo []) then {
                _cfg params ["_ulbIdc", "_arrPrefix", "_statVar"];
                private _sel = lbCurSel (_disp displayCtrl _ulbIdc);
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
