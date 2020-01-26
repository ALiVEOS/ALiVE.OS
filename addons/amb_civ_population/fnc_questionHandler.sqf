/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_questionHandler

Description:
Main handler for questions

Parameters:
String - Question

Returns:
none

Examples:
(begin example)
["Home"] call ALiVE_fnc_questionHandler; //-- Ask where they live
["Insurgents"] call ALiVE_fnc_questionHandler; //-- Ask if they've seen any insurgents
["StrangeBehavior"] call ALiVE_fnc_questionHandler; //-- Ask if they've seen any strange behavior
(end)

Notes:
Civilians will stay stay hostile after becoming hostile (persistent through menu closing)
Civilians may become annoyed when you keep asking questions, which will raise their hostility
Some responses are shared by the hostile and non-hostile sections, this is done to keep a gray line between hostile and non-hostile

See Also:
- nil

Author:
SpyderBlack723

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_civData","_civInfo","_hostile","_hostility","_asked","_civ","_answerGiven"];
params [
    ["_logic", objNull],
    ["_question", ""]
];

//-- Define control ID's
#define MAINCLASS ALiVE_fnc_civInteract
#define CIVINTERACT_RESPONSELIST (findDisplay 923 displayCtrl 9239)

//-- Get civ hostility
_hostile =  false;
_civData = [_logic, "CivData"] call ALiVE_fnc_hashGet;
_civInfo = [_civData, "CivInfo"] call ALiVE_fnc_hashGet;
_civ = [_logic, "Civ"] call ALiVE_fnc_hashGet;
_civName = name _civ;

//-- Set questions asked
_asked = ([_civData, "Asked"] call ALiVE_fnc_hashGet) + 1;
[_civData, "Asked", _asked] call ALiVE_fnc_hashSet;

if (!isNil {[_civData, "Hostile"] call ALiVE_fnC_hashGet}) then {
    _hostile = true;
} else {
    _hostility = _civInfo select 1;
    if (random 100 < _hostility) then {
        _hostile = true;
        [_civData, "Hostile", true] call ALiVE_fnc_hashSet;
    };
};

//-- Hash new data to logic
[_logic, "CivData", _civData] call ALiVE_fnc_hashSet;

//-- Get previous responses
_answersGiven = [_civData, "AnswersGiven"] call ALiVE_fnc_hashGet;

//-- Clear previous responses
CIVINTERACT_RESPONSELIST ctrlSetText "";

//-- Check if question has already been answered
if ((_question in _answersGiven) and (floor random 100 < 75)) exitWith {
    _response1 = localize "STR_ALIVE_CIV_INTERACT_ANSWERGIVEN_1";
    _response2 = localize "STR_ALIVE_CIV_INTERACT_ANSWERGIVEN_2";
    _response3 = localize "STR_ALIVE_CIV_INTERACT_ANSWERGIVEN_3";
    _response4 = localize "STR_ALIVE_CIV_INTERACT_ANSWERGIVEN_4";
    _response5 = localize "STR_ALIVE_CIV_INTERACT_ANSWERGIVEN_5";
    _response6 = localize "STR_ALIVE_CIV_INTERACT_ANSWERGIVEN_6";
    _response7 = localize "STR_ALIVE_CIV_INTERACT_ANSWERGIVEN_7";
    _response8 = localize "STR_ALIVE_CIV_INTERACT_ANSWERGIVEN_8";
    _response = [_response1,_response2,_response3,_response4,_response5,_response6,_response7,_response8] call BIS_fnc_selectRandom;
    CIVINTERACT_RESPONSELIST ctrlSetText _response;

    //-- Check if civilian is irritated
    [_logic,"isIrritated", [_hostile,_asked,_civ]] call MAINCLASS;
};

