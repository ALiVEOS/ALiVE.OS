// Simply a package which requires other addons.
class CfgPatches {
	class ADDON {
		units[] = {};
		weapons[] = {"Tablet"};
		requiredVersion = REQUIRED_VERSION;
		requiredAddons[] = {"A3_Weapons_F"};
		versionDesc = "ALiVE";
		//versionAct = "['c_tablet',_this] execVM '\x\alive\addons\main\about.sqf';";
		VERSION_CONFIG;
		author[] = {"Tupolov"};
		authorUrl = "http://dev-heaven.net/projects/alive";
	};
};


