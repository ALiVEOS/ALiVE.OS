#include <\x\alive\addons\main\script_component.hpp>
SCRIPT(mainTablet);

/* ----------------------------------------------------------------------------
Function: mainTablet
Description:
Main Tablet to display messages

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:


Examples:
(begin example)

// open tablet for player
[["open"],"ALIVE_fnc_mainTablet",player,false,false] spawn BIS_fnc_MP;

// close tablet for player
[["close"],"ALIVE_fnc_mainTablet",player,false,false] spawn BIS_fnc_MP;

// set tablet title
[["setTitle","cheese"],"ALIVE_fnc_mainTablet",player,false,false] spawn BIS_fnc_MP;

// add a list item
[["updateList","list item 1"],"ALIVE_fnc_mainTablet",player,false,false] spawn BIS_fnc_MP;

// clear the list
[["clearList"],"ALIVE_fnc_mainTablet",player,false,false] spawn BIS_fnc_MP;

// apply status text
[["applyStatus",["Status 1","Status 2","Status 3"]],"ALIVE_fnc_mainTablet",player,false,false] spawn BIS_fnc_MP;

// update status text
[["updateStatus","Status 1"],"ALIVE_fnc_mainTablet",player,false,false] spawn BIS_fnc_MP;

// set status text
[["setStatus","Status 1"],"ALIVE_fnc_mainTablet",player,false,false] spawn BIS_fnc_MP;

(end)

See Also:

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

// Display components
#define MainTablet_CTRL_MainDisplay 10001
#define MainTablet_CTRL_Title 10002
#define MainTablet_CTRL_List 10003
#define MainTablet_CTRL_Text 10004

#define Main_getControl(disp,ctrl) ((findDisplay ##disp) displayCtrl ##ctrl)

private["_action","_args"];

_action = _this select 0;
_args = _this select 1;

if(isNil "ALiVE_mainTabletData") then {
    ALiVE_mainTabletData = [] call ALIVE_fnc_hashCreate;
    [ALiVE_mainTabletData,"status",[]] call ALIVE_fnc_hashSet;
    [ALiVE_mainTabletData,"list",[]] call ALIVE_fnc_hashSet;
};

switch(_action) do {

    case "open":{
        createDialog "MainTablet";
    };

    case "close":{
        closeDialog 0;
    };

    case "setTitle":{

        disableSerialization;

        private["_title"];

        _title = Main_getControl(MainTablet_CTRL_MainDisplay,MainTablet_CTRL_Title);
        _title ctrlShow true;

        _title ctrlSetText _args;
    };

    case "updateList":{

        disableSerialization;

        private["_currentListOptions","_option","_list"];

        _option = _args;

        _currentListOptions = [ALiVE_mainTabletData,"list"] call ALIVE_fnc_hashGet;

        _currentListOptions set [count _currentListOptions,_option];

        [ALiVE_mainTabletData,"list",_currentListOptions] call ALIVE_fnc_hashSet;

        _list = Main_getControl(MainTablet_CTRL_MainDisplay,MainTablet_CTRL_List);

        lbClear _list;

        {
            _list lbAdd format["%1", _x];
        } forEach _currentListOptions;

    };

    case "clearList":{

        disableSerialization;

        private["_currentListOptions","_list"];

        _list = Main_getControl(MainTablet_CTRL_MainDisplay,MainTablet_CTRL_List);

        lbClear _list;

    };

    case "applyStatus":{

        disableSerialization;

        private["_messages"];

        _messages = _args;

        {
            ["updateStatus",_x] call ALIVE_fnc_mainTablet;
        } forEach _messages;


    };

    case "updateStatus":{

        disableSerialization;

        private["_currentStatus","_message","_date","_hour","_minutes","_minutesArray","_time"];

        _currentStatus = [ALiVE_mainTabletData,"status"] call ALIVE_fnc_hashGet;

        _message = _args;

        _date = date;
        _hour = _date select 3;
        _minutes = _date select 4;
        _minutesArray = toArray format["%1",_minutes];

        if(count _minutesArray == 1) then {
            _minutes = format["0%1",_minutes];
        };

        _time = format["%1:%2",_hour,_minutes];

        _message = format["[%1] %2",_time,_message];

        _currentStatus set [count _currentStatus,_message];

        [ALiVE_mainTabletData,"status",_currentStatus] call ALIVE_fnc_hashSet;

        ["displayStatus"] call ALIVE_fnc_mainTablet;
    };

    case "displayStatus":{

        disableSerialization;

        private ["_status","_currentStatus","_text"];

        _status = Main_getControl(MainTablet_CTRL_MainDisplay,MainTablet_CTRL_Text);
        _status ctrlShow true;

        _currentStatus = [ALiVE_mainTabletData,"status"] call ALIVE_fnc_hashGet;
        _text = "";

        {
            _text = format["%1\n%2",_text,_x];
        } forEach _currentStatus;

        _status ctrlSetText _text;

    };

    case "setStatus":{

        disableSerialization;

        private ["_status"];

        _status = Main_getControl(MainTablet_CTRL_MainDisplay,MainTablet_CTRL_Text);
        _status ctrlShow true;

        _status ctrlSetText _args;

    };

    case "load":{

    };

    case "unload":{

    };
};

