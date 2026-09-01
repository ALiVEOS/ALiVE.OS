#include "\x\alive\addons\sys_classpicker\script_component.hpp"
SCRIPT(classPickerModule);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_classPickerModule

Description:
The class picker as a placed module, so that the tool can be found in the module
list rather than only by knowing what to type into the debug console.

Runs in Eden preview and nowhere else. A module runs its init on every machine,
so one left in a released mission would take the two picker keys away from every
player for the whole mission with nothing to ever give them back. Previewing from
the editor is where the tool is used anyway, and gating on it means a mission that
ships with the module still in it cannot do that.

Parameters:
    _logic     : OBJECT - the placed module
    _operation : STRING - "init"

Returns:
    Nil

Examples:
(begin example)
[_logic, "init"] call ALIVE_fnc_classPickerModule;
(end)

See Also:
- <ALIVE_fnc_classPicker>
- <ALIVE_fnc_classPickerMenuDef>

Author:
Jman
---------------------------------------------------------------------------- */

params ["_logic", ["_operation", "", [""]]];

switch (toLower _operation) do {

    case "init": {

        if !(hasInterface) exitWith {};

        if !(is3DENPreview) exitWith {
            ["ALiVE Class Picker module - only runs when previewing from the editor, doing nothing here. Remove it before release if you would rather it was not in the mission at all."] call ALiVE_fnc_dump;
        };

        // Sides are numbered as CfgFactionClasses numbers them, where east is 0
        // and west is 1, rather than in the order sides are usually written.
        private _playerSide = [east, west, resistance, civilian] find (side player);

        // Which sides a picker serves, worked out from the placement modules it
        // is synced to rather than from a setting of its own. The sync line
        // already says what the picker is for, and a separate side setting could
        // only ever agree with it or contradict it.
        private _sidesOf = {
            params ["_picker"];
            private _sides = [];
            {
                private _t = toLower typeOf _x;
                if (_t in ["alive_mil_placement", "alive_mil_placement_custom", "alive_civ_placement", "alive_civ_placement_custom"]) then {
                    private _faction = _x getVariable ["faction", ""];
                    if (_faction isEqualType "" && {_faction != ""}) then {
                        _sides pushBackUnique (getNumber (configFile >> "CfgFactionClasses" >> _faction >> "side"));
                    };
                };
            } forEach (synchronizedObjects _picker);
            _sides
        };

        private _mySides = [_logic] call _sidesOf;
        private _targetSide = if (_mySides isEqualTo []) then { _playerSide } else { _mySides select 0 };

        // Only one picker can hold the keys, so a picker wired to another side's
        // modules stands aside for the one wired to this side. It only does that
        // when such a picker actually exists, because a picker standing aside
        // when nothing else will run just means nothing runs at all.
        if !(_mySides isEqualTo []) then {
            if !(_playerSide in _mySides) then {
                private _otherServes = false;
                {
                    if (_x != _logic && {!_otherServes}) then {
                        if (_playerSide in ([_x] call _sidesOf)) then { _otherServes = true };
                    };
                } forEach (allMissionObjects "ALiVE_sys_classpicker");

                if (_otherServes) exitWith {
                    ["ALiVE Class Picker module - wired to side(s) %1 and this is side %2, so leaving it to the picker wired to this side", _mySides, _playerSide] call ALiVE_fnc_dump;
                };

                ["ALiVE Class Picker module - wired to side(s) %1 and this is side %2, but no other picker serves this side, so running anyway", _mySides, _playerSide] call ALiVE_fnc_dump;
            };
        };

        uiNamespace setVariable ["ALiVE_classPicker_sideOverride", _targetSide];

        // Which picker module this is, so the editor can use this one's sync
        // lines and not every picker's. Several pickers can be placed, each
        // wired to its own placement modules, but only one of them runs in any
        // one preview and only that one's targets should be written to.
        //
        // Position is the link. The logic running here and the entity sitting in
        // the editor are the same placement, and nothing else survives the trip:
        // the runtime object is gone by the time the editor is back.
        uiNamespace setVariable ["ALiVE_classPicker_activePos", getPosWorld _logic];

        // What this picker is wired to, so the menu can offer the settings that
        // are actually going to be filled and leave out the ones that are not.
        // Sync lines are an editor thing, but a running mission can still see
        // them through synchronizedObjects.
        private _syncedMil = 0;
        private _syncedCiv = 0;
        {
            private _t = toLower typeOf _x;
            if (_t in ["alive_mil_placement", "alive_mil_placement_custom"]) then { _syncedMil = _syncedMil + 1 };
            if (_t in ["alive_civ_placement", "alive_civ_placement_custom"]) then { _syncedCiv = _syncedCiv + 1 };
        } forEach (synchronizedObjects _logic);

        ALIVE_classPicker_syncedTo = [_syncedMil, _syncedCiv];

        // The areas the synced modules actually work in. Buildings outside them
        // are never garrisoned by those modules, so labelling them only invites
        // picking something that will never be used.
        //
        // Used to filter what gets labelled rather than as the search radius: a
        // TAOR is often kilometres across, and sweeping that would return
        // thousands of buildings and try to draw a label on each one.
        private _taor = [];
        {
            private _t = toLower typeOf _x;
            if (_t in ["alive_mil_placement", "alive_mil_placement_custom", "alive_civ_placement", "alive_civ_placement_custom"]) then {
                private _areas = _x getVariable ["taor", []];
                if (_areas isEqualType []) then {
                    { if (_x isEqualType "" && {_x != ""}) then { _taor pushBackUnique _x } } forEach _areas;
                };
            };
        } forEach (synchronizedObjects _logic);

        ALIVE_classPicker_taor = _taor;

        if !(_taor isEqualTo []) then {
            ["ALiVE Class Picker module - limiting to the %1 area(s) the synced modules cover: %2", count _taor, _taor] call ALiVE_fnc_dump;
        };

        if (_syncedMil + _syncedCiv > 0) then {
            ["ALiVE Class Picker module - synced to %1 military and %2 civilian placement module(s)", _syncedMil, _syncedCiv] call ALiVE_fnc_dump;
        };

        private _kinds     = _logic getVariable ["pickerKinds", "buildings"];
        private _radius    = parseNumber (_logic getVariable ["pickerRadius", "75"]);
        private _indices   = (_logic getVariable ["pickerIndices", "true"]) == "true";
        private _autoStart = (_logic getVariable ["pickerAutoStart", "true"]) == "true";

        if (_radius <= 0) then { _radius = 75 };

        // Set before the picker starts, because it reads them at the first frame
        // it draws. Left settable afterwards, so a value that reads badly against
        // whatever is behind it can still be changed without a rebuild.
        ALIVE_classPicker_labelSize = parseNumber (_logic getVariable ["pickerLabelSize", "0.042"]);
        ALIVE_classPicker_indexSize = parseNumber (_logic getVariable ["pickerIndexSize", "0.06"]);
        ALIVE_classPicker_font      = _logic getVariable ["pickerFont", "PuristaBold"];

        if (ALIVE_classPicker_labelSize <= 0) then { ALIVE_classPicker_labelSize = 0.042 };
        if (ALIVE_classPicker_indexSize <= 0) then { ALIVE_classPicker_indexSize = 0.06 };
        if (ALIVE_classPicker_font isEqualTo "") then { ALIVE_classPicker_font = "PuristaBold" };

        ALIVE_classPicker_moduleOpts = [_kinds, _radius, _indices];

        // Left where the editor can read it after the preview has ended. The
        // mission namespace does not survive that, and the editor has no other
        // way to know what this module was set to.
        // Falls back to applying, matching the attribute's own default. A module
        // placed before this attribute existed has nothing saved for it, and
        // falling back to reminding would leave it behaving like the old default
        // no matter what the panel says.
        uiNamespace setVariable ["ALIVE_classPicker_onReturn", _logic getVariable ["pickerOnReturn", "apply"]];

        // The same key every other ALiVE menu hangs off, rather than one of its own.
        [
            "player",
            [((["ALiVE", "openMenu"] call CBA_fnc_getKeybind) select 5) select 0],
            -9500,
            [
                "call ALIVE_fnc_classPickerMenuDef",
                ["main", "alive_flexiMenu_rscPopup"]
            ]
        ] call CBA_fnc_flexiMenu_Add;

        ["ALiVE Class Picker module - %1 within %2m, position numbers %3, starting %4",
            _kinds, _radius, ["off", "on"] select _indices, ["on request", "now"] select _autoStart] call ALiVE_fnc_dump;

        // Whatever the synced modules already hold comes into the collection
        // before anything is drawn, so a second visit carries on from the last
        // one instead of starting from nothing. The variable is the attribute's
        // own name, which is where the module framework puts the value.
        uiNamespace setVariable ["ALiVE_classPicker_preloaded", false];
        {
            private _existing = _x getVariable ["preferredGarrisonPositions", ""];
            if (_existing isEqualType "" && {_existing != ""}) then {
                ["load", _existing] call ALIVE_fnc_classPicker;
            };
        } forEach (synchronizedObjects _logic);

        if (_autoStart) then {
            ["start", [_kinds, _radius, _indices]] call ALIVE_fnc_classPicker;
        };
    };

    default {
        ["ALIVE_fnc_classPickerModule - unknown operation '%1'", _operation] call ALiVE_fnc_dump;
    };
};
