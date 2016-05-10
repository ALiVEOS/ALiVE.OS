#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(getGroupsDataSource);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_getGroupsDataSource

Description:
Get current groups info formatted for a UI datasource

Parameters:


Returns:
Array - Multi dimensional array of values and options

Examples:
(begin example)
_datasource = call ALiVE_fnc_getGroupsDataSource
(end)

Author:
ARJay
 
Peer reviewed:
nil
---------------------------------------------------------------------------- */

private ["_side","_faction","_sideNumber","_leaderSide","_leaderSideNumber","_matched","_data","_playerRows","_playerValues",
"_rows","_values","_groups","_leaderFaction","_leaderSide","_leaderSideNumber","_row","_labels","_rank","_containsPlayers",
"_vehicle","_vehicleName","_vehiclePosition","_playerType","_leaderType","_unitName","_leader"];

_player = _this select 0;
_side = _this select 1;
DEFAULT_PARAM(2,_faction,nil);

_sideNumber = [_side] call ALIVE_fnc_sideTextToNumber;
_data = [];
_playerRows = [];
_playerValues = [];
_rows = [];
_values = [];
_groups = allGroups;

{
    if !(isnull _x) then {

        _leaderFaction = faction leader _x;
	    _leaderSide = _leaderFaction call ALiVE_fnc_FactionSide;
	    _leaderSideNumber = [_leaderSide] call ALIVE_fnc_sideObjectToNumber;

	    _matched = false;

	    if(_sideNumber == _leaderSideNumber) then {
            _matched = true;
        };

	    if!(isNil "_faction") then {
	        if(_faction == _leaderFaction) then {
                _matched = true;
	        }else{
                _matched = false;
	        };
	    };

	    if(_matched) then {

	        _row = [];
	        _labels = [];

	        _distance = floor (player distance leader _x);

	        _labels pushback (format['%1 [%2m] ---------------------------------------------------------------------',_x,_distance]);
	        _labels pushback ('');
	        _labels pushback ('');
	        _labels pushback ('');

	        _row pushback (_labels);

	        _containsPlayers = false;

	        {

                if(alive _x && isPlayer _x) then {
                    _containsPlayers = true;
                };
            } forEach units _x;


            if(_containsPlayers) then {

                _playerRows pushback (_row);
                _playerValues pushback (_x);

            }else{

                _rows pushback (_row);
                _values pushback (_x);

            };

            _row = [];
            _labels = [];

            _leader = leader _x;

            _rank = '';

            switch(rank _leader) do {
                case 'PRIVATE':{
                    _rank = 'PVT ';
                };
                case 'CORPORAL':{
                    _rank = 'CPL ';
                };
                case 'SERGEANT':{
                    _rank = 'SGT ';
                };
                case 'LIEUTENANT':{
                    _rank = 'LT ';
                };
                case 'CAPTAIN':{
                    _rank = 'CAPT ';
                };
                case 'MAJOR':{
                    _rank = 'MAJ ';
                };
                case 'COLONEL':{
                    _rank = 'COL ';
                };
            };

            _unitName = format["%1 ",name _leader];
            _vehicleName = "";
            _vehiclePosition = "";

            if!(vehicle _leader == _leader) then {

                _vehicle = assignedVehicle _leader;
                _vehicleName = getText (configFile >> "CfgVehicles" >> (typeOf vehicle _leader) >> "DisplayName");

                if((driver _vehicle == _leader) || (gunner _vehicle == _leader)) then
                {
                    if(driver _vehicle == _leader) then {
                        _vehiclePosition = "- Driver";
                    }else{
                        _vehiclePosition = "- Gunner";
                    };
                }else{
                    _vehiclePosition = "- Cargo";
                };
            };

            _playerType = "AI ";
            if(isPlayer _leader) then {
                _playerType = "Player ";
            };

            _labels pushback (format['%1%2%3%4 %5', _playerType, _rank, _unitName, _vehiclePosition, _vehicleName]);

            _row pushback (_labels);

            if(_containsPlayers) then {

                _playerRows pushback (_row);
                _playerValues pushback (_leader);

            }else{

                _rows pushback (_row);
                _values pushback (_leader);

            };


	        {

            	if(alive _x && _x != _leader) then {

                    _row = [];
                    _labels = [];
                    _rank = '';

                    switch(rank _x) do {
                        case 'PRIVATE':{
                            _rank = 'PVT ';
                        };
                        case 'CORPORAL':{
                            _rank = 'CPL ';
                        };
                        case 'SERGEANT':{
                            _rank = 'SGT ';
                        };
                        case 'LIEUTENANT':{
                            _rank = 'LT ';
                        };
                        case 'CAPTAIN':{
                            _rank = 'CAPT ';
                        };
                        case 'MAJOR':{
                            _rank = 'MAJ ';
                        };
                        case 'COLONEL':{
                            _rank = 'COL ';
                        };
                    };

                    _unitName = format["%1 ",name _x];
                    _vehicleName = "";
                    _vehiclePosition = "";

                    if!(vehicle _x == _x) then {

                        _vehicle = assignedVehicle _x;
                        _vehicleName = getText (configFile >> "CfgVehicles" >> (typeOf vehicle _x) >> "DisplayName");

                        if((driver _vehicle == _x) || (gunner _vehicle == _x)) then
                        {
                            if(driver _vehicle == _x) then {
                                _vehiclePosition = "- Driver";
                            }else{
                                _vehiclePosition = "- Gunner";
                            };
                        }else{
                            _vehiclePosition = "- Cargo";
                        };
                    };

                    _playerType = "AI ";
                    if(isPlayer _x) then {
                        _playerType = "Player ";
                    };

                    _labels pushback (format['%1%2%3%4 %5', _playerType, _rank, _unitName, _vehiclePosition, _vehicleName]);

                    _row pushback (_labels);

                    if(_containsPlayers) then {

                        _playerRows pushback (_row);
                        _playerValues pushback (_x);

                    }else{

                        _rows pushback (_row);
                        _values pushback (_x);

                    };

            	};
            } forEach units _x;
	    };
    };
} foreach _groups;

_rows = _playerRows + _rows;
_values = _playerValues + _values;

_data pushback (_rows);
_data pushback (_values);

_data
