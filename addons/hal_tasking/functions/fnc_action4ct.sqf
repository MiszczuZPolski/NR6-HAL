#include "..\\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:197 (Action4ct)
/**
 * @description Server-side condition/execution handler for slot 4: Request close air support
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	private ["_trg","_chosen","_HQ","_dist","_request"];

	_HQ = grpNull;

	if not (isNil "LeaderHQ") then {if ((group (_this select 0)) in ((group LeaderHQ) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQ)}};
	if not (isNil "LeaderHQB") then {if ((group (_this select 0)) in ((group LeaderHQB) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQB)}};
	if not (isNil "LeaderHQC") then {if ((group (_this select 0)) in ((group LeaderHQC) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQC)}};
	if not (isNil "LeaderHQD") then {if ((group (_this select 0)) in ((group LeaderHQD) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQD)}};
	if not (isNil "LeaderHQE") then {if ((group (_this select 0)) in ((group LeaderHQE) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQE)}};
	if not (isNil "LeaderHQF") then {if ((group (_this select 0)) in ((group LeaderHQF) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQF)}};
	if not (isNil "LeaderHQG") then {if ((group (_this select 0)) in ((group LeaderHQG) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQG)}};
	if not (isNil "LeaderHQH") then {if ((group (_this select 0)) in ((group LeaderHQH) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQH)}};

	[(_this select 0), 'Command, requesting close air support at our position - Over'] remoteExecCall ["RYD_MP_Sidechat"];

	sleep 3;

	_trg = (_this select 0) findNearestEnemy (position (_this select 0));
	_request = true;

	if (_trg isEqualTo objNull) then {
		_trg = (_this select 0);
	};

	if (((_this select 0) distance2D _trg) > 300) then {
		_trg = (_this select 0);
	};

	_chosen = grpNull;

	_dist = 10000000;

	{
	if ((typeName _x) == "GROUP") then {
	
		if (not (_x getVariable [("Busy" + (str _x)),false]) and not (_x == (group (_this select 0))) and not (_x getVariable ["Unable",false]) and (((_this select 0) distance2D (leader _x)) < _dist)) then {_chosen = _x; _dist = ((_this select 0) distance2D (leader _x));};
		};
	} forEach (((_HQ getVariable ["RydHQ_BAirG",[]]) + (_HQ getVariable ["RydHQ_RCAS",[]])) - (_HQ getVariable ["RydHQ_Exhausted",[]]));

	if (_chosen isEqualTo grpNull) exitWith {[leader _HQ, (groupId (group (_this select 0))) + ', negative. No air support units are available at the moment - Out'] remoteExecCall ["RYD_MP_Sidechat"]};

	_chosen setVariable ["Busy" + (str _chosen),true];
	_HQ setVariable ["RydHQ_AttackAv",(_HQ getVariable ["RydHQ_AttackAv",[]]) - [_chosen]];
								
	[[_chosen,_trg,_HQ,_request],(["AIR"] call EFUNC(common,goLaunch))] call EFUNC(common,spawn);

	[leader _HQ, (groupId (group (_this select 0))) + ', ' + (groupId _chosen) + ' has been dispatched for CAS - Out'] remoteExecCall ["RYD_MP_Sidechat"];
