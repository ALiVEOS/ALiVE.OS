/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_edenApplyGarrisonList

Description:
Puts a picked garrison list into placement modules' Preferred Garrison Buildings
setting, so the list does not have to be pasted by hand.

Runs in the editor, not in a mission. A running mission cannot touch an Eden
attribute at all, so the picking happens in preview and the writing happens
here, after Escape.

The list is taken from the clipboard, which is where the picker's copy puts it.
If the clipboard holds something that is not a garrison list, the picker's own
last collection is used instead, so the setting still gets filled in when
somebody forgets the copy step or copies something else in between.

Which modules get written to depends on how it was asked for:

    from the right click menu, whatever is selected, whichever kind it is
    on returning from preview, every module of the kind the list was copied for

The copy names its destination ("Copy for Military Placement garrisons"), so
there is no guessing involved and no reason to stop at one module. A mission
with four military placement modules gets the list on all four.

Anything already in a field is kept and the new entries are added after it. A
class named twice takes the later list, so re-picking a building that was
already listed replaces its positions rather than fighting with them.

NOTE this file is deliberately free of any script_component include and of the
SCRIPT macro. It is compiled by hand from main's preInit, because a function
registered through CfgFunctions is never defined in the editor at all.

Parameters:
    _entities : ARRAY   - Eden entities to write to. Empty means work it out.
    _auto     : BOOLEAN - true when this ran itself on returning from preview,
                          which restricts it to the kind the list was copied for

Returns:
    NOTHING

Examples:
(begin example)
[get3DENSelected "logic"] call ALIVE_fnc_edenApplyGarrisonList;
[[], true] call ALIVE_fnc_edenApplyGarrisonList;
(end)

See Also:
- <ALIVE_fnc_classPicker>
- <ALIVE_fnc_resolvePreferredGarrisonPositions>

Author:
Jman
---------------------------------------------------------------------------- */

params [["_entities", [], [[]]], ["_auto", false, [false]]];

// A module only answers to its own property name, so the name that answers is
// also what says which kind of module this is.
private _milProps = ["ALiVE_mil_placement_preferredGarrisonPositions", "ALiVE_mil_placement_custom_preferredGarrisonPositions"];
private _civProps = ["ALiVE_civ_placement_preferredGarrisonPositions", "ALiVE_civ_placement_custom_preferredGarrisonPositions"];
private _allProps = _milProps + _civProps;

// The faction setting that sits alongside each garrison setting, for working out
// which side a module belongs to.
private _factionProps = createHashMapFromArray [
    ["ALiVE_mil_placement_preferredGarrisonPositions",        "ALiVE_mil_placement_faction"],
    ["ALiVE_mil_placement_custom_preferredGarrisonPositions", "ALiVE_mil_placement_custom_faction"],
    ["ALiVE_civ_placement_preferredGarrisonPositions",        "ALiVE_civ_placement_faction"],
    ["ALiVE_civ_placement_custom_preferredGarrisonPositions", "ALiVE_civ_placement_custom_faction"]
];

// Side the list was picked on, as CfgFactionClasses numbers them.
private _pickedSide = uiNamespace getVariable ["ALiVE_classPicker_side", -1];

// Whether the picking started from what the modules already held. Decides
// whether writing back replaces what is there or adds to it.
private _preloaded = uiNamespace getVariable ["ALiVE_classPicker_preloaded", false];

// What the list was copied for, recorded by the menu entry that copied it.
private _dest = uiNamespace getVariable ["ALiVE_classPicker_destination", []];
private _destKey = "";
private _list = "";
if (_dest isEqualType [] && {count _dest > 1}) then {
    _destKey = _dest select 0;
    _list = _dest select 1;
};

// The clipboard is what the picker's copy fills, and pasting it is what this is
// for. copyFromClipboard is refused in multiplayer, never in the editor.
private _clip = copyFromClipboard;
private _source = "the last picking session";
if ("=" in _clip) then { _list = _clip; _source = "the clipboard" };

if (_list == "") then {
    private _stash = uiNamespace getVariable ["ALiVE_classPicker_stash", []];
    if (_stash isEqualType [] && {count _stash > 0}) then { _list = _stash select 0 };
};

// Fold the line breaks the same way the resolver does, so a list built one entry
// per line arrives as one string rather than pasting a newline into the field.
_list = (_list splitString toString [13,10]) joinString ";";
while {count _list > 0 && {(_list select [0,1]) == ";"}} do { _list = _list select [1] };
while {count _list > 0 && {(_list select [count _list - 1, 1]) == ";"}} do { _list = _list select [0, count _list - 1] };

