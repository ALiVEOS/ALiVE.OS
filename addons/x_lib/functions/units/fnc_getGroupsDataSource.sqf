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

private ["_side","_sideNumber","_leaderSide","_leaderSideNumber","_data","_rows","_values","_groups","_row","_labels","_rank"];

_side = _this select 0;

_sideNumber = [_side] call ALIVE_fnc_sideTextToNumber;
_data = [];
_rows = [];
_values = [];
_groups = allGroups;

{
    if !(isnull _x) then {

	    _leaderSide = (faction leader _x) call ALiVE_fnc_FactionSide;
	    _leaderSideNumber = [_leaderSide] call ALIVE_fnc_sideObjectToNumber;

	    if(_sideNumber == _leaderSideNumber) then {

	        _row = [];
	        _labels = [];

	        _labels pushback (format['%1',_x]);
	        _labels pushback ('----------------------');
	        _labels pushback ('----------');
	        _labels pushback ('----');

	        _row pushback (_labels);

	        _rows pushback (_row);

	        _values pushback (_x);

	        {

            	if(alive _x) then {

                    _row = [];
                    _labels = [];
                    _rank = '';

                    switch(rank _x) do {
                        case 'PRIVATE':{
                            _rank = 'PVT';
                        };
                        case 'CORPORAL':{
                            _rank = 'CPL';
                        };
                        case 'SERGEANT':{
                            _rank = 'SGT';
                        };
                        case 'LIEUTENANT':{
                            _rank = 'LT';
                        };
                        case 'CAPTAIN':{
                            _rank = 'CAPT';
                        };
                        case 'MAJOR':{
                            _rank = 'MAJ';
                        };
                        case 'COLONEL':{
                            _rank = 'COL';
                        };
                    };

                    _labels pushback (format['%1',_rank]);

                    _labels pushback (format['%1',name _x]);

                    if(isPlayer _x) then {
                        _labels pushback ('Player');
                    }else{
                        _labels pushback ('AI');
                    };

                    if(isFormationLeader _x) then {
                        _labels pushback ('Lead');
                    };

                    _row pushback (_labels);

                    _rows pushback (_row);

                    _values pushback (_x);

            	};
            } forEach units _x;
	    };
    };
} foreach _groups;

_data pushback (_rows);
_data pushback (_values);

_data
