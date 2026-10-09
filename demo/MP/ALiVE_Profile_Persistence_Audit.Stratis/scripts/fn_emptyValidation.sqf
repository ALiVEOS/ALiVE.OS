// Exercise actual loaders against their real PNS read boundaries. Only this
// test mission's namespace entries are temporarily changed, then restored.
private _legacyKey = format ["ALiVE_%1_%2", missionName, worldName];
private _legacyExisted = !isNil {profileNamespace getVariable _legacyKey};
private _legacyOriginal = profileNamespace getVariable [_legacyKey, false];
private _normalOriginal = +(profileNamespace getVariable PA_missionKey);
private _hadLoadTime = !isNil "ALiVE_sysProfileLastLoadTime";
private _loadTime = missionNamespace getVariable ["ALiVE_sysProfileLastLoadTime", 0];

{
    _x params ["_label", "_storeKey", "_moduleKey", "_loader"];
    {
        private _case = _x;
        [ALIVE_profileHandler, "reset"] call ALIVE_fnc_profileHandler;
        private _seed = [["B_Soldier_TL_F"], "WEST", "BLU_F", [1810, 5500, 0],
            0, "", false, "PA_empty_validation", false, "PRIVATE",
            [[1810, 5500, 0]]] call ALIVE_fnc_createProfileEntity;
        private _seedID = [_seed, "profileID"] call ALIVE_fnc_hashGet;
        private _payload = [];
        switch (_case) do {
            case "missing": {};
            case "short array": {_payload = ["#CBA_HASH#"]};
            case "wrong marker": {_payload = ["not a CBA hash", [], [], nil]};
            case "non-array values": {_payload = ["#CBA_HASH#", [], true, nil]};
            case "misaligned keys": {_payload = ["#CBA_HASH#", ["orphan"], [], nil]};
            case "empty": {_payload = [] call ALIVE_fnc_hashCreate};
            case "populated": {
                _payload = [ALIVE_profileHandler, "exportProfileData"] call ALIVE_fnc_profileHandler;
                // Different saved/live classes prove that the populated save
                // was imported, rather than merely leaving the seed in place.
                private _savedSeed = [_payload, _seedID] call ALIVE_fnc_hashGet;
                [_savedSeed, "unitClasses", ["B_Soldier_F"]] call ALIVE_fnc_hashSet;
            };
        };
        private _store = [] call ALIVE_fnc_hashCreate;
        if (_case != "missing") then {
            [_store, _moduleKey, _payload] call ALIVE_fnc_hashSet;
        };
        profileNamespace setVariable [_storeKey, _store];
        ALIVE_loadProfilesPersistent = true;
        ALiVE_sysProfileLastLoadTime = nil;
        call _loader;

        private _valid = _case in ["empty", "populated"];
        [format ["%1 loader / %2: persistence decision", _label, _case],
            ALIVE_loadProfilesPersistent isEqualTo _valid, _valid,
            ALIVE_loadProfilesPersistent] call PA_fnc_assert;
        private _restored = [ALIVE_profileHandler, "getProfile", _seedID] call ALIVE_fnc_profileHandler;
        private _seedShouldExist = _case != "empty";
        [format ["%1 loader / %2: seed retained or cleared", _label, _case],
            (!isNil "_restored") isEqualTo _seedShouldExist,
            _seedShouldExist, !isNil "_restored"] call PA_fnc_assert;
        if (!isNil "_restored") then {
            private _expectedClasses = [["B_Soldier_TL_F"], ["B_Soldier_F"]] select (_case == "populated");
            private _classes = [_restored, "unitClasses"] call ALIVE_fnc_hashGet;
            [format ["%1 loader / %2: saved/live class selection", _label, _case],
                _classes isEqualTo _expectedClasses, _expectedClasses,
                _classes] call PA_fnc_assert;
        };
    } forEach ["missing", "short array", "wrong marker", "non-array values",
        "misaligned keys", "empty", "populated"];
} forEach [
    ["Normal", PA_missionKey, "sys_profile", ALIVE_fnc_profilesLoadData],
    ["Legacy PNS", _legacyKey, "ALiVE_SYS_PROFILE", ALIVE_fnc_profilesLoadDataPNS]
];

profileNamespace setVariable [PA_missionKey, _normalOriginal];
if (_legacyExisted) then {
    profileNamespace setVariable [_legacyKey, _legacyOriginal];
} else {
    profileNamespace setVariable [_legacyKey, nil];
};
[ALIVE_profileHandler, "reset"] call ALIVE_fnc_profileHandler;
ALIVE_loadProfilesPersistent = true;
ALiVE_sysProfileLastLoadTime = nil;
call ALIVE_fnc_profilesLoadData;
if (_hadLoadTime) then {
    ALiVE_sysProfileLastLoadTime = _loadTime;
} else {
    ALiVE_sysProfileLastLoadTime = nil;
};
[] call PA_fnc_verify;
