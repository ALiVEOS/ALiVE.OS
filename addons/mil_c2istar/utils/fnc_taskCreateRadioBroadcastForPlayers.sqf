#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskCreateRadioBroadcastForPlayers);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskCreateRadioBroadcastForPlayers

Description:
Mark a position for players

Parameters:

Returns:

Examples:
(begin example)
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_messageCode","_taskDialog","_taskSide","_taskPlayers","_sideObject","_messages"];

_messageCode = _this select 0;
_taskDialog = _this select 1;
_taskSide = _this select 2;
_taskPlayers = _this select 3;

if(_messageCode in (_taskDialog select 1)) then {

    _sideObject = [_taskSide] call ALIVE_fnc_sideTextToObject;
    _messages = [_currentTaskDialog,_messageCode] call ALIVE_fnc_hashGet;

    [_sideObject,_messages,_taskPlayers] spawn {

        private ["_sideObject","_messages","_taskPlayers","_messageSource","_message","_player","_radioBroadcast","_player"];

        _sideObject = _this select 0;
        _messages = _this select 1;
        _taskPlayers = _this select 2;

        {
            _messageSource = _x select 0;
            _message = _x select 1;

            {
                _player = [_x] call ALIVE_fnc_getPlayerByUID;

                if !(isNull _player) then {

                    switch(_messageSource) do {
                        case "HQ":{
                            _radioBroadcast = [_player,_message,"side",_sideObject,false,false,false,true,"HQ",false,true];
                        };
                        case "PLAYERS":{
                            _radioBroadcast = [_player,_message,"side",_sideObject,false,false,false,false,"HQ",true,false];
                        };
                    };

                    if(isDedicated) then {
                        [_radioBroadcast,"ALIVE_fnc_radioBroadcast",_player,false,false] spawn BIS_fnc_MP;
                    }else{
                        _radioBroadcast call ALIVE_fnc_radioBroadcast;
                    };
                };

            } forEach _taskPlayers;

            sleep 3;

        } forEach _messages;

    };

};