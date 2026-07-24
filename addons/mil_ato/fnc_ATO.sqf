//#define DEBUG_MPDE_FULL
#include "\x\alive\addons\mil_ato\script_component.hpp"
SCRIPT(ATO);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ATO
Description:
Military Air Tasking Orders

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Nil - init - Initiate instance
Nil - destroy - Destroy instance
Boolean - debug - Debug enabled
Array - state - Save and restore module state
Array - faction - Faction associated with module

Examples:
[_logic, "debug", true] call ALiVE_fnc_ATO;

See Also:
- <ALIVE_fnc_ATOInit>
- The Slowest Arma Module Ever Written

Author:
Tupolov & Jman
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_ATO
#define MTEMPLATE "ALiVE_ATO_%1"
#define DEFAULT_FACTION "OPF_F"
#define DEFAULT_AIRSPACE []
#define DEFAULT_PILOTBUILDING ""
#define DEFAULT_RUNWAYSTARTPOS ""
#define DEFAULT_RUNWAYENDPOS ""
#define DEFAULT_RUNWAYWIDTH ""
#define DEFAULT_EVENT_QUEUE []
#define DEFAULT_ANALYSIS []
#define DEFAULT_SIDE "EAST"
// #460 Phase B - how long to wait for a LOGCOM replacement before giving up on it.
// LOGCOM has no failure callback for an AI requester (all its response messages are
// gated on _playerRequested), so a request that dies quietly - force pool exhausted,
// no valid class for the faction, event cancelled - can only be detected by timeout.
#define ATO_RESUPPLY_TIMEOUT 1800
// "AS" was listed here for years but has no implementation anywhere - no branch
// in any switch, and nothing raises it - so it fell through to a plain loiter.
// Removed so this agrees with the Eden picker, which only offers types that exist.
#define DEFAULT_ATO_TYPES ["CAP","DCA","SEAD","CAS","Strike","Recce","OCA"]
#define DEFAULT_REGISTRY_ID ""
#define DEFAULT_OP_HEIGHT 750
#define DEFAULT_OP_DURATION 25
#define DEFAULT_SPEED "NORMAL"
#define DEFAULT_MIN_WEAP_STATE 0.5
#define DEFAULT_MIN_FUEL_STATE 0.5
#define DEFAULT_RADAR_HEIGHT 105
#define DEFAULT_WAIT_TIME 60
#define WAIT_TIME_CAS 10
#define WAIT_TIME_DCA 30
#define WAIT_TIME_CAP 60
#define WAIT_TIME_SEAD 60
#define WAIT_TIME_Strike 90
#define WAIT_TIME_Recce 90
#define CHANCE_OF_RESCUE 1


TRACE_1("ATO - input",_this);

