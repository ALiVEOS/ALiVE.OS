#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenFactionChoiceMultiLoad);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_edenFactionChoiceMultiLoad

Description:
Eden-attribute `attributeLoad` handler for the ALiVE_FactionChoiceMulti
control family. Multi-select counterpart to fnc_edenFactionChoiceLoad.sqf
(single-select Combo). Populates a multi-select ListBox at IDC 100 from
loaded CfgFactionClasses entries (same population/filter logic as the
single-select handler), then ticks the items matching the stored value.

Three control variants share this handler, parameterized via the side
allowlist passed alongside _this:
    ALiVE_FactionChoiceMulti           sides [0,1,2,3] (all)
    ALiVE_FactionChoiceMulti_Military  sides [0,1,2]   (no civilians)
    ALiVE_FactionChoiceMulti_Civilian  sides [3]       (civilians only)

Backward-compatible stored-value parsing - accepts ALL of these forms:
  - Empty string / nil           -> no items selected
  - Empty array literal "[]"     -> no items selected
  - SQF array literal "[\"a\",\"b\"]" -> parseSimpleArray to list
  - CSV "a,b,c"                  -> split on comma
  - Single faction "a"           -> treated as [a]

Allowing all three lets us replace the legacy Edit-field "paste array
literal or CSV" UX without breaking missions saved with either format.
The Save handler always emits the canonical array-literal form going
forward.

The variable name on the logic and the Eden value slot is configurable
via the third element of _this. Defaults to "factions" (mil_opcom's
attribute name) but can be overridden by the per-control attributeLoad
expression for other modules whose attribute is named differently
(e.g. "CQB_FACTIONS" for mil_cqb).

Optional 4th element (_initialDefault) is an array of faction classnames
to pre-tick when no stored value is found - i.e. fresh module placement
with no logic variable set and no Eden value slot. Used by mil_opcom to
mirror its runtime BLU_F fallback so the listbox shows a sensible default
rather than blank. Most consumers omit it - empty default is semantic
opt-in for them. Encoded as if the user had explicitly stored that list,
so it goes through the same parse/populate path as a real saved value.

Parameters:
    [_display, _allowedSides, _varName, _initialDefault, _sqmValue, _titleStr]
    _display        : DISPLAY - Eden attribute display. ListBox control IDC 100.
    _allowedSides   : ARRAY of NUMBERs - sides to include. Defaults [0,1,2,3].
    _varName        : STRING - name of the logic variable storing the value.
                      Defaults to "factions".
    _initialDefault : ARRAY of STRINGs - faction classnames to pre-tick when
                      no value is stored. Defaults to [] (no pre-tick).
    _sqmValue       : STRING - SQM-serialised attribute value passed in from
                      the variant control class's attributeLoad expression
                      using Cfg3DEN's engine-auto-populated `_value` magic
                      variable. When non-empty this is the highest-priority
                      source - it carries the value the engine de-serialised
                      from the .sqm directly, regardless of which logic
                      variable name the consuming attribute uses. Fixes a
                      cross-consumer varName mismatch where the listbox
                      highlights didn't persist on Eden re-load for any
                      attribute whose `expression` writes to a logic var
                      not named "factions" (insurgentFaction / CQB_FACTIONS
                      / pr_factionWhitelist / skillFactions* etc.). Optional;
                      callers that don't pass it get the legacy logic-var /
                      display.value resolution path.
    _supplementVarName : STRING - optional. The EDITOR PROPERTY name (the full
                      ALiVE_<module>_<attribute> form, NOT the logic variable
                      name) of a companion field on the same module whose
                      contents are ADDED to whatever is ticked here rather than
                      replacing it. Where that field names anything, the runtime
                      has factions to work with and will not fall back, so the
                      _initialDefault pre-tick is stood down and the list is left
                      as the mission maker set it. Read with get3DENAttribute
                      because a plain Edit field with no expression is not a
                      logic variable while the mission is being built. Defaults
                      to "" (no companion field, pre-tick behaves as before).
    _titleStr       : STRING - localised title text or $STR_ key applied to
                      the controlsGroup's Title sub-control (idc 101).
                      Defaults to "Factions:". Each variant's attributeLoad
                      expression passes its own value so the visible label
                      reflects the consuming attribute.
    _tooltipStr     : STRING - localised tooltip text or $STR_ key applied
                      to the Title sub-control's tooltip via ctrlSetTooltip
                      (idc 101). Each variant passes its consuming
                      attribute's $STR_..._COMMENT so hovering the label
                      surfaces the per-attribute description rather than
                      the generic multi-select UX hint inherited from the
                      Base substrate. Optional - empty defers to the
                      Base's hardcoded tooltip.

