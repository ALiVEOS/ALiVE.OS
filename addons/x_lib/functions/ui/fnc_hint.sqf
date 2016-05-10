#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_hint

Description:
	Hints a message to the player without overwriting other hints.
	
Parameters:
	0 - Hint text [string]
	1 - Text format parameters [array] (optional)
	2 - Hint silent [bool] (optional)
	3 - Hint display duration seconds [number] (optional)

Returns:
	Nothing [nil]

Attributes:
	N/A

Examples:
	N/A

See Also:

Author:
	Naught
---------------------------------------------------------------------------- */

if (hasInterface) then // Don't do anything on non-GUI machines
{
	if (isNil "ALiVE_hintQueue") then {ALiVE_hintQueue = []};
	
	[ALiVE_hintQueue, _this] call ALiVE_fnc_push;
	
	if ((count ALiVE_hintQueue) == 1) then // Run queue
	{
		0 spawn
		{
			while {(count ALiVE_hintQueue) > 0} do
			{
				private ["_curHint", "_text"];
				_curHint = ALiVE_hintQueue select 0;
				_text = format([_curHint select 0] + ([_curHint, 1, ["ARRAY"], []] call ALiVE_fnc_param));
				
				if ([_curHint, 2, ["BOOL"], false] call ALiVE_fnc_param) then // Silent
				{
					hintSilent parseText(_text);
				}
				else // Normal
				{
					hint parseText(_text);
				};
				
				uiSleep([_curHint, 3, ["SCALAR"], (1.5 + ([_text] call ALiVE_fnc_timeToRead))] call ALiVE_fnc_param);
				
				[ALiVE_hintQueue, 0] call ALiVE_fnc_erase;
			};
		};
	};
};
