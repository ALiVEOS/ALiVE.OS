#include "\x\alive\addons\mil_IED\script_component.hpp"

SCRIPT(createIED);

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_ied
#define DEFAULT_IED_THREAT 60
#define DEFAULT_IED_CHARGE "ALIVE_IEDUrbanSmall_Remote_Ammo"

// IED - create IED(s) at location
private ["_position","_town","_debug","_numIEDs","_j","_size","_posloc","_IEDs","_threat","_IEDData","_IEDcount", "_dud"];

if !(isServer) exitWith {["IED Not running on server!"] call ALiVE_fnc_dump;};

TRACE_1("IED",_this);

_debug = ADDON getVariable ["debug", false];
_threat = ADDON getVariable ["IED_Threat", DEFAULT_IED_THREAT];
// Resolved at module init by ALIVE_fnc_detectIEDIntegrations. Possible values:
//   "alive"      - full ALiVE pipeline (arm + proximity + disarm + charge).
//   "mine"       - createVehicle but skip ALiVE arming (legacy thirdParty=Yes).
//   "passive"    - createVehicle, no arming, no charge, no addAction.
//                  Engine handles via collision damage. For SOG punji sticks etc.
//   "engineMine" - createMINE (not createVehicle) so the engine arms the object
//                  as a proper mine. No ALiVE pipeline. For tripwire mines.
private _integrationMode = ADDON getVariable ["resolvedIntegrationMode", "alive"];
private _thirdParty       = (_integrationMode != "alive");   // legacy alias
private _isAlive          = (_integrationMode == "alive");
private _isPassive        = (_integrationMode == "passive");
private _isEngineMine     = (_integrationMode == "engineMine");

if (_thirdParty && _debug) then {
    ["MIL IED: Using non-alive integration mode: %1", _integrationMode] call ALiVE_fnc_dump;
};

_position = _this select 0;
_size = _this select 1;

if ((count _this) > 2) then {
    _town = _this select 2;
};

if ((count _this) > 3) then {
    _numIEDs = _this select 3;
} else {
    // IMPROVED: Reduced spawn formula - divisor changed from 50 to 150 for 67% reduction
    _numIEDs = round ((_size / 150) * ( _threat / 100));
    // Ensure minimum of 1 IED if threat > 0
    if (_numIEDs < 1 && _threat > 0) then {_numIEDs = 1;};
};

