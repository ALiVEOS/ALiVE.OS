class CfgHints
{
	class PREFIX
	{
		// Topic title (displayed only in topic listbox in Field Manual)
		displayName = "ALiVE Mod";
		class ADDON
		{
			// Hint title, filled by arguments from 'arguments' param
			displayName = "$STR_ALIVE_LOGISTICS";
            // Optional hint subtitle, filled by arguments from 'arguments' param
			displayNameShort = "$STR_ALIVE_LOGISTICS";
			// Structured text, filled by arguments from 'arguments' param
			description = "ALiVE Player Logistics is %3ON by default%4.  This allows players to lift, move and stow objects in cargo vehicles as well as tow or heli lift light vehicles and boats.  Player Logistics can be completely disabled by placing the %3Disable Logistics%4 module in the editor. The logistics actions must be enabled by the player in game.%1%1%2Open the %3ALiVE Action Menu%4 and select %3Player Logistics%4 from the list%1%2Approach a movable object such as an ammo crate and use the BIS Action Menu item to lift it%1%2Drop the object within 2m of a suitable cargo vehicle.%1%2Approach the cargo vehicle and select Load from the BIS Action Menu%1%1Use the same technique for towing or heli lifting vehicles.  Take care to ensure the area around the cargo vehicle is clear of unneeded objects before loading.";
            // Optional structured text, filled by arguments from 'arguments' param (first argument is %11, see notes bellow), grey color of text
            tip = "$STR_ALIVE_LOGISTICSDISABLE_USAGE";
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

