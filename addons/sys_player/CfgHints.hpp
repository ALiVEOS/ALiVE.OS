class CfgHints
{
    class PREFIX
    {
        // Topic title (displayed only in topic listbox in Field Manual)
        displayName = "ALiVE Mod";
        // What a player save keeps of the soldiers a player leads: their squad and their High Command teams
        class sys_player_squad
        {
            displayName = "$STR_ALIVE_PLAYER_HINT_SQUAD";
            displayNameShort = "$STR_ALIVE_PLAYER_HINT_SQUAD_SHORT";
            description = "$STR_ALIVE_PLAYER_HINT_SQUAD_DESC";
            tip = "$STR_ALIVE_PLAYER_HINT_SQUAD_TIP";
            arguments[] = {};
            image = "x\alive\addons\ui\logo_alive_square.paa";
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
