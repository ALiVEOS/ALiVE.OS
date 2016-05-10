#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(radioBroadcast);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_radioBroadcast

Description:
Broadcast radio messages including to all friendly sides, with HQ is desired
Only for use with BIS_fnc_MP

Parameters:
Object - the sender
String - the message
String - the radio channel (global,side,group,vehicle,sideRadio)
Side - the side
Boolean - to HQ message is prefixed with HQ callsign
Boolean - from HQ message is delivered from HQ callsign
String - HQ Class the CfgHQIdentities class (AirBase,Base,BLU,HQ,IND,IND_G,OPF,PAPA_BEAR)

Returns:

Examples:
(begin example)

// generic message
_radioBroadcast = [player,"Hello World"];
[_radioBroadcast,"ALIVE_fnc_radioBroadcast",true,true] spawn BIS_fnc_MP;

// selected channel message
_radioBroadcast = [player,"Hello World","global"];
[_radioBroadcast,"ALIVE_fnc_radioBroadcast",true,true] spawn BIS_fnc_MP;

// player callsign to HQ callsign
_radioBroadcast = [player,"Hello World","side",WEST,true,false,true,false,"HQ"];
[_radioBroadcast,"ALIVE_fnc_radioBroadcast",true,true] spawn BIS_fnc_MP;

// player callsign
_radioBroadcast = [player,"Hello World","side",WEST,true,false,false,false,"HQ"];
[_radioBroadcast,"ALIVE_fnc_radioBroadcast",true,true] spawn BIS_fnc_MP;

// HQ callsign to player callsign
_radioBroadcast = [player,"Hello World","side",WEST,false,true,false,true,"HQ"];
[_radioBroadcast,"ALIVE_fnc_radioBroadcast",true,true] spawn BIS_fnc_MP;

// HQ callsign
_radioBroadcast = [player,"Hello World","side",WEST,false,false,false,true,"HQ"];
[_radioBroadcast,"ALIVE_fnc_radioBroadcast",true,true] spawn BIS_fnc_MP;


(end)

See Also:

Author:
ARJay, Gunny
---------------------------------------------------------------------------- */
private ["_unit","_message","_channel","_side","_fromUnit","_toUnit","_toHQ","_fromHQ","_hqClass","_fromGroup","_toGroup"];

_unit = _this select 0;
_message = _this select 1;
_channel = if(count _this > 2) then {_this select 2} else {"side"};
_side = if(count _this > 3) then {_this select 3} else {WEST};
_fromUnit = if(count _this > 4) then {_this select 4} else {false};
_toUnit = if(count _this > 5) then {_this select 5} else {false};
_toHQ = if(count _this > 6) then {_this select 6} else {false};
_fromHQ = if(count _this > 7) then {_this select 7} else {false};
_hqClass = if(count _this > 8) then {_this select 8} else {"PAPA_BEAR"};
_fromGroup = if(count _this > 9) then {_this select 9} else {false};
_toGroup = if(count _this > 10) then {_this select 10} else {false};

if(isNil "_message") exitWith {};

// if from unit get the callSign of the unit
if(_fromUnit || _toUnit) then {

    private ["_group","_groupArray","_fromCallSign"];

    _group = format ["%1", group _unit];
    _groupArray = toArray _group;
    _fromCallSign = [];

    {
    	if !(_forEachIndex in [0,1]) then
    	{
    		_fromCallSign pushback _x;
    	};
    } forEach _groupArray;

    _fromCallSign = toString _fromCallSign;

    if(_fromUnit) then {
        _message = format["this is %1 %2",_fromCallSign,_message];
    }else{
        _message = format["%1 %2",_fromCallSign,_message];
    };

};

// if from group get the callSign of the group
if(_fromGroup || _toGroup) then {

    private ["_group","_groupArray","_fromCallSign"];

    _group = format ["%1", group _unit];

    if(_fromGroup) then {
        _message = format["%1 %2",_group,_message];
    }else{
        _message = format["%1 %2",_group,_message];
    };

};

// if to HQ get the callSign of the HQ identity
if(_toHQ) then {

    private ["_toCallSign"];

    _toCallSign = getText(configFile >> "CfgHQIdentities" >> _hqClass >> "name");
    _message = format["%1 %2",_toCallSign,_message];
};


switch (_channel) do
{
    case "global" : {
        _unit globalChat _message
    };
    case "side" : {
        if(_fromUnit || _fromGroup) then {
            _unit sideChat _message;
        };

        if(_fromHQ) then {
            [_side,_hqClass] sideChat _message;
        };

        if(!(_fromUnit) && !(_fromHQ) && !(_fromGroup)) then {
            _unit sideChat _message;
        };
    };
    case "group" : {
        _unit groupChat _message
    };
    case "vehicle" : {
        _unit vehicleChat _message
    };
    case "sideRadio" : {
        _unit sideRadio _message
    };
};