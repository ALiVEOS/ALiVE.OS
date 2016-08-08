class cfgFunctions {
    class PREFIX {
        class COMPONENT {
            FUNC_FILEPATH(player,"The main class");
            FUNC_FILEPATH(playerInit,"The module initialisation function");
            FUNC_FILEPATH(playerMenuDef,"The module menu definition");
            FUNC_FILEPATH(getPlayer,"Gets player data from the store and applies it to the player object");
            FUNC_FILEPATH(setPlayer,"Sets player data to the store");
            FUNC_FILEPATH(getGear,"Gets loadout data from a store and applies it to the player object");
            FUNC_FILEPATH(setGear,"Sets loadout data to a store");
            FUNC_FILEPATH(player_OnPlayerDisconnected,"The module onPlayerDisconnected handler");
            FUNC_FILEPATH(player_OnPlayerConnected,"The module onPlayerConnected handler");
            FUNC_FILEPATH(autoStorePlayer,"Checks to see if the player data should be saved to server or DB");
        };
    };
};
