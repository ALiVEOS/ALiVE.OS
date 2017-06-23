#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_getConfigValue

Description:
    Retrieves any config value.

Parameters:
    0 - Config path [config]
    1 - Default value [any] (optional)

Returns:
    Config value [any]

Attributes:
    N/A

Examples:
    N/A

See Also:
    - <>
    - <>

Author:
    Naught, dixon13
---------------------------------------------------------------------------- */

params ["_cfg", ["_default", nil]];

switch (true) do {
    case (isText(_cfg)): {getText(_cfg)};
    case (isNumber(_cfg)): {getNumber(_cfg)};
    case (isArray(_cfg)): {getArray(_cfg)};
    case (isClass(_cfg)): {_cfg};
    default { _default };
};
