#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(storeFile);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_storeFile

Description:
Where a mission's Local saves are kept: the mission's own save file (missionProfileNamespace,
<mission>.vars beside the profile) or, as before, the profile file every mission shares.
Saving the shared file rewrites every mission's saves in it, so a mission writing only its own
file pauses the server for less on each autosave.

The mission's own file is used when the server setting ALiVE_storeMissionFile is on (the default).
A save that cannot be written there (in Eden, or when the game turns it down) goes to the
shared file instead, as before. Until a later session has loaded a save back from the mission's
own file, every save is written to the shared file too, so a save is never lost to a first
write that failed; once loaded back and saved again, the shared copy is removed. Each copy
carries the time it was written, and a load takes the newer one. Server only.

Parameters:
String - what to do:
    "get" - the saved store under a name, from whichever file has the newer copy (nil if none)
    "set" - put a store under a name (written at the next "save")
    "save" - write the files now, or, during an autosave's one-frame save, once at its end
    "flush" - write the files now
    "delete" - remove a name from both files (written at the next "save")
    "wipeAll" - mark every mission's own file as wiped (Wipe ALL cannot reach other missions' files)
    "hold" - stop later "set"s for a name until the mission restarts, so a save that was just cleared
             is not written straight back by the next autosave, a player leaving or the mission ending.
             With slot names, only those slots are left out of what is written; with none, nothing is.
String - the name (for get, set, delete, hold)
Any - the store (for set), or an array of slot names (for hold, optional)

Returns:
The store for "get", nothing otherwise

Examples:
(begin example)
private _store = ["get", _missionKey] call ALiVE_fnc_storeFile;
["set", _missionKey, _store] call ALiVE_fnc_storeFile;
["save"] call ALiVE_fnc_storeFile;
(end)

See Also:
ALiVE_fnc_storeKeys, ALiVE_fnc_ProfileNameSpaceWipe

Author:
Jman
---------------------------------------------------------------------------- */

params [["_op", "", [""]], ["_key", "", [""]], "_value"];

if (!isServer) exitWith {};

#define STAMP(k) (k + "|written")
#define WIPED(k) (k + "|wipes")
#define WIPE_COUNT "ALiVE_storeWipes"
#define VERIFIED "ALiVE_storeLoadedBack"
#define WORKS "ALiVE_storeOwnFileWorks"

private _useMission = (missionNamespace getVariable ["ALiVE_storeMissionFile", true]) isEqualTo true && {!is3DEN};

// true when stamp _a (systemTimeUTC) is later than _b; no stamp is the oldest
private _fnc_later = {
    params ["_a", "_b"];
    if !(_a isEqualType [] && {count _a == 7}) exitWith { false };
    if !(_b isEqualType [] && {count _b == 7}) exitWith { true };
    private _later = false;
    for "_i" from 0 to 6 do {
        if ((_a select _i) != (_b select _i)) exitWith { _later = (_a select _i) > (_b select _i) };
    };
    _later
};

private _result = nil;