Author:
Jman
---------------------------------------------------------------------------- */

// ------------------------------------------------------------------------
// Unpack invocation. Variant control classes call:
//   [_display, _allowedSides, _varName, _initialDefault, _value, _title, _tooltip,
//    _supplementVarName] ...
// (where _value is the engine-auto-populated SQM value for the attribute).
// Legacy direct call (just the display) kept compatible.
// ------------------------------------------------------------------------
private _display = controlNull;
private _allowedSides = [0,1,2,3];
private _varName = "factions";
private _initialDefault = [];
private _sqmValue = "";
private _titleStr = "Factions:";
private _tooltipStr = "";
// Optional name of a companion field on the same module that is ADDED to whatever is ticked
// here. Where one is named and holds something, the pre-tick below is stood down. Empty for
// every consumer that has no such field, which is all of them but the AI Commander.
private _supplementVarName = "";
if (typeName _this == "ARRAY") then {
    _display = _this select 0;
    if (count _this > 1 && {typeName (_this select 1) == "ARRAY"}) then {
        _allowedSides = _this select 1;
    };
    if (count _this > 2 && {typeName (_this select 2) == "STRING"} && {(_this select 2) != ""}) then {
        _varName = _this select 2;
    };
    if (count _this > 3 && {typeName (_this select 3) == "ARRAY"}) then {
        _initialDefault = _this select 3;
    };
    if (count _this > 4 && {typeName (_this select 4) == "STRING"}) then {
        _sqmValue = _this select 4;
    };
    if (count _this > 5 && {typeName (_this select 5) == "STRING"} && {(_this select 5) != ""}) then {
        _titleStr = _this select 5;
    };
    if (count _this > 6 && {typeName (_this select 6) == "STRING"}) then {
        _tooltipStr = _this select 6;
    };
    if (count _this > 7 && {typeName (_this select 7) == "STRING"}) then {
        _supplementVarName = _this select 7;
    };
} else {
    _display = _this;
};

// ------------------------------------------------------------------------
// Title text + tooltip. Resolves $STR_ keys via localize. Pattern matches
// fnc_edenTaskTypeChoiceLoad / fnc_edenSideChoiceMultiLoad - the LOAD
// handler sets Title.text + Title.tooltip at runtime so per-attribute
// labels and descriptions survive without per-attribute control variants.
// ------------------------------------------------------------------------
private _titleResolved = _titleStr;
if (count _titleStr > 0 && {(_titleStr select [0, 1]) == "$"}) then {
    _titleResolved = localize (_titleStr select [1]);
};
private _tooltipResolved = _tooltipStr;
if (count _tooltipStr > 0 && {(_tooltipStr select [0, 1]) == "$"}) then {
    _tooltipResolved = localize (_tooltipStr select [1]);
};
if (!isNull _display) then {
    private _titleCtrl = _display controlsGroupCtrl 101;
    if (!isNull _titleCtrl) then {
        _titleCtrl ctrlSetText _titleResolved;
        if (_tooltipResolved != "") then { _titleCtrl ctrlSetTooltip _tooltipResolved; };
    };
};

