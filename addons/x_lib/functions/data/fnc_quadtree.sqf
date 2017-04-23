#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(quadtree);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_quadtree

Description:
A Spacial-Partioning structure. Sorts points by position in the world on insertion.
Results in fast queries of objects contained within a range.

Parameters:
Any - Parameters for the given operation

Returns:
Any - The result of the given operation

Examples:
(begin example)
Create a quadtree with origin at [0,0,0]
That covers the entire map
Holds 20 objects per quad
Subdivides up to 5 times
_quadtree = [nil,"create", [[0,0,0], worldsize, worldsize, 20, 5]] call ALiVE_fnc_quadtree;
(end)

Author:
SpyderBlack723
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALiVE_fnc_baseClassHash
#define MAINCLASS   ALiVE_fnc_quadtree

private "_result";

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];


switch (_operation) do {

    //////////////////////////////////////////////////
    //
    //  Create a new quadtree
    //
    //  Arguments:
    //      Array:
    //          Position: 2D Position of the quadtree, position should be the bottom-left corner of the rectangle
    //          Width: Full width from left and right corners of the rectangle
    //          Height: Full height from bottom to the top corners of the rectangle
    //          Max Objects: Total objects a single quadtree can hold before dividing
    //          Max Depth: Number of times a quadtree can divide
    //          Depth: Depth of a quadtree, should not be set by user
    //
    //  Returns:
    //      None
    //
    //////////////////////////////////////////////////

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
                ["center", [(_position select 0) + _width * 0.50, (_position select 1) + _height * 0.50]],
                ["halfWidth", _width * 0.50],
                ["halfHeight", _height * 0.50],
                ["children", []],
                ["objects", []],
                ["maxObjects", _maxObjects],
                ["depth", _depth],
                ["maxDepth", _maxDepth]
            ]
        ] call ALiVE_fnc_hashCreate;

    };

    //////////////////////////////////////////////////
    //
    //  Create 4 new quadtrees inside an existing quadtree
    //
    //  Arguments:
    //      None
    //
    //  Notes:
    //      - Should not be called by the user
    //
    //  Returns:
    //      None
    //
    //////////////////////////////////////////////////

    case "subdivide": {

        private _center = _logic select 2 select 0;
        private _maxObjects = _logic select 2 select 5;
        private _maxDepth = _logic select 2 select 7;
        private _depth = _logic select 2 select 6;

        if (_depth < _maxDepth) then {

            private _childWidth = _logic select 2 select 1;
            private _childHeight = _logic select 2 select 2;
            private _childDepth = _depth + 1;

            private _children = _logic select 2 select 3;

            private _childTemplate = [[], _childWidth, _childHeight, _maxObjects, _maxDepth, _childDepth];

            // NW

            _childTemplate set [0, [(_center select 0) - _childWidth, _center select 1]];
            _children pushback ([nil,"create", +_childTemplate] call MAINCLASS);

            // NE

            _childTemplate set [0, +_center];
            _children pushback ([nil,"create", +_childTemplate] call MAINCLASS);

            // SW

            _childTemplate set [0, [(_center select 0) - _childWidth, (_center select 1) - _childHeight]];
            _children pushback ([nil,"create", +_childTemplate] call MAINCLASS);

            // SE

            _childTemplate set [0, [_center select 0, (_center select 1) - _childHeight]];
            _children pushback ([nil,"create", +_childTemplate] call MAINCLASS);

        };

    };

    //////////////////////////////////////////////////
    //
    //  Inserts an item into the quadtree at the correct location
    //
    //  Arguments:
    //      Array:
    //          Position: Position of the item in the world
    //          Value: Value to be stored
    //
    //  Returns:
    //      Success: True if added, false if outside of quadtree
    //
    //////////////////////////////////////////////////

    case "insert": {

        /*
        _args params [
            "_dataPosition",
            "_dataValue"
        ];
        */

        private _dataPosition = _args select 0;

        private _center = _logic select 2 select 0;
        private _halfWidth = _logic select 2 select 1;
        private _halfHeight = _logic select 2 select 2;

        _result = false;

        // check tree contains point

        if (_dataPosition inArea [_center, _halfWidth, _halfHeight, 0, true]) then {

            private _maxObjects = _logic select 2 select 5;
            private _objects = _logic select 2 select 4;

            private _depth = _logic select 2 select 6;
            private _maxDepth = _logic select 2 select 7;
            private _children = _logic select 2 select 3;

            if (count _objects < _maxObjects || {_children isEqualTo [] && _depth == _maxDepth}) exitwith {
                _objects pushback _args;
                _result = true;
            };

            if (_children isEqualTo []) then {
                [_logic,"subdivide"] call MAINCLASS;
            };

            // find child to insert point

            if ((_dataPosition select 0) < (_center select 0)) then {
                // point is either in quad NW or SW

                if ((_dataPosition select 1) < (_center select 1)) then {
                    [(_children select 2),"insert", _args] call MAINCLASS;
                } else {
                    [(_children select 0),"insert", _args] call MAINCLASS;
                };
            } else {
                // point is either in quad NE or SE

                if ((_dataPosition select 1) < (_center select 1)) then {
                    [(_children select 3),"insert", _args] call MAINCLASS;
                } else {
                    [(_children select 1),"insert", _args] call MAINCLASS;
                };
            };

        };

    };

    //////////////////////////////////////////////////
    //
    //  Retrieves items contained in a given rectangle
    //
    //  Arguments:
    //      Array:
    //          Position: Position of the bottom-left corner of the rectangle
    //          Width: Full width of the rectangle from left to right corners
    //          Height: FUll height of the rectangle from bottom to top corners
    //
    //  Returns:
    //      Array:
    //          Items in Range: Items that are contained in the passed rectangle, item format is [position,value]
    //
    //////////////////////////////////////////////////

    case "queryRect": {

        _args params ["_rangePosition","_rangeWidth","_rangeHeight", ["_inAreaArgs",[]]];

        _result = [];

        // check if passed bounding box intersects with tree

        private _center = _logic select 2 select 0;
        private _halfWidth = _logic select 2 select 1;
        private _halfHeight = _logic select 2 select 2;

        if !(
            ((_rangePosition select 0) + _rangeWidth) <= (_center select 0) - _halfWidth ||
            {((_center select 0) + _halfWidth) <= (_rangePosition select 0)} ||
            {((_rangePosition select 1) + _rangeHeight) <= (_center select 1) - _halfHeight} ||
            {((_center select 1) + _halfHeight) <= (_rangePosition select 1)}
        ) then {

            // return objects in this tree
            // that fit inside passed range

            if (_inAreaArgs isEqualTo []) then {
                _inAreaArgs = [[(_rangePosition select 0) + _rangeWidth * 0.50, (_rangePosition select 1) + _rangeHeight * 0.50], _rangeWidth * 0.50, _rangeHeight * 0.50, 0, true];
                _args pushback _inAreaArgs;
            };

            {
                if ((_x select 0) inArea _inAreaArgs) then {
                    _result pushback _x;
                }
            } foreach (_logic select 2 select 4); // objects

            // add objects in sub trees

            {
                _result append ([_x,"queryRect", _args] call MAINCLASS);
            } foreach (_logic select 2 select 3); // children

        };

    };

    //////////////////////////////////////////////////
    //
    //  Retrieves items contained in a given circle
    //
    //  Arguments:
    //      Array:
    //          Position: Center of the circle
    //          Radius: Radius of the circle
    //
    //  Returns:
    //      Array:
    //          Items in Range: Items that are contained in the passed rectangle, item format is [position,value]
    //
    //////////////////////////////////////////////////

    case "queryRadius": {

        _args params ["_circleCenter","_radius"];

        _result = [_logic,"queryRect", [[(_circleCenter select 0) - _radius, (_circleCenter select 1) - _radius], _radius * 2, _radius * 2]] call MAINCLASS;

        _result select {(_x select 0) distance _circleCenter <= _radius};

    };

    //////////////////////////////////////////////////
    //
    //  Retrieves items contained in a given polygon
    //
    //  Arguments:
    //      Array:
    //          Points: Points defining a rectangle
    //
    //  Returns:
    //      Array:
    //          Items in Range: Items that are contained in the passed rectangle, item format is [position,value]
    //
    //////////////////////////////////////////////////

    case "queryPolygon": {

        private _pointArray = _args;

        if (count _pointArray < 3) exitwith {_result = []};

        // generate bounding box for polygon
        // significantly easier to test rect-rect
        // intersection than rect-poly intersection

        private _minX = 0;
        private _minY = 0;
        private _maxX = 0;
        private _maxY = 0;

        {
            if ((_x select 0) < _minX) then {_minX = _x select 0} else {
                if ((_x select 0) > _maxX) then {_maxX = _x select 0}
            };
            if ((_x select 1) < _minY) then {_minY = _x select 1} else {
                if ((_x select 1) > _maxY) then {_maxY = _x select 1}
            };

            if (count _x < 3) then {_x pushback 0};
        } foreach _pointArray;

        private _polygonBB = [[_minX,_minY,0], _maxX - _minX, _maxY - _minY];

        _result = [_logic,"queryPolygonInternal", [_pointArray,_polygonBB]] call MAINCLASS;

    };

    case "queryPolygonInternal": {

        _args params ["_pointArray","_polygonBB"];

        _result = [];

        private _center = _logic select 2 select 0;
        private _halfWidth = _logic select 2 select 1;
        private _halfHeight = _logic select 2 select 2;

        // check if polygon bounding box intersects quad

        _polygonBB params ["_rangePosition","_rangeWidth","_rangeHeight"];

        if !(
            ((_rangePosition select 0) + _rangeWidth) <= (_center select 0) - _halfWidth ||
            {((_center select 0) + _halfWidth) <= (_rangePosition select 0)} ||
            {((_rangePosition select 1) + _rangeHeight) <= (_center select 1) - _halfHeight} ||
            {((_center select 1) + _halfHeight) <= (_rangePosition select 1)}
        ) then {
            // return objects in this tree
            // that fit inside passed polygon

            // inPolygon requires 3D position vectors

            {
                if (count _x < 3) then {
                    if ([_x select 0 select 0,_x select 0 select 1,0] inPolygon _pointArray) then {
                        _result pushback _x;
                    };
                } else {
                    if ((_x select 0) inPolygon _pointArray) then {
                        _result pushback _x;
                    };
                };
            } foreach (_logic select 2 select 4); // objects

            // add objects in sub trees

            {
                _result append ([_x,"queryPolygonInternal", [_pointArray,_polygonBB]] call MAINCLASS);
            } foreach (_logic select 2 select 3); // children
        };

    };

    //////////////////////////////////////////////////
    //
    //  Clears all items from a quadtree and its children
    //
    //  Arguments:
    //      None
    //
    //  Returns:
    //      None
    //
    //////////////////////////////////////////////////

    case "clear": {

        private _objects = _logic select 2 select 4;

        _objects resize 0;

        private _children = _logic select 2 select 3;

        {
            [_x,"clear"] call MAINCLASS;
        } foreach _children;

        _children resize 0; // might be worth ignoring in SQF if max depth is low enough and mem is not an issue

    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };

};

if (!isnil "_result") then {_result} else {nil};