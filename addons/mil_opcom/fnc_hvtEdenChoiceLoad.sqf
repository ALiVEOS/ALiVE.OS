#include "\x\alive\addons\mil_opcom\script_component.hpp"
SCRIPT(hvtEdenChoiceLoad);

/* ----------------------------------------------------------------------------
Function: fnc_hvtEdenChoiceLoad

Description:
Eden attributeLoad for the AI Commander's High Value Target Class and High Value Target Guards
pickers, on ALiVE's filtered multi-select (ALiVE_FilteredMultiSelect_Base): a list of every soldier class of one
side, loaded mods and CDLC included, starting on the side of the commander's first faction.

- The first button (idc 1210) cycles BLUFOR, OPFOR and Independent; the second (1211) shows This
  side or All sides.
- The list is multi-select, like ALiVE's other pickers: the ticked rows are saved, and the ticks
  are kept while the buttons change what's shown. CLASS: one officer is picked at random from
  them. GUARDS: the list also has the side's infantry groups; tick soldiers, or one group.
- The typed field (idc 102) starts empty. Classes typed there, separated by commas, are added to
  the ticked ones when saved, for a class the list doesn't show. A stored class this game doesn't
  have is listed and ticked, so it isn't lost.

Parameters:
    [_display, "CLASS" or "GUARDS", stored value, title]

Author:
Jman
---------------------------------------------------------------------------- */

params [["_display", controlNull], ["_mode", "CLASS"], ["_value", ""], ["_title", ""], ["_tipKey", ""]];
if (isNull _display) exitWith {};
private _list = _display controlsGroupCtrl 100;
if (isNull _list) exitWith {};
if (_title != "") then {
    (_display controlsGroupCtrl 101) ctrlSetText (if ((_title select [0, 1]) == "$") then { localize (_title select [1]) } else { _title });
};

// the commander's side, from the first faction ticked on the module being edited
private _side = 1;
private _ent = (get3DENSelected "logic") param [0, objNull];
if (!isNull _ent) then {
    private _raw = (_ent get3DENAttribute "ALiVE_mil_opcom_factions") param [0, ""];
    private _facs = if (_raw isEqualType [] ) then { _raw } else {
        if ((_raw select [0, 1]) == "[") then { parseSimpleArray _raw } else { _raw splitString ", " }
    };
    private _f = _facs param [0, ""];
    if (_f isEqualType "" && {isClass (configFile >> "CfgFactionClasses" >> _f)}) then {
        _side = [0, 1, 2] param [getNumber (configFile >> "CfgFactionClasses" >> _f >> "side"), 1];
    };
};

// The rows: [sort key, label, class, side (0 east, 1 west, 2 independent)]
private _rows = [];
{
    private _cls = configName _x;
    private _s = getNumber (_x >> "side");
    if (_s in [0, 1, 2] && {_cls isKindOf "CAManBase"}) then {
        private _fac = getText (_x >> "faction");
        private _fname = getText (configFile >> "CfgFactionClasses" >> _fac >> "displayName");
        if (_fname == "") then { _fname = _fac };
        private _name = getText (_x >> "displayName");
        _rows pushBack [toLower (_fname + _name), format ["%1: %2  (%3)", _fname, _name, _cls], _cls, _s];
    };
} forEach ("getNumber (_x >> 'scope') == 2 && {getNumber (_x >> 'isMan') == 1 || {getText (_x >> 'simulation') == 'soldier'}}" configClasses (configFile >> "CfgVehicles"));
if (_mode == "GUARDS") then {
    {
        private _s = ["east", "west", "indep"] find toLower configName _x;
        if (_s >= 0) then {
            {
                private _fac = configName _x;
                private _fname = getText (configFile >> "CfgFactionClasses" >> _fac >> "displayName");
                if (_fname == "") then { _fname = _fac };
                {
                    {
                        private _units = "isClass _x" configClasses _x;
                        if (_units isNotEqualTo [] && {(_units findIf { !((getText (_x >> "vehicle")) isKindOf "CAManBase") }) < 0}) then {
                            private _gname = getText (_x >> "name");
                            if (_gname == "") then { _gname = configName _x };
                            _rows pushBack [" " + toLower (_fname + _gname), format [localize "STR_ALIVE_OPCOM_HVT_PICK_GROUP", _fname, _gname, count _units], configName _x, _s];
                        };
                    } forEach ("true" configClasses _x);
                } forEach ("true" configClasses _x);
            } forEach ("true" configClasses _x);
        };
    } forEach ("true" configClasses (configFile >> "CfgGroups"));
};
_rows sort true;

_display setVariable ["alive_hvtMode", _mode];
_display setVariable ["alive_hvtRows", _rows];
_display setVariable ["alive_hvtSide", _side];
_display setVariable ["alive_hvtAll", false];
_display setVariable ["alive_selectedClasses", (if (_value isEqualType "") then { _value } else { "" }) splitString ", "];

