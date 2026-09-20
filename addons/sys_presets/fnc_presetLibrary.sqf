#include "script_component.hpp"
SCRIPT(presetLibrary);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_presetLibrary

Description:
The mission maker's own collection of presets, kept in their profile.

A preset that came from the site or from somebody in Discord is a line of text.
Pasting it every time you want it is the difference between a feature people use
and one they try once, so pasting it ONCE puts it in here, and it is still here
next week and in every scenario.

The profile is used because it is the only place a mod can write to. Arma cannot
write files from script, so the editor's own composition folder is out of reach
without asking somebody to unzip an archive into a folder they will never find.
The profile costs nothing and belongs to the person rather than to a scenario.

Presets that ship with ALiVE are listed from config alongside the collected ones,
so there is one place to look whatever a preset came from.

Parameters:
    _operation - STRING - "list", "add", "remove"
    _args      - the operation's argument:
                   "add"    - STRING, the preset text
                   "remove" - STRING, the name of a collected preset

Returns:
    "list"   - ARRAY of [_name, _description, _text, _shipped]
    "add"    - ARRAY [_ok, _message]
    "remove" - BOOL

Examples:
    (begin example)
    private _all = ["list"] call ALIVE_fnc_presetLibrary;
    (["add", copyFromClipboard] call ALIVE_fnc_presetLibrary) params ["_ok", "_why"];
    (end)

See Also:
    ALIVE_fnc_presetWindow, ALIVE_fnc_presetParse, ALIVE_fnc_presetPlace

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_operation", "list", [""]], ["_args", "", ["", []]]];

#define STORE "ALiVE_presetLibrary"

private _saved = profileNamespace getVariable [STORE, []];
if !(_saved isEqualType []) then { _saved = [] };

private _result = false;

switch (toLower _operation) do {

    // Everything the person can place: what ALiVE ships, then what they have
    // collected. Shipped first, because those have been through a review and are
    // the ones somebody with nothing yet should see at the top.
    case "list": {
        private _out = [];

        private _shipped = configFile >> "CfgALiVEPresets" >> "Shipped";
        for "_i" from 0 to (count _shipped) - 1 do {
            private _c = _shipped select _i;
            if (isClass _c) then {
                _out pushBack [
                    getText (_c >> "name"),
                    getText (_c >> "description"),
                    getText (_c >> "text"),
                    true
                ];
            };
        };

        {
            if (_x isEqualType [] && {count _x > 2}) then {
                _out pushBack [_x select 0, _x select 1, _x select 2, false];
            };
        } forEach _saved;

        _result = _out;
    };

    // Kept only if it reads as a preset for this build, so a collection cannot
    // fill up with text that will not place. The name comes from the preset
    // itself; one without a name is stored under the date it was collected,
    // which at least sorts.
    case "add": {
        private _text = if (_args isEqualType "") then { _args } else { "" };
        ([_text] call ALIVE_fnc_presetParse) params ["_ok", "_preset", "_problems"];
        if (!_ok) exitWith {
            _result = [false, if (count _problems > 0) then { _problems select 0 } else { "That is not a preset." }];
        };

        private _meta = _preset select 2;
        private _name = [_meta, 0, "", [""]] call BIS_fnc_param;
        private _description = [_meta, 1, "", [""]] call BIS_fnc_param;
        if (_name isEqualTo "") then {
            // The real date, not the scenario's: a preset kept today should not
            // be filed under the year the editor happens to be set to. Somebody
            // can rename it, and a preset with no name of its own is exactly the
            // one they will want to.
            private _now = systemTime;
            private _minute = str (_now select 4);
            if (count _minute < 2) then { _minute = "0" + _minute };
            _name = format ["Collected %1-%2-%3 %4:%5", _now select 0, _now select 1, _now select 2,
                _now select 3, _minute];
        };

        // A second copy of the same preset replaces the first rather than
        // stacking up. Somebody pasting the same line twice means "make sure I
        // have this", not "give me two of them".
        private _at = _saved findIf { (_x select 0) isEqualTo _name };
        if (_at >= 0) then {
            _saved set [_at, [_name, _description, _text]];
        } else {
            _saved pushBack [_name, _description, _text];
        };

        profileNamespace setVariable [STORE, _saved];
        saveProfileNamespace;
        _result = [true, format ["Added ""%1"" to your presets. It will be here next time.", _name]];
    };

    // Renaming and describing. The name and description are written into the
    // preset's own text as well as into the list, so a preset copied back out
    // carries what it was called here rather than arriving somewhere else
    // nameless. A preset collected from a stranger often has no name at all,
    // which is exactly when somebody wants to give it one.
    case "update": {
        _args params [["_was", "", [""]], ["_name", "", [""]], ["_description", "", [""]]];
        private _at = _saved findIf { (_x select 0) isEqualTo _was };
        if (_at < 0) exitWith { _result = [false, "That preset is not one of yours."] };
        if (_name isEqualTo "") exitWith { _result = [false, "A preset needs a name."] };
        if (_name != _was && {(_saved findIf { (_x select 0) isEqualTo _name }) >= 0}) exitWith {
            _result = [false, format ["You already have one called ""%1"".", _name]];
        };

        private _text = (_saved select _at) select 2;
        ([_text] call ALIVE_fnc_presetParse) params ["_ok", "_preset"];
        if (_ok) then {
            private _meta = _preset select 2;
            while { count _meta < 6 } do { _meta pushBack "" };
            _meta set [0, _name];
            _meta set [1, _description];
            _preset set [2, _meta];
            private _rewritten = _preset call ALIVE_fnc_presetSerialize;
            if !(_rewritten isEqualTo "") then { _text = _rewritten };
        };

        _saved set [_at, [_name, _description, _text]];
        profileNamespace setVariable [STORE, _saved];
        saveProfileNamespace;
        _result = [true, format ["Saved as ""%1"".", _name]];
    };

    case "remove": {
        private _name = if (_args isEqualType "") then { _args } else { "" };
        private _at = _saved findIf { (_x select 0) isEqualTo _name };
        if (_at < 0) exitWith { _result = false };
        _saved deleteAt _at;
        profileNamespace setVariable [STORE, _saved];
        saveProfileNamespace;
        _result = true;
    };

    default {
        ["ALIVE_fnc_presetLibrary - no such operation: %1", _operation] call ALiVE_fnc_dump;
    };
};

_result
