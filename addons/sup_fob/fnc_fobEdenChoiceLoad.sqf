#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(fobEdenChoiceLoad);

/* ----------------------------------------------------------------------------
Function: fnc_fobEdenChoiceLoad

Description:
Eden attributeLoad for the Player FOBs pickers ALiVE_FOBHubChoice (Headquarters Buildings) and
ALiVE_FOBGroupChoice (Garrison Groups), on the ALiVE_FactionSlotChoice control: a single-select
list with two cycle buttons.

- The slot button (idc 1210) cycles BLUFOR, OPFOR and Independent: each side has its own pick.
- The second button (idc 1211) filters the list. Buildings: Military (military structures) or
  All (every building). Groups: Auto (the slot's own side) or All (every side).

A building row's data is its class; a group row's is "faction/group" (the garrison is made from
that faction's group), and the first row, "", is a random infantry group of the FOB's faction.
A stored pick the list doesn't hold (a mod not loaded) is kept and shown as unrecognised. The
typed field below the list (idc 102) starts empty, as on ALiVE's other pickers: what's typed
there becomes the current side's pick, for a class the list doesn't show.

Buildings tick (Lenahan, 20 Oct): a click ticks or unticks a building, and each side can have
several, stored comma-separated; players choose one when they deploy a FOB. Groups stay single.

Storage: one string, the three picks in BLUFOR|OPFOR|Independent order.

Parameters:
    [_display, "HUB" or "GROUP", _value, title or $STR_ key]

Author:
Jman
---------------------------------------------------------------------------- */

#define CHECK_ON "\a3\3DEN\Data\Controls\ctrlCheckbox\textureChecked_ca.paa"
#define CHECK_OFF "\a3\3DEN\Data\Controls\ctrlCheckbox\textureUnchecked_ca.paa"

params [["_display", controlNull], ["_mode", "HUB"], ["_value", ""], ["_title", ""]];
if (isNull _display) exitWith {};
private _list = _display controlsGroupCtrl 100;
if (isNull _list) exitWith {};
if (_title != "") then {
    (_display controlsGroupCtrl 101) ctrlSetText (if ((_title select [0, 1]) == "$") then { localize (_title select [1]) } else { _title });
};

// The stored value, blank picks kept in place
private _raw = if (_value isEqualType "") then { _value } else { "" };
private _picks = [];
private _at = _raw find "|";
while {_at >= 0} do { _picks pushBack (_raw select [0, _at]); _raw = _raw select [_at + 1]; _at = _raw find "|" };
_picks pushBack _raw;
_picks resize 3;
_picks = _picks apply { if (isNil "_x") then { "" } else { _x } };
if (_mode == "HUB") then {
    { if ((_picks select _forEachIndex) == "") then { _picks set [_forEachIndex, _x] } } forEach ["Land_Cargo_HQ_V1_F", "Land_Cargo_HQ_V3_F", "Land_Cargo_HQ_V2_F"];
};

// The rows: [sort key, label, data, side or -1 for any, military]
private _rows = [];
if (_mode == "HUB") then {
    {
        private _cfg = _x;
        private _cat = toLower getText (_cfg >> "editorCategory");
        private _class = configName _cfg;
        if (_class isKindOf "House" && {"structures" in _cat} && {!("ruins" in _cat)} && {!("ruin" in toLower _class)}) then {
            private _name = getText (_cfg >> "displayName");
            if (_name == "") then { _name = _class };
            private _mil = getText (_cfg >> "editorSubcategory") == "EdSubcat_Military";
            _rows pushBack [toLower _name, format ["%1  (%2)", _name, _class], _class, -1, _mil];
        };
    } forEach ("getNumber (_x >> 'scope') == 2" configClasses (configFile >> "CfgVehicles"));
} else {
    _rows pushBack [" ", localize "STR_ALIVE_FOB_GARRISON_RANDOM", "", -1, true];
    {
        private _sideCfg = _x;
        private _side = ["east", "west", "indep"] find toLower configName _sideCfg;
        if (_side >= 0) then {
            {
                private _faction = configName _x;
                private _fname = getText (configFile >> "CfgFactionClasses" >> _faction >> "displayName");
                if (_fname == "") then { _fname = _faction };
                // every category, not only the game's own "Infantry": mods file their foot groups
                // under their own names (RHS, CUP...). A group counts when every unit is a soldier.
                {
                    {
                        private _units = "isClass _x" configClasses _x;
                        if (_units isNotEqualTo [] && {(_units findIf { !((getText (_x >> "vehicle")) isKindOf "CAManBase") }) < 0}) then {
                            private _gname = getText (_x >> "name");
                            if (_gname == "") then { _gname = configName _x };
                            _rows pushBack [toLower (_fname + _gname), format ["%1: %2", _fname, _gname], _faction + "/" + configName _x, _side, true];
                        };
                    } forEach ("true" configClasses _x);
                } forEach ("true" configClasses _x);
            } forEach ("true" configClasses _sideCfg);
        };
    } forEach ("true" configClasses (configFile >> "CfgGroups"));
};
_rows sort true;

