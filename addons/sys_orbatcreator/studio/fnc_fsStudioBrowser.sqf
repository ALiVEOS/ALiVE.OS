#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsStudioBrowser);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsStudioBrowser

Description:
The class browser popup (ALiVE_FS_Browser, 14800), opened over the studio by the
Units and Vehicles tabs.

    - "open" [mode, kind]: mode "multi" adds the picked classes to the faction,
      "single" changes the selected entry's base class; kind 0 men, 1 vehicles.
      The class index is built first when it is not there yet (status
      BR_BUILDING); the list fills once it is;
    - "search": the search box, 0.15 s after the last key;
    - "faction", "kind", "side": the three combos;
    - "select": one picked row stands on the stage;
    - "add" (multi): each picked class through ALiVE_fnc_fsImportMan or
      fsImportVehicle and the model's "add"; with "Base new units on the parent
      class" ticked, base is the class's parent;
    - "keep" / "take" (single): the selected entry's base becomes the picked
      class, keeping its loadout or taking the class's own;
    - "close": closes the popup. Close and Esc redraw the tab, so its entry is
      back on the stage.
At most 500 rows are drawn; the count line says how many matched.

Parameters:
    _op   - STRING - as above
    _args - ARRAY - the event arguments

Returns:
    Nothing

Examples:
    (begin example)
    ["open", ["multi", 0]] call ALiVE_fnc_fsStudioBrowser;
    (end)

See Also:
    ALiVE_fnc_fsIndexBuild, ALiVE_fnc_fsIndexFilter, ALiVE_fnc_fsStudioTabUnits

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\data\ui\studio\idc.hpp"

disableSerialization;

params [["_op", "", [""]], ["_args", []]];

private _session = missionNamespace getVariable "ALiVE_FS_session";
if (isNil "_session") exitWith {};
private _studio = _session getOrDefault ["display", displayNull];
private _popup = findDisplay FS_IDD_BROWSER;

private _ctrl = { _popup displayCtrl _this };

// the list from the index and the three combos
private _fill = {
    private _search = toLower (ctrlText (FS_IDC_BR_SEARCH call _ctrl));
    private _cf = FS_IDC_BR_FACTION call _ctrl;
    private _faction = if (lbCurSel _cf < 0) then { "" } else { _cf lbData (lbCurSel _cf) };
    private _ck = FS_IDC_BR_KIND call _ctrl;
    private _kind = if (lbCurSel _ck < 0) then { -1 } else { _ck lbValue (lbCurSel _ck) };
    private _cs = FS_IDC_BR_SIDE call _ctrl;
    private _side = if (lbCurSel _cs < 0) then { -1 } else { _cs lbValue (lbCurSel _cs) };
    ([_search, _faction, _kind, _side, 500] call ALiVE_fnc_fsIndexFilter) params ["_rows", "_total"];
    private _list = FS_IDC_BR_LIST call _ctrl;
    lbClear _list;
    {
        _x params ["_class", "", "_name"];
        private _i = _list lbAdd _name;
        _list lbSetData [_i, _class];
        // a long class name is cut with "..." (the tooltip has it whole), and a space keeps it off the edge
        _list lbSetTextRight [_i, ([_class, (_class select [0, 30]) + "..."] select (count _class > 32)) + " "];
        _list lbSetTooltip [_i, _class];
    } forEach _rows;
    (FS_IDC_BR_COUNT call _ctrl) ctrlSetText format [localize (["STR_ALIVE_FS_BR_COUNT", "STR_ALIVE_FS_BR_MORE"] select (count _rows < _total)), count _rows, _total];
};