// ------------------------------------------------------------------------
// 1. Resolve the currently-stored value.
//    Priority: SQM-serialised _value (passed in from attributeLoad's
//              engine-auto-populated `_value`) > logic variable >
//              Eden attribute "value" slot > "" default.
//
//    The SQM source wins because it's the canonical de-serialised value
//    for this specific attribute, independent of how the consuming
//    module names its logic variable. Legacy logic-var path stays as a
//    fallback for callers that don't plumb _value through.
// ------------------------------------------------------------------------
private _selected = get3DENSelected "logic";
private _storedFromLogic = if (count _selected > 0) then {
    (_selected select 0) getVariable [_varName, nil]
} else {
    nil
};
private _edenValue = _display getVariable "value";

private _value = "";
if (!isNil "_edenValue" && {typeName _edenValue == "STRING"} && {_edenValue != ""}) then {
    _value = _edenValue;
};
if (!isNil "_storedFromLogic" && {typeName _storedFromLogic == "STRING"} && {_storedFromLogic != ""}) then {
    _value = _storedFromLogic;  // logic variable wins over display.value
};
if (_sqmValue != "") then {
    _value = _sqmValue;  // SQM auto-populated value wins over both
};

// Defensive: strip surrounding single quotes (same legacy quote-escape
// healing as fnc_edenFactionChoiceLoad - some legacy SQMs accidentally
// wrap the stored value in apostrophes from old defaultValue formats).
private _len = count _value;
if (
    _len >= 2 &&
    {(_value select [0, 1]) == "'"} &&
    {(_value select [_len - 1, 1]) == "'"}
) then {
    _value = _value select [1, _len - 2];
    _len = count _value;
};

// ------------------------------------------------------------------------
// 2. Parse stored value into a list of selected faction classnames.
//    Three forms accepted (see fn header). Output is always an ARRAY
//    of STRINGs (possibly empty).
// ------------------------------------------------------------------------
private _selectedFactions = [];
if (_value != "") then {
    private _trimmed = _value;
    // Trim whitespace - poor-man's trim (SQF has no native trim).
    while {count _trimmed > 0 && {(_trimmed select [0, 1]) == " "}} do {
        _trimmed = _trimmed select [1];
    };
    while {count _trimmed > 0 && {(_trimmed select [count _trimmed - 1, 1]) == " "}} do {
        _trimmed = _trimmed select [0, count _trimmed - 1];
    };

    if (count _trimmed > 0 && {(_trimmed select [0, 1]) == "["}) then {
        // Looks like an SQF array literal - parseSimpleArray.
        // parseSimpleArray returns nil on malformed input (we tolerate that
        // gracefully - empty selection rather than crash).
        private _parsed = parseSimpleArray _trimmed;
        if (typeName _parsed == "ARRAY") then {
            { if (typeName _x == "STRING") then { _selectedFactions pushBack _x } } forEach _parsed;
        };
    } else {
        // Treat as CSV (or single faction). Split on comma, trim each.
        private _parts = [_trimmed, ","] call CBA_fnc_split;
        {
            private _p = _x;
            while {count _p > 0 && {(_p select [0, 1]) == " "}} do { _p = _p select [1] };
            while {count _p > 0 && {(_p select [count _p - 1, 1]) == " "}} do { _p = _p select [0, count _p - 1] };
            if (_p != "") then { _selectedFactions pushBack _p };
        } forEach _parts;
    };
};

