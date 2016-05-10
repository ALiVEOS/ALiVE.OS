private ["_chopper", "_engage", "_crew"];
				_chopper = _this select 0;
				_engage = _this select 1;
				_crew = crew _chopper;
				
				{
					if (!isPlayer _x && !(_x in assignedCargo _chopper)) then
					{
						if (_engage) then
						{
							_x enableAi "TARGET";
							_x enableAi "AUTOTARGET";
							_x setCombatMode "YELLOW";
							group _x enableAttack true;
						}
						else
						{
							_x disableAi "TARGET";
							_x disableAi "AUTOTARGET";
							_x setCombatMode "BLUE";
							group _x enableAttack false;
						};
					};
				} forEach _crew;