// the faction combo: every faction with its count for the kind and side chosen
private _factions = {
    private _index = uiNamespace getVariable ["ALiVE_FS_index", createHashMap];
    private _ck = FS_IDC_BR_KIND call _ctrl;
    private _kind = if (lbCurSel _ck < 0) then { -1 } else { _ck lbValue (lbCurSel _ck) };
    private _cs = FS_IDC_BR_SIDE call _ctrl;
    private _side = if (lbCurSel _cs < 0) then { -1 } else { _cs lbValue (lbCurSel _cs) };
    private _cf = FS_IDC_BR_FACTION call _ctrl;
    private _was = if (lbCurSel _cf < 0) then { "" } else { _cf lbData (lbCurSel _cf) };
    private _rows = _index getOrDefault ["rows", []];
    private _counts = createHashMap;
    {
        if ((_kind < 0 || {(_x select 5) == _kind}) && {_side < 0 || {(_x select 4) == _side}}) then {
            private _f = _x select 3;
            _counts set [_f, (_counts getOrDefault [_f, 0]) + 1];
        };
    } forEach _rows;
    lbClear _cf;
    private _all = _cf lbAdd (localize "STR_ALIVE_FS_BR_ALL_FACTIONS");
    _cf lbSetData [_all, ""];
    private _pick = 0;
    {
        _x params ["_class", "_name"];
        private _n = _counts getOrDefault [toLower _class, 0];
        if (_n > 0) then {
            private _i = _cf lbAdd format ["%1 (%2)", _name, _n];
            _cf lbSetData [_i, toLower _class];
            if ((toLower _class) == _was) then { _pick = _i };
        };
    } forEach (_index getOrDefault ["factions", []]);
    _cf lbSetCurSel _pick;
};

