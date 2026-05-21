#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenFactionChoiceMultiSave);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_edenFactionChoiceMultiSave

Description:
Eden-attribute `attributeSave` handler for the ALiVE_FactionChoiceMulti
control family. Multi-select counterpart to fnc_edenFactionChoiceSave.sqf.

Reads ALL selected items from the multi-select ListBox (IDC 100), maps
each to its lbData (faction classname), and returns an SQF array literal
string like `["BLU_F","OPF_F","IND_F"]`. This format is what the
existing mil_opcom `factions` consumer (case "convert" in fnc_OPCOM.sqf)
already accepts and parses, so no runtime changes are needed downstream.

Three storage paths to make the value survive Eden's serialisation
(same as the single-select handler):
  1. Push into Eden's "value" attribute slot on the control.
  2. setVariable on each edited logic under the configured variable name.
  3. The attribute's `expression` in CfgVehicles re-applies on mission start.

Variable name on the logic is configurable via the second element of
_this. Defaults to "factions" but can be overridden by the per-control
attributeSave expression for other modules whose attribute is named
differently (e.g. "CQB_FACTIONS").

Empty-selection contract: returns "[]" (canonical empty-array literal)
rather than "" — this lets the consumer's parser distinguish "user
explicitly chose no factions" from "control was never opened". Most
consumers (mil_opcom included) treat both the same way (fall back to
defaults), but the explicit form is more diagnosable in RPT.

Parameters:
    [_display, _varName]
    _display : DISPLAY - Eden attribute display. ListBox control IDC 100.
    _varName : STRING  - logic variable name. Defaults to "factions".

Returns:
    STRING - SQF array literal of selected faction classnames,
             or "[]" if nothing selected.

Author:
Jman
---------------------------------------------------------------------------- */

// Unpack invocation. Backward-compat: legacy direct call (just the
// display) defaults the variable name.
private _display = controlNull;
private _varName = "factions";
if (typeName _this == "ARRAY") then {
    _display = _this select 0;
    if (count _this > 1 && {typeName (_this select 1) == "STRING"} && {(_this select 1) != ""}) then {
        _varName = _this select 1;
    };
} else {
    _display = _this;
};

private _ctrl = (_display controlsGroupCtrl 100);
if (isNull _ctrl) exitWith {
    ["ALIVE FactionChoiceMulti SAVE: listbox control (IDC 100) not found"] call ALiVE_fnc_dump;
    "[]"
};

// ------------------------------------------------------------------------
// 1. Read multi-selection. lbSelection returns ARRAY of selected indices
//    on a multi-select listbox. Map each to lbData (the faction classname).
// ------------------------------------------------------------------------
private _selectedIdxs = lbSelection _ctrl;
private _selectedFactions = [];
{
    private _data = _ctrl lbData _x;
    if (typeName _data == "STRING" && {_data != ""}) then {
        _selectedFactions pushBack _data;
    };
} forEach _selectedIdxs;

// ------------------------------------------------------------------------
// 2. Format as SQF array literal string. Each entry quoted with double
//    quotes; faction classnames are bare identifiers so no internal
//    escaping needed (defensive str() handles edge cases anyway).
//    Empty selection produces canonical "[]" not "" - see header.
// ------------------------------------------------------------------------
private _result = if (count _selectedFactions == 0) then {
    "[]"
} else {
    private _quoted = _selectedFactions apply { format ["""%1""", _x] };
    format ["[%1]", _quoted joinString ","]
};

// Path 1: Eden "value" slot - for SQM serialisation
_display setVariable ["value", _result];

// Path 2: logic variable - for attributeLoad to find on re-open
{
    _x setVariable [_varName, _result, true];
} forEach (get3DENSelected "logic");

// Path 3 (mission start re-apply) is handled by the attribute's `expression`
// declared in each consuming module's CfgVehicles.hpp.

// Diagnostic - mirror of the load handler's logging.
[
    "ALIVE FactionChoiceMulti SAVE: varName='%1' selected=%2 (%3 items) -> '%4'",
    _varName,
    _selectedFactions,
    count _selectedFactions,
    _result
] call ALiVE_fnc_dump;

_result
