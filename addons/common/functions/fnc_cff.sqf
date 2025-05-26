#include "..\script_component.hpp"

params ["_artG","_knownEnemies","_enemyArmor","_friends","_Debug","_ldr"];

private _fr = (group _ldr) getVariable ["RydHQ_Front", locationNull];
if !(isNull _fr) then {
	_knownEnemies = [_knownEnemies, [], {_ldr distance (vehicle _x) }, "ASCEND",{((getPosATL (vehicle _x)) in _fr)}] call BIS_fnc_sortBy;
};

private _amount = RydART_Amount;

private _CFFMissions = ceil (random (count _artG));

for "_i" from 1 to _CFFMissions do {
	private _tgt = [_knownEnemies] call RYD_CFF_TGT;
	if !(isNull _tgt) then {
		private _ammo = "HE";
		private _amnt = _amount;
		if ((random 100) > 85) then {_ammo = "SPECIAL"; _amnt = (ceil (_amount/3))};
		//if (_tgt in _enemyArmor) then {_ammo = "HE";_amnt = 6};

		private _bArr = [(getPosATL _tgt), _artG, _ammo, _amnt, objNull] call RYD_ArtyMission;
		private _possible = _bArr select 0;

		//_UL = leader (_friends select (floor (random (count _friends))));
		private _UL = _tgt getVariable ["RydHQ_MyFO", leader (_friends select (floor (random (count _friends))))];

		if !(isPlayer _UL) then {if ((random 100) < RydxHQ_AIChatDensity) then {[_UL,RydxHQ_AIC_ArtyReq,"ArtyReq"] call RYD_AIChatter}};

		if (_possible) then {
				{
					if !(isNull _x) then {
						_x setVariable ["RydHQ_BatteryBusy", true]
					};
				} forEach (_bArr select 1);
			if ((random 100) < RydxHQ_AIChatDensity) then {[_ldr,RydxHQ_AIC_ArtAss,"ArtAss"] call RYD_AIChatter};
			//[_bArr select 1,_tgt,_bArr select 2,_bArr select 3,_friends,_Debug,_ammo,_amnt] spawn RYD_CFF_FFE

			[[_bArr select 1, _tgt, _bArr select 2, _bArr select 3, _friends, _Debug, _ammo, _amnt min (_bArr select 4)], RYD_CFF_FFE] call RYD_Spawn;
		} else {
			switch (true) do {
				case (_ammo in ["SPECIAL","SECONDARY"]) : {_ammo = "HE"; _amnt = _amount};
				case (_ammo in ["HE"]) : {_ammo = "SECONDARY"; _amnt = _amount};
			};

			_bArr = [(getPosATL _tgt),_artG,_ammo,_amnt,objNull] call RYD_ArtyMission;

			_possible = _bArr select 0;
			if (_possible) then {
					{
						if !(isNull _x) then {
							_x setVariable ["RydHQ_BatteryBusy", true]
						};
					} forEach (_bArr select 1);
				if ((random 100) < RydxHQ_AIChatDensity) then {[_ldr,RydxHQ_AIC_ArtAss,"ArtAss"] call RYD_AIChatter};
				//[_bArr select 1,_tgt,_bArr select 2,_bArr select 3,_friends,_Debug,_ammo,_amnt] spawn RYD_CFF_FFE

				[[_bArr select 1, _tgt, _bArr select 2, _bArr select 3, _friends, _Debug, _ammo, _amnt min (_bArr select 4)], RYD_CFF_FFE] call RYD_Spawn;
			} else {
				if ((random 100) < RydxHQ_AIChatDensity) then {[_ldr, RydxHQ_AIC_ArtDen, "ArtDen"] call RYD_AIChatter}
			};
		};
	};

	sleep (5 + (random 5));
};
