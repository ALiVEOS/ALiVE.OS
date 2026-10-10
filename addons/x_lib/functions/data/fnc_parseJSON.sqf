#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(parseJSON);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_parseJSON
Description:
Converts a JSON formatted string into a CBA HASH array

Parameters:
String - The JSON string

Returns:
Hash - array of data

Examples:
(begin example)
// _hash = [_input] call ALIVE_fnc_parseJSON;
(end)

See Also:
- <CBA_fnc_parseYAML>

Author:
Tupolov

Peer reviewed:
nil
---------------------------------------------------------------------------- */

// JSON Specific tokens
#define JSON_OBJECT_START 123
#define JSON_OBJECT_FINISH 125
#define JSON_ARRAY_START 91
#define JSON_ARRAY_FINISH 93

// Named character codes used by toArray / toString.
#define ASCII_BACKSPACE 8
#define ASCII_TAB 9
#define ASCII_NEWLINE 10
#define ASCII_FORM_FEED 12
#define ASCII_CARRIAGE_RETURN 13
#define ASCII_SPACE 32
#define ASCII_QUOTES 34
#define ASCII_COMMA 44
#define ASCII_SLASH 47
#define ASCII_COLON 58
#define ASCII_BACKSLASH 92

private ["_string","_charArray"];
private _whitespace = [ASCII_TAB, ASCII_NEWLINE, ASCII_CARRIAGE_RETURN, ASCII_SPACE];
private _tokenTerminators = _whitespace + [ASCII_COMMA, JSON_ARRAY_FINISH, JSON_OBJECT_FINISH];
private _hexDigits = toArray "0123456789abcdef";

// Read exactly four hexadecimal digits after the u in a Unicode escape.
private _readUnicodeEscape = {
    params ["_chars", "_pos"];
    if (_pos + 4 > count _chars) exitWith {[0, count _chars, false]};
    private _code = 0;
    private _valid = true;
    for "_i" from 1 to 4 do {
        private _digit = _hexDigits find
            ((toArray (toLower (toString [_chars select _pos]))) select 0);
        _pos = _pos + 1;
        if (_digit < 0) exitWith {_valid = false};
        _code = _code * 16 + _digit;
    };
    [_code, _pos, _valid]
};

// Readers return [value, next unread position, valid].
// Consume a complete quoted string without interpreting its JSON punctuation.
private _readString = {
    params ["_chars", "_index"];
    private _decoded = [];
    private _closed = false;
    private _valid = true;
    _index = _index + 1;
    while {_index < count _chars && {!_closed} && {_valid}} do {
        private _char = _chars select _index;
        _index = _index + 1;
        if (_char == ASCII_QUOTES) then {
            _closed = true;
        } else {
            if (_char == ASCII_BACKSLASH) then {
                if (_index >= count _chars) then {
                    _valid = false;
                } else {
                    private _escape = _chars select _index;
                    _index = _index + 1;
                    // JSON's backslash escapes: b/f/n/r/t denote control characters,
                    // u starts four hexadecimal digits; quote, backslash and slash
                    // keep their character code unchanged.
                    private _decodedChar = switch (toString [_escape]) do {
                        case "b": {ASCII_BACKSPACE};
                        case "f": {ASCII_FORM_FEED};
                        case "n": {ASCII_NEWLINE};
                        case "r": {ASCII_CARRIAGE_RETURN};
                        case "t": {ASCII_TAB};
                        case "u": {
                            ([_chars, _index] call _readUnicodeEscape) params ["_code", "_nextPosition", "_escapeValid"];
                            _index = _nextPosition;
                            _valid = _escapeValid;
                            _code
                        };
                        default {
                            _valid = _escape in [ASCII_QUOTES, ASCII_BACKSLASH, ASCII_SLASH];
                            _escape
                        };
                    };
                    if (_valid) then {_decoded pushBack _decodedChar};
                };
            } else {
                if (_char < ASCII_SPACE) then {_valid = false} else {_decoded pushBack _char};
            };
        };
    };
    [toString _decoded, _index, _valid && {_closed}]
};

