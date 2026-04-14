#include "..\script_component.hpp"
// Originally from nr6_hal/HAL/Reloc.sqf

_SCRname = "Reloc";

private ["_HQ","_expression","_radius","_precision","_sourcesCount","_LU","_lastpos","_position","_Spot","_posX","_posY","_isWater","_AAO","_obj"];

_HQ = _this select 0;

_AAO = _HQ getVariable [QEGVAR(boss,chosenAAO),false];

_expression = "(1 + (2 * Meadow)) * (1 - Forest) * (1 - (0.5 * Trees)) * (1 - (10 * sea)) * (1 - (2 * Houses))";
_radius = 100;
_precision = 20;
_sourcesCount = 1;

_obj = _HQ getVariable [QEGVAR(core,obj),(leader _HQ)];

if (_AAO) then
	{
	_obj = _HQ getVariable [QEGVAR(core,eyeOfBattle),getPosATL (vehicle (leader _HQ))]
	};

	{
	if not (isNil {_x}) then
		{
		if not (isNull _x) then
			{
			_LU = leader _x;
			_lastpos = _x getVariable ("START" + (str _x));
			if (isNil ("_lastpos")) then 
				{
				_lastPos = getPosATL (assignedVehicle _LU);
				_x setVariable [("START" + (str _x)),_lastPos]
				};

			_position = [((getPosATL (vehicle (leader _HQ))) select 0) + (random 800) - 400,((getPosATL (vehicle (leader _HQ))) select 1) + (random 800) - 400];
			_Spot = selectBestPlaces [_position,_radius,_expression,_precision,_sourcesCount];
			_Spot = _Spot select 0;
			_Spot = _Spot select 0;

			_posX = _Spot select 0;
			_posY = _Spot select 1;
			
			_isWater = surfaceIsWater [_posX,_posY];

			if (not (_x in (_HQ getVariable [QEGVAR(core,airG),[]])) and not
				(_iswater) and
					((_lastpos distance _obj) > 2000) and 
						((_lastpos distance (leader _HQ)) > 1000) and 
							((isNull ((leader _HQ) findNearestEnemy [_posX,_posY])) or ((((leader _HQ) findNearestEnemy [_posX,_posY]) distance [_posX,_posY]) > 600)) or
								(not (isNull (_LU findNearestEnemy _LU)) and (((_LU findNearestEnemy _LU) distance _LU) < 500))) then 
				{
				_x setVariable [("START" + (str _x)),[_posX,_posY]];
				};
			}
		}
	}   
forEach (_HQ getVariable [QEGVAR(core,nCCargoG),[]]);
