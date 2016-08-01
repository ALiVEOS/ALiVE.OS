class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class player {
                          description = "The main class";
                          file = PATHTO_FUNC(player);
                          recompile = RECOMPILE;
                        };
                        class playerInit {
                          description = "The module initialisation function";
                          file = PATHTO_FUNC(playerInit);
                          recompile = RECOMPILE;
                        };
                        class playerMenuDef {
                          description = "The module menu definition";
                          file = PATHTO_FUNC(playerMenuDef);
                          recompile = RECOMPILE;
                        };
                        class getPlayer {
                          description = "Gets player data from the store and applies it to the player object";
                          file = PATHTO_FUNC(getPlayer);
                          recompile = RECOMPILE;
                        };
                        class setPlayer {
                          description = "Sets player data to the store";
                          file = PATHTO_FUNC(setPlayer);
                          recompile = RECOMPILE;
                        };
                        class getGear {
                          description = "Gets loadout data from a store and applies it to the player object";
                          file = PATHTO_FUNC(getGear);
                          recompile = RECOMPILE;
                        };
                        class setGear {
                          description = "Sets loadout data to a store";
                          file = PATHTO_FUNC(setGear);
                          recompile = RECOMPILE;
                        };
                        class player_OnPlayerDisconnected {
                          description = "The module onPlayerDisconnected handler";
                          file = PATHTO_FUNC(player_onPlayerDisconnected);
                          recompile = RECOMPILE;
                        };
                        class player_OnPlayerConnected {
                          description = "The module onPlayerConnected handler";
                          file = PATHTO_FUNC(player_onPlayerConnected);
                          recompile = RECOMPILE;
                        };
                        class autoStorePlayer {
                          description = "Checks to see if the player data should be saved to server or DB";
                          file = PATHTO_FUNC(autoStorePlayer);
                          recompile = RECOMPILE;
                        };
                };
        };
};
