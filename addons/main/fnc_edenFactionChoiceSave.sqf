#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenFactionChoiceSave);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_edenFactionChoiceSave

Description:
Eden-attribute `attributeSave` handler for the shared ALiVE_FactionChoice
control. Returns the currently-selected entry's lbData (the faction
classname). If nothing is selected it keeps the module's earlier value and
logs a warning; the default "OPF_F" is used only when there is none.

Three storage paths to make the string value survive Eden's numeric-leaning
Combo serialisation:
  1. Push into Eden's "value" attribute slot on the control so SQM
     serialisation sees it.
  2. setVariable directly on each edited logic under the variable name
     "faction" so the attributeLoad handler finds it on re-open.
  3. The attribute's `expression` in CfgVehicles applies the SQM-stored
     value back onto the logic at mission start (landing on the same
     variable name "faction").

Shared across mil_placement, civ_placement, civ_placement_custom, and any
future ALiVE module with a `faction` attribute.

Parameters:
    _this: DISPLAY - the Eden attribute's display. Combo control has IDC 100.

Returns:
    STRING - the selected faction classname (e.g. "OPF_F", "rhs_faction_msv").
             For "(unrecognised)" entries, the original stored string is
             preserved in lbData and returned unchanged.

Author:
Jman
---------------------------------------------------------------------------- */

// Unpack invocation. New-style call from variant control classes that
// pass a custom variable name is
//   [_this, _varName] call compile preprocessFileLineNumbers '...'
// Legacy direct call is `_this call ...` where _this = display, with
// _varName defaulting to "faction" (the property name used by the
// majority of single-select faction attributes).
private _display = controlNull;
private _varName = "faction";
private _allowNone = false;
if (typeName _this == "ARRAY") then {
    _display = _this select 0;
    if (count _this > 1 && {typeName (_this select 1) == "STRING"} && {(_this select 1) != ""}) then {
        _varName = _this select 1;
    };
    if (count _this > 2 && {typeName (_this select 2) == "BOOL"}) then {
        _allowNone = _this select 2;
    };
} else {
    _display = _this;
};

private _ctrl = (_display controlsGroupCtrl 100);
private _sel = lbCurSel _ctrl;
private _result = if (_sel < 0) then { "" } else { _ctrl lbData _sel };
if (typeName _result != "STRING") then { _result = "" };

// Nothing usable selected on a picker that needs a faction: keep what the
// module already had rather than quietly writing vanilla CSAT (OPF_F) over
// it, and say so. OPF_F is only the last resort when there is no earlier
// value at all.
if (_result == "" && {!_allowNone}) then {
    private _selected = get3DENSelected "logic";
    private _previous = if (_selected isNotEqualTo []) then { (_selected select 0) getVariable [_varName, ""] } else { "" };
    if (typeName _previous != "STRING") then { _previous = "" };
    if (_previous == "") then { _previous = _display getVariable ["value", ""] };
    if (typeName _previous != "STRING") then { _previous = "" };
    _result = [_previous, "OPF_F"] select (_previous == "");
    diag_log format ["ALiVE Faction choice WARNING: no faction was selected for '%1'; kept %2%3", _varName, _result, ["", " (the default, vanilla CSAT) as there was no earlier value"] select (_previous == "")];
};

// Path 1: Eden "value" slot - for SQM serialisation
_display setVariable ["value", _result];

// Path 2: logic variable - for attributeLoad to find on re-open AND for
// Eden's variables[] SQM serialisation (broadcast=true). Variant control
// classes with a non-default _varName write to that key instead of
// "faction" so attributes with a sibling "faction" on the same module
// don't clobber each other's stored values.
{
    _x setVariable [_varName, _result, true];
} forEach (get3DENSelected "logic");

// Path 3 (mission start re-apply) is handled by the attribute's `expression`
// declared in each consuming module's CfgVehicles.hpp.

_result
