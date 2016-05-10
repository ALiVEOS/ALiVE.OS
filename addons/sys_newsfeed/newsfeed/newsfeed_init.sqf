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

//diag_log format["Map: %1",  _map];
//diag_log format["Mission: %1",  _mission];
//diag_log format["Player: %1",  _player];
//diag_log format["URL: %1",  _newsOnline];
