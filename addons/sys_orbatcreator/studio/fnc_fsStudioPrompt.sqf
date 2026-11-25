#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsStudioPrompt);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsStudioPrompt

Description:
The question popup (ALiVE_FS_Prompt, 14870) over the studio: a yes/no question,
or a question with one line to type in.

    - "open" [question, text, callback, args]: text nil (or not a string) asks
      yes/no and hides the line; a string shows the line filled with it. The
      callback is called once, when the popup closes, with
      [ok, text, args]: ok true for OK, false for Cancel or Esc. A fifth
      element names the popup class: "ALiVE_FS_CodePrompt" gives a tall box of
      several lines (Init Code);
    - "ok" / "cancel": the two buttons.

Parameters:
    _op   - STRING - "open", "ok" or "cancel"
    _args - ARRAY - for "open", as above

Returns:
    Nothing

Examples:
    (begin example)
    ["open", [localize "STR_ALIVE_FS_Q_REPLACE", nil, { params ["_ok"]; if (_ok) then { ... } }]] call ALiVE_fnc_fsStudioPrompt;
    (end)

See Also:
    ALiVE_fnc_fsStudioTabFaction

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\data\ui\studio\idc.hpp"

disableSerialization;

params [["_op", "", [""]], ["_args", []]];

private _session = missionNamespace getVariable "ALiVE_FS_session";
if (isNil "_session") exitWith {};
private _popup = findDisplay FS_IDD_PROMPT;

switch (_op) do {
    case "open": {
        _args params [["_question", ""], "_text", ["_callback", {}, [{}]], ["_cbArgs", []], ["_class", "ALiVE_FS_Prompt", [""]]];
        private _studio = _session getOrDefault ["display", displayNull];
        if (isNull _studio) exitWith {};
        // an open prompt is answered "no" before the new one takes its place
        if (!isNull _popup) then { _popup closeDisplay 2 };
        _session set ["prompt", [_callback, _cbArgs, false, ""]];
        _popup = _studio createDisplay _class;
        if (isNull _popup) exitWith {
            _session deleteAt "prompt";
            [false, "", _cbArgs] call _callback;
        };
        (_popup displayCtrl FS_IDC_PR_QUESTION) ctrlSetStructuredText parseText (((_question regexReplace ["&", "&amp;"]) regexReplace ["<", "&lt;"]) regexReplace [">", "&gt;"]);
        private _edit = _popup displayCtrl FS_IDC_PR_EDIT;
        private _line = !isNil "_text" && {_text isEqualType ""};
        _edit ctrlShow _line;
        if (_line) then { _edit ctrlSetText _text; ctrlSetFocus _edit } else { ctrlSetFocus (_popup displayCtrl FS_IDC_PR_OK) };
        // every way out (OK, Cancel, Esc) ends here, so the callback runs once
        _popup displayAddEventHandler ["Unload", {
            private _session = missionNamespace getVariable ["ALiVE_FS_session", createHashMap];
            private _p = _session getOrDefault ["prompt", []];
            _session deleteAt "prompt";
            if (_p isEqualTo []) exitWith {};
            _p params ["_callback", "_cbArgs", "_ok", "_text"];
            // after the popup is gone, so the callback can open another one
            [{ params ["_callback", "_ok", "_text", "_cbArgs"]; [_ok, _text, _cbArgs] call _callback }, [_callback, _ok, _text, _cbArgs]] call CBA_fnc_execNextFrame;
        }];
    };
    case "ok": {
        if (isNull _popup) exitWith {};
        private _p = _session getOrDefault ["prompt", []];
        if !(_p isEqualTo []) then {
            _p set [2, true];
            _p set [3, ctrlText (_popup displayCtrl FS_IDC_PR_EDIT)];
        };
        _popup closeDisplay 1;
    };
    case "cancel": {
        if (!isNull _popup) then { _popup closeDisplay 2 };
    };
    default {};
};
