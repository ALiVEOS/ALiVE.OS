class CfgHints
{
	class PREFIX
	{
		// Topic title (displayed only in topic listbox in Field Manual)
		displayName = "ALiVE Mod";
		class ADDON
		{
			// Hint title, filled by arguments from 'arguments' param
			displayName = "Logistics - Resupply";
            // Optional hint subtitle, filled by arguments from 'arguments' param
			displayNameShort = "Player Resupply Requests";
			// Structured text, filled by arguments from 'arguments' param
			description = "Allows players to submit requests for vehicles, equipment, combat supplies and reinforcements from the Logistics Commander (LOGCOM).  Supplies are sourced from a common Force Pool used by all friendly Military AI Commanders (OPCOM).%1%1%2Open the %3ALiVE Action Menu%4 and select %3Resupply Requests%4 from the list%1%2Find the desired items and add to the current consignment%1%2Choose a delivery method, select a drop off point on the minimap and Send%1%1AI reinforcements can be added to the consignment either in groups or as individuals.  AI must be given an assignment after they arrive at the drop off location%1%1%2Join - will join the player group%1%2Defend - will occupy defensive positions and remain at that location%1%2Patrol - will commence patrolling and can be tasked by OPCOM.";
            // Optional structured text, filled by arguments from 'arguments' param (first argument is %11, see notes bellow), grey color of text
            tip = "The delivery type determines available capacity.  Land convoys have a much higher capacity than transport planes and you can not airlift tanks!";
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

