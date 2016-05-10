// Simply a package which requires other addons.
class CfgPatches {
	class ADDON {
		units[] = {};
		weapons[] = {};
		requiredVersion = REQUIRED_VERSION;
		requiredAddons[] = {"ALIVE_fnc_strategic","ALIVE_fnc_analysis"};
		versionDesc = "ALiVE";
		//versionAct = "['mil_logistics',_this] execVM '\x\alive\addons\main\about.sqf';";
		VERSION_CONFIG;
		author[] = {"ARJay"};
		authorUrl = "http://dev-heaven.net/projects/alive";
	};
};
class Extended_InitPost_EventHandlers {
	class ADDON {
		init = QUOTE(call COMPILE_FILE(XEH_postInit));
	};
};

