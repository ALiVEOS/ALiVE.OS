/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_edenApplyGarrisonList

Description:
Puts what the class picker collected into a placement module's settings, so
nothing has to be pasted by hand. Two settings are written, each from its own
collection: Preferred Garrison Buildings from the buildings and positions taken
with Home and End, and Garrison Building Blacklist from the ones excluded with
Delete. One session can produce both, so which setting this call is for is
either named by the caller or worked out from what was picked.

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
    _field    : STRING  - which setting to write, "positions" or "blacklist". Empty
                          works it out from what was copied and what was picked. A
                          return from preview names it, because one session can have
                          produced both and each has to reach its own field.

Returns:
    NOTHING

Examples:
(begin example)
[get3DENSelected "logic"] call ALIVE_fnc_edenApplyGarrisonList;
[[], true, "positions"] call ALIVE_fnc_edenApplyGarrisonList;
[get3DENSelected "logic", false, "blacklist"] call ALIVE_fnc_edenApplyGarrisonList;
(end)

See Also:
- <ALIVE_fnc_classPicker>
- <ALIVE_fnc_resolvePreferredGarrisonPositions>

Author:
Jman
---------------------------------------------------------------------------- */

// _field names which setting to write when the caller already knows: "positions" or
// "blacklist". Empty means work it out from what was copied and what was picked,
// which is what the right click entries and the older callers rely on.
params [["_entities", [], [[]]], ["_auto", false, [false]], ["_field", "", [""]]];

// A module only answers to its own property name, so the name that answers is
// also what says which kind of module this is.
private _milProps = ["ALiVE_mil_placement_preferredGarrisonPositions", "ALiVE_mil_placement_custom_preferredGarrisonPositions"];
private _civProps = ["ALiVE_civ_placement_preferredGarrisonPositions", "ALiVE_civ_placement_custom_preferredGarrisonPositions"];

// The blacklist settings, which take the same treatment for a different field.
// It says which buildings no garrison may use, so it names classes and nothing
// else, and it is not filtered by side: a building unfit to stand in is unfit
// whoever is standing.
private _blacklistProps = ["ALiVE_mil_placement_garrisonBuildingBlacklist", "ALiVE_mil_placement_custom_garrisonBuildingBlacklist",
                           "ALiVE_civ_placement_garrisonBuildingBlacklist", "ALiVE_civ_placement_custom_garrisonBuildingBlacklist"];

private _allProps = _milProps + _civProps + _blacklistProps;

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

// The same question asked of the exclusions. They are preloaded from the field too
// now, so the collection already contains whatever was there and writing it back
// replaces rather than doubles.
private _blacklistPreloaded = uiNamespace getVariable ["ALiVE_classPicker_blacklistPreloaded", false];

// What the list was copied for, recorded by the menu entry that copied it.
private _dest = uiNamespace getVariable ["ALiVE_classPicker_destination", []];
private _destKey = "";
private _list = "";
if (_dest isEqualType [] && {count _dest > 1}) then {
    _destKey = _dest select 0;
    _list = _dest select 1;
};

// Which of the two settings this list is for. A positions list is recognised by
// carrying an "="; a blacklist is bare class names, so that test would reject
// every one of them and the whole feature would read as doing nothing.
// What was excluded during the preview, whether or not anybody copied it for a
// setting. Coming back from a preview should put what was picked into the modules,
// and an exclusion is as much a thing that was picked as a position is. Held apart
// from _list because the two go to different fields.
private _stashed = uiNamespace getVariable ["ALiVE_classPicker_stash", []];
private _blacklistPicked = "";
if (_stashed isEqualType [] && {count _stashed > 4}) then {
    private _b = _stashed select 4;
    if (!isNil "_b" && {_b isEqualType ""}) then { _blacklistPicked = _b };
};

private _named = toLower _field;

// Named outright, or worked out from what was copied. A caller that names the field
// gets that field whatever was last copied for something else, which is what lets
// one return apply the positions and the exclusions to their own settings in turn.
private _isBlacklist = switch (_named) do {
    case "blacklist": { true };
    case "positions": { false };
    default {
        // Nothing was copied for anything, but buildings were excluded. That is a
        // blacklist apply and nothing else. This is the ordinary way it happens:
        // press Delete on a few buildings, press Escape, and expect to find them.
        ((toLower _destKey) == "garrisonblacklist")
            || {_destKey == "" && {_list == ""} && {_blacklistPicked != ""}}
    };
};

