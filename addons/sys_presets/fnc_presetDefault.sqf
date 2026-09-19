#include "script_component.hpp"
SCRIPT(presetDefault);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_presetDefault

Description:
What a module setting reads when nobody has touched it, and whether the value in
front of you is that or something the mission maker chose.

A preset carries only what was chosen. Everything else is left out on purpose, so
that a preset written today still gets the benefit of a default improved
tomorrow, and so a preset is a few hundred characters rather than forty thousand.
That only works if "chosen" can be told from "left alone", which is what this
answers.

The default is the attribute's own defaultValue, which config holds as a piece of
text to evaluate rather than a value. Comparing is done on the written-out form of
both sides rather than by type: the editor hands back the text "false" for a
setting whose default evaluates to the text "false", but a handful of settings
declare a type and come back as a real number or a real true/false, and a preset
must not record those as changed just because the two sides are held differently.

Parameters:
    _attr    - CONFIG  - the attribute class, a child of the module's Attributes
    _entity  - OBJECT  - the module the default is being worked out for. Optional:
                         defaultValue is evaluated with the module as _this, and a
                         few read it.

Returns:
    ARRAY [_known, _default] - _known is false when the attribute declares no
    default at all, in which case nothing can be said about it and the caller
    should keep the value.

Examples:
    (begin example)
    private _r = [configFile >> "CfgVehicles" >> "ALiVE_mil_OPCOM" >> "Attributes" >> "controltype"] call ALIVE_fnc_presetDefault;
    // _r is [true, "invasion"]
    (end)

See Also:
    ALIVE_fnc_presetCollect, ALIVE_fnc_presetSerialize

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_attr", configNull, [configNull]], ["_entity", objNull, [objNull]]];

if (isNull _attr) exitWith { [false, ""] };

private _raw = getText (_attr >> "defaultValue");
if (_raw isEqualTo "") exitWith { [false, ""] };

// Evaluated, not read: defaultValue is a piece of SQF text. ALiVE's own are
// literals ("""false""", "200", "[]"), but the editor evaluates them with the
// module as _this and a mod could rely on that, so it is called the same way.
private _code = compile _raw;
private _value = if (isNull _entity) then { call _code } else { _entity call _code };
if (isNil "_value") exitWith { [false, ""] };

[true, _value]
