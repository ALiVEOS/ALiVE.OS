params ["_side","_support","_callsign"];

switch (_support) do
{
    case "TRANSPORT" :
    {
        private _transportArrayString = format ["NEO_radioTrasportArray_%1", _side];
        private _transportArray = NEO_radioLogic getVariable _transportArrayString;
        private _index = _transportArray findif { (_x select 2) == _callsign };

        if (_index != -1) then
        {
            private _transportToRemove = _transportArray select _index;
            _transportToRemove params ["_vehicle","_group","_callsign","_fsm"];

            {
                if (!isPlayer _x) then {
                    deletevehicle _x;
                }
            } forEach (crew _vehicle);

            deleteVehicle _vehicle;
            _group call ALiVE_fnc_DeleteGroupRemote;

            _fsm setFSMVariable ["_removeFSM", true];

            _transportArray deleteat _index;
            NEO_radioLogic setVariable [_transportArrayString, _transportArray, true];
        }
        else
        {
            ["Support with callsign %1 not found in Transport units", _callsign] call ALiVE_fnc_Dump;
        };
    };

    case "CAS" :
    {
        private _casArrayString = format ["NEO_radioCasArray_%1", _side];
        private _casArray = NEO_radioLogic getVariable _casArrayString;
        private _index = _casArray findIf { (_x select 2) == _callsign };

        if (_index != -1) then
        {
            private _casToRemove = _casArray select _index;
            _casToRemove params ["_vehicle","_group","_callsign","_fsm"];

            {
                if (!isPlayer _x) then {
                    deletevehicle _x;
                };
            } forEach (crew _vehicle);

            deleteVehicle _vehicle;
            _group call ALiVE_fnc_DeleteGroupRemote;

            _fsm setFSMVariable ["_removeFSM", true];

            _casArray deleteat _index;
            NEO_radioLogic setVariable [_casArrayString, _casArray, true];
        }
        else
        {
            ["Support with callsign %1 not found in Cas units", _callsign] call ALiVE_fnc_Dump;
        };
    };

    case "ARTY" :
    {
        private _artyArrayString = format ["NEO_radioArtyArray_%1", _side];
        private _artyArray = NEO_radioLogic getVariable _artyArrayString;
        private _index = _artyArray findIf { (_x select 2) == _callsign };

        if (_index != -1) then
        {
            private _artyToRemove = _artyArray select _index;
            _artyToRemove params ["_leader","_group","_callsign","_units","_roundAvailable","_fsm"];

            deleteVehicle _leader;

            { deletevehicle _x } forEach (units _group);
            _group call ALiVE_fnc_DeleteGroupRemote;

            { deleteVehicle _x } forEach _units;

            _fsm setFSMVariable ["_removeFSM", true];

            _artyArray deleteat _index;
            NEO_radioLogic setVariable [_artyArrayString, _artyArray, true];
        }
        else
        {
            ["Support with callsign %1 not found in Arty units", _callsign] call ALiVE_fnc_Dump;
        };
    };
};