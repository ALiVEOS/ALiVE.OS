// Simply a package which requires other addons.
class CfgPatches {
	class ADDON {
		units[] = { };
		weapons[] = { };
		requiredVersion = REQUIRED_VERSION;
		requiredAddons[] = {"ALIVE_main"};
		versionDesc = "ALiVE";
		//versionAct = "['SYS_WEATHER',_this] execVM '\x\alive\addons\main\about.sqf';";
		VERSION_CONFIG;
		author = MODULE_AUTHOR;
		authors[] = {"Jman"};
		authorUrl = "http://alivemod.com/";
	};
};
