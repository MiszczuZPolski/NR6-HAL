#include "..\script_component.hpp"
// Originally from nr6_hal/HAL/Rev.sqf

_SCRname = "Rev";

private ["_HQ","_players","_KnU","_ldr","_dst","_friends","_enemies"];

_HQ = _this select 0;

_players = [];
_friends = (_HQ getVariable [QEGVAR(core,friends),[]]);
_enemies = (_HQ getVariable [QEGVAR(core,knEnemies),[]]);

if (_HQ getVariable [QEGVAR(core,knowTL),true]) then 
	{
		{
		if (isPlayer (leader _x)) then {_players pushBack _x};
		}
	forEach _friends;
	};

for [{_z = 0},{_z < (count _enemies)},{_z = _z + 1}] do
	{
	_KnU = _enemies select _z;

		{
		if ((_x knowsAbout _KnU) > 0.01) then 
			{
				{
				_x reveal [_KnU,2]
				} 
			forEach ([_HQ] + _players);

			if (EGVAR(core,nEAware) > 0) then
				{
					{
					_ldr = vehicle (leader _x);
					_dst = _ldr distance (vehicle _KnU); 
					if (_dst < EGVAR(core,nEAware)) then
						{
						_x reveal [_KnU,2]
						}
					}
				forEach _friends;
				}
			}
		}
	forEach _friends 
	};

for [{_z = 0},{_z < (count _friends)},{_z = _z + 1}] do
	{
	_KnU = _friends select _z;

		{
		_x reveal [(vehicle (leader _KnU)),4]
		} 
	forEach ([_HQ] + _players)
	};
