// Only I/O is simulated; bulkSave/bulkLoad/convert use production CouchDB code.
// No production function is replaced. No network or PNS write occurs here.
params ["_handler", "_args", "_operation"];
private _docs = [_handler, "PA_docs"] call ALIVE_fnc_hashGet;
private _module = _args select 0;
switch (_operation) do {
    case "read": {
        private _doc = _docs getOrDefault [_module + ":" + (_args select 2), "NOT_FOUND"];
        if (_doc isEqualType []) then {_doc = +_doc};
        _doc
    };
    case "write": {
        private _doc = +(_args select 1);
        private _id = _args select 3;
        private _key = _module + ":" + _id;
        private _existing = _docs getOrDefault [_key, []];
        if (count _existing > 0 && {
            ([_doc, "_rev", ""] call ALIVE_fnc_hashGet) != ([_existing, "_rev", ""] call ALIVE_fnc_hashGet)
        }) exitWith {["ERROR: revision conflict"]};
        private _revision = ([_handler, "PA_revision", 0] call ALIVE_fnc_hashGet) + 1;
        [_handler, "PA_revision", _revision] call ALIVE_fnc_hashSet;
        [_doc, "_id", _id] call ALIVE_fnc_hashSet;
        [_doc, "_rev", str _revision] call ALIVE_fnc_hashSet;
        _docs set [_key, _doc];
        ["OK"]
    };
    case "bulkWrite": {
        if ([_handler, "PA_failNextWrite", false] call ALIVE_fnc_hashGet) exitWith {
            [_handler, "PA_failNextWrite", false] call ALIVE_fnc_hashSet;
            ["ERROR: injected document write failure"]
        };
        private _data = _args select 1;
        private _missionKey = _args select 3;
        private _responses = [];
        {
            private _id = _missionKey + "-" + _x;
            private _doc = +((_data select 2) select _forEachIndex);
            _responses pushBack ([_handler, [_module, _doc, false, _id], "write"] call PA_fnc_cloudTransport);
        } forEach (_data select 1);
        _responses
    };
    case "bulkRead": {
        private _missionKey = _args select 1;
        private _result = [] call ALIVE_fnc_hashCreate;
        {
            private _doc = _docs getOrDefault [_module + ":" + _missionKey + "-" + _x, []];
            if (count _doc > 0) then {[_result, _x, +_doc] call ALIVE_fnc_hashSet};
        } forEach (_args select 2);
        _result
    };
    default {format ["ERROR: unsupported test transport operation %1", _operation]};
}
