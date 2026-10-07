#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(exportWrite);
/* Queue complete export statements in one caller-owned context. A call with
   only the context flushes it. The caller must flush before reporting success.
   Native null/pipe handling is preserved by sending those packets individually.
   Optional context fields: extension, limit, send (test transport callback).
   Failed writes latch error and prevent subsequent writes. */
params ["_writer", ["_request", "", [""]]];
if ((_writer getOrDefault ["error", ""]) != "") exitWith {false};
private _send = {
    params ["_packet"];
    private _response = if ("send" in _writer) then {
        _packet call (_writer get "send")
    } else {
        (_writer getOrDefault ["extension", "ALiVEClient"]) callExtension _packet
    };
    if (_response != "SUCCESS") then {
        _writer set ["error", format ["ALiVE export write failed: %1", _response]];
    };
    _response == "SUCCESS"
};
private _flush = {
    private _parts = _writer getOrDefault ["parts", []];
    if (count _parts == 0) exitWith {true};
    private _packet = (_writer get "header") + (_parts joinString (toString [13,10]));
    _writer set ["parts", []];
    _writer set ["bytes", 0];
    [_packet] call _send
};
if (count _this == 1) exitWith {call _flush};
private _first = _request find "|";
private _isIndex = (_request find "indexData~") == 0;
private _supported = _isIndex || {(_request find "clusterData~") == 0} || {(_request find "sectorData~") == 0};
if (!_supported || {_first < 0}) exitWith {
    if !(call _flush) exitWith {false};
    [_request] call _send
};
private _bodyAt = _first + 1;
if (!_isIndex) then {
    private _second = (_request select [_bodyAt]) find "|";
    _bodyAt = if (_second < 0) then {-1} else {_bodyAt + _second + 1};
};
if (_bodyAt < 0) exitWith {
    if !(call _flush) exitWith {false};
    [_request] call _send
};
private _header = _request select [0,_bodyAt];
private _body = _request select [_bodyAt];
// Fast ASCII path; toArray yields UTF-16 units for non-ASCII byte accounting.
private _bytes = count _request;
if !(_request regexMatch "^[\x00-\x7F]*$") then {
    _bytes = 0;
    {
        _bytes = _bytes + (if (_x < 128) then {1} else {
            if (_x < 2048) then {2} else {
                if (_x >= 55296 && {_x <= 57343}) then {2} else {3}
            }
        });
    } forEach toArray _request;
};
private _limit = _writer getOrDefault ["limit",65536];
private _barrier = (_body find "|") >= 0 || {!_isIndex && {(_body find "null") >= 0}};
if (_barrier || {_bytes > _limit}) exitWith {
    if !(call _flush) exitWith {false};
    [_request] call _send
};
private _parts = _writer getOrDefault ["parts", []];
private _added = _bytes - count _header + (if (count _parts > 0) then {2} else {0});
if ((_writer getOrDefault ["header", ""]) != _header || {(_writer getOrDefault ["bytes",0]) + _added > _limit}) then {
    call _flush;
    _parts = [];
    _writer set ["header", _header];
    _writer set ["bytes",count _header];
};
if ((_writer getOrDefault ["error", ""]) != "") exitWith {false};
_writer set ["bytes", (_writer getOrDefault ["bytes",count _header]) + _bytes - count _header + (if (count _parts > 0) then {2} else {0})];
_parts pushBack _body;
_writer set ["parts",_parts];
true
