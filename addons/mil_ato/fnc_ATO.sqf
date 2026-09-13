//#define DEBUG_MPDE_FULL
#include "\x\alive\addons\mil_ato\script_component.hpp"
SCRIPT(ATO);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ATO
Description:
Military Air Tasking Orders. The name every other addon calls, and now a
forwarder onto the kernel.

This file used to BE the module: eight and a half thousand lines holding the
records, the placing, the orders, the planning, the air picture and the driving
of all of it. That is now ten pieces with a test each, and a kernel that drives
them, and this is what keeps the name they were all reached through working.

Two things happen here, in this order, and the order is the point.

The seven helper functions below are defined at file scope, exactly as they
always were, because they are the module's only file-scope names and things
outside this module call them: the observer asks for ALiVE_fnc_isAntiAir behind
a guard, so losing it would blind the air defence scan silently rather than
loudly. They are defined by CALLING this function, which is what the module's
own init does first, so they exist from init onwards just as before.

Then every operation is handed to the kernel. Every name, call shape, default
and return value is the kernel's, and the kernel was written to keep all of
them. A name that no longer exists falls through the kernel to the base class
and is logged rather than thrown, which is what keeps an old caller alive.

TO PUT THE OLD MODULE BACK: revert this one file. Nothing else was changed for
the switch. The module's init still calls this function, the global registry
still calls it by name in three places, and the save button still calls the
save function, so there is no second edit to undo and no order to undo it in.

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - Whatever the kernel answers for that operation

Examples:
[_logic, "debug", true] call ALiVE_fnc_ATO;

See Also:
- <ALIVE_fnc_ATOKernel>
- <ALIVE_fnc_ATOInit>

Author:
Tupolov & Jman
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_ATO

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

	  private ["_airportID","_markerExists","_markerList","_alpha","_runwayWidth","_runwayStartPos","_runwayEndPos","_mkrname","_marker"];
    _markerList = []; 
    
    _runwayStartPos = [_logic, "runwaystartpos"] call MAINCLASS;
    _runwayEndPos = [_logic, "runwayendpos"] call MAINCLASS;
    _runwayWidth = [_logic, "runwaywidth"] call MAINCLASS;
    
    if (isNil "_runwayStartPos") then {
	     // DEBUG -------------------------------------------------------------------------------------
	     if(_debug) then {
	  	   ["ATO - _runwayStartPos is empty!"] call ALiVE_fnc_dump;
	     };
	     // DEBUG ------------------------------------------------------------------------------------- 
    } else {
	    _runwayStartPos = call compile _runwayStartPos;
	    _runwayEndPos = call compile _runwayEndPos;
	    _runwayWidth = parseNumber _runwayWidth;
	    if !(isNil "_runwayStartPos") then {
			    if ((count _runwayStartPos > 0) && (count _runwayEndPos > 0) && (_runwayWidth > 0)) then {
			       // DEBUG -------------------------------------------------------------------------------------
			       if(_debug) then {
			         ["ATO - Runway Start Position: %1(%4), Runway End Position: %2(%5), Runway Width: %3(%6)", _runwayStartPos, _runwayEndPos, _runwayWidth, typeName _runwayStartPos, typeName _runwayEndPos, typeName _runwayWidth] call ALiVE_fnc_dump;
			       };
			       // DEBUG ------------------------------------------------------------------------------------- 
			       if(_debug) then {_alpha = 0.5;} else {_alpha = 0;};
			        _airportID = [_pos] call ALiVE_fnc_getNearestAirportID; 
			        _mkrname = "runway_"+(str _airportID); 
			        _markerExists = [_mkrname] call ALIVE_fnc_markerExists;
			       if (_markerExists) then {
			        _marker = _mkrname;
			       } else {
			        _marker = [_mkrname, _runwayStartPos, _runwayEndPos, _runwayWidth, _color, _alpha] call ALIVE_fnc_createLineMarker;
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

// ----------------------------------------------------------------------------
// And on to the kernel.
//
// ASSERTed rather than guarded, because a build with this file and without the
// kernel is a broken build and silence would make it look like a module that
// simply does nothing.
ASSERT_DEFINED("ALIVE_fnc_ATOKernel","The air commander's kernel is missing");

[_logic, _operation, _args] call ALIVE_fnc_ATOKernel
