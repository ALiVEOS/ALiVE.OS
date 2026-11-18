#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsStudioTextBox);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsStudioTextBox

Description:
The text popup (ALiVE_FS_TextBox, 14850) over the studio: a title and a long
read-only text, for the share text and for import notes.

    - "open" [title, text]: shows it;
    - "copy": the text to the clipboard (status S_SHARE_COPIED with its length);
    - "close".

Parameters:
    _op   - STRING - "open", "copy" or "close"
    _args - ARRAY - for "open", [title, text]

Returns:
    Nothing

Examples:
    (begin example)
    ["open", ["Share text", _text]] call ALiVE_fnc_fsStudioTextBox;
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
private _popup = findDisplay FS_IDD_TEXTBOX;

switch (_op) do {
    case "open": {
        _args params [["_title", "", [""]], ["_text", "", [""]]];
        private _studio = _session getOrDefault ["display", displayNull];
        if (isNull _studio) exitWith {};
        if (!isNull _popup) then { _popup closeDisplay 2 };
        _popup = _studio createDisplay "ALiVE_FS_TextBox";
        if (isNull _popup) exitWith {};
        (_popup displayCtrl FS_IDC_TB_TITLE) ctrlSetText _title;
        (_popup displayCtrl FS_IDC_TB_TEXT) ctrlSetText _text;
        _session set ["textBox", _text];
    };
    case "copy": {
        private _text = _session getOrDefault ["textBox", ""];
        copyToClipboard _text;
        [0, "S_SHARE_COPIED", [(count _text) toFixed 0]] call ALiVE_fnc_fsStudioStatus;
    };
    case "close": {
        if (!isNull _popup) then { _popup closeDisplay 2 };
    };
    default {};
};
