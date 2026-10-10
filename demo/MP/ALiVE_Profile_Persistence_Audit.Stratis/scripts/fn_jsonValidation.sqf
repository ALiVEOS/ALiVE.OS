// Exercise the production Cloud codec and writer without contacting the plugin.
[ALIVE_profileSystem, "pause", true] call ALIVE_fnc_profileSystem;
private _handler = [[["source", "couchdb"], ["storeType", true]]] call ALIVE_fnc_hashCreate;
private _dictionaryBefore = +ALIVE_DataDictionary;
// RPT messages are limited to 1024 characters; retain complete wire evidence.
private _logWire = {
    params ["_name", "_wire"];
    private _chars = toArray _wire;
    for "_offset" from 0 to (count _chars - 1) step 120 do {
        diag_log format ["[PA_JSON_CODES] %1 %2 %3", _name, _offset, _chars select [_offset, 120]];
    };
};
private _punctuation = "quote "" slash \ path C:\ALiVE\test literal \n [, {, ,]} : [ ] { } / apostrophe '";
private _controls = toString [1, 8, 9, 10, 12, 13, 31];
private _unicode = toString [338, 937, 20013, 55357, 56832];
private _key = "key"":[,]\" + toString [9];
private _nested = [[[_key, _punctuation]]] call ALIVE_fnc_hashCreate;
private _fixture = [[["PA_JSON_text", _punctuation], ["PA_JSON_controls", _controls],
    ["PA_JSON_unicode", _unicode], ["PA_JSON_nested", _nested],
    ["PA_JSON_array", ["", _punctuation, [_controls, _unicode], [], false, true, 12.5]],
    ["PA_JSON_emptyHash", [] call ALIVE_fnc_hashCreate],
    ["onEachSpawn", "_this params [""_unit""];"], ["onEachSpawnOnce", false]]] call ALIVE_fnc_hashCreate;