private _populate = {
    params ["_display"];
    private _list = _display controlsGroupCtrl 100;
    private _side = _display getVariable ["alive_hvtSide", 1];
    private _all = _display getVariable ["alive_hvtAll", false];
    private _rows = _display getVariable ["alive_hvtRows", []];
    private _sel = _display getVariable ["alive_selectedClasses", []];
    _display setVariable ["alive_populating", true];
    lbClear _list;
    // a stored class this game doesn't have stays listed and ticked
    {
        private _c = _x;
        if ((_rows findIf { (_x select 2) == _c }) < 0 && {toLower _c != "none"}) then {
            private _i = _list lbAdd format [localize "STR_ALIVE_FOB_PICK_UNKNOWN", _c];
            _list lbSetData [_i, _c];
            _list lbSetSelected [_i, true];
        };
    } forEach _sel;
    {
        _x params ["", "_label", "_data", "_s"];
        // Find (#1083)
        private _q = _display getVariable ["alive_searchText", ""];
        if ((_all || {_s == _side}) && {_q isEqualTo "" || {((toLower (_label + " " + _data)) find _q) >= 0}}) then {
            private _i = _list lbAdd _label;
            _list lbSetData [_i, _data];
            if (_data in _sel) then { _list lbSetSelected [_i, true] };
        };
    } forEach _rows;
    (_display controlsGroupCtrl 1200) ctrlSetText format ["%1: %2", localize "STR_ALIVE_OPCOM_HVT_PICK_SIDE",
        localize (["STR_ALIVE_OPCOM_HVT_PICK_OPFOR", "STR_ALIVE_OPCOM_HVT_PICK_BLUFOR", "STR_ALIVE_OPCOM_HVT_PICK_INDEP"] select _side)];
    (_display controlsGroupCtrl 1201) ctrlSetText format ["%1: %2", localize "STR_ALIVE_OPCOM_HVT_PICK_SHOW",
        localize (["STR_ALIVE_OPCOM_HVT_PICK_THISSIDE", "STR_ALIVE_OPCOM_HVT_PICK_ALLSIDES"] select _all)];
    _display setVariable ["alive_populating", false];
};
_display setVariable ["alive_populateFn", _populate];
_display setVariable ["alive_searchable", true];
[_display] call _populate;

_list setVariable ["alive_disp", _display];
_list ctrlAddEventHandler ["LBSelChanged", {
    params ["_ctrl", "_i"];
    private _disp = _ctrl getVariable "alive_disp";
    if (isNull _disp || {_disp getVariable ["alive_populating", false]}) exitWith {};
    // keep the ticks of rows not shown, and take the shown rows' ticks from the list
    private _sel = _disp getVariable ["alive_selectedClasses", []];
    private _ticked = (lbSelection _ctrl) apply { _ctrl lbData _x };
    for "_r" from 0 to (lbSize _ctrl - 1) do {
        private _d = _ctrl lbData _r;
        if (_d in _ticked) then { _sel pushBackUnique _d } else { _sel = _sel - [_d] };
    };
    _disp setVariable ["alive_selectedClasses", _sel];
}];

// the typed field starts empty; what's typed is added to the ticks when saved
private _edit = _display controlsGroupCtrl 102;
if (!isNull _edit) then {
    _edit ctrlSetText "";
    private _label = _display controlsGroupCtrl 103;
    _label ctrlSetText localize "STR_ALIVE_OPCOM_HVT_PICK_TYPED";
    // the caller's own tooltip when it gives one (the Recruiter Class picker shares this one)
    private _tip = localize ([(["STR_ALIVE_OPCOM_HVT_CLASS_COMMENT", "STR_ALIVE_OPCOM_HVT_GUARDS_COMMENT"] select (_mode == "GUARDS")), _tipKey] select (_tipKey != ""));
    _label ctrlSetTooltip _tip;
    _edit ctrlSetTooltip _tip;
};
{
    _x params ["_idc", "_code"];
    private _btn = _display controlsGroupCtrl _idc;
    if (!isNull _btn) then {
        _btn setVariable ["alive_disp", _display];
        _btn ctrlAddEventHandler ["ButtonClick", _code];
    };
} forEach [
    [1210, { private _d = (_this select 0) getVariable "alive_disp"; _d setVariable ["alive_hvtSide", [1, 2, 0] select (_d getVariable ["alive_hvtSide", 1])]; [_d] call (_d getVariable "alive_populateFn") }],
    [1211, { private _d = (_this select 0) getVariable "alive_disp"; _d setVariable ["alive_hvtAll", !(_d getVariable ["alive_hvtAll", false])]; [_d] call (_d getVariable "alive_populateFn") }]
];

// a plain click ticks or unticks just that row, and ticked rows read [+] (#1083)
[_display controlsGroupCtrl 100] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenListToggle.sqf';
