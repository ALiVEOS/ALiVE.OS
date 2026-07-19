private ["_display","_lb","_index","_asset","_callsign","_grp"];

disableSerialization;
_display = findDisplay 655555;
_tasklb = _display displayctrl 655565;
_task = _tasklb lbText (lbCurSel _tasklb);
if (!isNil "ALiVE_sup_combatsupport_debug" && {ALiVE_sup_combatsupport_debug}) then { ["_task: %1", _task] call ALiVE_fnc_dump; };


switch (toUpper _task) do
{
    case "TRANSPORT" : {
        private ["_transportUnitLb","_transportArray"];

        _transportUnitLb = _display displayCtrl 655568;
        _transportArray = NEO_radioLogic getVariable [format ["NEO_radioTrasportArray_%1", playerSide], []];

        if ((lbCurSel _transportUnitLb) < 0) exitwith {};

        if (!isNil {NEO_radioLogic getVariable "NEO_radioTalkWithPilot"}) then {
            _asset = NEO_radioLogic getVariable "NEO_radioTalkWithPilot";
            _grp = group (driver _asset);
            _callsign = (format ["%1", _grp]) call NEO_fnc_callsignFix;
        }
        else {
            _asset = _transportArray select (lbCurSel _transportUnitLb) select 0;
            _grp = _transportArray select (lbCurSel _transportUnitLb) select 1;
            _callsign = _transportArray select (lbCurSel _transportUnitLb) select 2;
        };
    };
    case "CAS" : {
        private ["_casUnitLb","_casArray"];

        _casUnitLb = _display displayCtrl 655582;
        _casArray = NEO_radioLogic getVariable [format ["NEO_radioCasArray_%1", playerSide], []];

        if ((lbCurSel _casUnitLb) < 0) exitwith {};

        _asset = _casArray select (lbCurSel _casUnitLb) select 0;
        _grp = _casArray select (lbCurSel _casUnitLb) select 1;
        _callsign = _casArray select (lbCurSel _casUnitLb) select 2;
    };
    case "ARTY" : {
        private ["_artyUnitLb","_artyArray"];

        _artyUnitLb = _display displayCtrl 655594;
        
  	    _has_SPE_leFH18 = false;
  	    {
  	    	if(_x select 1 == "SPE_leFH18") then {
  	    		_has_SPE_leFH18 = true;
  	    	}
  	    } forEach SUP_ARTYARRAYS;
  
        _artyArray = []; 
        _artyArray append (NEO_radioLogic getVariable [format ["NEO_radioArtyArray_%1", playerSide], []]);
 
	      if (_has_SPE_leFH18) then { 
	      	if (playerSide != WEST) then {
	        _artyArray append (NEO_radioLogic getVariable [format ["NEO_radioArtyArray_%1", WEST], []]);
	        };
	      };

        if ((lbCurSel _artyUnitLb) < 0) exitwith {};

        _asset = _artyArray select (lbCurSel _artyUnitLb) select 0;
        _grp = _artyArray select (lbCurSel _artyUnitLb) select 1;
        _callsign = _artyArray select (lbCurSel _artyUnitLb) select 2;
    };
};

if (isnil "_asset") exitwith {};

private ["_callSignPlayer","_pos","_assetpos","_ammoArray","_speed"];

_callSignPlayer = (format ["%1", group player]) call NEO_fnc_callsignFix;
_pos = getposATL _asset;
_assetpos = mapGridPosition _pos;
_currentTask = _asset getVariable ["NEO_radioCurrentTask",[]];
_destination = if (count _currentTask > 0) then {_currentTask select 1} else {_pos};
_speed = speed _asset;

private ["_damage","_fuel","_text","_ammo","_avail"];

_damage = getDammage _asset;
_fuel = fuel _asset;
_ammoArray = _asset call ALiVE_fnc_vehicleGetAmmo;
_distance = _destination distance _pos;

// Ammo: mean fill across the asset's magazines. Guard the empty case - unarmed
// transports have no ammo array, which previously divided by zero and poisoned Condition
_ammo = -1;
_avail = 0;
{
    if ((_x select 2) > 0) then { _avail = _avail + ((_x select 1) / (_x select 2)); };
} forEach _ammoArray;
if (count _ammoArray > 0) then { _ammo = _avail / (count _ammoArray) };

_text = format ["%1 this is %2, send SITREP. Over.",_callsign, _callSignPlayer];

[[player, _text, "side"],"NEO_fnc_messageBroadcast",true,false] spawn BIS_fnc_MP;

