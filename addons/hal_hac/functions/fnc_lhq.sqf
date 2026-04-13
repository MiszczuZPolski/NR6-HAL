#include "..\script_component.hpp"
// Originally from nr6_hal/HAL/LHQ.sqf

_SCRname = "LHQ";

_cycle = 0;

_HQ = _this select 0;
_signum = _HQ getVariable [QEGVAR(core,codeSign),"X"];
_debug = _HQ getVariable [QEGVAR(common,debug),false];

while {not (isNull _HQ)} do
	{
	_last = _HQ getVariable ["leaderHQ",objNull];
	if (isNil ("_last")) then {_last = objNull};
	sleep 0.2;
	if (isNull _HQ) exitWith {};
	if (_HQ getVariable [QEGVAR(common,kIA),false]) exitWith {}; 
	_HQ setVariable ["leaderHQ",(leader _HQ)];

	if not (_last == (leader _HQ)) then
		{
		if not (isNull (leader _HQ)) then
			{
			if (alive (leader _HQ)) then
				{
				if not (isNull _HQ) then
					{
					if not (_cycle == (_HQ getVariable [QEGVAR(core,cyclecount),0])) then
						{
						if not ((_HQ getVariable [QEGVAR(core,cyclecount),0]) < 2) then 
							{
							EGVAR(core,allLeaders) = EGVAR(core,allLeaders) - [_last];
							EGVAR(core,allLeaders) pushBack (leader _HQ);
							_cycle = (_HQ getVariable [QEGVAR(core,cyclecount),0]);

							// Read current traits from HQ (fixes pre-existing scope bug:
							// function is invoked via spawn which does not inherit caller locals).
							_Personality    = _HQ getVariable [QEGVAR(core,personality),     ""];
							_Recklessness   = _HQ getVariable [QEGVAR(core,recklessness),    0.5];
							_Consistency    = _HQ getVariable [QEGVAR(core,consistency),     0.5];
							_Activity       = _HQ getVariable [QEGVAR(core,activity),        0.5];
							_Reflex         = _HQ getVariable [QEGVAR(core,reflex),          0.5];
							_Circumspection = _HQ getVariable [QEGVAR(core,circumspection),  0.5];
							_Fineness       = _HQ getVariable [QEGVAR(core,fineness),        0.5];

							_Personality = _Personality + "-";
							_Recklessness = _Recklessness + (random 0.2);
							_Consistency = _Consistency - (random 0.2);
							_Activity = _Activity - (random 0.2);
							_Reflex = _Reflex - (random 0.2);
							_Circumspection = _Circumspection - (random 0.2);
							_Fineness = _Fineness - (random 0.2);
							
							if (_Recklessness > 1) then {_Recklessness = 1};
							if (_Recklessness < 0) then {_Recklessness = 0};
							
							if (_Consistency > 1) then {_Consistency = 1};
							if (_Consistency < 0) then {_Consistency = 0};
							
							if (_Activity > 1) then {_Activity = 1};
							if (_Activity < 0) then {_Activity = 0};
							
							if (_Reflex > 1) then {_Reflex = 1};
							if (_Reflex < 0) then {_Reflex = 0};
							
							if (_Circumspection > 1) then {_Circumspection = 1};
							if (_Circumspection < 0) then {_Circumspection = 0};
							
							if (_Fineness > 1) then {_Fineness = 1};
							if (_Fineness < 0) then {_Fineness = 0};
							
							_HQ setVariable [QEGVAR(core,recklessness),_Recklessness];
							_HQ setVariable [QEGVAR(core,consistency),_Consistency];
							_HQ setVariable [QEGVAR(core,activity),_Activity];
							_HQ setVariable [QEGVAR(core,reflex),_Reflex];
							_HQ setVariable [QEGVAR(core,circumspection),_Circumspection];
							_HQ setVariable [QEGVAR(core,fineness),_Fineness];

							[_HQ] spawn
								{
								params ["_HQ"];
								sleep (60 + (random 120));
								_HQ setVariable [QEGVAR(core,morale),(_HQ getVariable [QEGVAR(core,morale),0]) - (10 + round (random 10))]
								}
							}
						}
					}
				}
			}
		};

	if (({alive _x} count (units _HQ)) == 0) exitWith 
		{
		EGVAR(core,allHQ) = EGVAR(core,allHQ) - [_HQ];
		};
	};

if (_debug) then 
	{
	hintSilent format ["HQ of %1 forces has been destroyed!",_signum]
	};
