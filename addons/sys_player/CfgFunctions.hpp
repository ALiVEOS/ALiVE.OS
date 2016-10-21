class cfgFunctions {
        class PREFIX {
                class COMPONENT {
                        class player {
                                description = "The main class";
                                file = "\x\alive\addons\sys_player\fnc_player.sqf";
                RECOMPILE;
                        };
                        class playerInit {
                                description = "The module initialisation function";
                                file = "\x\alive\addons\sys_player\fnc_playerInit.sqf";
                RECOMPILE;
                        };
                        class playerMenuDef {
                                description = "The module menu definition";
                                file = "\x\alive\addons\sys_player\fnc_playerMenuDef.sqf";
                RECOMPILE;
                        };
                        class getPlayer {
                                description = "Gets player data from the store and applies it to the player object";
                                file = "\x\alive\addons\sys_player\fnc_getPlayer.sqf";
                RECOMPILE;
                        };
                        class setPlayer {
                                description = "Sets player data to the store";
                                file = "\x\alive\addons\sys_player\fnc_setPlayer.sqf";
                                RECOMPILE;
                        };
                        class getGear {
                                description = "Gets loadout data from a store and applies it to the player object";
                                file = "\x\alive\addons\sys_player\fnc_getGear.sqf";
                                RECOMPILE;
                        };
                        class setGear {
                                description = "Sets loadout data to a store";
                                file = "\x\alive\addons\sys_player\fnc_setGear.sqf";
                RECOMPILE;
                        };
                        class player_OnPlayerDisconnected {
                                        description = "The module onPlayerDisconnected handler";
                                        file = "\x\alive\addons\sys_player\fnc_player_onPlayerDisconnected.sqf";
                                        RECOMPILE;
                        };
                        class player_OnPlayerConnected {
                                        description = "The module onPlayerConnected handler";
                                        file = "\x\alive\addons\sys_player\fnc_player_onPlayerConnected.sqf";
                                        RECOMPILE;
                        };
                        class autoStorePlayer {
                                        description = "Checks to see if the player data should be saved to server or DB";
                                        file = "\x\alive\addons\sys_player\fnc_autoStorePlayer.sqf";
                                        RECOMPILE;
                        };
                };
        };
};
