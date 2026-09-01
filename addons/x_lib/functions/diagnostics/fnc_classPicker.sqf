#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(classPicker);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_classPicker

Description:
Collect classnames by aiming at things in the world, for settings that want a
list of classes typed into them.

Run "start" in the debug console during preview and every object of the wanted
kinds nearby is labelled with its classname. Home collects whatever is under
the crosshair. For a building, End also collects the numbered position under
the crosshair, so a garrison list can be built by looking at the windows to be
filled rather than by counting indices in a config viewer. "copy" puts the
finished list on the clipboard in whichever form the target setting wants.

The settings this serves take three different shapes, so there is one
collection and three renderers rather than three tools:

    flat            Class1,Class2       an Eden text field
    sqfArray        ["Class1","Class2"] a global pasted into init.sqf
    classIndexPairs Class=1,2;Class2=0  preferredGarrisonPositions

Classnames are stored in the capitalisation CfgVehicles declares, NOT folded.
That is not cosmetic. Most consumers test membership with "in", which compares
strings case sensitively, so a folded name silently matches nothing and the
setting appears to do nothing at all. typeOf reports whatever spelling the
object was created with, so every capture goes through configName to get back
the declared one.

Aiming at a soldier also recovers the CfgGroups class of the group he was
spawned from, for the group blacklists, since no world object is a group and
there is otherwise nothing to aim at.

Parameters:
    _operation : STRING - "start", "stop", "toggleTarget", "toggleIndex",
                          "render", "copy", "clear"
    _args      : ANY    - per operation, see below

    "start"  - [_kinds, _radius, _wantIndices], all optional.
               _kinds is "buildings", "vehicles", "units" or an array of
               config roots to match, e.g. ["House","Land_Cargo_HQ_V1_F"].
               Anything inheriting from a named root matches.
    "render" - mode string, one of the three above, or "groups"
    "copy"   - as "render"

Returns:
    STRING for "render" and "copy", handler id for "start", nothing otherwise.

Examples:
(begin example)
// garrison positions
["start"] call ALIVE_fnc_classPicker;
// ... aim at buildings, Home to take one, End to take a position in it
["copy", "classIndexPairs"] call ALIVE_fnc_classPicker;

// vehicles to keep out of a mission
["start", ["vehicles", 100]] call ALIVE_fnc_classPicker;
["copy", "sqfArray"] call ALIVE_fnc_classPicker;
(end)

See Also:
- <ALIVE_fnc_resolvePreferredGarrisonPositions>
- <ALIVE_fnc_cursorTargetInfo>

Author:
Jman
---------------------------------------------------------------------------- */

params [["_operation", "", [""]]];
private _args = param [1, []];

private _result = nil;

// Held above the switch rather than inside "start", so that copying or stopping
// before anything has been started answers with an empty list instead of an
// undefined variable. A preview restart clears these along with everything else.
if (isNil "ALIVE_classPicker_classes") then { ALIVE_classPicker_classes = [] };
if (isNil "ALIVE_classPicker_groups")  then { ALIVE_classPicker_groups  = [] };
if (isNil "ALIVE_classPicker_indices") then { ALIVE_classPicker_indices = [] call ALiVE_fnc_hashCreate };
if (isNil "ALIVE_classPicker_lastHover") then { ALIVE_classPicker_lastHover = objNull };

// Text is drawn outlined in a bold face, because a thin light label over a
// bright sky cannot be read at all. The sizes are left settable so they can be
// tuned live against whatever happens to be behind them, without a rebuild:
//     ALIVE_classPicker_indexSize = 0.08;
if (isNil "ALIVE_classPicker_labelSize") then { ALIVE_classPicker_labelSize = 0.042 };
if (isNil "ALIVE_classPicker_indexSize") then { ALIVE_classPicker_indexSize = 0.060 };
if (isNil "ALIVE_classPicker_font")      then { ALIVE_classPicker_font      = "PuristaBold" };

