params ["_logic","_operation","_args"];

private "_result";

_grpUnits = [];
_xrayGroups = [alivegrp_xray,alivegrp_admin];

switch (_operation) do {
    case "create": {
        _args params ["_functionName"];
        
        private _logic = [
            [
                ["class", _functionName]
            ]
        ] call ALiVE_fnc_hashCreate;
    
        private _listenerID = [ALiVE_eventLog, "addListener", [_logic, ["OPCOM_ORDER_CONFIRMED","TACOM_ORDER_ISSUED"]]] call ALiVE_fnc_eventLog;
        
        [_logic,"listenerID", _listenerID] call ALiVE_fnc_hashSet;
        
        _result = _logic;
    };
    
    case "handleEvent": {
        private _event = _args;
        
        private _class = [_logic,"class"] call ALiVE_fnc_hashGet;
        private _thisFunction = missionNamespace getvariable _class;
        
        private _type = [_event,"type"] call ALiVE_fnc_hashGet;
        private _eventData = [_event,"data"] call ALiVE_fnc_hashGet;
        
        switch (_type) do {
            case "OPCOM_ORDER_CONFIRMED": {
                _eventData params ["_opcomID","_objective","_orderType","_opcomSide","_opcomFactions"];

                if (_opcomSide == "WEST" && _orderType == "attack") then {
                    private _objectivePosition = [_objective,"center"] call ALiVE_fnc_hashGet;
                    private _location = [_logic,"getClosestLocationName", [_objectivePosition]] call _thisFunction;
                //  systemchat format ["OPFOR is preparing an attack on %1", _location];
                
									 _title = "<t size='1.5' color='#68a7b7' shadow='1'>INTEL RECEIVED</t><br/>";
									 _text = format["%1<t>Axis forces are preparing an attack on %2</t>",_title,_location];
									 { _grpUnits append (units _x);} forEach _xrayGroups;
									 {["openSideSmall",0.4] remoteExecCall ["ALIVE_fnc_displayMenu", _x];
								   ["setSideSmallText",_text] remoteExecCall ["ALIVE_fnc_displayMenu", _x];} forEach (_grpUnits);
                };
                
                if (_opcomSide == "GUER" && _orderType == "attack") then {
                    private _objectivePosition = [_objective,"center"] call ALiVE_fnc_hashGet;
                    private _location = [_logic,"getClosestLocationName", [_objectivePosition]] call _thisFunction;
                //  systemchat format ["OPFOR is preparing an attack on %1", _location];
                
									 _title = "<t size='1.5' color='#68a7b7' shadow='1'>INTEL RECEIVED</t><br/>";
									 _text = format["%1<t>Allied forces are preparing an attack on %2</t>",_title,_location];
									 { _grpUnits append (units _x);} forEach _xrayGroups;
									 {["openSideSmall",0.4] remoteExecCall ["ALIVE_fnc_displayMenu", _x];
								   ["setSideSmallText",_text] remoteExecCall ["ALIVE_fnc_displayMenu", _x];} forEach (_grpUnits);
                };
                
            };
            case "TACOM_ORDER_ISSUED": {
                _eventData params ["_opcomID","_objective","_orderType","_opcomSide","_opcomFactions"];

                if (_opcomSide == "WEST" && _orderType == "capture") then {
                    private _objectivePosition = [_objective,"center"] call ALiVE_fnc_hashGet;
                    private _location = [_logic,"getClosestLocationName", [_objectivePosition]] call _thisFunction;
                //    systemchat format ["OPFOR is initiating it's attack on %1 ", _location];
                
									 _title = "<t size='1.5' color='#68a7b7' shadow='1'>INTEL RECEIVED</t><br/>";
									 _text = format["%1<t>Axis forces are initiating an attack on %2</t>",_title,_location];
									 { _grpUnits append (units _x);} forEach _xrayGroups;
									 {["openSideSmall",0.4] remoteExecCall ["ALIVE_fnc_displayMenu", _x];
								   ["setSideSmallText",_text] remoteExecCall ["ALIVE_fnc_displayMenu", _x];} forEach (_grpUnits);
                };
                
                 if (_opcomSide == "GUER" && _orderType == "capture") then {
                    private _objectivePosition = [_objective,"center"] call ALiVE_fnc_hashGet;
                    private _location = [_logic,"getClosestLocationName", [_objectivePosition]] call _thisFunction;
                //    systemchat format ["OPFOR is initiating it's attack on %1 ", _location];
                
									 _title = "<t size='1.5' color='#68a7b7' shadow='1'>INTEL RECEIVED</t><br/>";
									 _text = format["%1<t>Allied forces are initiating an attack on %2</t>",_title,_location];
									 { _grpUnits append (units _x);} forEach _xrayGroups;
									 {["openSideSmall",0.4] remoteExecCall ["ALIVE_fnc_displayMenu", _x];
								   ["setSideSmallText",_text] remoteExecCall ["ALIVE_fnc_displayMenu", _x];} forEach (_grpUnits);
                };
                
            };
        };
    };
    
    case "getClosestLocationName": {
        _args params [
            "_position",
            ["_locationTypes", ["NameVillage","NameCity","NameCityCapital","NameLocal","Strategic"]],
            ["_radius", 500]
        ];
        
        private _locations = nearestLocations [_position, _locationTypes, _radius];
        if (_locations isnotequalto []) then {
            private _nearestLocation = _locations select 0;
            
            _result = text _nearestLocation;
        } else {
            _result = "";
        };
    };
};

if (!isnil "_result") then {_result} else {nil};