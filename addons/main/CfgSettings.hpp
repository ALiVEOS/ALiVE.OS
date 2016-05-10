class CfgSettings {
	class CBA {
		class Versioning {
			// This registers ACME with the versioning system and looks for version info at CfgPatches -> MyMod_main
			class ADDON {
				// Optional: Manually specify the Main Addon for this mod
				main_addon = "ALiVE_main"; // Uncomment and specify this to manually define the Main Addon (CfgPatches entry) of the mod

				// Optional: Add a custom handler function triggered upon version mismatch
				handler = "ALiVE_fnc_versioning"; // Adds a custom script function that will be triggered on version mismatch. Make sure this function is compiled at a called preInit, not spawn/execVM

				// Optional: Dependencies
				// Example: Dependency on CBA
				class Dependencies {
					CBA[] = { "cba_main", { 1, 0, 0 }, "true" };
					XEH[] = { "cba_xeh", { 1, 0, 0 }, "true" };
				};

				// Optional: Removed addons Upgrade registry
				// Example: myMod_addon1 was removed and it's important the user doesn't still have it loaded
				//removed[] = {"myMod_addon1"};
			};
		};
	};

	class ADDON {
		// Server Settings - this should really be read from file (ACE does this with sys_settings)
		class ALiVE_server_settings {
			checkpbos = 1;
			checklist[] = { };
			check_all_ALiVE_pbos = 1;
			exclude_pbos[] = { };
		};
	};
};