params [
    ["_logic", objNull, [objNull]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];

ALiVE_fnc_catapultLaunch = {
   params [
        ["_vehicle", objNull, [objNull]],
        ["_catapult", [], [[]]]
    ];

    private _result = false;

    private _part = [_catapult, "part",objNull] call ALiVE_fnc_hashGet;
    private _animations = [_catapult, "animations",[]] call ALiVE_fnc_hashGet;
    private _partMemPoint = [_catapult, "memoryPoint",[]] call ALiVE_fnc_hashGet;
    private _catPos = [_catapult, "position",getposASL _vehicle] call ALiVE_fnc_hashGet;
    private _catDir = [_catapult, "dirOffset", direction _part] call ALiVE_fnc_hashGet;
    private _ldir = [(direction _part) + 180 - _catDir] call ALiVE_fnc_modDegrees;
    _vehicle setDir _ldir;
    //_vehicle setposASL _catPos;

    if (alive _vehicle) then {

        // Launch aircraft
        [_part, _animations, _vehicle] spawn {
            params [
                ["_part", objNull, [objNull]],
                ["_animations", [], [[]]],
                ["_vehicle", objNull, [objNull]]
            ];

            [_part, _animations, 10] call BIS_fnc_Carrier01AnimateDeflectors;

            sleep 3;

            (driver _vehicle) disableAI "MOVE";
            _vehicle setFuel 1;
            private _startpos = getPosWorld _vehicle;
            private _startdir = getdir _vehicle;
            private _starttime = time + 6;
            _vehicle engineOn true;
            _vehicle allowDamage false;

            WaitUntil {
                _vehicle setPosWorld _startpos;
                _vehicle setDir _startdir;
                time >= _starttime
            };

            (driver _vehicle) enableAI "MOVE";
            [_vehicle, _startdir] spawn BIS_fnc_AircraftCatapultLaunch;

            sleep 2.2;

            if (((getposASLW _vehicle) select 2) < 24) then {
                private _vel = velocity _vehicle;
                private _dir = direction _vehicle;
                _vehicle setVelocity [
                    (_vel select 0) + (sin _dir * 70),
                    (_vel select 1) + (cos _dir * 70),
                    (_vel select 2) + 50
                ];
            };
            sleep 4;

            [_part, _animations, 0] spawn BIS_fnc_Carrier01AnimateDeflectors;

            _vehicle allowDamage true;
        };

        _result = true;
    } else {
        _result = false;
    };

    _result
};

ALiVE_fnc_getAirportTaxiPos = {
    params [
        ["_airportID", 0, [0]],
        ["_taxiPos", "ilsTaxiIn", [""]], // ilsTaxiIn  ilsTaxisOff  ilsPosition
        ["_scope", 0, [0]],
        // Optional. Where to look for a runway on the ground when the terrain
        // config has no ILS data. Omit it and behaviour is exactly as before.
        ["_nearPos", [], [[]]]
    ];

    private _result = [];

    if (_airportID == 0) then {
        _result = getArray(configFile >> "cfgWorlds" >> WorldName >> _taxiPos);
    };

    if ( (_airportID > 0) && (_airportID < 100) ) then {
        _result = getArray(((configFile >> "cfgWorlds" >> WorldName >> "SecondaryAirports") select (_airportID-1)) >> _taxiPos);
    };

    if (_airportID > 99) then {
        // is a dynamic runway
        private _runway = ALiVE_Carriers select (_airportID - 100);

        _result = getArray(configFile >> "CfgVehicles" >> typeOf _runway >> _taxiPos);
        for "_i" from 0 to (count _result-1) step 2 do {
            private _pos = _runway modelToWorld [(_result select _i), (_result select _i+1), 0];
            _result set [_i, _pos select 0];
            _result set [_i+1, _pos select 1];
        };
    };

    // The terrain config had nothing for this airport. Rather than give up, use
    // the runway ALiVE can actually see on the ground - the same geometry that
    // already keeps compositions and parked aircraft off it. The two ends of the
    // centreline fit the shape callers expect: first coordinate pair is a
    // position, second pair gives them a heading down the strip.
    //
    // This is what makes a terrain with no airport in its config usable for
    // takeoff at all, instead of throwing on an empty array.
    if (count _result == 0 && {count _nearPos > 1}) then {
        private _centreline = [_nearPos, 1500] call ALiVE_fnc_getRunwayCentreline;
        if (count _centreline > 1) then {
            private _clA = _centreline select 0;
            private _clB = _centreline select 1;

            // Work from whichever end is closer, so an aircraft does not start
            // by crossing the whole airfield.
            if (_clB distance2D _nearPos < _clA distance2D _nearPos) then {
                private _swap = _clA;
                _clA = _clB;
                _clB = _swap;
            };

            _result = [_clA select 0, _clA select 1, _clB select 0, _clB select 1];
        };
    };

    if (_scope != 0) then {
        // Resizing UP pads the array with nil, and every caller selects straight
        // into the result - so an airport with no ILS data in its config handed
        // back [nil,nil,nil,nil] and surfaced as script errors downstream rather
        // than a clean "no taxi position available". Return nothing instead.
        if (count _result >= _scope) then {
            _result resize _scope;
        } else {
            _result = [];
        };
    };

    _result
};

ALiVE_fnc_getNearestCatapult = {
    params [
        ["_pos", [], [[]]],
        ["_isUCAV", false, [false]]
    ];

    private _result = [];

    private _carrier = nearestObjects [_pos,["StaticShip"],400] select 0;
    if (isNil "_carrier") exitWith {_result};

    private _parts = getArray(configFile >> "CfgVehicles" >> typeof _carrier >> "multiStructureParts");
    if (count _parts == 0) exitWith {_result};

    private _catapults = [] call ALiVE_fnc_hashCreate;
    private _catapultsPos = [];
    {
        private _part = _x select 0;
        if (isClass (configFile >> "CfgVehicles" >> _part >> "Catapults")) then {

            private _tmp = [configFile >> "CfgVehicles" >> _part >> "Catapults"] call ALiVE_fnc_configProperties;

            private _addHash = {
                private _partObject = nearestObjects [_pos,[_part],400] select 0;
                private _partMemPoint = [_value, "memoryPoint"] call ALiVE_fnc_hashGet;
                private _partOffset = _partObject selectionPosition _partMemPoint;
                private _position = _partObject modelToWorld _partOffset;

                // Check to see if object is suitable for Carrier catapults
                if !(_partMemPoint == "pos_catapult_04" || _partMemPoint == "pos_catapult_01") then { // Planes have tendency to crash when launching from outside catapults
                    _catapultsPos pushback [_key, _position];
                    [_value, "part", _partObject] call ALiVE_fnc_hashSet;
                    [_value, "position", _position] call ALiVE_fnc_hashSet;
                    [_catapults, _key, _value] call ALiVE_fnc_hashSet;
                };
            };

            [_tmp, _addHash] call CBA_fnc_hashEachPair;

        };
    } forEach _parts;

    if (count _catapultsPos == 0) exitWith {_result};

    private _tmp = [
                _catapultsPos,
                [_pos],
                {
                    _Input0 distance (_x select 1);
                },
                "ASCEND"
            ] call ALiVE_fnc_SortBy;

    _result = [_catapults, (_tmp select 0) select 0] call ALiVE_fnc_hashGet;

    _result
};

ALiVE_fnc_isVTOL = {
    params [
        ["_class", "", ["",objNull]]
    ];
    if (_class isEqualType objNull) then {_class = typeof _class};

    // vtol 0 = none, 1 = VTOL, 2 = STOVL, 3 = Semi VTOL, 4 = STOSL?
    private _result = getNumber(configFile >> "CfgVehicles" >> _class >> "vtol");
    _result
};

// ALiVE_fnc_getAircraftRoles now lives in x_lib beside the capability scan it
// builds on, so mil_placement can consult it while placing aircraft. Defined
// here, it did not exist until this module had run.

// Retained as a thin wrapper so anything still calling it keeps working. The
// real test now lives in x_lib as ALiVE_fnc_isAntiAirCapable, because the player
// suppression task in mil_c2istar needs the same answer and cannot reach a
// function defined inside this module.
ALiVE_fnc_isAntiAir = {
    params [
        ["_class", "", ["",objNull]]
    ];

    [_class] call ALiVE_fnc_isAntiAirCapable
};

ALiVE_fnc_DrawRunwayBlacklistMarkers = {
    params [
    	  ["_pos", [0,0,0], [[]]],
    	  ["_color", "COLORRED", [""]]
    ];

	  private ["_airportID","_markerExists","_markerList","_alpha","_height","_runwayStartPos","_runwayEndPos","_mkrname","_marker"];
    _markerList = []; 
    
    _runwayStartPos = [_logic, "runwaystartpos"] call MAINCLASS;
    _runwayEndPos = [_logic, "runwayendpos"] call MAINCLASS;
    _height = [_logic, "runwaywidth"] call MAINCLASS;
    
    if (isNil "_runwayStartPos") then {
	     // DEBUG -------------------------------------------------------------------------------------
	     if(_debug) then {
	  	   ["ATO - _runwayStartPos is empty!"] call ALiVE_fnc_dump;
	     };
	     // DEBUG ------------------------------------------------------------------------------------- 
    } else {
	    _runwayStartPos = call compile _runwayStartPos;
	    _runwayEndPos = call compile _runwayEndPos;
	    _height = parseNumber _height;
	    if !(isNil "_runwayStartPos") then {
			    if ((count _runwayStartPos > 0) && (count _runwayEndPos > 0) && (_height > 0)) then {
			       // DEBUG -------------------------------------------------------------------------------------
			       if(_debug) then {
			         ["ATO - Runway Start Position: %1(%4), Runway End Position: %2(%5), Runway Width: %3(%6)", _runwayStartPos, _runwayEndPos, _height, typeName _runwayStartPos, typeName _runwayEndPos, typeName _height] call ALiVE_fnc_dump;
			       };
			       // DEBUG ------------------------------------------------------------------------------------- 
			       if(_debug) then {_alpha = 0.5;} else {_alpha = 0;};
			        _airportID = [_pos] call ALiVE_fnc_getNearestAirportID; 
			        _mkrname = "runway_"+(str _airportID); 
			        _markerExists = [_mkrname] call ALIVE_fnc_markerExists;
			       if (_markerExists) then {
			        _marker = _mkrname;
			       } else {
			        _marker = [_mkrname, _runwayStartPos, _runwayEndPos, _height, _color, _alpha] call ALIVE_fnc_createLineMarker;
					   };
					   _markerList pushback _marker;
				     // DEBUG -------------------------------------------------------------------------------------
				     if(_debug) then {
				  	   ["ATO - Runway ID: %1, Marker Exists?: %2, Marker Name: %3",_airportID,_markerExists,_mkrname] call ALiVE_fnc_dump;
				  	   if (!_markerExists) then { ["ATO - Runway Start Position: %1, Runway End Position: %2", _runwayStartPos, _runwayEndPos] call ALiVE_fnc_dump; };
				  	   ["ATO - Runway Marker: %1", _marker] call ALiVE_fnc_dump;
				  	   ["ATO - Runway Marker List: %1", _markerList] call ALiVE_fnc_dump;
				     };
				     // DEBUG ------------------------------------------------------------------------------------- 
				  } else {
				  	 if(_debug) then {
				  		 ["ATO - No runway blacklist marker positions defined"] call ALiVE_fnc_dump;
				     };
				  };
		  } else {
		  	 if(_debug) then {
		  	   ["ATO - No runway blacklist marker positions defined"] call ALiVE_fnc_dump;
		  	 };
		  };
	  };
		_markerList
};

ALiVE_fnc_CheckSpawnInMarkerArea = {
    params [
    	  ["_markers", [], [[]]],
    	  ["_pos", [0,0,0], [[]]],
        ["_size", 0, [0]]
    ];
    
     private ["_flatPos","_inArea"];
     
     _inArea = false;      
     _flatPos = [_pos,(_size*4),70] call ALiVE_fnc_findFlatArea;
      
        if (count (_markers) > 0) then {
	       // DEBUG -------------------------------------------------------------------------------------
	       if(_debug) then {
	  	    ["ATO - ALiVE_fnc_CheckSpawnInMarkerArea() -> _markers: %1, _pos: %2, _size: %3", _markers, _pos, _size] call ALiVE_fnc_dump;
	  	    ["ATO - ALiVE_fnc_CheckSpawnInMarkerArea() -> _flatPos: %1", _flatPos] call ALiVE_fnc_dump;
	       };
	       // DEBUG ------------------------------------------------------------------------------------- 
         {
         	if ([_flatPos, _x] call ALiVE_fnc_inArea) exitWith {
         		_inArea = true;
	             // DEBUG -------------------------------------------------------------------------------------
	             if(_debug) then {
	             	["ATO - ALiVE_fnc_CheckSpawnInMarkerArea() -> _flatPos is _inArea (%1)", _inArea] call ALiVE_fnc_dump;
	             	["ATO - ALiVE_fnc_CheckSpawnInMarkerArea() -> Retrying Position generation..."] call ALiVE_fnc_dump;
	             };
	             // DEBUG ------------------------------------------------------------------------------------- 
	           _flatPos = [_markers,_pos,_size] call ALiVE_fnc_CheckSpawnInMarkerArea;
          };
         } forEach _markers;
        };
        
       _flatPos
};




private _result = true;

// Is this a drone? Accepts a class name or a live vehicle.
//
// Testing isKindOf "UAV" on its own is not enough and getting this wrong is
// expensive. Only the Greyhawk, the UAV_04 and the Sentinel families actually
// descend from the "UAV" base class. Nineteen other stock drones do not,
// including the AR-2 Darter, the Falcon and the whole UAV_06 family, so a
// narrow test sees them as ordinary aircraft.
//
// That mattered because the commander adopted them with the broad test and then
// crewed them with the narrow one, so those drones were tasked and spawned but
// never given an operator. They sat inert on the taxiway holding their slot, and
// every aircraft tasked behind them queued up and never launched.
//
// Every drone test in this file goes through here so the two halves cannot drift
// apart again.
private _fnc_isDroneClass = {
    params [["_v", "", ["", objNull]]];
    if (_v isEqualType objNull) then { _v = typeOf _v };
    if (_v == "") exitWith { false };
    (_v isKindOf "UAV") || {getNumber (configFile >> "CfgVehicles" >> _v >> "isUav") == 1}
};

// Safe reposition for recycled / aborted aircraft: stops the airframe detonating
// when it is teleported back into its hangar slot (the spawn position sits inside
// the hangar shell). If a sibling already occupies the slot, drop into a clear
// nearby spot instead of stacking. Damage is disabled across the move and
// re-enabled (with the maintenance repair applied) once the engine has settled
// any overlap - setDamage is blocked while allowDamage is false.
private _fnc_safeReposition = {
    params ["_veh", "_pos", ["_dir", -1]];
    // Null-safe: de-virtualized / destroyed profiles yield objNull here (the RPT `type= empty` no-op).
    if (isNull _veh || {!alive _veh}) exitWith {};
    // Never move an airframe a player is sitting in. Everything below is a
    // teleport: setPosATL onto the parking slot, attitude forced upright and
    // velocity zeroed. Done to an aircraft somebody is flying, that is a yank
    // out of the sky onto the apron. Leaving it where it is costs the commander
    // one parking slot; the alternative costs a player their aircraft.
    if ((crew _veh) findIf {isPlayer _x} > -1) exitWith {
        diag_log format ["ATO_HANGAR_DBG safeReposition SKIPPED type=%1 -- player aboard", typeOf _veh];
    };
    // mil_ato item6 -- INTERIM detonation fix (2026-07-03). This is the ONLY route that teleports a
    // LIVE airframe onto its hangar startPos (the slot IS the hangar interior by design). The detonation
    // fuse was the settle re-arming damage on a still-clipping frame: because `allowDamage false`
    // SUPPRESSES damage, the old `damage > 0.1` guard read 0 and always re-armed -> the pending overlap
    // resolved into a one-shot kill at ~t+8s (RPT KILLED sinceReposition~8). Interim fix keeps it
    // minimal: gate the settle on GEOMETRY, and if the frame is still clipping keep it INVULNERABLE
    // (allowDamage false) instead of re-arming -- no detonation, the hangar survives, and the airframe
    // stays sim-ON + parked at startPos so the ATO pool can still reuse it. Clean relocate-to-clear-apron
    // + pool-health (mirror fnc_profileVehicle.sqf:922-978) is OVERHAUL-SCOPE. findAirSpawnPosition is
    // still called below (harmless -- it also opens the hangar doors).
    private _target = _pos;
    private _air = [typeOf _veh, _target, 200, "auto"] call ALiVE_fnc_findAirSpawnPosition;
    // ATO_HANGAR_DBG (DIAG-STRIP): raw findAirSpawnPosition return -- shows whether it gave [] (no relocation, target stays the in-geometry hangar point) or an actual clear point.
    diag_log format ["ATO_HANGAR_DBG FASP type=%1 reqPos=%2 count=%3 return=%4", typeOf _veh, _target, count _air, _air];
    if (count _air >= 2) then {
        _target = _air select 0;
        if (_dir < 0) then { _dir = _air select 1; };
    };
    // Ground the frame: a hangar-parked profile stores the hangar BUILDING's elevated origin z (~5 m on
    // the RHS open hangar), so setPosATL at that z floats the plane up in the roof (and that 5 m roof-clip
    // WAS the detonation). Force terrain level so it sits on the apron -- boardable and clear of the roof.
    _target set [2, 0];
    _veh allowDamage false;
    if (_dir >= 0) then { _veh setDir _dir; };
    _veh setPosATL _target;
    _veh setVectorUp [0,0,1];
    _veh setVelocity [0,0,0];
    // ATO_HANGAR_DBG (DIAG-STRIP)
    diag_log format ["ATO_HANGAR_DBG safeReposition type=%1 target=%2 insideBldg=%3", typeOf _veh, _target, (count (nearestObjects [_target, ["House","Building"], 6]) > 0)];
    _veh setVariable ["ATO_reposT", time];
    _veh addEventHandler ["Killed", { params ["_u"]; diag_log format ["ATO_HANGAR_DBG KILLED type=%1 at=%2 sinceReposition=%3", typeOf _u, getPosATL _u, (time - (_u getVariable ["ATO_reposT", time]))]; }];
    [_veh, _target] spawn {
        params ["_v", "_tgt"];
        sleep 8;
        if (isNull _v || {!alive _v}) exitWith {};
        // The clip signal is the SETTLED HEIGHT, not damage (allowDamage false suppresses damage -> reads 0)
        // and not building-proximity (the hangar origin sits ~5 m up, inside any proximity radius even when
        // the plane is correctly grounded). A frame grounded on the apron settles at z~0-2; a frame still
        // clipping geometry is shoved UP by the physics separation (or was never dropped), so an elevated
        // settled z is the reliable tell.
        private _p = getPosATL _v;
        private _z = _p select 2;
        private _clip = _z > 3.5;
        // ATO_HANGAR_DBG (DIAG-STRIP): state at settle-end BEFORE deciding.
        diag_log format ["ATO_HANGAR_DBG settleEnd type=%1 dmg=%2 z=%3 insideBldg=%4", typeOf _v, damage _v, _z, _clip];
        if (_clip) then {
            // Still elevated/clipping -- NEVER re-arm damage (re-arming resolves the overlap into a one-shot
            // kill). Keep it invulnerable + intact + sim-ON, parked so the ATO pool can still reuse it.
            _v allowDamage false;
            diag_log format ["ATO_HANGAR_DBG settleClip type=%1 at=%2 -- still elevated (z=%3), kept invulnerable (no re-arm)", typeOf _v, _p, _z];
        } else {
            // Grounded and clear -- safe to re-arm damage and apply the maintenance repair.
            _v allowDamage true;
            _v setDamage 0;
        };
    };
};

switch(_operation) do {
    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };

    // Attributes
    case "createMarker": {

        private _position = _args select 0;
        private _side = _args select 1;
        private _text = _args select 2;
        private _radius = _args select 3;

        private _markers = _logic getVariable ["markers", []];

        if(count _markers > 10) then {
            {
                deleteMarker _x;
            } forEach _markers;
            _markers = [];
        };

        private _debugColor = "ColorPink";

        switch(_side) do {
            case "EAST":{
                _debugColor = "ColorRed";
            };
            case "WEST":{
                _debugColor = "ColorBlue";
            };
            case "GUER":{
                _debugColor = "ColorGreen";
            };
            case "CIV":{
                _debugColor = "ColorBrown";
            };
            default {
                _debugColor = "ColorGreen";
            };
        };

        private  _markerID = time;

        if(count _position > 0) then {
            private _m = createMarker [format["%1_%2",MTEMPLATE,_markerID], _position];

            if (_text find "RADIUS" != -1) then {
                _m setMarkerShape "ELLIPSE";
                _m setMarkerSize [_radius,_radius];
                _m setMarkerAlpha 0.3;
            } else {
                _m setMarkerShape "ICON";
                _m setMarkerSize [0.5, 0.5];
                _m setMarkerType "mil_dot";
                _m setMarkerText _text;
            };
            _m setMarkerColor _debugColor;
            _markers pushback _m;
        };

        _logic setVariable ["markers", _markers];
    };
    case "destroy": {
        [_logic, "debug", false] call MAINCLASS;
        if (isServer) then {
            // if server
            _logic setVariable ["super", nil];
            _logic setVariable ["class", nil];
            _logic setVariable ["markers", []];

            [_logic, "destroy"] call SUPERCLASS;
        };
    };
    case "debug": {
        if (_args isEqualType true) then {
            _logic setVariable ["debug", _args];
        } else {
            _args = _logic getVariable ["debug", false];
        };
        if (_args isEqualType "") then {
                if(_args == "true") then {_args = true;} else {_args = false;};
                _logic setVariable ["debug", _args];
        };
        ASSERT_TRUE(_args isEqualType true,str _args);

        _result = _args;
    };
    case "broadcastOnRadio": {
        if (_args isEqualType true) then {
            _logic setVariable ["broadcastOnRadio", _args];
        } else {
            // Default true to match the Eden default - a scripted module used to get
            // the opposite behaviour to an Editor-placed one with nothing reporting it.
            _args = _logic getVariable ["broadcastOnRadio", true];
        };
        if (_args isEqualType "") then {
                if(_args == "true") then {_args = true;} else {_args = false;};
                _logic setVariable ["broadcastOnRadio", _args];
        };
        ASSERT_TRUE(_args isEqualType true,str _args);

        _result = _args;
    };
    case "createHQ": {
        if (_args isEqualType true) then {
            _logic setVariable ["createHQ", _args];
        } else {
            // Default true to match the Eden default - a scripted module used to get
            // the opposite behaviour to an Editor-placed one with nothing reporting it.
            _args = _logic getVariable ["createHQ", true];
        };
        if (_args isEqualType "") then {
            if(_args == "true") then {_args = true;} else {_args = false;};
            _logic setVariable ["createHQ", _args];
        };
        ASSERT_TRUE(_args isEqualType true,str _args);

        _result = _args;
    };
    case "placeAir": {
        if (_args isEqualType true) then {
            _logic setVariable ["placeAir", _args];
        } else {
            _args = _logic getVariable ["placeAir", false];
        };
        if (_args isEqualType "") then {
            if(_args == "true") then {_args = true;} else {_args = false;};
            _logic setVariable ["placeAir", _args];
        };
        ASSERT_TRUE(_args isEqualType true,str _args);

        _result = _args;
    };
    case "generateTasks": {
        if (_args isEqualType true) then {
            _logic setVariable ["generateTasks", _args];
        } else {
            _args = _logic getVariable ["generateTasks", false];
        };
        if (_args isEqualType "") then {
            if (_args == "true") then {
                _args = true;
            } else {
                _args = false;
            };
            _logic setVariable ["generateTasks", _args];
        };
        ASSERT_TRUE(_args isEqualType true,str _args);

        _result = _args;
    };
    case "generateSEADTasks": {
        if (_args isEqualType true) then {
            _logic setVariable ["generateSEADTasks", _args];
        } else {
            _args = _logic getVariable ["generateSEADTasks", false];
        };
        if (_args isEqualType "") then {
            if (_args == "true") then {
                _args = true;
            } else {
                _args = false;
            };
            _logic setVariable ["generateSEADTasks", _args];
        };
        ASSERT_TRUE(_args isEqualType true,str _args);

        _result = _args;
    };
    case "resupply": {
        if (_args isEqualType true) then {
            _logic setVariable [_operation, _args];
        } else {
            // Default true, matching the Eden default. Keeping these two apart is
            // exactly what made offensive counter-air unreachable for years: an
            // Editor-placed module took one default and a scripted one took the
            // other, and nothing reported the difference.
            _args = _logic getVariable [_operation, true];
        };
        if (_args isEqualType "") then {
            if (_args == "true") then {
                _args = true;
            } else {
                _args = false;
            };
            _logic setVariable [_operation, _args];
        };
        ASSERT_TRUE(_args isEqualType true,str _args);

        _result = _args;
    };
    case "persistent": {
        if (_args isEqualType true) then {
            _logic setVariable ["persistent", _args];
        } else {
            _args = _logic getVariable ["persistent", false];
        };
        if (_args isEqualType "") then {
                if(_args == "true") then {_args = true;} else {_args = false;};
                _logic setVariable ["persistent", _args];
        };
        ASSERT_TRUE(_args isEqualType true,str _args);

        _result = _args;
    };
    case "pause": {
        if(!(_args isEqualTo true)) then {
            // if no new value was provided return current setting
            _args = [_logic,"pause",objNull,false] call ALIVE_fnc_OOsimpleOperation;
        } else {
                // if a new value was provided set groups list
                ASSERT_TRUE(_args isEqualType true,str typeName _args);

                private ["_state"];
                _state = [_logic,"pause",objNull,false] call ALIVE_fnc_OOsimpleOperation;
                if (_state && _args) exitwith {};

                //Set value
                _args = [_logic,"pause",_args,false] call ALIVE_fnc_OOsimpleOperation;
                ["Pausing state of %1 instance set to %2!",QMOD(ADDON),_args] call ALiVE_fnc_dumpR;
        };
        _result = _args;
    };
    case "airspace": {
        if(_args isEqualType "") then {
            _args = [_args, " ", ""] call CBA_fnc_replace;
            _args = [_args, ","] call CBA_fnc_split;
            if(count _args > 0) then {
                _logic setVariable [_operation, _args];
            };
        };
        if(_args isEqualType []) then {
            _logic setVariable [_operation, _args];
        };
        _result = _logic getVariable [_operation, DEFAULT_AIRSPACE];
    };
    case "types": {
        if(_args isEqualType "") then {
            // Accepts the Eden picker's CSV ("CAP,DCA,Strike") and the legacy
            // hand-typed array literal ("['CAP','DCA']") alike. Parsed rather
            // than compiled: this text comes straight from a mission file, and
            // one stray character used to take the module out with a compile
            // error instead of simply being ignored.
            //
            // Tokens are matched case-insensitively but stored in canonical
            // case, because the request gate is an exact `_eventType in _types`
            // match and "Strike"/"Recce" are title case. Anything not a known
            // type is dropped rather than poisoning the list.
            private _parsed = [];
            {
                private _token = toLower _x;
                if (_token != "") then {
                    {
                        if (toLower _x == _token && {!(_x in _parsed)}) then {
                            _parsed pushBack _x;
                        };
                    } forEach DEFAULT_ATO_TYPES;
                };
            } forEach (_args splitString "[]""', ");

            if (count _parsed == 0 && {_args != ""}) then {
                ["ATO %1 - Warning, no recognisable mission types in %2. Using the full set instead.", _logic, str _args] call ALiVE_fnc_dumpR;
                _parsed = DEFAULT_ATO_TYPES;
            };

            _logic setVariable [_operation, _parsed];
        };
        if(_args isEqualType []) then {
            _logic setVariable [_operation, _args];
        };

        _result = _logic getVariable [_operation, DEFAULT_ATO_TYPES];

        // An empty list is indistinguishable from a broken module: every request
        // is refused, the commander looks alive and flies nothing, and the only
        // clue is one line in the log. That has now happened for two different
        // reasons - a comparison that could never match, and an attribute that
        // saved empty - so rather than guard each cause in turn, treat the state
        // itself as impossible and say loudly when it is reached.
        //
        // A mission maker who wants no air missions does not place the commander.
        if (_result isEqualType [] && {count _result == 0}) then {
            ["ATO %1 - Warning, no air mission types are set for this commander, so nothing could be flown. Falling back to the full set - check the Available ATOs setting on the module.", _logic] call ALiVE_fnc_dumpR;
            _result = +DEFAULT_ATO_TYPES;
            _logic setVariable [_operation, _result];
        };
    };
    case "origTypes": {
        if (_args isEqualType "") then {
            _logic setVariable [_operation, call compile _args];
        };
        if (_args isEqualType []) then {
            _logic setVariable [_operation, _args];
        };

        _result = _logic getVariable [_operation, DEFAULT_ATO_TYPES];
    };
    case "side": {
        _result = [_logic,_operation,_args,DEFAULT_SIDE] call ALIVE_fnc_OOsimpleOperation;
    };
    // #875 - objective scenery objects: AA-style triplet.
    case "objectiveObjects": {
        _result = [_logic, _operation, _args, ""] call ALIVE_fnc_OOsimpleOperation;
    };
    case "objectiveObjectsCount": {
        _result = [_logic, _operation, _args, "0"] call ALIVE_fnc_OOsimpleOperation;
    };
    // Drone classes to place, overriding the faction's own list. Blank uses the
    // faction, which is right when it has drones catalogued and useless when it
    // does not - and plenty do not, however many the mod itself ships.
    case "droneTypes": {
        _result = [_logic, _operation, _args, ""] call ALIVE_fnc_OOsimpleOperation;
    };
    // Whether to place a drone at the base at mission start. Default false, in
    // line with placing crewed aircraft - putting things on the map is opt-in.
    // Independent of that setting because a drone needs no aircrew, so an air
    // component can consist of drones alone.
    case "placeDrones": {
        if (_args isEqualType true) then {
            _logic setVariable [_operation, _args];
        } else {
            _args = _logic getVariable [_operation, false];
        };
        if (_args isEqualType "") then {
            if (_args == "true") then { _args = true; } else { _args = false; };
            _logic setVariable [_operation, _args];
        };
        ASSERT_TRUE(_args isEqualType true,str _args);

        _result = _args;
    };
    // Whether this commander may use drones at all. Default true, matching the
    // behaviour before the setting existed - the module has flown drones for
    // years, with dedicated handling throughout for their lack of a crew.
    case "useUAVs": {
        if (_args isEqualType true) then {
            _logic setVariable [_operation, _args];
        } else {
            _args = _logic getVariable [_operation, true];
        };
        if (_args isEqualType "") then {
            if (_args == "true") then { _args = true; } else { _args = false; };
            _logic setVariable [_operation, _args];
        };
        ASSERT_TRUE(_args isEqualType true,str _args);

        _result = _args;
    };
    // Minutes allowed for a sortie. Blank or 0 keeps whatever the requesting
    // commander asked for. This single number drives the wait-for-pilot abort,
    // the target waypoint timeout, the force-launch nudge and the return-to-base
    // deadline, so it is the module's main tempo control.
    case "sortieDuration": {
        _result = [_logic, _operation, _args, ""] call ALIVE_fnc_OOsimpleOperation;
    };
    // Airframes remaining at or below which offensive tasking is suspended in
    // favour of defensive patrols. Blank or 0 keeps the built-in behaviour.
    case "minAssetsForOffensive": {
        _result = [_logic, _operation, _args, ""] call ALIVE_fnc_OOsimpleOperation;
    };
    case "objectiveObjectsChance": {
        _result = [_logic, _operation, _args, "100"] call ALIVE_fnc_OOsimpleOperation;
    };
    case "objectiveObjectsBehaviour": {
        _result = [_logic, _operation, _args, "dispersed"] call ALIVE_fnc_OOsimpleOperation;
    };
    case "HQBuilding": {
        _result = [_logic,_operation,_args,objNull] call ALIVE_fnc_OOsimpleOperation;
    };
    case "currentBase": {
        _result = [_logic,_operation,_args,[]] call ALIVE_fnc_OOsimpleOperation;
    };
    case "pilotbuilding": {
        _result = [_logic,_operation,_args,DEFAULT_PILOTBUILDING] call ALIVE_fnc_OOsimpleOperation;
    };
    case "runwaystartpos": {
        _result = [_logic,_operation,_args,DEFAULT_RUNWAYSTARTPOS] call ALIVE_fnc_OOsimpleOperation;
    };
    case "runwayendpos": {
        _result = [_logic,_operation,_args,DEFAULT_RUNWAYENDPOS] call ALIVE_fnc_OOsimpleOperation;
    };
    case "runwaywidth": {
        _result = [_logic,_operation,_args,DEFAULT_RUNWAYWIDTH] call ALIVE_fnc_OOsimpleOperation;
    };
    case "faction": {
        _result = [_logic,_operation,_args,DEFAULT_FACTION] call ALIVE_fnc_OOsimpleOperation;

        if !(_args isEqualType "") then {
            private _compiledFaction = [_logic] call ALiVE_fnc_factionCompilerResolveForModule;
            if !(_compiledFaction isEqualTo "") then {
                _result = _compiledFaction;
            };
        };
    };
    case "factions": {
        _result = [_logic,_operation,_args,[]] call ALIVE_fnc_OOsimpleOperation;
    };
    case "enemyFactions": {
        _result = [_logic,_operation,_args,[]] call ALIVE_fnc_OOsimpleOperation;
    };
    case "enemySides": {
        _result = [_logic,_operation,_args,[]] call ALIVE_fnc_OOsimpleOperation;
    };
    case "registryID": {
        _result = [_logic,_operation,_args,DEFAULT_REGISTRY_ID] call ALIVE_fnc_OOsimpleOperation;
    };
    case "isCarrier": {
        if (_args isEqualType true) then {
            _logic setVariable ["isCarrier", _args];
        } else {
            _args = _logic getVariable ["isCarrier", false];
        };
        if (_args isEqualType "") then {
            if(_args == "true") then {_args = true;} else {_args = false;};
            _logic setVariable ["isCarrier", _args];
        };
        ASSERT_TRUE(_args isEqualType true,str _args);

        _result = _args;
    };
    case "assets": {
        _result = [_logic,_operation,_args,[]] call ALIVE_fnc_OOsimpleOperation;
    };
    case "eventQueue": {
        _result = [_logic,_operation,_args,DEFAULT_EVENT_QUEUE] call ALIVE_fnc_OOsimpleOperation;
    };
    case "airspaceAssets": {
        _result = [_logic,_operation,_args,[]] call ALIVE_fnc_OOsimpleOperation;
    };
    case "airspaceOps": {
        _result = [];
        if (_args isEqualType "") then {
            // Get ops for the airspace
            private _eventQueue = [_logic, "eventQueue"] call MAINCLASS;
            {
                private _eventData = [_x,"data"] call ALiVE_fnc_hashGet;
                if ((_eventData select 3) == _args) then {
                    _result pushback _eventData;
                };
            } forEach (_eventQueue select 2);
        };
    };
    case "airspaceLastCAP": {
        _result = 0;
        if (isNil QGVAR(lastCAP)) then {
            GVAR(lastCAP) = [] call ALiVE_fnc_hashCreate;
        };
        if (_args isEqualType "") then {
            _result = [GVAR(lastCAP), _args, 0] call ALiVE_fnc_hashGet;
        };
        if (_args isEqualType []) then {
            _result = [GVAR(lastCAP), _args select 0, _args select 1] call ALiVE_fnc_hashSet;
        };
    };
    case "resupplyList": {
        // Get the current resupplyList
        _result = _logic getVariable ["resupplyList",[]];
        if (_args isEqualType []) then {
            _result pushback _args;
            _logic setVariable ["resupplyList",_result];
        };
        _result;
    };
    case "resupplyPending": {
        // #460 Phase B - in-flight LOGCOM replacement requests, keyed
        // eventID(string) -> [assetHash, requestTime, retryCount]. Lazily created
        // and returned by reference so callers hashSet/hashGet on it directly.
        _result = _logic getVariable ["resupplyPending", nil];
        if (isNil "_result") then {
            _result = [] call ALIVE_fnc_hashCreate;
            _logic setVariable ["resupplyPending", _result];
        };
        _result;
    };

    // Methods
    case "registerThreat": {
        private _threat = _args;
        //["THREAT: %1 : %2", _threat, typeof _threat] call ALiVE_fnc_dump;
        if (isNil QGVAR(threats)) then {GVAR(threats) = [] call ALiVE_fnc_hashCreate;};
        private _threatArray = [GVAR(threats), str(_logic),[]] call ALiVE_fnc_hashGet;

        private _profileID = _threat getVariable ["profileID",nil];
        if !(isNil "_profileID") then {
            _threat = _profileID;
        };

        _threatArray pushbackUnique _threat;
        [GVAR(threats), str(_logic), _threatArray] call ALiVE_fnc_hashSet;
    };
    case "scanAirspace": {

        private _airspace = [_logic,"airspace"] call MAINCLASS;
        private _intruders = [] call ALIVE_fnc_hashCreate;

        // Scan all enemy faction profiles to see if they are in the airspace
        private _enemyFactions = [_logic,"enemyFactions"] call MAINCLASS;
        {
            private _bogey = _x;
            if (faction _bogey in _enemyFactions && (getposATL _bogey) select 2 > DEFAULT_RADAR_HEIGHT) then {
                {
                    if ((getposATL _bogey) inArea _x) then {
                        private _tmp = [_intruders, _x, []] call ALiVE_fnc_hashGet;
                        // ["Adding to %1 in %2 for %3",_bogey,_tmp,_intruders] call ALiVE_fnc_dump;
                        _tmp pushback _bogey;
                        [_intruders, _x, _tmp] call ALiVE_fnc_hashSet;
                    };
                } forEach _airspace;
            };
        } forEach vehicles;

        _result = _intruders;
    };
    case "scanAirDefenses": {

        private _airspace = [_logic,"airspace"] call MAINCLASS;
        private _airDefenses = [] call ALIVE_fnc_hashCreate;

        // Scan all air defenses on map, assign to closest ATO
        private _enemySides = [_logic,"enemySides"] call MAINCLASS;

        // Check for AA sites
        {
            private _vehicle = _x;
            // ALiVE_fnc_isAA is deliberately no longer consulted here. It asks only
            // whether a turret elevates past 65 degrees and the vehicle is not
            // artillery, which any hull with a high-elevation remote mount satisfies
            // - armed or not. That was a second source of the wrongly-reported
            // targets in #828. Its job is covered by the elevation fallback inside
            // isAntiAir, which additionally requires the vehicle to be armed.
            // isAA itself is left alone: it also feeds the virtual damage model and
            // the commander's own assignments, which are not this scan's business.
            if ((_vehicle iskindOf "AAA_System_01_base_F" || _vehicle iskindOf "SAM_System_01_base_F" || _vehicle iskindOf "SAM_System_02_base_F" || [_vehicle] call ALiVE_fnc_isAntiAir) && {str(side _vehicle) in _enemySides}) then {
                private _tmpAS = [_airspace,[_vehicle],{_Input0 distance (getMarkerPos _x)},"ASCEND"] call ALiVE_fnc_SortBy;
                private _tmp = [_airDefenses, (_tmpAS select 0), []] call ALiVE_fnc_hashGet;
                _tmp pushbackUnique _vehicle;
                [_airDefenses, (_tmpAS select 0), _tmp] call ALiVE_fnc_hashSet;

                /*
                // Check there's crew
                if (count (crew _vehicle) == 0) then {
                    createVehicleCrew _vehicle;
                };
                */
            };
        } forEach vehicles;

        private _threats = [GVAR(threats),str(_logic),[]] call ALiVE_fnc_hashGet;
        // Check for known AA units
        {
            private _position = [0,0,0];

            if (_x isEqualTo objNull) then {
                _position = position _x;
            } else {
                private _profile = [ALiVE_profileHandler,"getProfile",_x] call ALiVE_fnc_ProfileHandler;
                if !(isNil "_profile") then {
                    _position = [_profile, "position"] call ALiVE_fnc_hashGet;
                };
            };

            if (str(_position) == "[0,0,0]") exitWith {};

            private _tmpAS = [_airspace,[_position],{_Input0 distance (getMarkerPos _x)},"ASCEND"] call ALiVE_fnc_SortBy;
            private _tmp = [_airDefenses, (_tmpAS select 0), []] call ALiVE_fnc_hashGet;
            _tmp pushback _x;
            [_airDefenses, (_tmpAS select 0), _tmp] call ALiVE_fnc_hashSet;

        } forEach _threats;

        _result = _airDefenses;
    };
    case "requestAnalysis": {
        _result = [_logic,_operation,_args,DEFAULT_ANALYSIS] call ALIVE_fnc_OOsimpleOperation;
    };
    case "addRunway": {
        private _runways = [_logic,"runways"] call MAINCLASS;
        private _runway = _args;

        if !([_runways,_runway] call CBA_fnc_hashHasKey) then {
            [_runways, _runway, false] call ALIVE_fnc_hashSet;
            [_logic,"runways",_runways] call MAINCLASS;
        };
    };
    case "unlockRunway": {
        private _runways = [_logic,"runways"] call MAINCLASS;
        private _runway = _args;

        if ([_runways,_runway] call CBA_fnc_hashHasKey) then {
            [_runways, _runway, false] call ALIVE_fnc_hashSet;
            [_logic,"runways",_runways] call MAINCLASS;
        };
    };
    case "runways": {
        _result = [_logic,_operation,_args,[]] call ALIVE_fnc_OOsimpleOperation;
    };
    case "registerProfile": {

        // Register an entity or vehicle profile with ATO.
        private _profileID = _args select 0;
        private _assetAirspace = _args select 1;

        private _assets = [_logic,"assets"] call MAINCLASS;

        private _as = [_logic,"airspaceAssets"] call MAINCLASS;
        private _airspaceAssets = [_as, _assetAirspace,[]] call ALiVE_fnc_hashGet;

        private _profile = [ALiVE_ProfileHandler,'getProfile',_profileID] call ALiVE_fnc_ProfileHandler;
        private _vehicleProfileIDs = [_profileID]; // assume its a vehicle profile

        // If this is an entity, then get all vehicles and register them
        private _type = [_profile,"type"] call ALIVE_fnc_hashGet;
        if (_type == "entity") then {
            _vehicleProfileIDs = [_profile, "vehiclesInCommandOf"] call ALiVE_fnc_hashGet;
        };

        {
            private _vehicleProfile = [ALiVE_ProfileHandler,'getProfile',_x] call ALiVE_fnc_ProfileHandler;
            private _vehicleClass = [_vehicleProfile,"vehicleClass",""] call ALIVE_fnc_HashGet;
            private _isVTOL = [_vehicleClass] call ALiVE_fnc_isVTOL;

            // isKindOf "UAV" alone is not enough: the Darter's base inherits from
            // Helicopter_Base_F rather than UAV, so the small reconnaissance drones
            // slip past it. The isUav config property resolves through inheritance
            // and catches them.
            // Flyable drones only. isUav is not an air property - the ground rover
            // base descends from Car_F and carries it too - and this admits an
            // aircraft past the armament check below, so without the Air test a
            // rover parked in the airspace could be taken on by the air commander
            // and tasked with a sortie.
            private _isDroneAsset = _vehicleClass isKindOf "Air"
                                 && {_vehicleClass isKindOf "UAV"
                                     || {getNumber (configFile >> "CfgVehicles" >> _vehicleClass >> "isUav") == 1}};

            // Skip drones when the mission maker has turned them off. Checked here
            // rather than at selection so an excluded drone never joins the pool at
            // all - otherwise it counts towards the airframe totals that decide
            // whether the commander has enough aircraft to keep flying offensive
            // missions.
            if (_isDroneAsset && {!([_logic,"useUAVs"] call MAINCLASS)}) exitWith {
                if (_debug) then {
                    ["ATO %1 ignoring %2 - drones are turned off for this commander", _logic, _vehicleClass] call ALiVE_fnc_dump;
                };
            };

            // If Combat support asset, then do not register
            private _isCombatSupport = false;
            private _isPlayer = false;
            if ([_vehicleProfile,"active",false] call ALiVE_fnc_hashGet) then {

                private _vehicle = [_vehicleProfile,"vehicle"] call ALiVE_fnc_hashGet;

                // Assign, do not redeclare. The second "private" here created a new
                // variable scoped to this block, so the outer one stayed false and the
                // guard below never fired - the Combat Support check has been dead since
                // it was written. sup_combatsupport shields its assets from the profiler
                // at source, so this is a backstop rather than the primary defence; it can
                // only see assets that are currently spawned.
                if (!isNil "_vehicle" && {!isNull _vehicle}) then {
                    _isCombatSupport = _vehicle getVariable ["ALIVE_CombatSupport", false];
                };
            };
            if (_isCombatSupport) exitWith {

                if (_debug) then {
                    ["ATO %1 ignoring %2 as it is a combat support asset", _logic, _vehicleClass] call ALiVE_fnc_dump;
                };

            };

            // Everything below is the adoption itself, so an aircraft that fails this
            // is never taken on at all.
            //
            // Drones are admitted whether or not they carry weapons. A reconnaissance
            // drone's only "weapon" is a camera, and the armament test deliberately
            // discounts pilot cameras and laser designators - so the aircraft most
            // worth having for reconnaissance was the one aircraft that could never be
            // adopted. Place a Darter at an airfield and the commander simply ignored
            // it, despite carrying handling throughout for aircraft that have no crew.
            //
            // A drone reaching this point has already passed the Use Drones check
            // above, so no second test is needed here.
            // What can this airframe actually be asked to do? Worked out here rather than
            // after adoption, because it is the admission test.
            //
            // An aircraft is only useful to the commander if it resolves to at least one
            // role. Every role needs a weapon: reconnaissance needs sensors and armament,
            // ground attack and close air support need a gun or air to ground ordnance,
            // interception needs air to air missiles on a fixed wing. An unarmed transport
            // satisfies none of them.
            //
            // Such an airframe used to be adopted anyway, because the armament test counts
            // weapon pylons rather than what is hanging on them and a transport has plenty
            // of hardpoints. It then sat in the roster permanently unmatched: holding a
            // runway registration, drawing replenishment, and with its crew marked busy so
            // those men were taken from the ground commander for the rest of the mission.
            // Half the roster on a normal mission was made up of these.
            //
            // Worse, it made the commander look broken. Asked for air support it answered
            // that no appropriate aircraft were available, which reads as "your aircraft
            // were never picked up" when it actually meant "none of mine can do this job".
            private _admitLoadout = [_vehicleProfile,"pylonLoadout",[]] call ALiVE_fnc_hashGet;
            private _admitRoles = [_vehicleClass, _admitLoadout] call ALiVE_fnc_getAircraftRoles;

            if (count _admitRoles == 0) then {
                if (_debug) then {
                    ["ATO %1 - not adopting %2: it resolves to no roles, so nothing could ever task it", _logic, _vehicleClass] call ALiVE_fnc_dump;
                };
            };

            if ((([_vehicleClass] call ALiVE_fnc_isArmed) || _isDroneAsset) && {count _admitRoles > 0}) then {

                // make sure vehicle is set to side of logic
                [_vehicleProfile, "side", [_logic,"side"] call MAINCLASS] call ALiVE_fnc_profileVehicle;

                private _asset = [] call ALIVE_fnc_hashCreate;
                [_asset,"vehicleClass",_vehicleClass] call ALiVE_fnc_hashSet;
                [_asset,"airspace",_assetAirspace] call ALiVE_fnc_hashSet;

                private _position = +([_vehicleProfile,"position"] call ALIVE_fnc_HashGet);

                // Adopted aircraft are taken wherever they happen to be standing, and whatever
                // placed them had no idea aircraft need to taxi past. A parked airframe on the
                // runway or a taxiway stops every aircraft trying to get out, because the engine
                // snags fixed wing taxi pathfinding on anything within about eight metres of the
                // route, and a transport sitting across a threshold is the worst offender.
                //
                // Move it onto the open ground between the runway and the taxiways. That is where
                // dispersed aircraft sit on a real airfield, so it reads as deliberate rather than
                // dumped, and it keeps the movement surfaces clear.
                //
                // Runway and taxiway only: an apron, hardstand or helipad is a proper parking spot
                // and is left exactly as placed.
                if (!isNil "ALiVE_fnc_airsideClear" && {count _position > 1}) then {
                    private _clearPos = [_position, [1,2]] call ALiVE_fnc_airsideClear;
                    if ((_clearPos distance2D _position) > 1) then {
                        if (_debug) then {
                            ["ATO %1 - adopted %2 was on a movement surface, moved %3m onto open ground", _logic, _vehicleClass, round (_clearPos distance2D _position)] call ALiVE_fnc_dump;
                        };
                        _position = _clearPos;
                        _position set [2, 0];
                        // Keep the profile in step, or the airframe snaps back to the blocking
                        // spot on its next despawn and respawn.
                        [_vehicleProfile,"position",_position] call ALiVE_fnc_profileVehicle;
                        // Move the live airframe too, unless somebody is aboard.
                        private _liveVeh = [_vehicleProfile,"vehicle"] call ALiVE_fnc_hashGet;
                        if (!isNil "_liveVeh" && {!isNull _liveVeh} && {alive _liveVeh} && {(crew _liveVeh) findIf {isPlayer _x} < 0}) then {
                            _liveVeh setPosATL _position;
                            _liveVeh setVelocity [0,0,0];
                        };
                    };
                };
                [_asset,"startPos",_position] call ALiVE_fnc_hashSet;

                private _dir = [_vehicleProfile,"direction"] call ALIVE_fnc_HashGet;
                [_asset,"startDir",_dir] call ALiVE_fnc_hashSet;

                private _isOnCarrier = false;

                if ( [_position] call ALiVE_fnc_nearShip ) then {
                    _isOnCarrier = true;

                    // Due to issues spawning aircraft on ships after changing sea levels keep assets spawned
                    [_vehicleProfile,"spawnType",["preventDespawn"]] call ALiVE_fnc_profileVehicle;
                    [_vehicleProfile,"spawn"] call ALiVE_fnc_profileVehicle;
                };

                [_asset,"isOnCarrier", _isOnCarrier] call ALiVE_fnc_hashSet;

                if (_vehicleClass iskindof "Plane" && (_isVTOL < 3) ) then {

                    // Get airportID
                    private _airportID = [_position] call ALiVE_fnc_getNearestAirportID;
                    [_asset,"airportID",_airportID] call ALiVE_fnc_hashSet;
                    [_logic,"addRunway",_airportID] call MAINCLASS;

                } else {

                    // Heli or VTOL?
                    // Get HeliH object
                    private _helipad = nearestObject [_position, "HeliH"];
                    if (isNull _helipad) then {
                        // create an invisble helipad
                        _helipad = "Land_HelipadEmpty_F" createvehicle _position;
                    };
                    [_asset,"helipad", position _helipad] call ALiVE_fnc_hashSet;

                };

                // Check role of aircraft. The fitted loadout is passed alongside the
                // class because a config scan only sees each pylon's default
                // attachment - an aircraft rearmed in the Editor or from an arsenal
                // reads as though it still carries whatever it shipped with. The
                // snapshot is captured at virtualisation and replayed on spawn, so
                // it is the closest thing available to what the aircraft is really
                // carrying.
                private _fittedLoadout = _admitLoadout;   // read once, above, as part of the admission test
                // Already worked out above as the admission test; do not repeat the config read.
                private _roles = _admitRoles;
                [_asset,"roles",_roles] call ALiVE_fnc_hashSet;

                // Keep the capability list too, not just the roles derived from it.
                // Roles are deliberately broad so that nothing gets excluded, which
                // means they cannot tell an air-superiority jet from a ground-attack
                // aircraft: both carry a cannon, so both come out as Attack and CAS.
                // Choosing between two aircraft that qualify for the same job needs
                // the finer detail, and working it out once here is far cheaper than
                // re-reading config every time a mission is requested.
                private _caps = [_vehicleClass, _fittedLoadout] call ALiVE_fnc_getAircraftCapabilities;
                [_asset,"capabilities",_caps] call ALiVE_fnc_hashSet;

                // Report what each airframe was credited with and why. Capability is
                // read from config, and third-party aircraft vary in how completely
                // they declare sensors and ordnance - so rather than assert this
                // works on any given mod, make it checkable: turn on Debug and the
                // log states, per airframe, exactly what was detected.
                //
                // An aircraft that declares no sensor component at all reports
                // sensorsUnknown and is left eligible on purpose. That keeps mods
                // which predate or ignore the sensor overhaul working as they do
                // today rather than quietly dropping out of the roster.
                if (_debug) then {
                    ["ATO %1 - %2 capabilities %3 -> roles %4 (fitted loadout: %5)", _logic, _vehicleClass, _caps, _roles, count _fittedLoadout] call ALiVE_fnc_dump;
                };

                if (_type == "entity") then {

                    [_asset,"crewID",_profileID] call ALiVE_fnc_hashSet;
                    // Set the entity as busy so OPCOM doesn't use it
                    [_profile,"busy",true] call ALIVE_fnc_profileEntity;

                } else {

                    if !(ALIVE_loadProfilesPersistent && {[ALIVE_ATOGlobalRegistry,"persistenceLoaded", false] call ALIVE_fnc_hashGet}) then {
                        // Register a crew
                        // Check to see if this is just a vehicle (likely a plane), if so create the crew in a nearby building
                        if ([_profile,"type"] call ALiVE_fnc_hashGet == "vehicle" && !([_vehicleClass] call _fnc_isDroneClass)) then {

                            // Check to see if the vehicle has a crew, if not create
                            if (count ([_profile,"entitiesInCommandOf"] call ALiVE_fnc_hashGet) == 0) then {

                                private _side = [_profile,"side"] call ALiVE_fnc_hashGet;
                                private _faction = [_profile,"faction"] call ALiVE_fnc_hashGet;
                                private _crewpos = +_position;
                                
                                
                                private ["_crewPos","_thispos"];
                                private _atoPosition = position _logic;
                                _crewPos = + _atoPosition;


                                if !(_isOnCarrier) then {
                                
                                 // if pilotbuilding is defined
                                 private _pilotbuilding = [_logic, "pilotbuilding"] call MAINCLASS;
                                 

                                 if (count _pilotbuilding >0) then {
                                 	
	                                  // DEBUG -------------------------------------------------------------------------------------
												            if(_debug) then {
											                  ["ATO - Pilot Building Class: %1",_pilotbuilding] call ALiVE_fnc_dump;
											                  ["ATO - ATO Module Position: %1", _atoPosition] call ALiVE_fnc_dump;
											              };
	                                  // DEBUG ------------------------------------------------------------------------------------- 
                                  
                                    private _vnbuildings = nearestObjects [_atoPosition, [_pilotbuilding], 50];
                                    
	                                    // DEBUG -------------------------------------------------------------------------------------
														          if(_debug) then {
												                ["ATO - Count Nearby Buildings: %1", count _vnbuildings] call ALiVE_fnc_dump;
												              };
		                                  // DEBUG ------------------------------------------------------------------------------------- 

                                    if (count _vnbuildings > 0) then {
                                    	
	                                    // DEBUG -------------------------------------------------------------------------------------
														          if(_debug) then {
												                ["ATO - Nearby Buildings: %1", _vnbuildings] call ALiVE_fnc_dump;
												              };
		                                  // DEBUG ------------------------------------------------------------------------------------- 
                                    	
	                                     private _thisbuilding = selectRandom _vnbuildings;
	                                     _thispos = [_thisbuilding,1] call ALIVE_fnc_findIndoorHousePositions;
	                                     if (count _thispos > 0) then {
	                                      _crewPos = selectRandom _thispos;
			                                    // DEBUG -------------------------------------------------------------------------------------
														              if(_debug) then {
			                                      	["ATO - Building Selected: %1", _thispos] call ALiVE_fnc_dump;
			                                    }; 
			                                    // DEBUG ------------------------------------------------------------------------------------- 
		                                   };   
                                    };


                                 } else {
                                 	 // Only override the crew position when there is actually somewhere indoor to
                                 	 // put them. selectRandom [] returns nil, and assigning nil here would delete
                                 	 // _crewPos (the recovery guard below rebinds it in the wrong scope), leaving
                                 	 // it undefined when the crew is added. No indoor spot: keep the module default.
                                 	 private _indoor = [_position, 100] call ALIVE_fnc_findIndoorHousePositions;
                                 	 if (count _indoor > 0) then { _crewPos = selectRandom _indoor };
                                 };

                                 if (isNil "_crewPos") then {
                                     _crewPos = _atoPosition getpos [10 + (random 15), random 360];
										  	            // DEBUG -------------------------------------------------------------------------------------
											            	if(_debug) then {
											             		["ATO - No Buildings Nearby With House Positions. Set Random Crew Position: %1", _crewPos] call ALiVE_fnc_dump;
											            	};
											              // DEBUG -------------------------------------------------------------------------------------
                                 };

                                } else {
                                    private _bridge = (_position nearObjects ["Land_Carrier_01_island_02_F",700]) select 0;
                                    _crewPos = ASLtoATL (_bridge modelToWorld [-2.43359,1.98047,0]); // entities are saved as ATL positions
                                    // ["ATO PLACE CREW AT %1 (pos: %2)", _crewpos, _position] call ALiVE_fnc_dump;
                                };

                                // Check for no building?

                                private _entityID = [ALIVE_profileHandler, "getNextInsertEntityID"] call ALIVE_fnc_profileHandler;
                                private _profileEntity = [nil, "create"] call ALIVE_fnc_profileEntity;
                                [_profileEntity, "init"] call ALIVE_fnc_profileEntity;
                                [_profileEntity, "profileID", format["%1-%2",_faction,_entityID]] call ALIVE_fnc_profileEntity;
                                [_profileEntity, "position", _crewPos] call ALIVE_fnc_profileEntity;
                                [_profileEntity, "side", _side] call ALIVE_fnc_profileEntity;
                                [_profileEntity, "faction", _faction] call ALIVE_fnc_profileEntity;
                                [_profileEntity, "busy", true] call ALIVE_fnc_profileEntity;
                                [_profileEntity, "ignore_HC", true] call ALIVE_fnc_profileEntity;
                                [_profileEntity, "despawnPosition", _crewPos] call ALIVE_fnc_profileEntity;
                                [_profileEntity, "isSPE", false] call ALIVE_fnc_profileEntity;
                                [_profileEntity, "aiBehaviour", "SAFE"] call ALIVE_fnc_profileEntity;
                                
                                
                                [ALIVE_profileHandler, "registerProfile", _profileEntity] call ALIVE_fnc_profileHandler;

                                // Create the vehicle's crew
                                private _crew = _vehicleClass call ALIVE_fnc_configGetVehicleCrew;
                                private _vehiclePositions = [_vehicleClass] call ALIVE_fnc_configGetVehicleEmptyPositions;
                                private _countCrewPositions = 0;

                                // count all non cargo positions
                                for "_i" from 0 to count _vehiclePositions -3 do {
                                    _countCrewPositions = _countCrewPositions + (_vehiclePositions select _i);
                                };

                                // for all crew positions add units to the entity group
                                for "_i" from 0 to _countCrewPositions -1 do {
                                    [_profileEntity, "addUnit", [_crew,_crewPos,0,"CAPTAIN"]] call ALIVE_fnc_profileEntity;
                                };

                                // Store the crew as a profileID
                                [_asset,"crewID",([_profileEntity, "profileID"] call ALIVE_fnc_profileEntity)] call ALiVE_fnc_hashSet;
                            };
                        };
                    };
                };

                // Register asset
                [_assets,_x,_asset] call ALiVE_fnc_hashSet;

                // Register asset in airspace
                _airspaceAssets pushback _x;

                if (_debug) then {
                    ["ATO %1 registered %2 (%3) as an asset.", _logic, _x, _vehicleClass] call ALiVE_fnc_dump;
                };

            } else {
                if (_debug) then {
                    ["ATO %1 not registering %2 (%3) as it is unarmed.", _logic, _x, _vehicleClass] call ALiVE_fnc_dump;
                };
            };
        } forEach _vehicleProfileIDs;

        // Set assets
        [_logic, "assets", _assets] call MAINCLASS;

        // Set airspace
        [_as, _assetAirspace, _airspaceAssets] call ALIVE_fnc_hashSet;
        [_logic,"airspaceAssets", _as] call MAINCLASS;
    };
    case "requestCSARPlayerTask": {

        private _aircraft = _args;
        private _target = [_aircraft,"vehicleClass"] call ALiVE_fnc_hashGet;
        private _crewID = [_aircraft,"crewID"] call ALiVE_fnc_hashGet;
        private _destination = [_aircraft,"currentPos"] call ALiVE_fnc_hashGet;

        private _crewProfile = [ALiVE_profileHandler,"getProfile",_crewID] call ALiVE_fnc_ProfileHandler;
        private _isALive = false;

        // Check to see if crew are alive, if so rescue
        if !(isNil "_crewProfile") then {
            _destination = [_crewProfile,"position"] call ALiVE_fnc_hashGet;
            _destination set [2,0]; // make sure the position isn't in the air (in case they are currently in a parachute)
            _isAlive = true;
        };

        if (isNil "_destination") exitWith {
             if(_debug) then {
                ["ATO - CSAR Request does not have a desintation: %1", _aircraft] call ALiVE_fnc_dump;
            };
        };

        // Find crashsite and check if its on land
        private _crashsites = [];
        {
            if !(alive _x) then {
                _crashsites pushback _x;
            };
        } forEach (entities _target);
        if (count _crashsites > 0) then {
            _crashsites = [_crashsites,[_destination],{_Input0 distance _x},"ASCEND"] call ALiVE_fnc_SortBy;
            _destination = if !(surfaceIsWater (position (_crashsites select 0))) then {position (_crashsites select 0)} else {_destination};
            deleteVehicle (_crashsites select 0);
        };

        if (_isAlive) then {
            // Set the crew so they don't run away
            [_crewProfile, "clearWaypoints"] call ALiVE_fnc_profileEntity;

            private _waypoint = [_destination, 10] call ALIVE_fnc_createProfileWaypoint;
            [_crewProfile, "addWaypoint",_waypoint] call ALiVE_fnc_profileEntity;
        };

        private _probability = If (_isAlive) then {true} else {(random 1) < CHANCE_OF_RESCUE};

        private _isEnemyNear = [_destination, _side, 3000, true] call ALiVE_fnc_isEnemyNear;
        private _enemyTerritory = false;
        private _enemyFaction = [_destination, 3000] call ALiVE_fnc_getDominantFaction;

        if !(isNil "_enemyFaction") then {
            _enemyTerritory = ([_side] call ALIVE_fnc_sideTextToObject) getFriend (_enemyFaction call ALIVE_fnc_factionSide) < 0.6;
        };

        if ((_isEnemyNear || _enemyTerritory)  && _probability) then {

            private _faction = [_logic,"faction"] call MAINCLASS;
            private _side = [_logic, "side"] call MAINCLASS;

            if (_isEnemyNear && !_enemyTerritory) then {
                private _enemySides = [_logic, "enemySides"] call MAINCLASS;
                private _enemySide = _enemySides select 0;
                _enemyFaction = (([_destination,3000,[_enemySide,"entity"]] call ALIVE_fnc_getNearProfiles) select 0) select 2 select 29;
            };

            private _requestID = format["%1_%2",_faction,floor(time)];

            // Don' specify a player
            private _playerID =  "ATO";

            // All players in side
            private _sidePlayers = [_side] call ALiVE_fnc_getPlayersDataSource;
            _sidePlayers = [_sidePlayers select 1,_sidePlayers select 0];

            private _current = "Y";
            private _apply = "Side";

            private _location = "NULL";

            private _taskData = [_requestID,_playerID,_side,_faction,"CSAR",_location,_destination,_sidePlayers,_enemyFaction,_current,_apply,_target];

            if (_isAlive) then {
                _taskData pushback _crewID;
            };

            private _event = ['TASK_GENERATE', _taskData, "ATO"] call ALIVE_fnc_event;
            [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
        };
    };
    case "requestPlayerTask": {

        private _type = _args select 0;
        private _targets = +(_args select 1);
        private _friendly = "";

        if (count _args > 2) then {
            _friendly = _args select 2;
        };

        // 1st target will be handled by ATO, check other targets for player
        if (_type != "SEAD" && _type != "DefendHQ") then {
            _targets set [0, -1];
            _targets = _targets - [-1];
        };

        if (isNil QGVAR(playerRequests)) then {
            GVAR(playerRequests) = [] call ALiVE_fnc_hashCreate;
        };

        // Check to see if this target has already been handed to players
        private _target = nil;
        private _currentTargets = [GVAR(playerRequests),_type,[]] call ALiVE_fnc_hashGet;

        {
            if !(_x in _currentTargets) exitWith {
                _target = _x;
            };
        } forEach _targets;

        // ["PLAYER ATO TASK %1 %2", _args, _target] call ALiVE_fnc_dump;

        // If not create a task to destroy the target
        if !(isNil "_target") then {

            _currentTargets pushback _target;

            private _destination = [];
            private _enemyFaction = "OPF_F";

            // Target could be profiled aircraft, profile AA, non-profiled AA, building, HQ
            if (_target isEqualType "") then {
                private _targetProfile = [ALiVE_profileHandler, "getProfile", (_targets select 1)] call ALiVE_fnc_ProfileHandler;
                if !(isNil "_targetProfile") then {
                    _destination = [_targetProfile,"position"] call ALiVE_fnc_hashGet;
                    _enemyFaction = [_targetProfile,"faction"] call ALiVE_fnc_hashGet;
                };
            } else {
                _destination = position _target;
                _enemyFaction = faction _target;
            };

            // Don't send request if destination isn't defined
            if (count _destination == 0) exitWith {
                 if(_debug) then {
                    ["ATO - Task Request does not have a desintation target: %1", _target] call ALiVE_fnc_dump;
                };
            };

            // Request task - Defend HQ?, Destroy Vehicles, CSAR, SEAD
            private _side = [_logic,"side"] call MAINCLASS;
            private _faction = [_logic,"faction"] call MAINCLASS;
            private _requestID = format["%1_%2",_faction,floor(time)];

            // Don' specify a player
            private _playerID =  "ATO";

            // All players in side
            private _sidePlayers = [_side] call ALiVE_fnc_getPlayersDataSource;
            _sidePlayers = [_sidePlayers select 1, _sidePlayers select 0];

            private _current = "Y";
            private _apply = "Side";

            private _taskType = _type;

            switch (_type) do {
                case "DefendHQ": {
                    _taskType = "MilDefence"; // Might need to change this to clear area or something
                };
                case "Strike": {
                    _taskType = "DestroyBuilding";
                };
                default {
                    _taskType = _type;
                };
            };

            if (_debug) then {
                ["CREATING PLAYER ATO TASK %1 %2", _args, [_requestID,_playerID,_side,_faction,_taskType,"NULL",_destination,_sidePlayers,_enemyFaction,_current,_apply,[_target]]] call ALIVE_fnc_dump;
            };

            private _targetArray = [_target];

            if (_type == "OCA") then {
                _targetArray = _targets;
            };

            private _taskData = [_requestID,_playerID,_side,_faction,_taskType,"NULL",_destination,_sidePlayers,_enemyFaction,_current,_apply,_targetArray];

            if (_type == "CAS") then {
                _taskData pushback _friendly;
            };

            private _event = ["TASK_GENERATE", _taskData, "ATO"] call ALIVE_fnc_event;
            [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

            [GVAR(playerRequests), _type, _currentTargets] call ALiVE_fnc_hashSet;
        };
    };

    // Main process
    // Set module variables and attributes
    case "init": {
        if (isServer) then {

            // if server, initialise module game logic
            _logic setVariable ["super", SUPERCLASS];
            _logic setVariable ["class", MAINCLASS];
            _logic setVariable ["moduleType", "ALIVE_ATO"];
            _logic setVariable ["startupComplete", false];
            _logic setVariable ["listenerID", ""];
            _logic setVariable ["registryID", ""];
            _logic setVariable ["initialAnalysisComplete", false];
            _logic setVariable ["analysisInProgress", false];
            _logic setVariable ["eventQueue", [] call ALIVE_fnc_hashCreate];
            _logic setVariable ["position", getposATL _logic];

            GVAR(threats) = [] call ALiVE_fnc_hashCreate;
            GVAR(lastCAP) = [] call ALiVE_fnc_hashCreate;

            private _debug = [_logic, "debug"] call MAINCLASS;
            private _faction = [_logic, "faction"] call MAINCLASS;

            private _side = _faction call ALiVE_fnc_factionSide;
            [_logic, "side", str _side] call MAINCLASS;

            private _factions = [_logic, "factions",[_faction]] call MAINCLASS;
            private _types = [_logic, "types", _logic getVariable ["types", DEFAULT_ATO_TYPES]] call MAINCLASS;
            private _airspace = [_logic, "airspace", _logic getVariable ["airspace", DEFAULT_AIRSPACE]] call MAINCLASS;

            [_logic,"generateTasks", _logic getVariable ["generateTasks", false]] call MAINCLASS;
            [_logic,"generateSEADTasks", _logic getVariable ["generateSEADTasks", false]] call MAINCLASS;

            [_logic, "assets",[] call ALiVE_fnc_hashCreate] call MAINCLASS;
            [_logic,"airspaceAssets",[] call ALiVE_fnc_hashCreate] call MAINCLASS;
            [_logic,"runways",[] call ALiVE_fnc_hashCreate] call MAINCLASS;
            
            // Define enemy factions by getting enemy sides
            private _enemyFactions = [];
            private _sides = ["EAST","WEST","GUER"];
            private _sidesEnemy = [];

            {
                if ((_side getfriend ([_x] call ALIVE_fnc_sideTextToObject)) < 0.6) then {
                    _sidesEnemy pushBack _x
                };
            } forEach (_sides - [_side]);

            //Thank you again, BIS...
            {if (_x == "RESISTANCE") then {_sidesEnemy set [_forEachIndex,"GUER"]}} forEach _sidesEnemy;

            {
                // Get side factions
                _enemyFactions append (_x call ALiVE_fnc_getSideFactions);
            } forEach _sidesEnemy;

            [_logic,"enemyFactions",_enemyFactions] call MAINCLASS;
            [_logic,"enemySides",_sidesEnemy] call MAINCLASS;

            // Drop airspace markers that do not exist. A misspelled name used to survive
            // all the way to the cluster lookups, which then found nothing and aborted
            // startup with only a log line - so the commander simply never ran, with no
            // HQ, no aircraft and no tasking. Filtering here lets the whole-map fallback
            // below take over, so a typo costs the intended boundary rather than the
            // entire module.
            if (count _airspace > 0) then {
                private _validAirspace = _airspace select {markerShape _x != ""};
                if (count _validAirspace < count _airspace) then {
                    ["ATO %1 - Warning, airspace marker(s) %2 do not exist and have been ignored. Check the spelling in this module's Airspace Markers setting.", _logic, str (_airspace - _validAirspace)] call ALiVE_fnc_dumpR;
                    _airspace = _validAirspace;
                    [_logic, "airspace", _airspace] call MAINCLASS;
                };
            };

            // If no airspace marker, then use the whole map
            if (count _airspace == 0) then {
                private _marker = createMarker [format["ATO_%1", ceil(random 10000)], [worldSize/2,worldSize/2]];
                _marker setMarkerSize [worldSize/2 - 100,worldSize/2 - 100];
                _marker setMarkerShape "RECTANGLE";
                // _marker setMarkerColor "colorBlue";
                _marker setMarkerAlpha 0;
                [_logic, "airspace", [_marker]] call MAINCLASS;
            };

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                ["ATO - Init %1", _logic] call ALiVE_fnc_dump;
                ["ATO - ATO Types: %1",[_logic, "types"] call MAINCLASS] call ALiVE_fnc_dump;
                ["ATO - Airspace Markers: %1",[_logic, "airspace"] call MAINCLASS] call ALiVE_fnc_dump;
                ["ATO - Side: %1",[_logic, "side"] call MAINCLASS] call ALiVE_fnc_dump;
                ["ATO - Factions: %1",[_logic, "factions"] call MAINCLASS] call ALiVE_fnc_dump;
                ["ATO - Persistent: %1",[_logic, "persistent"] call MAINCLASS] call ALiVE_fnc_dump;
                ["ATO - Create HQ: %1",[_logic, "createHQ"] call MAINCLASS] call ALiVE_fnc_dump;
                ["ATO - Place Air Assets: %1",[_logic, "placeAir"] call MAINCLASS] call ALiVE_fnc_dump;
                ["ATO - Resupply: %1",[_logic, "resupply"] call MAINCLASS] call ALiVE_fnc_dump;
                ["ATO - Generate Tasks: %1",[_logic, "generateTasks"] call MAINCLASS] call ALiVE_fnc_dump;
                ["ATO - Generate SEAD Tasks: %1",[_logic, "generateSEADTasks"] call MAINCLASS] call ALiVE_fnc_dump;
                ["ATO - Runway Start Position: %1",[_logic, "runwaystartpos"] call MAINCLASS] call ALiVE_fnc_dump;
                ["ATO - Runway End Position: %1",[_logic, "runwayendpos"] call MAINCLASS] call ALiVE_fnc_dump;
                ["ATO - Runway Width: %1",[_logic, "runwaywidth"] call MAINCLASS] call ALiVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------

            // create the global registry
            if(isNil "ALIVE_ATOGlobalRegistry") then {
                ALIVE_ATOGlobalRegistry = [nil, "create"] call ALIVE_fnc_ATOGlobalRegistry;
                [ALIVE_ATOGlobalRegistry, "init", [_logic, "persistent"] call MAINCLASS] call ALIVE_fnc_ATOGlobalRegistry;
                [ALIVE_ATOGlobalRegistry, "debug", _debug] call ALIVE_fnc_ATOGlobalRegistry;
            };

            TRACE_1("After module init",_logic);

            [_logic,"start"] call MAINCLASS;
        } else {
            // Make any markers invisible
            [_logic, "airspace", _logic getVariable ["airspace", DEFAULT_AIRSPACE]] call MAINCLASS;
            {_x setMarkerAlpha 0} forEach (_logic getVariable ["airspace", DEFAULT_AIRSPACE]);
        };
    };

    // Analyse synchronised OPCOMs, create HQ, create AA, set HQ base cluster
    case "start": {
        if (isServer) then {

            private ["_modules","_module","_worldName","_file","_moduleObject"];

            private _debug = [_logic, "debug"] call MAINCLASS;
            private _isCarrier = false;

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                ["ATO %1 - Startup", _logic] call ALiVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------

            // check modules are available
            if !(["ALiVE_sys_profile","ALiVE_mil_opcom"] call ALiVE_fnc_isModuleAvailable) exitwith {
                ["Military Air Component Commander reports that Virtual AI module or Military AI Commander is not placed! Exiting..."] call ALiVE_fnc_DumpR;
            };
            waituntil {!(isnil "ALiVE_ProfileHandler") && {[ALiVE_ProfileSystem,"startupComplete",false] call ALIVE_fnc_hashGet}};

            // if civ cluster data not loaded, load it
            if(isNil "ALIVE_clustersCiv" && isNil "ALIVE_loadedCivClusters") then {
                _worldName = toLower(worldName);
                _file = format["x\alive\addons\civ_placement\clusters\clusters.%1_civ.sqf", _worldName];
                call compile preprocessFileLineNumbers _file;
                ALIVE_loadedCIVClusters = true;
            };
            waituntil {!(isnil "ALIVE_loadedCIVClusters") && {ALIVE_loadedCIVClusters}};

            // if mil cluster data not loaded, load it
            if(isNil "ALIVE_clustersMil" && isNil "ALIVE_loadedMilClusters") then {
                _worldName = toLower(worldName);
                _file = format["x\alive\addons\mil_placement\clusters\clusters.%1_mil.sqf", _worldName];
                call compile preprocessFileLineNumbers _file;
                ALIVE_loadedMilClusters = true;
            };
            waituntil {!(isnil "ALIVE_loadedMilClusters") && {ALIVE_loadedMilClusters}};

            // get all synced modules
            _modules = [];
            for "_i" from 0 to ((count synchronizedObjects _logic)-1) do {
                _moduleObject = (synchronizedObjects _logic) select _i;

                waituntil {_module = _moduleObject getVariable "handler"; !(isnil "_module")};
                _module = _moduleObject getVariable "handler";
                _modules pushback _module;
            };

            // Establish base of operations for ATO
            // Find plane related clusters on map
            private _airspace = [_logic, "airspace"] call MAINCLASS;
            private _airClusters = [(ALIVE_clustersMilAir select 2), _airspace] call ALIVE_fnc_clustersInsideMarker;

            // If no runways etc then look for helipads
            if (count _airClusters == 0) then {
                _airClusters = [(ALIVE_clustersMilHeli select 2), _airspace] call ALIVE_fnc_clustersInsideMarker;
            };

            if (count _airClusters == 0) then {
                 _airClusters = [(ALIVE_clustersMil select 2), _airspace] call ALIVE_fnc_clustersInsideMarker;
            };

            if (count _airClusters == 0) exitWith {
                ["ATO - Warning no usable military buildings within airspace found, the ATO module for %1 may be incorrectly configured.", _faction] call ALiVE_fnc_dumpR;
            };

            // Select the nearest cluster to the module or use Aircraft Carrier
            private _position = getposATL _logic;

            // Check for Carrier, if so, create base cluster around Carrier
            if ([_position] call ALiVE_fnc_nearShip) then {
                _isCarrier = true;
            };

            // Sort clusters by distance
            private _tmp = [_airclusters,[_position],{_Input0 distance ([_x,"center",[0,0,0]] call ALiVE_fnc_HashGet)},"ASCEND"] call ALiVE_fnc_SortBy;
            private _baseCluster = _tmp select 0;

            // Always use the carrier as the base if the module is close to the carrier
            if (_isCarrier) then {
                _baseCluster = ([(AGLtoASL _position) nearObjects ["Strategic",700]] call ALiVE_fnc_findClusters) select 0;
                [_baseCluster,"center", [[_baseCluster,"nodes"] call ALiVE_fnc_hashGet] call ALiVE_fnc_findClusterCenter] call ALiVE_fnc_hashSet;
                [_baseCluster,"size",[_baseCluster,"size"] call ALiVE_fnc_cluster] call ALiVE_fnc_hashSet;
            };

            if (_debug) then {
                ["Nearest Base Cluster %1 --------------------------------------------------------------------------", _logic] call ALIVE_fnc_dump;
                _baseCluster call ALIVE_fnc_inspectHash;
            };

            // If createHQ, select a suitable nearby building or create one, if not, choose a building or just use node
            private _createHQ = [_logic, "createHQ"] call MAINCLASS;
            If (_createHQ && !_isCarrier) then {

                private _faction = [_logic, "faction"] call MAINCLASS;

                // Get nearest buildings
                private _buildings = nearestObjects [_position, ["building"], 750];

                // Check to see if the buildings match our ALiVE types
                {
                    private _blg = typeof _x;
                    if ( {(tolower _blg) find (tolower _x) != -1} count (ALiVE_militaryBuildingTypes + ALIVE_militaryHQBuildingTypes) == 0) then {
                        _buildings set [_forEachIndex, -1];
                    };
                    if !([_x] call ALIVE_fnc_isHouseEnterable) then {
                        _buildings set [_forEachIndex, -1];
                    };
                } forEach _buildings;
                _buildings = _buildings - [-1];

                // ["ATO %1 - Buildings: %2", _logic, _buildings] call ALiVE_fnc_dump;
                if(count _buildings > 0) then {
                    private _hqBuilding = _buildings select 0;


                    // DEBUG -------------------------------------------------------------------------------------
                    if(_debug) then {
                        private _atoSide = getNumber ((_faction call ALiVE_fnc_configGetFactionClass) >> "side") call ALIVE_fnc_sideNumberToText;
                        [position _hqBuilding, 4, format ["%1 - ATO HQ Building (%2)", _atoSide, _faction], "ColorPink", "placement.ato"] call ALIVE_fnc_placeDebugMarker;
                        ["ATO [%1] - HQ Building placed at %2 - building %3", _faction, position _hqBuilding, typeOf _hqBuilding] call ALiVE_fnc_dump;
                    };
                    // DEBUG -------------------------------------------------------------------------------------

                    if !(ALIVE_loadProfilesPersistent) then {
                        private _group = ["Infantry",_faction] call ALIVE_fnc_configGetRandomGroup;
                        private _profiles = [_group, position _hqBuilding, random 360, true, _faction] call ALIVE_fnc_createProfilesFromGroupConfig;

                        {
                            if (([_x,"type"] call ALiVE_fnc_HashGet) == "entity") then {
                                [_x, "setActiveCommand", ["ALIVE_fnc_garrison","spawn",[50,"false",[0,0,0]]]] call ALIVE_fnc_profileEntity;
                            };
                        } forEach _profiles;
                    };

                    [_logic, "HQBuilding", _hqBuilding] call MAINCLASS;

                    if (_debug) then {
                        ["ATO %1 - ATO building selected: %2", _logic, [_logic, "HQBuilding"] call MAINCLASS] call ALiVE_fnc_dump;
                    };

                } else {

                    // Spawn a field HQ
                    private _pos = [_baseCluster,"center"] call ALiVE_fnc_HashGet;
                    private _size = [_baseCluster,"size",150] call ALiVE_fnc_HashGet;
                    // Debug-only runway marker visualisation. The unified
                    // composition-spawn validator handles runway / taxiway /
                    // helipad rejection natively via getAirfieldGeometry; the
                    // marker overlay is kept just for the visible runway
                    // outline during debug previews.
                    private _runwayMarkers = [_pos,"COLORRED"] call ALiVE_fnc_DrawRunwayBlacklistMarkers;

                    // Composition selection - hoisted outside the
                    // !COMPOSITIONS_LOADED branch so the validator below can
                    // size its envelope to the actual layout. Falls back to
                    // generic HQ / FieldHQ / Communications when no
                    // Airports / Heliports composition exists for the faction.
                    private _compType = "Military";
                    If (_faction call ALiVE_fnc_factionSide == RESISTANCE) then {
                        _compType = "Guerrilla";
                    };
                    private _HQ = selectRandom ([_compType, ["Airports","Heliports"], [], _faction] call ALiVE_fnc_getCompositions);
                    if (isNil "_HQ") then {
                        _HQ = selectRandom ([_compType, ["HQ","FieldHQ","Communications"], ["Medium"], _faction] call ALiVE_fnc_getCompositions);
                    };

                    if (isNil "_HQ") exitWith {
                        ["ATO [%1] - Field ATO: no Airport / Heliport / HQ composition available for faction (compType %2) - skipped", _faction, _compType] call ALiVE_fnc_dump;
                    };

                    // Road-tangent preferred direction (airports tend to align
                    // with the nearest road's heading in built-up areas).
                    // Computed against cluster centre (validator hasn't run
                    // yet - was incorrectly using uninitialised _flatPos in
                    // the legacy path).
                    private _nearRoad = [_pos, 750, true] call ALiVE_fnc_getClosestRoad;
                    private _direction = if (_nearRoad distance _pos > 5) then {
                        private _road = roadat _nearRoad;
                        private _roadConnectedTo = roadsConnectedTo _road;
                        if (count _roadConnectedTo > 0) then {
                            private _connectedRoad = _roadConnectedTo select 0;
                            (_road getDir _connectedRoad)
                        } else {
                            90
                        };
                    } else {
                        0
                    };

                    // Validator wiring. Replaces the legacy CheckSpawnInMarkerArea
                    // + findFlatArea path. Mode "military" excludes runways /
                    // helipads / buildings / sloped surface / water natively;
                    // the marker-based runway exclusion the legacy helper did
                    // is now redundant.
                    private _envelope = [_HQ] call ALiVE_fnc_getCompositionRadius;
                    private _result = [_pos, _size, _envelope, "military", _direction, _debug] call ALiVE_fnc_findCompositionSpawnPosition;
                    if (count _result == 0) exitWith {
                        ["ATO [%1] - Field ATO: validator found no clear spawn position within %2m of %3 (envelope %4m) - skipped", _faction, _size, _pos, _envelope] call ALiVE_fnc_dump;
                    };
                    _result params ["_flatPos", "_safeDir"];

                    if (isNil QMOD(COMPOSITIONS_LOADED)) then {
                        [_HQ, _flatPos, _safeDir, _faction] call ALiVE_fnc_spawnComposition;
                    };

                    [_logic, "HQBuilding", nearestObject [_flatPos, "building"]] call MAINCLASS;

                    if !(ALIVE_loadProfilesPersistent) then {
                        private _group = ["Infantry",_faction] call ALIVE_fnc_configGetRandomGroup;
                        private _profiles = [_group, _flatPos, random 360, true, _faction] call ALIVE_fnc_createProfilesFromGroupConfig;

                        {
                            if (([_x,"type"] call ALiVE_fnc_HashGet) == "entity") then {
                                [_x, "setActiveCommand", ["ALIVE_fnc_garrison","spawn",[50,"false",[0,0,0]]]] call ALIVE_fnc_profileEntity;
                            };
                        } forEach _profiles;
                    };

                    // DEBUG -------------------------------------------------------------------------------------
                    if(_debug) then {
                        private _atoSide = getNumber ((_faction call ALiVE_fnc_configGetFactionClass) >> "side") call ALIVE_fnc_sideNumberToText;
                        [_flatPos, 4, format ["%1 - Field ATO (%2)", _atoSide, _faction], "ColorPink", "placement.ato"] call ALIVE_fnc_placeDebugMarker;

                        ["ATO [%1] - Field ATO created at %2 - composition %3 - building %4 (envelope=%5m, dir=%6)", _faction, _flatPos, configName _HQ, [_logic, "HQBuilding"] call MAINCLASS, _envelope, _safeDir] call ALiVE_fnc_dump;
                    };
                    // DEBUG -------------------------------------------------------------------------------------
                };
            } else {
                private _faction = [_logic, "faction"] call MAINCLASS;

                // Get nearest buildings
                private _buildings = nearestObjects [_position, ["building"], 750];
                private _hqBuilding = objnull;

                // Check for water, spawn carrier?

                // Check to see if the buildings match our ALiVE types
                {
                    private _blg = typeof _x;
                    if ( {(tolower _blg) find (tolower _x) != -1} count (ALiVE_militaryBuildingTypes + ALIVE_militaryHQBuildingTypes) == 0) then {
                        _buildings set [_forEachIndex, -1];
                    };
                    if !([_x] call ALIVE_fnc_isHouseEnterable) then {
                        _buildings set [_forEachIndex, -1];
                    };
                } forEach _buildings;
                _buildings = _buildings - [-1];

                // ["ATO %1 - Buildings: %2", _logic, _buildings] call ALiVE_fnc_dump;
                if(count _buildings > 0) then {

                    _hqBuilding = _buildings select 0;

                } else {

                    _hqBuilding = ([_baseCluster,"nodes"] call ALiVE_fnc_hashGet) select 0;

                };

                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    private _atoSide = getNumber ((_faction call ALiVE_fnc_configGetFactionClass) >> "side") call ALIVE_fnc_sideNumberToText;
                    [position _hqBuilding, 4, format ["%1 - ATO Building (%2)", _atoSide, _faction], "ColorPink", "placement.ato"] call ALIVE_fnc_placeDebugMarker;
                };
                // DEBUG -------------------------------------------------------------------------------------

                [_logic, "HQBuilding", _hqBuilding] call MAINCLASS;

                if (_debug) then {
                    ["ATO %1 - ATO building selected: %2", _logic, [_logic, "HQBuilding"] call MAINCLASS] call ALiVE_fnc_dump;
                };
            };

            // Set the base location
            [_logic,"currentBase", _baseCluster] call MAINCLASS;

            if(count _modules > 0 && !_isCarrier) then {
                // Tell OPCOM this is a high priority reserve objective
                private _opcom = selectRandom _modules;
                private _id = format["OPCOM_%1_objective_%2",[_opcom,"opcomID"] call ALiVE_fnc_hashGet, format["ATO_%1",ceil(random 1000)]];
                private _pos = [_baseCluster, "center"] call ALiVE_fnc_hashGet;
                private _size = [_baseCluster, "size"] call ALiVE_fnc_hashGet;
                private _type = "strategic";
                private _priority = 500;
                private _opcom_state = "unassigned";
                private _clusterID = [_baseCluster, "clusterID"] call ALiVE_fnc_hashGet;
                private _opcomID = [_opcom,"opcomID"] call ALiVE_fnc_hashGet;

                [_opcom,"addObjective",[_id,_pos,_size,_type,_priority,_opcom_state,_clusterID,_opcomID]] call ALiVE_fnc_OPCOM;
            };

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["ATO %1 - Startup completed", _logic] call ALiVE_fnc_dump;
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------

            // #875 - objective scenery objects (AA-style triplet).
            // 350m default radius for the airfield area.
            private _objCountStr_ATO = [_logic, "objectiveObjectsCount"] call MAINCLASS;
            private _objCount_ATO = if (typeName _objCountStr_ATO == "STRING" && {_objCountStr_ATO != ""}) then { parseNumber _objCountStr_ATO } else { 0 };
            private _objBehaviour_ATO = [_logic, "objectiveObjectsBehaviour"] call MAINCLASS;
            private _objChanceStr_ATO = [_logic, "objectiveObjectsChance"] call MAINCLASS;
            private _objChance_ATO = if (typeName _objChanceStr_ATO == "STRING" && {_objChanceStr_ATO != ""}) then { (parseNumber _objChanceStr_ATO) max 0 min 100 } else { 100 };
            private _countObjectiveObjects_ATO = [_logic, position _logic, 350, _objCount_ATO, _objBehaviour_ATO, _debug, _objChance_ATO] call ALiVE_fnc_spawnObjectiveObjects;
            if (_debug) then {
                ["ATO %1 - Objective objects placed: %2 of %3 (behaviour=%4)",
                    _logic, _countObjectiveObjects_ATO, _objCount_ATO, _objBehaviour_ATO] call ALiVE_fnc_dump;
            };

            _logic setVariable ["startupComplete", true];

            [_logic,"isCarrier", _isCarrier] call MAINCLASS;

            if(count _modules > 0) then {

                // start initial analysis
                [_logic, "initialAnalysis", _modules] call MAINCLASS;
            }else{
                ["ATO %1 - Information, no AI Commanders are synced to Military Air Component Commander module. No CAS, Strike or Recce ATOs available", _logic] call ALiVE_fnc_dump;

            };
        };
    };

    // Analyse Air assets, place aircraft if needed
    case "initialAnalysis": {

        // Get the OPCOMs synchronized and register all air assets and airbases

        if (isServer) then {

            private _modules = _args;
            private _debug = [_logic, "debug"] call MAINCLASS;
            private _modulesFactions = [_logic, "factions"] call MAINCLASS;
            private _airspace = [_logic, "airspace"] call MAINCLASS;
            private _isCarrier = [_logic, "isCarrier"] call MAINCLASS;
            private _persistent = [_logic, "persistent"] call MAINCLASS;
            private _modulesAir = [];
            private _opcoms =[];

            // get modules settings and air assets from syncronised OPCOM instances -------------------------------------------------------------------
            {
                private _module = _x;

                waituntil {
                    ["ATO %1 waiting for OPCOM %2", _logic, [_module,"module"] call ALIVE_fnc_hashGet] call ALiVE_fnc_dump;
                    sleep 10;
                    [_module, "startupComplete"] call ALiVE_fnc_hashGet;
                };

                private _moduleSide = [_module,"side"] call ALiVE_fnc_HashGet;

                // If OPCOM isn't friendly don't add them
                if !([[_moduleSide] call ALIVE_fnc_sideTextToObject,[[_logic, "side"] call MAINCLASS] call ALIVE_fnc_sideTextToObject] call BIS_fnc_sideIsFriendly) exitWith {
                    ["ATO %1 - Warning, AI Commander is synced to an Air Component Commander that is not side friendly.", _logic] call ALiVE_fnc_dumpR;
                    // No deleteAt here - exitWith already skips this module, and removing
                    // an element from the array being walked shifted everything down by
                    // one, so the NEXT synced commander was silently skipped too and its
                    // factions never merged. _modules is not read after this loop.
                };

                // Register side with clients
                MOD(Require) setVariable [format["ALIVE_MIL_ATO_AVAIL_%1", _moduleSide], true, true];

                // Register factions from OPCOM
                private _moduleFactions = [_module,"factions"] call ALiVE_fnc_HashGet;
                {
                    if !(_x in _modulesfactions) then {
                        _modulesFactions pushback _x;
                    };
                } forEach _moduleFactions;

                // Get objectives
                private _objectives = [_module,"objectives"] call ALiVE_fnc_hashGet;
                // (_objectives select 0) call ALIVE_fnc_inspectHash;

            } forEach _modules;

            [_logic, "factions", _modulesFactions] call MAINCLASS;

            // register the module
            [ALIVE_ATOGlobalRegistry,"register",_logic] call ALIVE_fnc_ATOGlobalRegistry;

            if !(_persistent && {[ALIVE_ATOGlobalRegistry,"persistenceLoaded", false] call ALIVE_fnc_hashGet}) then {

                // If no data is loaded, analyse current profiles and register assets

                // Check for any uncrewed profiled vehicles (not registered with OPCOMs) -----------------------------------------------------

                // Grab profiles for the faction
                private _profileIDs = [];
                {
                    _profileIDs = _profileIDs + ([ALIVE_profileHandler, "getProfilesByFaction",_x] call ALIVE_fnc_profileHandler);
                } forEach _modulesFactions;

                // Grab vehicle profiles information only
                {
                    private _profile = [ALIVE_profileHandler, "getProfile",_x] call ALIVE_fnc_profileHandler;

                    if !(isnil "_profile") then {

                        private _type = [_profile,"type"] call ALIVE_fnc_hashGet;

                        switch (tolower _type) do {
                            case ("vehicle") : {

                                private _assignments = [_profile,"entitiesInCommandOf",[]] call ALIVE_fnc_hashGet;

                                if ((count (_assignments)) == 0) then {
                                    private _objectType = [_profile,"objectType"] call ALIVE_fnc_hashGet;
                                    if (tolower _objectType == "plane" || tolower _objectType == "helicopter") then {
                                            _modulesAir pushback _x;
                                    };
                                };
                            };
                        };
                    };
                } forEach _profileIDs;

                if (_debug) then {
                        ["ATO %1 OPCOM has %3 air assets: %2", _logic, _modulesAir, count _modulesAir] call ALiVE_fnc_dump;
                };

                // Go through all profiles and register them ---------------------------------------------------------------------------------------------------
                {
                    private _profileID = _x;
                    private _profile = [ALIVE_profileHandler, "getProfile",_profileID] call ALIVE_fnc_profileHandler;
                    if !(isnil "_profile") then {

                        private _position = [_profile,"position"] call ALIVE_fnc_hashGet;

                        // Check to see if asset is in an airspace
                        private _assetAirspace = nil;
                        {
                            if (_position inArea _x) exitWith {
                                _assetAirspace = _x;
                            };
                        } forEach _airspace;

                        if !(isNil "_assetAirspace") then {
                            [_logic,"registerProfile",[_profileID, _assetAirspace]] call MAINCLASS;
                        };
                    };
                } forEach _modulesAir;

                // If there are no armed air assets and place Air is true then place at least one armed plane or heli ------------------------------------
                private _placeAir = [_logic, "placeAir"] call MAINCLASS;
                private _airCount = [_logic, "assets"] call MAINCLASS;

                if (_debug) then {
                    ["ATO %1 AIR ASSETS: %2",_logic, _airCount] call ALiVE_fnc_dump;
                };

                // DIAG-STRIP: settles whether this module places aircraft at all in a given
                // mission. Both halves matter and neither is visible from the outcome: the
                // block is skipped when Place Aircraft is off, AND skipped when the commander
                // already holds two or more air assets, which is the usual case once adopted
                // aircraft are counted. An airframe parked badly is therefore just as likely
                // to have come from another module entirely.
                if (_debug) then {
                    ["ATO %1 DIAG-STRIP placement gate: placeAir=%2 airAssets=%3 isCarrier=%4 -> placementRuns=%5",
                        _logic,
                        _placeAir,
                        count (_airCount select 1),
                        _isCarrier,
                        (count (_airCount select 1) < 2 && _placeAir && !_isCarrier)] call ALiVE_fnc_dump;
                };

                if (count (_airCount select 1) < 2 && _placeAir && !_isCarrier) then {

                    if(_debug) then {
                        ["ATO %1 - No armed air assets available, placing additional aircraft at base location", _logic] call ALiVE_fnc_dump;
                    };

                    private _baseCluster = [_logic, "currentBase"] call MAINCLASS;
                    private _center = [_baseCluster,"center"] call ALiVE_fnc_hashGet;

                    // Set airspace where base and assets are located
                    private _baseAirspace = _airspace select 0;
                    {
                        if (_center inArea _x) exitWith {
                            _baseAirspace = _x;
                        };
                    } forEach _airspace;

                    private _side = [_logic, "side"] call MAINCLASS;
                    private _faction = [_logic, "faction"] call MAINCLASS;
                    private _aprofiles = [];

                    // Place Helis
                    private _heliClasses = [0,_faction,"Helicopter"] call ALiVE_fnc_findVehicleType;
                    _heliClasses = _heliClasses - ALiVE_PLACEMENT_VEHICLEBLACKLIST;

                    // Remove unarmed classes
                    {
                        if !([_x] call ALiVE_fnc_isArmed) then {
                            _heliClasses set [_forEachIndex, -1];
                        };
                    } forEach _heliClasses;

                    _heliClasses = _heliClasses - [-1];

                    if(count _heliClasses > 0) then {
                        private _nodes = [_baseCluster, "nodes"] call ALIVE_fnc_hashGet;

                        // ["ATO %1 - %3 Nodes: %2", _logic, _nodes, count _nodes] call ALiVE_fnc_dump;
                        {
                            private _pos = [0,0,0];
                            private _dir = 0;
                            private _helipad = objNull;
                            if (_x isKindOf "HeliH") then {
                                _pos = position _x;
                                _dir = direction _x;
                                _helipad = _x;
                            } else {
                                private _helipads = nearestObjects [position _x, ["HeliH"], 250];
                                if (count _helipads > 0) then {
                                    _helipad = _helipads select 0;
                                };
                            };

                            if (!isNull _helipad) then {

                                _pos = position _helipad;
                                _dir = getdir _helipad;

                                // Check helipad is not allocated to unarmed heli
                                private _nearbyObj = nearestObjects [position _helipad, ["Helicopter"], 10];
                                private _nearbyProfiles = [position _helipad, 10, [_side,"vehicle","Helicopter"]] call ALIVE_fnc_getNearProfiles;

                                if (count _nearbyObj == 0 && count _nearbyProfiles == 0) then {

                                    private _vehicleClass = _heliClasses call BIS_fnc_selectRandom;

                                    if(_debug) then {
                                        ["ATO (%2) - Found helipad at %3 adding %1", _vehicleClass, _faction, _pos] call ALiVE_fnc_dump;
                                    };

                                    private _tmp = [_vehicleClass,_side,_faction,"CAPTAIN",_pos,_dir,false,_faction,false] call ALIVE_fnc_createProfilesCrewedVehicle;
                                    {
                                        // _x call ALIVE_fnc_inspectHash;
                                        if ([_x,"type"] call ALiVE_fnc_hashGet == "entity") then {
                                            _aprofiles pushback ([_x,"profileID"] call ALiVE_fnc_hashGet);
                                        };
                                    } forEach _tmp;
                                };
                            };
                        } forEach _nodes;

                        // IF there are no helipads available, we want atleast 1 chopper. Spawn a composition
                        if (count _aprofiles == 0) then {
                            // Spawn a heliport
                            private _pos = [_baseCluster,"center"] call ALiVE_fnc_HashGet;
                            private _size = [_baseCluster,"size",150] call ALiVE_fnc_HashGet;

                            // Composition selection - hoisted outside the
                            // !COMPOSITIONS_LOADED branch so the validator
                            // below can size its envelope to the actual layout.
                            private _compType = "Military";
                            If (_faction call ALiVE_fnc_factionSide == RESISTANCE) then {
                                _compType = "Guerrilla";
                            };
                            private _heliport = selectRandom ([_compType, ["Heliports"], [], _faction] call ALiVE_fnc_getCompositions);

                            if !(isNil "_heliport") then {

                                // Road-tangent preferred direction. Computed
                                // against cluster centre (validator hasn't
                                // run yet).
                                private _nearRoad = [_pos, 750, true] call ALiVE_fnc_getClosestRoad;
                                private _direct = if (_nearRoad distance _pos > 5) then {
                                    private _road = roadat _nearRoad;
                                    private _roadConnectedTo = roadsConnectedTo _road;
                                    if (count _roadConnectedTo > 0) then {
                                        private _connectedRoad = _roadConnectedTo select 0;
                                        (_road getDir _connectedRoad)
                                    } else {
                                        90
                                    };
                                } else {
                                    0
                                };

                                // Validator wiring. Mode "military" excludes
                                // existing helipads from the footprint
                                // (`_excludeHelipads`) so a new Heliport
                                // composition won't overlap an existing one.
                                private _envelope = [_heliport] call ALiVE_fnc_getCompositionRadius;
                                private _result = [_pos, _size, _envelope, "military", _direct, _debug] call ALiVE_fnc_findCompositionSpawnPosition;
                                if (count _result == 0) exitWith {
                                    ["ATO [%1] - Heliport: validator found no clear spawn position within %2m of %3 (envelope %4m) - skipped", _faction, _size, _pos, _envelope] call ALiVE_fnc_dump;
                                };
                                _result params ["_flatPos", "_safeDir"];
                                _direct = _safeDir;
                                private _position = _flatPos;

                                if (isNil QMOD(COMPOSITIONS_LOADED)) then {
                                    [_heliport, _flatPos, _safeDir, _faction] call ALiVE_fnc_spawnComposition;

                                    private _helipad = nearestObject [_flatpos, "HeliH"];

                                    if !(isNull _helipad) then {

                                        _position = position _helipad;

                                        // remove any pre-placed aircraft on composition?
                                        private _nearbyObj = nearestObjects [position _helipad, ["Helicopter"], 20];
                                        if (count _nearbyObj > 0) then {
                                            {
                                                deleteVehicle _x;
                                            }forEach _nearbyObj;
                                        };

                                    } else {
                                        // add a bloody helipad TODO: improve placement
                                        "Land_HelipadEmpty_F" createVehicle _flatPos;
                                    };

                                    private _vehicleClass = selectRandom _heliClasses;

                                    if(_debug) then {
                                        ["ATO %1 (%2) - Created helipad at %3 adding %1", _vehicleClass, _faction, _position] call ALiVE_fnc_dump;
                                    };

                                    private _tmp = [_vehicleClass,_side,_faction,"CAPTAIN",_position,_direct,true,_faction,false] call ALIVE_fnc_createProfilesCrewedVehicle;
                                    {
                                        // _x call ALIVE_fnc_inspectHash;
                                        if ([_x,"type"] call ALiVE_fnc_hashGet == "entity") then {
                                            _aprofiles pushback ([_x,"profileID"] call ALiVE_fnc_hashGet);
                                        };
                                    } forEach _tmp;

                                };
                            };
                        };

                        if(_debug) then {
                            ["ATO %1 - %3 Helicopters to be added: %2", _logic, _aprofiles, count _aprofiles] call ALiVE_fnc_dump;
                        };
                    };

                    // Place planes
                    private _airClasses = [0,_faction,"Plane"] call ALiVE_fnc_findVehicleType;

                    // Remove unarmed classes
                    {
                        if !([_x] call ALiVE_fnc_isArmed) then {
                            _airClasses set [_forEachIndex, -1];
                        };
                    } forEach _airClasses;

                    _airClasses = _airClasses - [-1];

                    if(count _airClasses > 0) then {

                        private _nodes = [_baseCluster, "nodes"] call ALIVE_fnc_hashGet;

                        private _buildings = [_nodes, (ALIVE_airBuildingTypes + ALIVE_militaryAirBuildingTypes)] call ALIVE_fnc_findBuildingsInClusterNodes;
                        // ["ATO %1 - %3 Hangar Buildings: %2", _logic, _buildings, count _buildings] call ALiVE_fnc_dump;

                        if (count _buildings == 0) then {
                            // No hangars, use HQ and check for runways
                            _buildings = [[_logic, "HQBuilding"] call MAINCLASS];
                        };

                        private _firstbuilding = true;

                        {
                            // Check hangar is not allocated to a plane
                            private _nearbyObj = nearestObjects [position _x, ["Plane","Helicopter"], 20];
                            private _nearbyProfiles = [position _x, 20, [_side,"vehicle","Plane"]] call ALIVE_fnc_getNearProfiles;
                            private _availablePlane = true;

                            if (count _nearbyObj == 0 && count _nearbyProfiles == 0) then {
                                if (_firstbuilding || random 1 > 0.30) then {

                                    private _posi = [0,0,0];
                                    private _dire = 0;
                                    private _vehicleClass = _airClasses call BIS_fnc_selectRandom;

                                    // Find safe place to put aircraft
                                    private ["_pavement","_runway","_position"];
                                    if (([typeOf _x, "hangar"] call CBA_fnc_find != -1 || [typeOf _x, "Hangar"] call CBA_fnc_find != -1) && _vehicleClass iskindof "Plane") then {
                                        _posi = position _x;
                                        _dire = direction _x;

                                        // Handle reversed hangars
                                        if (typeof _x in ALIVE_problematicHangarBuildings  || str(_posi) in ALIVE_problematicHangarBuildings) then {
                                            // reverse the direction of planes
                                            _dire = _dire + 180;

                                        };

                                        // open all doors
                                        private _numOfDoors = getNumber (configfile >> "CfgVehicles" >> typeOf _x >> "numberOfDoors");
                                        if (_numOfDoors > 0) then {
                                            for "_i" from 1 to _numOfDoors do {
                                                [_x, _i, 1] call BIS_fnc_door;
                                            };
                                        }

                                    } else {

                                        // find a taxiway
                                        _runway = [];
                                        {
                                            if ( (str(_x) find "taxiway" != -1 && typeof _x == "") || str(_x) find "invisible" != -1 ) then {
                                                _runway pushback _x;
                                            };
                                        } forEach (nearestObjects [position _x, [], 400]);

                                        if (count _runway > 0) then {
                                            // ["Cannot find hangar, choosing safe taxiway from: %1", _runway] call ALiVE_fnc_dump;
                                            _pavement = selectRandom _runway;
                                            _posi = [position _pavement, 0, 75, 20, 0, 0.2, 0] call BIS_fnc_findSafePos;
                                            _dire = direction _pavement;
                                        } else {

                                            // No safe place for plane, try to place VTOL instead
                                            //["Cannot find hangar or taxiway, looking for safe place to put aircraft %1", _vehicleClass] call ALiVE_fnc_dump;
                                            _availablePlane = false;

                                            If !(_vehicleClass isKindOf "VTOL_Base_F") then {
                                                // Find a vtol aircraft,
                                                {
                                                    if (_vehicleClass isKindOf "VTOL_Base_F") then {
                                                        _vehiclesClass = _x;
                                                        _availablePlane = true;
                                                    };
                                                } forEach _airClasses;
                                            };

                                            _posi = [position _x, 5, 200, 30, 0, 0.2, 0] call BIS_fnc_findSafePos;
                                            _dire = direction _x;
                                        };

                                        if (_availablePlane) then {
                                           // No Hangar, then place one somewhere (if available) and plane is available

                                            if (isNil QMOD(COMPOSITIONS_LOADED)) then {

                                                // Get a composition
                                                private _compType = "Military";
                                                If (_faction call ALiVE_fnc_factionSide == RESISTANCE) then {
                                                    _compType = "Guerrilla";
                                                };

                                            private _hangar = selectRandom ([_compType, ["Airports"], ["Medium"], _faction] call ALiVE_fnc_getCompositions);
                                            if !(isNil "_hangar") then {
                                                // Validator wiring. Search
                                                // anchored on the existing
                                                // airport building (`_x` in
                                                // the surrounding foreach);
                                                // direction inherits from
                                                // the building so the new
                                                // hangar aligns with the
                                                // airfield's primary axis.
                                                private _envelope = [_hangar] call ALiVE_fnc_getCompositionRadius;
                                                private _result = [position _x, 150, _envelope, "military", direction _x, _debug] call ALiVE_fnc_findCompositionSpawnPosition;
                                                if (count _result > 0) then {
                                                    _result params ["_flatPos", "_safeDir"];
                                                    [_hangar, _flatPos, _safeDir, _faction] call ALiVE_fnc_spawnComposition;
                                                    if (_debug) then {
                                                        ["ATO [%1] - Hangar: %2 spawned at %3 (envelope=%4m, dir=%5)", _faction, configName _hangar, _flatPos, _envelope, _safeDir] call ALiVE_fnc_dump;
                                                    };
                                                } else {
                                                    if (_debug) then {
                                                        ["ATO [%1] - Hangar: validator found no clear spawn position within 150m of %2 (envelope %3m) - skipped", _faction, position _x, _envelope] call ALiVE_fnc_dump;
                                                    };
                                                };
                                            };
                                            };
                                        };
                                    };

                                    if (_availablePlane) then {
                                        // Place a hangar

                                        // Place Aircraft
                                        // ATO_HANGAR_DBG (DIAG-STRIP): initial airframe placement. _posi is the hangar building position, reused later as the profile startPos by _fnc_safeReposition on return. PASSIVE log only -- deliberately does NOT call findAirSpawnPosition here (it opens hangar doors + reserves a 60s anti-race slot, which would perturb the real spawn); the FASP return is captured at reposition instead.
                                        diag_log format ["ATO_HANGAR_DBG SPAWN class=%1 pos=%2 insideBldg=%3 bldgTypes=%4", _vehicleClass, _posi, (count (nearestObjects [_posi, ["House","Building"], 6]) > 0), (nearestObjects [_posi, ["House","Building"], 6] apply {typeOf _x})];
                                        private _tmp = [_vehicleClass,_side,_faction,_posi,_dire,false,_faction] call ALIVE_fnc_createProfileVehicle;
                                        // _tmp call ALIVE_fnc_inspectHash;
                                        _aprofiles pushback ([_tmp, "profileID"] call ALIVE_fnc_hashGet);
                                    };

                                };
                                _firstbuilding = false;
                            };
                        } forEach _buildings;
                    };

                    if(_debug) then {
                        ["ATO %1 - %3 total aircraft to be added: %2", _logic, _aprofiles, count _aprofiles] call ALiVE_fnc_dump;
                    };

                    // Add new profiles to module
                    {
                        private _profileID = _x;
                        private _profile = [ALIVE_profileHandler, "getProfile",_profileID] call ALIVE_fnc_profileHandler;

                        if !(isnil "_profile") then {
                            [_logic,"registerProfile",[_profileID,_baseAirspace]] call MAINCLASS;
                        };
                    } forEach _aprofiles;
                };

                // Place drones. Separate from placing crewed aircraft on purpose:
                // a drone needs no aircrew, so an air component can consist of
                // nothing but drones, and that should not depend on whether crewed
                // aircraft were wanted as well.
                if (([_logic,"placeDrones"] call MAINCLASS) && {!_isCarrier}) then {

                    // No point placing what the commander has been told to ignore.
                    if !([_logic,"useUAVs"] call MAINCLASS) then {
                        if (_debug) then {
                            ["ATO %1 - not placing drones, they are turned off for this commander", _logic] call ALiVE_fnc_dump;
                        };
                    } else {

                        private _droneBase = [_logic, "currentBase"] call MAINCLASS;
                        private _droneCentre = [_droneBase,"center"] call ALiVE_fnc_hashGet;

                        private _droneAirspace = _airspace select 0;
                        {
                            if (_droneCentre inArea _x) exitWith { _droneAirspace = _x; };
                        } forEach _airspace;

                        private _droneSide = [_logic, "side"] call MAINCLASS;
                        private _droneFaction = [_logic, "faction"] call MAINCLASS;

                        private _droneClasses = [];

                        // A named list wins over the faction's own. Plenty of factions
                        // catalogue no drones at all - RHS US Army is one - so without
                        // this the setting simply cannot work for them, however many
                        // drones the mod itself ships.
                        private _customDrones = [_logic,"droneTypes"] call MAINCLASS;

                        if (_customDrones != "") then {
                            {
                                private _cls = _x;
                                if (_cls != "") then {
                                    if !(isClass (configFile >> "CfgVehicles" >> _cls)) then {
                                        ["ATO %1 - Warning, drone type %2 does not exist and was ignored. Check the spelling in this module's Drone Types setting.", _logic, _cls] call ALiVE_fnc_dumpR;
                                    } else {
                                        // Named classes are checked for being flyable as well
                                        // as existing. The picker only offers aircraft, but a
                                        // value typed by hand, or carried over from a mission
                                        // saved before the picker existed, is not constrained
                                        // by it - and a ground rover would be placed at the
                                        // airfield and then tasked with a sortie.
                                        if (_cls isKindOf "Air") then {
                                            _droneClasses pushBackUnique _cls;
                                        } else {
                                            ["ATO %1 - Warning, drone type %2 is not an aircraft and was ignored.", _logic, _cls] call ALiVE_fnc_dumpR;
                                        };
                                    };
                                };
                            } forEach (_customDrones splitString "[]""', ");
                        } else {

                            // Ask for both families and keep only the drones. Asking for
                            // the "UAV" class directly would miss the small rotary
                            // reconnaissance drones, whose base inherits from the
                            // helicopter chain rather than from UAV, and those are the
                            // ones most worth having.
                            _droneClasses = (([0,_droneFaction,"Helicopter"] call ALiVE_fnc_findVehicleType)
                                          + ([0,_droneFaction,"Plane"] call ALiVE_fnc_findVehicleType))
                                          - ALiVE_PLACEMENT_VEHICLEBLACKLIST;

                            _droneClasses = _droneClasses select {
                                _x isKindOf "UAV" || {getNumber (configFile >> "CfgVehicles" >> _x >> "isUav") == 1}
                            };
                        };

                        // Deliberately NOT filtered for armament, unlike the crewed
                        // aircraft above. A reconnaissance drone carries nothing, so
                        // that filter would throw away exactly what was asked for -
                        // which is why drones were never placed even when a faction
                        // had them.

                        if (count _droneClasses == 0) then {
                            ["ATO %1 - Warning, drone placement is on but faction %2 has no drones to place.", _logic, _droneFaction] call ALiVE_fnc_dumpR;
                        } else {

                            private _droneClass = selectRandom _droneClasses;
                            private _dronePos = +_droneCentre;
                            private _droneDir = random 360;

                            private _dronePlaced = false;
                            // Which step actually chose the spot. Worth recording: the
                            // difference between a deliberate helipad and a position that
                            // was merely shoved off the taxiway is invisible otherwise, and
                            // they look identical in the log once placed.
                            private _droneVia = "base centre fallback";

                            // Prefer a helipad if the base has one - it keeps the drone
                            // clear of the runway and looks deliberate rather than
                            // dropped in the middle of the field.
                            {
                                if (_x isKindOf "HeliH") exitWith {
                                    _dronePos = position _x;
                                    _droneDir = direction _x;
                                    _dronePlaced = true;
                                    _droneVia = "helipad";
                                };
                            } forEach ([_droneBase, "nodes"] call ALIVE_fnc_hashGet);

                            // No helipad, so ask the air placement validator for a real
                            // spot rather than falling back to the middle of the base.
                            // That fallback is what put a drone on the taxiway, where it
                            // stopped every aircraft trying to taxi out: the engine snags
                            // fixed wing taxi pathfinding on anything parked within about
                            // eight metres of the route, and the validator already applies
                            // that clearance along with runway and taxiway exclusion,
                            // footprint checks and a short lived registry that stops two
                            // placements choosing the same spot.
                            if (!_dronePlaced && {!isNil "ALiVE_fnc_findAirSpawnPosition"}) then {
                                private _spot = [_droneClass, _droneCentre, 400, "auto"] call ALiVE_fnc_findAirSpawnPosition;
                                if (count _spot >= 2) then {
                                    _dronePos = +(_spot select 0);
                                    // Ground it: a hangar tier spot carries the building's
                                    // elevated origin and would float the drone in the roof.
                                    _dronePos set [2, 0];
                                    _droneDir = _spot select 1;
                                    _dronePlaced = true;
                                    _droneVia = "air spawn validator";
                                };
                            };

                            // Keep it off the runway and the taxiways. Without a helipad the
                            // position above falls back to the middle of the base, which on a
                            // real airfield is as likely as not to be the taxiway, and a parked
                            // drone sitting there blocks every aircraft trying to get out.
                            //
                            // Parking areas are deliberately still allowed: an apron is exactly
                            // where a drone should sit. Only the surfaces aircraft have to move
                            // along are cleared.
                            //
                            // The isNil guard covers the window where this file has been picked
                            // up by file patching but the airside functions have not been
                            // compiled yet; skipping the nudge leaves the old behaviour rather
                            // than throwing.
                            if (!isNil "ALiVE_fnc_airsideClear") then {
                                private _clearPos = [_dronePos, [1,2]] call ALiVE_fnc_airsideClear;
                                if (_debug && {(_clearPos distance2D _dronePos) > 1}) then {
                                    ["ATO %1 - drone start position moved %2m clear of runway and taxiway", _logic, round (_clearPos distance2D _dronePos)] call ALiVE_fnc_dump;
                                };
                                _dronePos = _clearPos;
                            };

                            private _droneProfile = [_droneClass,_droneSide,_droneFaction,_dronePos,_droneDir,false,_droneFaction] call ALIVE_fnc_createProfileVehicle;

                            if !(isNil "_droneProfile") then {
                                private _droneID = [_droneProfile, "profileID"] call ALIVE_fnc_hashGet;
                                if (!isNil "_droneID" && {_droneID != ""}) then {
                                    [_logic,"registerProfile",[_droneID,_droneAirspace]] call MAINCLASS;
                                    if (_debug) then {
                                        ["ATO %1 - placed drone %2 at %3 via %4", _logic, _droneClass, _dronePos, _droneVia] call ALiVE_fnc_dump;
                                    };
                                };
                            };
                        };
                    };
                };

                // Register new assets
                private _registryID = [_logic, "registryID"] call MAINCLASS;
                private _assets = [_logic, "assets"] call MAINCLASS;
                [ALIVE_ATOGlobalRegistry,"updateGlobalATO",[_registryID,_assets]] call ALIVE_fnc_ATOGlobalRegistry;

            } else {

                // Update ATO module and aircraft state
                private _factions = ALIVE_globalATO select 1;
                private _assets = [] call ALIVE_fnc_hashCreate;
                private _as = [_logic,"airspaceAssets",[] call ALIVE_fnc_hashCreate] call ALiVE_fnc_ATO;

                {
                    if (_x in ([_logic,"factions"] call ALiVE_fnc_ATO)) then {

                        private _aircraft = [ALIVE_globalATO, _x] call ALiVE_fnc_hashGet;

                        // DEBUG -------------------------------------------------------------------------------------
                        if(_debug) then {
                            ["ATO Updating %1 logic faction %2 with %3", _logic, _x, (_aircraft select 1)] call ALIVE_fnc_dump;
                        };
                        // DEBUG -------------------------------------------------------------------------------------

                        {

                            private _profile = [ALIVE_profileHandler, "getProfile", _x] call ALiVE_fnc_profileHandler;

                            if !(isNil "_profile") then {

                                private _vehicle = [_aircraft, _x] call ALiVE_fnc_hashGet;
                                private _currentPosition = [_profile, "position"] call ALiVE_fnc_hashGet;

                                // reset operation and current position, add runway
                                [_vehicle, "currentOp", ""] call ALiVE_fnc_hashSet;
                                [_vehicle, "currentPos", _currentPosition] call ALiVE_fnc_hashSet;

                                // TODO If aircraft are in mid air, get them to RTB?

                                private _runway = [_vehicle, "airportID",""] call ALiVE_fnc_hashGet;
                                if (_runway isEqualType 0) then {
                                    [_logic, "addRunway", _runway] call ALIVE_fnc_ATO;
                                };

                                // put back any helipads
                                private _helipadPos = [_vehicle, "helipad",[]] call ALiVE_fnc_hashGet;
                                if (count _helipadPos > 0) then {
                                    // create an invisble helipad
                                    private _tmp = _helipadPos nearObjects ["HeliH", 5];
                                    if (count _tmp == 0) then {
                                        private _helipad = "Land_HelipadEmpty_F" createvehicle _helipadPos;
                                        [_vehicle,"helipad",position _helipad] call ALiVE_fnc_hashSet;
                                    } else {
                                        [_vehicle,"helipad",position (_tmp select 0)] call ALiVE_fnc_hashSet;
                                    };
                                };

                                // Add vehicle to logic
                                [_assets, _x, _vehicle] call ALiVE_fnc_hashSet;

                                // Add vehicle to logic airspace
                                private _assetAirspace = [_vehicle, "airspace"] call ALiVE_fnc_hashGet;
                                private _airspaceAssets = [_as, _assetAirspace, [] ] call ALiVE_fnc_hashGet;
                                _airspaceAssets pushbackUnique _x;
                                [_as, _assetAirspace, _airspaceAssets] call ALiVE_fnc_hashSet;
                            };

                        } forEach (_aircraft select 1);
                    }
                } forEach _factions;

                [_logic, "assets" ,_assets] call ALiVE_fnc_ATO;
                [_logic,"airspaceAssets",_as] call ALiVE_fnc_ATO;
            };

            // set as initial analysis complete
            _logic setVariable ["initialAnalysisComplete", true];

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["ATO %1 - Analysis completed",_logic] call ALiVE_fnc_dump;
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                ["ATO - Analysis %1", _logic] call ALiVE_fnc_dump;
                ["ATO - OPCOMs: %1", count _modules] call ALiVE_fnc_dump;
                ["ATO - Factions: %1", [_logic, "factions"] call MAINCLASS] call ALiVE_fnc_dump;
                ["ATO - Air Assets: %1", count (([_logic, "assets"] call MAINCLASS) select 1)] call ALiVE_fnc_dump;
                ["ATO - Assets by Airspace:"] call ALiVE_fnc_dump;
                ([_logic,"airspaceAssets"] call MAINCLASS) call ALIVE_fnc_inspectHash;
            };
            // DEBUG -------------------------------------------------------------------------------------

            // Broadcast radio message
            private _faction = [_logic, "faction"] call MAINCLASS;
            private _location = mapGridPosition (position ([_logic, "HQBuilding"] call MAINCLASS));
            private _side = [_logic, "side"] call MAINCLASS;
            private _sideObject = [_side] call ALIVE_fnc_sideTextToObject;
            private _factionName = getText((_faction call ALiVE_fnc_configGetFactionClass) >> "displayName");
            private _hqClass = switch (_sideObject) do {
                case WEST: {
                    "BLU"
                };
                case EAST: {
                    "OPF"
                };
                case RESISTANCE: {
                    "IND"
                };
                default {
                    "HQ"
                };
            };
            private _HQ = getText(configFile >> "CfgHQIdentities" >> _hqClass >> "name");

            private _message = format[localize "STR_ALIVE_ATO_ESTABLISHED", _HQ, _factionName, _location];

            // If no air assets, say so - but do NOT stop here
            if (count (([_logic, "assets"] call MAINCLASS) select 1) == 0) then {
                ["ATO %1 - Warning, no air assets found within the airspace. Requests will be refused until aircraft are available. Check this module's faction, its airspace markers, and that armed aircraft of that faction start inside them.", _logic] call ALiVE_fnc_dumpR;
                _message = format[localize "STR_ALIVE_ATO_NOT_ESTABLISHED", _HQ, _factionName];
            };

            // send a message to all side players from HQ
            private _radioBroadcast = [objNull,_message,"side",_sideObject,false,false,false,true,_hqClass];
            [_side,_radioBroadcast] call ALIVE_fnc_radioBroadcastToSide;

            // Start main processes even when the roster came up empty. This used to exit
            // early, which left the commander deaf for the rest of the mission: it never
            // subscribed to the event bus at all, so requests went unanswered rather than
            // refused, and nothing delivered later could ever be taken on. Starting the
            // listener regardless costs nothing - with no aircraft the request gate simply
            // declines every request, which is the behaviour a mission maker expects.
            // start listening for ATO events
            [_logic,"listen"] call MAINCLASS;

            // trigger main processing loop
            [_logic, "monitor"] call MAINCLASS;
        };
    };

    // Listen for events
    case "listen": {
        private["_listenerID"];

        // #460 Phase B - LOGISTICS_COMPLETE lets us adopt an airframe LOGCOM delivered
        // against one of our resupply requests. Every module hears every completion, so
        // the handler filters by the eventID we stashed in resupplyPending.
        _listenerID = [ALIVE_eventLog, "addListener",[_logic, ["ATO_REQUEST","ATO_STATUS_REQUEST","ATO_CANCEL_REQUEST","LOGISTICS_COMPLETE"]]] call ALIVE_fnc_eventLog;
        _logic setVariable ["listenerID", _listenerID];
    };

    // Handle events
    case "handleEvent": {

        private["_event","_type","_eventData"];

        if(_args isEqualType []) then {

            _event = _args;
            _type = [_event, "type"] call ALIVE_fnc_hashGet;

            [_logic, _type, _event] call MAINCLASS;

        };
    };

    // #460 Phase B - adopt an airframe LOGCOM delivered against one of our requests.
    // NOTE: the case name MUST be the raw event type - handleEvent dispatches
    // [_logic, _type, _event] straight into this switch.
    case "LOGISTICS_COMPLETE": {

        private _debug = [_logic, "debug"] call MAINCLASS;
        private _eventData = [_args, "data"] call ALIVE_fnc_hashGet;
        if !(_eventData isEqualType []) exitWith {};

        private _eventID = _eventData param [3, ""];
        private _pending = [_logic, "resupplyPending"] call MAINCLASS;
        private _entry   = [_pending, str _eventID, []] call ALiVE_fnc_hashGet;

        // Every module hears every completion - anything not ours exits quietly.
        if !(_entry isEqualType []) exitWith {};
        if (count _entry == 0) exitWith {};

        // Consume the pending entry now: this completion is ours whether or not the
        // adoption below succeeds, and a duplicate completion (some transport paths
        // fire it twice) must not re-run it.
        private _abandoned = if (count _entry > 3) then {_entry select 3} else {false};
        [_pending, str _eventID] call ALiVE_fnc_hashRem;

        private _asset     = _entry select 0;
        private _delivered = _eventData param [5, []];

        // The sweep already gave up on this one and queued a replacement by another route,
        // so adopting now would leave us a duplicate airframe. ML held these busy for us,
        // so hand them to OPCOM rather than stranding an aircraft nobody commands.
        if (_abandoned) exitWith {
            ["ATO - LOGCOM delivery for event %1 arrived after we gave up on it; releasing rather than orphaning.", _eventID] call ALiVE_fnc_dumpR;
            {
                {
                    private _p = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                    if !(isNil "_p") then { [_p, "busy", false] call ALiVE_fnc_hashSet; };
                } forEach _x;
            } forEach _delivered;
        };

        // Resolve the delivered pair by PROFILE TYPE, not by position - the export is a
        // nested [entityID, vehicleID] pair and relying on ordering is fragile.
        private _entityID  = "";
        private _vehicleID = "";
        {
            {
                private _p = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                if !(isNil "_p") then {
                    if (([_p, "type"] call ALIVE_fnc_hashGet) == "entity") then {
                        _entityID = _x;
                    } else {
                        _vehicleID = _x;
                    };
                };
            } forEach _x;
        } forEach _delivered;

        if (_entityID == "") exitWith {
            ["ATO - LOGCOM delivery for event %1 carried no adoptable crewed airframe; releasing it.", _eventID] call ALiVE_fnc_dumpR;
            // Don't strand it. ML held these busy for us, so hand back what did arrive
            // rather than leave an airframe nobody can command.
            {
                {
                    private _p = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                    if !(isNil "_p") then { [_p, "busy", false] call ALiVE_fnc_hashSet; };
                } forEach _x;
            } forEach _delivered;
        };

        // Adopt via the ENTITY profile. registerProfile only stamps crewID (and busies the
        // crew) on the entity path; adopting the vehicle profile of an already-crewed
        // airframe leaves crewID unset and the tasking loop rejects it as crew-unavailable.
        private _baseAirspace = [_asset, "airspace"] call ALiVE_fnc_hashGet;
        [_logic, "registerProfile", [_entityID, _baseAirspace]] call MAINCLASS;

        // Stand the ML fuel watchdog down - we command this airframe now, and it would
        // otherwise keep forcing RTB/landing at an ML position and fight our tasking.
        private _entProfile = [ALIVE_profileHandler, "getProfile", _entityID] call ALIVE_fnc_profileHandler;
        if !(isNil "_entProfile") then {
            [_entProfile, "alive_ml_releaseWatchdog", true] call ALiVE_fnc_hashSet;
        };

        // registerProfile derives startPos/startDir/airportID (and can create a helipad)
        // from where the airframe currently IS - wherever LOGCOM flew it, not our parking
        // spot. Restore the lost aircraft's geometry from the stashed asset.
        private _assets   = [_logic, "assets"] call MAINCLASS;
        private _aircraft = [_assets, _vehicleID, ""] call ALiVE_fnc_hashGet;

        if (_aircraft isEqualType "") exitWith {
            ["ATO - adopted %1 for event %2 but no asset was registered against %3.", _entityID, _eventID, _vehicleID] call ALiVE_fnc_dumpR;
        };

        {
            private _v = [_asset, _x, "__unset__"] call ALiVE_fnc_hashGet;
            if !(_v isEqualTo "__unset__") then { [_aircraft, _x, _v] call ALiVE_fnc_hashSet; };
        } forEach ["startPos","startDir","airportID","helipad","isOnCarrier"];

        // Mirror the self-create tail so the maintenance cycle sees identical state.
        [_aircraft, "maintenance", time] call ALiVE_fnc_hashSet;

        if (_debug) then {
            ["ATO - adopted LOGCOM-delivered %1 (entity %2, vehicle %3) for event %4.",
                [_asset,"vehicleClass"] call ALiVE_fnc_hashGet, _entityID, _vehicleID, _eventID] call ALiVE_fnc_dumpR;
        };
    };

    // Handle status request
    case "ATO_STATUS_REQUEST": { //TODO

        private["_debug","_event","_eventData","_eventQueue","_side","_factions","_eventFaction","_eventSide","_factionFound",
        "_moduleFactions","_eventPlayerID","_eventRequestID"];

        if(_args isEqualType []) then {

            _event = _args;
            _eventData = [_event, "data"] call ALIVE_fnc_hashGet;

            _side = [_logic, "side"] call MAINCLASS;
            _factions = [_logic, "factions"] call MAINCLASS;

            _eventFaction = _eventData select 0;
            _eventSide = _eventData select 1;
            _eventRequestID = _eventData select 2;
            _eventPlayerID = _eventData select 3;

            // check if the faction in the event is handled
            // by this module
            _factionFound = false;

            {
                _moduleFactions = _x select 1;
                if(_eventFaction in _moduleFactions) then {
                    _factionFound = true;
                };
            } forEach _factions;

            // faction not handled by this mil air tasking orders module
            if!(_factionFound) then {

                private ["_sideOPCOMModules","_factionOPCOMModules","_checkModule","_moduleType","_handler","_OPCOMSide","_OPCOMFactions","_OPCOMHasLogistics","_mod"];

                _sideOPCOMModules = [];
                _factionOPCOMModules = [];

                // loop through OPCOM modules with mil air tasking orders synced and find any matching the events side and faction
                {

                    _checkModule = _x;
                    _moduleType = _x getVariable "moduleType";

                    if!(isNil "_moduleType") then {

                        if(_moduleType == "ALIVE_OPCOM") then {

                            _handler = _checkModule getVariable "handler";
                            _OPCOMSide = [_handler,"side"] call ALIVE_fnc_hashGet;
                            _OPCOMFactions = [_handler,"factions"] call ALIVE_fnc_hashGet;
                            _OPCOMHasLogistics = false;

                            for "_i" from 0 to ((count synchronizedObjects _checkModule)-1) do {

                                _mod = (synchronizedObjects _checkModule) select _i;

                                if ((typeof _mod) == "ALiVE_mil_ato") then {
                                    _OPCOMHasLogistics = true;
                                };
                            };

                            if(_OPCOMHasLogistics) then {

                                if(_OPCOMSide == _eventSide) then {
                                    _sideOPCOMModules pushback _checkModule;
                                };

                                {
                                    if(_x == _eventFaction) then {
                                        _factionOPCOMModules pushback _checkModule;
                                    };

                                } forEach _OPCOMFactions;

                            };
                        };
                    };
                } forEach (entities "Module_F");

                // if no mil air tasking orders handles this faction, and there is more than one mil
                // air tasking orders for this side return an error
                if(((count _factionOPCOMModules == 0) && (count _sideOPCOMModules > 1)) || ((count _factionOPCOMModules == 0) && (count _sideOPCOMModules == 0))) then {
                    _factionFound = false;
                };

                // if no mil air tasking orders handles this faction, and there is one mil
                // air tasking orders for this side and this module handles that side
                if((count _factionOPCOMModules == 0) && (count _sideOPCOMModules == 1) && (_side == _eventSide)) then {
                    _factionFound = true;
                };
            };

            if!(_factionFound) exitWith {};

            if(_factionFound) then {

                private ["_eventQueue","_response","_responseItem","_playerRequested","_eventData","_logEvent","_playerID",
                "_eventState","_eventType","_eventATO","_requestID","_transportProfiles","_position","_playerRequestProfileID","_profile"];

                // get the event data for this player

                _eventQueue = [_logic, "eventQueue"] call MAINCLASS;

                _response = [];

                if((count (_eventQueue select 2)) > 0) then {

                    {
                        _playerRequested = [_x, "playerRequested"] call ALIVE_fnc_hashGet;

                        if(_playerRequested) then {
                            _eventData = [_x, "data"] call ALIVE_fnc_hashGet;
                            _playerID = _eventData select 5;
                            _eventType = _eventData select 4;
                            _eventATO = _eventData select 3;

                            if(_eventPlayerID == _playerID) then {

                                _responseItem = [];

                                _requestID = _eventATO select 0;
                                _eventState = [_x, "state"] call ALIVE_fnc_hashGet;
                                _transportProfiles = [_x, "transportProfiles"] call ALIVE_fnc_hashGet;

                                _positions = [];

                                if(count _transportProfiles > 0) then {

                                    {
                                        _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;

                                        if!(isNil "_profile") then {
                                            _position = _profile select 2 select 2;
                                            _positions pushBack _position;
                                        };

                                    } forEach _transportProfiles;

                                };

                                _responseItem pushBack _eventType;
                                _responseItem pushBack _requestID;
                                _responseItem pushBack _eventState;
                                _responseItem pushBack _positions;

                                _response pushBack _responseItem;
                            };
                        };

                    } forEach (_eventQueue select 2);

                };

                // respond to player request
                _logEvent = ['ATO_RESPONSE', [_eventRequestID,_eventPlayerID,_response],"Military Air Component Commander","STATUS"] call ALIVE_fnc_event;
                [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;
            };
        };
    };

    // Handle cancel request
    case "ATO_CANCEL_REQUEST": { //TODO

        private["_debug","_event","_eventData","_eventQueue","_side","_factions","_eventFaction","_eventSide","_factionFound",
        "_moduleFactions","_eventPlayerID","_eventRequestID","_eventCancelRequestID"];

        if(_args isEqualType []) then {

            _event = _args;
            _eventData = [_event, "data"] call ALIVE_fnc_hashGet;

            _side = [_logic, "side"] call MAINCLASS;
            _factions = [_logic, "factions"] call MAINCLASS;

            _eventFaction = _eventData select 0;
            _eventSide = _eventData select 1;
            _eventRequestID = _eventData select 2;
            _eventPlayerID = _eventData select 3;
            _eventCancelRequestID = _eventData select 4;

            // check if the faction in the event is handled
            // by this module
            _factionFound = false;

            {
                _moduleFactions = _x select 1;
                if(_eventFaction in _moduleFactions) then {
                    _factionFound = true;
                };
            } forEach _factions;

            // faction not handled by this mil air tasking orders module
            if!(_factionFound) then {

                private ["_sideOPCOMModules","_factionOPCOMModules","_checkModule","_moduleType","_handler","_OPCOMSide","_OPCOMFactions","_OPCOMHasLogistics","_mod"];

                _sideOPCOMModules = [];
                _factionOPCOMModules = [];

                // loop through OPCOM modules with mil air tasking orders synced and find any matching the events side and faction
                {

                    _checkModule = _x;
                    _moduleType = _x getVariable "moduleType";

                    if!(isNil "_moduleType") then {

                        if(_moduleType == "ALIVE_OPCOM") then {

                            _handler = _checkModule getVariable "handler";
                            _OPCOMSide = [_handler,"side"] call ALIVE_fnc_hashGet;
                            _OPCOMFactions = [_handler,"factions"] call ALIVE_fnc_hashGet;
                            _OPCOMHasLogistics = false;

                            for "_i" from 0 to ((count synchronizedObjects _checkModule)-1) do {

                                _mod = (synchronizedObjects _checkModule) select _i;

                                if ((typeof _mod) == "ALiVE_mil_ato") then {
                                    _OPCOMHasLogistics = true;
                                };
                            };

                            if(_OPCOMHasLogistics) then {

                                if(_OPCOMSide == _eventSide) then {
                                    _sideOPCOMModules pushback _checkModule;
                                };

                                {
                                    if(_x == _eventFaction) then {
                                        _factionOPCOMModules pushback _checkModule;
                                    };

                                } forEach _OPCOMFactions;

                            };
                        };
                    };
                } forEach (entities "Module_F");

                // if no mil air tasking orders handles this faction, and there is more than one mil
                // air tasking orders for this side return an error
                if(((count _factionOPCOMModules == 0) && (count _sideOPCOMModules > 1)) || ((count _factionOPCOMModules == 0) && (count _sideOPCOMModules == 0))) then {
                    _factionFound = false;
                };

                // if no mil air tasking orders handles this faction, and there is one mil
                // air tasking orders for this side and this module handles that side
                if((count _factionOPCOMModules == 0) && (count _sideOPCOMModules == 1) && (_side == _eventSide)) then {
                    _factionFound = true;
                };

            };

            if!(_factionFound) exitWith {};

            if(_factionFound) then {

                private ["_eventQueue","_response","_responseItem","_playerRequested","_eventID","_eventData","_logEvent","_playerID",
                "_eventState","_eventType","_eventATO","_responseItem","_eventCargoProfiles","_infantryProfiles","_armourProfiles",
                "_mechanisedProfiles","_motorisedProfiles","_planeProfiles","_heliProfiles","_eventAssets","_allRequestedProfiles","_anyActive",
                "_transportProfiles","_transportVehiclesProfiles","_requestID","_position","_playerRequestProfileID","_profile","_active","_profileType"];

                // get the event data for this player

                _eventQueue = [_logic, "eventQueue"] call MAINCLASS;

                _response = [];

                if((count (_eventQueue select 2)) > 0) then {

                    {
                        _playerRequested = [_x, "playerRequested"] call ALIVE_fnc_hashGet;

                        if(_playerRequested) then {
                            _eventID = [_x, "id"] call ALIVE_fnc_hashGet;
                            _eventData = [_x, "data"] call ALIVE_fnc_hashGet;
                            _playerID = _eventData select 5;
                            _eventType = _eventData select 4;
                            _eventATO = _eventData select 3;

                            if(_eventPlayerID == _playerID) then {

                                _responseItem = [];

                                _requestID = _eventATO select 0;

                                if(_requestID == _eventCancelRequestID) then {

                                    //_x call ALIVE_fnc_inspectHash;

                                    _eventCargoProfiles = [_x, "cargoProfiles"] call ALIVE_fnc_hashGet;

                                    _transportProfiles = [_x, "transportProfiles"] call ALIVE_fnc_hashGet;
                                    _transportVehiclesProfiles = [_x, "transportVehiclesProfiles"] call ALIVE_fnc_hashGet;

                                    _infantryProfiles = [_eventCargoProfiles, 'infantry'] call ALIVE_fnc_hashGet;
                                    _armourProfiles = [_eventCargoProfiles, 'armour'] call ALIVE_fnc_hashGet;
                                    _mechanisedProfiles = [_eventCargoProfiles, 'mechanised'] call ALIVE_fnc_hashGet;
                                    _motorisedProfiles = [_eventCargoProfiles, 'motorised'] call ALIVE_fnc_hashGet;
                                    _planeProfiles = [_eventCargoProfiles, 'plane'] call ALIVE_fnc_hashGet;
                                    _heliProfiles = [_eventCargoProfiles, 'heli'] call ALIVE_fnc_hashGet;

                                    _allRequestedProfiles = [];
                                    _anyActive = false;

                                    {
                                        _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                        if!(isNil "_profile") then {
                                            _active = _profile select 2 select 1;
                                            if(_active) then {
                                                _anyActive = true;
                                            };
                                            _allRequestedProfiles pushBack _profile;
                                        };

                                    } forEach _transportProfiles;

                                    {
                                        _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                        if!(isNil "_profile") then {
                                            _active = _profile select 2 select 1;
                                            if(_active) then {
                                                _anyActive = true;
                                            };
                                            _allRequestedProfiles pushBack _profile;
                                        };

                                    } forEach _transportVehiclesProfiles;

                                    {
                                        _profile = [ALIVE_profileHandler, "getProfile", _x select 0] call ALIVE_fnc_profileHandler;
                                        if!(isNil "_profile") then {
                                            _active = _profile select 2 select 1;
                                            if(_active) then {
                                                _anyActive = true;
                                            };
                                            _allRequestedProfiles pushBack _profile;
                                        };

                                    } forEach _infantryProfiles;

                                    {
                                        {
                                            _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                            if!(isNil "_profile") then {
                                                _active = _profile select 2 select 1;
                                                if(_active) then {
                                                    _anyActive = true;
                                                };
                                                _allRequestedProfiles pushBack _profile;
                                            };
                                        } forEach _x;

                                    } forEach _armourProfiles;

                                    {
                                        {
                                            _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                            if!(isNil "_profile") then {
                                                _active = _profile select 2 select 1;
                                                if(_active) then {
                                                    _anyActive = true;
                                                };
                                                _allRequestedProfiles pushBack _profile;
                                            };
                                        } forEach _x;

                                    } forEach _mechanisedProfiles;

                                    {
                                        {
                                            _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                            if!(isNil "_profile") then {
                                                _active = _profile select 2 select 1;
                                                if(_active) then {
                                                    _anyActive = true;
                                                };
                                                _allRequestedProfiles pushBack _profile;
                                            };
                                        } forEach _x;

                                    } forEach _motorisedProfiles;

                                    {
                                        {
                                            _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                            if!(isNil "_profile") then {
                                                _active = _profile select 2 select 1;
                                                if(_active) then {
                                                    _anyActive = true;
                                                };
                                                _allRequestedProfiles pushBack _profile;
                                            };
                                        } forEach _x;

                                    } forEach _planeProfiles;

                                    {
                                        {
                                            _profile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                                            if!(isNil "_profile") then {
                                                _active = _profile select 2 select 1;
                                                if(_active) then {
                                                    _anyActive = true;
                                                };
                                                _allRequestedProfiles pushBack _profile;
                                            };
                                        } forEach _x;

                                    } forEach _heliProfiles;

                                    if(_anyActive) then {

                                        // respond to player request
                                        _logEvent = ['LOGCOM_RESPONSE', [_eventRequestID,_eventPlayerID,_response],"air tasking orders","CANCEL_FAILED"] call ALIVE_fnc_event;
                                        [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                                    }else{

                                        // delete all profiles

                                        {
                                            _profileType = _x select 2 select 5;
                                            if(_profileType == 'entity') then {
                                                [_x, "destroy"] call ALIVE_fnc_profileEntity;
                                            }else{
                                                [_x, "destroy"] call ALIVE_fnc_profileVehicle;
                                            };

                                        } forEach _allRequestedProfiles;

                                        _eventAssets = [_x, "eventAssets"] call ALIVE_fnc_hashGet;

                                        {
                                            deleteVehicle _x;
                                        } forEach _eventAssets;

                                        // set state to event complete
                                        [_x, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                                        [_eventQueue, _eventID, _x] call ALIVE_fnc_hashSet;

                                        // respond to player request
                                        _logEvent = ['LOGCOM_RESPONSE', [_eventRequestID,_eventPlayerID,_response],"air tasking orders","CANCEL_OK"] call ALIVE_fnc_event;
                                        [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                                    };
                                };
                            };
                        };

                    } forEach (_eventQueue select 2);

                };
            };
        };
    };

    // Handle ATO request
    case "ATO_REQUEST": {

        if(_args isEqualType []) then {

            // EVENT DATA STRUCTURE is hash
            // type : 'ATO_REQUEST'
            // data : [_type,_side,_faction,_airspace,[_ROE,_altitude,_speed,minWeaponState,minFuelState,_range,_duration,_targets],_requestID,_playerID]
            // from: "OPCOM"
            // message : "DENIED"
            // id : 0
            // Requestors can be OPCOM, ATO, PLAYER

            private _debug = [_logic, "debug"] call MAINCLASS;
            private _types = [_logic, "types"] call MAINCLASS;
            private _broadcastOnRadio = [_logic, "broadcastOnRadio"] call MAINCLASS;

            private _event = _args;
            private _eventData = [_event, "data"] call ALIVE_fnc_hashGet;
            private _eventType = _eventData select 0;

            private _initComplete = true;

            if !(_initComplete) exitWith {};

            private _side = [_logic, "side"] call MAINCLASS;
            private _factions = [_logic, "factions"] call MAINCLASS;
            private _eventSide = _eventData select 1;
            private _eventFaction = _eventData select 2;
            private _airspace = _eventData select 3;

            // check if the faction in the event is handled
            // by this module
            private _factionFound = false;
            if(_eventFaction in _factions) then {
                _factionFound = true;
            };

            if!(_factionFound) exitWith {};

            if(_factionFound) then {

                // For radio broadcasts
                private _sideObject = [_side] call ALIVE_fnc_sideTextToObject;
                private _factionName = getText((_eventFaction call ALiVE_fnc_configGetFactionClass) >> "displayName");
                private _hqClass = switch (_sideObject) do {
                    case WEST: {
                        "BLU"
                    };
                    case EAST: {
                        "OPF"
                    };
                    case RESISTANCE: {
                        "IND"
                    };
                    default {
                        "HQ"
                    };
                };
                private _HQID = getText(configFile >> "CfgHQIdentities" >> _hqClass >> "name");

                // Validate airspace
                if (_airspace isEqualType "" && {_airspace == ""}) then {
                    _airspace = ([_logic, "airspace"] call MAINCLASS) select 0;
                };

                // Check to see if airspace position has been provided, if so set airspace
                if (_airspace isEqualType []) then {
                    private _tmpAirspace = "";
                    {
                        if (_airspace inArea _x) exitWith {
                            _tmpAirspace = _x;
                        };
                    } forEach (([_logic, "airspaceAssets"] call MAINCLASS) select 1);
                    _airspace = _tmpAirspace;
                    _eventData set [3,_airspace];
                    [_event,"data",_eventData] call ALiVE_fnc_hashSet;
                };

                // Check if this module is operating and has assets

                // Check HQ is alive or baseCluster is not captured
                private _baseCluster = [_logic, "currentBase"] call MAINCLASS;
                private _baseCaptured = false;
                private _HQIsALive = true;

                // #897 - the HQ property defaults to objNull, so a never-assigned HQ
                // (faction without HQ compositions, or no clear spot to place one)
                // read as a dead building and latched the compromised broadcast
                // forever. Only a building that existed and died counts as HQ down.
                private _HQ = [_logic,"HQBuilding",nil] call MAINCLASS;
                if (!isNil "_HQ" && {!isNull _HQ}) then {
                    _HQIsALive = alive _HQ;
                };

                // #897 - probe where the base actually lives (the HQ) rather than the
                // baked cluster centre, which sits mid-runway on large airfields and
                // reaches ~500m past the field edge. Civilians no longer count and
                // votes are weighted by unit count, so a couple of passing enemy
                // scout profiles can't outvote the garrison.
                private _probePos = [_baseCluster,"center"] call ALiVE_fnc_hashGet;
                if (!isNil "_HQ" && {!isNull _HQ}) then { _probePos = getPosATL _HQ; };

                private _dominantFaction = [_probePos, 500, true, true] call ALiVE_fnc_getDominantFaction;

                if (isNil "_dominantFaction") then {_dominantFaction = _eventFaction;};

                // #897 - a faction with no resolvable CfgFactionClasses side maps to
                // EAST by default, which read friendly custom/ORBAT factions (possibly
                // this module's own) as an enemy takeover. Unresolvable factions never
                // flip the base.
                private _dominantSideKnown = isNumber ((_dominantFaction call ALiVE_fnc_configGetFactionClass) >> "side");

                if (_dominantSideKnown && {!([(_dominantFaction call ALiVE_fnc_factionSide), [_eventSide] call ALIVE_fnc_sideTextToObject] call BIS_fnc_sideIsFriendly)}) then {
                    _baseCaptured = true;
                };

                if (_debug || !(_HQIsAlive) || _baseCaptured ) then {
                     ["ATO %4 - MACC HQ online: %1 Base Captured: %2 Dominant Faction: %3", _HQIsAlive,_baseCaptured,_dominantFaction, _logic] call ALiVE_fnc_dump;
                };

                if (_HQIsAlive && !_baseCaptured) then {

                    // Check all available assets
                    private _assets = [ALIVE_globalATO, _eventFaction] call ALIVE_fnc_hashGet;

                    private _loaded = false;
                    // Handle addition 2 records (id,rev) when saved to ClownDB
                    if (count (_assets  select 1) > 0 && {_assets select 1 select 0 == "_id" }) then {
                        _loaded = true;
                    };

                    // DEBUG -------------------------------------------------------------------------------------
                    if(_debug) then {
                        ["ATO - Global ATO:"] call ALiVE_fnc_dump;
                        ALIVE_globalATO call ALIVE_fnc_inspectHash;
                    };
                    // DEBUG -------------------------------------------------------------------------------------

                    // if there are still assets available
                    if ( count (_assets select 1) > 0 || (_loaded && count (_assets select 1) > 2) ) then {

                        private _available = false;

                        if(_eventType in _types) then {

                            _available = true;

                            // Apply this module's sortie duration override, if it has one.
                            // The requesting commander proposes a duration (index 6 of the
                            // ATO argument array) and every sortie timer is derived from it,
                            // so overriding here sets the tempo for the whole module in one
                            // place. Blank or zero leaves the requester's value untouched.
                            private _sortieDuration = parseNumber ([_logic,"sortieDuration"] call MAINCLASS);
                            if (_sortieDuration > 0) then {
                                private _atoArgs = _eventData select 4;
                                if (!isNil "_atoArgs" && {_atoArgs isEqualType []} && {count _atoArgs > 6}) then {
                                    _atoArgs set [6, _sortieDuration];
                                    _eventData set [4, _atoArgs];
                                    [_event, "data", _eventData] call ALIVE_fnc_hashSet;
                                };
                            };

                            // set the state of the event
                            [_event, "state", "requested"] call ALIVE_fnc_hashSet;

                            // set the player requested flag on the event
                            [_event, "playerRequested", false] call ALIVE_fnc_hashSet;

                        };

                        if (_debug) then {
                            _event call ALIVE_fnc_inspectHash;
                        };

                        if(_available) then {

                            // Set event ID
                            private _eventID = [_event, "id"] call ALIVE_fnc_hashGet;

                            // set the time the event was received
                            [_event, "time", time] call ALIVE_fnc_hashSet;

                            // set the state data array of the event
                            [_event, "stateData", []] call ALIVE_fnc_hashSet;

                            // set the profiles array of the event
                            [_event, "friendlyProfiles", []] call ALIVE_fnc_hashSet;
                            [_event, "enemyProfiles", []] call ALIVE_fnc_hashSet;
                            [_event, "playerRequestProfiles", []] call ALIVE_fnc_hashSet;

                            // store the event on the event queue
                            private _eventQueue = [_logic, "eventQueue"] call MAINCLASS;
                            [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                            // DEBUG -------------------------------------------------------------------------------------
                            if(_debug) then {
                                ["ATO %1 - ATO request event received", _logic] call ALiVE_fnc_dump;
                                private _assetCount = if (_loaded) then {count (_assets select 1) - 2} else {count (_assets select 1)};
                                ["ATO - %2 available assets for %1", _side, _assetCount] call ALiVE_fnc_dump;
                                _event call ALIVE_fnc_inspectHash;
                            };
                            // DEBUG -------------------------------------------------------------------------------------

                            private _airspacePos = [];
                            if (_airspace isEqualType "") then {
                                _airspacePos = getMarkerPos _airspace;
                            } else {
                                if (_airspace isEqualType []) then { _airspacePos = +_airspace };
                            };

                            // The broadcast quotes a grid, so it has to be a grid somebody could
                            // act on. Two things went wrong before this guard. A blank or missing
                            // marker name makes getMarkerPos hand back the map origin, which
                            // reads out as grid 000000, and even when the airspace does resolve
                            // it is the patrol boundary rather than the place support was asked
                            // for, which on a whole-map airspace is meaningless.
                            //
                            // So prefer where the trouble actually is. Targets come through as
                            // objects or as profile ids depending on who raised the request, and
                            // both have to be resolved.
                            private _fnc_degenerate = {
                                params ["_p"];
                                (count _p < 2) || {((abs (_p select 0)) < 1) && {(abs (_p select 1)) < 1}}
                            };

                            if ([_airspacePos] call _fnc_degenerate) then {
                                private _atoArgs = _eventData param [4, []];
                                private _targets = if (_atoArgs isEqualType [] && {count _atoArgs > 7}) then { _atoArgs select 7 } else { [] };
                                if (_targets isEqualType []) then {
                                    {
                                        private _tp = [];
                                        if (_x isEqualType objNull) then {
                                            if !(isNull _x) then { _tp = getPosATL _x };
                                        } else {
                                            if (_x isEqualType "") then {
                                                private _tprofile = [ALiVE_profileHandler, "getProfile", _x] call ALiVE_fnc_ProfileHandler;
                                                if !(isNil "_tprofile") then { _tp = [_tprofile,"position",[]] call ALiVE_fnc_hashGet };
                                            };
                                        };
                                        if !([_tp] call _fnc_degenerate) exitWith { _airspacePos = _tp };
                                    } forEach _targets;
                                };
                            };

                            // Last resort, the commander's own position. Still not where the
                            // support is wanted, but it is a real place on the map and it tells
                            // listeners which commander is speaking, which grid 000000 does not.
                            if ([_airspacePos] call _fnc_degenerate) then {
                                private _hqb = [_logic, "HQBuilding"] call MAINCLASS;
                                if (!isNil "_hqb" && {!isNull _hqb}) then { _airspacePos = position _hqb };
                            };

                            // Reaching here means the airspace, every target and the commander's
                            // own building all failed to give a real position, which should not
                            // happen. Log what the request carried so a stray grid 000000 can be
                            // traced to its requester rather than guessed at.
                            if ([_airspacePos] call _fnc_degenerate) then {
                                diag_log format ["ATO grid unresolved: from=%1 type=%2 airspace=%3 eventType=%4",
                                    [_event,"from",""] call ALiVE_fnc_hashGet, typeName _airspace, _airspace, _eventType];
                            };

                            //Radio Broadcast
                            if (_broadcastOnRadio) then {
                                private _message = format[localize "STR_ALIVE_ATO_REQUEST_ACKNOWLEDGED", _HQID, _factionName, _eventType, mapGridPosition _airspacePos];
                                // send a message to all side players from HQ
                                private _radioBroadcast = [objNull,_message,"side",_sideObject,false,false,false,true,_hqClass];
                                [_side,_radioBroadcast] call ALIVE_fnc_radioBroadcastToSide;
                            };

                            // trigger analysis
                            [_logic,"onDemandAnalysis"] call MAINCLASS;


                        }else{

                            // nothing left after non allowed types ruled out
                            // DEBUG -------------------------------------------------------------------------------------
                            if(_debug) then {
                                ["ATO %2 - ATO type %1 is not in list of ATOs supported %3", _eventType, _logic, _types] call ALiVE_fnc_dump;
                            };
                            // DEBUG -------------------------------------------------------------------------------------
                        };
                    }else{

                        // DEBUG -------------------------------------------------------------------------------------
                        if(_debug) then {
                            ["ATO %2 - Air Tasking request denied, Military Air Component Commander for %1 has no available air assets", _eventFaction, _logic] call ALiVE_fnc_dump;
                        };
                        // DEBUG -------------------------------------------------------------------------------------

                        if(_eventType == "PR_STRIKE" || _eventType == "PR_RECCE" || _eventType == "PR_CAS") then {

                            private _requestID = _eventData select 5;
                            private _playerID = _eventData select 6;

                            //Radio Broadcast
                            if (_broadcastOnRadio) then {
                                private _message = format[localize "STR_ALIVE_ATO_UNAVAILABLE", _HQID];
                                // send a message to all side players from HQ
                                private _radioBroadcast = [objNull,_message,"side",_sideObject,false,false,false,true,_hqClass];
                                [_side,_radioBroadcast] call ALIVE_fnc_radioBroadcastToSide;
                            };

                            // respond to player request
                            private _logEvent = ['ATO_RESPONSE', [_requestID,_playerID],"Military Air Component Commander","DENIED_ATO_UNAVAILABLE"] call ALIVE_fnc_event;
                            [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                        };
                    };
                } else {
                    // DEBUG -------------------------------------------------------------------------------------
                    if(_debug) then {
                        ["ATO %2 - Air Tasking request denied, Military Air Component Commander for %1 is not available", _eventFaction, _logic] call ALiVE_fnc_dump;
                    };
                    // DEBUG -------------------------------------------------------------------------------------

                    //Radio Broadcast
                    // #897 - every ATO request replayed this broadcast (OPCOM raises
                    // one on each enemy contact anywhere on the map), spamming players
                    // with "compromised" radio that tracked unrelated fighting. One
                    // message per 10 minutes carries the same information.
                    if (_broadcastOnRadio && {time - (_logic getVariable ["ATO_lastOverrunBroadcast", -3600]) > 600}) then {
                        _logic setVariable ["ATO_lastOverrunBroadcast", time];
                        private _message = format[localize "STR_ALIVE_ATO_OVERRUN", _HQID, _factionName, mapGridPosition _HQ];
                        // send a message to all side players from HQ
                        private _radioBroadcast = [objNull,_message,"side",_sideObject,false,false,false,true,_hqClass];
                        [_side,_radioBroadcast] call ALIVE_fnc_radioBroadcastToSide;
                    };
                };
            };

        };
    };

    // ATO prioritisation
    case "onDemandAnalysis": { // TODO

        if (isServer) then {

            // Check to see the current state of air assets

            private _debug = [_logic, "debug"] call MAINCLASS;
            private _analysisInProgress = _logic getVariable ["analysisInProgress", false];

            // if analysis not already underway
            if!(_analysisInProgress) then {

                _logic setVariable ["analysisInProgress", true];

                // Check base is available
                private _baseCluster = [_logic, "currentBase"] call MAINCLASS;
                private _baseCaptured = false;
                private _HQIsALive = true;
                private _side = [_logic, "side"] call MAINCLASS;
                private _faction = [_logic, "faction"] call MAINCLASS;

                // #897 - same hardening as the request handler: a never-assigned HQ is
                // not a dead HQ, probe at the HQ rather than the runway midpoint,
                // ignore civilians, weight votes by unit count, and never let an
                // unresolvable faction read as an enemy takeover.
                private _HQ = [_logic,"HQBuilding",nil] call MAINCLASS;
                if (!isNil "_HQ" && {!isNull _HQ}) then {
                    _HQIsALive = alive _HQ;
                };

                private _probePos = [_baseCluster,"center"] call ALiVE_fnc_hashGet;
                if (!isNil "_HQ" && {!isNull _HQ}) then { _probePos = getPosATL _HQ; };

                private _dominantFaction = [_probePos, 500, true, true] call ALiVE_fnc_getDominantFaction;

                if (isNil "_dominantFaction") then {_dominantFaction = _faction;};

                private _dominantSideKnown = isNumber ((_dominantFaction call ALiVE_fnc_configGetFactionClass) >> "side");

                if (_dominantSideKnown && {!([(_dominantFaction call ALiVE_fnc_factionSide), [_side] call ALIVE_fnc_sideTextToObject] call BIS_fnc_sideIsFriendly)}) then {
                    _baseCaptured = true;
                };

                if (!_baseCaptured && _HQIsALive) then {
                    private _available = true;
                    private _loaded = false;
                    private _registryID = [_logic, "registryID"] call MAINCLASS;
                    private _airspaceAssets = [_logic, "airspaceAssets"] call MAINCLASS;
                    private _assets = [ALIVE_globalATO,_faction] call ALIVE_fnc_hashGet;

                    if(_assets isEqualType "") then {
                        _assets = call compile _assets;
                    };

                    // Cleanup killed assets
                    private _allAssetIds = +(_assets select 1);
                    private _currentAssetIds = [_logic, "removeUnregisteredProfiles", _allAssetIds] call MAINCLASS;

                    // Handle additional 2 records (id,rev) when saved to ClownDB
                    if (count (_assets  select 1) > 0 && {_assets select 1 select 0 == "_id" }) then {
                        _loaded = true;
                    };

                    // DEBUG -------------------------------------------------------------------------------------
                    if(_debug) then {
                        ["ATO %1 - Air component analysis started", _logic] call ALiVE_fnc_dump;
                    };
                    // DEBUG -------------------------------------------------------------------------------------

                    // Check to see if all existing assets are still available
                    if ( count (_assets select 1) == 0 || (_loaded && count (_assets select 1) == 2) ) then {
                        _available = false;
                    };

                    // Airframe count at or below which offensive tasking is suspended in
                    // favour of defensive patrols. Blank keeps the original behaviour -
                    // 4 when the roster came back from persistence, 2 otherwise - so an
                    // untouched mission behaves exactly as before.
                    private _minAssets = parseNumber ([_logic,"minAssetsForOffensive"] call MAINCLASS);
                    if (_minAssets <= 0) then {
                        _minAssets = if (_loaded) then {4} else {2};
                    };
                    private _assetsRemaining = count (_assets select 1);

                    // Check to see the current state of air assets, if scarce restrict ATOs
                    if (_assetsRemaining <= _minAssets) then {
                        private _types = [_logic, "types"] call MAINCLASS;

                        // Remember the unrestricted list the first time we restrict so it can
                        // be put back later. A dedicated flag is needed because the origTypes
                        // accessor falls back to the full default type list when unset, so
                        // "count _orig == 0" could never answer "have we saved yet" and the
                        // original list was never actually stored.
                        if !(_logic getVariable ["origTypesSaved", false]) then {
                            [_logic,"origTypes",+_types] call MAINCLASS;
                            _logic setVariable ["origTypesSaved", true];
                        };

                        // Defensive tasking only while airframes are scarce. Note "CAP" and not
                        // ["CAP"] - the list holds strings, so the array form never matched and
                        // this emptied the type list instead of narrowing it, silently stopping
                        // ALL air tasking. The restore branch below could not undo it either, so
                        // one dip in aircraft numbers grounded the MACC for the rest of the mission.
                        private _tmpTypes = [];
                        if ("CAP" in _types) then {
                            _tmpTypes pushback "CAP";
                        };
                        if ("DCA" in _types) then {
                            _tmpTypes pushback "DCA";
                        };

                        // Only narrow if something survives - a mission running neither CAP nor
                        // DCA should keep flying what it has rather than go silent.
                        if (count _tmpTypes > 0) then {
                            [_logic,"types",_tmpTypes] call MAINCLASS;
                        };

                    };

                    if (_assetsRemaining > _minAssets) then {

                        // Only restore if we actually saved something. Passing [] to the accessor
                        // here used to SET origTypes to an empty list and then reseed it from the
                        // already-narrowed types, destroying the original list both ways round.
                        if (_logic getVariable ["origTypesSaved", false]) then {
                            private _types = [_logic, "types"] call MAINCLASS;
                            private _orig = [_logic, "origTypes"] call MAINCLASS;

                            // Reset ATOs
                            if (count _types < count _orig) then {
                                [_logic,"types",+_orig] call MAINCLASS;
                            };

                            _logic setVariable ["origTypesSaved", false];
                        };
                    };

                    // if not order new assets from LOGCOM
                    // #460 Phase B - sweep in-flight LOGCOM replacement requests. Runs before
                    // the gate below so anything it re-queues is picked up on this same pass.
                    if ([_logic,"resupply"] call MAINCLASS) then {
                        private _pendingSweep = [_logic,"resupplyPending"] call MAINCLASS;
                        // Copy the keys: the loop mutates the hash as it goes.
                        private _pendingKeys = +(_pendingSweep select 1);
                        {
                            private _pkey   = _x;
                            private _pentry = [_pendingSweep, _pkey, []] call ALiVE_fnc_hashGet;

                            if (_pentry isEqualType [] && {count _pentry >= 3}) then {
                                private _pAsset     = _pentry select 0;
                                private _pTime      = _pentry select 1;
                                private _pRetries   = _pentry select 2;
                                private _pAbandoned = if (count _pentry > 3) then {_pentry select 3} else {false};
                                private _age        = time - _pTime;

                                if (_pAbandoned) then {

                                    // Already given up on. Keep the entry a while longer so a late
                                    // delivery can still be reconciled (released rather than left
                                    // holding busy forever), then purge it.
                                    if (_age > (ATO_RESUPPLY_TIMEOUT * 2)) then {
                                        [_pendingSweep, _pkey] call ALiVE_fnc_hashRem;
                                    };

                                } else {

                                    if (_age > ATO_RESUPPLY_TIMEOUT) then {

                                        // Flag rather than delete, so a late arrival is still recognised.
                                        [_pendingSweep, _pkey, [_pAsset, _pTime, _pRetries + 1, true]] call ALiVE_fnc_hashSet;

                                        if (_pRetries < 1) then {
                                            // One more attempt through LOGCOM - a transient blockage
                                            // (pool briefly empty, no route) usually clears.
                                            [_logic,"resupplyList",_pAsset] call MAINCLASS;
                                            ["ATO - LOGCOM replacement for %1 timed out (event %2); retrying once.",
                                                [_pAsset,"vehicleClass"] call ALiVE_fnc_hashGet, _pkey] call ALiVE_fnc_dumpR;
                                        } else {
                                            // Second failure: fall back to the proven self-create path
                                            // so the air campaign never silently grinds down.
                                            [_pAsset,"forceSelfCreate",true] call ALiVE_fnc_hashSet;
                                            [_logic,"resupplyList",_pAsset] call MAINCLASS;
                                            ["ATO - LOGCOM replacement for %1 timed out twice (event %2); self-creating instead.",
                                                [_pAsset,"vehicleClass"] call ALiVE_fnc_hashGet, _pkey] call ALiVE_fnc_dumpR;
                                        };
                                    };
                                };
                            };
                        } forEach _pendingKeys;
                    };

                    if ([_logic,"resupply"] call MAINCLASS && {count ([_logic,"resupplyList"] call MAINCLASS) > 0}) then {

                        // Order 1 asset each go around, first in first out!
                        private _resupplyList = [_logic,"resupplyList"] call MAINCLASS;
                        private _asset = _resupplyList deleteAt 0;

                        private _side = [_logic,"side"] call MAINCLASS;
                        private _debug = [_logic,"debug"] call MAINCLASS;

                        // #460 Phase B - route replacement airframes through LOGCOM when a
                        // mil_logistics module is present (and the asset isn't carrier-based,
                        // which LOGCOM's ground/air delivery can't service). Otherwise fall
                        // through to the proven self-create path in the else below.
                        private _useLogcom = (["ALiVE_MIL_LOGISTICS"] call ALiVE_fnc_isModuleAvailable)
                            && {!([_asset,"isOnCarrier",false] call ALiVE_fnc_hashGet)}
                            // Set by the sweep after LOGCOM failed us twice - take the proven path.
                            && {!([_asset,"forceSelfCreate",false] call ALiVE_fnc_hashGet)};

                        if (_useLogcom) then {

                            private _base = [_logic,"HQBuilding",nil] call MAINCLASS;

                            if (isNil "_base") exitWith {
                                if (_debug) then {["ATO - LOGCOM resupply for side %1 held: no secured HQ position yet.",_side] call ALiVE_fnc_dumpR};
                                // Re-queue the asset so the replacement isn't lost while the HQ is unsecured.
                                [_logic,"resupplyList",_asset] call MAINCLASS;
                            };

                            private _vehicleClass = [_asset,"vehicleClass"] call ALiVE_fnc_hashGet;
                            private _position = position _base;

                            // Request from the ATO's own faction - a third-party config faction
                            // (e.g. BLU_F on an RHS OPCOM) would be dropped by LOGCOM's routing.
                            private _factions = [_logic,"factions"] call MAINCLASS;
                            private _faction = getText(configFile >> "CfgVehicles" >> _vehicleClass >> "faction");
                            if (count _factions > 0) then {
                                private _f0 = _factions select 0;
                                _faction = if (_f0 isEqualType "") then {_f0} else {(_f0 select 1) select 0};
                            };

                            private _plane = if (_vehicleClass isKindOf "Plane") then {1} else {0};
                            private _heli  = if (_vehicleClass isKindOf "Helicopter") then {1} else {0};
                            private _forceMakeup = [0,0,0,0,_plane,_heli];

                            private _event = ['LOGCOM_REQUEST', [_position,_faction,_side,_forceMakeup,"STANDARD"], "ATO"] call ALIVE_fnc_event;
                            // Carry the exact lost class so LOGCOM builds that airframe, not a random one.
                            [_event, "requestVehicleClass", _vehicleClass] call ALiVE_fnc_hashSet;
                            private _eventID = [ALIVE_eventLog, "addEvent", _event] call ALIVE_fnc_eventLog;

                            // Track the pending request; the completion handler + timeout sweep
                            // (later increments) correlate the delivery back to this asset by eventID.
                            private _pending = [_logic,"resupplyPending"] call MAINCLASS;
                            [_pending, str _eventID, [_asset, time, 0, false]] call ALiVE_fnc_hashSet;

                            if (_debug) then {
                                ["ATO - LOGCOM resupply requested: class %1, faction %2, eventID %3", _vehicleClass, _faction, _eventID] call ALiVE_fnc_dumpR;
                            };

                        } else {

                            // If not LOGCOM, create asset and add a maintenance time

                            private _debug = [_logic,"debug"] call MAINCLASS;

                            private _vehicleClass = [_asset,"vehicleClass"] call ALiVE_fnc_hashGet;
                            private _faction = getText(configFile >> "CfgVehicles" >> _vehicleClass >> "faction");
                            private _position = [_asset,"startPos"] call ALiVE_fnc_hashGet;
                            private _dir = [_asset,"startDir"] call ALiVE_fnc_hashGet;
                            private _baseAirspace = [_asset,"airspace"] call ALiVE_fnc_hashGet;

                            private _plane = if (_vehicleClass isKindOf "Plane") then {1} else {0};
                            private _heli = if (_vehicleClass isKindOf "Helicopter") then {1} else {0};

                            private _tmp = [];

                            if (_debug) then {
                                //["ATO - Replenishing %1 for side %2!",_vehicleClass, _side] call ALiVE_fnc_dumpR;
                            };

                            if (_heli == 1) then {

                                // Check to see if there is a wreck around, causing explosions
                                private _nearbyObj = nearestObjects [_position, ["Helicopter"], 5];
                                {if (!alive _x) then {deleteVehicle _x}} forEach _nearbyObj;

                                private _createdProfiles = [_vehicleClass,_side,_faction,"CAPTAIN",_position,_dir,false,_faction,false] call ALIVE_fnc_createProfilesCrewedVehicle;
                                _tmp = _createdProfiles select (_createdProfiles findIf { ([_x,"type"] call ALiVE_fnc_hashGet) == "vehicle" });
                            };

                            if (_plane == 1) then {
                                // Check to see if there is a wreck around, causing explosions
                                private _nearbyObj = nearestObjects [_position, ["Plane"], 5];
                                {if (!alive _x) then {deleteVehicle _x}} forEach _nearbyObj;

                                _tmp = [_vehicleClass,_side,_faction,_position,_dir,false,_faction] call ALIVE_fnc_createProfileVehicle;
                            };

                            private _profileID = [_tmp, "profileID"] call ALIVE_fnc_hashGet;

                            private _profile = [ALIVE_profileHandler, "getProfile", _profileID] call ALIVE_fnc_profileHandler;

                            if !(isnil "_profile") then {
                                [_logic,"registerProfile",[_profileID,_baseAirspace]] call MAINCLASS;
                            };

                            // Get asset by profile
                            private _assets = [_logic,"assets"] call MAINCLASS;
                            private _aircraft = [_assets, _profileID, ""] call ALiVE_fnc_hashGet;

                            // Add aircraft to maintenance
                            if !(_aircraft isEqualType "") then {
                                [_aircraft,"maintenance",time] call ALiVE_fnc_hashSet;
                            };

                            if (_debug) then {
                                _tmp call ALIVE_fnc_inspectHash;
                                _aircraft call ALIVE_fnc_inspectHash;
                            };
                        };

                    };

                    // Check to see if there are new assets?

                    // Update assets and airspaceAssets

                    //[ALIVE_ATOGlobalRegistry,"updateGlobalATO",[_registryID,_assets]] call ALIVE_fnc_ATOGlobalRegistry;

                    // store the analysis results
                    _requestAnalysis = [] call ALIVE_fnc_hashCreate;
                    [_requestAnalysis, "available", _available] call ALIVE_fnc_hashSet;

                    [_logic, "requestAnalysis", _requestAnalysis] call MAINCLASS;

                    // DEBUG -------------------------------------------------------------------------------------
                    if(_debug) then {
                        ["ATO %1 - On demand analysis complete", _logic] call ALiVE_fnc_dump;
                        ["ATO %2 - Air assets still available: %1",_available, _logic] call ALiVE_fnc_dump;
                    };
                    // DEBUG -------------------------------------------------------------------------------------
                // #897 - was "} then {": a second then after the if-block is a runtime
                // type error, logged on every on-demand analysis pass, and made this
                // branch unreachable
                } else {

                    // Need to relocate base

                        /// TODO

                    // DEBUG -------------------------------------------------------------------------------------
                    if(_debug) then {
                        ["ATO %1 - On demand analysis complete", _logic] call ALiVE_fnc_dump;
                        ["ATO %2 - Airbase is unavailable: %1", _logic] call ALiVE_fnc_dump;
                    };
                    // DEBUG -------------------------------------------------------------------------------------
                };

                _logic setVariable ["analysisInProgress", false];
            };
        };
    };

    // Airspace Management
    case "monitor": {
        if (isServer) then {

            // spawn monitoring loop - 1. Monitor events and 2. to scan airspace/air defense etc

            [_logic] spawn {

                private _logic = _this select 0;
                private _debug = [_logic, "debug"] call MAINCLASS;

                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["ATO %1 - Request loop started", _logic] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------

                waituntil {

                    sleep (10);

                    if!([_logic, "pause"] call MAINCLASS) then {

                        private ["_requestAnalysis","_analysisInProgress","_eventQueue"];

                        _requestAnalysis = [_logic, "requestAnalysis"] call MAINCLASS;

                        // analysis has run
                        if(count _requestAnalysis > 0) then {

                            _analysisInProgress = _logic getVariable ["analysisInProgress", false];

                            // if analysis not processing
                            if!(_analysisInProgress) then {

                                // loop the event queue
                                // and manage each event
                                _eventQueue = [_logic, "eventQueue"] call MAINCLASS;

                                if((count (_eventQueue select 2)) > 0) then {

                                    {
                                        [_logic,"monitorEvent",[_x, _requestAnalysis]] call MAINCLASS;
                                    } forEach (_eventQueue select 2);

                                };

                            };

                        };

                    };

                    false
                };
            };

            [_logic] spawn {

                private _logic = _this select 0;
                private _debug = [_logic, "debug"] call MAINCLASS;
                private _side = [_logic,"side"] call MAINCLASS;
                private _faction = [_logic,"faction"] call MAINCLASS;
                // Check to see if generateTasks
                private _generateTasks = [_logic,"generateTasks"] call MAINCLASS;
                private _generateSEADTasks = [_logic,"generateSEADTasks"] call MAINCLASS;
                // Check to see if C2ISTAR is available
                private _C2ISTARisAvailable = ["ALiVE_mil_c2istar"] call ALiVE_fnc_isModuleAvailable;

                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["ATO %1 - Airspace Management loop started", _logic] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------

                waituntil {

                    sleep (60 + (random 90));

                    if!([_logic, "pause"] call MAINCLASS) then {

                        // Check to see if there is an intruder in any airspace
                        if ("DCA" in ([_logic,"types"] call MAINCLASS)) then {

                            // Check for intruders in each managed airspace
                            private _intruders = [_logic, "scanAirspace"] call MAINCLASS;

                            // Grab the airspaces with intruders
                            private _airspaceIntruders = _intruders select 1;

                            {
                                sleep (random 5);
                                // If intruder, check to see if there is an active DCA against it, if not scramble
                                private _bogeys = [_intruders, _x] call ALiVE_fnc_hashGet;
                                if (count _bogeys > 0) then {
                                    private _currentOps = [_logic, "airspaceOps", _x] call MAINCLASS;
                                    private _DCA = false;

                                    {
                                        if ((_x select 0) == "DCA") exitWith {
                                            // check all intruders are being intercepted?
                                            _DCA = true;
                                        };
                                    } forEach _currentOps;

                                    if !(_DCA) then {
                                        private _type = "DCA";
                                        private _range = if ((getMarkerSize _x) select 0 > (getMarkerSize _x) select 1) then {(getMarkerSize _x) select 0} else {(getMarkerSize _x) select 1};
                                        private _args = [
                                            "RED",                // ROE
                                            DEFAULT_OP_HEIGHT,
                                            "FULL",                 // SPEED MODE
                                            DEFAULT_MIN_WEAP_STATE,
                                            DEFAULT_MIN_FUEL_STATE,
                                            _range * 0.9,       // RADIUS / RANGE
                                            10,
                                            _bogeys                 // TARGETS
                                        ];
                                        private _event = ['ATO_REQUEST', [_type, _side, _faction, _x, _args],"ATO"] call ALIVE_fnc_event;
                                        private _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

                                        if (count _bogeys > 1) then {
                                            // DEBUG -------------------------------------------------------------------------------------
                                            if(_debug) then {
                                                ["ATO %1 - Request Player help %2 %3", _logic, _generateTasks, _C2ISTARisAvailable] call ALiVE_fnc_dump;
                                            };
                                            // DEBUG -------------------------------------------------------------------------------------
                                            if (count _bogeys > 1 && _generateTasks && _C2ISTARisAvailable) then {
                                                [_logic, "requestPlayerTask", ["DCA",_bogeys]] call MAINCLASS;
                                            };
                                        };
                                    };

                                };
                            } forEach _airspaceIntruders
                        };

                        // Check to see if there is a CAP
                        private _airspace = [_logic,"airspace"] call MAINCLASS;
                        {

                            sleep (random 5);
                            if ("CAP" in ([_logic,"types"] call MAINCLASS)) then {
                                private _currentOps = [_logic, "airspaceOps", _x] call MAINCLASS;
                                private _CAP = false;
                                {
                                    if ((_x select 0) == "CAP") exitWith {
                                        _CAP = true;
                                    };
                                } forEach _currentOps;

                                private _lastCAPTime = [_logic, "airspaceLastCAP", _x] call MAINCLASS;
                                private _CAPTime = time > _lastCAPTime + (300 + random 600);

                                // If no cap then request one
                                if (!_CAP && (_CAPTime || time < 600) ) then {
                                    private _type = "CAP";
                                    private _range = if ((getMarkerSize _x) select 0 < (getMarkerSize _x) select 1) then {(getMarkerSize _x) select 0} else {(getMarkerSize _x) select 1};
                                    private _args = [
                                        // Fire at will. Combat air patrol exists to engage what
                                        // it finds, and WHITE is hold fire, so the aircraft
                                        // orbited over contacts without ever shooting. Not RED:
                                        // that also grants engage at will, which lets a fighter
                                        // abandon its patrol to chase something across the map.
                                        "YELLOW",               // ROE
                                        DEFAULT_OP_HEIGHT,
                                        DEFAULT_SPEED,
                                        DEFAULT_MIN_WEAP_STATE,
                                        DEFAULT_MIN_FUEL_STATE,
                                        _range * 0.9,       // RADIUS
                                        45,
                                        []                      // TARGETS
                                    ];
                                    private _event = ['ATO_REQUEST', [_type, _side, _faction, _x, _args],"ATO"] call ALIVE_fnc_event;
                                    private _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
                                };
                            };

                        } forEach _airspace;

                        // Check to see if there are any air defences
                        if ("SEAD" in ([_logic,"types"] call MAINCLASS)) then {

                            // Check for static air defenses near ATO
                            private _airDefenses = [_logic, "scanAirDefenses"] call MAINCLASS;

                            // Grab air defense targets
                            private _airDefenseTargets = _airDefenses select 1;

                            {
                                sleep (random 5);
                                // If there's no SEAD mission already, then launch one against the target
                                private _targets = [_airDefenses, _x] call ALiVE_fnc_hashGet;
                                if (count _targets > 0) then {
                                    private _currentOps = [_logic, "airspaceOps", _x] call MAINCLASS;
                                    private _SEAD = false;

                                    {
                                        if ((_x select 0) == "SEAD") exitWith {
                                            // check all intruders are being intercepted?
                                            _SEAD = true;
                                        };
                                    } forEach _currentOps;

                                    if !(_SEAD) then {
                                        private _type = "SEAD";
                                        private _range = 4000;
                                        private _args = [
                                            "RED",                // ROE
                                            100,
                                            "FULL",                 // SPEED MODE
                                            DEFAULT_MIN_WEAP_STATE,
                                            DEFAULT_MIN_FUEL_STATE,
                                            _range * 0.9,       // RADIUS / RANGE
                                            10,
                                            _targets                 // TARGETS
                                        ];

                                        // Disabled as aircraft get owned by AA
                                        //private _event = ['ATO_REQUEST', [_type, _side, _faction, _x, _args],"ATO"] call ALIVE_fnc_event;
                                        //private _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;


                                        if (count _targets > 0) then {

                                            // Request that players handle SEAD
                                            // DEBUG -------------------------------------------------------------------------------------
                                            if(_debug) then {
                                                ["ATO %1 - Request Player help %2 %3", _logic, _generateSEADTasks, _C2ISTARisAvailable] call ALiVE_fnc_dump;
                                            };
                                            // DEBUG -------------------------------------------------------------------------------------

                                            // Send this task if SEAD taskings are on, if taskings are on for C2ISTAR it will process the request.
                                            if (_C2ISTARisAvailable && _generateSEADTasks) then {

                                                [_logic, "requestPlayerTask", ["SEAD",_targets]] call MAINCLASS;

                                            };
                                        };

                                    };
                                };
                            } forEach _airDefenseTargets;
                        };
                    };

                    false
                };
            };
        };
    };

    // Air Tasking Order Mission Framework
    case "monitorEvent": {

        private _debug = [_logic, "debug"] call MAINCLASS;
        private _broadcastOnRadio = [_logic, "broadcastOnRadio"] call MAINCLASS;
        private _registryID = [_logic, "registryID"] call MAINCLASS;
        private _event = _args select 0;
        private _requestAnalysis = _args select 1;

        private _side = [_logic, "side"] call MAINCLASS;
        private _eventQueue = [_logic, "eventQueue"] call MAINCLASS;
        private _isCarrier = [_logic, "isCarrier"] call MAINCLASS;

        private _eventID = [_event, "id"] call ALIVE_fnc_hashGet;
        private _eventData = [_event, "data"] call ALIVE_fnc_hashGet;
        private _eventTime = [_event, "time"] call ALIVE_fnc_hashGet;
        private _eventState = [_event, "state"] call ALIVE_fnc_hashGet;
        private _eventSender = [_event, "from","OPCOM"] call ALIVE_fnc_hashGet;
        private _eventStateData = [_event, "stateData"] call ALIVE_fnc_hashGet;
        private _eventFriendlyProfiles = [_event, "friendlyProfiles"] call ALIVE_fnc_hashGet;
        private _eventEnemyProfiles = [_event, "enemyProfiles"] call ALIVE_fnc_hashGet;
        private _playerRequested = [_event, "playerRequested"] call ALIVE_fnc_hashGet;
        private _playerRequestProfiles = [_event, "playerRequestProfiles"] call ALIVE_fnc_hashGet;

        private _eventType = _eventData select 0;
        private _eventSide = _eventData select 1;
        private _eventFaction = _eventData select 2;
        private _eventAirspace = _eventData select 3;
        private _eventATO = _eventData select 4;

        private _eventROE = _eventATO select 0;
        private _eventHeight = _eventATO select 1;
        private _eventSpeed = _eventATO select 2;
        private _eventMinWeap = _eventATO select 3;
        private _eventMinFuel = _eventATO select 4;
        private _eventRange = _eventATO select 5;
        private _eventDuration = _eventATO select 6;
        private _eventTargets = _eventATO select 7;

        // Check to see if generateTasks
        private _generateTasks = [_logic,"generateTasks"] call MAINCLASS;
        // Check to see if C2ISTAR is available
        private _C2ISTARisAvailable = ["ALiVE_mil_c2istar"] call ALiVE_fnc_isModuleAvailable;

        // For radio broadcasts
        private _sideObject = [_side] call ALIVE_fnc_sideTextToObject;
        private _factionName = getText((_eventFaction call ALiVE_fnc_configGetFactionClass) >> "displayName");
        private _hqClass = switch (_sideObject) do {
            case WEST: {
                "BLU"
            };
            case EAST: {
                "OPF"
            };
            case RESISTANCE: {
                "IND"
            };
            default {
                "HQ"
            };
        };
        private _HQ = getText(configFile >> "CfgHQIdentities" >> _hqClass >> "name");

        private _assets = [ALIVE_globalATO,_eventFaction] call ALIVE_fnc_hashGet;
        private _airspaceAssets = [_logic,"airspaceAssets"] call MAINCLASS;

        // Check to see if airspace name or position has been provided
        if (_eventAirspace isEqualType []) then {
            private _tmpAirspace = "";
            {
                if (_eventAirspace inArea _x) exitWith {
                    _tmpAirspace = _x;
                };
            } forEach (_airspaceAssets select 1);
            _eventAirspace = _tmpAirspace;
            _eventData set [3,_eventAirspace];
            [_event,"data",_eventData] call ALiVE_fnc_hashSet;
        };

        // Check to see if request is within airspace, if not use 1st airspace
        if (_eventAirspace == "") then {
            _eventAirspace = (_airspaceAssets select 1) select 0;
            _eventData set [3,_eventAirspace];
            [_event,"data",_eventData] call ALiVE_fnc_hashSet;
        };

        private _airspaceAssets = [_airspaceAssets, _eventAirspace,[]] call ALiVE_fnc_hashGet;
        private _airports = [_logic,"runways"] call MAINCLASS;

        if(_playerRequested) then {
            _playerID = _eventData select 5;
            _requestID = _eventData select 6;
        };

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["ATO %1 - Monitoring Event", _logic] call ALiVE_fnc_dump;
            _event call ALIVE_fnc_inspectHash;
            _requestAnalysis call ALIVE_fnc_inspectHash;
        };
        // DEBUG -------------------------------------------------------------------------------------


        // react according to current event state
        switch(_eventState) do {

            // AI REQUEST ---------------------------------------------------------------------------------------------------------------------------------

            // operation has been requested
            case "requested": {

                private _waitTime = 40;

                // according to the type of operation
                // adjust wait time and setup profiles for operation

                switch(_eventType) do {
                    case "CAP": {
                        _waitTime = WAIT_TIME_CAP;
                    };
                    case "DCA": {
                        _waitTime = WAIT_TIME_DCA;
                    };
                    case "SEAD": {
                        _waitTime = WAIT_TIME_SEAD;
                    };
                    case "CAS": {
                        _waitTime = WAIT_TIME_CAS;
                    };
                    case "Strike": {
                        _waitTime = WAIT_TIME_Strike;
                    };
                    case "Recce": {
                        _waitTime = WAIT_TIME_Recce;
                    };
                    case default {
                        _waitTime = DEFAULT_WAIT_TIME;
                    };
                };

                if (_eventSender == "OPCOM") then {
                    _waitTime = 0;
                };

                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    ["ATO %4 - Event state: %1 event timer: %2 wait time on event: %3 ",_eventState, (time - _eventTime), _waitTime, _logic] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------

                if((time - _eventTime) > _waitTime) then {
                    // Assuming assets are available, find nearest asset that can complete the task, if no appropriate asset report back
                    private _assetAvailable = false;
                    private _opAssets = [];
                    private _selectedAsset = [];
                    private _aircraftType = ["Plane","Helicopter"];
                    private _aircraftRole = "Attack";
                    private _eventPosition = getMarkerPos _eventAirspace;

                    // Based on Op, check what type of aircraft we need
                    switch (_eventType) do {
                        case "CAP";
                        case "DCA" : {
                            _aircraftType = ["Plane"];
                            _aircraftRole = "Fighter";
                        };
                        case "Recce" : {
                            _aircraftType = ["Plane","Helicopter"];
                            _aircraftRole = "Recon";
                        };
                        default {
                            _aircraftType = ["Plane","Helicopter"];
                            _aircraftRole = "Attack";
                        };
                    };

                    // Check airspace assets first
                    {
                        private _profileID = _x;
                        private _tmpType = [[_assets,_profileID] call ALiVE_fnc_hashGet,"vehicleClass"] call ALiVE_fnc_hashGet;
                        if ( {_tmpType iskindof _x} count _aircraftType > 0) then {
                            _opAssets pushback _x;
                        };
                    } forEach _airspaceAssets;

                    if (_debug) then {
                        ["ATO %1 OP ASSETS: %2", _logic, _opAssets] call ALiVE_fnc_dump;
                    };

                    // Get an asset from another airspace if it is CAS
                    if (count _opAssets == 0 && _eventType == "CAS") then {

                        {
                            If (_x != _eventAirspace) then {
                                {
                                    private _tmpType = [[_assets,_x] call ALiVE_fnc_hashGet,"vehicleClass"] call ALiVE_fnc_hashGet;
                                    if ( {_tmpType iskindof _x} count _aircraftType > 0) then {
                                        _opAssets pushback _x;
                                    };
                                } forEach ([[_logic,"airspaceAssets"] call MAINCLASS, _x] call ALiVE_fnc_hashGet);
                            };
                        } forEach ([_logic,"airspaceAssets"] call MAINCLASS select 1);
                    };

                    // Check to see if they are available - check damage, fuel, ammo, parked or on CAP
                    if (count _opAssets > 0) then {

                        {
                            private _profileID = _x;
                            private _profile = [ALIVE_profileHandler, "getProfile",_profileID] call ALIVE_fnc_profileHandler;
                            private _exit = false;

                            if !(isNil "_profile") then {
                                private _aircraft = [_assets,_x] call ALiVE_fnc_hashGet;

                                // Check aircraft is not under maintenance
                                private _maintenanceTime = [_aircraft,"maintenance",0] call ALiVE_fnc_hashGet;
                                private _underMaintenance = (time < (_maintenanceTime + (180 + random 600))) && (time > 600);

                                // check aircraft has the correct role
                                private _aircraftRoles = [_aircraft,"roles"] call ALiVE_fnc_hashGet;
                                if (_aircraftRole in _aircraftRoles && !_underMaintenance) then {
                                    private _position = [_aircraft,"startPos"] call ALiVE_fnc_hashGet;
                                    private _currentOp = [_aircraft,"currentOp",""] call ALiVE_fnc_hashGet;
                                    private _profileType = [_profile, "type"] call ALiVE_fnc_hashGet;
                                    private _crewAvailable = true;


                                    if (_profileType == "entity") then {
                                        private _profileVehID = ([_profile, "vehiclesInCommandOf"] call ALiVE_fnc_hashGet) select 0;
                                        _profile = [ALIVE_profileHandler, "getProfile",_profileVehID] call ALIVE_fnc_profileHandler;
                                    };

                                    private _active = [_profile,"active"] call ALiVE_fnc_hashGet;
                                    private _damage = [_profile, "damage"] call ALiVE_fnc_hashGet;
                                    if (count _damage == 0) then {
                                        _damage = 0;
                                    } else {
                                        // Calculate % of damage
                                        private _curDamage = 0;
                                        {
                                            _curDamage = _curDamage + (_x select 1);
                                        } forEach _damage;
                                        if (_curDamage == 0) then {
                                            _damage = 0;
                                        } else {
                                            _damage = _curDamage / count _damage;
                                        };
                                    };

                                    private _fuel = [_profile, "fuel"] call ALiVE_fnc_hashGet;
                                    private _currentPosition = [_profile, "position"] call ALiVE_fnc_hashGet;

                                    private _ammo = [_profile, "ammo"] call ALiVE_fnc_hashGet;
                                    if (count _ammo == 0) then {
                                            _ammo = 1;
                                    } else {
                                        // Calculate % of ammo
                                        private _avail = 0;
                                        {
                                            _avail = _avail + ((_x select 1)/(_x select 2));
                                        } forEach _ammo;
                                        _ammo = _avail / count _ammo;
                                    };

                                    // An airframe with a player in it is off limits, however
                                    // suitable it looks on paper. Nothing downstream expects a
                                    // human in the seat: the crew boards with moveInAny, which
                                    // quietly finds no seat at all in a single seater and leaves
                                    // the commander believing a sortie launched that never did,
                                    // and the return leg teleports the airframe back to its
                                    // parking slot with whoever is aboard still inside it.
                                    //
                                    // Only spawned aircraft can be occupied, so this costs
                                    // nothing for the virtualised majority of the roster.
                                    private _playerOccupied = false;
                                    private _assetClass = [_aircraft,"vehicleClass",""] call ALiVE_fnc_hashGet;
                                    // Set when the aircraft is somewhere it cannot fly from and
                                    // is on its way back. Held out of selection until it arrives.
                                    private _returnHome = false;
                                    // A profile marked spawned whose object has gone reports
                                    // zero fuel and a position at map origin, and it is the zero
                                    // fuel that keeps a destroyed aircraft out of the running.
                                    // That is left exactly as it was, but the bogus position
                                    // must not reach the home check below, which would read it
                                    // as an aircraft stranded in the sea off the map corner.
                                    private _liveObjMissing = false;

                                    if (_active) then {
                                        private _vehicleObj = [_profile, "vehicle"] call ALiVE_fnc_hashGet;
                                        _damage = damage _vehicleObj;
                                        _fuel = fuel _vehicleObj;
                                        _currentPosition = getposATL _vehicleObj;

                                        if (isNull _vehicleObj) then {
                                            _liveObjMissing = true;
                                        } else {
                                            // Seated crew covers the ordinary case. The second
                                            // test covers a drone being flown from a terminal,
                                            // where the operator is nowhere near the airframe
                                            // and so never appears in its crew.
                                            _playerOccupied = (crew _vehicleObj) findIf {isPlayer _x} > -1;

                                            if !(_playerOccupied) then {
                                                private _uavOperator = (UAVControl _vehicleObj) param [0, objNull];
                                                _playerOccupied = !isNull _uavOperator && {isPlayer _uavOperator};
                                            };
                                        };
                                    };

                                    if (_playerOccupied && _debug) then {
                                        ["ATO %1 %2 skipped: player aboard", _logic, _assetClass] call ALiVE_fnc_dump;
                                    };

                                    // Home reconciliation. startPos is written once when the
                                    // aircraft joins the roster and never revisited, so an
                                    // airframe a player has flown and left somewhere else is
                                    // still being measured against a hangar it is no longer in.
                                    // Everything downstream reads that distance: an aircraft
                                    // more than 15 m from startPos is taken to be already
                                    // airborne, so it gets tasked with no takeoff run, and the
                                    // return leg then teleports it back to a slot it never
                                    // left from.
                                    //
                                    // Only an idle aircraft is reconciled. One in the middle of
                                    // a sortie is away from its parking slot for a good reason.
                                    // The isNil guard is not paranoia: source files are picked up
                                    // live under file patching but a new CfgFunctions entry only
                                    // exists after a rebuild, so this file can legitimately run
                                    // for a while before the function it calls is compiled.
                                    // Skipping reconciliation entirely in that window leaves
                                    // behaviour exactly as it was rather than throwing.
                                    //
                                    // The verdict is remembered against the position it was made
                                    // at. Working out whether somewhere is an airfield means
                                    // sweeping for runway objects over a wide radius, and an
                                    // aircraft left standing where it cannot fly from is not
                                    // going to move on its own while a player is beside it.

                                    // Without this the same sweep would run again on every
                                    // request for as long as it sat there.
                                    private _strandedAt = [_aircraft,"strandedAt",[]] call ALiVE_fnc_hashGet;

                                    if (count _strandedAt > 1 && {_strandedAt distance _currentPosition < 25}) then {
                                        _returnHome = true;
                                    } else {

                                    if (!isNil "ALiVE_fnc_isAirfieldPosition"
                                        && {!_liveObjMissing}
                                        && {_currentOp == ""}
                                        && {!_playerOccupied}
                                        && {_position distance _currentPosition > 250}) then {

                                        // Before trusting a negative answer, check the test can
                                        // answer at all here. If the aircraft's OWN parking slot
                                        // does not read as an airfield, this terrain has no
                                        // runway data the test can see, and a "not an airfield"
                                        // verdict anywhere else means nothing. Acting on it would
                                        // strand aircraft sitting on their own apron.
                                        //
                                        // Only the negative needs this guard. A positive answer
                                        // is evidence in its own right whatever the home reads as.
                                        private _atAirfield = [_currentPosition, _assetClass] call ALiVE_fnc_isAirfieldPosition;
                                        private _homeIsAirfield = _atAirfield || {[_position, _assetClass] call ALiVE_fnc_isAirfieldPosition};

                                        if (!_homeIsAirfield) then {
                                            if (_debug) then {
                                                ["ATO %1 %2 home reconciliation skipped: no runway data near %3", _logic, _assetClass, _position] call ALiVE_fnc_dump;
                                            };
                                        } else {

                                        if (_atAirfield) then {
                                            [_aircraft,"strandedAt",[]] call ALiVE_fnc_hashSet;
                                            // Parked somewhere it can legitimately operate from,
                                            // so adopt it as the new home rather than dragging
                                            // the airframe back across the map. Direction is
                                            // taken as it sits: it was landed and parked by a
                                            // person, which is a better heading than anything
                                            // inferred from a hangar it is not in.
                                            [_aircraft,"startPos",_currentPosition] call ALiVE_fnc_hashSet;
                                            if (_active) then {
                                                private _vObj = [_profile, "vehicle"] call ALiVE_fnc_hashGet;
                                                if !(isNull _vObj) then {
                                                    [_aircraft,"startDir",direction _vObj] call ALiVE_fnc_hashSet;
                                                };
                                            };
                                            // The airport it answers to changes with it, or the
                                            // taxi and ILS lookups keep resolving against the
                                            // field it flew away from.
                                            [_aircraft,"airportID",[_currentPosition] call ALiVE_fnc_getNearestAirportID] call ALiVE_fnc_hashSet;
                                            _position = _currentPosition;

                                            if (_debug) then {
                                                ["ATO %1 %2 re-homed to %3", _logic, _assetClass, _currentPosition] call ALiVE_fnc_dump;
                                            };
                                        } else {
                                            // Sitting somewhere it cannot operate from. Send it
                                            // home and keep it out of the running until it is
                                            // there, rather than ordering a takeoff from a field.
                                            //
                                            // Nobody is watching a virtualised airframe, so the
                                            // profile is simply put back where it belongs. If it
                                            // is spawned it stays visibly put: a plane vanishing
                                            // in front of a player is worse than a commander
                                            // being one aircraft short.
                                            _returnHome = true;

                                            if !(_active) then {
                                                [_profile, "position", _position] call ALiVE_fnc_profileVehicle;
                                                [_aircraft,"currentPos",_position] call ALiVE_fnc_hashSet;
                                            } else {
                                                // Spawned, so it stays where it is and the verdict
                                                // is remembered against this spot. It gets tested
                                                // again the moment it moves more than 25 m.
                                                [_aircraft,"strandedAt",_currentPosition] call ALiVE_fnc_hashSet;
                                            };

                                            if (_debug) then {
                                                ["ATO %1 %2 stranded off-airfield at %3, returning to %4 (spawned=%5)", _logic, _assetClass, _currentPosition, _position, _active] call ALiVE_fnc_dump;
                                            };
                                        };

                                        };
                                    };

                                    };

                                    if (_debug) then {
                                        ["ATO %4 %5 F:%1, A:%2, D:%3, Dist:%6,",_fuel, _ammo, _damage, _logic, _profileID, _position distance _currentPosition] call ALiVE_fnc_dump;
                                    };

                                    // Check crew are alive if not UAV

                                    if !([[_profile,"vehicleClass",""] call ALiVE_fnc_hashGet] call _fnc_isDroneClass) then {
                                        private _crewID = [_aircraft,"crewID",""] call ALiVE_fnc_hashGet;
                                        private _crewProfile = [ALIVE_profileHandler, "getProfile",_crewID] call ALIVE_fnc_profileHandler;
                                        if (isNil "_crewProfile") then {
                                            _crewAvailable = false;
                                            if (_debug) then {
                                                ["ATO %1 %2 Crew unavailable!", _logic, _crewID] call ALiVE_fnc_dump;
                                            };
                                        };
                                    };

                                    // If an asset is parked or flying a CAP (and the request is not CAP) then the aircraft is available (or if CAS is requested)
                                    if (_crewAvailable && !_playerOccupied && !_returnHome) then {

                                        // Get active event type
                                        if (_currentOp != "") then {
                                            //Retrieve event data
                                            private _currentEvent = [_eventQueue, _currentOp,[]] call ALIVE_fnc_hashGet;
                                            private _currentOpState = [_currentEvent, "state",""] call ALIVE_fnc_hashGet;
                                            if !(_currentOpState in ["aircraftLanding","aircraftReturnWait","aircraftStart"]) then {
                                                _currentOp = [_currentEvent, "data"] call ALIVE_fnc_hashGet select 0;
                                            } else {
                                                // Aircraft is starting/landing, so not available yet, set fuel measurement to zero
                                                _fuel = 0;
                                            };
                                        };

                                        // Don't reroute an aircraft twice
                                        if !([_aircraft,"reroute", false] call ALiVE_fnc_hashGet) then {

                                            // If parked and not doing anything add, if on CAP and request is DCA,CAS,SEAD then reroute, if its CAS and currently on CAS don't reroute - make sure aircraft is fit for purpose
                                            if ( ( ((_position distance _currentPosition < 15) && _currentOp == "") || (_currentOp == "CAP" && _eventType in ["DCA","CAS","SEAD"]) || (_currentOp != "CAS" && _eventType == "CAS") ) && (_fuel > _eventMinFuel && _ammo > _eventMinWeap && _damage < 0.5)) then {

                                                [_aircraft,"currentPos",_currentPosition] call ALiVE_fnc_hashSet;
                                                [_aircraft,"profileID",_x] call ALiVE_fnc_hashSet;
                                                _selectedAsset pushback _aircraft;

                                                // If the aircraft is on a CAP and not in the process of landing, send it to intercept
                                                if (_currentOp == "CAP" && _eventType == "DCA") then {
                                                    _selectedAsset = [_aircraft];
                                                    _exit = true;
                                                };
                                            };
                                        };
                                    } else {
                                        // If crew is not available, ensure LOGCOM request goes in
                                    };
                                } else {
                                    if (_debug) then {
                                        ["ATO %1 Aircraft not suitable for role (%2) or under maintenance %3", _logic, (_aircraftRole in _aircraftRoles), _underMaintenance] call ALiVE_fnc_dump;
                                    };
                                };
                            };
                            if (_exit) exitWith {};
                        } forEach _opAssets;

                        if (count _selectedAsset > 0) then {

                            // Get target position
                            if (_eventType != "CAP") then {

                                // Spawn any event targets
                                {
                                    if (_x isEqualType "") then {
                                         private _targetProfile = [ALiVE_profileHandler, "getProfile", _x] call ALiVE_fnc_ProfileHandler;
                                         if !(isNil "_targetProfile") then {
                                            [_targetProfile,"spawnType",["preventDespawn"]] call ALiVE_fnc_hashSet;

                                            private _active = [_targetProfile,"active"] call ALiVE_fnc_hashGet;
                                            if !(_active) then {
                                                 private _type = [_targetProfile,"type"] call ALiVE_fnc_hashGet;
                                                 //["ATO %3 SPAWNING %4 TARGET %1: %2",_type, _x, _logic, _eventType] call ALiVE_fnc_dump;
                                                 if (_type == "entity") then {
                                                    [_targetProfile,"spawn"] call ALiVE_fnc_profileEntity;
                                                 } else {
                                                    [_targetProfile,"spawn"] call ALiVE_fnc_profileVehicle;
                                                };
                                            };
                                        };
                                    };
                                } forEach _eventTargets;

                                // Work out distance to first target
                                if ((_eventTargets select 0) isEqualType objNull) then {
                                    _eventPosition = position (_eventTargets select 0);
                                } else {
                                    private _targetProfile = [ALiVE_profileHandler, "getProfile", (_eventTargets select 0)] call ALiVE_fnc_ProfileHandler;
                                    if !(isNil "_targetProfile") then {_eventPosition = [_targetProfile,"position"] call ALiVE_fnc_hashGet;};
                                };
                            };

                            // Sort by how well suited the aircraft is, then by distance.
                            //
                            // Distance alone meant every qualifying aircraft was equal, so
                            // whatever sat closest won. A ground-attack aircraft carrying
                            // self-defence missiles counts as a fighter, so an A-10 parked
                            // near the runway was being sent on combat air patrol ahead of
                            // an actual fighter parked further away - and then loitering
                            // over defended ground until it was shot down.
                            //
                            // The preference only reorders, it never excludes: if the
                            // ill-suited aircraft is all there is, it still flies. That
                            // matters more than picking well, because an empty result means
                            // no air support at all.

                            // Each branch works out its own penalty and hands it back
                            // rather than adding to a running total, because the case
                            // blocks run as their own scopes and writing to a variable
                            // declared outside them is the sort of thing that works right
                            // up until someone moves the code.
                            private _fnc_suitability = {
                                params ["_asset", "_wantRole"];

                                // An asset whose capabilities never resolved must not sink
                                // the whole sort. Nothing known means no penalty, so it
                                // ranks on distance alone, exactly as it did before.
                                private _rawCaps = [_asset,"capabilities",[]] call ALiVE_fnc_hashGet;
                                private _caps = if (!isNil "_rawCaps" && {_rawCaps isEqualType []}) then {_rawCaps} else {[]};

                                // The cannon is deliberately ignored on both counts below.
                                // Nearly every combat aircraft carries one, so it says
                                // nothing about what the airframe is for. What separates
                                // them is the air-to-ground ordnance hanging off the wings.
                                private _agGuided   = "agGuided"   in _caps;
                                private _agUnguided = "agUnguided" in _caps;

                                switch (_wantRole) do {
                                    // Patrolling for aircraft: bombs and ground missiles
                                    // are dead weight up there, and an aircraft built to
                                    // carry them is slower and less survivable than one
                                    // built to fight. Each kind carried pushes it down.
                                    case "Fighter": {
                                        {_x} count [_agGuided, _agUnguided]
                                    };
                                    // Going after something on the ground: precision
                                    // ordnance first, then unguided, and an aircraft with
                                    // only a cannon last. It can still be sent, but it is
                                    // the weakest answer to the request.
                                    case "Attack": {
                                        if (_agGuided) then {0} else {if (_agUnguided) then {1} else {2}}
                                    };
                                    // Looking rather than shooting: send the drone where
                                    // there is one, and keep aircrew out of it.
                                    case "Recon": {
                                        private _cls = [_asset,"vehicleClass",""] call ALiVE_fnc_hashGet;
                                        private _isDrone = _cls isKindOf "Air"
                                                        && {_cls isKindOf "UAV"
                                                            || {getNumber (configFile >> "CfgVehicles" >> _cls >> "isUav") == 1}};
                                        if (_isDrone) then {0} else {1}
                                    };
                                    default {0};
                                }
                            };

                            // Suitability dominates, distance breaks ties inside a band.
                            // The multiplier only has to exceed any real distance on any
                            // map, and the largest terrains are a few tens of kilometres.
                            private _ranked = [_selectedAsset,[],{
                                (([_x, _aircraftRole] call _fnc_suitability) * 1000000)
                                + (_eventPosition distance ([_x,"currentPos"] call ALiVE_fnc_hashGet))
                            },"ASCEND"] call ALiVE_fnc_SortBy;

                            _selectedAsset = _ranked select 0;
                            _assetAvailable = true;

                            // DEBUG -------------------------------------------------------------------------------------
                            if(_debug) then {
                                // The whole ranking, in order, with what each aircraft was
                                // marked down for. Without this a bad choice looks the same
                                // as no choice at all, which is what made the wrong aircraft
                                // being sent on patrol so hard to spot in the first place.
                                {
                                    ["ATO %1 rank %2 for %3: %4 penalty=%5 dist=%6 caps=%7",
                                        _logic,
                                        _forEachIndex,
                                        _aircraftRole,
                                        [_x,"vehicleClass",""] call ALiVE_fnc_hashGet,
                                        [_x, _aircraftRole] call _fnc_suitability,
                                        round (_eventPosition distance ([_x,"currentPos"] call ALiVE_fnc_hashGet)),
                                        [_x,"capabilities",[]] call ALiVE_fnc_hashGet
                                    ] call ALiVE_fnc_dump;
                                } forEach _ranked;

                                _selectedAsset call ALIVE_fnc_inspectHash;
                            };

                        };
                    };

                    // If asset is available set data needed
                    if (_assetAvailable) then {

                        private _profileID = [_selectedAsset,"profileID"] call ALiVE_fnc_hashGet;
                        private _startPosition = [_selectedAsset,"startPos"] call ALiVE_fnc_hashGet;
                        private _vehicleClass = [_selectedAsset,"vehicleClass"] call ALiVE_fnc_hashGet;
                        private _currentPosition = [_selectedAsset,"currentPos"] call ALiVE_fnc_hashGet;
                        private _currentOp = [_selectedAsset,"currentOp",""] call ALiVE_fnc_hashGet;
                        private _parked = false;
                        private _takeoff = false;

                        // Get start position
                        if (_startPosition distance _currentPosition < 15) then {
                            _parked = true;
                        };

                        if (_parked) then {
                            // players near check
                            _playersInRange = [_startPosition, 1500] call ALiVE_fnc_anyPlayersInRange;

                            // if players are in visible range and aircraft parked, start takeoff procedure
                            if(_playersInRange > 0) then {
                                _takeoff = true;
                            };
                        };

                        // Add entity profile ID
                        _eventFriendlyProfiles pushback _profileID;

                        // DEBUG -------------------------------------------------------------------------------------
                        if(_debug) then {
                            // Log details
                            ["AI ATO Side: %1, Faction: %2, Asset: %3, Profiles: %8, Start: %4, Position: %5, ATO: %6, Targets: %7", _eventSide, _eventFaction, _vehicleClass, _currentPosition, _eventPosition, _eventType, _eventTargets,_eventFriendlyProfiles] call ALiVE_fnc_dump;

                            switch(_eventType) do {
                                case "CAP": {
                                    [_logic, "createMarker", [_currentPosition,_eventSide,"CAP ASSET",0]] call MAINCLASS;
                                    [_logic, "createMarker", [_eventPosition,_eventSide,"CAP RADIUS",_eventRange]] call MAINCLASS;
                                };
                                default {
                                    [_logic, "createMarker", [_currentPosition,_eventSide,"ATO ASSET",0]] call MAINCLASS;
                                    [_logic, "createMarker", [_eventPosition,_eventSide,"ATO TARGET",0]] call MAINCLASS;
                                };

                            };
                        };
                        // DEBUG -------------------------------------------------------------------------------------

                        // Set current op for asset

                        // Check for existing OP?
                        if (_currentOp != "") then {

                            //
                            if (_debug) then {
                                ["ATO %4 Rerouting %1 (%2) for new request %3", _profileID, _currentOp, _eventType, _logic] call ALiVE_fnc_dump;
                            };

                            // Radio Broadcast

                            // Vehicle is active and doing something, so remove all existing waypoints in prep for new request
                            private _profile = [ALIVE_profileHandler, "getProfile",_profileID] call ALIVE_fnc_profileHandler;
                            if (!isNil "_profile") then {
                                private _vehicleObj = [_profile, "vehicle",objnull] call ALiVE_fnc_hashGet;
                                private _grp = group _vehicleObj;
                                while {(count (waypoints _grp)) > 0} do
                                {
                                    deleteWaypoint ((waypoints _grp) select 0);
                                };
                            };

                            [_selectedAsset,"reroute",true] call ALiVE_fnc_hashSet;

                            // Remove old event so aircraft can switch to new tasking
                            // set state to event complete
                            private _oldEvent = [_eventQueue,_currentOp] call ALiVE_fnc_hashGet;
                            [_oldEvent, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                            [_eventQueue, _eventID, _oldEvent] call ALIVE_fnc_hashSet;
                        };

                        // Update assets
                        [_selectedAsset,"currentOp",_eventID] call ALiVE_fnc_hashSet;
                        [_assets,_profileID,_selectedAsset] call ALiVE_fnc_hashSet;
                        [_logic, "assets", _assets] call MAINCLASS;

                        _eventData pushback _eventPosition;
                        _eventData pushback _takeoff;

                        [_event, "friendlyProfiles", _eventFriendlyProfiles] call ALIVE_fnc_hashSet;

                        // get the profile IDs for eventTargets (and convert any profiles to real targets)
                        _eventEnemyProfiles = [];
                        {
                            if (_x isEqualType objNull) then {
                                if (_x getVariable ["profileID",""] != "") then {
                                    _eventEnemyProfiles pushback (_x getVariable "profileID");
                                };
                            } else {
                                _eventEnemyProfiles pushback _x;
                                private _targetProfile = [ALiVE_profileHandler, "getProfile", _x] call ALiVE_fnc_ProfileHandler;
                                if !(isNil "_targetProfile") then {
                                    private _type = [_targetProfile,"type"] call ALiVE_fnc_hashGet;
                                    // _targetProfile call ALIVE_fnc_inspectHash;
                                    private _vehicle = objNull;
                                    if (_type == "entity") then {
                                        _vehicle = [_targetProfile,"leader"] call ALiVE_fnc_hashGet;
                                    } else {
                                        _vehicle = [_targetProfile,"vehicle"] call ALiVE_fnc_hashGet;
                                    };
                                    _eventTargets set [_forEachIndex, _vehicle];
                                };
                            };
                        } forEach _eventTargets;

                        [_event, "enemyProfiles", _eventEnemyProfiles] call ALIVE_fnc_hashSet;

                        [_event, "data", _eventData] call ALIVE_fnc_hashSet;

                        // update the state of the event
                        // next state is aircraftStart
                        [_event, "state", "aircraftStart"] call ALIVE_fnc_hashSet;

                        // dispatch event
                        private _logEvent = [format['ATO_%1',_eventType], [_eventPosition,_eventFaction,_eventSide,_eventID],"air tasking orders"] call ALIVE_fnc_event;
                        [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                        [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                    }else{

                        // Check to see if there are any player controlled aircraft - if so, reroute request via C2ISTAR

                        private _playersInAircraft = [];
                        {
                            private _player = _x;
                            {
                                if ((vehicle _player) iskindof _x && (driver (vehicle _player) == _player)) exitWith {
                                    _playersInAircraft pushback _x;
                                };
                            } forEach _aircraftType;
                        } forEach allPlayers;

                        if (count _playersInAircraft > 0 && _generateTasks && _C2ISTARisAvailable) then {

                            [_logic,"requestPlayerTask",[_eventType,_eventTargets]] call MAINCLASS;

                            // REMOVE EVENT from ATO
                            [_logic, "removeEvent", _eventID] call MAINCLASS;

                        } else {

                            // An appropriate aircraft is not available to do the op
                            // DEBUG -------------------------------------------------------------------------------------
                            if(_debug) then {
                                ["ATO %2 - Air Tasking request denied, Military Air Component Commander for %1 has no appropriate air assets available", _eventFaction, _logic] call ALiVE_fnc_dump;
                            };
                            // DEBUG -------------------------------------------------------------------------------------

                            //Radio Broadcast
                            if (_broadcastOnRadio) then {
                                private _message = format[localize "STR_ALIVE_ATO_REQUEST_DENIED", _HQ, _eventType, mapGridPosition _eventPosition];
                                // send a message to all side players from HQ
                                private _radioBroadcast = [objNull,_message,"side",_sideObject,false,false,false,true,_hqClass];
                                [_side,_radioBroadcast] call ALIVE_fnc_radioBroadcastToSide;
                            };

                            // nothing to do so cancel..
                            [_logic, "removeEvent", _eventID] call MAINCLASS;
                        };

                    };
                };
            };

            case "aircraftStart": {

                private _eventPosition = _eventData select 5;
                private _takeoff = _eventData select 6;

                private _aircraftID = _eventFriendlyProfiles select 0;
                private _aircraft = [_assets,_aircraftID] call ALiVE_fnc_hashGet;
                if (isNil "_aircraft") exitWith {
                  ["ATO - aircraftTravel has no valid _aircraft"] call ALiVE_fnc_dump;
                }; 
                private _profileID = [_aircraft,"profileID"] call ALiVE_fnc_hashGet;
                private _startPosition = [_aircraft,"startPos"] call ALiVE_fnc_hashGet;
                private _startDir = [_aircraft,"startDir"] call ALiVE_fnc_hashGet;
                private _vehicleClass = [_aircraft,"vehicleClass"] call ALiVE_fnc_hashGet;
                private _isVTOL = [_vehicleClass] call ALiVE_fnc_isVTOL;
                private _currentPosition = [_aircraft,"currentPos"] call ALiVE_fnc_hashGet;
                private _aircraftReady = [_aircraft,"ready",false] call ALiVE_fnc_hashGet;
                private _isOnCarrier = [_aircraft,"isOnCarrier",false] call ALiVE_fnc_hashGet;
                private _isPlane = _vehicleClass iskindof "Plane" && (_isVTOL < 3);

                private _count = [_logic, "checkEvent", _event] call MAINCLASS;

                if(_count == 0) exitWith {
                    if (_broadcastOnRadio) then {
                        private _className = getText(configFile >> "CfgVehicles" >> _vehicleClass >> "displayName");
                        private _message = format[localize "STR_ALIVE_ATO_AIRCRAFT_LOST", _HQ, _className, _eventType];
                        // send a message to all side players from HQ
                        private _radioBroadcast = [objNull,_message,"side",_sideObject,false,false,false,true,_hqClass];
                        [_side,_radioBroadcast] call ALIVE_fnc_radioBroadcastToSide;
                    };

                    if(_playerRequested) then {
                        private _logEvent = ['ATO_RESPONSE', [_requestID,_playerID],"Logistics","REQUEST_LOST"] call ALIVE_fnc_event;
                        [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;
                    };

                    // set state to event complete
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                    if (_isPlane) then {

                        private _airportID = [_aircraft,"airportID",[_startPosition] call ALiVE_fnc_getNearestAirportID] call ALiVE_fnc_hashGet;

                        // if plane check to see if runway is busy, wait
                        private _airportBusy = [_airports, _airportID] call ALiVE_fnc_hashGet;

                        if (isNil "_airportBusy") then {_airportBusy = false};

                        if (_airportBusy) then {

                            // Mark airport as no longer busy
                            [_airports, _airportID, false] call ALiVE_fnc_hashSet;
                            [_logic,"runways",_airports] call MAINCLASS;
                        };
                    };

                };

                if !(_aircraftReady) then {

                    // Prep aircraft (launch if not spawned)
                    if (_takeoff) then {

                        private _airportBusy = false;
                        private _airportID = 0;
                        private _UCAV = false;
                        private _catapult = [];

                        // If runway takeoff, handle runway/catapult deconfliction
                        if (_isPlane) then {
                            _airportID = [_aircraft,"airportID",[_startPosition] call ALiVE_fnc_getNearestAirportID] call ALiVE_fnc_hashGet;
                            // if plane check to see if runway is busy, wait
                            _airportBusy = [_airports, _airportID] call ALiVE_fnc_hashGet;

                            // Check catapult is free
                            if (surfaceIsWater _startPosition && _isOnCarrier) then {
                                _isUCAV = if (_vehicleClass isKindOf "B_UAV_05_F") then {true} else {false};
                                _catapult = [_startPosition, _isUCAV] call ALiVE_fnc_getNearestCatapult;
                                if !(isNil "_catapult") then {
                                    private _position = [_catapult, "position"] call ALiVE_fnc_hashGet;
                                    private _nearbyObj = nearestObjects [_position, ["Plane"], 3];
                                    if (count _nearbyObj > 0) then {
                                        // [">>>>>>>>>>>>>>>>>>>>>>>>>>>>>. CATAPULT BUSY <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"] call ALiVE_fnc_dump;
                                        _airportBusy = true;
                                    };
                                };
                            };
                        };

                        if (!_airportBusy || !_isPlane) then {

                                // Play scramble alarm
                                [_startPosition] spawn {
                                    private _pos = _this select 0;
                                    private _alarm = createSoundSource ["Sound_AirRaidSiren", _pos, [], 0]; //starts alarm
                                    sleep 30;
                                    deleteVehicle _alarm; //stops alarm
                                };

                                private _taxiPosition = +_startPosition;
                                private _taxiDir = 0;

                                // Get taxi or catapult position
                                If (_isPlane) then {
                                    // Mark airport as busy
                                    [_airports, _airportID, true] call ALiVE_fnc_hashSet;
                                    [_logic,"runways",_airports] call MAINCLASS;

                                    // Get Taxi position
                                    private _taxiPositions = [_airportID, "ilsTaxiIn",4,_startPosition] call ALiVE_fnc_getAirportTaxiPos;

                                    // A terrain with no ILS data for this airport returns nothing.
                                    // Keep the parked position set above rather than indexing into
                                    // an empty list, which handed nil coordinates to the launch and
                                    // surfaced as script errors instead of a graceful fallback.
                                    if (count _taxiPositions >= 4) then {
                                        _taxiPosition = [_taxiPositions select 0, _taxiPositions select 1];
                                        _taxiDir = _taxiPosition getDir [_taxiPositions select 2, _taxiPositions select 3];
                                    };

                                    // Check to see if we are over water, assume aircraft carrier, check for catapult
                                    if (surfaceIsWater _taxiPosition && _isOnCarrier) then {
                                        _taxiPosition = +_startPosition;
                                        if !(isNil "_catapult") then {
                                            _taxiPosition = [_catapult, "position", _taxiPosition] call ALiVE_fnc_hashGet;

                                            private _part = [_catapult, "part"] call ALiVE_fnc_hashGet;
                                            _taxiDir = [_catapult, "dirOffset", direction _part] call ALiVE_fnc_hashGet;
                                            _taxiDir = [(direction _part) + 180 - _taxiDir] call ALiVE_fnc_modDegrees;

                                            [_aircraft,"catapult",_catapult] call ALiVE_fnc_hashSet;
                                        };
                                    };
                                };

                                // Continuous taxi/takeoff path watchdog. The
                                // aircraft taxis along an unpredictable path
                                // (apron -> taxiway -> runway -> roll), and
                                // AI may walk into that path mid-taxi. A
                                // one-shot sweep at takeoff start can't
                                // catch that. This spawns an async loop
                                // that:
                                //
                                //   1. Waits up to 30s for the aircraft
                                //      profile to spawn its real vehicle
                                //      object (the spawn happens further
                                //      down this same code path - watchdog
                                //      starts watching only after the
                                //      vehicle exists).
                                //   2. Tick every 1s. Scan a 100m radius
                                //      around the aircraft. Filter to AI
                                //      within a forward cone (+/-60 deg of
                                //      aircraft facing) - those are the
                                //      ones in the taxi/takeoff path.
                                //   3. Teleport any matching AI 80m off
                                //      perpendicular to the side. setPos
                                //      bypasses BIS AI orders entirely.
                                //   4. Exit when aircraft is airborne (Z >
                                //      50m), destroyed/null, or 120s
                                //      timeout (worst case).
                                //
                                // Excludes pilots (kindOf Pilot - aircraft
                                // crew), players, and empty vehicles.
                                if (_isPlane) then {
                                    [_profileID, _vehicleClass, _airportID, _debug] spawn {
                                        params ["_profileID", "_vehicleClass", "_airportID", "_debug"];

                                        // Look up profile (scoped local;
                                        // _profile in outer scope isn't
                                        // defined yet at this insertion
                                        // point - it's set further down
                                        // in fnc_ATO).
                                        private _profile = [ALIVE_profileHandler, "getProfile", _profileID] call ALIVE_fnc_profileHandler;
                                        if (isNil "_profile") exitWith {
                                            if (_debug) then {
                                                ["ATO sweep watchdog [%1]: profile %2 lookup failed - exit", _vehicleClass, _profileID] call ALiVE_fnc_dump;
                                            };
                                        };

                                        // Wait for aircraft vehicle to spawn
                                        private _vehicleObj = objNull;
                                        private _waitStart = diag_tickTime;
                                        while {
                                            isNull _vehicleObj
                                            && {(diag_tickTime - _waitStart) < 30}
                                        } do {
                                            _vehicleObj = [_profile, "vehicle", objNull] call ALiVE_fnc_hashGet;
                                            sleep 0.5;
                                        };

                                        if (isNull _vehicleObj) exitWith {
                                            if (_debug) then {
                                                ["ATO sweep watchdog [%1, airport %2]: aircraft never spawned within 30s - exit", _vehicleClass, _airportID] call ALiVE_fnc_dump;
                                            };
                                        };

                                        if (_debug) then {
                                            ["ATO sweep watchdog [%1, airport %2]: tracking %3", _vehicleClass, _airportID, _vehicleObj] call ALiVE_fnc_dump;
                                        };

                                        // Track until airborne / dead / timeout
                                        private _trackStart = diag_tickTime;
                                        private _totalDoMove = 0;
                                        private _totalTeleport = 0;
                                        while {
                                            !isNull _vehicleObj
                                            && {alive _vehicleObj}
                                            && {(getPosATL _vehicleObj) select 2 < 50}
                                            && {(diag_tickTime - _trackStart) < 120}
                                        } do {
                                            private _pos = getPosATL _vehicleObj;
                                            private _dir = direction _vehicleObj;
                                            {
                                                private _u = _x;
                                                // Pilot exclusion: kindOf "Pilot"
                                                // catches BIS variants but RHS
                                                // pilots may not inherit the
                                                // base class. Also substring-
                                                // match typeOf for "pilot" /
                                                // "crew" to catch mod-defined
                                                // crew classes.
                                                private _typeLower = toLower (typeOf _u);
                                                private _isCrewLike = (_u isKindOf "Pilot")
                                                    || {_typeLower find "pilot" >= 0}
                                                    || {_typeLower find "crew" >= 0};
                                                // Aircraft proximity exclusion:
                                                // anything within 30m of the
                                                // aircraft is likely its own
                                                // crew about to board. The
                                                // forward-cone scan starts at
                                                // the aircraft so this protects
                                                // boarding crew from being
                                                // teleported away.
                                                private _distFromAircraft = _u distance _vehicleObj;
                                                if (
                                                    alive _u
                                                    && {_u != _vehicleObj}
                                                    && {!isPlayer (effectiveCommander _u)}
                                                    && {!_isCrewLike}
                                                    && {_distFromAircraft > 30}
                                                ) then {
                                                    private _hasLiveCrew = if (_u isKindOf "CAManBase") then {
                                                        true
                                                    } else {
                                                        ({alive _x} count (crew _u)) > 0
                                                    };
                                                    if (_hasLiveCrew) then {
                                                        // Forward cone gate: only
                                                        // sweep units in the path
                                                        // ahead of the aircraft.
                                                        private _bearing = _pos getDir _u;
                                                        private _angleDelta = abs ((_bearing - _dir + 540) mod 360 - 180);
                                                        if (_angleDelta < 60) then {
                                                            // Sweep target: 80m
                                                            // perpendicular to the
                                                            // forward axis. Random
                                                            // side so units don't
                                                            // pile up on one flank.
                                                            private _sideDir = _dir + (selectRandom [-90, 90]);
                                                            private _clearPos = _pos getPos [80, _sideDir];

                                                            // Two-stage move: first
                                                            // try doMove + commandMove
                                                            // (graceful, AI walks off);
                                                            // 5s grace period; if unit
                                                            // hasn't moved 3m+ from
                                                            // warn position by then,
                                                            // teleport. State per-unit
                                                            // via setVariable.
                                                            private _unitPos = getPosATL _u;
                                                            private _warnTime = _u getVariable ["ALiVE_ATO_sweep_warnTime", -1];
                                                            if (_warnTime < 0) then {
                                                                // First sighting -
                                                                // issue doMove, mark.
                                                                private _grp = group _u;
                                                                _grp setBehaviour "AWARE";
                                                                _grp setSpeedMode "NORMAL";
                                                                _u enableAI "MOVE";
                                                                _u enableAI "PATH";
                                                                _u doMove _clearPos;
                                                                _u commandMove _clearPos;
                                                                _u setVariable ["ALiVE_ATO_sweep_warnTime", diag_tickTime];
                                                                _u setVariable ["ALiVE_ATO_sweep_warnPos", _unitPos];
                                                                _u setVariable ["ALiVE_ATO_sweep_clearPos", _clearPos];
                                                                _totalDoMove = _totalDoMove + 1;
                                                            } else {
                                                                private _warnPos = _u getVariable ["ALiVE_ATO_sweep_warnPos", _unitPos];
                                                                private _moved = _unitPos distance _warnPos;
                                                                private _elapsed = diag_tickTime - _warnTime;
                                                                if (_moved > 10) then {
                                                                    // Successfully
                                                                    // moved away,
                                                                    // reset state in
                                                                    // case they
                                                                    // wander back.
                                                                    _u setVariable ["ALiVE_ATO_sweep_warnTime", -1];
                                                                } else {
                                                                    if (_elapsed > 5) then {
                                                                        // 5s grace
                                                                        // expired, no
                                                                        // movement -
                                                                        // teleport.
                                                                        private _tgt = _u getVariable ["ALiVE_ATO_sweep_clearPos", _clearPos];
                                                                        _u setPosATL _tgt;
                                                                        _u setVariable ["ALiVE_ATO_sweep_warnTime", -1];
                                                                        _totalTeleport = _totalTeleport + 1;
                                                                    };
                                                                };
                                                            };
                                                        };
                                                    };
                                                };
                                            } forEach (nearestObjects [_pos, ["CAManBase","Car","Tank","Truck_F"], 100]);
                                            sleep 1;
                                        };

                                        if (_debug) then {
                                            private _z = if (!isNull _vehicleObj) then { (getPosATL _vehicleObj) select 2 } else { -1 };
                                            ["ATO sweep watchdog [%1]: ended after %2s, doMove issued=%3 teleport fallback=%4 (aircraftZ=%5 alive=%6)", _vehicleClass, round (diag_tickTime - _trackStart), _totalDoMove, _totalTeleport, _z, !isNull _vehicleObj && {alive _vehicleObj}] call ALiVE_fnc_dump;
                                        };
                                    };
                                };

                                // If not active then assign crew and spawn else move crew into aircraft
                                private _profile = [ALIVE_profileHandler, "getProfile",_profileID] call ALIVE_fnc_profileHandler;
                                private _crewID = [_aircraft,"crewID",""] call ALiVE_fnc_hashGet;
                                private _crewProfile = [ALIVE_profileHandler, "getProfile",_crewID] call ALIVE_fnc_profileHandler;

                                // When the aircraft profile is already active its crew must be live
                                // too, so an invalid group handle there means the crew profile is
                                // corrupt rather than merely unspawned. A crew profile that has been
                                // through an entity despawn could carry an Object in its "group" slot
                                // instead of a Group, and hashGet does no type checking, so it reached
                                // "_group addVehicle" below and threw "Type Object, expected Group",
                                // killing the activation. Treat it as crew-unavailable and take the
                                // abort path already used for a missing crew profile.
                                private _crewGroupBad = false;
                                if (!isNil "_crewProfile" && {[_profile,"active",false] call ALiVE_fnc_hashGet}) then {
                                    private _crewGroup = [_crewProfile,"group"] call ALiVE_fnc_hashGet;
                                    if (isNil "_crewGroup" || {!(_crewGroup isEqualType grpNull)} || {isNull _crewGroup}) then {
                                        _crewGroupBad = true;
                                        ["ATO %1 - crew profile %2 for aircraft %3 has an invalid group handle, aborting activation", _logic, _crewID, _profileID] call ALiVE_fnc_dumpR;
                                    };
                                };

                                if ((isNil "_crewProfile" || _crewGroupBad) && !([_vehicleClass] call _fnc_isDroneClass)) exitWith {
                                    // abort mission
                                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                                    // unlock runway
                                    if (_isPlane) then {
                                        [_logic, "unlockRunway", _airportID] call MAINCLASS;
                                    };

                                    // reset aircraft Op
                                    [_aircraft,"currentOp",""] call ALiVE_fnc_hashSet;
                                    [_assets,_profileID,_aircraft] call ALiVE_fnc_hashSet;
                                    [_logic, "assets" ,_assets] call MAINCLASS;
                                };

                                // DEBUG -------------------------------------------------------------------------------------
                                if(_debug) then {
                                    ["ATO %3 - Preparing aircraft (%1 - %2)", _profileID, _vehicleClass, _logic] call ALiVE_fnc_dump;
                                };
                                // DEBUG -------------------------------------------------------------------------------------

                                // DIAG-STRIP: a tasked drone that reaches the runway without an
                                // operator cannot fly, holds its slot, and every aircraft tasked
                                // behind it queues forever. The branch it takes through this case
                                // decides whether it is ever handed to createVehicleCrew, so log
                                // that decision rather than inferring it from the outcome.
                                if (_debug) then {
                                    ["ATO %1 DIAG-STRIP aircraftStart entry: class=%2 isDrone=%3 profileActive=%4 crewProfile=%5 crewGroupBad=%6",
                                        _logic,
                                        _vehicleClass,
                                        [_vehicleClass] call _fnc_isDroneClass,
                                        [_profile,"active",false] call ALiVE_fnc_hashGet,
                                        !isNil "_crewProfile",
                                        _crewGroupBad] call ALiVE_fnc_dump;
                                };

                                if !([_profile,"active"] call ALiVE_fnc_hashGet) then {

                                    // Assign crew if not UAV
                                    if !([_vehicleClass] call _fnc_isDroneClass) then {
                                        [_crewProfile,_profile] call ALIVE_fnc_createProfileVehicleAssignment;
                                    };

                                    // Spawn aircraft and if UAV add crew
                                    [_profile,"spawnType",["preventDespawn"]] call ALiVE_fnc_profileVehicle;
                                    if (_isOnCarrier) then {
                                        _taxiPosition = ASLtoATL _taxiPosition;
                                    };

                                    // ["ALIVE ATO %1 SPAWNING AIRCRAFT %2 AT POSITION %3", _logic, _profileID, _taxiPosition] call ALiVE_fnc_dump;
                                    [_profile,"position",_taxiPosition] call ALiVE_fnc_profileVehicle;
                                    [_profile,"despawnPosition", _taxiPosition] call ALiVE_fnc_profileVehicle;
                                    [_profile,"direction",_taxiDir] call ALiVE_fnc_profileVehicle;
                                    [_profile,"spawn"] call ALiVE_fnc_profileVehicle;
                                    if (_debug) then {
                                        ["ATO: Spawning"] call ALiVE_fnc_dump;
                                        _profile call ALIVE_fnc_inspectHash;
                                    };

                                } else {

                                    // Make sure crew are active
                                    if (!([_vehicleClass] call _fnc_isDroneClass) && {!([_crewProfile,"active"] call ALiVE_fnc_hashGet)} ) then {

                                        [_crewProfile,"spawn"] call ALiVE_fnc_profileEntity;
                                        if (_debug) then {
                                            ["ATO: Spawning crew (for aircraft already spawned)"] call ALiVE_fnc_dump;
                                            _crewProfile call ALIVE_fnc_inspectHash;
                                        };
                                    };

                                    // Get vehicle
                                    private _vehicleObj = [_profile,"vehicle"] call ALiVE_fnc_hashGet;

                                    if !([_vehicleClass] call _fnc_isDroneClass) then {
                                        // Move crew into aircraft
                                        private _group = [_crewProfile,"group"] call ALiVE_fnc_hashGet;

                                        // DEBUG -------------------------------------------------------------------------------------
                                        if(_debug) then {
                                            ["ATO %3 - MOVING CREW (%4) TO AIRCRAFT (%1 - %2)", _profileID, _vehicleClass, _logic, _group] call ALiVE_fnc_dump;
                                        };
                                        // DEBUG -------------------------------------------------------------------------------------

                                        // diag_log _group;
                                        _group addVehicle _vehicleObj;

                                        if (_isOnCarrier) then { // AI can't run to plane on carrier deck
                                            {
                                                _x moveInAny _vehicleObj;
                                            } forEach (units _group);

                                        } else {
                                            (units _group) orderGetIn true;
                                        };
                                    };

                                    // Move aircraft to start position
                                    if (_isPlane) then {
                                        // Move the plane to ilsTaxiIn position or nearest catapult on carrier
                                        // ["ALIVE ATO %1 MOVING AIRCRAFT %2 TO POSITION %3",_logic, _profileID, _taxiPosition] call ALiVE_fnc_dump;
                                        // _profile call ALIVE_fnc_inspectHash;
                                        if (surfaceIsWater _taxiPosition && _isOnCarrier) then {

                                            _vehicleObj setPosASL _taxiPosition; // might need to adjust for sea level changes?

                                            _vehicleObj setFuel 0;

                                        } else {
                                            // Occupancy guard: ilsTaxiIn resolves to ONE fixed engine point per airport and
                                            // this teleport had no occupancy check - two near-simultaneous taskings (an
                                            // unowned runway unlock in between) placed both planes on the same spot and they
                                            // detonated on contact. Keep the exact point when clear (single-tasking flow
                                            // unchanged); if a live airframe already sits there, relocate to a clear spot and
                                            // keep damage off until the frame has settled - never re-arm while overlapping.
                                            if (count _taxiPosition < 3) then { _taxiPosition pushBack 0; };
                                            private _requestedPos = +_taxiPosition;
                                            private _bbr = boundingBoxReal _vehicleObj;
                                            private _sep = ((((_bbr select 1) select 0) - ((_bbr select 0) select 0)) max (((_bbr select 1) select 1) - ((_bbr select 0) select 1))) + 6;
                                            private _fnc_taxiOccupied = {
                                                count ((nearestObjects [_taxiPosition, ["Air"], _sep]) select {alive _x && {!(_x isEqualTo _vehicleObj)}}) > 0
                                            };
                                            private _occupiedOffset = call _fnc_taxiOccupied;
                                            if (_occupiedOffset) then {
                                                // findAirSpawnPosition: 60s anti-race registry hands concurrent callers
                                                // distinct spots (same validator the fresh-spawn path uses)
                                                private _clearSpot = [_vehicleClass, _taxiPosition, 200, "auto"] call ALiVE_fnc_findAirSpawnPosition;
                                                if (count _clearSpot >= 2) then {
                                                    _taxiPosition = +(_clearSpot select 0);
                                                    // Ground the frame - hangar-tier spots carry the building's elevated origin z
                                                    _taxiPosition set [2, 0];
                                                    // Face the validated direction (nose-out of a hangar / along the apron),
                                                    // not the taxi heading - fit was only checked for the validated attitude
                                                    _taxiDir = _clearSpot select 1;
                                                };
                                                // The validator's hangar tier is registry-only (no live-vehicle sweep at the
                                                // bay centre), so re-verify the spot against live occupants; sidestep
                                                // perpendicular to the taxi direction until genuinely clear.
                                                if (call _fnc_taxiOccupied) then {
                                                    private _try = 1;
                                                    while {(call _fnc_taxiOccupied) && {_try <= 8}} do {
                                                        _taxiPosition = [(_requestedPos select 0) + (_sep * _try) * sin (_taxiDir + 90), (_requestedPos select 1) + (_sep * _try) * cos (_taxiDir + 90), 0];
                                                        _try = _try + 1;
                                                    };
                                                };
                                                _vehicleObj allowDamage false;
                                            };
                                            _vehicleObj setPos _taxiPosition;
                                            // ATO_HANGAR_DBG (DIAG-STRIP): outbound await-pilot placement decision - this path had no diag before
                                            diag_log format ["ATO_HANGAR_DBG OUTBOUND type=%1 reqPos=%2 finalPos=%3 occupiedOffset=%4", _vehicleClass, _requestedPos, _taxiPosition, _occupiedOffset];
                                            if (_occupiedOffset) then {
                                                _vehicleObj setVelocity [0,0,0];
                                                [_vehicleObj] spawn {
                                                    params ["_v"];
                                                    sleep 8;
                                                    if (isNull _v || {!alive _v}) exitWith {};
                                                    // Settled-height gate (mirrors _fnc_safeReposition): re-arm damage only once
                                                    // the frame sits grounded and clear - an elevated settle means it is still
                                                    // clipping and re-arming would resolve the overlap into a one-shot kill.
                                                    if (((getPosATL _v) select 2) > 3.5) then {
                                                        _v allowDamage false;
                                                        // ATO_HANGAR_DBG (DIAG-STRIP)
                                                        diag_log format ["ATO_HANGAR_DBG OUTBOUND settleClip type=%1 at=%2 -- kept invulnerable (no re-arm)", typeOf _v, getPosATL _v];
                                                    } else {
                                                        _v allowDamage true;
                                                    };
                                                };
                                            };
                                        };
                                        _vehicleObj setDir _taxiDir;
                                    };
                                };

                                if ([_vehicleClass] call _fnc_isDroneClass) then {
                                    private _vehicleObj = [_profile,"vehicle"] call ALiVE_fnc_hashGet;
                                    // Add crew
                                    // DIAG-STRIP: which crewing site fired for this drone, and whether it took.
                                    private _cbefore = count (crew _vehicleObj);
                                    createVehicleCrew _vehicleObj;
                                    if (_debug) then {
                                        ["ATO %1 DIAG-STRIP drone crewed at site 1: class=%2 crew %3 -> %4 driver=%5", _logic, typeOf _vehicleObj, _cbefore, count (crew _vehicleObj), (if (isNull (driver _vehicleObj)) then {"NONE"} else {typeOf (driver _vehicleObj)})] call ALiVE_fnc_dump;
                                    };
                                };

                                // Mark aircraft as ready
                                _aircraftReady = true;
                                [_aircraft,"ready",true] call ALiVE_fnc_hashSet;

                        } else {
                            // Airport is busy
                            if (_debug) then {
                                ["ATO %3 Airport busy %1 %2",_airportID,_airportBusy, _logic] call ALiVE_fnc_dump;
                            };
                        };

                    } else {
                        // if parked assign crew to vehicle if necessary, if at home move to ilsTaxiOut position at 300 feet, spawn aircraft at speed
                        if (_startPosition distance _currentPosition < 15) then {

                            private _isPlane = _vehicleClass iskindof "Plane" && (_isVTOL < 3);
                            private _profile = [ALIVE_profileHandler, "getProfile",_profileID] call ALIVE_fnc_profileHandler;

                            // If not active and not a UAV then launch, else go take off normally.
                            if !([_profile,"active"] call ALiVE_fnc_hashGet) then {

                                private _crewID = [_aircraft,"crewID",""] call ALiVE_fnc_hashGet;
                                private _crewProfile = [ALIVE_profileHandler, "getProfile",_crewID] call ALIVE_fnc_profileHandler;

                                if (isNil "_crewProfile" && !([_vehicleClass] call _fnc_isDroneClass)) exitWith {
                                    // abort mission
                                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                                    // unlock runway
                                    if (_isPlane) then {
                                        private _airportID = [_aircraft,"airportID",[_startPosition] call ALiVE_fnc_getNearestAirportID] call ALiVE_fnc_hashGet;
                                        [_logic, "unlockRunway", _airportID] call MAINCLASS;
                                    };

                                    // reset aircraft Op
                                    [_aircraft,"currentOp",""] call ALiVE_fnc_hashSet;
                                    [_assets,_profileID,_aircraft] call ALiVE_fnc_hashSet;
                                    [_logic, "assets", _assets] call MAINCLASS;
                                };

                                // Assign crew to aircraft
                                if !([_vehicleClass] call _fnc_isDroneClass) then {
                                    // Assign crew
                                    [_crewProfile,_profile] call ALIVE_fnc_createProfileVehicleAssignment;
                                };

                                private _taxiPosition = +_startPosition;
                                private _taxiDir = [_profile,"direction"] call ALiVE_fnc_hashGet;
                                _taxiPosition set [2,300];

                                if (_isPlane) then {
                                    // Set position relative to TaxiOff (but 300m up)
                                    private _airportID = [_aircraft,"airportID",[_startPosition] call ALiVE_fnc_getNearestAirportID] call ALiVE_fnc_hashGet;
                                    private _taxiPositions = [_airportID, "ilsTaxiOff",4,_startPosition] call ALiVE_fnc_getAirportTaxiPos;

                                    if (!isnil {_taxiPositions select 0}) then {

                                        _taxiPosition = [_taxiPositions select 0, _taxiPositions select 1, 300];
                                        _taxiDir = _taxiPosition getDir [_taxiPositions select 2, _taxiPositions select 3, _taxiPosition select 2];
                                    };
                                };

                                if (surfaceIsWater _taxiPosition) then {
                                    _taxiPosition set [2, 600];
                                };

                                // Concurrent-launch separation: ilsTaxiOff is ONE fixed point per airport and this
                                // flying-start branch has no runway-busy gate - two taskings in the same monitor
                                // pass would spawn both aircraft inside each other at the same [x,y,300] point.
                                // Sidestep laterally while another live airframe is near the spawn point (ground
                                // traffic 300m below is outside the 3D radius).
                                private _requestedPos = +_taxiPosition;
                                private _occupiedOffset = false;
                                private _launchTry = 1;
                                while {(count ((nearestObjects [_taxiPosition, ["Air"], 150]) select {alive _x})) > 0 && {_launchTry <= 8}} do {
                                    _occupiedOffset = true;
                                    _taxiPosition = [(_requestedPos select 0) + (200 * _launchTry) * sin (_taxiDir + 90), (_requestedPos select 1) + (200 * _launchTry) * cos (_taxiDir + 90), _requestedPos select 2];
                                    _launchTry = _launchTry + 1;
                                };
                                // ATO_HANGAR_DBG (DIAG-STRIP): outbound flying-start placement decision
                                diag_log format ["ATO_HANGAR_DBG OUTBOUND flyStart type=%1 reqPos=%2 finalPos=%3 occupiedOffset=%4", _vehicleClass, _requestedPos, _taxiPosition, _occupiedOffset];

                                // Set profile information
                                [_profile,"engineOn",true] call ALiVE_fnc_profileVehicle;
                                [_profile,"position",_taxiPosition] call ALiVE_fnc_profileVehicle;
                                [_profile,"despawnPosition", _taxiPosition] call ALiVE_fnc_profileVehicle;
                                [_profile,"direction",_taxiDir] call ALiVE_fnc_profileVehicle;
                                [_profile,"spawnType",["preventDespawn"]] call ALiVE_fnc_profileVehicle;

                                // Spawn aircraft
                                [_profile,"spawn"] call ALiVE_fnc_profileVehicle;
                                if (_debug) then {
                                    ["ATO: Spawning"] call ALiVE_fnc_dump;
                                    _profile call ALIVE_fnc_inspectHash;
                                };

                                if ([_vehicleClass] call _fnc_isDroneClass) then {
                                    private _vehicleObj = [_profile,"vehicle"] call ALiVE_fnc_hashGet;
                                    // Add crew
                                    // DIAG-STRIP: which crewing site fired for this drone, and whether it took.
                                    private _cbefore = count (crew _vehicleObj);
                                    createVehicleCrew _vehicleObj;
                                    if (_debug) then {
                                        ["ATO %1 DIAG-STRIP drone crewed at site 2: class=%2 crew %3 -> %4 driver=%5", _logic, typeOf _vehicleObj, _cbefore, count (crew _vehicleObj), (if (isNull (driver _vehicleObj)) then {"NONE"} else {typeOf (driver _vehicleObj)})] call ALiVE_fnc_dump;
                                    };
                                };

                                // Set Aircraft as ready for mission
                                _aircraftReady = true;
                                [_aircraft,"ready",true] call ALiVE_fnc_hashSet;
                            } else {

                                // If active, needs to takeoff properly? or move to height?
                                _eventData set [6,true];
                                [_event, "data", _eventData] call ALIVE_fnc_hashSet;

                            };
                        } else {
                            // else plane should be active with crew and flying and ready
                            _aircraftReady = true;
                            [_aircraft,"ready",true] call ALiVE_fnc_hashSet;
                        };
                    };

                } else {

                    // DEBUG -------------------------------------------------------------------------------------
                    if(_debug) then {
                        ["ATO %3 - aircraft (%1 - %2) is READY.", _profileID, _vehicleClass, _logic] call ALiVE_fnc_dump;
                    };
                    // DEBUG -------------------------------------------------------------------------------------
                    // Get vehicle to check for crew
                    private _vehProfile = [ALIVE_profileHandler, "getProfile",_profileID] call ALIVE_fnc_profileHandler;
                    private _vehicle = [_vehProfile,"vehicle"] call ALiVE_fnc_hashGet;

                    private _grp = group _vehicle;

                    //Radio Broadcast
                    if (_broadcastOnRadio) then {
                        private _callsign = groupID _grp;

                        if (_callsign != "") then {
                            private _message = format[localize "STR_ALIVE_ATO_START", _HQ, _callsign, _eventType, mapGridPosition _eventPosition];
                            // send a message to all side players from HQ
                            private _radioBroadcast = [objNull,_message,"side",_sideObject,false,false,false,true,_hqClass];
                            [_side,_radioBroadcast] call ALIVE_fnc_radioBroadcastToSide;
                        };
                    };

                    // Wait for driver or time expiration
                    if ( !(isNull (driver _vehicle)) || {time > (_eventTime + ((_eventDuration/3)*60))} || {_isOnCarrier}) then {

                        // Check driver is onboard if not put the crew in there
                        if (isNull (driver _vehicle) || {time > (_eventTime + ((_eventDuration/3)*60))} ) then {
                            if (_debug) then {
                                ["ATO %3 - aircraft (%1 - %2) is waiting on the pilot in group %4 with the units: %5.", _profileID, typeof _vehicle, _logic, _grp, units _grp] call ALiVE_fnc_dump;
                            };
                            {
                                _x moveInAny _vehicle;
                            } forEach (units _grp);
                            if ([_vehicle] call _fnc_isDroneClass) then {
                                // DIAG-STRIP: which crewing site fired for this drone, and whether it took.
                                private _cbefore = count (crew _vehicle);
                                createVehicleCrew _vehicle;
                                if (_debug) then {
                                    ["ATO %1 DIAG-STRIP drone crewed at site 3: class=%2 crew %3 -> %4 driver=%5", _logic, typeOf _vehicle, _cbefore, count (crew _vehicle), (if (isNull (driver _vehicle)) then {"NONE"} else {typeOf (driver _vehicle)})] call ALiVE_fnc_dump;
                                };
                            };
                        };

                        // Ok driver should be in vehicle now
                        if !(isNull (driver _vehicle)) then {

                            // DEBUG -------------------------------------------------------------------------------------
                            if(_debug) then {
                                ["ATO %3 - aircraft (%1 - %2) is LAUNCHING.", _profileID, _vehicleClass, _logic] call ALiVE_fnc_dump;
                            };
                            // DEBUG -------------------------------------------------------------------------------------

                            // Handle Carrier takeoff
                            If ( _isOnCarrier && _takeoff && _isPlane ) then {

                                // Get the catapult
                                private _catapult = [_aircraft,"catapult",[position _vehicle] call ALiVE_fnc_getNearestCatapult] call ALiVE_fnc_hashGet;
                                // Launch the aircraft
                                private _result = [_vehicle, _catapult] call ALiVE_fnc_catapultLaunch;

                                if (_debug) then {
                                    ["ATO %3 IS CATAPULT LAUNCHING AIRCRAFT %1 with result %2", _profileID, _result, _Logic] call ALiVE_fnc_dump;
                                };
                            };

                            // Make sure the group are not quiesced since last op
                            _grp enableAttack true;
                            {
                                _x enableAI "TARGET";
                                _x enableAI "AUTOTARGET";
                                _x setCombatMode _eventROE;
                            } forEach units _grp;

                            // Make sure targets are spawned
                            if (_debug) then {
                               ["ATO EVENT TARGETS: %1 (%2)", _eventTargets, typeName _eventTargets] call ALiVE_fnc_dump;
                            };
                            if !(isNil "_eventTargets") then {
                                {
                                    if (!(_x isEqualType objNull) || {isNull _x}) then {
                                        // _eventTargets mixes resolved target objects with profile-id
                                        // strings; resolve any non-object slot to its profile's object,
                                        // else objNull -- never leave a string here, so the downstream
                                        // isNull checks on _eventTargets (waypoint / CAS / validity) stay
                                        // type-safe.
                                        private _vehicle = objNull;
                                        private _profileID = _eventEnemyProfiles select _forEachIndex;
                                        private _targetProfile = [ALiVE_profileHandler, "getProfile", _profileID] call ALiVE_fnc_ProfileHandler;
                                        if !(isNil "_targetProfile") then {
                                            private _type = [_targetProfile,"type"] call ALiVE_fnc_hashGet;
                                            if (_type == "entity") then {
                                                _vehicle = [_targetProfile,"leader"] call ALiVE_fnc_hashGet;
                                            } else {
                                                _vehicle = [_targetProfile,"vehicle"] call ALiVE_fnc_hashGet;
                                            };
                                        };
                                        _eventTargets set [_forEachIndex, _vehicle];
                                    };
                                } forEach _eventTargets;
                            };

                            private _wpPosition = _eventPosition;

                            if (_eventType in ["CAS","DCA","SEAD","Strike"] && count _eventTargets > 0) then {
                                if !(isNull (_eventTargets select 0)) then {
                                    _wpPosition = _eventTargets select 0;
                                };
                            };

                            private _wp = _grp addWaypoint [_wpPosition,0,1,"ATO"];
                            _wp setWaypointSpeed _eventSpeed;
                            _wp setWaypointBehaviour "AWARE";
                            _wp setWaypointCombatMode _eventROE;

                            switch (_eventType) do {
                                case "Recce": {
                                    // Loiter waypoint
                                    _wp setWaypointType "LOITER";
                                    _wp setWaypointLoiterType "CIRCLE_L";
                                    _wp setWaypointLoiterRadius (_eventRange * 0.9);
                                    _wp setWaypointTimeout [_eventDuration,_eventDuration,_eventDuration];
                                    // _wp setWaypointCompletionRadius _eventRange;
                                };
                                case "CAS": {
                                    // SAD waypoint, if targets then DESTROY
                                    if ( count _eventTargets == 1 && !(isNull (_eventTargets select 0)) ) then {
                                        _wp waypointAttachVehicle (_eventTargets select 0);
                                        _wp setWaypointType "DESTROY";
                                        _grp reveal (_eventTargets select 0);
                                        (units _grp) doTarget (_eventTargets select 0);
                                        _wp setWaypointCompletionRadius _eventHeight;
                                    } else {
                                        _wp setWaypointType "SAD";
                                        _wp setWaypointPosition [_eventPosition, 0];
                                        _wp setWaypointTimeout [_eventDuration,_eventDuration,_eventDuration];

                                    };
                                };
                                case "OCA";
                                case "DCA";
                                case "SEAD";
                                case "Strike": {

                                    private _targetObject = _eventTargets select 0;

                                    // DESTROY
                                    if (_debug) then {
                                        ["ATO EVENT TARGET: %1 (%2)", _targetObject, typeName _targetObject] call ALiVE_fnc_dump;
                                    };

                                    _grp reveal _targetObject;

                                    if ( _targetObject iskindof "House") then {

                                        _wp setWaypointType "SAD";

                                        {
                                            if (_forEachIndex < 3) then {

                                                private _dummyGrp = createGroup SideLogic;
                                                private _dummy = _dummyGrp createUnit ["Logic", getPos _x, [], 0, "NONE"];

                                                //["ATO Created Dummy %1!",_dummy] call ALiVE_fnc_dumpR;

                                                private _lazor = "LaserTargetE";
                                                if (side _grp getFriend WEST > 0.6) then {_lazor = "LaserTargetW"} else {_lazor = "LaserTargetE"};

                                                private _laze = _lazor createVehicle getPos _x;
                                                _laze attachTo [_dummy,[-15 + (random 30),-15 + (random 30), 1]];

                                                //["ATO Created lazer %1 and attached it to %2!",_laze,_dummy] call ALiVE_fnc_dumpR;

                                                _grp reveal _laze;
                                                (units _grp) doTarget _laze;

                                                _targetObject setvariable [QGVAR(DUMMY),_dummy];
                                                _targetObject setvariable [QGVAR(LAZE),_laze];

                                                _targetObject addEventHandler["KILLED", {
                                                    params ["_unit","_killer"];

                                                    private _dummy = _unit getvariable [QGVAR(DUMMY),objNull];
                                                    private _laze = _unit getvariable [QGVAR(LAZE),objNull];
                                                    private _dummyGrp = group _dummy;

                                                    //["ATO Dummy object %1 has been destroyed by %2!",_unit,_killer] call ALiVE_fnc_dumpR;

                                                    deletevehicle _laze;
                                                    deletevehicle _dummy;
                                                    deletevehicle _unit;
                                                    deleteGroup _dummyGrp;
                                                }];

                                                //_wp setWaypointStatements ["true", "diag_log ['GroupLeader: ', this]; diag_log ['Units: ', thislist]"];
                                            };
                                        } forEach _eventTargets;
                                    } else {
                                        _wp waypointAttachVehicle _targetObject;
                                        _wp setWaypointType "DESTROY";
                                        (units _grp) doTarget _targetObject;
                                        _wp setWaypointCompletionRadius _eventHeight;
                                    };

                                };
                                default {
                                    // CAP
                                    _wp setWaypointType "LOITER";
                                    _wp setWaypointLoiterType "CIRCLE";
                                    _wp setWaypointLoiterRadius (_eventRange * 0.7);
                                    _wp setWaypointTimeout [_eventDuration,_eventDuration,_eventDuration];
                                    // Behaviour is deliberately left as the AWARE set with the
                                    // rest of the sortie waypoints. This used to force SAFE here,
                                    // which alone would be survivable, but combined with the hold
                                    // fire rules of arrival it produced a patrol that circled over
                                    // contacts and never engaged one. Do not put SAFE back.
                                    // _wp setWaypointCompletionRadius _eventRange;
                                };
                            };

                            _vehicle flyInHeight _eventHeight;

                            // If SEAD available add eventhandler to aircraft to detect any GBAD
                            if ("SEAD" in ([_logic,"types"] call MAINCLASS)) then {

                                _vehicle setVariable [QGVAR(logic),_logic];

                                // Check if anything fires a missile at the aircraft
                                private _missileCode = {
                                    private _vehicle = _this select 0;
                                    private _attacker = _this select 2;

                                    if ( (vehicle _attacker) iskindof "LandVehicle" ) then {
                                        [_vehicle getvariable QGVAR(logic),"registerThreat", _attacker] call MAINCLASS;
                                    };
                                };
                                _vehicle addEventHandler ["IncomingMissile",_missileCode];

                                // Check if anything hits the aircraft
                                private _hitCode = {
                                    private _vehicle = _this select 0;
                                    private _attacker = _this select 1;
                                    if ((position _vehicle) select 2 < 5) exitWith {};
                                    if ( (vehicle _attacker) iskindof "LandVehicle" ) then {
                                        [_vehicle getvariable QGVAR(logic),"registerThreat", _attacker] call MAINCLASS;
                                    };
                                };
                                _vehicle addEventHandler ["hit",_hitCode];
                            };

                            // dispatch event
                            private _logEvent = ['ATO_DESTINATION', [_eventPosition,_eventFaction,_side,_eventID],"air tasking orders"] call ALIVE_fnc_event;
                            [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                            // respond to player request
                            if(_playerRequested) then {
                                private _logEvent = ['ATO_RESPONSE', [_requestID,_playerID],"air tasking orders","REQUEST_ENROUTE"] call ALIVE_fnc_event;
                                [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;
                            };

                            [_event, "state", "aircraftTravel"] call ALIVE_fnc_hashSet;
                            [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                        } else {
                            // Waiting on pilot to be ready
                            // DEBUG -------------------------------------------------------------------------------------
                            if(_debug) then {
                                ["ATO %3 - Requested aircraft (%1 - %2) is STILL waiting on the pilot.", _profileID, typeof _vehicle, _logic] call ALiVE_fnc_dump;
                            };
                            // DEBUG -------------------------------------------------------------------------------------

                            // If we are still short of a driver and time is running out, can the request? Reroute?
                            if (time > (_eventTime + ((_eventDuration/3)*60))) then {
                                // DEBUG -------------------------------------------------------------------------------------
                                if(_debug) then {
                                    ["ATO %3 - Requested aircraft (%1 - %2) is OUT OF TIME waiting on the pilot.", _profileID, typeof _vehicle, _logic] call ALiVE_fnc_dump;
                                };
                                // DEBUG -------------------------------------------------------------------------------------

                                //Move back to original position (safe reposition - guards against hangar detonation)
                                private _startDir = [_aircraft,"startDir"] call ALiVE_fnc_hashGet;
                                if !(_isOnCarrier) then {
                                    [_vehicle, _startPosition, _startDir] call _fnc_safeReposition;
                                } else {
                                    _vehicle setDir _startDir;
                                    _vehicle setposATL [_startPosition select 0, _startPosition select 1, (_startPosition select 2) + 1];
                                };

                                // remove currentOp from vehicle
                                [_aircraft,"currentOp",""] call ALiVE_fnc_hashSet;
                                [_assets,_aircraftID,_aircraft] call ALiVE_fnc_hashSet;


                                // Unlock runway
                                if (_vehicleClass iskindof "Plane" && (_isVTOL < 3)) then {
                                    private _airportID = [_aircraft,"airportID",[_startPosition] call ALiVE_fnc_getNearestAirportID] call ALiVE_fnc_hashGet;
                                    [_logic, "unlockRunway", _airportID] call MAINCLASS;
                                };

                                // set state to event complete
                                if(_playerRequested) then {
                                    private _logEvent = ['ATO_RESPONSE', [_requestID,_playerID],"Logistics","REQUEST_LOST"] call ALIVE_fnc_event;
                                    [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;
                                };
                                [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                                [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                            };

                        };

                    } else {
                        // Waiting on pilot to be ready
                        // DEBUG -------------------------------------------------------------------------------------
                        if(_debug) then {
                            ["ATO %3 - Requested aircraft (%1 - %2) is waiting on the pilot.", _profileID, typeof _vehicle, _logic] call ALiVE_fnc_dump;
                        };
                        // DEBUG -------------------------------------------------------------------------------------
                    };
                };

                // Set aircraft state in case we are waiting for the pilot
                [_assets,_aircraftID,_aircraft] call ALiVE_fnc_hashSet;
            };

            case "aircraftTravel": {
                // wait for the aircraft to get on station
                private _eventPosition = _eventData select 5;
                private _aircraftID = _eventFriendlyProfiles select 0;
                private _aircraft = [_assets,_aircraftID] call ALiVE_fnc_hashGet;
                if (isNil "_aircraft") exitWith {
                  ["ATO - aircraftTravel has no valid _aircraft"] call ALiVE_fnc_dump;
                }; 
                private _startPosition = [_aircraft,"startPos"] call ALiVE_fnc_hashGet;
                private _vehicleClass = [_aircraft,"vehicleClass"] call ALiVE_fnc_hashGet;
                private _isVTOL = [_vehicleClass] call ALiVE_fnc_isVTOL;
                private _isOnCarrier = [_aircraft,"isOnCarrier",false] call ALiVE_fnc_hashGet;
                private _launched = [_aircraft,"launched", false] call ALiVE_fnc_hashGet;
                private _count = [_logic, "checkEvent", _event] call MAINCLASS;

                if(_count == 0) exitWith {
                    if (_broadcastOnRadio) then {
                        private _className = getText(configFile >> "CfgVehicles" >> _vehicleClass >> "displayName");
                        private _message = format[localize "STR_ALIVE_ATO_AIRCRAFT_LOST", _HQ, _className, _eventType];
                        // send a message to all side players from HQ
                        private _radioBroadcast = [objNull,_message,"side",_sideObject,false,false,false,true,_hqClass];
                        [_side,_radioBroadcast] call ALIVE_fnc_radioBroadcastToSide;
                    };

                    // Unlock runway
                    private _airportID = [_aircraft,"airportID",[_startPosition] call ALiVE_fnc_getNearestAirportID] call ALiVE_fnc_hashGet;
                    [_logic, "unlockRunway", _airportID] call MAINCLASS;

                    // set state to event complete
                    if(_playerRequested) then {
                        private _logEvent = ['ATO_RESPONSE', [_requestID,_playerID],"Logistics","REQUEST_LOST"] call ALIVE_fnc_event;
                        [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;
                    };
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                private _profileID = [_aircraft,"profileID"] call ALiVE_fnc_hashGet;
                private _profile = [ALIVE_profileHandler, "getProfile",_profileID] call ALIVE_fnc_profileHandler;
                private _vehicle = [_profile,"vehicle"] call ALiVE_fnc_hashGet;

                // Reset aircraft launch ready state
                [_aircraft,"ready",false] call ALiVE_fnc_hashSet;
                [_aircraft,"currentPos", position _vehicle] call ALiVE_fnc_hashSet;

                // If aircraft is taking too much time, launch it
                if (time > (_eventTime + ((_eventDuration/2)*60)) ) then {

                    // Check to see if it has taken off, if hasn't launch it
                    if ((getposATL _vehicle) select 2 < 10  || (_isOnCarrier && ((getposASL _vehicle) select 2 < 30))) then {
                        // Launch
                        _vehicle engineOn true;
                        _vehicle setposATL [(getposATL _vehicle) select 0, (getposATL _vehicle) select 1, 600];
                        private _direction = direction _vehicle;
                        private _speed = 200;
                        _vehicle setVelocity [(sin _direction*_speed), (cos _direction*_speed),0.1];
                    };
                };

                // If aircraft is airborne, unlock runway once
                if ( (getposATL _vehicle) select 2 > 50 && (getposASL _vehicle) select 2 > 50 && !_launched) then {
                    // Unlock runway now
                    if (_vehicleClass iskindof "Plane" && (_isVTOL < 3) ) then {
                        private _airportID = [_aircraft,"airportID",[_startPosition] call ALiVE_fnc_getNearestAirportID] call ALiVE_fnc_hashGet;
                        [_logic, "unlockRunway", _airportID] call MAINCLASS;
                    };
                    [_aircraft,"launched", true] call ALiVE_fnc_hashSet;
                };

                if (_debug) then {
                    ["ATO %3: aircraft %4 distance %1 (%2)", (_eventPosition distance2D _vehicle),(_eventRange * 1.2), _logic, _profileID] call ALiVE_fnc_dump;
                };

                if ( (_eventPosition distance2D _vehicle) < (_eventRange * 1.2) && (getposATL _vehicle) select 2 > 50 && (getposASL _vehicle) select 2 > 50 ) then {

                    [_event, "state", "aircraftExecuteWait"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                    // Aircraft is on station
                    // DEBUG -------------------------------------------------------------------------------------
                    if(_debug) then {
                        ["ATO %3 - Requested aircraft (%1 - %2) is on station", _profileID, typeof _vehicle, _logic] call ALiVE_fnc_dump;
                    };
                    // DEBUG -------------------------------------------------------------------------------------

                    // Radio Broadcast
                    if (_broadcastOnRadio) then {
                        private _callsign = groupID (group _vehicle);
                        private _message = format[localize "STR_ALIVE_ATO_ON_STATION", _HQ, _callsign, mapGridPosition _vehicle, _eventType];
                        // send a message to all side players from HQ
                        private _radioBroadcast = [objNull,_message,"side",_sideObject,false,false,false,true,_hqClass];
                        [_side,_radioBroadcast] call ALIVE_fnc_radioBroadcastToSide;
                    };

                    // respond to player request
                    if(_playerRequested) then {
                        private  _logEvent = ['ATO_RESPONSE', [_requestID,_playerID],"Logistics","REQUEST_ARRIVED"] call ALIVE_fnc_event;
                        [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;
                    };

                    // Reset launched state
                    [_aircraft,"launched", false] call ALiVE_fnc_hashSet;
                };
            };

            case "aircraftExecuteWait": {
                // wait for waypoint to be completed or bingo fuel/weapons or destroyed
                private _eventPosition = _eventData select 5;
                private _aircraftID = _eventFriendlyProfiles select 0;
                private _aircraft = [_assets,_aircraftID] call ALiVE_fnc_hashGet;
                if (isNil "_aircraft") exitWith {
                	 ["ATO - aircraftExecuteWait has no valid _aircraft"] call ALiVE_fnc_dump;
                };
                private _vehicleClass = [_aircraft,"vehicleClass"] call ALiVE_fnc_hashGet;

                private _count = [_logic, "checkEvent", _event] call MAINCLASS;
                if(_count == 0) exitWith {

                    //Radio Broadcast
                    if (_broadcastOnRadio) then {
                        private _className = getText(configFile >> "CfgVehicles" >> _vehicleClass >> "displayName");
                        private _message = format[localize "STR_ALIVE_ATO_AIRCRAFT_LOST", _HQ, _className, _eventType];
                        // send a message to all side players from HQ
                        private _radioBroadcast = [objNull,_message,"side",_sideObject,false,false,false,true,_hqClass];
                        [_side,_radioBroadcast] call ALIVE_fnc_radioBroadcastToSide;
                    };

                    if(_playerRequested) then {
                        private _logEvent = ['ATO_RESPONSE', [_requestID,_playerID],"ATO","REQUEST_LOST"] call ALIVE_fnc_event;
                        [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;
                    };
                    // set state to event complete
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                private _profileID = [_aircraft,"profileID"] call ALiVE_fnc_hashGet;
                private _missionComplete = false;
                private _healthIssue = false;
                private _profile = [ALIVE_profileHandler, "getProfile",_profileID] call ALIVE_fnc_profileHandler;
                private _vehicle = [_profile,"vehicle"] call ALiVE_fnc_hashGet;

                [_aircraft,"currentPos", position _vehicle] call ALiVE_fnc_hashSet;

                private _radioChoice = "STR_ALIVE_ATO_RETURN";

                // Check to see if unit still has waypoints
                if (count waypoints (group _vehicle) > 0) then {
                    // Check waypoint
                    if (time > (_eventTime + (_eventDuration*60)) ) then {
                        _missionComplete = true;
                    };
                } else {
                    if (_debug) then {
                        ["ATO %3 - Aircraft (%1 - %2) has no more waypoints.", _profileID, typeof _vehicle, _logic] call ALiVE_fnc_dump;
                    };
                    _missionComplete = true;
                };

                // Check to see if target is still there
                if (count _eventTargets > 0 && isNull (_eventTargets select 0)) then {
                    if (_debug) then {
                        ["ATO %3 - Aircraft (%1 - %2) has no valid target.", _profileID, typeof _vehicle, _logic] call ALiVE_fnc_dump;
                    };
                    _missionComplete = true;
                };

                // Check damage
                private _damage = damage _vehicle;
                if (_damage > 0.5) then {
                    _healthIssue = true;
                    _radioChoice = "STR_ALIVE_ATO_RETURN_DAMAGE";
                };

                // Check fuel
                private _fuel = fuel _vehicle;
                if (_fuel < 0.2) then {
                    _healthIssue = true;
                    _radioChoice = "STR_ALIVE_ATO_RETURN_FUEL";
                };

                // Check Weapons
                // Calculate % of ammo
                private _ammoArray = _vehicle call ALiVE_fnc_vehicleGetAmmo;
                private _ammo = 0;
                if (count _ammoArray > 0) then {
                    private _avail = 0;
                    {
                        if ((_x select 2) > 0) then {
                            _avail = _avail + ((_x select 1)/(_x select 2));
                        };
                    } forEach _ammoArray;
                    _ammo = _avail / count _ammoArray;
                };
                if (_ammo < 0.1) then {
                    _healthIssue = true;
                    _radioChoice = "STR_ALIVE_ATO_RETURN_AMMO";
                };

                // Check targets
                if (count _eventEnemyProfiles > 0 && _missionComplete && !_healthIssue) then {
                    // Set another waypoint?
                };

                // If waypoint has been completed
                if(_missionComplete || _healthIssue) then {

                    // return home
                    private _eventStateData set [0, _healthIssue];
                    private _eventStateData set [1, _missionComplete];
                    [_event, "stateData", _eventStateData] call ALIVE_fnc_hashSet;

                    // Radio broadcast
                    if (_broadcastOnRadio) then {
                        if !("ItemRadio" in (assignedItems driver _vehicle)) then {
                            driver _vehicle addItem "ItemRadio";
                        };
                        private _callsign = groupID (group _vehicle);
                        private _message = format[localize _radioChoice, _eventType];
                        // send a message to all side players from HQ
                        private _radioBroadcast = [driver _vehicle,_message,"side",_sideObject,true];
                        [_side,_radioBroadcast] call ALIVE_fnc_radioBroadcastToSide;
                    };

                    [_event, "state", "aircraftReturn"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                };
            };

            case "aircraftReturn": {
                private _aircraftID = _eventFriendlyProfiles select 0;
                private _aircraft = [_assets,_aircraftID] call ALiVE_fnc_hashGet;
                if (isNil "_aircraft") exitWith {
                	 ["ATO - aircraftReturn has no valid _aircraft"] call ALiVE_fnc_dump;
                };
                private _vehicleClass = [_aircraft,"vehicleClass"] call ALiVE_fnc_hashGet;
                private _count = [_logic, "checkEvent", _event] call MAINCLASS;
                if(_count == 0) exitWith {

                    // Radio Broadcast
                    if (_broadcastOnRadio) then {
                        private _className = getText(configFile >> "CfgVehicles" >> _vehicleClass >> "displayName");
                        private _message = format[localize "STR_ALIVE_ATO_AIRCRAFT_LOST", _HQ, _className, _eventType];
                        // send a message to all side players from HQ
                        private _radioBroadcast = [objNull,_message,"side",_sideObject,false,false,false,true,_hqClass];
                        [_side,_radioBroadcast] call ALIVE_fnc_radioBroadcastToSide;
                    };

                    // set state to event complete
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                private _aircraftID = _eventFriendlyProfiles select 0;
                private _aircraft = [_assets,_aircraftID] call ALiVE_fnc_hashGet;
                private _eventPosition = _eventData select 5;
                private _startPosition = [_aircraft,"startPos"] call ALiVE_fnc_hashGet;

                // Set waypoint to land back at starting positions

                // Assign waypoints to the aircraft crew
                private _profileID = [_aircraft,"profileID"] call ALiVE_fnc_hashGet;
                private _profile = [ALIVE_profileHandler, "getProfile",_profileID] call ALIVE_fnc_profileHandler;
                private _vehicle = [_profile,"vehicle"] call ALiVE_fnc_hashGet;

                private _grp = group _vehicle;

                 while {(count (waypoints _grp)) > 0} do
                 {
                    deleteWaypoint ((waypoints _grp) select 0);
                 };

                private _wp = _grp addWaypoint [_startPosition,400];
                _wp setWaypointBehaviour "CARELESS";
                _wp setWaypointCombatMode "BLUE";
                _wp setWaypointStatements ["true","if (alive this) then {vehicle driver this setVariable ['ALIVE_MIL_ATO_RTB',true]; deleteWaypoint [group this, currentWaypoint (group this)];}"];

                // Quiesce group
                _grp enableAttack false;
                {
                    _x disableAI "TARGET";
                    _x disableAI "AUTOTARGET";
                    _x setCombatMode "BLUE";
                } forEach units _grp;

                // dispatch event
                _logEvent = ['ATO_RETURN', [_startPosition,_eventFaction,_side,_eventID],"air tasking orders"] call ALIVE_fnc_event;
                [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;

                // respond to player request
                if(_playerRequested) then {
                    _logEvent = ['ATO_RESPONSE', [_requestID,_playerID],"air tasking orders","REQUEST_RETURN"] call ALIVE_fnc_event;
                    [ALIVE_eventLog, "addEvent",_logEvent] call ALIVE_fnc_eventLog;
                };

                // set state to wait for return of transports
                [_event, "state", "aircraftReturnWait"] call ALIVE_fnc_hashSet;
                [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
            };

            case "aircraftReturnWait": {

                private _aircraftID = _eventFriendlyProfiles select 0;
                private _aircraft = [_assets,_aircraftID] call ALiVE_fnc_hashGet;
                if (isNil "_aircraft") exitWith {
                	 ["ATO - aircraftReturnWait has no valid _aircraft"] call ALiVE_fnc_dump;
                }; 
                private _eventPosition = _eventData select 5;
                private _startPosition = [_aircraft,"startPos"] call ALiVE_fnc_hashGet;
                private _vehicleClass = [_aircraft,"vehicleClass"] call ALiVE_fnc_hashGet;
                private _isVTOL = [_vehicleClass] call ALiVE_fnc_isVTOL;
                private _isPlane = _vehicleClass iskindof "Plane" && (_isVTOL < 3);

                private _count = [_logic, "checkEvent", _event] call MAINCLASS;
                if(_count == 0) exitWith {

                    // Radio Broadcast
                    if (_broadcastOnRadio) then {
                        private _className = getText(configFile >> "CfgVehicles" >> _vehicleClass >> "displayName");
                        private _message = format[localize "STR_ALIVE_ATO_AIRCRAFT_LOST", _HQ, _className, _eventType];
                        // send a message to all side players from HQ
                        private _radioBroadcast = [objNull,_message,"side",_sideObject,false,false,false,true,_hqClass];
                        [_side,_radioBroadcast] call ALIVE_fnc_radioBroadcastToSide;
                    };

                    // Unlock runway
                    if (_isPlane ) then {
                        private _airportID = [_aircraft,"airportID",[_startPosition] call ALiVE_fnc_getNearestAirportID] call ALiVE_fnc_hashGet;
                        [_logic, "unlockRunway", _airportID] call MAINCLASS;
                    };

                    // set state to event complete
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                private _isOnCarrier = [_aircraft,"isOnCarrier"] call ALiVE_fnc_hashGet;
                private _profile = [ALIVE_profileHandler, "getProfile",_aircraftID] call ALIVE_fnc_profileHandler;
                private _vehicle = [_profile,"vehicle"] call ALiVE_fnc_hashGet;
                private _grp = group _vehicle;

                [_aircraft,"currentPos", position _vehicle] call ALiVE_fnc_hashSet;

                // Check to see if aircraft is in vicinty of starting position
                if(_vehicle getVariable [QGVAR(RTB),false]) then {

                    // Check to see there are any players around
                    private _playersInRange = [_startPosition, 1000] call ALiVE_fnc_anyPlayersInRange;

                    // If players are around then execute landing
                    if (_playersInRange > 0) then {

                        if (_isPlane) then {

                            private _airportID = [_aircraft,"airportID",[_startPosition] call ALiVE_fnc_getNearestAirportID] call ALiVE_fnc_hashGet;
                            private _airportBusy = false;

                            // if plane check to see if runway is busy, wait
                            _airportBusy = [_airports, _airportID] call ALiVE_fnc_hashGet;

                            // DEBUG -------------------------------------------------------------------------------------
                            if(_debug) then {
                                ["ATO %3 - Aircraft (%1 - %2) is looking to land at %4 (%5) Plane: %6", _vehicle, typeof _vehicle, _logic, _airportID, _airportBusy, _vehicleClass iskindof "Plane"] call ALiVE_fnc_dump;
                            };
                            // DEBUG -------------------------------------------------------------------------------------

                            if !(_airportBusy) then {

                                // Mark airport as busy for landing, and remember THIS landing took the lock
                                // (the no-players quick-land path never locks - its completion must not unlock)
                                [_airports, _airportID, true] call ALiVE_fnc_hashSet;
                                [_logic,"runways",_airports] call MAINCLASS;
                                _vehicle setVariable [QGVAR(LANDINGLOCK), true];

                                if (_airportID < 100) then {
                                    _vehicle landAt _airportID;
                                } else {
                                    private _dynamicAirport =  nearestObject [_startPosition, "AirportBase"];
                                    _vehicle landAt _dynamicAirport;
                                };

                                // DEBUG -------------------------------------------------------------------------------------
                                if(_debug) then {
                                    ["ATO %3 - Aircraft (%1 - %2) is landing at %4", _vehicle, typeof _vehicle, _logic, _airportID] call ALiVE_fnc_dump;
                                };
                                // DEBUG -------------------------------------------------------------------------------------

                                // add eventhandler for aircraft landing
                                _vehicle addEventHandler ["LandedStopped", {(_this select 0) setVariable [QGVAR(LANDED),true]}];
                                _vehicle addEventHandler ["LandedTouchDown", {(_this select 0) setVariable [QGVAR(LANDEDTOUCHDOWN),time]}];

                                // set state to wait for return of transports
                                [_event, "state", "aircraftLanding"] call ALIVE_fnc_hashSet;
                                [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                            };

                        } else {

                            private _helipad = nearestObject [[_aircraft,"helipad"] call ALiVE_fnc_hashGet, "HeliH"];

                            // Helicopter or VTOL?
                            if !(_isVTOL < 3) then {

                                _vehicle land "LAND";
                                _vehicle landat _helipad;
                                 doGetOut (driver _vehicle);

                            } else {

                                // Tell VTOL to GETOUT at position
                                private _wp = _grp addWaypoint [_startPosition, 400];
                                _wp setWaypointBehaviour "CARELESS";
                                _wp setWaypointCombatMode "BLUE";
                                _wp setWaypointType "TR UNLOAD";
                                doGetOut (driver _vehicle);

                            };

                            // DEBUG -------------------------------------------------------------------------------------
                            if(_debug) then {
                                ["ATO %3 - Aircraft (%1 - %2) is landing at %4", _vehicle, typeof _vehicle, _logic, _helipad] call ALiVE_fnc_dump;
                            };
                            // DEBUG -------------------------------------------------------------------------------------

                            // set state to wait for return of transports
                            [_event, "state", "aircraftLanding"] call ALIVE_fnc_hashSet;
                            [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                        };

                    } else {

                        _vehicle setVariable [QGVAR(LANDED),true];
                        // set state to wait for return of transports
                        [_event, "state", "aircraftLanding"] call ALIVE_fnc_hashSet;
                        [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                    };

                    _vehicle setVariable [QGVAR(LANDING),time];

                };
            };

            case "aircraftLanding": {

                private _aircraftID = _eventFriendlyProfiles select 0;
                private _aircraft = [_assets,_aircraftID] call ALiVE_fnc_hashGet;
                if (isNil "_aircraft") exitWith {
                	 ["ATO - aircraftReturnWait has no valid _aircraft"] call ALiVE_fnc_dump;
                }; 
                private _isOnCarrier = [_aircraft,"isOnCarrier"] call ALiVE_fnc_hashGet;
                private _startPosition = [_aircraft,"startPos"] call ALiVE_fnc_hashGet;
                private _vehicleClass = [_aircraft,"vehicleClass"] call ALiVE_fnc_hashGet;
                private _isVTOL = [_vehicleClass] call ALiVE_fnc_isVTOL;
                private _isPlane = _vehicleClass iskindof "Plane" && (_isVTOL < 3);
                private _count = [_logic, "checkEvent", _event] call MAINCLASS;

                if(_count == 0) exitWith {

                    // Radio Broadcast
                    if (_broadcastOnRadio) then {
                        private _className = getText(configFile >> "CfgVehicles" >> _vehicleClass >> "displayName");
                        private _message = format[localize "STR_ALIVE_ATO_AIRCRAFT_LOST", _HQ, _className, _eventType];
                        // send a message to all side players from HQ
                        private _radioBroadcast = [objNull,_message,"side",_sideObject,false,false,false,true,_hqClass];
                        [_side,_radioBroadcast] call ALIVE_fnc_radioBroadcastToSide;
                    };

                    // Unlock runway
                    private _airportID = [_aircraft,"airportID",[_startPosition] call ALiVE_fnc_getNearestAirportID] call ALiVE_fnc_hashGet;
                    [_logic, "unlockRunway", _airportID] call MAINCLASS;

                    // set state to event complete
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;
                };

                private _profile = [ALIVE_profileHandler, "getProfile",_aircraftID] call ALIVE_fnc_profileHandler;
                private _vehicle = [_profile,"vehicle"] call ALiVE_fnc_hashGet;
                private _grp = group _vehicle;

                private _landingTime = _vehicle getVariable [QGVAR(LANDING), time];

                private _landed = _vehicle getVariable [QGVAR(LANDED),false];
                private _touchDown = _vehicle getVariable [QGVAR(LANDEDTOUCHDOWN),0];

                // Tailhook for carrier landings
                if (_isOnCarrier && _isPlane && !_landed) then {
                    [_vehicle] spawn {
                        private _vehicle = _this select 0;
                        [_vehicle] call BIS_fnc_aircraftTailhook;
                    };
                };

                // manage taxi for planes
                if (_touchDown > 0) then {
                    if ( time > (_touchDown + 180) || (_isOnCarrier && time > (_touchDown + 25)) )  then {
                        _landed = true;
                    };
                };

                if ( _vehicle iskindof "Helicopter" && ( (getposATL _vehicle) select 2 < 2 || (_isOnCarrier && (getposASL _vehicle) select 2 < 25) ) ) then {
                    _landed = true;
                };

                // Check to see if aircraft is in vicinty of starting position
                if(_landed || time > (_landingTime + 300) ) then {

                    // DEBUG -------------------------------------------------------------------------------------
                    if(_debug) then {
                        ["ATO %3 - Aircraft (%1 - %2) has landed at time: %4", _vehicle, typeof _vehicle, _logic, _touchDown] call ALiVE_fnc_dump;
                    };
                    // DEBUG -------------------------------------------------------------------------------------

                    // Radio Broadcast
                    if (_broadcastOnRadio) then {
                        private _callsign = groupID _grp;
                        private _message = format[localize "STR_ALIVE_ATO_MISSION_COMPLETE", _HQ, _callsign, _eventType];
                        // send a message to all side players from HQ
                        private _radioBroadcast = [objNull,_message,"side",_sideObject,false,false,false,true,_hqClass];
                        [_side,_radioBroadcast] call ALIVE_fnc_radioBroadcastToSide;
                    };

                    _vehicle setVariable [QGVAR(LANDED),false];

                    // Turn off engine
                    _vehicle engineOn false;

                    // Once landed and either on helo position or close to taxi off position then disembark crewzz
                    _vehicle setVelocity [0,0,0];

                    // Set position if plane to taxi position
                    if (_vehicle iskindOf "Plane") then {
                        private _airportID = [_aircraft,"airportID",[_startPosition] call ALiVE_fnc_getNearestAirportID] call ALiVE_fnc_hashGet;
                        private _taxiPositions = [_airportID, "ilsTaxiIn",0,_startPosition] call ALiVE_fnc_getAirportTaxiPos;

                        // With no ILS data for this airport the list comes back empty and the
                        // count-2 / count-1 indices below go negative, throwing on arrival.
                        // Fall back to the aircraft's own parking spot.
                        private _taxiPosition = +_startPosition;
                        if (count _taxiPositions >= 2) then {
                            _taxiPosition = [_taxiPositions select (count _taxiPositions -2), _taxiPositions select (count _taxiPositions -1), 0];
                        };
                        if (_isOnCarrier) then {
                            _vehicle setposATL [_startPosition select 0, _startPosition select 1, (_startPosition select 2) + 1];
                        } else {
                            _vehicle setposATL _taxiPosition;
                        };
                    };

                     while {(count (waypoints _grp)) > 0} do
                     {
                        deleteWaypoint ((waypoints _grp) select 0);
                     };

                    if !([_vehicle] call _fnc_isDroneClass) then {
                        private _leader = leader _grp;

                        // Crew should be unassigned from aircraft
                        _grp leaveVehicle _vehicle;


                        				private ["_crewPos","_thispos"];
                                private _atoPosition = position _logic;
                                private _crewpos = +_startPosition;
                                _crewPos = + _atoPosition;
                        				
                        				
                                 // if pilotbuilding is defined
                                 private _pilotbuilding = [_logic, "pilotbuilding"] call MAINCLASS;
                                 

                                 if (count _pilotbuilding >0) then {
                                 	
	                                  // DEBUG -------------------------------------------------------------------------------------
												            if(_debug) then {
											                  ["ATO - Pilot Building Class: %1",_pilotbuilding] call ALiVE_fnc_dump;
											                  ["ATO - ATO Module Position: %1", _atoPosition] call ALiVE_fnc_dump;
											              };
	                                  // DEBUG ------------------------------------------------------------------------------------- 
                                  
                                    private _vnbuildings = nearestObjects [_atoPosition, [_pilotbuilding], 50];
                                    
	                                    // DEBUG -------------------------------------------------------------------------------------
														          if(_debug) then {
												                ["ATO - Count Nearby Buildings: %1", count _vnbuildings] call ALiVE_fnc_dump;
												              };
		                                  // DEBUG ------------------------------------------------------------------------------------- 

                                    if (count _vnbuildings > 0) then {
                                    	
	                                    // DEBUG -------------------------------------------------------------------------------------
														          if(_debug) then {
												                ["ATO - Nearby Buildings: %1", _vnbuildings] call ALiVE_fnc_dump;
												              };
		                                  // DEBUG ------------------------------------------------------------------------------------- 
                                    	
	                                     private _thisbuilding = selectRandom _vnbuildings;
	                                     _thispos = [_thisbuilding,1] call ALIVE_fnc_findIndoorHousePositions;
	                                     if (count _thispos > 0) then {
	                                      _crewPos = selectRandom _thispos;
			                                    // DEBUG -------------------------------------------------------------------------------------
														              if(_debug) then {
			                                      	["ATO - Building Selected: %1", _thispos] call ALiVE_fnc_dump;
			                                    }; 
			                                    // DEBUG ------------------------------------------------------------------------------------- 
		                                   };   
                                    };


                                 } else {
                                 	 // Only override the crew position when there is actually somewhere indoor to
                                 	 // put them. selectRandom [] returns nil, and assigning nil here would delete
                                 	 // _crewPos (the recovery guard below rebinds it in the wrong scope), leaving
                                 	 // it undefined when the crew is added. No indoor spot: keep the module default.
                                 	 private _indoor = [_startPosition, 100] call ALIVE_fnc_findIndoorHousePositions;
                                 	 if (count _indoor > 0) then { _crewPos = selectRandom _indoor };
                                 };

                                 if (isNil "_crewPos") then {
                                     _crewPos = _atoPosition getpos [10 + (random 15), random 360];
										  	            // DEBUG -------------------------------------------------------------------------------------
											            	if(_debug) then {
											             		["ATO - No Buildings Nearby With House Positions. Set Random Crew Position: %1", _crewPos] call ALiVE_fnc_dump;
											            	};
											              // DEBUG -------------------------------------------------------------------------------------
                                 };

                        // tell crew to move to nearest building
                        if (_isOnCarrier) then {
                                private _bridge = (_startPosition nearObjects ["Land_Carrier_01_island_02_F",700]) select 0;
                                _crewPos = ASLtoATL (_bridge modelToWorld [-2.43359,1.98047,0]);
                                {
                                    _x setposATL _crewpos;
                                } forEach units _grp;
                        } else {

                            (group _leader) move _crewPos;
                        };

                        // Set crew profile to move to building.
                        private _crewID = [_aircraft,"crewID",""] call ALiVE_fnc_hashGet;
                        private _crewProfile = [ALIVE_profileHandler, "getProfile",_crewID] call ALIVE_fnc_profileHandler;
                        if !(isNil "_crewProfile") then {
                            private _profileWaypoint = [_crewPos, 2] call ALIVE_fnc_createProfileWaypoint;
                            [_crewProfile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
                            [_crewProfile,"spawnType",[]] call ALiVE_fnc_profileEntity;
                        };
                    } else {
                        {
                            _vehicle deleteVehicleCrew _x;
                        } forEach (crew _vehicle);
                    };

                    // Turn off engine
                    _vehicle engineOn false;

                    //Move back to original position (safe reposition - guards against hangar detonation)
                    private _startDir = [_aircraft,"startDir"] call ALiVE_fnc_hashGet;
                    if !(_isOnCarrier) then {
                        [_vehicle, [_startPosition select 0, _startPosition select 1, (_startPosition select 2) + 1], _startDir] call _fnc_safeReposition;
                    } else {
                        _vehicle setDir _startDir;
                    };

                    // Airport is no longer busy - but only release the lock THIS landing took.
                    // The no-players quick-land path (LANDED set without locking) used to fall
                    // through here and unconditionally unlock, releasing a lock still held by an
                    // OUTBOUND plane waiting at ilsTaxiIn for its pilot - the next tasking then
                    // passed the busy gate and teleported a second airframe onto it.
                    if (_isPlane && {_vehicle getVariable [QGVAR(LANDINGLOCK), false]}) then {
                        private _airportID = [_aircraft,"airportID",[_startPosition] call ALiVE_fnc_getNearestAirportID] call ALiVE_fnc_hashGet;
                        // Mark airport as not busy
                        [_logic, "unlockRunway", _airportID] call MAINCLASS;
                    };
                    _vehicle setVariable [QGVAR(LANDINGLOCK), false];

                    // Reset landing values
                    _vehicle setVariable [QGVAR(LANDED),false];
                    _vehicle setVariable [QGVAR(LANDEDTOUCHDOWN),0];

                    // Refuel, rearm and fix vehicle
                    _vehicle setDamage 0;
                    _vehicle setFuel 1;

                    // turn off prevent despawn
                    [_profile,"spawnType",[]] call ALiVE_fnc_profileVehicle;

                    // remove currentOp from vehicle - place aircraft under maintenance
                    [_aircraft,"maintenance",time] call ALiVE_fnc_hashSet;
                    [_aircraft,"currentOp",""] call ALiVE_fnc_hashSet;
                    [_assets,_aircraftID,_aircraft] call ALiVE_fnc_hashSet;

                    // set state to event complete
                    [_event, "state", "eventComplete"] call ALIVE_fnc_hashSet;
                    [_eventQueue, _eventID, _event] call ALIVE_fnc_hashSet;

                };
            };

            case "eventComplete": {

                if (count _eventFriendlyProfiles > 0) then {
                    private _aircraftID = _eventFriendlyProfiles select 0;
                    private _aircraft = [_assets,_aircraftID] call ALiVE_fnc_hashGet;
                    if (isNil "_aircraft") exitWith {
                	    ["ATO - eventComplete has no valid _aircraft"] call ALiVE_fnc_dump;
                    }; 
                    //reset if rerouted
                    [_aircraft,"reroute",false] call ALiVE_fnc_hashSet;
                    [_assets,_aircraftID,_aircraft] call ALiVE_fnc_hashSet;
                };

                // despawn any existing targets
                if (count _eventEnemyProfiles > 0) then {
                    {
                        private _targetProfile = [ALiVE_profileHandler, "getProfile", _x] call ALiVE_fnc_ProfileHandler;
                        if !(isNil "_targetProfile") then {
                            [_targetProfile,"spawnType",[]] call ALiVE_fnc_hashSet;
                        };
                    } forEach _eventEnemyProfiles;
                };

                // Register finish time of last CAP
                if (_eventType == "CAP") then {
                    [_logic, format ["airspaceLast%1",_eventType],[_eventAirspace, time]] call MAINCLASS;
                };

                 // send radio broadcast
                _sideObject = [_eventSide] call ALIVE_fnc_sideTextToObject;
                _factionName = getText((_eventFaction call ALiVE_fnc_configGetFactionClass) >> "displayName");

                // TODO RADIO MESSAGE

                //  Update assets?
                _assets = [ALIVE_globalATO,_eventFaction] call ALIVE_fnc_hashGet;

                // remove the event
                [_logic, "removeEvent", _eventID] call MAINCLASS;
            };

            // PLAYER REQUEST ---------------------------------------------------------------------------------------------------------------------------------

            // Would conflict with Combat Support?
        };
    };

    // Check to see if aircraft is still alive etc
    case "checkEvent": {

        private _event = _args;

        private _debug = [_logic, "debug"] call MAINCLASS;

        private _eventID = [_event, "id"] call ALIVE_fnc_hashGet;
        private _eventData = [_event, "data"] call ALIVE_fnc_hashGet;
        private _eventTime = [_event, "time"] call ALIVE_fnc_hashGet;
        private _eventState = [_event, "state"] call ALIVE_fnc_hashGet;
        private _eventStateData = [_event, "stateData"] call ALIVE_fnc_hashGet;
        private _eventFriendlyProfiles = [_event, "friendlyProfiles"] call ALIVE_fnc_hashGet;
        private _eventEnemyProfiles = [_event, "enemyProfiles"] call ALIVE_fnc_hashGet;
        private _playerRequested = [_event, "playerRequested"] call ALIVE_fnc_hashGet;
        private _playerRequestProfiles = [_event, "playerRequestProfiles"] call ALIVE_fnc_hashGet;

        private _eventType = _eventData select 0;
        private _eventSide = _eventData select 1;
        private _eventFaction = _eventData select 2;
        private _eventAirspace = _eventData select 3;
        private _eventATO = _eventData select 4;

        private _eventTargets = _eventATO select 7;

        private _totalCount = 0;

        _eventFriendlyProfiles = [_logic, "removeUnregisteredProfiles", _eventFriendlyProfiles] call MAINCLASS;
        [_event, "friendlyProfiles", _eventFriendlyProfiles] call ALIVE_fnc_hashSet;

        _totalCount = count _eventFriendlyProfiles;

        if (_totalCount != 0) then {

            _eventEnemyProfiles = [_logic, "removeUnregisteredProfiles", _eventEnemyProfiles] call MAINCLASS;
            [_event, "enemyProfiles", _eventEnemyProfiles] call ALIVE_fnc_hashSet;

            _totalCount = _totalCount + count _eventEnemyProfiles;
        };

        _result = _totalCount;
    };

    // Remove profiles that are nolonger valid
    case "removeUnregisteredProfiles": {

        private ["_profiles","_profile"];

        _profiles = _args;
        {
            private _profileID = _x;
            _profile = [ALIVE_profileHandler, "getProfile", _profileID] call ALIVE_fnc_profileHandler;
            if(isNil "_profile") then {
                // Remove the asset
                private _assets = [_logic, "assets"] call MAINCLASS;

                if ([_assets,_profileID] call CBA_fnc_hashHasKey) then {

                    private _asset = [_assets, _profileID] call ALiVE_fnc_hashGet;

                    // Check to see if generateTasks
                    private _generateTasks = [_logic,"generateTasks"] call MAINCLASS;
                    // Check to see if C2ISTAR is available
                    private _C2ISTARisAvailable = ["ALiVE_mil_c2istar"] call ALiVE_fnc_isModuleAvailable;
                    // Send CSAR request
                    if (_generateTasks && _C2ISTARisAvailable) then {
                        [_logic, "requestCSARPlayerTask", _asset] call MAINCLASS;
                    };

                    // remove it from airspace assets first
                    private _airspace = [_asset,"airspace"] call ALiVE_fnc_hashGet;
                    private _as = [[_logic,"airspaceAssets"] call MAINCLASS, _airspace] call ALiVE_fnc_hashGet;

                    _as = _as - [_profileID];
                    [[_logic,"airspaceAssets"] call MAINCLASS, _airspace, _as] call ALiVE_fnc_hashSet;

                    // If resupply then push the asset to the order queue
                    if ([_logic,"resupply"] call MAINCLASS) then {
                        [_logic,"resupplyList", _asset] call MAINCLASS;
                    };

                    // remove it from assets
                    [_assets,_profileID] call CBA_fnc_hashRem;
                    [_logic, "assets", _assets] call MAINCLASS;
                };
                _profiles set [_forEachIndex,"DELETE"];
            };

        } forEach _profiles;

        _profiles = _profiles - ["DELETE"];

        _result = _profiles;
    };

    // Remove event
    case "removeEvent": {
        private["_debug","_eventID","_eventQueue"];

        // remove the event from the queue

        _eventID = _args;
        _eventQueue = [_logic, "eventQueue"] call MAINCLASS;

        [_eventQueue,_eventID] call ALIVE_fnc_hashRem;

        [_logic, "eventQueue", _eventQueue] call MAINCLASS;
    };
};

TRACE_1("ATO - output",_result);
_result;
