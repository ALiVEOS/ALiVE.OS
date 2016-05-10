// Simply a package which requires other addons.
class CfgPatches {
	class ADDON {
		units[] = {};
		weapons[] = {};
		requiredVersion = REQUIRED_VERSION;
		requiredAddons[] = {"ALIVE_fnc_strategic"};
		versionDesc = "ALiVE";
		//versionAct = "['civ_placement',_this] execVM '\x\alive\addons\main\about.sqf';";
		VERSION_CONFIG;
		author[] = {"Wolffy_au"};
		authorUrl = "http://dev-heaven.net/projects/alive";
	};
};
class Extended_InitPost_EventHandlers {
	class ADDON {
		init = QUOTE(call COMPILE_FILE(XEH_postInit));
	};
};

