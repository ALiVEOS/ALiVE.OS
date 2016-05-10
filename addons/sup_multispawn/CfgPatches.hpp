// Simply a package which requires other addons.
class CfgPatches {
	class ADDON {
		units[] = {};
		weapons[] = {};
		requiredVersion = REQUIRED_VERSION;
		requiredAddons[] = {"ALIVE_main","cba_ui"};
		versionDesc = "ALiVE";
		//versionAct = "['sup_multispawn',_this] execVM '\x\alive\addons\main\about.sqf';";
		VERSION_CONFIG;
		author[] = {"WobbleyHeadedBob"};
		authorUrl = "http://dev-heaven.net/projects/alive";
	};
};
