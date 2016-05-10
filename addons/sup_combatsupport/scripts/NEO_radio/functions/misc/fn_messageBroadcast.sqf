	private ["_unit", "_text", "_radio","_side"];
	_unit = _this select 0;
	_text = _this select 1;
	_radio = _this select 2;
	_side = side _unit;

	//enableRadio true;
	//enableSentences true;
	//sleep 1;

	_friendlySides = [];
	{if (_x getfriend (_side) >= 0.6) then {_friendlySides set [count _friendlySides,_x]}} foreach [WEST,EAST,RESISTANCE,CIVILIAN];

	switch (_radio) do
	{
		case "global" : { _unit globalChat _text };
		case "side" : { {[_x,"HQ"] sideChat _text} foreach _friendlySides };
		case "group" : { _unit groupChat _text };
		case "vehicle" : { _unit vehicleChat _text };
		case "sideRadio" : { _unit sideRadio _text };
	};
	
	//sleep 1;
	//enableSentences false;
	//enableRadio false;


true;
