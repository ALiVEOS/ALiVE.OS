class CfgHints
{
	class PREFIX
	{
		// Topic title (displayed only in topic listbox in Field Manual)
		displayName = "ALiVE Mod";
		class ADDON
		{
			// Hint title, filled by arguments from 'arguments' param
			displayName = "Combat Support";
            // Optional hint subtitle, filled by arguments from 'arguments' param
			displayNameShort = "CAS, OS, Transport";
			// Structured text, filled by arguments from 'arguments' param
			description = "Combat Support provides an interface for players to request AI piloted Close Air Support from helicopters and aircraft, Offensive Support from artillery and mortars, and battlefield transport from Support Helicopters.%1%1%2Open the %3ALiVE Action Menu%4 and select %3Combat Support%4%%12Choose from one of the available support elements%1%2Select an available support type and associated options%1%2Click the minimap to set the area of operations%1%2Submit the request to HQ%1%1For best results, order CAS aircraft to loiter at a safe holding area before commencing an attack run as they will return to this location afterwards.%1Aircraft on %3Attack%4 or %3Search and Destroy%4 tasks will engage laser designator spots as a priority.%1Support Helicopters will attempt to land at the nearest clear area to the indicated landing site.  For greater control, use the Pick Up option and mark the LZ with smoke.";
            // Optional structured text, filled by arguments from 'arguments' param (first argument is %11, see notes bellow), grey color of text
            tip = "Support may take some time to arrive on station.  Users can click the %3SITREP%4 button to get a report from Support on location and state.";
			arguments[] = {
				{{"getOver"}},  // Double nested array means assigned key (will be specially formatted)
                {"name"},       // Nested array means element (specially formatted part of text)
				"name player"   // Simple string will be simply compiled and called
                                // String is used as a link to localization database in case it starts by str_
			};
			// Optional image
			image = "x\alive\addons\ui\logo_alive_square.paa";
			// optional parameter for not showing of image in context hint in mission (default false))
			noImage = false;
		};
	};
};

/*

    First item from arguments field in config is inserted in text via variable %11, second item via %12, etc.
    Variables %1 - %10 are hardcoded:
         %1 - small empty line
         %2 - bullet (for item in list)
         %3 - highlight start
         %4 - highlight end
         %5 - warning color formated for using in structured text tag
         %6 - BLUFOR color attribute
         %7 - OPFOR color attribute
         %8 - Independent color attribute
         %9 - Civilian color attribute
         %10 - Unknown side color attribute
    color formated for using in structured text is string: "color = 'given_color'"
*/

