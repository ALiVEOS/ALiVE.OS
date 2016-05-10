#include <\x\alive\addons\sys_marker\script_component.hpp>
SCRIPT(marker);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_marker
Description:
Allows users to mark the map with advanced markers that are persisted, with or without a SPOTREP.
Press CTRL and Left Mouse button to add a marker. Press CTRL and Right Mouse button to delete a marker.
Press CTRL and left mouse button on an existing marker to edit it.

Users may also draw lines, rectangles, arrows, ellipses. By default drawing on the map is broadcast to all players on your side.
Press the [ button to cycle through drawing modes. Press the END button to exit drawing mode.
Press the up arrow to increase the width of a line or angle of a box/ellipse, press the down arrow to decrease the width of the line or angle of box/ellipse.
Press the left arrow to change color. Press the right arrow to change fill (if appropriate).
Press CTRL and the left mouse button to start drawing, press CTRL and the left mouse button again to stop drawing.

CTRL and mouse buttons to edit or delete markers drawn.

Arrows are not persisted (use an arrow icon marker to persist).

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array,String,Number,Boolean - The selected parameters

Returns:
Array, String, Number, Any - The expected return value

Properties:
drawToggle - sets or gets the map drawing toggle state [OFF, LINE, ARROW, BOX, ELLIPSE, FREE]
drawing - sets or gets whether or not a marker is being drawn

EventHandlers:
keyDown - handles key press while on map screen
mouseMoving - handles the movement of the mouse while on map screen

Methods:
create - creates the game logic
init - initialises game logic
state - returns the state of the marker STORE?
destroy - destroys the game logic
destroyGlobal - destroys the game logic globally

onMarker - checks to see if a marker exists at a specified position
isAuthorized - checks to see if a player may add, edit or delete a marker
getMarker - returns extended marker information
loadMarkers - loads markers from the database
saveMarkers - saves markers to the database
restoreMarkers - restores the markers loaded to the map
openDialog - opens the advanced marker user interface
addMarker - adds a marker to the store
removeMarker - removes a marker from the store
createMarker - creates a marker on the client machine
updateMarker - updates a marker
deleteMarker - deletes a marker
deleteAllMarkers - deletes all markers on the map (Admin Only)

Examples:
(begin example)
// Create instance by placing editor module
[_logic,"init"] call ALiVE_fnc_marker;
(end)

See Also:
- <ALIVE_fnc_markerInit>

Author:
Tupolov

In memory of Peanut

To Do:
- isauthorized
- persist/edit arrow markers
- free draw (create,edit,delete,MP)
- deleteAll

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_marker

#define NO_DRAW 0
#define FREE_DRAW 5
#define ARROW_DRAW 2
#define ELLIPSE_DRAW 4
#define RECTANGLE_DRAW 3
#define LINE_DRAW 1

#define DEFAULT_TOGGLE 0

#define MAP_DISPLAY 12
#define MAP_CONTROL 51
#define BRIEFING_DISPLAY_SERVER 52
#define BRIEFING_DISPLAY_CLIENT 53

#define SYS_MARKER_MAP_TEXT 5999


private ["_result", "_operation", "_args", "_logic"];

_logic = [_this, 0, objNull, [objNull]] call BIS_fnc_param;
_operation = [_this, 1, "", [""]] call BIS_fnc_param;
_args = [_this, 2, objNull, [objNull,[],"",0,true,false]] call BIS_fnc_param;


TRACE_3("SYS_marker",_logic, _operation, _args);

switch (_operation) do {

    	case "create": {
            if (isServer) then {

	            // Ensure only one module is used
	            if !(isNil QMOD(SYS_marker)) then {
                	_logic = MOD(SYS_marker);
                    ERROR_WITH_TITLE(str _logic, localize "STR_ALIVE_marker_ERROR1");
	            } else {
	        		_logic = (createGroup sideLogic) createUnit ["ALiVE_SYS_MARKER", [0,0], [], 0, "NONE"];
                    MOD(SYS_marker) = _logic;
                };

                //Push to clients
	            PublicVariable QMOD(SYS_marker);
            };

            TRACE_1("Waiting for object to be ready",true);

            waituntil {!isnil QMOD(SYS_marker)};

            TRACE_1("Creating class on all localities",true);

			// initialise module game logic on all localities
			MOD(SYS_marker) setVariable ["super", QUOTE(SUPERCLASS)];
			MOD(SYS_marker) setVariable ["class", QUOTE(MAINCLASS)];

            _result = MOD(SYS_marker);
        };

        case "init": {

            //["%1 - Initialisation started...",_logic] call ALiVE_fnc_Dump;

            /*
            MODEL - no visual just reference data
            - module object datastorage parameters
            - Establish data handler on server
            - Establish data model on server and client
            */

             [_logic, "drawToggle", DEFAULT_TOGGLE] call ALIVE_fnc_marker;
             [_logic, "drawing", false] call ALIVE_fnc_marker;

//             diag_log format["TOGGLE: %1", [_logic, "drawToggle",[]] call MAINCLASS];

            // Define module basics on server
			if (isServer) then {
                _errorMessage = "Please include the Requires ALiVE module! %1 %2";
                _error1 = ""; _error2 = ""; //defaults
                if(
                    !(["ALiVE_require"] call ALiVE_fnc_isModuleavailable)
                    ) exitwith {
                    [_errorMessage,_error1,_error2] call ALIVE_fnc_dumpR;
                };

				// Wait for disable log module to set module parameters
                if (["AliVE_SYS_markerPARAMS"] call ALiVE_fnc_isModuleavailable) then {
                    waituntil {!isnil {MOD(SYS_marker) getvariable "DEBUG"}};
                };

                // Create store initially on server
                GVAR(STORE) = [] call ALIVE_fnc_hashCreate;

                // Reset states with provided data;
                if !(_logic getvariable ["DISABLEPERSISTENCE",false]) then {
                    if (isDedicated && {[QMOD(SYS_DATA)] call ALiVE_fnc_isModuleAvailable}) then {
                        waituntil {!isnil QMOD(SYS_DATA) && {MOD(SYS_DATA) getvariable ["startupComplete",false]}};
                    };

                    ["DATA: Loading marker data."] call ALIVE_fnc_dump;
                    _state = [_logic, "loadMarkers"] call ALIVE_fnc_marker;

                    if !(typeName _state == "BOOL") then {
                        GVAR(STORE) = _state;
                    } else {
                        LOG("No markers loaded...");
                    };

                };

                GVAR(STORE) call ALIVE_fnc_inspectHash;

            	[_logic,"state",GVAR(STORE)] call ALiVE_fnc_marker;

                //Push to clients
                PublicVariable QGVAR(STORE);

                _logic setVariable ["init", true, true];
			};

            /*
            CONTROLLER  - coordination
            */

            // Wait until server init is finished
            waituntil {_logic getvariable ["init",false]};

            TRACE_1("Spawning Server processes",isServer);

            if (isServer) then {
                // Start any server-side processes that are needed
            };

			TRACE_1("Spawning clientside processes",hasInterface);

            if (hasInterface) then {
                // Start any client-side processes that are needed

                ["ALiVE","mapDotMarker", "Map - Place dot icon quick marker", {}, {}, [52,[false,true,false]]] call CBA_fnc_addKeybind;
                ["ALiVE","mapObjMarker", "Map - Place objective icon quick marker", {}, {}, [45,[false,true,false]]] call CBA_fnc_addKeybind;
                ["ALiVE","mapUnkMarker", "Map - Place unknown icon quick marker", {}, {}, [53,[true,true,false]]] call CBA_fnc_addKeybind;
                ["ALiVE","mapCycleDraw", "Map - Cycle drawing mode", {}, {}, [26,[false,false,false]]] call CBA_fnc_addKeybind;
                ["ALiVE","mapEndDraw", "Map - End drawing", {}, {}, [207,[false,false,false]]] call CBA_fnc_addKeybind;
                ["ALiVE","mapIncLine", "Map - Draw - Increase line width / box angle", {}, {}, [200,[false,false,false]]] call CBA_fnc_addKeybind;
                ["ALiVE","mapDecLine", "Map - Draw - Decrease line width / box angle", {}, {}, [208,[false,false,false]]] call CBA_fnc_addKeybind;
                ["ALiVE","mapChgColor", "Map - Draw - Change colour", {}, {}, [203,[false,false,false]]] call CBA_fnc_addKeybind;
                ["ALiVE","mapChgFill", "Map - Draw - Change Fill", {}, {}, [205,[false,false,false]]] call CBA_fnc_addKeybind;

                 waituntil {!isnil QGVAR(STORE)};

                 if (didJIP) then {
                    ["Registering Advanced Marker PVEH for %1. JIP: %2 ", player, didJIP] call ALiVE_fnc_Dump;
                    QGVAR(STORE) addPublicVariableEventHandler {
                        // Restore Markers on map for JIP
                        [ADDON, "restoreMarkers", [GVAR(STORE)]] call ALiVE_fnc_marker;
                    };
                };

                TRACE_1("Initial STORE", GVAR(STORE));

                GVAR(arrowList) = [];
                GVAR(colorChoice) = 0;
                GVAR(colorList) = [
                    "ColorBlack",
                    "ColorGrey",
                    "ColorRed",
                    "ColorGreen",
                    "ColorBlue",
                    "ColorYellow",
                    "ColorOrange",
                    "ColorWhite",
                    "ColorPink",
                    "ColorBrown",
                    "ColorKhaki",
                    "ColorWEST",
                    "ColorEAST",
                    "ColorGUER",
                    "ColorCIV",
                    "ColorUNKNOWN",
                    "Color1_FD_F",
                    "Color2_FD_F",
                    "Color3_FD_F",
                    "Color4_FD_F",
                    "ColorBLUFOR",
                    "ColorCivilian",
                    "ColorIndependent",
                    "ColorOPFOR"
                ];

                if !(didJIP) then { // Don't run if JIP as no briefing screen appears
                    ["Registering Advanced Marker controls for briefing screen. JIP: %1", didJIP] call ALiVE_fnc_Dump;
                    [_logic] spawn {
                        // Install handlers on briefing screen
                        private ["_display","_control","_logic"];

                        _logic = _this select 0;

                        _display = BRIEFING_DISPLAY_CLIENT;
                        if (isServer && isMultiplayer) then {
                            _display = BRIEFING_DISPLAY_SERVER;
                        };

                        _waitTime = diag_tickTime + 150000;
                        waitUntil {
                            LOG(str ( (findDisplay _display) displayCtrl MAP_CONTROL ));
                            str ((findDisplay _display) displayCtrl MAP_CONTROL) != "No control" || diag_tickTime > _waitTime;
                        };
                         // Add eventhandler for creating markers

                        if (str ((findDisplay _display) displayCtrl MAP_CONTROL) != "No control" ) then {
                            // diag_log _display;
                            disableSerialization;
                            _display = findDisplay _display;
                            _control = _display displayCtrl MAP_CONTROL;
                            _control ctrlAddEventHandler ["MouseButtonClick", "[ALiVE_SYS_marker,'mouseButton',[player, _this]] call ALiVE_fnc_marker;"];
                            _control ctrlAddEventHandler ["MouseButtonDblClick", "hintSilent 'Only ALIVE Advanced Markers will be stored. Default BIS markers are not supported by ALIVE. CTRL-MOUSE BUTTON to create an Advanced Marker.'"];
                            _control ctrlAddEventHandler ["draw", "[ALiVE_SYS_marker,'draw',[player, _this]] call ALiVE_fnc_marker;"];
                            _control ctrlAddEventHandler ["MouseMoving", {[ALiVE_SYS_marker,"mouseMoving",[player, _this]] call ALiVE_fnc_marker;}];

                            _display displayAddEventHandler ["keyDown", {[ALiVE_SYS_marker,"keyDown",[player, _this]] call ALiVE_fnc_marker;}];
                            ["Registered controls for NON-JIP on briefing screen: %1", player] call ALiVE_fnc_Dump;

                            // Restore Markers on map for non JIPs
                            [_logic, "restoreMarkers", [GVAR(STORE)]] call ALiVE_fnc_marker;
                        } else {
                            ["Did not Register Adv Marker controls for briefing screen: %1", player] call ALiVE_fnc_Dump;
                        };
                    };
                };

                waitUntil {
                    sleep 1;
                    ((str side player) != "UNKNOWN")
                };

                // Wait until game map is opened and register map controls
                [] spawn {
                    private ["_display","_control"];

                    ["Registering Advanced Marker controls for %1 on map screen.", player] call ALiVE_fnc_Dump;

                    waitUntil {LOG(str ((findDisplay MAP_DISPLAY) displayCtrl MAP_CONTROL)); str ((findDisplay MAP_DISPLAY) displayCtrl MAP_CONTROL) != "No control"};

                    LOG(str ((findDisplay MAP_DISPLAY) displayCtrl MAP_CONTROL));

                    disableSerialization;

                    // Add eventhandler for creating markers
                    _display = findDisplay MAP_DISPLAY;

                    _control = _display displayCtrl MAP_CONTROL;
    				_control ctrlAddEventHandler ["MouseButtonClick", "[ALiVE_SYS_marker,'mouseButton',[player, _this]] call ALiVE_fnc_marker;"];
                    _control ctrlAddEventHandler ["MouseButtonDblClick", "hint 'Only ALIVE Advanced Markers will be stored. Default BIS markers are not supported by ALIVE. CTRL-MOUSE BUTTON to create an Advanced Marker.'"];
       				_control ctrlAddEventHandler ["draw", "[ALiVE_SYS_marker,'draw',[player, _this]] call ALiVE_fnc_marker;"];
                    _control ctrlAddEventHandler ["MouseMoving", {[ALiVE_SYS_marker,"mouseMoving",[player, _this]] call ALiVE_fnc_marker;}];

                    _display displayAddEventHandler ["keyDown", {[ALiVE_SYS_marker,"keyDown",[player, _this]] call ALiVE_fnc_marker;}];
                    ["Registered controls for PLAYER on map screen: %1", player] call ALiVE_fnc_Dump;
                };
            };


            TRACE_1("After module init",_logic);

            // Indicate Init is finished on server
            if (isServer) then {
                _logic setVariable ["startupComplete", true, true];
            };

            //["%1 - Initialisation Completed...",MOD(SYS_marker)] call ALiVE_fnc_Dump;
            _logic setVariable ["bis_fnc_initModules_activate",true];
            _result = MOD(SYS_marker);
        };

         case "mouseButton":
         { // Runs locally on client

            private ["_player","_shift","_alt","_ctr","_ok","_control","_xPos","_yPos","_toggle"];
            _player = player;
            _params = _args select 1;
            _control = _params select 0;
            _button = _params select 1;
   			_xPos = _params select 2;
			_yPos = _params select 3;
            _shift = _params select 4;
            _ctr = _params select 5;
            _alt = _params select 6;

            _toggle = [_logic, "drawToggle"] call MAINCLASS;

			// Check to see if CTRL is held down
			if (_ctr && !_shift && !_alt) then {
				private ["_side","_xy","_pos","_check"];
				_xy = [_params select 2, _params select 3];

				_pos = _control ctrlMapScreenToWorld _xy;
				uiNamespace setVariable [QGVAR(pos), _pos];

				// Check to see if Marker exists at location, if so change the mode
				_check = [_logic, "onMarker", [_pos]] call ALIVE_fnc_marker;

				if (_button == 0) then {
					uiNamespace setVariable [QGVAR(edit), _check];

					if ([_logic, "isAuthorized", [_check]] call ALIVE_fnc_marker) then {

                        if (_toggle == NO_DRAW || typeName _check != "BOOL") then {
							// Open Dialog
                            _display = ctrlParent _control;
                            if (str _display == "Display #12") then {
    							_ok = createDialog "RscDisplayALiVEAdvancedMarker";
    							if !(_ok) then {
    								diag_log "Could not open Marker Dialog!";
    							};
                            } else {
                                private "_tcontrol";
                                _tcontrol = _display displayCtrl SYS_MARKER_MAP_TEXT;
                                _tcontrol ctrlSetText "Add Marker Not Available";
                            };
                        } else {

                             // drawToggle is on
                            if (_ctr && _button == 0) then {
                                private "_drawing";

                                _drawing = [_logic, "drawing"] call ALIVE_fnc_marker;

                                if (_drawing) then {
                                    private ["_markersHash","_width","_color","_angle","_fill"];
                                    [_logic, "drawing", false] call ALIVE_fnc_marker;
                                    _width = [_logic, "width"] call ALIVE_fnc_marker;
                                    _color = [_logic, "color"] call ALIVE_fnc_marker;
                                    _angle = [_logic, "angle"] call ALIVE_fnc_marker;
                                    _fill = [_logic, "fill"] call ALIVE_fnc_marker;

                                    if (_fill == "") then {_fill = "Border"} else {_fill = "Solid"};

                                    _markersHash = [] call ALIVE_fnc_hashCreate;
                                    [_markersHash, QGVAR(color), _color] call ALIVE_fnc_hashSet;
                                    [_markersHash, QGVAR(alpha), 0.9] call ALIVE_fnc_hashSet;
                                    [_markersHash, QGVAR(dir), _angle] call ALIVE_fnc_hashSet;
                                    [_markersHash, QGVAR(locality), "SIDE"] call ALIVE_fnc_hashSet;
                                    [_markersHash, QGVAR(localityValue), str(side (group player))] call ALIVE_fnc_hashSet;
                                    [_markersHash, QGVAR(player), getPlayerUID player] call ALIVE_fnc_hashSet;
                                    [_markersHash, QGVAR(hasspotrep), false] call ALIVE_fnc_hashSet;

                                    switch (_toggle) do {
                                        case FREE_DRAW: {           // Free Draw
                                            hintSilent "Free Draw Mode";
                                       };
                                        case ARROW_DRAW: {          // Free Arrow Draw
                                            // Create Add to the arrow list
                                            GVAR(arrowList) set [count GVAR(arrowList), [GVAR(startpoint), GVAR(endpoint), (configfile >> "cfgmarkercolors" >> _color >> "color") call BIS_fnc_colorConfigToRGBA]];
                                            publicVariable QGVAR(arrowList);
                                        };
                                        case ELLIPSE_DRAW: {            // Free Ellipse Draw
                                            [_markersHash, QGVAR(brush), _fill] call ALIVE_fnc_hashSet;
                                            [_markersHash, QGVAR(shape), "ELLIPSE"] call ALIVE_fnc_hashSet;
                                            [_markersHash, QGVAR(size), [abs ((GVAR(endpoint) select 0) - (GVAR(startpoint) select 0)), abs ((GVAR(endpoint) select 1) - (GVAR(startpoint) select 1))]] call ALIVE_fnc_hashSet;
                                            [_markersHash, QGVAR(pos), GVAR(startpoint)] call ALIVE_fnc_hashSet;
                                            // Create Marker
                                            _markerName = "ELLIPSE" + str(random 5000 + 1);
                                            [MOD(SYS_marker), "addMarker", [_markerName, _markersHash]] call ALiVE_fnc_marker;

                                        };
                                        case RECTANGLE_DRAW: {          // Free Rectangle Draw
                                            [_markersHash, QGVAR(brush), _fill] call ALIVE_fnc_hashSet;
                                            [_markersHash, QGVAR(shape), "RECTANGLE"] call ALIVE_fnc_hashSet;
                                            [_markersHash, QGVAR(size), [abs ((GVAR(endpoint) select 0) - (GVAR(startpoint) select 0)), abs ((GVAR(endpoint) select 1) - (GVAR(startpoint) select 1))]] call ALIVE_fnc_hashSet;
                                            [_markersHash, QGVAR(pos), GVAR(startpoint)] call ALIVE_fnc_hashSet;
                                            // Create Marker
                                            _markerName = "RECT" + str(random 5000 + 1);
                                            [MOD(SYS_marker), "addMarker", [_markerName, _markersHash]] call ALiVE_fnc_marker;

                                        };
                                        case LINE_DRAW: {           // Free Line Draw
                                            private ["_pos","_tmp","_length","_dir"];
                                            [_markersHash, QGVAR(brush), "Solid"] call ALIVE_fnc_hashSet;
                                            [_markersHash, QGVAR(shape), "RECTANGLE"] call ALIVE_fnc_hashSet;
                                            _pos = [
                                                ((GVAR(startpoint) select 0) + (GVAR(endpoint) select 0)) / 2,
                                                ((GVAR(startpoint) select 1) + (GVAR(endpoint) select 1)) / 2,
                                                0
                                            ];

                                            _tmp = [
                                                ((GVAR(endpoint) select 0) - (GVAR(startpoint) select 0)),
                                                ((GVAR(endpoint) select 1) - (GVAR(startpoint) select 1))
                                            ];

                                            _length = (_tmp select 0) * (_tmp select 0) + (_tmp select 1) * (_tmp select 1);
                                            _length = sqrt _length;

                                            _dir = _tmp call CBA_fnc_vectDir;
                                            [_markersHash, QGVAR(dir), _dir] call ALIVE_fnc_hashSet;
                                            [_markersHash, QGVAR(size), [_width,_length/2]] call ALIVE_fnc_hashSet;
                                            [_markersHash, QGVAR(pos), _pos] call ALIVE_fnc_hashSet;
                                            _markersHash call ALIVE_fnc_inspectHash;
                                            // Create Marker
                                            _markerName = "LINE" + str(random 5000 + 1);
                                            [MOD(SYS_marker), "addMarker", [_markerName, _markersHash]] call ALiVE_fnc_marker;
                                        };
                                        default {
                                            // NO DRAW
                                        };
                                    };
                                } else {
                                    [_logic, "drawing", true] call ALIVE_fnc_marker;
                                    GVAR(freeDrawCount) = 0;
                                     GVAR(startpoint) = _control ctrlMapScreenToWorld [_xPos, _yPos];
                                     GVAR(endpoint) = GVAR(startpoint);
                                    [_logic, "width",1] call ALIVE_fnc_marker;
                                    [_logic, "angle",0] call ALIVE_fnc_marker;
                                };
                            };

                        };
					} else {
						hint "You are not authorized to add/edit this marker";
					};
				} else {
					if (typeName _check != "BOOL") then {
						if ([_logic, "isAuthorized", [_check]] call ALIVE_fnc_marker) then {
							// delete marker
							[_logic, "removeMarker",[_check]] call ALIVE_fnc_marker;
						} else {
							hint "You are not authorized to delete this marker";
						};
						_result = false;
					};
				};

				_result = false;

			} else {
				_result = true;
			};
        };

		case "keyDown": {
			// Handles pressing of certain keys on map
            private ["_player","_shift","_alt","_ctr","_key","_toggle","_width","_angle","_display"];

//            diag_log str _this;

			_params = _args select 1;

            _display = _params select 0;
			_key = _params select 1;
			_shift = _params select 2;
            _ctr = _params select 3;
            _alt = _params select 4;

            _result = false;

            _toggle = [_logic, "drawToggle"] call ALIVE_fnc_marker;
            _width = [_logic, "width"] call ALIVE_fnc_marker;
            _angle = [_logic, "angle"] call ALIVE_fnc_marker;

			switch _key do {
				case (((["ALiVE", "mapDotMarker"] call cba_fnc_getKeybind) select 5) select 0): { 			// Press . to place a dot icon
                    private ["_color","_markersHash","_markerName"];
                    if (_ctr) then {
                        _color = [_logic, "color"] call ALIVE_fnc_marker;
                        _markersHash = [] call ALIVE_fnc_hashCreate;
                        [_markersHash, QGVAR(shape), "ICON"] call ALIVE_fnc_hashSet;
                        [_markersHash, QGVAR(type), "mil_dot"] call ALIVE_fnc_hashSet;
                        [_markersHash, QGVAR(size), [1,1]] call ALIVE_fnc_hashSet;
                        [_markersHash, QGVAR(pos), GVAR(mousePosition)] call ALIVE_fnc_hashSet;
                        [_markersHash, QGVAR(color), _color] call ALIVE_fnc_hashSet;
                        [_markersHash, QGVAR(alpha), 0.9] call ALIVE_fnc_hashSet;
                        [_markersHash, QGVAR(dir), _angle] call ALIVE_fnc_hashSet;
                        [_markersHash, QGVAR(locality), "SIDE"] call ALIVE_fnc_hashSet;
                        [_markersHash, QGVAR(localityValue), str(side (group player))] call ALIVE_fnc_hashSet;
                        [_markersHash, QGVAR(player), getPlayerUID player] call ALIVE_fnc_hashSet;
                        [_markersHash, QGVAR(hasspotrep), false] call ALIVE_fnc_hashSet;
                        _markerName = "DOT" + str(random 5000 + 1);
                        [MOD(SYS_marker), "addMarker", [_markerName, _markersHash]] call ALiVE_fnc_marker;
                        _result = true;
                    };
				};
				case (((["ALiVE", "mapObjMarker"] call cba_fnc_getKeybind) select 5) select 0): { 			// Press x to place objective marker
                    private ["_color","_markersHash","_markerName"];
                    if (_ctr) then {
                        _color = [_logic, "color"] call ALIVE_fnc_marker;
                        _markersHash = [] call ALIVE_fnc_hashCreate;
                        [_markersHash, QGVAR(shape), "ICON"] call ALIVE_fnc_hashSet;
                        [_markersHash, QGVAR(type), "mil_objective"] call ALIVE_fnc_hashSet;
                        [_markersHash, QGVAR(size), [1,1]] call ALIVE_fnc_hashSet;
                        [_markersHash, QGVAR(pos), GVAR(mousePosition)] call ALIVE_fnc_hashSet;
                        [_markersHash, QGVAR(color), _color] call ALIVE_fnc_hashSet;
                        [_markersHash, QGVAR(alpha), 0.9] call ALIVE_fnc_hashSet;
                        [_markersHash, QGVAR(dir), _angle] call ALIVE_fnc_hashSet;
                        [_markersHash, QGVAR(locality), "SIDE"] call ALIVE_fnc_hashSet;
                        [_markersHash, QGVAR(localityValue), str(side (group player))] call ALIVE_fnc_hashSet;
                        [_markersHash, QGVAR(player), getPlayerUID player] call ALIVE_fnc_hashSet;
                        [_markersHash, QGVAR(hasspotrep), false] call ALIVE_fnc_hashSet;
                        _markerName = "OBJ" + str(random 5000 + 1);
                        [MOD(SYS_marker), "addMarker", [_markerName, _markersHash]] call ALiVE_fnc_marker;
                        _result = true;
                    };
				};
                case (((["ALiVE", "mapUnkMarker"] call cba_fnc_getKeybind) select 5) select 0): {          // Press ? to place unknown marker
                    private ["_color","_markersHash","_markerName"];
                    if (_shift && _ctr) then {
                        _color = [_logic, "color"] call ALIVE_fnc_marker;
                        _markersHash = [] call ALIVE_fnc_hashCreate;
                        [_markersHash, QGVAR(shape), "ICON"] call ALIVE_fnc_hashSet;
                        [_markersHash, QGVAR(type), "mil_unknown"] call ALIVE_fnc_hashSet;
                        [_markersHash, QGVAR(size), [1,1]] call ALIVE_fnc_hashSet;
                        [_markersHash, QGVAR(pos), GVAR(mousePosition)] call ALIVE_fnc_hashSet;
                        [_markersHash, QGVAR(color), _color] call ALIVE_fnc_hashSet;
                        [_markersHash, QGVAR(alpha), 0.9] call ALIVE_fnc_hashSet;
                        [_markersHash, QGVAR(dir), _angle] call ALIVE_fnc_hashSet;
                        [_markersHash, QGVAR(locality), "SIDE"] call ALIVE_fnc_hashSet;
                        [_markersHash, QGVAR(localityValue), str(side (group player))] call ALIVE_fnc_hashSet;
                        [_markersHash, QGVAR(player), getPlayerUID player] call ALIVE_fnc_hashSet;
                        [_markersHash, QGVAR(hasspotrep), false] call ALIVE_fnc_hashSet;
                        _markerName = "UNKN" + str(random 5000 + 1);
                        [MOD(SYS_marker), "addMarker", [_markerName, _markersHash]] call ALiVE_fnc_marker;
                        _result = true;
                    };
                };
				case (((["ALiVE", "mapCycleDraw"] call cba_fnc_getKeybind) select 5) select 0):{ 			// Press [ to cycle drawing mode
                    if (_toggle == ELLIPSE_DRAW) then {
                        private ["_title","_control"];
                    	[_logic, "drawToggle", NO_DRAW] call ALIVE_fnc_marker;
                        _title =  "DRAW MODE OFF";
                        hintSilent _title;
                        _control = _display displayCtrl SYS_MARKER_MAP_TEXT;
                        _control ctrlSetText _title;
                    } else {
                        private ["_title","_msg","_control"];
                    	[_logic, "drawToggle", _toggle + 1] call ALIVE_fnc_marker;
                        switch (_toggle + 1) do {
                            case FREE_DRAW: {           // Free Draw
                                hintSilent "Free Draw Mode";
                           };
                            case ARROW_DRAW: {          // Free Arrow Draw
                                _title = "Arrow Draw Mode";
                                 _msg = "Press [Left Ctrl] + [LMB] to select start point.<br/>Press [Left Arrow] to change color.<br/>Press [Right Arrow] to toggle fill<br/>Press [Left Ctrl] + [LMB] again to finish.<br/>Press [END] to cancel.<br/>Press [Left Bracket] to cycle draw mode.";
                            };
                            case ELLIPSE_DRAW: {            // Free Ellipse Draw
                                _title =  "Ellipse Draw Mode";
                                _msg = "Press [Left Ctrl] + [LMB] to select start point.<br/>Press [Left Arrow] to change color.<br/>Press [Right Arrow] to toggle fill<br/>Press [Up Arrow] to rotate clockwise<br/>Press [Down Arrow] to rotate counter-clockwise<br/>Press [Left Ctrl] + [LMB] again to finish.<br/>Press [END] to cancel.<br/>Press [Left Bracket] to cycle draw mode.<br/>Press [Left Ctrl] + [RMB] to delete"
                            };
                            case RECTANGLE_DRAW: {          // Free Rectangle Draw
                                _title =  "Rectangle Draw Mode";
                                _msg = "Press [Left Ctrl] + [LMB] to select start point.<br/>Press [Left Arrow] to change color.<br/>Press [Right Arrow] to toggle fill<br/>Press [Up Arrow] to rotate clockwise<br/>Press [Down Arrow] to rotate counter-clockwise<br/>Press [Left Ctrl] + [LMB] again to finish.<br/>Press [END] to cancel.<br/>Press [Left Bracket] to cycle draw mode.<br/>Press [Left Ctrl] + [RMB] to delete"
                            };
                            case LINE_DRAW: {           // Free Line Draw
                                _title =  "Line Draw Mode";
                                _msg = "Press [Left Ctrl] + [LMB] to select start point.<br/>Press [Left Arrow] to change color.<br/>Press [Right Arrow] to toggle fill<br/>Press [Up Arrow] to increase width<br/>Press [Down Arrow] to decrease width<br/>Press [Left Ctrl] + [LMB] again to finish.<br/>Press [END] to cancel.<br/>Press [Left Bracket] to cycle draw mode.<br/>Press [Left Ctrl] + [RMB] to delete"
                            };
                            default {
                                _title =  "DRAW MODE OFF";
                                _msg = "";
                            };
                        };
                        [_title, _msg] call ALIVE_fnc_sendHint;
                        // Update the map screen to show the mode
                        _control = _display displayCtrl SYS_MARKER_MAP_TEXT;
                        _control ctrlSetText _title;
                    };
                    _result = true;
				};
				case (((["ALiVE", "mapEndDraw"] call cba_fnc_getKeybind) select 5) select 0):{ 			// Press END to stop drawing
                    private ["_title","_control"];
                    [_logic, "drawToggle", NO_DRAW] call ALIVE_fnc_marker;
					[_logic, "drawing", false] call ALIVE_fnc_marker;
                    _title =  "DRAW MODE OFF";
                    hintSilent _title;
                    _control = _display displayCtrl SYS_MARKER_MAP_TEXT;
                    _control ctrlSetText _title;
                    _result = true;
				};
				case (((["ALiVE", "mapIncLine"] call cba_fnc_getKeybind) select 5) select 0):{ 			// Press up arrow to increase width
                    if (_toggle == RECTANGLE_DRAW || _toggle == ELLIPSE_DRAW) then {
                        if (_angle == 360) then {
                           [_logic, "angle", 0] call ALIVE_fnc_marker;
                        } else {
                            [_logic, "angle", _angle + 5] call ALIVE_fnc_marker;
                        };
                    } else {
    					if (_width == 20) then {
    					   [_logic, "width", 1] call ALIVE_fnc_marker;
    					} else {
    						[_logic, "width", _width + 1] call ALIVE_fnc_marker;
    					};
                    };
                    _result = true;
				};
				case (((["ALiVE", "mapDecLine"] call cba_fnc_getKeybind) select 5) select 0):{ 			// Press down arrow to decrease width
                    if (_toggle == RECTANGLE_DRAW || _toggle == ELLIPSE_DRAW) then {
                        if (_angle == 0) then {
                           [_logic, "angle", 360] call ALIVE_fnc_marker;
                        } else {
                            [_logic, "angle", _angle - 5] call ALIVE_fnc_marker;
                        };
                    } else {
    					if (_width == 1) then {
    					   [_logic, "width", 20] call ALIVE_fnc_marker;
    					} else {
    						[_logic, "width", _width - 1] call ALIVE_fnc_marker;
    					};
                    };
                    _result = true;
				};
				case (((["ALiVE", "mapChgColor"] call cba_fnc_getKeybind) select 5) select 0):{ 			// Press left arrow to change color
                    private "_colorRGBA";
                    if (GVAR(colorChoice) == count GVAR(colorList)) then {
                        GVAR(colorChoice) = 0;
                    } else {
                        GVAR(colorChoice) = GVAR(colorChoice) + 1;
                    };
                    [_logic, "color", GVAR(colorList) select GVAR(colorChoice)] call ALIVE_fnc_marker;

                    // Update the fill too
                     if ([_logic, "fill"] call ALIVE_fnc_marker != "") then {
                         _colorRGBA = (configfile >> "cfgmarkercolors" >> (GVAR(colorList) select GVAR(colorChoice)) >> "color") call BIS_fnc_colorConfigToRGBA;
                        [_logic, "fill", (_colorRGBA) call bis_fnc_colorRGBAtoTexture] call ALIVE_fnc_marker;
                    };

                    _result = true;
				};
				case (((["ALiVE", "mapChgFill"] call cba_fnc_getKeybind) select 5) select 0):{ 			// Press right arrow to fill
                    private ["_color","_colorClass"];
                    if ([_logic, "fill"] call ALIVE_fnc_marker == "") then {
                         _colorClass = [_logic,"color"] call ALiVE_fnc_marker;
                        _color = (configfile >> "cfgmarkercolors" >> _colorClass >> "color") call BIS_fnc_colorConfigToRGBA;
					   [_logic, "fill", (_color) call bis_fnc_colorRGBAtoTexture] call ALIVE_fnc_marker;
                    } else {
                       [_logic, "fill", ""] call ALIVE_fnc_marker;
                    };
                    _result = true;
				};
				default { _result = false };
			};
		};

		case "mouseMoving": {
            private ["_control", "_xPos", "_yPos", "_start", "_end","_toggle","_params","_pos"];

            _params = _args select 1;
			_control = _params select 0;
			_xPos = _params select 1;
			_yPos = _params select 2;

            _pos = _control ctrlMapScreenToWorld [_xPos, _yPos];

            GVAR(mousePosition) = _pos;

			// Handles drawing
			_drawing = [_logic, "drawing"] call ALIVE_fnc_marker;

            if (_drawing) then {
    			// Check drawing toggle
                _toggle = [_logic, "drawToggle"] call ALIVE_fnc_marker;
    			switch _toggle do {
    				case FREE_DRAW: {			// Free Draw
                        hintSilent "Free Draw Mode";
                        GVAR(endpoint) = _pos;
    				};
    				case ARROW_DRAW: {			// Free Arrow Draw

                        GVAR(endpoint) = _pos;
    				};
    				case ELLIPSE_DRAW: {			// Free Ellipse Draw

                        GVAR(endpoint) = _pos;
    				};
    				case RECTANGLE_DRAW: {			// Free Rectangle Draw

                        GVAR(endpoint) = _pos;
    				};
    				case LINE_DRAW: {			// Free Line Draw

                        GVAR(endpoint) = _pos;
    				};
    				default {
    					// NO DRAW
    				};
    			};
            };
		};

		case "draw": {
			private ["_control", "_toggle","_drawing"];
			_control = (_args select 1) select 0;
			_toggle = [_logic, "drawToggle"] call ALIVE_fnc_marker;
			_drawing = [_logic, "drawing"] call ALIVE_fnc_marker;

            if (_toggle != NO_DRAW  && _drawing) then {
                private ["_width","_colorClass","_angle","_fill","_color"];
                _width = [_logic, "width"] call ALIVE_fnc_marker;
                _colorClass = [_logic, "color"] call ALIVE_fnc_marker;
                _angle = [_logic, "angle"] call ALIVE_fnc_marker;
                _fill = [_logic, "fill"] call ALIVE_fnc_marker;

                _color = (configfile >> "cfgmarkercolors" >> _colorClass >> "color") call BIS_fnc_colorConfigToRGBA;

				// Check drawing toggle
				switch _toggle do {
					case FREE_DRAW: {
						_control drawLine [GVAR(startpoint), GVAR(endpoint), _color];
                        GVAR(freeDrawCount) = GVAR(freeDrawCount) + 1;
                        if (GVAR(freeDrawCount) > 10) then {
                            if !( [GVAR(startpoint),GVAR(endpoint)] call BIS_fnc_areEqual ) then {
                                private "_mkrname";
                                // create a rectangle marker from the line info
                                _mkrname = "FREE" + str(random time + 1);
                                [_mkrname, GVAR(startpoint), GVAR(endpoint), _width, _color, 0.8] call ALiVE_fnc_createLineMarker;

                            };
                            GVAR(freeDrawCount) = 0;
                            GVAR(startpoint) = GVAR(endpoint);
                        };
					};
					case ARROW_DRAW: {
                        _control drawArrow [GVAR(startpoint), GVAR(endpoint), _color];
    				};
					case ELLIPSE_DRAW: {
                        _control drawEllipse [GVAR(startpoint), abs ((GVAR(endpoint) select 0) - (GVAR(startpoint) select 0)), abs ((GVAR(endpoint) select 1) - (GVAR(startpoint) select 1)), _angle, _color, _fill];
					};
					case RECTANGLE_DRAW: {
                        _control drawRectangle [GVAR(startpoint), abs ((GVAR(endpoint) select 0) - (GVAR(startpoint) select 0)), abs ((GVAR(endpoint) select 1) - (GVAR(startpoint) select 1)), _angle, _color, _fill];
					};
					case LINE_DRAW: {
                        for "_i" from 0 to _width do {
                            private ["_sx","_sy","_ex","_ey"];
                            _sx = (GVAR(startpoint) select 0) + _i;
                            _sy = (GVAR(startpoint) select 1) + _i;
                            _ex = (GVAR(endpoint) select 0) + _i;
                            _ey = (GVAR(endpoint) select 1) + _i;
                            _control drawLine [[_sx, _sy], [_ex, _ey], _color];
                        };

					};
				};
            };

            {
                _control drawArrow [_x select 0, _x select 1, _x select 2];
            } foreach GVAR(arrowList);

		};

       case "state": {

            TRACE_1("ALiVE SYS marker state called",_logic);

            if ((isnil "_args") || {!isServer}) exitwith {
                _result = GVAR(STORE)
            };

            // State is being set - restore markers

            _result = GVAR(STORE);
        };

        case "drawToggle": {
            _result = [_logic,_operation,_args,DEFAULT_TOGGLE] call ALIVE_fnc_OOsimpleOperation;
        };

        case "drawing": {
            _result = [_logic,_operation,_args,false] call ALIVE_fnc_OOsimpleOperation;
        };

        case "color": {
            _result = [_logic,_operation,_args, "ColorBLUFOR"] call ALIVE_fnc_OOsimpleOperation;
        };

        case "angle": {
            _result = [_logic,_operation,_args,0] call ALIVE_fnc_OOsimpleOperation;
        };

        case "width": {
            _result = [_logic,_operation,_args,1] call ALIVE_fnc_OOsimpleOperation;
        };

        case "fill": {
            private ["_color","_colorClass"];
            _colorClass = [_logic,"color"] call ALiVE_fnc_marker;
            _color = (configfile >> "cfgmarkercolors" >> _colorClass >> "color") call BIS_fnc_colorConfigToRGBA;
            _result = [_logic,_operation,_args,(_color) call bis_fnc_colorRGBAtoTexture] call ALIVE_fnc_OOsimpleOperation;
        };

        case "isAuthorized": {
            private "_marker";
            _marker = _args select 0;

            if (typeName _marker == "BOOL") then {
                _result = isPlayer player;
            } else {
                // If player owns marker, or player is admin or player is higher rank than owner
                _result = true;
            };
        };

        case "onMarker": {
            // Check to see if cursor is on a marker

            private ["_markerName", "_markerPos", "_marker","_obj","_pos"];

            _pos = _args select 0;
            _result = false;

            // Find nearest marker
            _markerName = "";
            _markerPos = [0,0,0];
            {
                _marker = _x;
                if ((getmarkerpos _marker) distance _pos < _markerPos distance _pos) then {
                    _markerName = _marker;
                    _markerPos = getmarkerPos _marker;
                };
            } foreach (GVAR(STORE) select 1);

            LOG(_markerName);

            // See if position is inside nearest marker
            if (markerShape _markerName != "ICON") then {
                _obj = "Land_Can_Rusty_F" createVehicleLocal _pos;
                _result = [_obj, _markerName] call ALIVE_fnc_inArea;
                deleteVehicle _obj;
                if (_result) then {_result = _markerName};
            } else {
                _scale = ctrlMapScale ((findDisplay 12) displayCtrl 51);
                if (_scale * 160 > ((getmarkerpos _markerName) distance _pos)) then {
                    _result = _markerName;
                };
            };

        };

        case "loadMarkers": {
            // Get markers from DB
            _result = call ALIVE_fnc_markerLoadData;
        };

        case "restoreMarkers": {
            // Create markers from the store locally (run on clients only)
            private ["_restoreMarkers","_hash","_i"];

            _hash = _args select 0;


            _restoreMarkers = {
                private "_locality";
                LOG(str _this);
                _locality = [_value, QGVAR(locality),"SIDE"] call ALIVE_fnc_hashGet;
                switch _locality do {
                    case "SIDE": {
                        if ( str(side (group player)) == [_value, QGVAR(localityValue), ""] call ALiVE_fnc_hashGet) then {
                            [MOD(SYS_marker), "createMarker", [_key,_value]] call ALIVE_fnc_marker;
                        };
                    };
                    case "GROUP": {
                        if (str(group player) == [_value, QGVAR(localityValue),""] call ALiVE_fnc_hashGet) then {
                            [MOD(SYS_marker), "createMarker", [_key,_value]] call ALIVE_fnc_marker;
                        };
                    };
                    case "FACTION": {
                        [MOD(SYS_marker), "createMarker", [_key,_value,  [_value, QGVAR(localityValue)] call ALiVE_fnc_hashGet]] call ALIVE_fnc_marker;
                    };
                    case "LOCAL": {
                        if ( (getPlayerUID player) == [_value, QGVAR(player), ""] call ALiVE_fnc_hashGet) then {
                            [MOD(SYS_marker), "createMarker", [_key,_value]] call ALIVE_fnc_marker;
                        };
                    };
                    case default {
                        [MOD(SYS_marker), "createMarker", [_key,_value]] call ALIVE_fnc_marker;
                    };
                };

            };

            [_hash, _restoreMarkers] call CBA_fnc_hashEachPair;

            _result = true;

        };

        case "createMarker": {
            // Handles creating a marker on the map
            // Accepts a hash as input (either from loading or from UI)
            private ["_markerName","_markerHash","_check"];
            _markerName = _args select 0;
            _markerHash = _args select 1;
            _check = false;
            _result = false;

            if (hasInterface) then {

                if (count _args > 2) then {
                    if (faction player == (_args select 2)) then {_check = true};
                } else {
                    _check = true;
                };

                if (_check) then {
                    [
                        _markerName,
                        [_markerHash, QGVAR(pos)] call ALiVE_fnc_hashGet,
                        [_markerHash, QGVAR(shape)] call ALiVE_fnc_hashGet,
                        [_markerHash, QGVAR(size)] call ALiVE_fnc_hashGet,
                        [_markerHash, QGVAR(color)] call ALiVE_fnc_hashGet,
                        [_markerHash, QGVAR(text)] call ALiVE_fnc_hashGet,
                        [_markerHash, QGVAR(type),""] call ALiVE_fnc_hashGet,
                        [_markerHash, QGVAR(brush),""] call ALiVE_fnc_hashGet,
                        [_markerHash, QGVAR(dir),0] call ALiVE_fnc_hashGet,
                        [_markerHash, QGVAR(alpha),1] call ALiVE_fnc_hashGet
                    ] call ALIVE_fnc_createMarker;

                    _result = true;
                };
            };

        };

        case "addMarker": {
        	// Adds a marker to the store on the server and creates markers on necessary clients
            // Expects a markername and hash as input.

            private ["_markerName","_markerHash","_marker"];
            _markerName = _args select 0;
            _markerHash = _args select 1;

            // Add marker to marker store on all localities
            [[_logic, "addMarkerToStore", [_markerName, _markerHash]], "ALIVE_fnc_marker",true,false,true] call BIS_fnc_MP;


            // Create Marker

            switch ([_markerHash, QGVAR(locality), "SIDE"] call ALIVE_fnc_hashGet) do {
                case "GLOBAL": {
                    [[_logic,"createMarker",[_markerName,_markerHash]], "ALIVE_fnc_marker", nil, false, true] call BIS_fnc_MP;
                };
                case "SIDE": {
                    [[_logic,"createMarker",[_markerName,_markerHash]], "ALIVE_fnc_marker", side (group player), false, true] call BIS_fnc_MP;
                };
                case "GROUP": {
                    [[_logic,"createMarker",[_markerName,_markerHash]], "ALIVE_fnc_marker", group player, false, true] call BIS_fnc_MP;
                };
                case "FACTION": {
                    [[_logic,"createMarker",[_markerName,_markerHash, faction player]], "ALIVE_fnc_marker", nil, false, true] call BIS_fnc_MP;
                };
                case "LOCAL": {
                    [_logic,"createMarker",[_markerName,_markerHash]] call ALIVE_fnc_marker;
                };
            };
            _result = _markerName;
        };

        case "addStandardMarker": {
            // Adds a marker to the store on the server
            // Expects marker and locality as input
            private "_marker";
            _marker = _args select 0;

            _markersHash = [] call ALIVE_fnc_hashCreate;
            [_markersHash, QGVAR(color), getMarkerColor _marker] call ALIVE_fnc_hashSet;
            [_markersHash, QGVAR(size), getMarkerSize _marker] call ALIVE_fnc_hashSet;
            [_markersHash, QGVAR(pos), getMarkerPos _marker] call ALIVE_fnc_hashSet;
            [_markersHash, QGVAR(type), getMarkerType _marker] call ALIVE_fnc_hashSet;
            [_markersHash, QGVAR(alpha), markerAlpha _marker] call ALIVE_fnc_hashSet;
            [_markersHash, QGVAR(brush), markerBrush _marker] call ALIVE_fnc_hashSet;
            [_markersHash, QGVAR(dir), markerDir _marker] call ALIVE_fnc_hashSet;
            [_markersHash, QGVAR(text), markerText _marker] call ALIVE_fnc_hashSet;
            [_markersHash, QGVAR(shape), MarkerShape _marker] call ALIVE_fnc_hashSet;
            [_markersHash, QGVAR(locality), _args select 1] call ALIVE_fnc_hashSet;

            if (isDedicated) then {
                _markersHash = [_markersHash] call ALIVE_fnc_hashAddWarRoomData;
            };

            _result = _markersHash;
        };

        case "addMarkerToStore": {
             private ["_markerName","_markerHash"];
            _markerName = _args select 0;
            _markerHash = _args select 1;

            if (isDedicated) then {
                _markerHash = [_markerHash] call ALIVE_fnc_hashAddWarRoomData;
            };

            [GVAR(STORE), _markerName, _markerHash] call ALIVE_fnc_hashSet;

            _result = GVAR(STORE);
        };


        case "editMarker": {
            // Handles editing a marker on the map
        };

        case "removeMarker": {
            // Removes a marker from the store
            private ["_markerName","_markerHash","_marker"];
            _markerName = _args select 0;

            _markerHash = [GVAR(STORE),_markerName] call ALIVE_fnc_hashGet;

            // Remove spotrep if necessary
            if ([_markerHash, QGVAR(hasspotrep), false] call ALIVE_fnc_hashGet) then {
                private "_spotrep";
               _spotrep = [_markerHash, QGVAR(spotrep)] call ALIVE_fnc_hashGet;
                [MOD(sys_spotrep), "removespotrep",[_spotrep]] call ALIVE_fnc_spotrep;
            };

            _result = false;

            // Delete Marker
            switch ([_markerHash, QGVAR(locality), "SIDE"] call ALIVE_fnc_hashGet) do {
                case "SIDE": {
                    [[_logic,"deleteMarker",[_markerName]], "ALIVE_fnc_marker", side (group player), false, true] call BIS_fnc_MP;
                };
                case "GROUP": {
                    [[_logic,"deleteMarker",[_markerName]], "ALIVE_fnc_marker", group player, false, true] call BIS_fnc_MP;
                };
                case "FACTION": {
                   [[_logic,"deleteMarker",[_markerName, faction player]], "ALIVE_fnc_marker", true, false, true] call BIS_fnc_MP;
                };
                case "LOCAL": {
                    [_logic,"deleteMarker",[_markerName]] call ALIVE_fnc_marker;
                };
                case default {
                    [[_logic,"deleteMarker",[_markerName]], "ALIVE_fnc_marker", true, false, true] call BIS_fnc_MP;
                };
            };

            // Remove marker from store on all localities
            [[_logic, "deleteMarkerFromStore", [_markerName, _markerHash]], "ALIVE_fnc_marker",true,false,true] call BIS_fnc_MP;


            _result = GVAR(STORE);

        };

        case "deleteMarker": {
            // Handles deleting a marker on the map
            // Expects a markername as input
            private ["_markerName","_check"];
            _markerName = _args select 0;

            LOG(str _this);
            _check = false;

            if (hasInterface) then {

                if (count _args > 1) then {
                    if (faction player == (_args select 1)) then {_check = true};
                } else {
                    _check = true;
                };

                if (_check) then {
                    LOG("Deleting marker...");
                    LOG(_markerName);
                    deleteMarkerLocal _markerName;
                };
            };

            _result = _check;
        };

        case "deleteMarkerFromStore": {
             private ["_markerName"];
            _markerName = _args select 0;
            _markerHash = _args select 1;

            If (isDedicated) then {
                private "_response";
                _response = [_markerName, _markerHash] call ALIVE_fnc_markerDeleteData;
                TRACE_1("Delete Marker", _response);
            };

            [GVAR(STORE), _markerName] call ALIVE_fnc_hashRem;

            _result = GVAR(STORE);
        };

        case "deleteAllMarkers": {
            // Delete all markers on the map
        };

        case "destroy": {
            [[_logic, "destroyGlobal",_args],"ALIVE_fnc_marker",true, false] call BIS_fnc_MP;
        };

        case "destroyGlobal": {

                [_logic, "debug", false] call MAINCLASS;

                if (isServer) then {
                		// if server
                        MOD(SYS_marker) = _logic;

                        MOD(SYS_marker) setVariable ["super", nil];
                        MOD(SYS_marker) setVariable ["class", nil];
                        MOD(SYS_marker) setVariable ["init", nil];

                        [_logic, "destroy"] call SUPERCLASS;

                        // and publicVariable to clients
                         MOD(SYS_marker) = _logic;
                        publicVariable QMOD(SYS_marker);
                };

                if (hasInterface) then {
                };
        };

        default {
            _result = [_logic, _operation, _args] call SUPERCLASS;
        };
};


TRACE_1("ALiVE SYS marker - output",_result);

if !(isnil "_result") then {
    _result;
};