private _wire = [_handler, "convert", [_fixture]] call ALIVE_fnc_Data;
["fixture", _wire] call _logWire;
["JSON / quotes escaped", (_wire find "\""_unit\""") >= 0, "escaped quotes", _wire] call PA_fnc_assert;
["JSON / backslashes escaped", (_wire find "C:\\ALiVE\\test") >= 0, "escaped path", _wire] call PA_fnc_assert;
["JSON / controls escaped", (_wire find "\u0001\b\t\n\f\r\u001f") >= 0,
    "escaped controls", _wire] call PA_fnc_assert;
// Ignore the CBA hash's undefined default slot when comparing JSON values.
private "_normalize";
_normalize = {
    if ([_this] call ALIVE_fnc_isHash) exitWith {
        ["hash", _this select 1, (_this select 2) apply {_x call _normalize}]
    };
    if (_this isEqualType []) exitWith {_this apply {_x call _normalize}};
    _this
};
private _decoded = [_handler, "restore", [_wire]] call ALIVE_fnc_Data;
{
    _x params ["_field", "_expected"];
    private _actual = [_decoded, _field] call ALIVE_fnc_hashGet;
    ["JSON / roundtrip / " + _field, (_actual call _normalize) isEqualTo (_expected call _normalize), _expected, _actual] call PA_fnc_assert;
} forEach [
    ["PA_JSON_text", _punctuation], ["PA_JSON_controls", _controls],
    ["PA_JSON_unicode", _unicode], ["PA_JSON_nested", _nested],
    ["PA_JSON_array", ["", _punctuation, [_controls, _unicode], [], false, true, 12.5]],
    ["PA_JSON_emptyHash", [] call ALIVE_fnc_hashCreate],
    ["onEachSpawn", "_this params [""_unit""];"], ["onEachSpawnOnce", false]
];
private _standard = ["{""escaped\""key"": ""value\/\b\f\n\r\t\\\"""", ""unicode"": ""\u0152\u03A9\u4e2d\uD83D\uDE00"", ""items"": ["""", ""a,b"", {}, []], ""number"": 42, ""bool"": false}"] call ALIVE_fnc_parseJSON;
{
    _x params ["_field", "_expected"];
    private _actual = [_standard, _field] call ALIVE_fnc_hashGet;
    private _label = if (_field == "escaped""key") then {"escaped key"} else {_field};
    ["JSON / standard / " + _label, (_actual call _normalize) isEqualTo (_expected call _normalize), _expected, _actual] call PA_fnc_assert;
} forEach [
    ["escaped""key", "value/" + toString [8, 12, 10, 13, 9, 92, 34]],
    ["unicode", _unicode], ["items", ["", "a,b", [] call ALIVE_fnc_hashCreate, []]],
    ["number", "42"], ["bool", "false"]
];
["JSON / empty object", ((["{}"] call ALIVE_fnc_parseJSON) call _normalize) isEqualTo (([] call ALIVE_fnc_hashCreate) call _normalize),
    "empty hash", ["{}"] call ALIVE_fnc_parseJSON] call PA_fnc_assert;
{
    private _actual = [_x] call ALIVE_fnc_parseJSON;
    ["JSON / invalid escape / " + str _forEachIndex, _actual isEqualTo "ERROR", "ERROR", _actual] call PA_fnc_assert;
} forEach ["{""a"":""\q""}", "{""a"":""\u00zz""}", "{""a"":""unterminated}"];

// Invalid strings must reject the entire response, wherever they are nested.
{
    private _wire = _x;
    private _index = _forEachIndex;
    {
        _x params ["_name", "_wrapped"];
        private _actual = [_wrapped] call ALIVE_fnc_parseJSON;
        ["JSON / nested error / " + _name + " / " + str _index,
            _actual isEqualTo "ERROR", "ERROR", _actual] call PA_fnc_assert;
    } forEach [
        ["object", "{""doc"":" + _wire + ",""ok"":""x""}"],
        ["array", "{""docs"":[" + _wire + "]}"],
        ["rows", "{""rows"":[{""doc"":" + _wire + "}]}"]
    ];
} forEach ["{""a"":""\q""}", "{""a"":""\u00zz""}", "{""a"":""unterminated}"];
{
    private _actual = [_x] call ALIVE_fnc_parseJSON;
    ["JSON / nested boundary / " + str _forEachIndex,
        _actual isEqualTo "ERROR", "ERROR", _actual] call PA_fnc_assert;
} forEach [
    "{""outer"":{""bad\q"":""x""}}",
    "{""outer"":{""bad\u00zz"":""x""}}",
    "{""outer"":{",
    "{""outer"":[",
    "{""outer"":{""code"":""x""",
    "{""outer"":[{""code"":""x""}",
    "{"
];
private _validError = ["{""doc"":{""code"":""ERROR""},""array"":[""ERROR""]}"] call ALIVE_fnc_parseJSON;
private _errorDoc = [_validError, "doc"] call ALIVE_fnc_hashGet;
["JSON / ERROR literal is valid data",
    ([_errorDoc, "code"] call ALIVE_fnc_hashGet) isEqualTo "ERROR"
        && {([_validError, "array"] call ALIVE_fnc_hashGet) isEqualTo ["ERROR"]},
    "literal strings preserved", _validError] call PA_fnc_assert;

// Every container enforces member/value sequencing, not just quoted escapes.
{
    private _actual = [_x] call ALIVE_fnc_parseJSON;
    ["JSON / invalid grammar / " + str _forEachIndex, _actual isEqualTo "ERROR", "ERROR", _actual] call PA_fnc_assert;
} forEach [
    "{""doc"":{""dangling""}}", "{""doc"":{dangling}}", "{""doc"":{""a"":1,}}",
    "{""doc"":{,}}", "{""doc"":{""a"" ""b"":1}}", "{""doc"":{""a""::1}}",
    "{""doc"":{""a"":}}", "{""doc"":{""a"":1 ""b"":2}}", "{""doc"":{""a"":1,,}}",
    "{""items"":[1,]}", "{""items"":[,]}", "{""items"":[1,,2]}", "{""items"":[1 2]}",
    "{""items"":[}", "{""doc"":{]}", "{""items"":[""a"" ""b""]}",
    "{""a"":00}", "{""a"":+1}", "{""a"":.5}", "{""a"":1.}", "{""a"":1e}",
    "{""a"":--1}", "{""a"":NaN}", "{""a"":Infinity}", "{""a"":truefalse}",
    "{}{}", "{} trailing", "{""a"":1,}", "{""a"":}"
];
private _numberTokens = ["0", "-0", "0.5", "-10.25", "1e3", "1E-2", "-2.5e+4"];
private _numbers = ["{""numbers"":[" + (_numberTokens joinString ",") + "]}"] call ALIVE_fnc_parseJSON;
["JSON / valid number grammar", ([_numbers, "numbers"] call ALIVE_fnc_hashGet) isEqualTo _numberTokens,
    _numberTokens, [_numbers, "numbers"] call ALIVE_fnc_hashGet] call PA_fnc_assert;
private _space = toString [9, 10, 13, 32];
private _spaced = [_space + "{""doc"": {},""values"": [true,false,null],""key"": """"}" + _space] call ALIVE_fnc_parseJSON;
["JSON / whitespace and empty values",
    ([_spaced, "values"] call ALIVE_fnc_hashGet) isEqualTo ["true", "false", "null"]
        && {([_spaced, "key"] call ALIVE_fnc_hashGet) isEqualTo ""}
        && {(([_spaced, "doc"] call ALIVE_fnc_hashGet) call _normalize) isEqualTo
            (([] call ALIVE_fnc_hashCreate) call _normalize)},
    "empty object/string and primitive tokens", _spaced] call PA_fnc_assert;

// Capture only the plugin boundary, invoking the actual production bulk writer.
private _pluginBefore = ALIVE_fnc_sendToPlugIn;
private _bulkCommands = [];
[{
    ALIVE_fnc_sendToPlugIn = {_bulkCommands pushBack (_this select 0); "PA_CAPTURE"};
    private _docs = [[["one", [[["PA_JSON_bulk", _punctuation]]] call ALIVE_fnc_hashCreate],
        ["two", [[["PA_JSON_bulk", _controls]]] call ALIVE_fnc_hashCreate]]] call ALIVE_fnc_hashCreate;
    [_handler, ["sys_profile_PA", _docs, false, "audit"]] call ALIVE_fnc_bulkWriteData_couchdb;
    [_handler, ["sys_profile_PA", [] call ALIVE_fnc_hashCreate, false, "audit"]] call ALIVE_fnc_bulkWriteData_couchdb;
    ALIVE_fnc_sendToPlugIn = _pluginBefore;
}, []] call CBA_fnc_directCall;
{
    private _start = (_x find ",'{") + 2;
    private _json = _x select [_start, count _x - _start - 2];
    ["bulk" + str _forEachIndex, _json] call _logWire;
    private _parsed = [_json] call ALIVE_fnc_parseJSON;
    private _docs = [_parsed, "docs", []] call ALIVE_fnc_hashGet;
    private _expected = if (_forEachIndex == 0) then {[_punctuation, _controls]} else {[]};
    private _actual = _docs apply {[_x, "PA_JSON_bulk"] call ALIVE_fnc_hashGet};
    ["JSON / bulk / " + str _forEachIndex, (_actual call _normalize) isEqualTo (_expected call _normalize), _expected, _actual] call PA_fnc_assert;
} forEach _bulkCommands;

// Real profile export -> Cloud encode -> restore -> import -> physical spawning.
[ALIVE_profileHandler, "reset"] call ALIVE_fnc_profileHandler;
private _hook = "_this params [""_unit""]; _unit setVariable [""PA_JSON_hookRan"", ""quote """" works""];" + toString [10]
    + "_unit setVariable [""PA_JSON_path"", ""C:\ALiVE\test""]; _unit setVariable [""PA_JSON_punctuation"", ""[, {, ,]}""];";
private _fixtures = [];
{
    private _profile = [["B_Soldier_F", "B_Soldier_F"], "WEST", "BLU_F", [1810, 5520, 0],
        0, "", false, "PA_json_" + str _x, false, "PRIVATE", [[1810, 5520, 0], [1810, 5520, 0]]] call ALIVE_fnc_createProfileEntity;
    [_profile, "onEachSpawn", _hook] call ALIVE_fnc_profileEntity;
    [_profile, "onEachSpawnOnce", _x] call ALIVE_fnc_profileEntity;
    _fixtures pushBack [[_profile, "profileID"] call ALIVE_fnc_hashGet, _x];
} forEach [false, true];
private _saved = [ALIVE_profileHandler, "exportProfileData"] call ALIVE_fnc_profileHandler;
_wire = [_handler, "convert", [_saved]] call ALIVE_fnc_Data;
_decoded = [_handler, "restore", [_wire]] call ALIVE_fnc_Data;
[{
    [ALIVE_profileHandler, "reset"] call ALIVE_fnc_profileHandler;
    [ALIVE_profileHandler, "importProfileData", _decoded] call ALIVE_fnc_profileHandler;
}, []] call CBA_fnc_directCall;
{
    _x params ["_id", "_once"];
    private _profile = [ALIVE_profileHandler, "getProfile", _id] call ALIVE_fnc_profileHandler;
    private _label = "JSON / profile / " + str _once;
    [_label + ": restored", !isNil "_profile", _id, if (isNil "_profile") then {"missing"} else {_id}] call PA_fnc_assert;
    if (!isNil "_profile") then {
        private _actualHook = [_profile, "onEachSpawn"] call ALIVE_fnc_hashGet;
        private _actualOnce = [_profile, "onEachSpawnOnce"] call ALIVE_fnc_hashGet;
        [_label + ": code exact", _actualHook isEqualTo _hook, _hook, _actualHook] call PA_fnc_assert;
        [_label + ": boolean exact", _actualOnce isEqualTo _once, _once, _actualOnce] call PA_fnc_assert;
        for "_round" from 1 to 2 do {
            private _task = [_profile, "spawn"] spawn ALIVE_fnc_profileEntity;
            private _deadline = diag_tickTime + 15;
            waitUntil {sleep 0.05; scriptDone _task || {diag_tickTime > _deadline}};
            if (!scriptDone _task) then {terminate _task};
            sleep 0.2;
            private _units = [_profile, "units", []] call ALIVE_fnc_hashGet;
            private _expected = if (_once && {_round == 2}) then {""} else {"quote "" works"};
            private _actual = _units apply {_x getVariable ["PA_JSON_hookRan", ""]};
            [_label + ": execution " + str _round,
                scriptDone _task && {count _units == 2} && {_actual isEqualTo [_expected, _expected]}
                    && {(_units findIf {
                        (_x getVariable ["PA_JSON_path", ""]) != (if (_expected == "") then {""} else {"C:\ALiVE\test"})
                        || {(_x getVariable ["PA_JSON_punctuation", ""]) != (if (_expected == "") then {""} else {"[, {, ,]}"})}
                    }) == -1},
                [_expected, _expected], _actual] call PA_fnc_assert;
            {_x allowDamage false; _x disableAI "ALL"} forEach _units;
            [_profile, "despawn"] call ALIVE_fnc_profileEntity;
        };
    };
} forEach _fixtures;
// Lose only the two Boolean dictionary entries, retaining a real Cloud payload.
[ALIVE_profileHandler, "reset"] call ALIVE_fnc_profileHandler;
private _boolFixtures = [];
{
    _x params ["_alias", "_once", "_ran"];
    private _profile = [["B_Soldier_F", "B_Soldier_F"], "WEST", "BLU_F", [1810, 5520, 0],
        0, "", false, "PA_json_bool_" + _alias, false, "PRIVATE", [[1810, 5520, 0], [1810, 5520, 0]]] call ALIVE_fnc_createProfileEntity;
    [_profile, "onEachSpawn", _hook] call ALIVE_fnc_profileEntity;
    [_profile, "onEachSpawnOnce", _once] call ALIVE_fnc_profileEntity;
    [_profile, "spawnCodeRun", _ran] call ALIVE_fnc_hashSet;
    _boolFixtures pushBack [_alias, [_profile, "profileID"] call ALIVE_fnc_hashGet, _once, _ran];
} forEach [["repeat", false, false], ["once", true, false], ["ranOnce", true, true], ["ranRepeat", false, true]];
for "_round" from 1 to 2 do {
    _saved = [ALIVE_profileHandler, "exportProfileData"] call ALIVE_fnc_profileHandler;
    _wire = [_handler, "convert", [_saved]] call ALIVE_fnc_Data;
    {[ALIVE_DataDictionary, _x] call ALIVE_fnc_hashRem} forEach ["onEachSpawnOnce", "spawnCodeRun"];
    _decoded = [_handler, "restore", [_wire]] call ALIVE_fnc_Data;
    {
        _x params ["_alias", "_id", "_once", "_ran"];
        private _record = [_decoded, _id] call ALIVE_fnc_hashGet;
        private _expectedRan = _ran || {_once && {_round == 2}};
        ["JSON / Boolean fallback / " + str _round + " / " + _alias + ": source strings",
            ([_record, "onEachSpawnOnce"] call ALIVE_fnc_hashGet) isEqualTo str _once
                && {([_record, "spawnCodeRun"] call ALIVE_fnc_hashGet) isEqualTo str _expectedRan},
            [str _once, str _expectedRan],
            [_record, ["onEachSpawnOnce", "spawnCodeRun"]] call ALIVE_fnc_hashGetMany] call PA_fnc_assert;
    } forEach _boolFixtures;
    [{
        [ALIVE_profileHandler, "reset"] call ALIVE_fnc_profileHandler;
        [ALIVE_profileHandler, "importProfileData", _decoded] call ALIVE_fnc_profileHandler;
    }, []] call CBA_fnc_directCall;
    {
        _x params ["_alias", "_id", "_once", "_ran"];
        private _label = "JSON / Boolean fallback / " + str _round + " / " + _alias;
        private _profile = [ALIVE_profileHandler, "getProfile", _id] call ALIVE_fnc_profileHandler;
        [_label + ": restored", !isNil "_profile", _id,
            if (isNil "_profile") then {"missing"} else {_id}] call PA_fnc_assert;
        if (!isNil "_profile") then {
            private _expectedRan = _ran || {_once && {_round == 2}};
            private _actualOnce = [_profile, "onEachSpawnOnce"] call ALIVE_fnc_hashGet;
            private _actualRan = [_profile, "spawnCodeRun"] call ALIVE_fnc_hashGet;
            [_label + ": once Boolean", _actualOnce isEqualTo _once, _once, _actualOnce] call PA_fnc_assert;
            [_label + ": execution Boolean", _actualRan isEqualTo _expectedRan, _expectedRan, _actualRan] call PA_fnc_assert;
            private _task = [_profile, "spawn"] spawn ALIVE_fnc_profileEntity;
            private _deadline = diag_tickTime + 15;
            private _expected = if (_once && {_expectedRan}) then {""} else {"quote "" works"};
            waitUntil {
                sleep 0.05;
                (scriptDone _task && {
                    private _units = [_profile, "units", []] call ALIVE_fnc_hashGet;
                    count _units == 2 && {(_units findIf {(_x getVariable ["PA_JSON_hookRan", ""]) != _expected}) == -1}
                }) || {diag_tickTime > _deadline}
            };
            if (!scriptDone _task) then {terminate _task};
            private _units = [_profile, "units", []] call ALIVE_fnc_hashGet;
            private _actual = _units apply {_x getVariable ["PA_JSON_hookRan", ""]};
            [_label + ": physical execution", scriptDone _task && {count _units == 2}
                && {_actual isEqualTo [_expected, _expected]}, [_expected, _expected], _actual] call PA_fnc_assert;
            {_x allowDamage false; _x disableAI "ALL"} forEach _units;
            [_profile, "despawn"] call ALIVE_fnc_profileEntity;
        };
    } forEach _boolFixtures;
};
ALIVE_DataDictionary = _dictionaryBefore;
