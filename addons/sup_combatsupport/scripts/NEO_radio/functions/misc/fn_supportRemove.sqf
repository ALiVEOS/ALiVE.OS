	private ["_side", "_support", "_callsign"];
	_side = _this select 0;
	_support = _this select 1;
	_callsign = _this select 2;

	switch (_support) do
	{
		case "TRANSPORT" :
		{
			private ["_array", "_index"];
			_array = NEO_radioLogic getVariable format ["NEO_radioTrasportArray_%1", _side];
			_index = 99;

			{
				if ((_x select 2) == _callsign) then
				{
					_index = _forEachIndex;
				};
			} forEach _array;

			if (_index != 99) then
			{
				{
					switch (_forEachIndex) do
					{
						case 0 : { { if (!isPlayer _x) then { deletevehicle _x } } forEach crew _x; deleteVehicle _x };
						case 1 : { _x call ALiVE_fnc_DeleteGroupRemote };
					};
				} forEach (_array select _index);

				_array set [_index, "DELETEPLEASE"];
				_array = _array - ["DELETEPLEASE"];
				NEO_radioLogic setVariable [format ["NEO_radioTrasportArray_%1", _side], _array, true];
			}
			else
			{
				diag_log format ["Support with callsign %1 not found in Transport units", _callsign];
			};
		};

		case "CAS" :
		{
			private ["_array", "_index"];
			_array = NEO_radioLogic getVariable format ["NEO_radioCasArray_%1", _side];
			_index = 99;

			{
				if ((_x select 2) == _callsign) then
				{
					_index = _forEachIndex;
				};
			} forEach _array;

			if (_index != 99) then
			{
				{
					switch (_forEachIndex) do
					{
						case 0 : { { deletevehicle _x } forEach crew _x; deleteVehicle _x };
						case 1 : { _x call ALiVE_fnc_DeleteGroupRemote };
					};
				} forEach (_array select _index);

				_array set [_index, "DELETEPLEASE"];
				_array = _array - ["DELETEPLEASE"];
				NEO_radioLogic setVariable [format ["NEO_radioCasArray_%1", _side], _array, true];
			}
			else
			{
				diag_log format ["Support with callsign %1 not found in Cas units", _callsign];
			};
		};

		/*case "ARTY" :
		{
			private ["_array", "_index"];
			_array = NEO_radioLogic getVariable format ["NEO_radioArtyArray_%1", _side];
			_index = 99;

			{
				if ((_x select 2) == _callsign) then
				{
					_index = _forEachIndex;
				};
			} forEach _array;

			if (_index != 99) then
			{
				{
					switch (_forEachIndex) do
					{
						case 0 : { deleteVehicle _x };
						case 1 : { { deletevehicle _x } forEach units _x; _x call ALiVE_fnc_DeleteGroupRemote };
						case 3 : { { deleteVehicle _x } forEach _x };
					};
				} forEach (_array select _index);

				_array set [_index, "DELETEPLEASE"];
				_array = _array - ["DELETEPLEASE"];
				NEO_radioLogic setVariable [format ["NEO_radioArtyArray_%1", _side], _array, true];
			}
			else
			{
				diag_log format ["Support with callsign %1 not found in Arty units", _callsign];
			};
		};*/
	};

