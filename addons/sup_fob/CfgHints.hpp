class CfgHints
{
    class PREFIX
    {
        // Topic title (displayed only in topic listbox in Field Manual)
        displayName = "ALiVE Mod";
        // Putting up a FOB from its kit, and the FOB types a mission can offer
        class sup_fob_deploy
        {
            displayName = "$STR_ALIVE_FOB_HINT_DEPLOY";
            displayNameShort = "$STR_ALIVE_FOB_HINT_DEPLOY_SHORT";
            description = "$STR_ALIVE_FOB_HINT_DEPLOY_DESC";
            tip = "$STR_ALIVE_FOB_HINT_DEPLOY_TIP";
            arguments[] = {};
            image = "x\alive\addons\ui\logo_alive_square.paa";
            noImage = false;
        };
        // The Build Menu: favourites, placing one after another, tiers
        class sup_fob_build
        {
            displayName = "$STR_ALIVE_FOB_HINT_BUILD";
            displayNameShort = "$STR_ALIVE_FOB_HINT_BUILD_SHORT";
            description = "$STR_ALIVE_FOB_HINT_BUILD_DESC";
            tip = "$STR_ALIVE_FOB_HINT_BUILD_TIP";
            arguments[] = {};
            image = "x\alive\addons\ui\logo_alive_square.paa";
            noImage = false;
        };
    };
};

/*
    Variables %1 - %4: %1 small empty line, %2 bullet, %3 highlight start, %4 highlight end
*/
