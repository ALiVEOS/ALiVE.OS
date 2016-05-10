private ["_smoke", "_color"];
_smoke = _this;
_color = switch (typeOf _smoke) do
{
	case "SmokeShell" : { "white" };
	case "SmokeShellRed": { "red" };
	case "SmokeShellGreen": { "green" };
	case "SmokeShellYellow": { "yellow" };
	case "SmokeShellPurple": { "purple" };
	case "SmokeShellBlue": { "blue" };
	case "SmokeShellOrange": { "orange" };
	case "3Rnd_Smoke_Grenade_shell": { "white" };
	case "3Rnd_SmokeRed_Grenade_shell": { "red" };
	case "3Rnd_SmokeGreen_Grenade_shell": { "green" };
	case "3Rnd_SmokeBlue_Grenade_shell": { "blue" };
	case "3Rnd_SmokeOrange_Grenade_shell": { "orange" };
	case "3Rnd_SmokePurple_Grenade_shell": { "purple" };
	case "3Rnd_SmokeYellow_Grenade_shell": { "yellow" };
	case "1Rnd_SmokeBlue_Grenade_shell": { "blue" };
	case "1Rnd_SmokeGreen_Grenade_shell": { "green" };
	case "1Rnd_SmokeOrange_Grenade_shell": { "orange" };
	case "1Rnd_SmokeRed_Grenade_shell": { "red" };
	case "1Rnd_Smoke_Grenade_shell": { "white" };
	case "1Rnd_SmokeYellow_Grenade_shell": { "yellow" };
	case DEFAULT { "white" };
};

_color;