// Get IEDs from store if available
_IEDs = [[GVAR(STORE), "IEDs"] call ALiVE_fnc_hashGet, _town, [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashGet;
_IEDcount = count (_IEDs select 1);

// IF first time creating IEDs for location go work out how many IEDs
if (_IEDcount == 0) then {
    ["ALIVE-%1 IED: creating %2 IEDs at %5 (%3) - size %4", time, _numIEDs, mapgridposition  _position, _size, _town] call ALiVE_fnc_dump;

    // Find positions in area
    _posloc = [];
    _posloc = [_position, true, true, true, _size] call ALIVE_fnc_placeIED;
    if (_debug) then {
        ["ALIVE-%1 IED: Found %2 spots for IEDs",time, count _posloc] call ALiVE_fnc_dump;
    };

    // Clamp numIEDs to available positions.
    // Use (count _posloc) not (count _posloc) - 1 to avoid going negative.
    // If posloc is empty the for-loop handles it naturally since 1 to 0 never executes.
    if (_numIEDs > (count _posloc)) then {
        _numIEDs = count _posloc;
    };

    // Bail out early with a clear debug message if there are no valid positions
    if (_numIEDs == 0) exitWith {
        ["ALIVE-%1 IED: No valid positions found for IEDs at %2 - skipping", time, _town] call ALiVE_fnc_dump;
    };

    _IEDData = [] call ALiVE_fnc_hashCreate;

} else {
    _numIEDs = _IEDcount;
};

for "_j" from 1 to _numIEDs do {
    private ["_IEDpos","_pos","_cen","_near","_IED","_IEDskin","_data","_ID","_error","_IEDskins"];

    // Select Position for IED and remove position used
    _error = false;

    If (_IEDcount == 0) then {
        _index = round (random ((count _posloc) -1));
        _pos = _posloc select _index;
        _posloc set [_index, -1];
        _posloc = _posloc - [-1];

        // Use validated position directly - our placement validation already handled terrain/obstacles
        _IEDpos = _pos;

        private ["_IEDskins","_near","_choice","_allIEDClasses"];

        // Check no other IEDs nearby - IMPROVED: increased from 3m to 12m for better spacing
        // IMPORTANT: use only the actual ALIVE IED model classes here, NOT urbanIEDClasses.
        // urbanIEDClasses includes clutter objects (Land_Sacks_heap_F etc.) which are also
        // placed as camouflage by earlier iterations - using the full list causes false positives
        // where the proximity check finds its own clutter and skips the IED placement.
        private _realIEDClasses = ["ALIVE_IEDUrbanSmall_Remote_Ammo","ALIVE_IEDLandSmall_Remote_Ammo","ALIVE_IEDUrbanBig_Remote_Ammo","ALIVE_IEDLandBig_Remote_Ammo","ALIVE_DemoCharge_Remote_Ammo","ALIVE_SatchelCharge_Remote_Ammo"];
        _near = nearestObjects [_IEDpos, _realIEDClasses, 12];

        // Exit THIS ITERATION if other IEDs are found or position is on water
        if (count _near > 0) then {
            ["ALIVE-%1 IED: skipping - other IEDs found %2",time,_near] call ALiVE_fnc_dump; 
            _error = true;
        };
        if (surfaceIsWater _IEDpos) then {
            ["ALIVE-%1 IED: skipping - pos was on water.",time] call ALiVE_fnc_dump; 
            _error = true;
        };

        // Check not placed near a player
        // Skip THIS ITERATION if position is too close to a player
        if ({(getpos _x distance _IEDpos) < 75} count ([] call BIS_fnc_listPlayers) > 0) then {
            ["ALIVE-%1 IED: skipping - placement too close to player.",time] call ALiVE_fnc_dump; 
            _error = true;
        };

        // If error occurred, skip IED creation for this iteration
        if (!_error) then {
        private _isRoadContext = false;

        if (isOnRoad _IEDpos) then {
            _IEDskins = ADDON getVariable ["resolvedRoadIEDClasses", [ADDON, "roadIEDClasses"] call MAINCLASS];
            _isRoadContext = true;
        } else {
            // Check to see proximity to houses (use "House" base class to catch all map building types)
            if (count (_IEDpos nearObjects ["House", 40]) > 0) then {
                _IEDskins = ADDON getVariable ["resolvedUrbanIEDClasses", [ADDON, "urbanIEDClasses"] call MAINCLASS];

                // Add clutter nearby so its not so obvious that there is an IED
                private ["_clutter","_c","_clut","_clutm","_t"];
                _clutter = ADDON getVariable ["resolvedClutterClasses", [ADDON, "clutterClasses"] call MAINCLASS];
                for "_c" from 1 to (2 + (ceil(random 6))) do {

                    //Seems to cause a crash lateley if _clutter is empty (trigger-related?)
                    //Fixme: @Tup: why is clutter clutterClasses empty?
                    if (count _clutter > 0) then {
                        _clut = createVehicle [(selectRandom _clutter),_IEDpos, [], 40, "NONE"];
                        _clut setvariable [QUOTE(ADDON), true];

                        // Bounded retry: in dense urban areas with
                        // closely packed roads, the random nudge can
                        // keep landing on roads and the unbounded
                        // version hung mission init when a trigger
                        // fired immediately at startup (player
                        // spawned inside an IED zone). 10 attempts
                        // matches the road-clutter loop pattern below.
                        private _urbanRetry = 0;
                        while {isOnRoad _clut && _urbanRetry < 10} do {
                            _clut setPos [((position _clut) select 0) - 10 + random 20, ((position _clut) select 1) - 10 + random 20, ((position _clut) select 2)];
                            _urbanRetry = _urbanRetry + 1;
                        };
                    };

                    /* if (_debug) then {
                        ["ALIVE-%1 IED: Planting clutter (%2) at %3.", time, typeOf _clut, position _clut] call ALiVE_fnc_dump;
                        //Mark clutter position
                        _t = format["cl_r%1", floor (random 1000)];
                        _clutm = [_t, position _clut, "Icon", [1,1], "TEXT:", "", "TYPE:", "mil_dot", "COLOR:", "ColorGreen", "GLOBAL"] call CBA_fnc_createMarker;
                        _clut setvariable ["Marker", _clutm];
                    };*/
                };
            } else {
                _IEDskins = ADDON getVariable ["resolvedRoadIEDClasses", [ADDON, "roadIEDClasses"] call MAINCLASS];
                _isRoadContext = true;
            };
        };

        // Road IED clutter - sparse (1-3 pieces) and placed tight to the IED
        // to break up its silhouette against open verge. Urban IEDs already
        // get dense clutter above; rural road IEDs previously had none, which
        // left a bare model visible against cleared shoulder terrain.
        if (_isRoadContext) then {
            private ["_clutter","_roadC","_roadClut"];
            _clutter = ADDON getVariable ["resolvedClutterClasses", [ADDON, "clutterClasses"] call MAINCLASS];
            for "_roadC" from 1 to (1 + (ceil (random 2))) do {
                if (count _clutter > 0) then {
                    _roadClut = createVehicle [(selectRandom _clutter), _IEDpos, [], 8, "NONE"];
                    _roadClut setvariable [QUOTE(ADDON), true];

                    // Nudge off tarmac if it landed on a road. Bounded retry
                    // so we don't infinite-loop on wide intersections.
                    private _retry = 0;
                    while {isOnRoad _roadClut && _retry < 8} do {
                        _roadClut setPos [
                            ((position _roadClut) select 0) - 6 + random 12,
                            ((position _roadClut) select 1) - 6 + random 12,
                            ((position _roadClut) select 2)
                        ];
                        _retry = _retry + 1;
                    };
                };
            };
        };

        // Guard: the resolved pool could be empty if a selected integration
        // declares no classes for this category AND the user has wiped the
        // base attribute and _additional field. Skip this iteration cleanly
        // rather than feeding nil to createVehicle.
        if (count _IEDskins == 0) exitWith {
            _error = true;
            ["ALIVE-%1 MIL_IED: empty class pool, skipping placement (check integrationChoice + <cat>_additional fields)", time] call ALiVE_fnc_dump;
        };

        // Apply per-integration vertical offset. Default -0.1 (ALiVE classic
        // burial); registry entries can override (e.g. RHS sets 0 so visible
        // mine objects don't sink under terrain).
        _IEDpos set [2, ADDON getVariable ["resolvedPlacementZ", -0.1]];
        _IEDskin = (selectRandom _IEDskins);

        // engineMine mode uses createMine instead of createVehicle so the
        // engine treats the placed object as a properly armed mine - this is
        // what makes pressure / tripwire triggers actually fire on it.
        // Other modes (alive, mine, passive) all use createVehicle.
        _IED = if (_isEngineMine) then {
            createMine [_IEDskin, _IEDpos, [], 0]
        } else {
            createVehicle [_IEDskin, _IEDpos, [], 0, "NONE"]
        };

        _ID = format ["%1-%2", _town, _j];
        if (random 1 < 0.95) then {_dud = false} else {_dud = true};

        _data = [] call ALiVE_fnc_hashCreate;
        [_data, "IEDskin", _IEDskin] call ALiVE_fnc_hashSet;
        [_data, "IEDpos", getposATL _IED] call ALiVE_fnc_hashSet;
        [_data, "IEDtype", "IED"] call ALiVE_fnc_hashSet;
        [_data, "IEDDud", _dud] call ALiVE_fnc_hashSet;
        [_IEDData, _ID, _data] call ALiVE_fnc_hashSet;

        }; // End of if (!_error) block - only create IED if no errors

    } else {
        private ["_data"];
        _ID = (_IEDs select 1) select (_j-1);
        _data = [_IEDs, _ID] call ALiVE_fnc_hashGet;
        _dud = [_data, "IEDDud"] call ALiVE_fnc_hashGet;
        private _storedPos = [_data, "IEDpos", [0,0,0]] call ALiVE_fnc_hashGet;

        // Player-distance guard on store replay. mil_ied uses repeating
        // triggers (size+250m) per IED town; first-time placement (above)
        // checks 75m to any player before spawning, but the replay branch
        // previously did not — so a player camping or walking onto a
        // stored IED position when the trigger refired would see the IED
        // pop out of the ground under their feet (#899). Defer THIS
        // iteration if a player is within 75m; the trigger will fire
        // again as players move and the IED will reappear when clear.
        if ({(getpos _x distance _storedPos) < 75} count ([] call BIS_fnc_listPlayers) > 0) then {
            ["ALIVE-%1 IED: store-replay skipped - player within 75m of stored pos %2", time, _storedPos] call ALiVE_fnc_dump;
            _error = true;
        } else {
            _IED = createVehicle [[_data, "IEDskin", "ALIVE_IEDUrbanSmall_Remote_Ammo"] call ALiVE_fnc_hashGet, _storedPos, [], 0, "NONE"];
            if (_thirdParty) then {
                _IED setpos [(position _IED) select 0, (position _IED) select 1, 0.15];
            };
        };
    };

    // Only proceed with IED setup if no error occurred and IED was created
    if (!_error) then {
        // Guard: skip the rest of the per-IED setup if createVehicle returned objNull.
        // Without this guard the demo charge below would be created at world origin
        // (or wherever attachTo objNull places it) and ACE would see a loose
        // explosive with no parent mine - the "lone charge" symptom.
        if (isNull _IED) then {
            ["ALIVE-%1 MIL_IED arm/charge SKIPPED for null _IED (skin=%2 pos=%3) - this would have produced an orphaned charge",
                time, _IEDskin, _IEDpos] call ALiVE_fnc_dump;
        } else {
        _IED setvariable ["ID", _ID];
    _IED setvariable ["town", _town];

    // Check if Dud IED
    if (!_dud && !_thirdParty) then {
        [_IED, typeOf _IED] call ALIVE_fnc_armIED;

        // Attach the demo charge. chargeOffsetZ controls Z relative to the IED:
        //   0 (default)  - sit at IED reference point (correct for trash-pile
        //                  IEDs where the c4 model is "inside" the visual)
        //   negative     - bury below the IED (used by RHS so the visible mine
        //                  isn't covered up by the c4 model on top)
        _IEDCharge = createVehicle ["ALIVE_DemoCharge_Remote_Ammo",getposATL _IED, [], 0, "CAN_COLLIDE"];
        _IEDCharge attachTo [_IED, [0, 0, ADDON getVariable ["resolvedChargeOffsetZ", 0]]];

        // Damage-handler logic shared by both EHs (charge AND mine). Either
        // can fire when a bullet/explosive hits its target; the
        // `ALiVE_IED_Detonating` flag prevents both running. Mine-side EH is
        // the path that matters when the charge is buried out of sight (RHS):
        // shooting the visible mine still detonates the IED.
        _ehID = _IEDCharge addeventhandler ["HandleDamage",{
            params ["_charge", "", "", "_killer"];
            private _IED = attachedTo _charge;
            if (isNull _IED) exitWith {};
            if (_IED getVariable ["ALiVE_IED_Detonating", false]) exitWith {};
            _IED setVariable ["ALiVE_IED_Detonating", true];
            private _pos = getpos _charge;

            if (isPlayer _killer) then {
                if (ADDON getVariable "debug") then {
                    ["ALIVE-%1 IED: %2 explodes due to damage by %3 (via charge)", time, _IED, _killer] call ALiVE_fnc_dump;
                    [_IED getvariable "Marker"] call cba_fnc_deleteEntity;
                };
                [position _IED, [str(side (group _killer))], +10] call ALiVE_fnc_updateSectorHostility;
                _pos set [2,0];
                "M_Mo_120mm_AT" createVehicle _pos;
            };

            [ADDON, "removeIED", _IED] call ALiVE_fnc_IED;
            detach _charge;
            deleteVehicle _IED;
            deletevehicle _charge;
            private _trgr = _pos nearObjects ["EmptyDetector", 3];
            {
                deleteVehicle _x;
            } foreach _trgr;
        }];

        // Mirrored damage handler on the IED (mine) itself. Critical for
        // visible-mine integrations like RHS where the buried charge is out
        // of line-of-sight and a player's bullet hits the mine model first.
        //
        // Gated: vanilla A3 IED ammo classes used by ACE_Explosives integration
        // (e.g. IEDUrbanSmall_Remote_Ammo) inherit from an ammo-prop base that
        // doesn't expose the "HandleDamage" EH enum -- attempting to attach it
        // raises a recurring `Foreign error: Unknown enum value: HandleDamage`
        // to the RPT and returns -1. ALiVE_IED-derived classes (Thing base)
        // and MineBase-derived classes (RHS mines) DO support it, so restrict
        // the attach to those. The charge-side handler above covers the
        // single-model integrations where there is no separate mine model.
        private _supportsHandleDamage = ((typeOf _IED) isKindOf "ALiVE_IED") || ((typeOf _IED) isKindOf "MineBase");
        private _ehIDmine = -1;
        if (_supportsHandleDamage) then {
            _ehIDmine = _IED addEventHandler ["HandleDamage", {
            params ["_ied", "", "", "_killer"];
            if (_ied getVariable ["ALiVE_IED_Detonating", false]) exitWith {};
            _ied setVariable ["ALiVE_IED_Detonating", true];
            private _charge = _ied getVariable ["charge", objNull];
            private _pos = getpos _ied;

            if (isPlayer _killer) then {
                if (ADDON getVariable "debug") then {
                    ["ALIVE-%1 IED: %2 explodes due to damage by %3 (via mine)", time, _ied, _killer] call ALiVE_fnc_dump;
                    [_ied getvariable "Marker"] call cba_fnc_deleteEntity;
                };
                [position _ied, [str(side (group _killer))], +10] call ALiVE_fnc_updateSectorHostility;
                _pos set [2,0];
                "M_Mo_120mm_AT" createVehicle _pos;
            };

            [ADDON, "removeIED", _ied] call ALiVE_fnc_IED;
            if (!isNull _charge) then { detach _charge; deleteVehicle _charge; };
            deleteVehicle _ied;
            private _trgr = _pos nearObjects ["EmptyDetector", 3];
            {
                deleteVehicle _x;
            } foreach _trgr;
        }];
        };

        _IED setVariable ["ehID",_ehID, true];
        _IED setVariable ["ehIDmine",_ehIDmine, true];
        _IED setvariable ["charge", _IEDCharge, true];
    };

    if (_thirdParty) then {

        // ["MIL IED: Adding EH to 3rd party IEDs : %1 - %2", typeOf _IED, _IED] call ALiVE_fnc_dump;

    };

    if (_debug) then {
        private ["_t","_markers","_text","_iedm"];

        //Mark IED position
        _t = format["ied_r%1", floor (random 1000)];
        _text = "IED";

        _iedm = [_t, position _IED, "Icon", [0.5,0.5], "TEXT:", _text, "TYPE:", "mil_dot", "COLOR:", "ColorRed", "GLOBAL"] call CBA_fnc_createMarker;
        _IED setvariable ["Marker", _iedm];

        _markers = ADDON getVariable ["debugMarkers",[]];
        _markers pushback _iedm;
        ADDON setVariable ["debugMarkers",_markers];

    };
        }; // End of else (isNull _IED guard)
    }; // End of if (!_error) - only set up IED if it was successfully created
};

// Set data
if (_IEDcount == 0) then {
    [[GVAR(STORE), "IEDs"] call ALiVE_fnc_hashGet, _town, _IEDData] call ALiVE_fnc_hashSet;
};
