#include "..\\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:309 (Action5ct)
/**
 * @description Server-side condition/execution handler for slot 5: Request infantry support
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

params ["_unit"];
private _grp = group _unit;

private _HQ = grpNull;

if not (isNil "LeaderHQ") then {if (_grp in ((group LeaderHQ) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQ)}};
if not (isNil "LeaderHQB") then {if (_grp in ((group LeaderHQB) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQB)}};
if not (isNil "LeaderHQC") then {if (_grp in ((group LeaderHQC) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQC)}};
if not (isNil "LeaderHQD") then {if (_grp in ((group LeaderHQD) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQD)}};
if not (isNil "LeaderHQE") then {if (_grp in ((group LeaderHQE) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQE)}};
if not (isNil "LeaderHQF") then {if (_grp in ((group LeaderHQF) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQF)}};
if not (isNil "LeaderHQG") then {if (_grp in ((group LeaderHQG) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQG)}};
if not (isNil "LeaderHQH") then {if (_grp in ((group LeaderHQH) getVariable ["RydHQ_Friends",[]])) then {_HQ = (group LeaderHQH)}};

[_unit, 'Command, requesting infantry support at our position - Over'] remoteExecCall ["hal_common_fnc_MP_Sidechat"];

sleep 3;

private _trg = _unit findNearestEnemy (position _unit);
private _request = true;

if (_trg isEqualTo objNull) then {
	_trg = _unit;
	_request = true;
};

if ((_unit distance2D _trg) > 250) then {
	_trg = _unit;
	_request = true;
};

_trg = (vehicle (leader (group _trg)));

private _chosen = grpNull;

private _dist = 10000000;

{

if ((typeName _x) == "GROUP") then {

if (not (_x getVariable [("Busy" + (str _x)),false]) and not (_x == _grp) and not (_x getVariable ["Unable",false]) and ((_unit distance2D (leader _x)) < _dist)) then {_chosen = _x; _dist = (_unit distance2D (leader _x));};
};
} forEach (((_HQ getVariable ["RydHQ_NCrewInfG",[]]) - (_HQ getVariable ["RydHQ_SpecForG",[]])) + ((_HQ getVariable ["RydHQ_CarsG",[]]) - ((_HQ getVariable ["RydHQ_ATInfG",[]]) + (_HQ getVariable ["RydHQ_AAInfG",[]]) + (_HQ getVariable ["RydHQ_SupportG",[]]) + (_HQ getVariable ["RydHQ_NCCargoG",[]]))));

if (_chosen isEqualTo grpNull) exitWith {[leader _HQ, (groupId _grp) + ', negative. No infantry squads are available at the moment - Out'] remoteExecCall ["hal_common_fnc_MP_Sidechat"]};


_chosen setVariable ["Busy" + (str _chosen),true];
_HQ setVariable ["RydHQ_AttackAv",(_HQ getVariable ["RydHQ_AttackAv",[]]) - [_chosen]];

[[_chosen,_trg,_HQ,_request],(["INF"] call EFUNC(common,goLaunch))] call EFUNC(common,spawn);

[leader _HQ, (groupId _grp) + ', ' + (groupId _chosen) + ' has been dispatched - Out'] remoteExecCall ["hal_common_fnc_MP_Sidechat"];
