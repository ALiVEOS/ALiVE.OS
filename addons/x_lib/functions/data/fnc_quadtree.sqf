#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(quadtree);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_quadtree

Description:
Quadtree class

Parameters:
Any - Parameters for the given operation

Returns:
Array - The hash

Examples:
(begin example)
Create a quadtree with origin at [0,0,0]
That covers the entire map
Holds 20 objects per quad
Subdivides up to 5 times
_quadtree = [nil,"create", [[0,0,0], mapWidth, mapHeight, 20, 5]] call ALiVE_fnc_quadtree;
(end)

See Also:
TODO: BoundingBox Class

Author:
SpyderBlack723
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALIVE_fnc_baseClassHash
#define MAINCLASS   ALIVE_fnc_quadtree

private "_result";

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];


switch (_operation) do {

    case "create": {

        _args params [
            ["_position", [0,0,0]],
            ["_width", 1000],
            ["_height", 1000],
            ["_maxObjects", 20],
            ["_maxDepth", 5],
            ["_depth",1]
        ];

        _result = [
            [
                ["position", _position],
                ["width", _width],
                ["height", _height],
                ["children", []],
                ["objects", []],
                ["maxObjects", _maxObjects],
                ["depth", _depth],
                ["maxDepth", _maxDepth]
            ]
        ] call ALiVE_fnc_hashCreate;

    };


    ////////////// Bounding Box Helpers //////////////

    case "contains": {

        _args params ["_boundingBox","_point"];

        _boundingBox params ["_boundingPos","_boundingSize"];

        if (
            (_point select 0) >= (_boundingPos select 0) &&
            {(_point select 1) >= (_boundingPos select 1)} &&
            {(_point select 0) <= ((_boundingPos select 0) + (_boundingSize select 0))} &&
            {(_point select 1) <= ((_boundingPos select 1) + (_boundingSize select 1))}
        ) then {
            _result = true;
        } else {
            _result = false;
        };

    };

    //////////////////////////////////////////////////


    case "subdivide": {

        private _position = _logic select 2 select 0;
        private _maxObjects = _logic select 2 select 5;
        private _maxDepth = _logic select 2 select 7;
        private _depth = _logic select 2 select 6;

        if (_depth < _maxDepth) then {

            private _childWidth = (_logic select 2 select 1) * 0.50;
            private _childHeight = (_logic select 2 select 2) * 0.50;
            private _childDepth = _depth + 1;

            private _children = _logic select 2 select 3;

            private _childTemplate = [[], _childWidth, _childHeight, _maxObjects, _maxDepth, _childDepth];

            // NW

            _childTemplate set [0, +_position];
            _children pushback ([nil,"create", +_childTemplate] call MAINCLASS);

            // NE

            _childTemplate set [0, [(_position select 0) + _childWidth, _position select 1]];
            _children pushback ([nil,"create", +_childTemplate] call MAINCLASS);

            // SW

            _childTemplate set [0, [(_position select 0), (_position select 1) + _childHeight]];
            _children pushback ([nil,"create", +_childTemplate] call MAINCLASS);

            // SE

            _childTemplate set [0, [(_position select 0) + _childWidth, (_position select 1) + _childHeight]];
            _children pushback ([nil,"create", +_childTemplate] call MAINCLASS);

        };

    };

    case "insert": {

        _args params [
            "_dataPosition",
            "_dataValue"
        ];

        private _position = _logic select 2 select 0;
        private _size = [_logic select 2 select 1, _logic select 2 select 2];

        // ensure tree contains point

        if ([nil,"contains", [[_position, _size], _dataPosition]] call MAINCLASS) then {

            private _maxObjects = _logic select 2 select 5;
            private _objects = _logic select 2 select 4;

            private _depth = _logic select 2 select 6;
            private _maxDepth = _logic select 2 select 7;
            private _children = _logic select 2 select 3;

            if (count _objects <_maxObjects || {_children isEqualTo [] && _depth == _maxDepth}) exitwith {
                _objects pushback _args;
                _result = true;
            };

            if (_children isEqualTo []) then {
                [_logic,"subdivide"] call MAINCLASS;
            };

            private _added = false;

            {
                if (!_added) then {
                    _added = [_x,"insert", _args] call MAINCLASS;
                };
            } foreach _children;

            _result = false;

        };

    };

    case "queryRange": {

        _args params ["_rangePosition","_rangeWidth","_rangeHeight"];

        _result = [];

        // check if passed bounding box intersects with tree

        private _position = _logic select 2 select 0;
        private _width = _logic select 2 select 1;
        private _height = _logic select 2 select 2;

        if (
            ((_rangePosition select 0) + _rangeWidth) <= (_position select 0) ||
            ((_position select 0) + _width) <= (_rangePosition select 0) ||
            ((_rangePosition select 1) + _rangeHeight) <= (_position select 1) ||
            ((_position select 1) + _height) <= (_rangePosition select 1)
        ) exitwith {};

        // return objects in this tree

        private _objects = _logic select 2 select 4;

        _result append _objects;

        // add objects in sub trees

        private _children = _logic select 2 select 3;

        if !(_children isEqualTo []) then {
            {
                _result append ([_x,"queryRange", _args] call MAINCLASS);
            } foreach _children;
        };

    };

    case "clear": {

        private _objects = _logic select 2 select 4;

        _objects resize 0;

        private _children = _logic select 2 select 3;

        {
            [_x,"clear"] call MAINCLASS;
        } foreach _children;

        _children resize 0;

    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };

};

if (!isnil "_result") then {_result} else {nil};