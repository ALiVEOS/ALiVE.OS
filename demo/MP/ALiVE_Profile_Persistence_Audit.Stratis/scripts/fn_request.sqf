params ["_operation", "_caller"];
if (!isServer || {isNull _caller} || {!isPlayer _caller}) exitWith {};
private _sender = if (isRemoteExecuted) then {remoteExecutedOwner} else {owner _caller};
if (_sender != owner _caller) exitWith {};
if (_sender != 2 && {admin _sender == 0}) exitWith {
    "[PA] Log in as server admin to operate the test fixtures." remoteExec ["systemChat", _sender];
};
if (!PA_ready || {PA_busy}) exitWith {
    "[PA] Tests are not ready, or another operation is running." remoteExec ["systemChat", _sender];
};
if !(_operation in ["roundtrip", "empty", "cloud", "save", "verify", "show", "spawnHooks", "damage", "transport", "orders", "json", "cloudDownloads", "clear"]) exitWith {};
PA_busy = true;
[_operation, _caller] spawn {
    params ["_operation", "_caller"];
    PA_results = [];
    switch (_operation) do {
        case "show": {[_caller] call PA_fnc_show};
        case "spawnHooks": {[] call PA_fnc_spawnValidation};
        case "damage": {[] call PA_fnc_damageValidation};
        case "transport": {[] call PA_fnc_transportValidation};
        case "orders": {[] call PA_fnc_ordersValidation};
        case "json": {[] call PA_fnc_jsonValidation};
        case "cloudDownloads": {[] call PA_fnc_cloudDownloadValidation};
        case "cloud": {
            [{[] call PA_fnc_cloud}, []] call CBA_fnc_directCall;
        };
        case "verify": {
            [{[] call PA_fnc_verify}, []] call CBA_fnc_directCall;
        };
        case "clear": {
            [{
                [ALIVE_profileHandler, "reset"] call ALIVE_fnc_profileHandler;
                private _empty = [] call ALIVE_fnc_hashCreate;
                // Clear ONLY sys_profile and this harness's baseline, retaining
                // any other module records under the same mission key.
                [ALIVE_profileDatahandler, "bulkSave", ["sys_profile", _empty, PA_missionKey, false]] call ALIVE_fnc_Data;
                profileNamespace setVariable [PA_baselineKey, nil];
                saveProfileNamespace;
                PA_fixtures = [];
                "[PA] Test profile save and baseline cleared. Ready for fresh fixtures." remoteExec ["systemChat", 0];
            }, []] call CBA_fnc_directCall;
        };
        default {
            [{[_operation] call PA_fnc_local}, []] call CBA_fnc_directCall;
        };
    };
    PA_busy = false;
};
