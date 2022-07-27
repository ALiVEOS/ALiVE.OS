private ["_display", "_map", "_mission", "_player", "_newsOnline", "_newsOffline", "_ctrlHTML", "_htmlLoaded"];

disableSerialization;

createDialog "newsfeed_dialog";

    _display = (findDisplay 660002);

    _map = worldname;
    _mission  = missionName;
    _player = name player;

    _newsOnline = "http://alivemod.com/alive_news.php?map=" + _map + "&mission=" + _mission + "&player=" + _player;

    _newsOffline = "news.html";


    //Load the correct HTML into the control
    _ctrlHTML = _display displayCtrl 10042;
    _ctrlHTML htmlLoad _newsOnline;

//["Map: %1",  _map] call ALiVE_fnc_dump;
//["Mission: %1",  _mission] call ALiVE_fnc_dump;
//["Player: %1",  _player] call ALiVE_fnc_dump;
//["URL: %1",  _newsOnline] call ALiVE_fnc_dump;
