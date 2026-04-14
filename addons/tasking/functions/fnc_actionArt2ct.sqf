#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:1583 (ActionArt2ct)
/**
 * @description Server-side artillery fire mission executor (called via remoteExec from actionArtct)
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	params ["_HQ","_FO","_pos","_selectedPiece","_selectedOrd","_amnt"];


	private _bArr = [_pos,[_selectedPiece],_selectedOrd,_amnt,_FO] call EFUNC(common,artyMission);

	if ((_bArr select 0) and not (_selectedPiece getVariable [QEGVAR(common,batteryBusy),false])) then {
		_selectedPiece setVariable [QEGVAR(common,batteryBusy),true];
		[_bArr select 1,_pos,_bArr select 2,_bArr select 3,_HQ getVariable [QEGVAR(core,friends),[]],_HQ getVariable [QEGVAR(core,artyMarks),false],_selectedOrd,(_amnt) min (_bArr select 4),true] spawn EFUNC(common,CFF_FFE);
		sleep 5;
		[leader _HQ, "Affirmative. " + (groupId _selectedPiece) + " executing requested fire support - Out"] remoteExecCall ["hal_common_fnc_MP_Sidechat"];
		_FO setVariable ["HALArtPos",nil,true];
	} else {
		sleep 5;
		[leader _HQ, "Negative. " + (groupId _selectedPiece) + " unable to execute requested fire support - Out"] remoteExecCall ["hal_common_fnc_MP_Sidechat"];
		_FO setVariable ["HALArtPos",nil,true];
	};