// Per-attribute initial-default fallback. Triggered when parsing yielded
// no selection AND the caller passed a non-empty _initialDefault list.
// This catches three flavours of "no current selection":
//   1. Genuinely fresh placement (Eden may or may not have applied the
//      attribute expression to the logic - depends on engine path).
//   2. Eden-default empty literal "[]" written by defaultValue.
//   3. User explicitly unticked everything and saved.
//
// Triggering uniformly across all three is intentional. For consumers
// that pass _initialDefault (mil_opcom factions today), an empty
// selection is functionally equivalent to the runtime fallback - the
// runtime warns + defaults regardless - so the listbox showing what
// the runtime will use is the right UX. Consumers that omit
// _initialDefault (mil_cqb / sup_player_resupply / sys_aiskill /
// amb_civ_population) keep "user can persist empty" semantics
// because the seed never fires for them.
//
// Not, however, when a companion field beside this one already names something. That field is
// added to what is ticked here rather than replacing it, so anything in it means the runtime
// has something to work with and will NOT fall back. Pre-ticking anyway told someone who had
// deselected the default and typed a faction of their own that the default was coming back,
// and because a pre-tick becomes real as soon as the module is saved, it then did: they ended
// up commanding their own faction AND the default. Reported exactly that way.
// Read as an EDITOR ATTRIBUTE, not a logic variable. A plain Edit field with no expression
// never reaches the logic while the mission is being built; its value is applied at mission
// start, which is where the commander itself reads it. Asking the logic for it here always
// answers with nothing, and the test below would never once be true. The same trap is written
// up in fnc_edenTaskTypeChoiceLoad for the control type field, which has the same shape.
// More than one field can be named, separated by commas, because more than one can stop the
// fallback. The commander looks at the field beside this list and, failing that, at four older
// single-faction slots kept so that missions built before this list existed still work. Any of
// them holding a faction means no fallback, so any of them must stand the suggestion down. On a
// mission carried over from those older slots, checking only the field beside the list would
// show the default ticked while the commander quietly ran something else.
private _supplementHasValue = false;
{
    private _supplementProperty = _x;

    // Every module being edited, judged one at a time. Editing several commanders together and
    // reading only the first would suggest a default that is wrong for the rest, and the saving
    // side writes to all of them. Each one is judged where it is read, rather than picking a
    // value out and judging it afterwards: a module whose slot holds NONE would otherwise be
    // taken as the answer for the whole selection, found to say nothing, and hide a real faction
    // held by another. NONE is not a hypothetical value here, it is what the older single
    // faction slots shipped with and it is still sitting in missions built on them.
    {
        private _attr = _x get3DENAttribute _supplementProperty;
        private _raw = if (_attr isEqualType [] && {count _attr > 0}) then { _attr select 0 } else { "" };

        // Judged the same way the commander judges it, so the two cannot disagree. Anything
        // amounting to nothing once brackets, quotes and spaces come off, or saying NONE, is not
        // a faction, and the commander falls back exactly as if the slot were empty. Testing for
        // a bare empty string instead would call NONE a faction, stand the suggestion down, and
        // leave someone looking at an empty list for a commander running the default.
        private _names = [];
        if (_raw isEqualType []) then {
            _names = _raw;
        } else {
            if (_raw isEqualType "") then { _names = [_raw] call ALiVE_fnc_parseArrayFromString };
        };

        {
            if (typeName _x == "STRING") then {
                private _t = _x;
                while {count _t > 0 && {(_t select [0, 1]) == " "}} do { _t = _t select [1] };
                while {count _t > 0 && {(_t select [count _t - 1, 1]) == " "}} do { _t = _t select [0, count _t - 1] };
                if (!(_t in ["", "NONE"])) then { _supplementHasValue = true };
            };
        } forEach _names;

        // One is enough. Written directly in the loop body so it ends the loop, which is the
        // form this file blesses at its head and the form the pickers next door use.
        if (_supplementHasValue) exitWith {};
    } forEach _selected;

    if (_supplementHasValue) exitWith {};
} forEach (if (_supplementVarName == "") then { [] } else { _supplementVarName splitString "," });

if (count _selectedFactions == 0 && {count _initialDefault > 0} && {!_supplementHasValue}) then {
    {
        if (typeName _x == "STRING" && {_x != ""}) then {
            _selectedFactions pushBack _x;
        };
    } forEach _initialDefault;
};

