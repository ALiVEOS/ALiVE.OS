class CfgHints
{
	class PREFIX
	{
		// Topic title (displayed only in topic listbox in Field Manual)
		displayName = "ALiVE Mod";
		class ADDON
		{
			// Hint title, filled by arguments from 'arguments' param
			displayName = "Advanced Markers";
            // Optional hint subtitle, filled by arguments from 'arguments' param
			displayNameShort = "APP6A Military Map Symbols";
			// Structured text, filled by arguments from 'arguments' param
			description = "Allows users to mark the map with Advanced Markers with or without a SPOTREP. These markers are saved to the ALiVE database and restored at the restart of a mission.%1%2Press %3CTRL%4 and %3Left Mouse button%4 to add an ALiVE Advanced Marker.%1%1You can also place several Quick markers (without text or a SPOTREP) through shortcuts.%1%2Press %3CTRL%4 and %3.%4 to place a dot marker%1%2Press %3CTRL%4 and %3x%4 to place an objective marker%1%2Press %3CTRL%4 and %3SHIFT /%4 to place a question marker%1%1Note: You must be in DRAW MODE OFF to place Advanced or Quick Markers.%1%1Users may also draw lines, rectangles, arrows, ellipses (without text or SPOTREP). By default drawing on the map is broadcast to all players on your side. This is also available on the briefing screen.%1%2Press the %3[ key%4 to cycle through drawing modes.%1%2Press %3CTRL%4 and the %3Left Mouse button%4 to start drawing%1%2Press the %3UP Arrow%4 to increase the width of a line or angle of a box/ellipse%1%2Press the %3DOWN Arrow%4 to decrease the width of the line or angle of box/ellipse.%1%2Press the %3LEFT Arrow%4 to change color.%1%2Press the %3RIGHT Arrow%4 to change fill (if appropriate).%1%2Press the %3END key%4 to exit drawing mode.%1%2Press %3CTRL%4 and the %3Left Mouse button%4 again to complete drawing.%1%1You can edit/delete any marker placed by:%1%2Press %3CTRL%4 and %3Right Mouse button%4 to delete a marker.%1%2Press %3CTRL%4 and %3Left mouse button%4 on an existing marker to edit it.%1 %1Arrows are not persisted (use an arrow icon marker to persist) and cannot be deleted.";
            // Optional structured text, filled by arguments from 'arguments' param (first argument is %11, see notes bellow), grey color of text
            tip = "You can add a Drawn or Quick marker, then %3CTRL%4 and %3Left Mouse button%4 to edit that marker and convert it to an Advanced Marker";
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

