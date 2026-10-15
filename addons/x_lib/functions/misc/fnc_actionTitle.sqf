#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(actionTitle);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_actionTitle

Description:
The title of an ALiVE scroll-wheel action, in the player's own colour when they asked for one
in Addon Options > ALiVE > Game (Colour ALiVE Actions and Action Colour), and as it is otherwise.
An action whose title already carries its own colour (Disarm IED in red, a civilian's orders in
green) keeps it: the inner colour wins.

The title is coloured when the action is added, so a change to the setting reaches actions
added after it (after a respawn, or the next mission).

Parameters:
String - the title

Returns:
String - the title, coloured or not

Examples:
(begin example)
player addAction [localize "STR_ALIVE_FOB_ACTION_MANAGE" call ALiVE_fnc_actionTitle, { ... }];
(end)

Author:
Jman
---------------------------------------------------------------------------- */

params [["_title", "", [""]]];

if !(missionNamespace getVariable ["ALiVE_prefActionColourOn", false]) exitWith { _title };
private _c = missionNamespace getVariable ["ALiVE_prefActionColour", [0.788, 0.443, 0.157]];
if !(_c isEqualType [] && {count _c >= 3}) exitWith { _title };
format ["<t color='%1'>%2</t>", (_c select [0, 3]) call BIS_fnc_colorRGBtoHTML, _title]