// ------------------------------------------------------------------------
// 3. Locate the ListBox control inside the attribute display (IDC 100).
// ------------------------------------------------------------------------
private _ctrl = _display controlsGroupCtrl 100;
if (isNull _ctrl) exitWith {
    ["ALIVE FactionChoiceMulti LOAD: listbox control (IDC 100) not found"] call ALiVE_fnc_dump;
};

lbClear _ctrl;

// ------------------------------------------------------------------------
// 4. Enumerate factions defensively. Same filter logic as the single-
//    select handler (fnc_edenFactionChoiceLoad): strict side filter +
//    structural CfgGroups usability filter for military sides + civilian
//    blacklist + Cfg3rdPartyFactions registry overrides + inferability
//    check for non-conforming factions (Phase 3c.1 prediction).
//    Civilian factions exempt from CfgGroups check (spawn as individuals).
// ------------------------------------------------------------------------
private _sideCfgGroupsName = ["East", "West", "Indep", "Civilian"];
private _civilianBlacklist = ["virtual_f", "interactive_f"];

// Build registry overrides map from Cfg3rdPartyFactions (same as single-
// select handler).
private _registryOverrides = createHashMap;
private _registry = configFile >> "Cfg3rdPartyFactions";
if (isClass _registry) then {
    for "_i" from 0 to (count _registry - 1) do {
        private _entry = _registry select _i;
        if (isClass _entry) then {
            private _cp = getText (_entry >> "cfgPatchesName");
            if (_cp != "" && {isClass (configFile >> "CfgPatches" >> _cp)}) then {
                private _factionsClass = _entry >> "factions";
                if (isClass _factionsClass) then {
                    for "_j" from 0 to (count _factionsClass - 1) do {
                        private _facOverride = _factionsClass select _j;
                        if (isClass _facOverride) then {
                            private _facCN = configName _facOverride;
                            private _override = createHashMap;
                            if (isText (_facOverride >> "displayName")) then {
                                _override set ["displayName", getText (_facOverride >> "displayName")];
                            };
                            if (isNumber (_facOverride >> "excluded")) then {
                                _override set ["excluded", getNumber (_facOverride >> "excluded") > 0];
                            };
                            _registryOverrides set [toLower _facCN, _override];
                        };
                    };
                };
            };
        };
    };
};

private _seen = createHashMap;
private _entries = [];

private _configPaths = [
    missionConfigFile >> "CfgFactionClasses",
    configFile >> "CfgFactionClasses"
];
{
    private _root = _x;
    for "_i" from 0 to (count _root - 1) do {
        private _fac = _root select _i;
        if (isClass _fac) then {
            private _cn = configName _fac;
            private _cnLower = toLower _cn;
            if !(_cnLower in _seen) then {
                _seen set [_cnLower, true];
                private _side = getNumber (_fac >> "side");
                if !(isNumber (_fac >> "side")) then { _side = -1 };

                if (_side in [0, 1, 2, 3] && {_side in _allowedSides}) then {
                    private _usable = if (_side == 3) then {
                        !(_cnLower in _civilianBlacklist)
                    } else {
                        private _sideName = _sideCfgGroupsName select _side;
                        private _groupsEntry = configFile >> "CfgGroups" >> _sideName >> _cn;
                        if (isClass _groupsEntry && {count _groupsEntry > 0}) then {
                            true
                        } else {
                            // Inferability check (Phase 3c.1): does the faction
                            // have any CfgVehicles Man-class units? If yes,
                            // runtime inference will produce a redirect mapping.
                            private _vehicles = "true" configClasses (configFile >> "CfgVehicles");
                            (_vehicles findIf {
                                (toLower (getText (_x >> "faction"))) == _cnLower &&
                                {(configName _x) isKindOf "Man"}
                            }) >= 0
                        };
                    };
                    if (_usable) then {
                        private _override = _registryOverrides getOrDefault [_cnLower, createHashMap];
                        if !(_override getOrDefault ["excluded", false]) then {
                            private _dn = _override getOrDefault ["displayName", ""];
                            if (_dn isEqualTo "") then {
                                _dn = getText (_fac >> "displayName");
                                if (_dn isEqualTo "") then { _dn = _cn };
                            };
                            _entries pushBack [_cn, _dn, _side];
                        };
                    };
                };
            };
        };
    };
} forEach _configPaths;

