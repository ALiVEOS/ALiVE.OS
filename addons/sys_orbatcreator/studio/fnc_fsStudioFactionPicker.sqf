#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsStudioFactionPicker);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsStudioFactionPicker

Description:
The "Import a faction" popup (ALiVE_FS_FactionPicker, 14820): first the
factions ALiVE's Faction Compiler built in this mission (single player or a
listen server's host), then every config faction with its unit, vehicle and
group counts. A compiled row's data is "@cmp:" and its faction id, and it is
imported by ALiVE_fnc_fsImportCompiled.

    - "open": the list fills at once; its two buttons stay off until the class
      index and ALiVE's static data are both there (group import needs the
      mappings), and come on by themselves when they are;
    - "select": the picked row;
    - "new": asks first (Q_REPLACE), then the imported faction replaces the
      working one (a backup is made, Restore brings it back). A faction with no
      tag of its own keeps the working faction's tag, else asks for one (Q_TAG);
    - "merge": the imported faction is merged into the working one;
    - "close".
Import notes, when there are any, are shown in the text popup afterwards.

Parameters:
    _op   - STRING - as above
    _args - ARRAY - the event arguments

Returns:
    Nothing

Examples:
    (begin example)
    ["open"] call ALiVE_fnc_fsStudioFactionPicker;
    (end)

See Also:
    ALiVE_fnc_fsImportFaction, ALiVE_fnc_fsImportCompiled, ALiVE_fnc_fsImportMerge, ALiVE_fnc_fsStudioTabFaction

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\data\ui\studio\idc.hpp"

disableSerialization;

params [["_op", "", [""]], ["_args", []]];

private _session = missionNamespace getVariable "ALiVE_FS_session";
if (isNil "_session") exitWith {};
private _popup = findDisplay FS_IDD_PICKER;

// the picked faction class, or ""
private _picked = {
    if (isNull _popup) exitWith { "" };
    private _l = _popup displayCtrl FS_IDC_PK_LIST;
    if (lbCurSel _l < 0) then { "" } else { _l lbData (lbCurSel _l) }
};

// a picked row to [incoming, notes]: a compiled faction or a config one
private _import = {
    params ["_class"];
    if ((_class select [0, 5]) isEqualTo "@cmp:") exitWith { [_class select [5]] call ALiVE_fnc_fsImportCompiled };
    [_class] call ALiVE_fnc_fsImportFaction
};
// after an import: the tab redrawn, the notes shown
private _after = {
    params ["_notes"];
    [_session getOrDefault ["tab", "faction"]] call ALiVE_fnc_fsStudioTab;
    if !(_notes isEqualTo []) then {
        ["open", [localize "STR_ALIVE_FS_PK_TITLE", _notes joinString endl]] call ALiVE_fnc_fsStudioTextBox;
    };
};

