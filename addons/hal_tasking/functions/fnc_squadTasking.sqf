#include "..\script_component.hpp"
// Originally from nr6_hal/SquadTaskingNR6.sqf

while {true} do {

	private ["_HalFriends"];

	if (isNil ("LeaderHQ")) then {LeaderHQ = objNull};
	if (isNil ("LeaderHQB")) then {LeaderHQB = objNull};
	if (isNil ("LeaderHQC")) then {LeaderHQC = objNull};
	if (isNil ("LeaderHQD")) then {LeaderHQD = objNull};
	if (isNil ("LeaderHQE")) then {LeaderHQE = objNull};
	if (isNil ("LeaderHQF")) then {LeaderHQF = objNull};
	if (isNil ("LeaderHQG")) then {LeaderHQG = objNull};
	if (isNil ("LeaderHQH")) then {LeaderHQH = objNull};


	_HalFriends = (group LeaderHQ getVariable [QEGVAR(core,friends),[]]) + (group LeaderHQB getVariable [QEGVAR(core,friends),[]]) + (group LeaderHQC getVariable [QEGVAR(core,friends),[]]) + (group LeaderHQD getVariable [QEGVAR(core,friends),[]]) + (group LeaderHQE getVariable [QEGVAR(core,friends),[]]) + (group LeaderHQF getVariable [QEGVAR(core,friends),[]]) + (group LeaderHQG getVariable [QEGVAR(core,friends),[]]) + (group LeaderHQH getVariable [QEGVAR(core,friends),[]]);


	{
		private ["_IsHal"];

		if ((group _x in _HalFriends) or ((group _x) getVariable ["EnableHALActions",false])) then {
			_IsHal = true;
		} else {
			_IsHal = false;
		};

		if (EGVAR(core,actionsMenu)) then {

			if ((_x == leader _x) and (not (_x getVariable ["HAL_TaskMenuAdded",false]) or not (_x == (_x getVariable ["HAL_PlayerUnit",objNull]))) and (_IsHal)) then {

					if not (EGVAR(core,actionsAceOnly)) then {

						[_x] remoteExecCall ["hal_tasking_fnc_actionMfnc",_x];
						
					};

					if ((isClass(configFile >> "CfgPatches" >> "ace_main")) and not (_x getVariable ["HAL_TaskMenuAdded",false])) then {

					[_x] remoteExecCall ["hal_tasking_fnc_aceActionMfnc",_x];				
					
					};
					_x setVariable ["HAL_TaskMenuAdded",true];
					_x setVariable ["HAL_PlayerUnit",_x];
				};

			if ((not (_x == leader _x) and (_x getVariable ["HAL_TaskMenuAdded",false])) or (not (_IsHal) and (_x getVariable ["HAL_TaskMenuAdded",false]))) then {

					if not (EGVAR(core,actionsAceOnly)) then {

						[_x] remoteExecCall ["hal_tasking_fnc_actionMfncR",_x];
						
					};
					if (isClass(configFile >> "CfgPatches" >> "ace_main")) then {

						[_x] remoteExecCall ["hal_tasking_fnc_aceActionMfncR",_x];

					};
					_x setVariable ["HAL_TaskMenuAdded",false];

				};
			};

		// BELOW IS DEPRECATED

		//Tasking

		if (EGVAR(core,taskActions)) then {
		
			if ((_x == leader _x) and not (_x getVariable ["HAL_Task1Added",false]) and (_IsHal)) then {

				if not (EGVAR(core,actionsAceOnly)) then {

					[_x] remoteExecCall ["hal_tasking_fnc_action1fnc",_x];
				};

				if (isClass(configFile >> "CfgPatches" >> "ace_main")) then {

					[_x] remoteExecCall ["hal_tasking_fnc_aceAction1fnc",_x];				
					
				};
				_x setVariable ["HAL_Task1Added",true];
			};

			if ((_x == leader _x) and not (_x getVariable ["HAL_Task2Added",false]) and (_IsHal)) then {

				if not (EGVAR(core,actionsAceOnly)) then {

					[_x] remoteExecCall ["hal_tasking_fnc_action2fnc",_x];
					
				};

				if (isClass(configFile >> "CfgPatches" >> "ace_main")) then {

					[_x] remoteExecCall ["hal_tasking_fnc_aceAction2fnc",_x];
					
				};

				_x setVariable ["HAL_Task2Added",true];
			};

			if ((_x == leader _x) and not (_x getVariable ["HAL_Task3Added",false]) and (_IsHal)) then {

				if not (EGVAR(core,actionsAceOnly)) then {

					[_x] remoteExecCall ["hal_tasking_fnc_action3fnc",_x];
					
				};

				if (isClass(configFile >> "CfgPatches" >> "ace_main")) then {

					[_x] remoteExecCall ["hal_tasking_fnc_aceAction3fnc",_x];
					
				};

				_x setVariable ["HAL_Task3Added",true];
			};

			if ((not (_x == leader _x) and (_x getVariable ["HAL_Task1Added",false])) or (not (_IsHal) and (_x getVariable ["HAL_Task1Added",false]))) then {

				if not (EGVAR(core,actionsAceOnly)) then {

					[_x] remoteExecCall ["hal_tasking_fnc_action1fncR",_x];

				};
				if (isClass(configFile >> "CfgPatches" >> "ace_main")) then {

					[_x] remoteExecCall ["hal_tasking_fnc_aceAction1fncR",_x];

				};
				_x setVariable ["HAL_Task1Added",false];

			};

			if ((not (_x == leader _x) and (_x getVariable ["HAL_Task2Added",false])) or (not (_IsHal) and (_x getVariable ["HAL_Task2Added",false]))) then {

				if not (EGVAR(core,actionsAceOnly)) then {

					[_x] remoteExecCall ["hal_tasking_fnc_action2fncR",_x];
					
				};
				if (isClass(configFile >> "CfgPatches" >> "ace_main")) then {

					[_x] remoteExecCall ["hal_tasking_fnc_aceAction2fncR",_x];

				};
				_x setVariable ["HAL_Task2Added",false];

			};

			if ((not (_x == leader _x) and (_x getVariable ["HAL_Task3Added",false])) or (not (_IsHal) and (_x getVariable ["HAL_Task3Added",false]))) then {

				if not (EGVAR(core,actionsAceOnly)) then {

					[_x] remoteExecCall ["hal_tasking_fnc_action3fncR",_x];
					
				};
				if (isClass(configFile >> "CfgPatches" >> "ace_main")) then {

					[_x] remoteExecCall ["hal_tasking_fnc_aceAction3fncR",_x];
					
				};
				_x setVariable ["HAL_Task3Added",false];

			};
		
		};

		//Supports

		if (EGVAR(core,supportActions)) then {

			if ((_x == leader _x) and not (_x getVariable ["HAL_Task4Added",false]) and (_IsHal)) then {

				if not (EGVAR(core,actionsAceOnly)) then {

					[_x] remoteExecCall ["hal_tasking_fnc_action4fnc",_x];
					
				};

				if (isClass(configFile >> "CfgPatches" >> "ace_main")) then {

					[_x] remoteExecCall ["hal_tasking_fnc_aceAction4fnc",_x];
					
				};

				_x setVariable ["HAL_Task4Added",true];
			};

			if ((not (_x == leader _x) and (_x getVariable ["HAL_Task4Added",false])) or (not (_IsHal) and (_x getVariable ["HAL_Task4Added",false]))) then {

				if not (EGVAR(core,actionsAceOnly)) then {

					[_x] remoteExecCall ["hal_tasking_fnc_action4fncR",_x];
					
				};
				if (isClass(configFile >> "CfgPatches" >> "ace_main")) then {

					[_x] remoteExecCall ["hal_tasking_fnc_aceAction4fncR",_x];

				};
				_x setVariable ["HAL_Task4Added",false];

			};

			if ((_x == leader _x) and not (_x getVariable ["HAL_Task5Added",false]) and (_IsHal)) then {

				if not (EGVAR(core,actionsAceOnly)) then {

					[_x] remoteExecCall ["hal_tasking_fnc_action5fnc",_x];
					
				};

				if (isClass(configFile >> "CfgPatches" >> "ace_main")) then {

					[_x] remoteExecCall ["hal_tasking_fnc_aceAction5fnc",_x];
					
				};

				_x setVariable ["HAL_Task5Added",true];
			};

			if ((not (_x == leader _x) and (_x getVariable ["HAL_Task5Added",false])) or (not (_IsHal) and (_x getVariable ["HAL_Task5Added",false]))) then {

				if not (EGVAR(core,actionsAceOnly)) then {

					[_x] remoteExecCall ["hal_tasking_fnc_action5fncR",_x];
					
				};
				if (isClass(configFile >> "CfgPatches" >> "ace_main")) then {

					[_x] remoteExecCall ["hal_tasking_fnc_aceAction5fncR",_x];

				};
				_x setVariable ["HAL_Task5Added",false];

			};

			if ((_x == leader _x) and not (_x getVariable ["HAL_Task6Added",false]) and (_IsHal)) then {

				if not (EGVAR(core,actionsAceOnly)) then {

					[_x] remoteExecCall ["hal_tasking_fnc_action6fnc",_x];
					
				};

				if (isClass(configFile >> "CfgPatches" >> "ace_main")) then {

					[_x] remoteExecCall ["hal_tasking_fnc_aceAction6fnc",_x];
					
				};

				_x setVariable ["HAL_Task6Added",true];
			};

			if ((not (_x == leader _x) and (_x getVariable ["HAL_Task6Added",false])) or (not (_IsHal) and (_x getVariable ["HAL_Task6Added",false]))) then {

				if not (EGVAR(core,actionsAceOnly)) then {

					[_x] remoteExecCall ["hal_tasking_fnc_action6fncR",_x];
					
				};
				if (isClass(configFile >> "CfgPatches" >> "ace_main")) then {

					[_x] remoteExecCall ["hal_tasking_fnc_aceAction6fncR",_x];

				};
				_x setVariable ["HAL_Task6Added",false];

			};

			if ((_x == leader _x) and not (_x getVariable ["HAL_Task7Added",false]) and (_IsHal)) then {

				if not (EGVAR(core,actionsAceOnly)) then {

					[_x] remoteExecCall ["hal_tasking_fnc_action7fnc",_x];
					
				};

				if (isClass(configFile >> "CfgPatches" >> "ace_main")) then {

					[_x] remoteExecCall ["hal_tasking_fnc_aceAction7fnc",_x];
					
				};

				_x setVariable ["HAL_Task7Added",true];
			};

			if ((not (_x == leader _x) and (_x getVariable ["HAL_Task7Added",false])) or (not (_IsHal) and (_x getVariable ["HAL_Task7Added",false]))) then {

				if not (EGVAR(core,actionsAceOnly)) then {

					[_x] remoteExecCall ["hal_tasking_fnc_action7fncR",_x];
					
				};
				if (isClass(configFile >> "CfgPatches" >> "ace_main")) then {

					[_x] remoteExecCall ["hal_tasking_fnc_aceAction7fncR",_x];

				};
				_x setVariable ["HAL_Task7Added",false];

			};

			//LOGISTICS

			if ((_x == leader _x) and not (_x getVariable ["HAL_Task8Added",false]) and (_IsHal)) then {

				if not (EGVAR(core,actionsAceOnly)) then {

					[_x] remoteExecCall ["hal_tasking_fnc_action8fnc",_x];
					
				};

				if (isClass(configFile >> "CfgPatches" >> "ace_main")) then {

					[_x] remoteExecCall ["hal_tasking_fnc_aceAction8fnc",_x];
					
				};

				_x setVariable ["HAL_Task8Added",true];
			};

			if ((not (_x == leader _x) and (_x getVariable ["HAL_Task8Added",false])) or (not (_IsHal) and (_x getVariable ["HAL_Task8Added",false]))) then {

				if not (EGVAR(core,actionsAceOnly)) then {

					[_x] remoteExecCall ["hal_tasking_fnc_action8fncR",_x];
					
				};
				if (isClass(configFile >> "CfgPatches" >> "ace_main")) then {

					[_x] remoteExecCall ["hal_tasking_fnc_aceAction8fncR",_x];

				};
				_x setVariable ["HAL_Task8Added",false];

			};

			if ((_x == leader _x) and not (_x getVariable ["HAL_Task9Added",false]) and (_IsHal)) then {

				if not (EGVAR(core,actionsAceOnly)) then {

					[_x] remoteExecCall ["hal_tasking_fnc_action9fnc",_x];
					
				};

				if (isClass(configFile >> "CfgPatches" >> "ace_main")) then {

					[_x] remoteExecCall ["hal_tasking_fnc_aceAction9fnc",_x];
					
				};

				_x setVariable ["HAL_Task9Added",true];
			};

			if ((not (_x == leader _x) and (_x getVariable ["HAL_Task9Added",false])) or (not (_IsHal) and (_x getVariable ["HAL_Task9Added",false]))) then {

				if not (EGVAR(core,actionsAceOnly)) then {

					[_x] remoteExecCall ["hal_tasking_fnc_action9fncR",_x];
					
				};
				if (isClass(configFile >> "CfgPatches" >> "ace_main")) then {

					[_x] remoteExecCall ["hal_tasking_fnc_aceAction9fncR",_x];

				};
				_x setVariable ["HAL_Task9Added",false];

			};

			if ((_x == leader _x) and not (_x getVariable ["HAL_Task10Added",false]) and (_IsHal)) then {

				if not (EGVAR(core,actionsAceOnly)) then {

					[_x] remoteExecCall ["hal_tasking_fnc_action10fnc",_x];
					
				};

				if (isClass(configFile >> "CfgPatches" >> "ace_main")) then {

					[_x] remoteExecCall ["hal_tasking_fnc_aceAction10fnc",_x];
					
				};

				_x setVariable ["HAL_Task10Added",true];
			};

			if ((not (_x == leader _x) and (_x getVariable ["HAL_Task10Added",false])) or (not (_IsHal) and (_x getVariable ["HAL_Task10Added",false]))) then {

				if not (EGVAR(core,actionsAceOnly)) then {

					[_x] remoteExecCall ["hal_tasking_fnc_action10fncR",_x];
					
				};
				if (isClass(configFile >> "CfgPatches" >> "ace_main")) then {

					[_x] remoteExecCall ["hal_tasking_fnc_aceAction10fncR",_x];

				};
				_x setVariable ["HAL_Task10Added",false];

			};

			if ((_x == leader _x) and not (_x getVariable ["HAL_Task11Added",false]) and (_IsHal)) then {

				if not (EGVAR(core,actionsAceOnly)) then {

					[_x] remoteExecCall ["hal_tasking_fnc_action11fnc",_x];
					
				};

				if (isClass(configFile >> "CfgPatches" >> "ace_main")) then {

					[_x] remoteExecCall ["hal_tasking_fnc_aceAction11fnc",_x];
					
				};

				_x setVariable ["HAL_Task11Added",true];
			};

			if ((not (_x == leader _x) and (_x getVariable ["HAL_Task11Added",false])) or (not (_IsHal) and (_x getVariable ["HAL_Task11Added",false]))) then {

				if not (EGVAR(core,actionsAceOnly)) then {

					[_x] remoteExecCall ["hal_tasking_fnc_action11fncR",_x];
					
				};
				if (isClass(configFile >> "CfgPatches" >> "ace_main")) then {

					[_x] remoteExecCall ["hal_tasking_fnc_aceAction11fncR",_x];

				};
				_x setVariable ["HAL_Task11Added",false];

			};

			if ((_x == leader _x) and not (_x getVariable ["HAL_Task12Added",false]) and (_IsHal)) then {

				if not (EGVAR(core,actionsAceOnly)) then {

					[_x] remoteExecCall ["hal_tasking_fnc_action12fnc",_x];
					
				};

				if (isClass(configFile >> "CfgPatches" >> "ace_main")) then {

					[_x] remoteExecCall ["hal_tasking_fnc_aceAction12fnc",_x];
					
				};

				_x setVariable ["HAL_Task12Added",true];
			};

			if ((not (_x == leader _x) and (_x getVariable ["HAL_Task12Added",false])) or (not (_IsHal) and (_x getVariable ["HAL_Task12Added",false]))) then {

				if not (EGVAR(core,actionsAceOnly)) then {

					[_x] remoteExecCall ["hal_tasking_fnc_action12fncR",_x];
					
				};
				if (isClass(configFile >> "CfgPatches" >> "ace_main")) then {

					[_x] remoteExecCall ["hal_tasking_fnc_aceAction12fncR",_x];

				};
				_x setVariable ["HAL_Task12Added",false];

			};

			if ((_x == leader _x) and not (_x getVariable ["HAL_Task13Added",false]) and (_IsHal)) then {

				if not (EGVAR(core,actionsAceOnly)) then {

					[_x] remoteExecCall ["hal_tasking_fnc_action13fnc",_x];
					
				};

				if (isClass(configFile >> "CfgPatches" >> "ace_main")) then {

					[_x] remoteExecCall ["hal_tasking_fnc_aceAction13fnc",_x];
					
				};

				_x setVariable ["HAL_Task13Added",true];
			};

			if ((not (_x == leader _x) and (_x getVariable ["HAL_Task13Added",false])) or (not (_IsHal) and (_x getVariable ["HAL_Task13Added",false]))) then {

				if not (EGVAR(core,actionsAceOnly)) then {

					[_x] remoteExecCall ["hal_tasking_fnc_action13fncR",_x];
					
				};
				if (isClass(configFile >> "CfgPatches" >> "ace_main")) then {

					[_x] remoteExecCall ["hal_tasking_fnc_aceAction13fncR",_x];

				};
				_x setVariable ["HAL_Task13Added",false];

			};
		};
		
	} forEach allPlayers;

	sleep 15;
};
