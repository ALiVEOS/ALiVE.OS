private ["_text", "_array", "_return"];
_text = _this;
_array = toArray _this;
_return = [];

{
    if !(_forEachIndex in [0,1]) then
    {
        _return pushback _x;
    };
} forEach _array;

toString _return;