switch (_op) do {
    case "open": {
        private _studio = _session getOrDefault ["display", displayNull];
        if (isNull _studio) exitWith {};
        if (!isNull _popup) then { _popup closeDisplay 2 };
        _popup = _studio createDisplay "ALiVE_FS_FactionPicker";
        if (isNull _popup) exitWith {};
        private _l = _popup displayCtrl FS_IDC_PK_LIST;
        // the factions compiled in this mission, where the compiler ran (the server)
        if (!isNil "ALIVE_compiledFactions" && {!isNil "ALIVE_fnc_hashGet"}) then {
            {
                private _d = [ALIVE_compiledFactions, _x] call ALIVE_fnc_hashGet;
                private _g = if (isNil "_d") then { nil } else { [_d, "compiledGroups"] call ALIVE_fnc_hashGet };
                if (!isNil "_g" && {_g isEqualType []} && {count _g >= 3} && {count (_g select 1) > 0}) then {
                    private _dn = [_d, "displayName"] call ALIVE_fnc_hashGet;
                    if (isNil "_dn") then { _dn = _x };
                    private _i = _l lbAdd format [localize "STR_ALIVE_FS_PK_CMP_ROW", _dn, _x, count (_g select 1)];
                    _l lbSetData [_i, "@cmp:" + _x];
                    _l lbSetTooltip [_i, _x];
                    _l lbSetColor [_i, [0.576, 0.769, 0.49, 1]];
                };
            } forEach (ALIVE_compiledFactions select 1);
        };
        {
            _x params ["_class", "_name", "", "_units", "_vehicles", "_groups"];
            private _i = _l lbAdd format [localize "STR_ALIVE_FS_PK_ROW", _name, _units, _vehicles, _groups];
            _l lbSetData [_i, _class];
            _l lbSetTooltip [_i, _class];
        } forEach ([] call ALiVE_fnc_fsImportFactionList);
        { (_popup displayCtrl _x) ctrlEnable false } forEach [FS_IDC_PK_NEW, FS_IDC_PK_MERGE];
        // the buttons come on once the index and the static data are both there
        [_popup] spawn {
            params ["_popup"];
            disableSerialization;
            if (isNil { uiNamespace getVariable "ALiVE_FS_index" } && {!(missionNamespace getVariable ["ALiVE_FS_indexBuilding", false])}) then {
                missionNamespace setVariable ["ALiVE_FS_indexBuilding", true];
                [] call ALiVE_fnc_fsIndexBuild;
            };
            waitUntil { isNull _popup || {!isNil { uiNamespace getVariable "ALiVE_FS_index" } && {missionNamespace getVariable ["ALiVE_STATIC_DATA_LOADED", false]}} };
            if (isNull _popup) exitWith {};
            { (_popup displayCtrl _x) ctrlEnable true } forEach [FS_IDC_PK_NEW, FS_IDC_PK_MERGE];
        };
    };
    case "select": {};
    case "new": {
        private _class = call _picked;
        if (_class isEqualTo "") exitWith {};
        _popup closeDisplay 1;
        ["open", [localize "STR_ALIVE_FS_Q_REPLACE", nil, {
            params ["_ok", "", "_cbArgs"];
            _cbArgs params ["_class", "_after", "_import"];
            if (!_ok) exitWith {};
            ([_class] call _import) params ["_incoming", "_notes"];
            if ((count _incoming) == 0) exitWith { [1, "S_PASTE_BAD", [_class]] call ALiVE_fnc_fsStudioStatus };
            private _old = missionNamespace getVariable ["ALiVE_FS_faction", createHashMap];
            private _oldTag = _old getOrDefault ["tag", ""];
            ["replace", [_incoming]] call ALiVE_fnc_fsDataStore;
            ["import new", true] call ALiVE_fnc_fsDataTouch;
            private _session = missionNamespace getVariable ["ALiVE_FS_session", createHashMap];
            _session set ["selUnit", ""];
            _session set ["selVehicle", ""];
            _session set ["bodyRef", ""];
            [0, "S_IMPORTED", [_incoming getOrDefault ["name", _class], count (_incoming getOrDefault ["units", createHashMap]), count (_incoming getOrDefault ["vehicles", createHashMap]), count (_incoming getOrDefault ["groups", createHashMap])]] call ALiVE_fnc_fsStudioStatus;
            if ((_incoming getOrDefault ["tag", ""]) isEqualTo "") then {
                if !(_oldTag isEqualTo "") then {
                    ["tag", _oldTag] call ALiVE_fnc_fsStudioTabFaction;
                } else {
                    ["askTag", []] call ALiVE_fnc_fsStudioTabFaction;
                };
            };
            [_notes] call _after;
        }, [_class, _after, _import]]] call ALiVE_fnc_fsStudioPrompt;
    };
    case "merge": {
        private _class = call _picked;
        if (_class isEqualTo "") exitWith {};
        _popup closeDisplay 1;
        ([_class] call _import) params ["_incoming", "_notes"];
        if ((count _incoming) == 0) exitWith { [1, "S_PASTE_BAD", [_class]] call ALiVE_fnc_fsStudioStatus };
        private _working = missionNamespace getVariable ["ALiVE_FS_faction", createHashMap];
        ([_working, _incoming] call ALiVE_fnc_fsImportMerge) params ["_added", "_skipped", "_mergeNotes"];
        [0, "S_MERGED", [_incoming getOrDefault ["name", _class], _added, _skipped]] call ALiVE_fnc_fsStudioStatus;
        [_notes + _mergeNotes] call _after;
    };
    case "close": {
        if (!isNull _popup) then { _popup closeDisplay 2 };
    };
    default {};
};
