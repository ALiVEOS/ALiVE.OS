    private ["_unit", "_text", "_radio","_side"];
    _unit = _this select 0;
    _text = _this select 1;
    _radio = _this select 2;
    // An optional 4th argument names the side the message is for. The server's own respawn
    // notices pass it: they ran with "player" as the speaker, which is nobody on a dedicated
    // server, and nobody's side is UNKNOWN, friendly to no side (measured), so a side's "back
    // on station" and "out of assets" notices reached no one there.
    _side = if (count _this > 3 && {(_this select 3) isEqualType west}) then {_this select 3} else {side group _unit};

    //enableRadio true;
    //enableSentences true;
    //sleep 1;

    _friendlySides = [];
    {if (_x getfriend (_side) >= 0.6) then {_friendlySides pushback _x}} foreach [WEST,EAST,RESISTANCE,CIVILIAN];

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