switch (toLower _operation) do {

    case "start": {

        // Nothing here draws or reads keys without a screen to do it on.
        if !(hasInterface) exitWith {
            ["ALIVE_fnc_classPicker - no interface on this machine, nothing to draw"] call ALiVE_fnc_dump;
        };

        if !(isNil "ALIVE_classPicker_EH_Draw3D") exitWith {
            ["ALIVE_fnc_classPicker - already running"] call ALiVE_fnc_dump;
            hintSilent "ALiVE class picker\n\nAlready running.\nStop it with [""stop""] call ALIVE_fnc_classPicker";
        };

        if !(_args isEqualType []) then { _args = [_args] };
        // Several config roots given as one list is the documented form, and read
        // as [kinds, radius, indices] it would keep the first and quietly drop the
        // rest. Nothing but classnames in the list means the list IS the kinds.
        if (count _args > 1 && {(_args findIf { !(_x isEqualType "") }) == -1}) then { _args = [_args] };

        _args params [["_kinds", "buildings", ["", []]], ["_radius", 75, [0]], ["_wantIndices", true, [true]]];

        // Naming the config roots is the flexible form but it is also the form
        // that fails silently when the root is wrong, so the three kinds worth
        // picking have names.
        if (_kinds isEqualType "") then {
            _kinds = switch (toLower _kinds) do {
                case "buildings": { ["House"] };
                case "vehicles":  { ["LandVehicle", "Air", "Ship"] };
                case "units":     { ["CAManBase"] };
                default {
                    // Not one of the names, so a real class is taken as a root of
                    // its own and anything else is a typo worth saying so about.
                    if (isClass (configFile >> "CfgVehicles" >> _kinds)) then { [_kinds] } else { [] };
                };
            };
        };
        if (_kinds isEqualTo []) exitWith {
            ["ALIVE_fnc_classPicker - unknown kind, expected ""buildings"", ""vehicles"", ""units"", or a CfgVehicles class"] call ALiVE_fnc_dump;
            hintSilent "ALiVE class picker\n\nUnknown kind.\nUse ""buildings"", ""vehicles"" or ""units"".";
        };

        ALIVE_classPicker_opts = [_kinds, _radius, _wantIndices];
        ALIVE_classPicker_cache = [-1, []];

        ALIVE_classPicker_EH_Draw3D = addMissionEventHandler ["Draw3D", {

            ALIVE_classPicker_opts params ["_kinds", "_radius", "_wantIndices"];
            ALIVE_classPicker_cache params ["_nextScan", "_candidates"];

            // Only the sweep is throttled. Drawing has to run every frame or
            // the labels strobe. The classname and the height to float the label
            // at never change for a given object, so both are worked out here
            // rather than several hundred times a frame. The position itself is
            // not cached, because vehicles and men move between sweeps.
            if (diag_tickTime > _nextScan) then {
                private _found = [];
                { _found append (player nearObjects [_x, _radius]) } forEach _kinds;
                // Overlapping roots return the same object more than once, and a
                // twice drawn label is visibly bolder than its neighbours.
                _found = _found arrayIntersect _found;

                _candidates = [];
                {
                    // The declared spelling, not the spelling this object happens
                    // to have been created with, so the label matches what gets
                    // collected and the green highlight below can find it.
                    private _cfg = configFile >> "CfgVehicles" >> typeOf _x;
                    if (isClass _cfg) then {
                        _candidates pushBack [_x, configName _cfg, (((boundingBoxReal _x) select 1 select 2) max 1.5) + 0.4];
                    };
                } forEach _found;

                ALIVE_classPicker_cache = [diag_tickTime + 1, _candidates];
            };

            private _hover = ["hover"] call ALIVE_fnc_classPicker;

            // Remembered every frame so that something firing from a menu can act
            // on what was last being looked at. A menu takes the mouse to select
            // with, and the crosshair cannot be trusted to still resolve by the
            // time the entry is chosen.
            if !(isNull _hover) then { ALIVE_classPicker_lastHover = _hover };

            {
                _x params ["_obj", "_class", "_zOffset"];

                private _pos = _obj modelToWorldVisual [0, 0, _zOffset];

                // An icon off the side of the screen still costs a full draw, and
                // a busy village has hundreds of them.
                if !((worldToScreen _pos) isEqualTo []) then {
                    private _color = [1, 1, 1, 1];
                    if (_class in ALIVE_classPicker_classes) then { _color = [0.3, 1, 0.3, 1] };
                    if (_obj isEqualTo _hover) then { _color = [1, 0.8, 0, 1] };

                    drawIcon3D ["", _color, _pos, 0, 0, 0, _class, 2, ALIVE_classPicker_labelSize, ALIVE_classPicker_font];
                };
            } forEach _candidates;

            // Position numbers, for the building actually being looked at.
            if (_wantIndices && {!isNull _hover} && {_hover isKindOf "House"}) then {
                // Folded the same way the collection is keyed, or a building whose
                // spelling differs from the config's would show every position it
                // already holds as untaken.
                private _hoverClass = configName (configFile >> "CfgVehicles" >> typeOf _hover);
                private _picked = [ALIVE_classPicker_indices, _hoverClass, []] call ALiVE_fnc_hashGet;
                if (isNil "_picked" || {!(_picked isEqualType [])}) then { _picked = [] };
                {
                    // The seating code refuses a position reading as the world
                    // origin, so offering one here would be offering a seat
                    // nobody can take.
                    if !(_x isEqualTo [0,0,0]) then {
                        // Drawn larger than the classnames because the number is
                        // the thing being aimed at, not just read.
                        private _col = if (_forEachIndex in _picked) then { [0.3, 1, 0.3, 1] } else { [1, 0.25, 0.25, 1] };
                        drawIcon3D ["", _col, _x, 0, 0, 0, str _forEachIndex, 2, ALIVE_classPicker_indexSize, ALIVE_classPicker_font];
                    };
                } forEach (_hover buildingPos -1);
            };
        }];

        ALIVE_classPicker_EH_KeyDown = ["KeyDown", {
            switch (_this select 1) do {
                case 199: { ["toggleTarget"] call ALIVE_fnc_classPicker; true };  // Home
                case 207: { ["toggleIndex"]  call ALIVE_fnc_classPicker; true };  // End
                default  { false };
            };
        }] call CBA_fnc_addDisplayHandler;

        ["ALIVE_fnc_classPicker - started on %1 within %2m, position numbers %3", _kinds, _radius, ["off", "on"] select _wantIndices] call ALiVE_fnc_dump;
        ["review"] call ALIVE_fnc_classPicker;

        _result = ALIVE_classPicker_EH_Draw3D;
    };

    case "stop": {

        // Each handler is removed by its own id. Draw3D is a list and KeyDown is
        // CBA's, so neither teardown can disturb anything else that is drawing
        // or reading keys.
        if !(isNil "ALIVE_classPicker_EH_Draw3D") then {
            removeMissionEventHandler ["Draw3D", ALIVE_classPicker_EH_Draw3D];
            ALIVE_classPicker_EH_Draw3D = nil;
        };
        if !(isNil "ALIVE_classPicker_EH_KeyDown") then {
            ["KeyDown", ALIVE_classPicker_EH_KeyDown] call CBA_fnc_removeDisplayHandler;
            ALIVE_classPicker_EH_KeyDown = nil;
        };

        // The sweep holds a few hundred object references and is worthless once
        // the drawing has gone. The remembered target goes with it, so that a
        // menu entry cannot act on something looked at before the last stop.
        ALIVE_classPicker_cache = nil;
        ALIVE_classPicker_lastHover = objNull;

        private _held = count ALIVE_classPicker_classes;

        // The list outlives the drawing on purpose, so stopping and then copying
        // works, and so does stopping to walk somewhere and starting again.
        ["ALIVE_fnc_classPicker - stopped, %1 class(es) still held", _held] call ALiVE_fnc_dump;
        hintSilent format ["ALiVE class picker\n\nStopped. %1 class(es) still held.\n\n[""copy"", ""flat""] call ALIVE_fnc_classPicker", _held];
    };

    // Where the crosshair is pointing. cursorObject is the geometric lookup and
    // is the only one that resolves map placed buildings, but it reports the
    // p3d of a soldier's rifle rather than the soldier, so anything it returns
    // that is not a wanted kind gives way to cursorTarget.
    case "hover": {

        private _kinds = if (isNil "ALIVE_classPicker_opts") then { [] } else { ALIVE_classPicker_opts select 0 };

        private _wanted = {
            private _obj = _this;
            if (isNull _obj) exitWith { false };
            private _ok = false;
            { if (_obj isKindOf _x) exitWith { _ok = true } } forEach _kinds;
            _ok
        };

        // Nothing of a wanted kind under the crosshair means nothing under the
        // crosshair. Handing back an object of the wrong kind would let Home put
        // a house into a vehicle list.
        private _hover = cursorObject;
        if !(_hover call _wanted) then {
            private _alt = cursorTarget;
            _hover = if (_alt call _wanted) then { _alt } else { objNull };
        };

        _result = _hover;
    };

    case "toggletarget": {

        private _target = ["hover"] call ALIVE_fnc_classPicker;
        // Fired from a menu, the mouse has been taken to choose the entry and the
        // crosshair may no longer resolve, so the last thing looked at stands in.
        if (isNull _target) then { _target = ALIVE_classPicker_lastHover };
        if (isNull _target) exitWith {};

        // typeOf reports the spelling the object was made with. The config is
        // the only place the declared spelling can be had, and the consumers
        // compare case sensitively.
        private _cfg = configFile >> "CfgVehicles" >> typeOf _target;
        if !(isClass _cfg) exitWith {
            ["ALIVE_fnc_classPicker - %1 is not a CfgVehicles class, nothing to collect", typeOf _target] call ALiVE_fnc_dump;
        };
        private _class = configName _cfg;

        if (_class in ALIVE_classPicker_classes) then {
            ALIVE_classPicker_classes deleteAt (ALIVE_classPicker_classes find _class);
            [ALIVE_classPicker_indices, _class, []] call ALiVE_fnc_hashSet;
        } else {
            ALIVE_classPicker_classes pushBack _class;
        };

        // A man is also a way to reach the group template he came from, which
        // has no world object of its own to aim at.
        if (_target isKindOf "CAManBase") then { ["group", _target] call ALIVE_fnc_classPicker };

        ["review"] call ALIVE_fnc_classPicker;
    };

    case "toggleindex": {

        private _target = ["hover"] call ALIVE_fnc_classPicker;
        if (isNull _target) then { _target = ALIVE_classPicker_lastHover };
        if (isNull _target || {!(_target isKindOf "House")}) exitWith {};

        private _cfg = configFile >> "CfgVehicles" >> typeOf _target;
        if !(isClass _cfg) exitWith {};
        private _class = configName _cfg;

        // Whichever number is nearest the middle of the screen is the one being
        // read, so that is the one taken. Aiming at the label is the selection.
        private _all = _target buildingPos -1;
        private _best = -1;
        private _bestDist = 1e9;
        {
            if !(_x isEqualTo [0,0,0]) then {
                private _s = worldToScreen _x;
                if !(_s isEqualTo []) then {
                    private _dx = (_s select 0) - 0.5;
                    private _dy = (_s select 1) - 0.5;
                    private _d = sqrt ((_dx * _dx) + (_dy * _dy));
                    if (_d < _bestDist) then { _bestDist = _d; _best = _forEachIndex };
                };
            };
        } forEach _all;

        if (_best < 0) exitWith {
            hintSilent "ALiVE class picker\n\nNo position in view.\nLook at one of the numbers.";
        };

        // Taking a position implies taking the building it is in.
        if !(_class in ALIVE_classPicker_classes) then { ALIVE_classPicker_classes pushBack _class };

        // hashGet hands back the stored array itself, so the copy is what gets
        // edited rather than the hash's own value.
        private _picked = [ALIVE_classPicker_indices, _class, []] call ALiVE_fnc_hashGet;
        if (isNil "_picked" || {!(_picked isEqualType [])}) then { _picked = [] };
        _picked = +_picked;

        if (_best in _picked) then {
            _picked deleteAt (_picked find _best);
        } else {
            // Press order is kept. The list is a filling order, not a set.
            _picked pushBack _best;
        };
        [ALIVE_classPicker_indices, _class, _picked] call ALiVE_fnc_hashSet;

        ["review"] call ALIVE_fnc_classPicker;
    };

    // The CfgGroups class behind a spawned soldier. Every unit ALiVE spawns
    // carries the profile id of its GROUP, so any man in the group answers for
    // the whole group.
    case "group": {

        private _unit = _args;
        if (!(_unit isEqualType objNull) || {isNull _unit}) exitWith {};

        private _profileID = _unit getVariable ["profileID", ""];
        if (_profileID == "") exitWith {};

        // The handler is only ever created where isServer, so a dedicated
        // client has no way to answer this. Preview and hosted are both fine.
        if (isNil "ALIVE_profileHandler") exitWith {
            ["ALIVE_fnc_classPicker - no profile handler on this machine, group class unavailable"] call ALiVE_fnc_dump;
        };

        private _profile = [ALIVE_profileHandler, "getProfile", _profileID] call ALIVE_fnc_profileHandler;
        if (isNil "_profile") exitWith {};

        private _groupClass = [_profile, "objectType"] call ALiVE_fnc_hashGet;
        if (isNil "_groupClass" || {!(_groupClass isEqualType "")} || {_groupClass == ""} || {_groupClass == "inf"}) exitWith {};

        // Not every profile carries a real config class here. A faction built by
        // the faction compiler stores its own made up group id in the same
        // field, and that id names nothing in CfgGroups, so blacklisting it
        // would do nothing at all. Only check when the group config is already
        // built, because building it takes long enough to look like a freeze.
        private _isConfigClass = true;
        if !(isNil "ALIVE_groupConfig") then {
            private _faction = [_profile, "faction"] call ALiVE_fnc_hashGet;
            if (!isNil "_faction" && {_faction isEqualType ""}) then {
                private _cfg = [_faction, _groupClass] call ALIVE_fnc_configGetGroup;
                if (!(_cfg isEqualType configFile) || {!(isClass _cfg)}) then {
                    _isConfigClass = false;
                    ["ALIVE_fnc_classPicker - '%1' is not a CfgGroups class for faction %2, it is a compiled faction's own id and cannot be blacklisted", _groupClass, _faction] call ALiVE_fnc_dump;
                    hintSilent format ["ALiVE class picker\n\n%1\ncomes from a compiled faction, not from CfgGroups.\nIt cannot be used in a group blacklist.", _groupClass];
                };
            };
        };
        if !(_isConfigClass) exitWith {};

        if (_groupClass in ALIVE_classPicker_groups) then {
            ALIVE_classPicker_groups deleteAt (ALIVE_classPicker_groups find _groupClass);
        } else {
            ALIVE_classPicker_groups pushBack _groupClass;
        };
    };

    // The running list, redrawn after every change. A developer needs to see
    // what has been taken so far without opening anything.
    case "review": {

        private _lines = [];
        {
            private _idx = [ALIVE_classPicker_indices, _x, []] call ALiVE_fnc_hashGet;
            if (isNil "_idx" || {!(_idx isEqualType [])}) then { _idx = [] };
            if (_idx isEqualTo []) then {
                _lines pushBack _x;
            } else {
                _lines pushBack format ["%1 = %2", _x, _idx joinString ","];
            };
        } forEach ALIVE_classPicker_classes;

        private _body = if (_lines isEqualTo []) then { "nothing taken yet" } else { _lines joinString "\n" };
        private _groups = if (ALIVE_classPicker_groups isEqualTo []) then { "" } else {
            format ["\n\ngroups\n%1", ALIVE_classPicker_groups joinString "\n"]
        };

        hintSilent format ["ALiVE class picker\n\n%1%2\n\nHome  take what you are looking at\nEnd   take the position you are looking at", _body, _groups];
    };

    case "render": {

        private _mode = if (_args isEqualType "") then { toLower _args } else { "flat" };

        _result = switch (_mode) do {

            case "classindexpairs": {
                private _parts = [];
                {
                    private _idx = [ALIVE_classPicker_indices, _x, []] call ALiVE_fnc_hashGet;
                    if (isNil "_idx" || {!(_idx isEqualType [])}) then { _idx = [] };
                    // A building with no positions taken would render as
                    // "Class=", which the resolver rejects as malformed.
                    if !(_idx isEqualTo []) then {
                        _parts pushBack format ["%1=%2", _x, _idx joinString ","];
                    };
                } forEach ALIVE_classPicker_classes;
                _parts joinString ";"
            };

            case "groups":   { str ALIVE_classPicker_groups };
            case "sqfarray": { str ALIVE_classPicker_classes };
            default          { ALIVE_classPicker_classes joinString "," };
        };
    };

    case "copy": {

        private _string = ["render", _args] call ALIVE_fnc_classPicker;
        copyToClipboard _string;

        private _mode = if (_args isEqualType "") then { toLower _args } else { "flat" };
        private _count = if (_mode == "groups") then { count ALIVE_classPicker_groups } else { count ALIVE_classPicker_classes };

        private _note = "";
        if (_mode == "classindexpairs") then {
            private _empty = 0;
            {
                private _idx = [ALIVE_classPicker_indices, _x, []] call ALiVE_fnc_hashGet;
                if (isNil "_idx" || {!(_idx isEqualType [])} || {_idx isEqualTo []}) then { _empty = _empty + 1 };
            } forEach ALIVE_classPicker_classes;
            if (_empty > 0) then {
                _note = format ["\n%1 building(s) with no positions taken were left out.", _empty];
            };
        };

        ["ALIVE_fnc_classPicker - copied %1 entr(ies) as %2: %3", _count, _mode, _string] call ALiVE_fnc_dump;
        hintSilent format ["ALiVE class picker\n\n%1 entr(ies) copied to the clipboard.%2\n\n%3", _count, _note, _string];

        _result = _string;
    };

    case "clear": {
        ALIVE_classPicker_classes = [];
        ALIVE_classPicker_groups = [];
        ALIVE_classPicker_indices = [] call ALiVE_fnc_hashCreate;
        ["ALIVE_fnc_classPicker - list emptied"] call ALiVE_fnc_dump;
        ["review"] call ALIVE_fnc_classPicker;
    };

    default {
        ["ALIVE_fnc_classPicker - unknown operation '%1'", _operation] call ALiVE_fnc_dump;
    };
};

// Most operations never set a result, and reading a variable that was assigned
// nil raises an undefined variable error rather than returning nothing. Guarded
// the way the other dispatch functions here guard it.
if (isNil "_result") then { nil } else { _result }