switch (_question) do {

    //-- Where is your home located
    case "Home": {
        _homePos = _civInfo select 0;

        if (!(_hostile) and (floor random 100 > 15)) then {
            _response1 = format [localize "STR_ALIVE_CIV_INTERACT_HOME_NOTHOSTILE_1", _civName];
            _response2 = format [localize "STR_ALIVE_CIV_INTERACT_HOME_NOTHOSTILE_2", _civName];
            _response3 = format [localize "STR_ALIVE_CIV_INTERACT_HOME_NOTHOSTILE_3", _civName];
            _response4 = format [localize "STR_ALIVE_CIV_INTERACT_HOME_NOTHOSTILE_4", _civName];
            _response5 = format [localize "STR_ALIVE_CIV_INTERACT_HOME_NOTHOSTILE_6", _civName];
            _response = [_response1,_response2,_response3,_response4,_response5] call BIS_fnc_selectRandom;
            CIVINTERACT_RESPONSELIST ctrlSetText _response;

            //-- Create marker on home
            _answersGiven pushBack "Home";_answerGiven = true;
            _markerName = format ["%1's home", _civName];
            _marker = [str _homePos, _homePos, "ICON", [.35, .35], "ColorCIV", _markerName, "mil_circle", "Solid", 0, .5] call ALIVE_fnc_createMarkerGlobal;
            _marker spawn {sleep 30;deleteMarker _this};
        } else {
            _response1 = localize "STR_ALIVE_CIV_INTERACT_HOME_HOSTILE_1";
            _response2 = localize "STR_ALIVE_CIV_INTERACT_HOME_HOSTILE_2";
            _response3 = localize "STR_ALIVE_CIV_INTERACT_HOME_HOSTILE_3";
            _response4 = localize "STR_ALIVE_CIV_INTERACT_HOME_HOSTILE_4";
            _response5 = localize "STR_ALIVE_CIV_INTERACT_HOME_HOSTILE_5";
            _response6 = localize "STR_ALIVE_CIV_INTERACT_HOME_HOSTILE_6";
            _response = [_response1,_response2,_response3,_response4,_response5,_response6] call BIS_fnc_selectRandom;
            CIVINTERACT_RESPONSELIST ctrlSetText _response;
        };
    };

    //-- What town do you live in
    case "Town": {
        _homePos = _civInfo select 0;
        _town = [_homePos] call ALIVE_fnc_taskGetNearestLocationName;

        if !(_hostile) then {
            if (floor random 100 > 15) then {
                _response1 = format [localize "STR_ALIVE_CIV_INTERACT_TOWN_NOTHOSTILE_1", _town];
                _response2 = format [localize "STR_ALIVE_CIV_INTERACT_TOWN_NOTHOSTILE_2", _town];
                _response3 = format [localize "STR_ALIVE_CIV_INTERACT_TOWN_NOTHOSTILE_3", _town];
                _response4 = format [localize "STR_ALIVE_CIV_INTERACT_TOWN_NOTHOSTILE_4", _town];
                _response5 = localize "STR_ALIVE_CIV_INTERACT_TOWN_NOTHOSTILE_5";
                _response6 = localize "STR_ALIVE_CIV_INTERACT_TOWN_NOTHOSTILE_6";
                _response = [_response1, _response2, _response3, _response4, _response5, _response6] call BIS_fnc_selectRandom;
                CIVINTERACT_RESPONSELIST ctrlSetText _response;
                _answersGiven pushBack "Town";_answerGiven = true;
            } else {
                _response1 = localize "STR_ALIVE_CIV_INTERACT_TOWN_BADLUCK_1";
                _response2 = localize "STR_ALIVE_CIV_INTERACT_TOWN_BADLUCK_2";
                _response3 = localize "STR_ALIVE_CIV_INTERACT_TOWN_BADLUCK_3";
                _response4 = localize "STR_ALIVE_CIV_INTERACT_TOWN_BADLUCK_4";
                _response5 = localize "STR_ALIVE_CIV_INTERACT_TOWN_BADLUCK_5";
                _response = [_response1,_response2,_response3,_response4,_response5] call BIS_fnc_selectRandom;
                CIVINTERACT_RESPONSELIST ctrlSetText _response;
            };
        } else {
            _response1 = localize "STR_ALIVE_CIV_INTERACT_TOWN_HOSTILE_1";
            _response2 = localize "STR_ALIVE_CIV_INTERACT_TOWN_HOSTILE_2";
            _response3 = localize "STR_ALIVE_CIV_INTERACT_TOWN_HOSTILE_3";
            _response4 = localize "STR_ALIVE_CIV_INTERACT_TOWN_HOSTILE_4";
            _response5 = localize "STR_ALIVE_CIV_INTERACT_TOWN_HOSTILE_5";
            _response6 = localize "STR_ALIVE_CIV_INTERACT_TOWN_HOSTILE_6";
            _response7 = localize "STR_ALIVE_CIV_INTERACT_TOWN_HOSTILE_7";
            _response = [_response1, _response2, _response3, _response4, _response5, _response6, _response7] call BIS_fnc_selectRandom;
            CIVINTERACT_RESPONSELIST ctrlSetText _response;
        };
    };

    //-- Have you seen any IED's nearby
    case "IEDs": {

        _IEDs = [];
        {
            if (_x distance2D (getPos _civ) < 1000) then {_IEDs pushBack _x};
        } forEach allMines;

        if (count _IEDs == 0) then {
            if !(_hostile) then {
                if (floor random 100 > 25) then {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_IEDS_NOPRESENCE_NOTHOSTILE_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_IEDS_NOPRESENCE_NOTHOSTILE_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_IEDS_NOPRESENCE_NOTHOSTILE_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_IEDS_NOPRESENCE_NOTHOSTILE_4";
                    _response = [_response1, _response2, _response3, _response4] call BIS_fnc_selectRandom;
                    CIVINTERACT_RESPONSELIST ctrlSetText _response;
                    _answersGiven pushBack "IEDs";_answerGiven = true;
                } else {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_IEDS_BADLUCK_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_IEDS_BADLUCK_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_IEDS_BADLUCK_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_IEDS_BADLUCK_4";
                    _response = [_response1, _response2, _response3, _response4] call BIS_fnc_selectRandom;
                    CIVINTERACT_RESPONSELIST ctrlSetText _response;
                };
            } else {
                _response1 = localize "STR_ALIVE_CIV_INTERACT_IEDS_HOSTILE_1";
                _response2 = localize "STR_ALIVE_CIV_INTERACT_IEDS_HOSTILE_2";
                _response3 = localize "STR_ALIVE_CIV_INTERACT_IEDS_HOSTILE_3";
                _response4 = localize "STR_ALIVE_CIV_INTERACT_IEDS_HOSTILE_4";
                _response5 = localize "STR_ALIVE_CIV_INTERACT_IEDS_HOSTILE_5";
                _response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
                CIVINTERACT_RESPONSELIST ctrlSetText _response;
            };

        } else {
            _iedLocation = getPos (_IEDs call BIS_fnc_selectRandom);

            if !(_hostile) then {
                if (floor random 100 > 25) then {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_IEDS_PRESENCE3_NOTHOSTILE_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_IEDS_PRESENCE_NOTHOSTILE_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_IEDS_PRESENCE_NOTHOSTILE_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_IEDS_PRESENCE_NOTHOSTILE_4";
                    _response = [_response1, _response2, _response3, _response4] call BIS_fnc_selectRandom;
                    CIVINTERACT_RESPONSELIST ctrlSetText _response;
                    _answersGiven pushBack "IEDs";_answerGiven = true;

                    //-- Create marker on IED
                    _iedPos = getPos (_IEDs call BIS_fnc_selectRandom);
                    _iedPos = [_iedPos, (25 + ceil random 15)] call CBA_fnc_randPos;
                    _marker = [str _iedPos, _iedPos, "ELLIPSE", [40, 40], "ColorRed", "IED", "n_installation", "FDiagonal", 0, 0.5] call ALIVE_fnc_createMarkerGlobal;
                    _text = [str (str _iedPos),_iedPos,"ICON", [0.1,0.1],"ColorRed","IED", "mil_dot", "FDiagonal",0,0.5] call ALIVE_fnc_createMarkerGlobal;
                    [_marker,_text] spawn {sleep 30;deleteMarker (_this select 0);deleteMarker (_this select 1)};
                } else {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_IEDS_BADLUCK_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_IEDS_BADLUCK_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_IEDS_BADLUCK_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_IEDS_BADLUCK_4";
                    _response = [_response1, _response2, _response3, _response4] call BIS_fnc_selectRandom;
                    CIVINTERACT_RESPONSELIST ctrlSetText _response;
                };
            } else {
                _response1 = localize "STR_ALIVE_CIV_INTERACT_IEDS_HOSTILE_1";
                _response2 = localize "STR_ALIVE_CIV_INTERACT_IEDS_HOSTILE_2";
                _response3 = localize "STR_ALIVE_CIV_INTERACT_IEDS_HOSTILE_3";
                _response4 = localize "STR_ALIVE_CIV_INTERACT_IEDS_HOSTILE_4";
                _response5 = localize "STR_ALIVE_CIV_INTERACT_IEDS_HOSTILE_5";
                _response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
                CIVINTERACT_RESPONSELIST ctrlSetText _response;
            };

        };
    };

    //-- Have you seen any insurgent activity lately
    case "Insurgents": {

        _insurgentFaction = [_logic, "InsurgentFaction"] call ALiVE_fnc_hashGet;
        _pos = getPos _civ;
        _town = [_pos] call ALIVE_fnc_taskGetNearestLocationName;

        //-- Get nearby insurgents
        _insurgents = [];
        {
            _leader = leader _x;

            if ((faction _leader == _insurgentFaction) and {_leader distance2D _pos < 1100}) then {
                _insurgents pushBack _leader;
            };
        } forEach allGroups;

        if (count _insurgents == 0) then {
            //-- Insurgents are not nearby
            if !(_hostile) then {
                if (floor random 100 > 40) then {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_INSURGENTS_NOPRESENCE_NOTHOSTILE_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_INSURGENTS_NOPRESENCE_NOTHOSTILE_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_INSURGENTS_NOPRESENCE_NOTHOSTILE_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_INSURGENTS_NOPRESENCE_NOTHOSTILE_4";
                    _response5 = localize "STR_ALIVE_CIV_INTERACT_INSURGENTS_NOPRESENCE_NOTHOSTILE_5";
                    _response = [_response1, _response2, _response3, _response4,_response5] call BIS_fnc_selectRandom;
                    CIVINTERACT_RESPONSELIST ctrlSetText _response;
                    _answersGiven pushBack "Insurgents";_answerGiven = true;
                } else {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_INSURGENTS_NOPRESENCE_BADLUCK_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_INSURGENTS_NOPRESENCE_BADLUCK_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_INSURGENTS_NOPRESENCE_BADLUCK_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_INSURGENTS_NOPRESENCE_BADLUCK_4";
                    _response5 = localize "STR_ALIVE_CIV_INTERACT_INSURGENTS_NOPRESENCE_BADLUCK_5";
                    _response = [_response1, _response2, _response3, _response4,_response5] call BIS_fnc_selectRandom;
                    CIVINTERACT_RESPONSELIST ctrlSetText _response;
                };
            } else {
                _response1 = localize "STR_ALIVE_CIV_INTERACT_INSURGENTS_NOPRESENCE_HOSTILE_1";
                _response2 = localize "STR_ALIVE_CIV_INTERACT_INSURGENTS_NOPRESENCE_HOSTILE_2";
                _response3 = localize "STR_ALIVE_CIV_INTERACT_INSURGENTS_NOPRESENCE_HOSTILE_3";
                _response4 = localize "STR_ALIVE_CIV_INTERACT_INSURGENTS_NOPRESENCE_HOSTILE_4";
                _response5 = localize "STR_ALIVE_CIV_INTERACT_INSURGENTS_NOPRESENCE_HOSTILE_5";
                _response = [_response1, _response2, _response3, _response4,_response5] call BIS_fnc_selectRandom;
                CIVINTERACT_RESPONSELIST ctrlSetText _response;
            };
        } else {
            //-- Insurgents are nearby
            if !(_hostile) then {
                //-- Random chance to reveal insurgents
                if (floor random 100 > 50) then {
                    //-- Reveal location
                    _response1 = format [localize "STR_ALIVE_CIV_INTERACT_INSURGENTS_PRESENCE_NOTHOSTILE_1", _town];
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_INSURGENTS_PRESENCE_NOTHOSTILE_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_INSURGENTS_PRESENCE_NOTHOSTILE_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_INSURGENTS_PRESENCE_NOTHOSTILE_4";
                    _response = [_response1, _response2, _response3, _response4] call BIS_fnc_selectRandom;
                    CIVINTERACT_RESPONSELIST ctrlSetText _response;
                    _answersGiven pushBack "Insurgents";_answerGiven = true;

                    //-- Create marker on insurgent group
                    _insurgentLeaders = [_insurgents,[getPos player],{_Input0 distance2D getPos _x},"ASCEND"] call BIS_fnc_sortBy;
                    _insurgentPos = getPos (_insurgentLeaders select 0);
                    _insurgentPos = [_insurgentPos, (75 + ceil random 25)] call CBA_fnc_randPos;
                    _marker = [str _insurgentPos, _insurgentPos, "ELLIPSE", [100, 100], "ColorEAST", "Insurgents", "n_installation", "FDiagonal", 0, 0.5] call ALIVE_fnc_createMarkerGlobal;
                    _text = [str (str _insurgentPos),_insurgentPos,"ICON", [0.1,0.1],"ColorRed","Insurgents", "mil_dot", "FDiagonal",0,0.5] call ALIVE_fnc_createMarkerGlobal;
                    [_marker,_text] spawn {sleep 30;deleteMarker (_this select 0);deleteMarker (_this select 1)};
                } else {
                    //-- Don't reveal location
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_INSURGENTS_PRESENCE_BADLUCK_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_INSURGENTS_PRESENCE_BADLUCK_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_INSURGENTS_PRESENCE_BADLUCK_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_INSURGENTS_PRESENCE_BADLUCK_4";
                    _response5 = localize "STR_ALIVE_CIV_INTERACT_INSURGENTS_PRESENCE_BADLUCK_5";
                    _response6 = localize "STR_ALIVE_CIV_INTERACT_INSURGENTS_PRESENCE_BADLUCK_6";
                    _response = [_response1, _response2, _response3, _response4] call BIS_fnc_selectRandom;
                    CIVINTERACT_RESPONSELIST ctrlSetText _response;
                };
            } else {
                _response1 = localize "STR_ALIVE_CIV_INTERACT_INSURGENTS_PRESENCE_HOSTILE_1";
                _response2 = localize "STR_ALIVE_CIV_INTERACT_INSURGENTS_PRESENCE_HOSTILE_2";
                _response3 = localize "STR_ALIVE_CIV_INTERACT_INSURGENTS_PRESENCE_HOSTILE_3";
                _response4 = localize "STR_ALIVE_CIV_INTERACT_INSURGENTS_PRESENCE_HOSTILE_4";
                _response5 = localize "STR_ALIVE_CIV_INTERACT_INSURGENTS_PRESENCE_HOSTILE_5";
                _response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
                CIVINTERACT_RESPONSELIST ctrlSetText _response;
            };
        };

    };

    //-- Do you know the location of any insurgent hideouts
    case "Hideouts": {
        _installations = [_civData, "Installations"] call ALiVE_fnc_hashGet;
        _actions = [_civData, "Actions"] call ALiVE_fnc_hashGet;
        _installations params ["_factory","_HQ","_depot","_roadblocks"];
        _actions params ["_ambush","_sabotage","_ied","_suicide"];

        if ((_factory isEqualTo []) and (_HQ isEqualTo []) and (_depot isEqualTo []) and (_roadblocks isEqualTo [])) then {

            if !(_hostile) then {
                if (floor random 100 > 30) then {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_NOTHOSTILE_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_NOTHOSTILE_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_NOTHOSTILE_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_NOTHOSTILE_4";
                    _response5 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_NOTHOSTILE_5";
                    _response6 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_NOTHOSTILE_6";
                    _response7 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_NOTHOSTILE_7";
                    _response8 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_NOTHOSTILE_8";
                    _response9 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_NOTHOSTILE_9";
                    _response = [_response1,_response2,_response3,_response4,_response5,_response6,_response7,_response8,_response9] call BIS_fnc_selectRandom;
                    CIVINTERACT_RESPONSELIST ctrlSetText _response;
                    _answersGiven pushBack "Hideouts";_answerGiven = true;
                } else {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_BADLUCK_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_BADLUCK_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_BADLUCK_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_BADLUCK_4";
                    _response5 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_BADLUCK_5";
                    _response = [_response1,_response2,_response3,_response4,_response5] call BIS_fnc_selectRandom;
                    CIVINTERACT_RESPONSELIST ctrlSetText _response;
                };
            } else {
                _response1 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_HOSTILE_1";
                _response2 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_HOSTILE_2";
                _response3 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_HOSTILE_3";
                _response4 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_HOSTILE_4";
                _response5 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_HOSTILE_5";
                _response6 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_HOSTILE_6";
                _response7 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_HOSTILE_7";
                _response8 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_HOSTILE_8";
                _response9 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_HOSTILE_9";
                _response = [_response1,_response2,_response3,_response4,_response5,_response6,_response7,_response8,_response9] call BIS_fnc_selectRandom;
                CIVINTERACT_RESPONSELIST ctrlSetText _response;
            };
        } else {

            private ["_installation","_type","_typeName","_installationData"];
            for "_i" from 0 to 3 do {
                _installationArray = _installations call BIS_fnc_selectRandom;

                if (!(_installationArray isEqualTo []) and (isNil "_installation")) then {
                    _index = _installations find _installationArray;
                    switch (str _index) do {
                        case "0": {_typeName = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_TYPENAME_IEDFACTORY";_type = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_TYPE_IEDFACTORY"};
                        case "1": {_typeName = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_TYPENAME_RECRUITMENTHQ";_type = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_TYPE_RECRUITMENTHQ"};
                        case "2": {_typeName = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_TYPENAME_MUNITIONSDEPOT";_type = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_TYPE_MUNITIONSDEPOT"};
                        case "3": {_typeName = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_TYPENAME_ROADBLOCK";_type = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_TYPE_ROADBLOCK"};
                    };
                    _installation = _installationArray;
                };
            };

            if ((isNil "_type") or (isNil "_installation")) exitWith {

                _response1 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_BADLUCK_1";
                _response2 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_BADLUCK_2";
                _response3 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_BADLUCK_3";
                _response4 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_BADLUCK_4";
                _response5 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_BADLUCK_5";
                _response = [_response1,_response2,_response3,_response4,_response5] call BIS_fnc_selectRandom;
                CIVINTERACT_RESPONSELIST ctrlSetText _response;
                _answersGiven pushBack "Hideouts";_answerGiven = true;
            };

            if !(_hostile) then {
                if (floor random 100 > 60) then {
                    if (floor random 100 > 60) then {
                        _response1 = format [localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_NOTHOSTILE_MAP_1", _type,_typeName];
                        _response2 = format [localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_NOTHOSTILE_MAP_2", _type,_typeName];
                        _response3 = format [localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_NOTHOSTILE_MAP_3", _type,_typeName];
                        _response4 = format [localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_NOTHOSTILE_MAP_4", _type,_typeName];
                        _response5 = format [localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_NOTHOSTILE_MAP_5", _type,_typeName];
                        _response6 = format [localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_NOTHOSTILE_MAP_6", _type,_typeName];
                        _response7 = format [localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_NOTHOSTILE_MAP_7", _type,_typeName];
                        _response8 = format [localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_NOTHOSTILE_MAP_8", _type,_typeName];
                        _response9 = format [localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_NOTHOSTILE_MAP_9", _type,_typeName];
                        _response = [_response1,_response2,_response3,_response4,_response5,_response6,_response7,_response8,_response9] call BIS_fnc_selectRandom;
                        CIVINTERACT_RESPONSELIST ctrlSetText _response;
                        _answersGiven pushBack "Hideouts";_answerGiven = true;

                        if (floor random 100 > 30) then {
                            //-- Create marker on general installation location
                            _installationPos = getPos _installation;
                            _installationPos = [_installationPos, (75 + ceil random 25)] call CBA_fnc_randPos;
                            _marker = [str _installationPos, _installationPos, "ELLIPSE", [100,100], "ColorEAST", _typeName, "n_installation", "FDiagonal", 0, 0.5] call ALIVE_fnc_createMarkerGlobal;
                            _text = [str (str _installationPos),_installationPos,"ICON", [0.1,0.1],"ColorRed",_typeName, "mil_dot", "FDiagonal",0,0.5] call ALIVE_fnc_createMarkerGlobal;
                            [_marker,_text] spawn {sleep 30;deleteMarker (_this select 0);deleteMarker (_this select 1)};
                        } else {
                            //-- Create marker on installation location
                            _installationPos = getPos _installation;
                            _marker = [str _installationPos, _installationPos, "ICON", [1,1], "ColorRed", _type, "n_installation", "Solid", 0, .5] call ALIVE_fnc_createMarkerGlobal;
                            _marker spawn {sleep 30;deleteMarker _this};
                        };
                    } else {
                        _response1 = format [localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_NOTHOSTILE_1", _type];
                        _response2 = format [localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_NOTHOSTILE_2", _type];
                        _response3 = format [localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_NOTHOSTILE_3", _type];
                        _response4 = format [localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_NOTHOSTILE_4", _type];
                        _response5 = format [localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_NOTHOSTILE_5", _type];
                        _response6 = format [localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_NOTHOSTILE_6", _type];
                        _response7 = format [localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_NOTHOSTILE_7", _type];
                        _response8 = format [localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_NOTHOSTILE_8", _type];
                        _response9 = format [localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_NOTHOSTILE_9", _type];
                        _response = [_response1,_response2,_response3,_response4,_response5,_response6,_response7,_response8,_response9] call BIS_fnc_selectRandom;
                        CIVINTERACT_RESPONSELIST ctrlSetText _response;
                        _answersGiven pushBack "Hideouts";_answerGiven = true;
                    };
                } else {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_BADLUCK_1";
                	_response2 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_BADLUCK_2";
                	_response3 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_BADLUCK_3";
                	_response4 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_BADLUCK_4";
                	_response5 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_NOPRESENCE_BADLUCK_5";
                    _response = [_response1,_response2,_response3,_response4,_response5] call BIS_fnc_selectRandom;
                    CIVINTERACT_RESPONSELIST ctrlSetText _response;
                    _answersGiven pushBack "Hideouts";_answerGiven = true;
                };
            } else {
                if (floor random 100 > _hostility) then {
                    _response1 = format [localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_NOTHOSTILE_1", _type];
                    _response2 = format [localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_NOTHOSTILE_2", _type];
                    _response3 = format [localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_NOTHOSTILE_3", _type];
                    _response4 = format [localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_NOTHOSTILE_4", _type];
                    _response5 = format [localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_NOTHOSTILE_5", _type];
                    _response6 = format [localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_NOTHOSTILE_6", _type];
                    _response7 = format [localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_NOTHOSTILE_7", _type];
                    _response8 = format [localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_NOTHOSTILE_8", _type];
                    _response9 = format [localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_NOTHOSTILE_9", _type];
                    _response = [_response1,_response2,_response3,_response4,_response5,_response6,_response7,_response8,_response9] call BIS_fnc_selectRandom;
                    CIVINTERACT_RESPONSELIST ctrlSetText _response;
                    _answersGiven pushBack "Hideouts";_answerGiven = true;
                } else {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_HOSTILE_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_HOSTILE_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_HOSTILE_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_HOSTILE_4";
                    _response5 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_HOSTILE_5";
                    _response6 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_HOSTILE_6";
                    _response7 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_HOSTILE_7";
                    _response8 = localize "STR_ALIVE_CIV_INTERACT_HIDEOUTS_PRESENCE_HOSTILE_8";
                    _response = [_response1,_response2,_response3,_response4,_response5,_response6,_response7,_response8] call BIS_fnc_selectRandom;
                    CIVINTERACT_RESPONSELIST ctrlSetText _response;
                    _answersGiven pushBack "Hideouts";_answerGiven = true;
                };
            };
        };
    };

    //-- Have you noticed any strange behavior lately
    case "StrangeBehavior": {
        _hostileCivInfo = [_civData, "HostileCivInfo"] call ALiVE_fnc_hashGet;    //-- [_civ,_homePos,_activeCommands]
        //-- Check if data exists
        if (count _hostileCivInfo == 0) then {
            if !(_hostile) then {
                if (floor random 100 > 70) then {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_NOPRESENCE_NOTHOSTILE_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_NOPRESENCE_NOTHOSTILE_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_NOPRESENCE_NOTHOSTILE_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_NOPRESENCE_NOTHOSTILE_4";
                    _response5 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_NOPRESENCE_NOTHOSTILE_5";
                    _response6 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_NOPRESENCE_NOTHOSTILE_6";
                    _response = [_response1, _response2, _response3, _response4, _response5, _response6] call BIS_fnc_selectRandom;
                    CIVINTERACT_RESPONSELIST ctrlSetText _response;
                    _answersGiven pushBack "StrangeBehavior";_answerGiven = true;
                } else {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_NOPRESENCE_BADLUCK_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_NOPRESENCE_BADLUCK_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_NOPRESENCE_BADLUCK_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_NOPRESENCE_BADLUCK_4";
                    _response5 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_NOPRESENCE_BADLUCK_5";
                    _response6 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_NOPRESENCE_BADLUCK_6";
                    _response = [_response1, _response2, _response3, _response4, _response5,_response6] call BIS_fnc_selectRandom;
                    CIVINTERACT_RESPONSELIST ctrlSetText _response;
                };
            } else {
                _response1 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_HOSTILE_1";
                _response2 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_HOSTILE_2";
                _response3 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_HOSTILE_3";
                _response4 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_HOSTILE_4";
                _response5 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_HOSTILE_5";
                _response6 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_HOSTILE_6";
                _response7 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_HOSTILE_7";
                _response = [_response1,_response2,_response3,_response4,_response5,_response6,_response7] call BIS_fnc_selectRandom;
                CIVINTERACT_RESPONSELIST ctrlSetText _response;
                _answersGiven pushBack "StrangeBehavior";_answerGiven = true;
            };
        } else {
            _hostileCivInfo params ["_hostileCiv","_homePos","_activeCommands"];
            _activeCommand = _activeCommands call BIS_fnc_selectRandom;
            _activeCommand = _activeCommand select 0;
            _activePlan = [_logic,"getActivePlan",_activeCommand] call MAINCLASS;

            if (isNil "_activePlan") exitWith {CIVINTERACT_RESPONSELIST ctrlSetText (localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_HOSTILE_7")};

            if (!(_hostile) and (floor random 100 > 70)) then {
                _response1 = format [localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_PRESENCE_NOTHOSTILE_1", name _hostileCiv, _activePlan];
                _response2 = format [localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_PRESENCE_NOTHOSTILE_2", name _hostileCiv, _activePlan];
                _response3 = format [localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_PRESENCE_NOTHOSTILE_3", name _hostileCiv, _activePlan];
                _response4 = format [localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_PRESENCE_NOTHOSTILE_4", name _hostileCiv, _activePlan];
                _response5 = format [localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_PRESENCE_NOTHOSTILE_5", name _hostileCiv, _activePlan];
                _response6 = format [localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_PRESENCE_NOTHOSTILE_6", name _hostileCiv, _activePlan];
                _response = [_response1, _response2, _response3, _response4, _response5, _response6] call BIS_fnc_selectRandom;
                CIVINTERACT_RESPONSELIST ctrlSetText _response;
                _answersGiven pushBack "StrangeBehavior";_answerGiven = true;

                if (floor random 100 <= 35) then {
                    switch (str floor random 2) do {
                        case "0": {
                            _response1 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_PRESENCE_NOTHOSTILE_MAP_1";
                            _response2 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_PRESENCE_NOTHOSTILE_MAP_2";
                            _response3 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_PRESENCE_NOTHOSTILE_MAP_3";
                            _response4 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_PRESENCE_NOTHOSTILE_MAP_4";
                            _response = [_response1, _response2, _response3,_response4] call BIS_fnc_selectRandom;
                            CIVINTERACT_RESPONSELIST ctrlSetText ((ctrlText CIVINTERACT_RESPONSELIST) + _response);

                            //-- Create marker on hostile civ location
                            _civPos = [getPos _hostileCiv, (10 + ceil random 8)] call CBA_fnc_randPos;
                            _markerName = format ["%1's location", name _hostileCiv];
                            _marker = [str _civPos, _civPos, "ELLIPSE", [40, 40], "ColorRed", _markerName, "n_installation", "FDiagonal", 0, 0.5] call ALIVE_fnc_createMarkerGlobal;
                            _text = [str (str _civPos),_civPos,"ICON", [0.1,0.1],"ColorRed",_markerName, "mil_dot", "FDiagonal",0,0.5] call ALIVE_fnc_createMarkerGlobal;
                            [_marker,_text] spawn {sleep 30;deleteMarker (_this select 0);deleteMarker (_this select 1)};
                        };
                        case "1": {
                            _response1 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_PRESENCE_NOTHOSTILE_HOME_1";
                            _response2 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_PRESENCE_NOTHOSTILE_HOME_2";
                            _response3 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_PRESENCE_NOTHOSTILE_HOME_3";
                            _response4 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_PRESENCE_NOTHOSTILE_HOME_4";
                            _response = [_response1, _response2, _response3,_response4] call BIS_fnc_selectRandom;
                            CIVINTERACT_RESPONSELIST ctrlSetText ((ctrlText CIVINTERACT_RESPONSELIST) + _response);

                            //-- Create marker on hostile civ location
                            _markerName = format ["%1's home", name _hostileCiv];
                            _marker = [str _homePos, _homePos, "ICON", [.35, .35], "ColorRed", _markerName, "mil_circle", "Solid", 0, .5] call ALIVE_fnc_createMarkerGlobal;
                            _marker spawn {sleep 30;deleteMarker _this};
                        };
                    };
                };
            } else {
                if (floor random 100 > _hostility) then {
                    _response1 = format [localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_PRESENCE_NOTHOSTILE_1", name _hostileCiv, _activePlan];
                    _response2 = format [localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_PRESENCE_NOTHOSTILE_2", name _hostileCiv, _activePlan];
                    _response3 = format [localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_PRESENCE_NOTHOSTILE_3", name _hostileCiv, _activePlan];
                    _response4 = format [localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_PRESENCE_NOTHOSTILE_4", name _hostileCiv, _activePlan];
                    _response5 = format [localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_PRESENCE_NOTHOSTILE_5", name _hostileCiv, _activePlan];
                    _response6 = format [localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_PRESENCE_NOTHOSTILE_6", name _hostileCiv, _activePlan];
                    _response = [_response1, _response2, _response3, _response4, _response5, _response6] call BIS_fnc_selectRandom;
                    CIVINTERACT_RESPONSELIST ctrlSetText _response;
                    _answersGiven pushBack "StrangeBehavior";_answerGiven = true;
                } else {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_HOSTILE_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_HOSTILE_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_HOSTILE_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_HOSTILE_4";
                    _response5 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_HOSTILE_5";
                    _response6 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_HOSTILE_6";
                    _response7 = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_HOSTILE_7";
                    _response = [_response1,_response2,_response3,_response4,_response5,_response6,_response7] call BIS_fnc_selectRandom;
                    CIVINTERACT_RESPONSELIST ctrlSetText _response;
                    _answersGiven pushBack "StrangeBehavior";_answerGiven = true;
                };
            };
        };
    };

    //-- What is your opinion of our forces
    case "Opinion": {
        private ["_response"];
        _personalHostility = _civInfo select 1;
        _townHostility = _civInfo select 2;

        if (((_townHostility / 2.5) > 45) and (floor random 100 > 25) and (_personalHostility < 50)) exitWith {
            _response1 = localize "STR_ALIVE_CIV_INTERACT_OPINION_TOWN_1";
            _response2 = localize "STR_ALIVE_CIV_INTERACT_OPINION_TOWN_2";
            _response3 = localize "STR_ALIVE_CIV_INTERACT_OPINION_TOWN_3";
            _response4 = localize "STR_ALIVE_CIV_INTERACT_OPINION_TOWN_4";
            _response5 = localize "STR_ALIVE_CIV_INTERACT_OPINION_TOWN_5";
            _response6 = localize "STR_ALIVE_CIV_INTERACT_OPINION_TOWN_6";
            _response7 = localize "STR_ALIVE_CIV_INTERACT_OPINION_TOWN_7";
            _response = [_response1, _response2, _response3, _response4, _response5, _response6,_response7] call BIS_fnc_selectRandom;
            CIVINTERACT_RESPONSELIST ctrlSetText _response;

            //-- Check if civilian is irritated
            [_logic,"isIrritated", [_hostile,_asked,_civ]] call MAINCLASS;
        };

        if !(_hostile) then {
            if (floor random 100 < 70) then {

                //-- Give answer
                if (_personalHostility <= 25) then {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_OPINION_SUPPORT_STRONG_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_OPINION_SUPPORT_STRONG_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_OPINION_SUPPORT_STRONG_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_OPINION_SUPPORT_STRONG_4";
                    _response5 = localize "STR_ALIVE_CIV_INTERACT_OPINION_SUPPORT_STRONG_5";
                    _response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
                };

                if ((_personalHostility > 25) and (_personalHostility <= 50)) then {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_OPINION_SUPPORT_MEDIUM_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_OPINION_SUPPORT_MEDIUM_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_OPINION_SUPPORT_MEDIUM_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_OPINION_SUPPORT_MEDIUM_4";
                    _response5 = localize "STR_ALIVE_CIV_INTERACT_OPINION_SUPPORT_MEDIUM_5";
                    _response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
                };

                if ((_personalHostility > 50) and (_personalHostility <= 75)) then {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_OPINION_SUPPORT_WEAK_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_OPINION_SUPPORT_WEAK_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_OPINION_SUPPORT_WEAK_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_OPINION_SUPPORT_WEAK_4";
                    _response5 = localize "STR_ALIVE_CIV_INTERACT_OPINION_SUPPORT_WEAK_5";
                    _response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
                };

                if ((_personalHostility > 75) and (_personalHostility <= 100)) then {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_OPINION_OPPOSE_STRONG_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_OPINION_OPPOSE_STRONG_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_OPINION_OPPOSE_STRONG_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_OPINION_OPPOSE_STRONG_4";
                    _response5 = localize "STR_ALIVE_CIV_INTERACT_OPINION_OPPOSE_STRONG_5";
                    _response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
                };

                if (_personalHostility > 100) then {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_OPINION_OPPOSE_EXTREME_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_OPINION_OPPOSE_EXTREME_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_OPINION_OPPOSE_EXTREME_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_OPINION_OPPOSE_EXTREME_4";
                    _response5 = localize "STR_ALIVE_CIV_INTERACT_OPINION_OPPOSE_EXTREME_5";
                    _response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
                };

                if ((isNil "_response") or (isNil "_personalHostility")) then {_response = localize "STR_ALIVE_CIV_INTERACT_OPINION_NOANSWER_1"};
                CIVINTERACT_RESPONSELIST ctrlSetText _response;
                _answersGiven pushBack "Opinion";_answerGiven = true;
            } else {
                //-- Decline to answer
                _response1 = localize "STR_ALIVE_CIV_INTERACT_OPINION_NOANSWER_1";
                _response2 = localize "STR_ALIVE_CIV_INTERACT_OPINION_NOANSWER_2";
                _response3 = localize "STR_ALIVE_CIV_INTERACT_OPINION_NOANSWER_3";
                _response4 = localize "STR_ALIVE_CIV_INTERACT_OPINION_NOANSWER_4";
                _response5 = localize "STR_ALIVE_CIV_INTERACT_OPINION_NOANSWER_5";
                _response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
                CIVINTERACT_RESPONSELIST ctrlSetText _response;
            };
        } else {
            if (floor random 100 > _personalHostility) then {
                //-- Give answer
                if (_personalHostility <= 25) then {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_OPINION_SUPPORT_STRONG_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_OPINION_SUPPORT_STRONG_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_OPINION_SUPPORT_STRONG_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_OPINION_SUPPORT_STRONG_4";
                    _response5 = localize "STR_ALIVE_CIV_INTERACT_OPINION_SUPPORT_STRONG_5";
                    _response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
                };

                if ((_personalHostility > 25) and (_personalHostility <= 50)) then {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_OPINION_SUPPORT_MEDIUM_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_OPINION_SUPPORT_MEDIUM_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_OPINION_SUPPORT_MEDIUM_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_OPINION_SUPPORT_MEDIUM_4";
                    _response5 = localize "STR_ALIVE_CIV_INTERACT_OPINION_SUPPORT_MEDIUM_5";
                    _response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
                };

                if ((_personalHostility > 50) and (_personalHostility <= 75)) then {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_OPINION_SUPPORT_WEAK_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_OPINION_SUPPORT_WEAK_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_OPINION_SUPPORT_WEAK_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_OPINION_SUPPORT_WEAK_4";
                    _response5 = localize "STR_ALIVE_CIV_INTERACT_OPINION_SUPPORT_WEAK_5";
                    _response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
                };

                if ((_personalHostility > 75) and (_personalHostility <= 100)) then {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_OPINION_OPPOSE_STRONG_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_OPINION_OPPOSE_STRONG_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_OPINION_OPPOSE_STRONG_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_OPINION_OPPOSE_STRONG_4";
                    _response5 = localize "STR_ALIVE_CIV_INTERACT_OPINION_OPPOSE_STRONG_5";
                    _response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
                };

                if (_personalHostility > 100) then {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_OPINION_OPPOSE_EXTREME_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_OPINION_OPPOSE_EXTREME_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_OPINION_OPPOSE_EXTREME_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_OPINION_OPPOSE_EXTREME_4";
                    _response5 = localize "STR_ALIVE_CIV_INTERACT_OPINION_OPPOSE_EXTREME_5";
                    _response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
                };

                if ((isNil "_response") or (isNil "_personalHostility")) then {_response = localize "STR_ALIVE_CIV_INTERACT_STRANGEBEHAVIOR_HOSTILE_7"};
                CIVINTERACT_RESPONSELIST ctrlSetText _response;
                _answersGiven pushBack "Opinion";_answerGiven = true;
            } else {
                //-- Decline to answer
                _response1 = localize "STR_ALIVE_CIV_INTERACT_OPINION_NOANSWER_1";
                _response2 = localize "STR_ALIVE_CIV_INTERACT_OPINION_NOANSWER_2";
                _response3 = localize "STR_ALIVE_CIV_INTERACT_OPINION_NOANSWER_3";
                _response4 = localize "STR_ALIVE_CIV_INTERACT_OPINION_NOANSWER_4";
                _response5 = localize "STR_ALIVE_CIV_INTERACT_OPINION_NOANSWER_5";
                _response6 = localize "STR_ALIVE_CIV_INTERACT_OPINION_NOANSWER_6";
                _response = [_response1, _response2, _response3, _response4, _response5,_response6] call BIS_fnc_selectRandom;
                CIVINTERACT_RESPONSELIST ctrlSetText _response;
            };
        };
    };

    //-- What is the general opinion of our forces in your town
    case "TownOpinion": {
        private ["_response"];
        _personalHostility = _civInfo select 1;
        _townHostility = _civInfo select 2;

        if (((_townHostility / 2.5) > 45) and (floor random 100 > 25) and (_personalHostility < 50)) exitWith {
            _response1 = "They wouldn't like me talking to you.";
            _response2 = "I can't talk about this.";
            _response3 = "You must leave this place immediately.";
            _response4 = "You are in severe danger here.";
            _response5 = "Please leave before they see you.";
            _response6 = "You must leave immediately.";
            _response7 = "They must not see me talking to you.";
            _response = [_response1, _response2, _response3, _response4, _response5, _response6,_response7] call BIS_fnc_selectRandom;
            CIVINTERACT_RESPONSELIST ctrlSetText _response;

            //-- Check if civilian is irritated
            [_logic,"isIrritated", [_hostile,_asked,_civ]] call MAINCLASS;
        };

        //-- This really needs to be a switch, couldn't get it to work properly the first time
        if !(_hostile) then {
            if (floor random 100 < 70) then {

                //-- Give answer
                if (_townHostility <= 25) then {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_SUPPORT_STRONG_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_SUPPORT_STRONG_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_SUPPORT_STRONG_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_SUPPORT_STRONG_4";
                    _response5 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_SUPPORT_STRONG_5";
                    _response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
                };

                if ((_townHostility > 25) and (_townHostility <= 50)) then {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_SUPPORT_MEDIUM_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_SUPPORT_MEDIUM_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_SUPPORT_MEDIUM_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_SUPPORT_MEDIUM_4";
                    _response5 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_SUPPORT_MEDIUM_5";
                    _response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
                };

                if ((_townHostility > 50) and (_townHostility <= 75)) then {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_OPPOSE_MEDIUM_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_OPPOSE_MEDIUM_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_OPPOSE_MEDIUM_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_OPPOSE_MEDIUM_4";
                    _response5 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_OPPOSE_MEDIUM_5";
                    _response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
                };

                if ((_townHostility > 75) and (_townHostility <= 100)) then {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_OPPOSE_STRONG_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_OPPOSE_STRONG_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_OPPOSE_STRONG_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_OPPOSE_STRONG_4";
                    _response5 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_OPPOSE_STRONG_5";
                    _response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
                };

                if (_townHostility > 100) then {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_OPPOSE_EXTREME_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_OPPOSE_EXTREME_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_OPPOSE_EXTREME_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_OPPOSE_EXTREME_4";
                    _response5 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_OPPOSE_EXTREME_5";
                    _response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
                };

                if ((isNil "_response") or (isNil "_townHostility")) then {_response = localize "STR_ALIVE_CIV_INTERACT_OPINION_NOANSWER_1"};
                CIVINTERACT_RESPONSELIST ctrlSetText _response;
                _answersGiven pushBack "TownOpinion";_answerGiven = true;
            } else {
                //-- Decline to answer
                _response1 = localize "STR_ALIVE_CIV_INTERACT_OPINION_NOANSWER_1";
                _response2 = localize "STR_ALIVE_CIV_INTERACT_OPINION_NOANSWER_2";
                _response3 = localize "STR_ALIVE_CIV_INTERACT_OPINION_NOANSWER_3";
                _response4 = localize "STR_ALIVE_CIV_INTERACT_OPINION_NOANSWER_4";
                _response5 = localize "STR_ALIVE_CIV_INTERACT_OPINION_NOANSWER_5";
                _response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
                CIVINTERACT_RESPONSELIST ctrlSetText _response;
            };
        } else {
            if (floor random 100 > _personalHostility) then {
                //-- Give answer
                if (_townHostility <= 25) then {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_SUPPORT_STRONG_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_SUPPORT_STRONG_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_SUPPORT_STRONG_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_SUPPORT_STRONG_4";
                    _response5 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_SUPPORT_STRONG_5";
                    _response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
                };

                if ((_townHostility > 25) and (_townHostility <= 50)) then {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_SUPPORT_MEDIUM_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_SUPPORT_MEDIUM_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_SUPPORT_MEDIUM_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_SUPPORT_MEDIUM_4";
                    _response5 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_SUPPORT_MEDIUM_5";
                    _response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
                };

                if ((_townHostility > 50) and (_townHostility <= 75)) then {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_OPPOSE_MEDIUM_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_OPPOSE_MEDIUM_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_OPPOSE_MEDIUM_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_OPPOSE_MEDIUM_4";
                    _response5 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_OPPOSE_MEDIUM_5";
                    _response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
                };

                if ((_townHostility > 75) and (_townHostility <= 100)) then {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_OPPOSE_STRONG_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_OPPOSE_STRONG_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_OPPOSE_STRONG_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_OPPOSE_STRONG_4";
                    _response5 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_OPPOSE_STRONG_5";
                    _response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
                };

                if (_townHostility > 100) then {
                    _response1 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_OPPOSE_EXTREME_1";
                    _response2 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_OPPOSE_EXTREME_2";
                    _response3 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_OPPOSE_EXTREME_3";
                    _response4 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_OPPOSE_EXTREME_4";
                    _response5 = localize "STR_ALIVE_CIV_INTERACT_TOWNOPINION_OPPOSE_EXTREME_5";
                    _response = [_response1, _response2, _response3, _response4, _response5] call BIS_fnc_selectRandom;
                };

                if ((isNil "_response") or (isNil "_townHostility")) then {_response = localize "STR_ALIVE_CIV_INTERACT_OPINION_NOANSWER_1"};
                CIVINTERACT_RESPONSELIST ctrlSetText _response;
                _answersGiven pushBack "TownOpinion";_answerGiven = true;
            } else {
                //-- Decline to answer
                _response1 = localize "STR_ALIVE_CIV_INTERACT_OPINION_NOANSWER_1";
                _response2 = localize "STR_ALIVE_CIV_INTERACT_OPINION_NOANSWER_2";
                _response3 = localize "STR_ALIVE_CIV_INTERACT_OPINION_NOANSWER_3";
                _response4 = localize "STR_ALIVE_CIV_INTERACT_OPINION_NOANSWER_4";
                _response5 = localize "STR_ALIVE_CIV_INTERACT_OPINION_NOANSWER_5";
                _response6 = localize "STR_ALIVE_CIV_INTERACT_OPINION_NOANSWER_6";
                _response = [_response1, _response2, _response3, _response4, _response5,_response6] call BIS_fnc_selectRandom;
                CIVINTERACT_RESPONSELIST ctrlSetText _response;
            };
        };
    };

};

//-- Check if civilian is irritated
[_logic,"isIrritated", [_hostile,_asked,_civ]] call MAINCLASS;

if (_answerGiven) then {
    [_civData, "AnswersGiven", _answersGiven] call ALiVE_fnc_hashSet;
    _civ setVariable ["AnswersGiven",_answersGiven];
    _civ setVariable ["AnswersGiven",_answersGiven, false]; //-- Broadcasting could bring server perf loss with high use (set false to true at risk)
};


/*
Threat outline

ADD THREATS THAT CAN LOWER OR RAISE HOSTILITY DEPENDING ON THE CIVILIANS CURRENT
HOSTILITY AND THE AMOUNT OF QUESTIONS ASKED ALREADY
THREATS TOWARDS LOW HOSTILITY CIVS COULD HAVE A HIGHER CHANCE OF RAISING HOSTILITY
WHILE THREATS TOWARDS HIGH HOSTILITY CIVS COULD HAVE A HIGHER CHANCE (MAKE IT BALANCED)

if (floor random 100 > _hostility) then {
    _hostility = ceil (_hostility / 3);
    _civInfo = [_civInfo select 0, _hostility, _civInfo select 2];
    [_logic, "CivInfo", _civInfo] call ALiVE_fnc_hashSet;
} else {
    if (floor random 100 > 20) then {
        _hostility = ceil (_hostility / 3);
        _civInfo = [_civInfo select 0, _hostility, _civInfo select 2];
        [_logic, "CivInfo", _civInfo] call ALiVE_fnc_hashSet;
    };
};
*/