// However it was decided, a blacklist apply takes the exclusions and a positions
// apply must not be handed them.
if (_isBlacklist) then {
    _destKey = "garrisonBlacklist";
    if (_blacklistPicked != "" && {_list == "" || {_named == "blacklist"}}) then { _list = _blacklistPicked };
} else {
    if (_named == "positions") then { _destKey = "" };
};
private _fnc_looksRight = {
    params ["_text"];
    if (_text == "") exitWith { false };
    if !(_isBlacklist) exitWith { "=" in _text };

    // A blacklist has no punctuation to recognise it by, so it is recognised by
    // what it names: at least one entry that is a real class. Without this any
    // stray clipboard, a file path or a line of chat copied between picking and
    // pressing Escape, would be written into the setting verbatim.
    private _looks = false;
    {
        private _entry = _x;
        { _entry = (_entry splitString _x) joinString ""; } forEach ["[", "]", """", "'", " "];
        if (_entry != "" && {isClass (configFile >> "CfgVehicles" >> _entry)}) exitWith { _looks = true };
    } forEach (((_text splitString toString [13,10]) joinString ";") splitString ";,");
    _looks
};

// The clipboard is what the picker's copy fills, and pasting it is what this is
// for. copyFromClipboard is refused in multiplayer, never in the editor.
private _clip = copyFromClipboard;
private _source = "the last picking session";
// Asked for by name, what was picked wins. The clipboard is a convenience for the
// copy-then-apply route, not a thing that should quietly replace what somebody just
// picked because a list happened to be sitting on it.
if (_named == "" && {[_clip] call _fnc_looksRight}) then { _list = _clip; _source = "the clipboard" };

if (_list == "") then {
    private _stash = uiNamespace getVariable ["ALiVE_classPicker_stash", []];
    if (_stash isEqualType [] && {count _stash > 0}) then {
        // Slot 0 is the positions render and slot 4 the exclusions. Reaching for the
        // wrong one writes a Class=1,2 list into a field that holds class names.
        _list = _stash select ([0, 4] select _isBlacklist);
        if (isNil "_list" || {!(_list isEqualType "")}) then { _list = "" };
    };
};

// Fold the line breaks the same way the resolver does, so a list built one entry
// per line arrives as one string rather than pasting a newline into the field.
_list = (_list splitString toString [13,10]) joinString ";";
while {count _list > 0 && {(_list select [0,1]) == ";"}} do { _list = _list select [1] };
while {count _list > 0 && {(_list select [count _list - 1, 1]) == ";"}} do { _list = _list select [0, count _list - 1] };

if !([_list] call _fnc_looksRight) exitWith {
    if !(_auto) then {
        ["ALiVE class picker: nothing to apply. Preview the mission, pick some buildings and positions, then copy them for a setting from the ALiVE menu before coming back here.", 1, 30] call BIS_fnc_3DENNotification;
    };
    ["ALiVE class picker - nothing to apply, no garrison list on the clipboard and none stored"] call ALiVE_fnc_dump;
};

// Which properties count. Running on its own, only the kind the list was copied
// for, so a military list cannot land on a civilian module unasked. Asked for by
// hand, whatever was selected, because that is an explicit instruction.
private _wanted = switch (toLower _destKey) do {
    case "milgarrison":       { _milProps };
    case "civgarrison":       { _civProps };
    case "garrisonblacklist": { _blacklistProps };
    // Nothing was copied for anything, so this is the stash: the positions the
    // picker collected. It goes to the positions fields and nowhere else. Letting
    // it fall through to every field would write a Class=1,2 list into the
    // blacklist, which reads as a class name nothing matches and quietly excludes
    // whatever it does match.
    default                   { _milProps + _civProps };
};
// Asked for by hand, whatever is selected gets it, but still only the field the
// list was copied for. Writing class names into the positions field would produce
// a setting the resolver rejects entry by entry.
if (!_auto && {!_isBlacklist}) then { _wanted = _milProps + _civProps };

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
                            if (_pickedSide >= 0 && {!_isBlacklist} && {_garrisonProp in _milProps}) then {
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
            // The preload flag says the picking started from what the positions field
            // already held, so writing it back replaces rather than doubles it. Nothing
            // preloads the blacklist, so on that path the flag says nothing about this
            // field and honouring it would throw away classes typed in by hand.
            private _replacing = _current == "" ||
                {if (_isBlacklist) then {_blacklistPreloaded} else {_preloaded}};
            private _new = if (_replacing) then { _list } else { _current + ";" + _list };

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
        [format ["ALiVE class picker: nothing was written. What is selected has no %1 setting on it. Select a military or civilian placement module.",
                 ["Preferred Garrison Buildings", "Garrison Building Blacklist"] select _isBlacklist], 1, 30] call BIS_fnc_3DENNotification;
    };
    ["ALiVE class picker - nothing written, %1 selected item(s) carry no garrison setting", _skipped] call ALiVE_fnc_dump;
};

// Forgotten now it has been used. It lives in uiNamespace, which survives leaving
// the editor entirely, so leaving it set means the next preview that ends applies
// this same list again. The positions fields are replaced rather than added to and
// so survive that, but the blacklist is added to, and would double every time.
if (_auto) then { uiNamespace setVariable ["ALIVE_classPicker_destination", []] };

private _note = if (_skipped > 0) then { format ["\n%1 other selected item(s) had no such setting and were left alone.", _skipped] } else { "" };
[format ["ALiVE class picker: applied to %1 module(s) from %2. %3 %4 -- Ctrl+Z takes it back.", _done, _source, _names joinString ", ", _note], 0, 20] call BIS_fnc_3DENNotification;