// Keep primitive tokens as strings for the Data dictionary to restore.
private _numberPattern =
    "-?(0|[1-9][0-9]*)"       // integer
    + "(\.[0-9]+)?"          // optional fraction
    + "([eE][+-]?[0-9]+)?";  // optional exponent
private _isNumber = {
    _this regexMatch _numberPattern
};

private _skipWhitespace = {
    private _index = _this;
    while {_index < count _charArray && {(_charArray select _index) in _whitespace}} do {
        _index = _index + 1;
    };
    _index
};

private "_parseValue";
_parseValue = {
    // Positions point to the next unread character, including on failure.
    private _pos = _this call _skipWhitespace;
    if (_pos >= count _charArray) exitWith {["ERROR", _pos, false]};
    private _char = _charArray select _pos;
    switch (_char) do {
        case ASCII_QUOTES: {
            [_charArray, _pos] call _readString
        };
        case JSON_OBJECT_START;
        case JSON_ARRAY_START: {
            private _isObject = _char == JSON_OBJECT_START;
            private _end = if (_isObject) then {JSON_OBJECT_FINISH} else {JSON_ARRAY_FINISH};
            private _data = if (_isObject) then {[] call CBA_fnc_hashCreate} else {[]};
            _pos = (_pos + 1) call _skipWhitespace;
            // Only a freshly opened container may close without a member/value.
            if ((_charArray param [_pos, -1]) == _end) exitWith {[_data, _pos + 1, true]};
            private _valid = true;
            private _finished = false;
            while {_valid && {!_finished}} do {
                private _key = "";
                if (_isObject) then {
                    if ((_charArray param [_pos, -1]) != ASCII_QUOTES) then {
                        _valid = false;
                    } else {
                        ([_charArray, _pos] call _readString) params ["_keyValue", "_nextPosition", "_keyValid"];
                        _key = _keyValue;
                        _valid = _keyValid;
                        _pos = _nextPosition call _skipWhitespace;
                        if ((_charArray param [_pos, -1]) != ASCII_COLON) then {_valid = false};
                        _pos = _pos + 1;
                    };
                };
                if (!_valid) exitWith {};
                (_pos call _parseValue) params ["_value", "_nextPosition", "_valueValid"];
                _valid = _valueValid;
                _pos = _nextPosition call _skipWhitespace;
                if (!_valid) exitWith {};
                if (_isObject) then {
                    [_data, _key, _value] call CBA_fnc_hashSet;
                } else {
                    _data pushBack _value;
                };
                private _delimiter = _charArray param [_pos, -1];
                if (_delimiter == _end) then {
                    _finished = true;
                    _pos = _pos + 1;
                } else {
                    if (_delimiter == ASCII_COMMA) then {
                        // The next iteration requires a complete member/value.
                        _pos = (_pos + 1) call _skipWhitespace;
                    } else {
                        _valid = false;
                    };
                };
            };
            if (_valid && {_finished}) then {[_data, _pos, true]} else {["ERROR", _pos, false]}
        };
        default {
            private _start = _pos;
            while {_pos < count _charArray && {!((_charArray select _pos) in _tokenTerminators)}} do {
                _pos = _pos + 1;
            };
            private _token = toString (_charArray select [_start, _pos - _start]);
            private _valid = _token in ["true", "false", "null"] || {_token call _isNumber};
            if (_valid) then {[_token, _pos, true]} else {["ERROR", _pos, false]}
        };
    }
};

// This API returns an object hash. Nested arrays and primitive tokens are supported.
_string = _this select 0;
_charArray = toArray _string;
private _pos = 0 call _skipWhitespace;
if ((_charArray param [_pos, -1]) != JSON_OBJECT_START) exitWith {"ERROR"};
(_pos call _parseValue) params ["_value", "_nextPosition", "_valid"];
if (!_valid) exitWith {"ERROR"};
if ((_nextPosition call _skipWhitespace) != count _charArray) exitWith {"ERROR"};
_value
