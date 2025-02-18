class CfgHints
{
    class PREFIX
    {
        // Topic title (displayed only in topic listbox in Field Manual)
        displayName = "ALiVE Mod";
        class ADDON
        {
            // Hint title, filled by arguments from 'arguments' param
            displayName = "$STR_ALIVE_IED";
            // Optional hint subtitle, filled by arguments from 'arguments' param
            displayNameShort = "$STR_ALIVE_IED";
            // Structured text, filled by arguments from 'arguments' param
            description = "This module simulates a hostile and IED rich environment. IEDs can be hidden in clutter, or be half buried in or around roads. IEDs are usually strategically placed around built up areas.%1%1Players should take extreme caution when moving around towns, villages and settlements. Vehicle-Borne IEDs are also a threat and its not always obvious a vehicle is rigged (although its worth checking). IEDs are typically proximity based, although expect the worse if you disturb or damage such a device.%1%1Only Explosive Specialists or players carrying Mine Detectors can detect and/or disarm IEDs.%1%1IEDs can often be destroyed with controlled explosions or by using large caliber weapons.%1%1Use the Action Menu to Disarm an IED once you are close enough.%1%1In addition if a unit includes the text EOD in its name, they can also detect or disarm IEDs";
            // Optional structured text, filled by arguments from 'arguments' param (first argument is %11, see notes bellow), grey color of text
            tip = "$STR_ALIVE_IED_USAGE";
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

