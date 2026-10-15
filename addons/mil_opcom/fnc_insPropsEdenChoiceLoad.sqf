#include "\x\alive\addons\mil_opcom\script_component.hpp"
SCRIPT(insPropsEdenChoiceLoad);

/* ----------------------------------------------------------------------------
Function: fnc_insPropsEdenChoiceLoad

Description:
Eden attributeLoad for the AI Commander's Factory, Depot, HQ and Lab Interiors pickers: ALiVE's interior
sets for that kind of installation (small furniture compositions in CfgGroups >> Empty >>
ALiVE_Interiors, the mission's own included), one era at a time.

- The first button (idc 1210) steps through the eras (Modern, Vietnam, WW2, Cold War); the second
  (1211) shows This era or All eras. A set whose classes aren't all loaded isn't listed.
- The list is multi-select, like ALiVE's other pickers: the ticked sets are saved, and the ticks
  are kept while the buttons change the era shown. The typed field (idc 102) starts empty: set
  class names typed there, separated by commas, are added to the ticked ones when saved. A stored
  set this game doesn't have is listed and ticked, so it isn't lost.

Parameters:
    [_display, stored value, title, "Factory", "Depot", "HQ" or "Lab"]

Author:
Jman
---------------------------------------------------------------------------- */

params [["_display", controlNull], ["_value", ""], ["_title", ""], ["_kind", "Factory"]];
if (isNull _display) exitWith {};
private _list = _display controlsGroupCtrl 100;
if (isNull _list) exitWith {};
if (_title != "") then {
    (_display controlsGroupCtrl 101) ctrlSetText (if ((_title select [0, 1]) == "$") then { localize (_title select [1]) } else { _title });
};

// The rows: [sort key, label, set class, era]. The interior sets for this kind of installation
// (ALiVE_Interiors >> Factory, Depot or HQ; a mission's own, first, may also sit under CfgGroups >> Empty); a set
// whose classes aren't all loaded is left out.
// a set marked era "ANY" (the drug lab sets) is listed under every era
private _eraNames = createHashMapFromArray [["MODERN", "Modern"], ["VIETNAM", "Vietnam"], ["WW2", "WW2"], ["COLDWAR", "Cold War"], ["ANY", "Any era"]];
private _rows = [];
private _groups = [];
{
    private _root = _x >> _kind;
    {
        private _cls = configName _x;
        private _loaded = (("true" configClasses _x) findIf { !isClass (configFile >> "CfgVehicles" >> getText (_x >> "vehicle")) }) < 0;
        if (_loaded && {(_rows findIf { (_x select 2) == _cls }) < 0}) then {
            private _era = _eraNames getOrDefault [toUpper getText (_x >> "era"), getText (_x >> "era")];
            private _name = getText (_x >> "name");
            if (_name == "") then { _name = _cls };
            _rows pushBack [toLower (_era + _name), format ["%1  (%2, %3 objects)", _name, _era, count ("true" configClasses _x)], _cls, _era];
            _groups pushBackUnique _era;
        };
    } forEach ("isClass _x" configClasses _root);
} forEach [missionConfigFile >> "ALiVE_Interiors", missionConfigFile >> "CfgGroups" >> "Empty" >> "ALiVE_Interiors", configFile >> "ALiVE_Interiors"];
_rows sort true;
_groups = ["Modern", "Vietnam", "WW2", "Cold War"] select { _x in _groups };
if (_groups isEqualTo []) then { _groups = ["Any era"] };

_display setVariable ["alive_propRows", _rows];
_display setVariable ["alive_propGroups", _groups];
private _start = _groups find "Modern";
_display setVariable ["alive_propGroup", [_start, 0] select (_start < 0)];
_display setVariable ["alive_propAll", false];
_display setVariable ["alive_selectedClasses", (if (_value isEqualType "") then { _value } else { "" }) splitString ", "];

private _populate = {
    params ["_display"];
    private _list = _display controlsGroupCtrl 100;
    private _groups = _display getVariable ["alive_propGroups", []];
    private _g = _groups param [_display getVariable ["alive_propGroup", 0], ""];
    private _all = _display getVariable ["alive_propAll", false];
    private _rows = _display getVariable ["alive_propRows", []];
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
        _x params ["", "_label", "_data", "_grp"];
        // Find (#1083)
        private _q = _display getVariable ["alive_searchText", ""];
        if ((_all || {_grp in [_g, "Any era"]}) && {_q isEqualTo "" || {((toLower (_label + " " + _data)) find _q) >= 0}}) then {
            private _i = _list lbAdd _label;
            _list lbSetData [_i, _data];
            if (_data in _sel) then { _list lbSetSelected [_i, true] };
        };
    } forEach _rows;
    (_display controlsGroupCtrl 1200) ctrlSetText format ["%1: %2", localize "STR_ALIVE_OPCOM_INSPROPS_GROUP", _g];
    (_display controlsGroupCtrl 1201) ctrlSetText format ["%1: %2", localize "STR_ALIVE_OPCOM_HVT_PICK_SHOW",
        localize (["STR_ALIVE_OPCOM_INSPROPS_THISGROUP", "STR_ALIVE_OPCOM_INSPROPS_ALLGROUPS"] select _all)];
    _display setVariable ["alive_populating", false];
};
_display setVariable ["alive_populateFn", _populate];
// no Find row (Jman 14 Oct 2026): a few sets per era, so the filter is clutter; the populate keeps
// its text match in case a long list ever wants it back
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

private _edit = _display controlsGroupCtrl 102;
if (!isNull _edit) then {
    _edit ctrlSetText "";
    private _label = _display controlsGroupCtrl 103;
    _label ctrlSetText localize "STR_ALIVE_OPCOM_HVT_PICK_TYPED";
    _label ctrlSetTooltip localize "STR_ALIVE_OPCOM_INSPROPS_COMMENT";
    _edit ctrlSetTooltip localize "STR_ALIVE_OPCOM_INSPROPS_COMMENT";
};
{
    _x params ["_idc", "_code"];
    private _btn = _display controlsGroupCtrl _idc;
    if (!isNull _btn) then {
        _btn setVariable ["alive_disp", _display];
        _btn ctrlAddEventHandler ["ButtonClick", _code];
    };
} forEach [
    [1210, { private _d = (_this select 0) getVariable "alive_disp"; _d setVariable ["alive_propGroup", ((_d getVariable ["alive_propGroup", 0]) + 1) mod ((count (_d getVariable ["alive_propGroups", []])) max 1)]; [_d] call (_d getVariable "alive_populateFn") }],
    [1211, { private _d = (_this select 0) getVariable "alive_disp"; _d setVariable ["alive_propAll", !(_d getVariable ["alive_propAll", false])]; [_d] call (_d getVariable "alive_populateFn") }]
];

// a plain click ticks or unticks just that row, and ticked rows read [+] (#1083)
[_display controlsGroupCtrl 100] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenListToggle.sqf';
