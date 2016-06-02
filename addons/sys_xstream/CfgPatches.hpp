// Simply a package which requires other addons.
class CfgPatches {
	class ADDON {
		units[] = { };
		weapons[] = { };
		requiredVersion = REQUIRED_VERSION;
		requiredAddons[] = { };
		versionDesc = "ALiVE";
		//versionAct = "['sys_xstream',_this] execVM '\x\alive\addons\main\about.sqf';";
		VERSION_CONFIG;
		author = MODULE_AUTHOR;
		authors[] = { "Tupolov" };
		authorUrl = "http://alivemod.com/";
	};
};