if (_list == "" || {!("=" in _list)}) exitWith {
    if !(_auto) then {
        ["ALiVE class picker: nothing to apply. Preview the mission, pick some buildings and positions, then copy them for a setting from the ALiVE menu before coming back here.", 1, 30] call BIS_fnc_3DENNotification;
    };
    ["ALiVE class picker - nothing to apply, no garrison list on the clipboard and none stored"] call ALiVE_fnc_dump;
};

// Which properties count. Running on its own, only the kind the list was copied
// for, so a military list cannot land on a civilian module unasked. Asked for by
// hand, whatever was selected, because that is an explicit instruction.
private _wanted = switch (toLower _destKey) do {
    case "milgarrison": { _milProps };
    case "civgarrison": { _civProps };
    default            { _allProps };
};
if !(_auto) then { _wanted = _allProps };

if (_auto) then {

    // A line drawn from the picker module to a placement module says exactly
    // which modules the list is for, which beats working it out from sides and
    // factions and is visible in the editor rather than inferred. Anything
    // synced wins outright; the side matching below is only for a picker module
    // nobody has wired up.
    // Every picker module in the scene, so the one that was actually used can be
    // picked out of them.
    private _pickers = [];
    {
        {
            if (_x isEqualType objNull && {!isNull _x} && {(typeOf _x) == "ALiVE_sys_classpicker"}) then {
                _pickers pushBackUnique _x;
            };
        } forEach _x;
    } forEach all3DENEntities;

    // Only the picker that ran. Several can be placed, each wired to its own
    // placement modules, and pooling all their sync lines would put a list
    // picked on one side's picker onto the other side's modules.
    private _activePos = uiNamespace getVariable ["ALiVE_classPicker_activePos", []];
    private _active = objNull;
    if (_activePos isEqualType [] && {count _activePos > 2} && {!(_pickers isEqualTo [])}) then {
        private _best = 1e9;
        {
            private _d = (getPosWorld _x) distance _activePos;
            if (_d < _best) then { _best = _d; _active = _x };
        } forEach _pickers;
        // Same placement, so the two should sit on top of each other. Anything
        // further away is a different module and matching it would be a guess.
        if (_best > 5) then { _active = objNull };
    };

    if (isNull _active && {count _pickers == 1}) then { _active = _pickers select 0 };

    private _synced = [];
    if !(isNull _active) then {
        {
            private _peer = _x select 1;
            if (!isNil "_peer" && {_peer isEqualType objNull} && {!isNull _peer}) then {
                _synced pushBackUnique _peer;
            };
        } forEach ((get3DENConnections _active) select {(_x select 0) == "Sync"});
    } else {
        if (count _pickers > 1) then {
            ["ALiVE class picker - %1 picker modules placed and none of them matches the one that ran, so falling back to matching sides rather than guessing which sync lines to follow", count _pickers] call ALiVE_fnc_dump;
        };
    };

    // Only the synced things that actually carry a garrison setting. A picker
    // synced to an OPCOM as well should not be reported as a failure.
    private _syncTargets = [];
    {
        private _e = _x;
        {
            private _probe = _e get3DENAttribute _x;
            if (_probe isEqualType [] && {count _probe > 0}) then {
                private _v = _probe select 0;
                if (!isNil "_v" && {_v isEqualType ""}) then { _syncTargets pushBackUnique _e };
            };
        } forEach _allProps;
    } forEach _synced;

    if !(_syncTargets isEqualTo []) exitWith {
        ["ALiVE class picker - %1 module(s) synced to the picker, using those and ignoring sides", count _syncTargets] call ALiVE_fnc_dump;
        _entities = _syncTargets;
    };

    // Every module of that kind, not just one. Several military placement modules
    // in a mission all want the same buildings garrisoned the same way, and
    // stopping at one would only mean doing the rest by hand.
    private _carriers = [];
    private _wrongSide = 0;
    {
        {
            if (_x isEqualType objNull && {!isNull _x}) then {
                private _e = _x;
                {
                    private _garrisonProp = _x;
                    private _probe = _e get3DENAttribute _garrisonProp;
                    if (_probe isEqualType [] && {count _probe > 0}) then {
                        private _v = _probe select 0;
                        if (!isNil "_v" && {_v isEqualType ""}) then {

                            // Only this side's modules. A list picked as BLUFOR
                            // has no business on the module that fills the other
                            // side's objectives.
                            //
                            // Civilians are side 3 whoever picked the list, so
                            // there is no side to match against and the filter
                            // would only ever exclude everything.
                            private _sideOk = true;
                            if (_pickedSide >= 0 && {_garrisonProp in _milProps}) then {
                                _sideOk = false;
                                private _fp = _factionProps getOrDefault [_garrisonProp, ""];
                                if (_fp != "") then {
                                    private _fProbe = _e get3DENAttribute _fp;
                                    if (_fProbe isEqualType [] && {count _fProbe > 0}) then {
                                        private _faction = _fProbe select 0;
                                        if (!isNil "_faction" && {_faction isEqualType ""} && {_faction != ""}) then {
                                            _sideOk = (getNumber (configFile >> "CfgFactionClasses" >> _faction >> "side")) isEqualTo _pickedSide;
                                        } else {
                                            // No faction chosen yet, so nothing to
                                            // rule it out on.
                                            _sideOk = true;
                                        };
                                    };
                                };
                            };

                            if (_sideOk) then {
                                _carriers pushBackUnique _e;
                            } else {
                                _wrongSide = _wrongSide + 1;
                            };
                        };
                    };
                } forEach _wanted;
            };
        } forEach _x;
    } forEach all3DENEntities;

    if (_wrongSide > 0) then {
        ["ALiVE class picker - left %1 module(s) alone, their faction is not on the side the list was picked on", _wrongSide] call ALiVE_fnc_dump;
    };

    _entities = _carriers;
} else {
    if (_entities isEqualTo []) then { _entities = get3DENSelected "logic" };
};

