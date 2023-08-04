if isServer then {
	params ["_logic", "", "_activated"];

	if !_activated exitWith {};

	call (compile preprocessFileLineNumbers "mapmarker\scripts\fn_init.sqf");

	MM_var_ShowAllSides = (_logic getVariable "showAllSides") == 1;
	MM_var_ShowAllSidesOnSpectator = (_logic getVariable "showAllSidesOnSpectator") == 1;
	MM_var_showUnitNames = (_logic getVariable "showUnitNames") == 1;
	MM_var_showUnitNamesOnlyOnHover = (_logic getVariable "showUnitNamesOnlyOnHover") == 1;

	publicVariable "MM_var_ShowAllSides";
	publicVariable "MM_var_ShowAllSidesOnSpectator";
	publicVariable "MM_var_showUnitNames";
	publicVariable "MM_var_showUnitNamesOnlyOnHover";

	call MM_fnc_startMapMarkerServer;
};