switch (_op) do {

    case "get": {
        private _shared = profileNamespace getVariable _key;
        if (!isNil "_shared" && {!([_shared] call ALiVE_fnc_isHash)}) then { _shared = nil };
        private _own = nil;
        if (_useMission) then {
            _own = missionProfileNamespace getVariable _key;
            // a Wipe ALL since it was written wiped it too
            if (!isNil "_own" && {!([_own] call ALiVE_fnc_isHash) || {(missionProfileNamespace getVariable [WIPED(_key), 0]) < (profileNamespace getVariable [WIPE_COUNT, 0])}}) then { _own = nil };
        };

        private _from = "nothing saved yet";
        if (!isNil "_own" && {isNil "_shared" || {!([profileNamespace getVariable [STAMP(_key), []], missionProfileNamespace getVariable [STAMP(_key), []]] call _fnc_later)}}) then {
            _result = _own;
            _from = "the mission's own save file";
            // Proven readable: the shared copy goes at the next save that writes this file. Only a copy
            // read back in a later session counts, not one this session wrote itself.
            if !(_key in (missionNamespace getVariable ["ALiVE_storeFile_written", createHashMap])) then {
                private _loaded = missionNamespace getVariable ["ALiVE_storeFile_loaded", createHashMap];
                _loaded set [_key, true];
                missionNamespace setVariable ["ALiVE_storeFile_loaded", _loaded];
            };
        } else {
            if (!isNil "_shared") then {
                _result = _shared;
                _from = if (_useMission) then { "the shared profile file (kept there too until it has loaded back from the mission's own save file)" } else { "the shared profile file" };
            };
        };

        private _told = missionNamespace getVariable ["ALiVE_storeFile_told", createHashMap];
        if !(_key in _told) then {
            _told set [_key, true];
            missionNamespace setVariable ["ALiVE_storeFile_told", _told];
            ["[ALiVE Data] Saved data %1 loaded from %2", _key, _from] call ALiVE_fnc_dump;
        };
    };

    case "hold": {
        private _held = missionNamespace getVariable ["ALiVE_storeFile_held", createHashMap];
        private _slots = if (isNil "_value" || {!(_value isEqualType [])}) then { [] } else { _value };
        private _was = _held getOrDefault [_key, nil];
        // the whole name held stays held; otherwise the slots add up
        if (isNil "_was" || {_slots isEqualTo []}) then {
            _held set [_key, +_slots];
        } else {
            if (_was isNotEqualTo []) then { _held set [_key, _was + (_slots - _was)] };
        };
        missionNamespace setVariable ["ALiVE_storeFile_held", _held];
    };

    case "set": {
        // held since a clear (see "hold"): nothing, or the store without the held slots
        private _held = (missionNamespace getVariable ["ALiVE_storeFile_held", createHashMap]) getOrDefault [_key, nil];
        if (!isNil "_held") then {
            if (_held isEqualTo []) then { _value = nil } else {
                if ([_value] call ALiVE_fnc_isHash) then {
                    _value = +_value;
                    { [_value, _x] call ALiVE_fnc_hashRem } forEach _held;
                };
            };
        };
        if (isNil "_value") exitWith {};
        private _stamp = systemTimeUTC;
        private _sharedToo = true;
        if (_useMission) then {
            missionProfileNamespace setVariable [_key, _value];
            missionProfileNamespace setVariable [STAMP(_key), _stamp];
            missionProfileNamespace setVariable [WIPED(_key), profileNamespace getVariable [WIPE_COUNT, 0]];
            ALiVE_storeFile_dirtyOwn = true;
            private _written = missionNamespace getVariable ["ALiVE_storeFile_written", createHashMap];
            _written set [_key, true];
            missionNamespace setVariable ["ALiVE_storeFile_written", _written];
            // Once this mission's own file has loaded back in an earlier session, it is known to work here, so a
            // name saved for the first time (after a fresh start or a clear) goes to it alone: the copy in the
            // shared file cost about half a second more on each first save of a large mission.
            _sharedToo = !(_key in (missionProfileNamespace getVariable [VERIFIED, []])) && {!(missionProfileNamespace getVariable [WORKS, false])};
        };
        if (_sharedToo) then {
            profileNamespace setVariable [_key, _value];
            profileNamespace setVariable [STAMP(_key), _stamp];
            ALiVE_storeFile_dirtyShared = true;
        };
    };

    case "delete": {
        { _x setVariable [_key, nil]; _x setVariable [STAMP(_key), nil] } forEach ([profileNamespace] + (if (_useMission) then {[missionProfileNamespace]} else {[]}));
        ALiVE_storeFile_dirtyShared = true;
        if (_useMission) then {
            missionProfileNamespace setVariable [WIPED(_key), nil];
            private _verified = missionProfileNamespace getVariable [VERIFIED, []];
            if (_key in _verified) then { missionProfileNamespace setVariable [VERIFIED, _verified - [_key]] };
            ALiVE_storeFile_dirtyOwn = true;
        };
    };

    case "wipeAll": {
        profileNamespace setVariable [WIPE_COUNT, (profileNamespace getVariable [WIPE_COUNT, 0]) + 1];
        ALiVE_storeFile_dirtyShared = true;
        if (_useMission) then {
            // whether the file works here is kept: cleared saves are still saved to it alone
            { missionProfileNamespace setVariable [_x, nil] } forEach ((allVariables missionProfileNamespace) select { "alive" in toLower _x && {_x != toLower WORKS} });
            ALiVE_storeFile_dirtyOwn = true;
        };
    };

    case "save": {
        // an autosave writes the files once, after its last module (fnc_autosave.sqf)
        if ((missionNamespace getVariable ["ALIVE_PNS_HOLD_FRAME", -1]) == diag_frameNo) then {
            ALIVE_PNS_HOLD_DIRTY = true;
        } else {
            ["flush"] call ALiVE_fnc_storeFile;
        };
    };

    case "flush": {
        if (missionNamespace getVariable ["ALiVE_storeFile_dirtyOwn", false]) then {
            ALiVE_storeFile_dirtyOwn = false;
            private _verified = missionProfileNamespace getVariable [VERIFIED, []];
            // names loaded back from this file this session, written to it again now: their shared copy can go
            private _loaded = (keys (missionNamespace getVariable ["ALiVE_storeFile_loaded", createHashMap])) select {
                !(_x in _verified) && {!isNil {missionProfileNamespace getVariable _x}}
            };
            if (_loaded isNotEqualTo []) then {
                missionProfileNamespace setVariable [VERIFIED, _verified + _loaded];
                missionProfileNamespace setVariable [WORKS, true];
            };

            private _w = diag_tickTime;
            private _ok = saveMissionProfileNamespace;
            ALiVE_storeFile_writeSplit = format ["own file %1 ms", round ((diag_tickTime - _w) * 1000)];
            if (_ok) then {
                {
                    if (!isNil {profileNamespace getVariable _x}) then {
                        profileNamespace setVariable [_x, nil];
                        profileNamespace setVariable [STAMP(_x), nil];
                        ALiVE_storeFile_dirtyShared = true;
                        ["[ALiVE Data] Saved data %1 has loaded back from the mission's own save file, so it is now kept there only", _x] call ALiVE_fnc_dump;
                    };
                } forEach _loaded;
                missionNamespace setVariable ["ALiVE_storeFile_loaded", createHashMap];
            } else {
                // not written: everything put in it this session goes to the shared file instead
                missionProfileNamespace setVariable [VERIFIED, _verified];
                {
                    profileNamespace setVariable [_x, missionProfileNamespace getVariable _x];
                    profileNamespace setVariable [STAMP(_x), missionProfileNamespace getVariable STAMP(_x)];
                } forEach (keys (missionNamespace getVariable ["ALiVE_storeFile_written", createHashMap]));
                ALiVE_storeFile_dirtyShared = true;
                if (isNil "ALiVE_storeFile_toldFailed") then {
                    ALiVE_storeFile_toldFailed = true;
                    ["[ALiVE Data] The mission's own save file could not be written (isMissionProfileNamespaceLoaded %1), so saves go to the shared profile file", isMissionProfileNamespaceLoaded] call ALiVE_fnc_dump;
                };
            };
        };
        if (missionNamespace getVariable ["ALiVE_storeFile_dirtyShared", false]) then {
            ALiVE_storeFile_dirtyShared = false;
            private _w = diag_tickTime;
            saveProfileNamespace;
            // how long each file took, for the autosave's AUTOSAVE event
            private _prev = missionNamespace getVariable ["ALiVE_storeFile_writeSplit", ""];
            ALiVE_storeFile_writeSplit = (if (_prev == "") then { "" } else { _prev + ", " }) + format ["shared profile file %1 ms", round ((diag_tickTime - _w) * 1000)];
        };
    };
};

if (isNil "_result") exitWith {};
_result
