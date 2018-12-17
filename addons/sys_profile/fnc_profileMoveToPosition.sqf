params ["_profile","_position"];

private _pathfindingProcedure = [_profile] call ALiVE_fnc_profileGetPathfindingProcedure;
private _profilePosition = _profile select 2 select 2;
private _profileID = _profile select 2 select 4;

[ALiVE_Pathfinder,"findPath",[_profilePosition,_position,_pathfindingProcedure,true,[_profileID],{
    _this params ["_args","_path"];

    _args params ["_profileID"];

    private _profile = [ALiVE_profileHandler,"getProfile", _profileID] call ALiVE_fnc_profileHandler;

    {
        private _waypoint = [_x] call ALiVE_fnc_createProfileWaypoint;
        [_profile,"addWaypoint", _waypoint] call ALiVE_fnc_profileEntity;
    } foreach _path;

    [ALiVE_Pathfinder,"debugPath", _path] call ALiVE_fnc_pathfinder;
}]] call ALiVE_fnc_pathfinder;

systemchat format ["Added path for procedure: %1", _pathfindingProcedure];