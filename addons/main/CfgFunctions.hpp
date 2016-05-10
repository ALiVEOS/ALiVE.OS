class cfgFunctions {
	class PREFIX {
		class COMPONENT {
			class buttonAbort {
				description = "Calls any scripts required when the user disconnects";
				file = "\x\alive\addons\main\fnc_buttonAbort.sqf";
				recompile = RECOMPILE;
			};
			class aliveInit {
				description = "ALiVE init function";
				file = "\x\alive\addons\main\fnc_aliveInit.sqf";
				recompile = RECOMPILE;
			};
			class Nuke {
				description = "Fires a Nuke at given position";
				file = "\x\alive\addons\main\fnc_Nuke.sqf";
				recompile = RECOMPILE;
			};
			class isModuleSynced {
				description = "Checks if modules are synced";
				file = "\x\alive\addons\main\fnc_isModuleSynced.sqf";
				recompile = RECOMPILE;
			};
			class isModuleAvailable {
				description = "Checks if modules are available";
				file = "\x\alive\addons\main\fnc_isModuleAvailable.sqf";
				recompile = RECOMPILE;
			};
			class versioning {
				description = "Warns or kicks players on version mismatch";
				file = "\x\alive\addons\main\fnc_versioning.sqf";
				recompile = RECOMPILE;
			};
			class isModuleInitialised {
                description = "Checks if given modules are initialised";
                file = "\x\alive\addons\main\fnc_isModuleInitialised.sqf";
				recompile = RECOMPILE;
			};
			class pauseModule {
                description = "Pauses given module(s)";
                file = "\x\alive\addons\main\fnc_pauseModule.sqf";
				recompile = RECOMPILE;
			};
			class unPauseModule {
                description = "activates given module(s) after pausing";
                file = "\x\alive\addons\main\fnc_unPauseModule.sqf";
				recompile = RECOMPILE;
			};
			class pauseModulesAuto {
                description = "Adds EHs to pause all main modules if no players are on server";
                file = "\x\alive\addons\main\fnc_pauseModulesAuto.sqf";
				recompile = RECOMPILE;
			};
			class ZEUSinit {
				description = "Initialises Zeus for ALiVE";
				file = "\x\alive\addons\main\fnc_ZEUSinit.sqf";
				recompile = RECOMPILE;
			};
			class mainTablet {
                description = "ALiVE Main Tablet";
                file = "\x\alive\addons\main\fnc_mainTablet.sqf";
                recompile = RECOMPILE;
            };
			class AI_Distributor {
                description = "Distributes AI to all headless clients";
                file = "\x\alive\addons\main\fnc_AI_Distributor.sqf";
                recompile = RECOMPILE;
            };
		};
	};
};
