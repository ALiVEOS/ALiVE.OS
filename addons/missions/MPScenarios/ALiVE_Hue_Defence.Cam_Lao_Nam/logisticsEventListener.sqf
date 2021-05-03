params ["_logic","_operation","_args"];

private "_result";

private _grpUnits = [];
private _xrayGroups = [vn_alivegrp_xray_1,vn_alivegrp_xray_2];
	
switch (_operation) do {
    case "create": {
        _args params ["_functionName"];
        
        private _logic = [
            [
                ["class", _functionName]
            ]
        ] call ALiVE_fnc_hashCreate;
    
        private _listenerID = [ALiVE_eventLog, "addListener", [_logic, ["FORCEPOOL_UPDATED"]]] call ALiVE_fnc_eventLog;
        
        [_logic,"listenerID", _listenerID] call ALiVE_fnc_hashSet;
        
        _result = _logic;
    };
    
    case "handleEvent": {
        private _event = _args;
        
        private _class = [_logic,"class"] call ALiVE_fnc_hashGet;
        private _thisFunction = missionNamespace getvariable _class;
        
        private _type = [_event,"type"] call ALiVE_fnc_hashGet;
        private _eventData = [_event,"data"] call ALiVE_fnc_hashGet;
        
        private _forceStatus = "high";
				private _currentPercent = 100;
				private _currentPercentformatted = 100;
				private _factionmaxforcePool = 25;
				private _factionformatted = "PAVN";
				
        switch (_type) do {
            case "FORCEPOOL_UPDATED": {
                _eventData params ["_x","_forcePool"];

							  ["logisticsEventListener -> _forcePool: %1", _forcePool] call ALiVE_fnc_dump; 	
 								["logisticsEventListener -> _x: %1", _x] call ALiVE_fnc_dump; 	
 								
 								
 								if (_x == "O_PAVN") then {
 									_factionmaxforcePool = alive_forcepool_pavn;
 									_factionformatted = "PAVN";
 								};
 								
 								if (_x == "O_VC") then {
 									_factionmaxforcePool = alive_forcepool_vc;
 									_factionformatted = "VC";
 								};
 								
								_currentPercent = (_forcePool / _factionmaxforcePool) * 100;
							  _currentPercentformatted = floor _currentPercent;
							  
							  ["_currentPercent -> _currentPercent: %1", _currentPercent] call ALiVE_fnc_dump; 	
							  ["logisticsEventListener -> _currentPercentformatted: %1", _currentPercentformatted] call ALiVE_fnc_dump; 	

									if (_currentPercentformatted >=66 && _currentPercentformatted <=100) then {
									  _forceStatus = "high";
									};

									if (_currentPercentformatted >33 && _currentPercentformatted <66) then {
									  _forceStatus = "medium";
									};

									if (_currentPercentformatted >0 && _currentPercentformatted <=33) then {
									  _forceStatus = "low";
									};

									 _title = "<t size='1.5' color='#68a7b7' shadow='1'>INTEL RECEIVED</t><br/>";
									 _text = format["<t>CIDG reports %1 %2 reinforcement strength at %3 percent</t>", _forceStatus, _factionformatted, _currentPercentformatted];
									 { _grpUnits append (units _x);} forEach _xrayGroups;
									 {["openSideSmall",0.4] remoteExecCall ["ALIVE_fnc_displayMenu", _x];
								   ["setSideSmallText",_text] remoteExecCall ["ALIVE_fnc_displayMenu", _x];} forEach (_grpUnits);
		                
            
            };
        };
    };
};

if (!isnil "_result") then {_result} else {nil};