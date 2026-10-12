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
    // ground transport (#690): the transport panel's unit list
    case "GROUND" : {
        private _groundArray = NEO_radioLogic getVariable [format ["NEO_radioGroundArray_%1", playerSide], []];
        private _sel = lbCurSel (_display displayCtrl 655568);
        if (_sel < 0 || {_sel >= count _groundArray}) exitwith {};
        _asset = (_groundArray select _sel) select 0;
        _grp = (_groundArray select _sel) select 1;
        _callsign = (_groundArray select _sel) select 2;
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
_fuel = _asset getVariable ["NEO_casHeldFuel", fuel _asset];   // a CAS plane held on its stand keeps its real figure here
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

_text = ["STR_ALIVE_CS_MSG_SITREP_REQUEST", _callsign, _callSignPlayer];

[[player, _text, "side"],"NEO_fnc_messageBroadcast",true,false] spawn BIS_fnc_MP;

private ["_damageamcas","_fuelamcas","_amcas","_approxTime","_ammoStr","_statusLabel","_statusValue"];

// Condition = actual battle damage only (previously blended with ammo, so a healthy
// battery low on shells wrongly read as damaged)
_damageamcas = "$STR_ALIVE_CS_WORD_GREEN";
    if (_damage > 0.3) then {_damageamcas = "$STR_ALIVE_CS_WORD_AMBER"};
    if (_damage >= 0.6) then {_damageamcas = "$STR_ALIVE_CS_WORD_RED"};

// Fuel: the mid-band previously tested _damage by mistake, which could blank the field
_fuelamcas = "$STR_ALIVE_CS_WORD_RED";
    if (_fuel > 0.3) then {_fuelamcas = "$STR_ALIVE_CS_WORD_AMBER"};
    if (_fuel >= 0.6) then {_fuelamcas = "$STR_ALIVE_CS_WORD_GREEN"};

// Ammo as an explicit percentage of the asset's magazines; "n/a" for an unarmed asset
_ammoStr = if (_ammo < 0) then {"$STR_ALIVE_CS_WORD_NA"} else {format ["%1%2", round (_ammo * 100), "%"]};

// Movement / status field: aircraft report an ETA to their tasking; a ground battery
// does not fly, so it reports its tasking status instead ("taking off"/ETA were nonsense)
// sent as words for each player's own language ($STR_..., or [key, arguments])
_approxTime = "$STR_ALIVE_CS_WORD_UNKNOWN";
    if (_speed > 0 && {(_pos select 2) > 5}) then {_approxTime = ["STR_ALIVE_CS_UI_MINUTES", round((_distance/((_speed)/3.6))/60)]};
    if (_speed > 0 && {(_pos select 2) < 5}) then {_approxTime = "$STR_ALIVE_CS_WORD_TAKING_OFF"};
_statusLabel = "$STR_ALIVE_CS_WORD_ETA";
_statusValue = _approxTime;
if (toUpper _task == "ARTY") then {
    _statusLabel = "$STR_ALIVE_CS_WORD_STATUS";
    _statusValue = "$STR_ALIVE_CS_WORD_ARTY_" + (switch (_asset getVariable ["NEO_radioArtyUnitStatus", ""]) do {
        case "NONE": {"READY"};
        case "MISSION": {"MISSION"};
        case "MOVE": {"MOVE"};
        case "RTB": {"RTB"};
        case "RESPONSE": {"RANGE"};
        case "NOAMMO": {"NOAMMO"};
        case "KILLED": {"KILLED"};
        default {"STANDBY"};
    });
};
// a ground vehicle neither flies nor takes off: it reports what it is doing
if (toUpper _task == "GROUND") then {
    _statusLabel = "$STR_ALIVE_CS_WORD_STATUS";
    _statusValue = if (_asset getVariable ["NEO_groundDisarming", false]) then { "$STR_ALIVE_CS_WORD_GROUND_DISARMING" } else {
        "$STR_ALIVE_CS_WORD_GROUND_" + (_asset getVariable ["NEO_radioGroundUnitStatus", "NONE"])
    };
};

// Military Logistics Simulation status.
// Resupply state lives on the primary vehicle (single source of truth), not the leader / NEO asset,
// because that's the object LOGCOM updates on dispatch completion. Resolve via ALIVE_resupply_primaryVehicle
// and fall back to _asset so Transport/CAS (where _asset IS the vehicle) still works unchanged.
private _stateHolder = _asset getVariable ["ALIVE_resupply_primaryVehicle", _asset];
private _logisticsStatus = [];
if (_asset getVariable ["ALIVE_logistics_enabled", false]) then {
    private _resupplyState = _stateHolder getVariable ["ALIVE_resupply_state", "none"];
    switch (_resupplyState) do {
        case "none": {
            _logisticsStatus = ["STR_ALIVE_CS_LOG_READY"];
        };
        case "dispatched";
        case "enroute": {
            private _eta = _stateHolder getVariable ["ALIVE_resupply_eta", 0];
            private _startTime = _stateHolder getVariable ["ALIVE_resupply_startTime", serverTime];
            private _remaining = (_eta - (serverTime - _startTime)) max 0;
            private _mins = floor (_remaining / 60);
            private _secs = floor (_remaining mod 60);
            private _secsStr = if (_secs < 10) then {format ["0%1", _secs]} else {str _secs};
            _logisticsStatus = ["STR_ALIVE_CS_LOG_ENROUTE", _mins, _secsStr];
        };
        case "servicing": {
            _logisticsStatus = ["STR_ALIVE_CS_LOG_SERVICING"];
        };
        case "complete": {
            _logisticsStatus = ["STR_ALIVE_CS_LOG_COMPLETE"];
        };
        case "failed": {
            _logisticsStatus = ["STR_ALIVE_CS_LOG_FAILED"];
        };
    };
};

private _logSuffix = if (_logisticsStatus isNotEqualTo []) then {["STR_ALIVE_CS_LOG_SUFFIX", _logisticsStatus]} else {""};
_amcas = ["STR_ALIVE_CS_MSG_SITREP",_callSignPlayer,_callsign,_assetpos,_statusLabel,_statusValue,_ammoStr,_damageamcas,_fuelamcas,_logSuffix];

// Show resupply vehicle marker for currently selected asset.
private _resupplyVeh = _stateHolder getVariable ["ALIVE_resupply_vehicle", objNull];
if (!isNull _resupplyVeh && {alive _resupplyVeh}) then {
    [_resupplyVeh, format ["%1 Resupply", _callsign], "TRANSPORT"] call NEO_fnc_radioCreateMarker;
};

sleep 6;

[[player,_amcas,"side"],"NEO_fnc_messageBroadcast",true,false] spawn BIS_fnc_MP;