if (_entities isEqualTo []) exitWith {
    if !(_auto) then {
        ["ALiVE class picker: select a placement module first, then try again.", 1, 20] call BIS_fnc_3DENNotification;
    } else {
        ["ALiVE class picker - nothing to apply to, no module of the %1 kind is placed", _destKey] call ALiVE_fnc_dump;
    };
};

private _done = 0;
private _skipped = 0;
private _names = [];

{
    private _entity = _x;
    private _written = false;

    {
        private _prop = _x;
        private _before = _entity get3DENAttribute _prop;

        // A module that does not carry this setting answers with a one element
        // array holding nothing, so the element is what says whether it has it.
        private _has = false;
        private _current = "";
        if (_before isEqualType [] && {count _before > 0}) then {
            private _v = _before select 0;
            if (!isNil "_v" && {_v isEqualType ""}) then { _has = true; _current = _v };
        };

        if (_has) then {
            // When the picking started from what these modules already held, the
            // list already contains their contents and adding to it would name
            // every class twice. When it did not, whatever is in the field was
            // put there by hand and is kept.
            private _new = if (_current == "" || {_preloaded}) then { _list } else { _current + ";" + _list };

            // Collected so that Ctrl+Z takes it back. A scripted change the
            // editor's own undo does not know about is worse than no feature,
            // because the previous contents of the field are then gone for good.
            private _ok = false;
            collect3DENHistory {
                _ok = _entity set3DENAttribute [_prop, _new];
            };

            if (_ok) then {
                _written = true;
                _done = _done + 1;
                _names pushBackUnique (typeOf _entity);
                ["ALiVE class picker - wrote %1 on %2, was '%3', now '%4'", _prop, typeOf _entity, _current, _new] call ALiVE_fnc_dump;
            } else {
                ["ALiVE class picker - %1 refused the write on %2", _prop, typeOf _entity] call ALiVE_fnc_dump;
            };
        };
    } forEach _wanted;

    if (!_written) then { _skipped = _skipped + 1 };

} forEach _entities;

if (_done == 0) exitWith {
    if !(_auto) then {
        ["ALiVE class picker: nothing was written. What is selected has no Preferred Garrison Buildings setting on it. Select a military or civilian placement module.", 1, 30] call BIS_fnc_3DENNotification;
    };
    ["ALiVE class picker - nothing written, %1 selected item(s) carry no garrison setting", _skipped] call ALiVE_fnc_dump;
};

private _note = if (_skipped > 0) then { format ["\n%1 other selected item(s) had no such setting and were left alone.", _skipped] } else { "" };
[format ["ALiVE class picker: applied to %1 module(s) from %2. %3 %4 -- Ctrl+Z takes it back.", _done, _source, _names joinString ", ", _note], 0, 20] call BIS_fnc_3DENNotification;