_display setVariable ["alive_fobMode", _mode];
_display setVariable ["alive_fobRows", _rows];
_display setVariable ["alive_fobPicks", _picks];
_display setVariable ["alive_currentSlot", 0];
_display setVariable ["alive_fobAll", false];

private _populate = {
    params ["_display"];
    private _list = _display controlsGroupCtrl 100;
    private _mode = _display getVariable ["alive_fobMode", "HUB"];
    private _slot = _display getVariable ["alive_currentSlot", 0];
    private _all = _display getVariable ["alive_fobAll", false];
    private _pick = (_display getVariable ["alive_fobPicks", ["", "", ""]]) select _slot;
    private _ticked = (_pick splitString ", ;") apply { toLower _x };
    private _side = [1, 0, 2] select _slot;   // the slot's side, in CfgGroups' order (0 east, 1 west, 2 indep)
    _display setVariable ["alive_populating", true];
    lbClear _list;
    private _sel = -1;
    {
        _x params ["", "_label", "_data", "_rowSide", "_mil"];
        if (_all || {if (_mode == "HUB") then { _mil } else { _rowSide < 0 || {_rowSide == _side} }}) then {
            private _i = _list lbAdd _label;
            _list lbSetData [_i, _data];
            if (_mode == "HUB") then {
                _list lbSetPicture [_i, [CHECK_OFF, CHECK_ON] select (toLower _data in _ticked)];
            } else {
                if (_data == _pick) then { _sel = _i };
            };
        };
    } forEach (_display getVariable ["alive_fobRows", []]);
    if (_mode == "HUB") then {
        // ticked classes not in the list: one the Show filter hides keeps its own name, one the game
        // doesn't have (a mod not loaded, or typed) is kept and shown as unrecognised
        private _shown = [];
        for "_i" from 0 to (lbSize _list - 1) do { _shown pushBack toLower (_list lbData _i) };
        {
            if !(toLower _x in _shown) then {
                private _c = _x;
                private _row = (_display getVariable ["alive_fobRows", []]) select { toLower (_x select 2) == toLower _c };
                private _i = _list lbAdd (if (_row isEqualTo []) then { format [localize "STR_ALIVE_FOB_PICK_UNKNOWN", _c] } else { _row select 0 select 1 });
                _list lbSetData [_i, _c]; _list lbSetPicture [_i, CHECK_ON];
            };
        } forEach (_pick splitString ", ;");
        _list lbSetCurSel -1;
    } else {
        if (_sel < 0 && {_pick != ""}) then {
            _sel = _list lbAdd format [localize "STR_ALIVE_FOB_PICK_UNKNOWN", _pick];
            _list lbSetData [_sel, _pick];
        };
        if (_sel >= 0) then { _list lbSetCurSel _sel };
    };
    (_display controlsGroupCtrl 102) ctrlSetText "";
    (_display controlsGroupCtrl 1200) ctrlSetText format ["%1: %2", localize "STR_ALIVE_FOB_PICK_SIDE",
        localize (["STR_ALIVE_FOB_PICK_BLUFOR", "STR_ALIVE_FOB_PICK_OPFOR", "STR_ALIVE_FOB_PICK_INDEP"] select _slot)];
    (_display controlsGroupCtrl 1201) ctrlSetText format ["%1: %2", localize "STR_ALIVE_FOB_PICK_SHOW",
        localize ([["STR_ALIVE_FOB_PICK_MILITARY", "STR_ALIVE_FOB_PICK_ALL"], ["STR_ALIVE_FOB_PICK_THISSIDE", "STR_ALIVE_FOB_PICK_ALLSIDES"]] select (_mode != "HUB") select _all)];
    _display setVariable ["alive_populating", false];
};
_display setVariable ["alive_populateFn", _populate];
[_display] call _populate;