// ------------------------------------------------------------------------
// 5. Pre-add unrecognised entries (stored values that don't match any
//    currently-loaded faction). Same UX as single-select - they appear
//    at the TOP labelled "(unrecognised)" so mission-makers immediately
//    see something is missing from their loadout.
// ------------------------------------------------------------------------
private _entriesLowerSet = createHashMap;
{ _entriesLowerSet set [toLower (_x select 0), true] } forEach _entries;

private _unrecognisedTickIdxs = [];
{
    private _selFactionLower = toLower _x;
    if !(_selFactionLower in _entriesLowerSet) then {
        private _idx = _ctrl lbAdd format ["(unrecognised) %1", _x];
        _ctrl lbSetData [_idx, _x];
        _unrecognisedTickIdxs pushBack _idx;
    };
} forEach _selectedFactions;

// ------------------------------------------------------------------------
// 6. Populate listbox grouped by side, sorted alphabetically within each
//    bucket. Same ordering as single-select handler.
// ------------------------------------------------------------------------
private _selectedLowerSet = createHashMap;
{ _selectedLowerSet set [toLower _x, true] } forEach _selectedFactions;

private _sideBuckets = [
    [0, "OPFOR"],
    [1, "BLUFOR"],
    [2, "INDFOR"],
    [3, "CIVILIAN"]
];

private _tickIdxs = +_unrecognisedTickIdxs;

{
    _x params ["_sideValue", "_sideLabel"];
    if !(_sideValue in _allowedSides) then { continue };
    private _bucketEntries = _entries select {
        _x params ["", "", "_s"];
        _s == _sideValue
    };
    _bucketEntries sort true;

    {
        _x params ["_cn", "_dn"];
        private _label = if (_dn == _cn) then {
            format ["%1 - %2", _sideLabel, _dn]
        } else {
            format ["%1 - %2 (%3)", _sideLabel, _dn, _cn]
        };
        private _idx = _ctrl lbAdd _label;
        _ctrl lbSetData [_idx, _cn];
        if ((toLower _cn) in _selectedLowerSet) then {
            _tickIdxs pushBack _idx;
        };
    } forEach _bucketEntries;
} forEach _sideBuckets;

// ------------------------------------------------------------------------
// 7. Apply multi-selection. lbSetSelected (idx, true) ticks each item.
//    For multi-select listboxes (style flag LB_MULTI = 32) this allows
//    multiple items to be selected simultaneously; the user's
//    Ctrl+click / Shift+click then adds/removes from the selection.
// ------------------------------------------------------------------------
{ _ctrl lbSetSelected [_x, true] } forEach _tickIdxs;

// Whatever is ticked here, suggested or chosen, is saved as it stands. Deciding on the way out
// whether a tick was really meant was tried and is a trap: by then the field beside the list may
// have been filled in during the same sitting, and dropping the tick on the strength of what was
// true when the panel opened loses a faction the commander would have used. The decision belongs
// here, once, where it is made against what is actually stored.

// ------------------------------------------------------------------------
// Diagnostic logging - same shape as single-select handler. Helps debug
// "I selected these factions but they didn't stick" issues.
// ------------------------------------------------------------------------
[
    "ALIVE FactionChoiceMulti LOAD: varName='%1' allowedSides=%2 sqm='%3' resolved='%4' parsed=%5 populated=%6 ticked=%7 (incl %8 unrecognised at top)",
    _varName,
    _allowedSides,
    _sqmValue,
    _value,
    _selectedFactions,
    lbSize _ctrl,
    count _tickIdxs,
    count _unrecognisedTickIdxs
] call ALiVE_fnc_dump;
