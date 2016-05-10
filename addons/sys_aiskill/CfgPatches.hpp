// Simply a package which requires other addons.
class CfgPatches {
	class ADDON {
		units[] = { };
		weapons[] = { };
		requiredVersion = REQUIRED_VERSION;
		requiredAddons[] = { };
		versionDesc = "ALiVE";
		//versionAct = "['sys_aiskill',_this] execVM '\x\alive\addons\main\about.sqf';";
		VERSION_CONFIG;
		author[] = { "ARJay","Jman" };
		authorUrl = "http://dev-heaven.net/projects/alive";
	};
};
class Extended_InitPost_EventHandlers {
	class ADDON {
		init = QUOTE(call COMPILE_FILE(XEH_postInit));
	};
};