_list setVariable ["alive_disp", _display];
_list ctrlAddEventHandler ["LBSelChanged", {
    params ["_ctrl", "_i"];
    private _disp = _ctrl getVariable "alive_disp";
    if (isNull _disp || {_disp getVariable ["alive_populating", false]} || {_i < 0}) exitWith {};
    private _slot = _disp getVariable ["alive_currentSlot", 0];
    if ((_disp getVariable ["alive_fobMode", "HUB"]) == "HUB") then {
        // tick or untick the building, then clear the selection so the same row can be clicked again
        private _picks = ((_disp getVariable "alive_fobPicks") select _slot) splitString ", ;";
        private _data = _ctrl lbData _i;
        private _at = _picks findIf { _x == _data };
        if (_at >= 0) then { _picks deleteAt _at } else { _picks pushBack _data };
        _ctrl lbSetPicture [_i, [CHECK_OFF, CHECK_ON] select (_at < 0)];
        (_disp getVariable "alive_fobPicks") set [_slot, _picks joinString ", "];
        _disp setVariable ["alive_populating", true];
        _ctrl lbSetCurSel -1;
        _disp setVariable ["alive_populating", false];
    } else {
        (_disp getVariable "alive_fobPicks") set [_slot, _ctrl lbData _i];
    };
}];

// The typed field: what's typed is the current side's pick (empty leaves the list's)
private _edit = _display controlsGroupCtrl 102;
if (!isNull _edit) then {
    private _label = _display controlsGroupCtrl 103;
    _label ctrlSetText localize "STR_ALIVE_FOB_PICK_TYPED";
    _label ctrlSetTooltip localize (["STR_ALIVE_FOB_PICK_TYPED_HUB", "STR_ALIVE_FOB_PICK_TYPED_GROUP"] select (_mode != "HUB"));
    _edit ctrlSetTooltip localize (["STR_ALIVE_FOB_PICK_TYPED_HUB", "STR_ALIVE_FOB_PICK_TYPED_GROUP"] select (_mode != "HUB"));
    _edit setVariable ["alive_disp", _display];
    if (_mode == "HUB") then {
        // buildings: what's typed is ADDED to the side's ticked ones (Jman 20 Oct), one class or several
        // separated by commas, when the field is left; until then it's held for the save, so typing a
        // class and pressing OK straight away still keeps it
        _edit ctrlAddEventHandler ["KeyUp", {
            private _e = _this select 0;
            private _d = _e getVariable "alive_disp";
            if (isNull _d) exitWith {};
            _d setVariable ["alive_fobTyped", (ctrlText _e) trim [" ", 0]];
        }];
        _edit ctrlAddEventHandler ["KillFocus", {
            private _e = _this select 0;
            private _d = _e getVariable "alive_disp";
            if (isNull _d) exitWith {};
            private _slot = _d getVariable ["alive_currentSlot", 0];
            private _picks = ((_d getVariable "alive_fobPicks") select _slot) splitString ", ;";
            private _low = _picks apply { toLower _x };
            { if !(toLower _x in _low) then { _picks pushBack _x; _low pushBack toLower _x } } forEach ((ctrlText _e) splitString ", ;");
            (_d getVariable "alive_fobPicks") set [_slot, _picks joinString ", "];
            _d setVariable ["alive_fobTyped", ""];
            [_d] call (_d getVariable "alive_populateFn");
        }];
    } else {
        {
            _edit ctrlAddEventHandler [_x, {
                private _e = _this select 0;
                private _d = _e getVariable "alive_disp";
                if (isNull _d) exitWith {};
                private _t = (ctrlText _e) trim [" ", 0];
                // an empty field leaves the list's pick alone
                if (_t != "") then { (_d getVariable "alive_fobPicks") set [_d getVariable ["alive_currentSlot", 0], _t] };
            }];
        } forEach ["KeyUp", "KillFocus"];
    };
};
{
    _x params ["_idc", "_code"];
    private _btn = _display controlsGroupCtrl _idc;
    if (!isNull _btn) then {
        _btn setVariable ["alive_disp", _display];
        _btn ctrlAddEventHandler ["ButtonClick", _code];
    };
} forEach [
    [1210, { private _d = (_this select 0) getVariable "alive_disp"; _d setVariable ["alive_currentSlot", ((_d getVariable ["alive_currentSlot", 0]) + 1) mod 3]; [_d] call (_d getVariable "alive_populateFn") }],
    [1211, { private _d = (_this select 0) getVariable "alive_disp"; _d setVariable ["alive_fobAll", !(_d getVariable ["alive_fobAll", false])]; [_d] call (_d getVariable "alive_populateFn") }]
];