switch (_op) do {
    case "open": {
        _args params [["_mode", "multi", [""]], ["_kind", 0, [0]]];
        if (isNull _studio) exitWith {};
        if (!isNull _popup) then { _popup closeDisplay 2 };
        _session set ["browser", createHashMapFromArray [["mode", _mode], ["kind", _kind], ["filling", true], ["keys", 0]]];
        _popup = _studio createDisplay "ALiVE_FS_Browser";
        if (isNull _popup) exitWith {};
        private _single = _mode == "single";
        { (_x call _ctrl) ctrlShow _single } forEach [FS_IDC_BR_KEEP, FS_IDC_BR_TAKE];
        { (_x call _ctrl) ctrlShow !_single } forEach [FS_IDC_BR_ADD];
        // the parent tick box is for men only
        { (_x call _ctrl) ctrlShow (!_single && {_kind == 0}) } forEach [FS_IDC_BR_PARENT, FS_IDC_BR_PARENT_LABEL];
        private _list = FS_IDC_BR_LIST call _ctrl;
        if (_single) then { _list ctrlSetEventHandler ["LBDblClick", "['keep', _this] call ALiVE_fnc_fsStudioBrowser"] };
        // Close or Esc: the tab's entry goes back on the stage (Add and Use it close with 1 and redraw themselves)
        // where it was dragged to last time in this session: every control moves by the same offset
        private _title = FS_IDC_BR_TITLE call _ctrl;
        private _was = _session getOrDefault ["browserPos", []];
        if (count _was == 2) then {
            private _now = ctrlPosition _title;
            private _dx = (_was select 0) - (_now select 0);
            private _dy = (_was select 1) - (_now select 1);
            {
                private _p = ctrlPosition _x;
                _x ctrlSetPosition [(_p select 0) + _dx, (_p select 1) + _dy];
                _x ctrlCommit 0;
            } forEach (allControls _popup);
            ["popLayout", [_popup]] call ALiVE_fnc_fsStudioCamera;
        };
        _popup displayAddEventHandler ["Unload", {
            params ["_display", "_exit"];
            private _session = missionNamespace getVariable ["ALiVE_FS_session", createHashMap];
            _session set ["browserPos", (ctrlPosition (_display displayCtrl FS_IDC_BR_TITLE)) select [0, 2]];
            if (_exit != 2) exitWith {};
            _session set ["bodyRef", ""];
            private _tab = _session getOrDefault ["tab", ""];
            if (_tab == "units") then { ["refresh", []] call ALiVE_fnc_fsStudioTabUnits };
            if (_tab == "vehicles" && {!isNil "ALiVE_fnc_fsStudioTabVehicles"}) then { ["refresh", []] call ALiVE_fnc_fsStudioTabVehicles };
        }];

        private _ck = FS_IDC_BR_KIND call _ctrl;
        {
            _x params ["_key", "_value"];
            private _i = _ck lbAdd (localize ("STR_ALIVE_FS_" + _key));
            _ck lbSetValue [_i, _value];
        } forEach [["BR_MEN", 0], ["BR_VEHICLES", 1], ["BR_ALL", -1]];
        _ck lbSetCurSel ([_kind, 2] select (_kind < 0));
        // single mode keeps to the kind being changed
        _ck ctrlEnable !_single;
        private _cs = FS_IDC_BR_SIDE call _ctrl;
        {
            _x params ["_text", "_value"];
            private _i = _cs lbAdd _text;
            _cs lbSetValue [_i, _value];
        } forEach [[localize "STR_ALIVE_FS_BR_ALL", -1], [localize "STR_WEST", 1], [localize "STR_EAST", 0], [localize "STR_GUERRILA", 2], [localize "STR_CIVILIAN", 3]];
        _cs lbSetCurSel 0;

        // the index, built once per game session
        [_popup] spawn {
            params ["_popup"];
            disableSerialization;
            private _session = missionNamespace getVariable ["ALiVE_FS_session", createHashMap];
            if (isNil { uiNamespace getVariable "ALiVE_FS_index" }) then {
                [0, "BR_BUILDING", [count (configFile >> "CfgVehicles")]] call ALiVE_fnc_fsStudioStatus;
                if !(missionNamespace getVariable ["ALiVE_FS_indexBuilding", false]) then {
                    missionNamespace setVariable ["ALiVE_FS_indexBuilding", true];
                    [] call ALiVE_fnc_fsIndexBuild;
                };
                waitUntil { !isNil { uiNamespace getVariable "ALiVE_FS_index" } || {isNull _popup} };
                [-1] call ALiVE_fnc_fsStudioStatus;
            };
            if (isNull _popup) exitWith {};
            (_session getOrDefault ["browser", createHashMap]) set ["filling", false];
            // in one go: left to the scheduler, a large mod set took over two seconds to fill the list
            isNil { ["refill", []] call ALiVE_fnc_fsStudioBrowser };
            ctrlSetFocus (_popup displayCtrl FS_IDC_BR_SEARCH);
        };
    };
    case "refill": {
        if (isNull _popup) exitWith {};
        private _br = _session getOrDefault ["browser", createHashMap];
        _br set ["filling", true];
        call _factions;
        call _fill;
        _br set ["filling", false];
    };
    case "kind";
    case "side": {
        private _br = _session getOrDefault ["browser", createHashMap];
        if (isNull _popup || {_br getOrDefault ["filling", true]}) exitWith {};
        ["refill", []] call ALiVE_fnc_fsStudioBrowser;
    };
    case "faction": {
        private _br = _session getOrDefault ["browser", createHashMap];
        if (isNull _popup || {_br getOrDefault ["filling", true]}) exitWith {};
        call _fill;
    };
    case "search": {
        // only the last key press within 0.15 s fills the list
        private _br = _session getOrDefault ["browser", createHashMap];
        private _n = (_br getOrDefault ["keys", 0]) + 1;
        _br set ["keys", _n];
        [{
            params ["_n"];
            private _br = (missionNamespace getVariable ["ALiVE_FS_session", createHashMap]) getOrDefault ["browser", createHashMap];
            if ((_br getOrDefault ["keys", -1]) == _n && {!(_br getOrDefault ["filling", true])} && {!isNull findDisplay FS_IDD_BROWSER}) then { ["faction", []] call ALiVE_fnc_fsStudioBrowser };
        }, [_n], 0.15] call CBA_fnc_waitAndExecute;
    };
    case "select": {
        _args params [["_list", controlNull], ["_index", -1]];
        if (_index < 0 || {isNull _list}) exitWith {};
        if ((count (lbSelection _list)) != 1) exitWith {};
        ["class", _list lbData _index] call ALiVE_fnc_fsStudioPreview;
    };
    case "add": {
        if (isNull _popup) exitWith {};
        private _br = _session getOrDefault ["browser", createHashMap];
        private _kind = _br getOrDefault ["kind", 0];
        private _list = FS_IDC_BR_LIST call _ctrl;
        private _parent = (ctrlShown (FS_IDC_BR_PARENT call _ctrl)) && {cbChecked (FS_IDC_BR_PARENT call _ctrl)};
        private _faction = missionNamespace getVariable ["ALiVE_FS_faction", createHashMap];
        private _added = [];
        {
            private _class = _list lbData _x;
            private _isMan = _class isKindOf "CAManBase";
            private _entry = if (_isMan) then { [_class, _faction, []] call ALiVE_fnc_fsImportMan } else { [_class, createHashMap, _faction, []] call ALiVE_fnc_fsImportVehicle };
            if (_parent && {_isMan}) then {
                private _up = configName (inheritsFrom (configFile >> "CfgVehicles" >> _class));
                if (_up != "" && {_up isKindOf "CAManBase"}) then { _entry set ["base", _up] };
            };
            private _id = if (_isMan) then { ["add", [_entry], _faction] call ALiVE_fnc_fsDataUnit } else { ["add", [_entry], _faction] call ALiVE_fnc_fsDataVehicle };
            if !(_id isEqualTo "") then { _added pushBack [_id, _isMan] };
        } forEach (lbSelection _list);
        if (_added isEqualTo []) exitWith {};
        // the last one added is the one shown when the popup closes
        (_added select -1) params ["_last", "_lastMan"];
        _session set [["selVehicle", "selUnit"] select _lastMan, _last];
        ["browser add", false] call ALiVE_fnc_fsDataTouch;
        _popup closeDisplay 1;
        private _tab = _session getOrDefault ["tab", ""];
        if (_tab == "units") then { ["refresh", []] call ALiVE_fnc_fsStudioTabUnits };
        if (_tab == "vehicles" && {!isNil "ALiVE_fnc_fsStudioTabVehicles"}) then { ["refresh", []] call ALiVE_fnc_fsStudioTabVehicles };
        [0, "S_UNIT_ADDED", [count _added]] call ALiVE_fnc_fsStudioStatus;
    };
    case "keep";
    case "take": {
        if (isNull _popup) exitWith {};
        private _br = _session getOrDefault ["browser", createHashMap];
        private _isMan = (_br getOrDefault ["kind", 0]) == 0;
        private _list = FS_IDC_BR_LIST call _ctrl;
        private _sel = lbSelection _list;
        if (_sel isEqualTo []) exitWith {};
        private _class = _list lbData (_sel select 0);
        private _id = _session getOrDefault [["selVehicle", "selUnit"] select _isMan, ""];
        private _fn = [ALiVE_fnc_fsDataVehicle, ALiVE_fnc_fsDataUnit] select _isMan;
        private _entry = ((missionNamespace getVariable ["ALiVE_FS_faction", createHashMap]) getOrDefault [["vehicles", "units"] select _isMan, createHashMap]) getOrDefault [_id, createHashMap];
        if (count _entry == 0) exitWith { _popup closeDisplay 2 };
        private _why = ["set", [_id, "base", _class]] call _fn;
        if (_why isEqualTo "" && {_op == "take"} && {_isMan}) then { _why = ["set", [_id, "loadout", getUnitLoadout _class]] call _fn };
        if (_why isEqualTo "" && {!_isMan}) then {
            // a vehicle takes the new base's seats; parts and paint the new base does not have are dropped
            private _fresh = [_class, createHashMap, missionNamespace getVariable ["ALiVE_FS_faction", createHashMap], []] call ALiVE_fnc_fsImportVehicle;
            ["set", [_id, "turrets", _fresh getOrDefault ["turrets", []]]] call _fn;
            private _sources = (configProperties [configFile >> "CfgVehicles" >> _class >> "animationSources", "isClass _x", true]) apply { configName _x };
            ["set", [_id, "components", (_entry getOrDefault ["components", []]) select { (_x getOrDefault ["source", ""]) in _sources }]] call _fn;
            if !(isClass (configFile >> "CfgVehicles" >> _class >> "TextureSources" >> (_entry getOrDefault ["texture", ""]))) then { ["set", [_id, "texture", ""]] call _fn };
        };
        _popup closeDisplay 1;
        // a new body either way: the stage may still show the class last clicked in the browser
        _session set ["bodyRef", ""];
        if !(_why isEqualTo "") exitWith {
            if (_isMan) then { ["refresh", []] call ALiVE_fnc_fsStudioTabUnits } else { ["refresh", []] call ALiVE_fnc_fsStudioTabVehicles };
            [1, _why] call ALiVE_fnc_fsStudioStatus;
        };
        ["browser base", false] call ALiVE_fnc_fsDataTouch;
        if (_isMan) then { ["refresh", []] call ALiVE_fnc_fsStudioTabUnits } else { if (!isNil "ALiVE_fnc_fsStudioTabVehicles") then { ["refresh", []] call ALiVE_fnc_fsStudioTabVehicles } };
        [0, ["S_BASE_KEEP", "S_BASE_TAKE"] select (_op == "take"), [_entry getOrDefault ["name", _id], _class]] call ALiVE_fnc_fsStudioStatus;
    };
    case "close": {
        if (!isNull _popup) then { _popup closeDisplay 2 };
    };
    default {};
};
