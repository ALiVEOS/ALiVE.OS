#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_encodeJSON

Description:
    Encodes any SQF value to a JSON string.

Parameters:
    SQF data [any]

Returns:
    JSON [string]

Attributes:
    N/A

Examples:
    N/A

See Also:

Author:
    Naught
    Jman
---------------------------------------------------------------------------- */

if (isNil "_this") exitWith {"undefined"}; // Return

switch (typeName _this) do
{
    case "SCALAR": {format["%1", _this]}; // Return
    case "BOOL": {format["%1", _this]}; // Return

    case "OBJECT":
    {
        if (isNull _this) exitWith {"null"}; // Return

        '{' + // Return object format
            '"type": "object",' +
            '"netId": ' + (netId _this) +
        '}'
    };

    case "GROUP":
    {
        if (isNull _this) exitWith {"null"}; // Return

        '{' + // Return object format
            '"type": "group",' +
            '"netId": ' + (netId _this) +
        '}'
    };

    case "STRING":
    {
        // JSON-escaped: a double quote, a backslash, and the line break, carriage return and tab characters.
        // It looked for 22 (the quote's code in hexadecimal; toArray gives 34), so a string with a quote in it
        // went out unescaped and broke the saved JSON, and a lone backslash (as in a game file path) was never
        // escaped, which the reader rejects as an unknown escape. Strings with none of these take the old path.
        private _chars = toArray _this;
        if ((_chars findIf { _x in [34, 92, 10, 13, 9] }) < 0) then {
            ("""" + _this + """")
        } else {
            private _out = [34];
            {
                switch (_x) do {
                    case 34: { _out append [92, 34] };
                    case 92: { _out append [92, 92] };
                    case 10: { _out append [92, 110] };
                    case 13: { _out append [92, 114] };
                    case 9:  { _out append [92, 116] };
                    default  { _out pushBack _x };
                };
            } forEach _chars;
            _out pushBack 34;
            toString _out
        };
    };

    case "ARRAY":
    {
        private ["_output"];
        _output = "[";

        { // forEach
            if (_forEachIndex > 0) then {_output = _output + ","};
            _output = _output + (_x call ALiVE_fnc_encodeJSON);
        } forEach _this;

        (_output + "]") // Return
    };

    // For all other types, just convert to string
    default {str(_this) call ALiVE_fnc_encodeJSON};
};