private ["_damageamcas","_fuelamcas","_amcas","_approxTime","_ammoStr","_statusLabel","_statusValue"];

// Condition = actual battle damage only (previously blended with ammo, so a healthy
// battery low on shells wrongly read as damaged)
_damageamcas = "Green";
    if (_damage > 0.3) then {_damageamcas = "Amber"};
    if (_damage >= 0.6) then {_damageamcas = "Red"};

// Fuel: the mid-band previously tested _damage by mistake, which could blank the field
_fuelamcas = "Red";
    if (_fuel > 0.3) then {_fuelamcas = "Amber"};
    if (_fuel >= 0.6) then {_fuelamcas = "Green"};

// Ammo as an explicit percentage of the asset's magazines; "n/a" for an unarmed asset
_ammoStr = if (_ammo < 0) then {"n/a"} else {format ["%1%2", round (_ammo * 100), "%"]};

// Movement / status field: aircraft report an ETA to their tasking; a ground battery
// does not fly, so it reports its tasking status instead ("taking off"/ETA were nonsense)
_approxTime = "unknown";
    if (_speed > 0 && {(_pos select 2) > 5}) then {_approxTime = format ["%1 min", round((_distance/((_speed)/3.6))/60)]};
    if (_speed > 0 && {(_pos select 2) < 5}) then {_approxTime = "taking off"};
_statusLabel = "ETA";
_statusValue = _approxTime;
if (toUpper _task == "ARTY") then {
    _statusLabel = "Status";
    _statusValue = switch (_asset getVariable ["NEO_radioArtyUnitStatus", ""]) do {
        case "NONE": {"ready to fire"};
        case "MISSION": {"on a fire mission"};
        case "MOVE": {"repositioning into range"};
        case "RTB": {"returning to base"};
        case "RESPONSE": {"out of range"};
        case "NOAMMO": {"out of ammunition"};
        case "KILLED": {"combat ineffective"};
        default {"standing by"};
    };
};

// Military Logistics Simulation status.
// Resupply state lives on the primary vehicle (single source of truth), not the leader / NEO asset,
// because that's the object LOGCOM updates on dispatch completion. Resolve via ALIVE_resupply_primaryVehicle
// and fall back to _asset so Transport/CAS (where _asset IS the vehicle) still works unchanged.
private _stateHolder = _asset getVariable ["ALIVE_resupply_primaryVehicle", _asset];
private _logisticsStatus = "";
if (_asset getVariable ["ALIVE_logistics_enabled", false]) then {
    private _resupplyState = _stateHolder getVariable ["ALIVE_resupply_state", "none"];
    switch (_resupplyState) do {
        case "none": {
            _logisticsStatus = "Logistics: Ready";
        };
        case "dispatched";
        case "enroute": {
            private _eta = _stateHolder getVariable ["ALIVE_resupply_eta", 0];
            private _startTime = _stateHolder getVariable ["ALIVE_resupply_startTime", serverTime];
            private _remaining = (_eta - (serverTime - _startTime)) max 0;
            private _mins = floor (_remaining / 60);
            private _secs = floor (_remaining mod 60);
            private _secsStr = if (_secs < 10) then {format ["0%1", _secs]} else {str _secs};
            _logisticsStatus = format ["Logistics: Resupply en route (ETA %1:%2)", _mins, _secsStr];
        };
        case "servicing": {
            _logisticsStatus = "Logistics: Servicing...";
        };
        case "complete": {
            _logisticsStatus = "Logistics: Complete";
        };
        case "failed": {
            _logisticsStatus = "Logistics: Failed - retrying...";
        };
    };
};

private _logSuffix = if (_logisticsStatus != "") then {format [", %1", _logisticsStatus]} else {""};
_amcas = format ["%1 this is %2! Location: %3, %4: %5, Ammo: %6, Condition: %7, Fuel: %8%9",_callSignPlayer,_callsign,_assetpos,_statusLabel,_statusValue,_ammoStr,_damageamcas,_fuelamcas,_logSuffix];

// Show resupply vehicle marker for currently selected asset.
private _resupplyVeh = _stateHolder getVariable ["ALIVE_resupply_vehicle", objNull];
if (!isNull _resupplyVeh && {alive _resupplyVeh}) then {
    [_resupplyVeh, format ["%1 Resupply", _callsign], "TRANSPORT"] call NEO_fnc_radioCreateMarker;
};

sleep 6;

[[player,_amcas,"side"],"NEO_fnc_messageBroadcast",true,false] spawn BIS_fnc_MP;
