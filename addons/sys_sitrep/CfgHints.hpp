class CfgHints
{
	class PREFIX
	{
		// Topic title (displayed only in topic listbox in Field Manual)
		displayName = "ALiVE Mod";
		class ADDON
		{
			// Hint title, filled by arguments from 'arguments' param
			displayName = "C2ISTAR - Reports";
            // Optional hint subtitle, filled by arguments from 'arguments' param
			displayNameShort = "SITREP and PATROLREP";
			// Structured text, filled by arguments from 'arguments' param
			description = "Allows commanders to submit Situation Reports and Patrol Reports to HQ.  Reports are saved to the database and restored at the beginning of each mission.%1%1%2Open the %3ALiVE Action Menu%4 and select %3C2ISTAR%4 from the list%1%2Select Send SITREPor PATROLREP%1%2 Fill out the appropriate details, including a SITREP position on the map or start/end positions for the PATROLREP.%1%2%3Press SEND%4 to send your report to HQ.";
            // Optional structured text, filled by arguments from 'arguments' param (first argument is %11, see notes bellow), grey color of text
            tip = "Reports automatically record your Grid, Callsign and the Date Time Group in the military format (DDHHmmMMMYY)";
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

