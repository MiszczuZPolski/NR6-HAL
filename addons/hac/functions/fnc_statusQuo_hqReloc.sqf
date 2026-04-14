#include "..\script_component.hpp"
// Originally from nr6_hal/HAC_fnc2.sqf:1289-1430 (RYD_StatusQuo, block S9)

/**
 * @description HQ self-relocation: waypoint generation when RydHQ_LRelocating is set.
 *              Spawns an arrival watcher that issues a fallback waypoint if enemies
 *              are detected near the destination.
 * @param {Group} _HQ The HQ group
 * @param {Array} _knownEG Known enemy groups array
 * @param {Boolean} _AAO All-attack-order doctrine flag (reloc skipped if AAO active)
 * @param {Number} _cycleC Current cycle counter
 * @return {nil}
 */
params ["_HQ", "_knownEG", "_AAO", "_cycleC"];

if ((_HQ getVariable [QEGVAR(core,lRelocating),false]) and {not (_AAO)}) then
    {
    if ((abs (speed (vehicle (_HQ getVariable ["leaderHQ",(leader _HQ)])))) < 0.1) then {_HQ setVariable ["onMove",false]};
    private _onMove = _HQ getVariable ["onMove",false];

    if not (_onMove) then
        {
        if (not (isPlayer (_HQ getVariable ["leaderHQ",(leader _HQ)])) and {((_cycleC == 1) or {not ((_HQ getVariable [QEGVAR(core,progress),0]) == 0)})}) then
            {
            [_HQ] call CBA_fnc_clearWaypoints;if (_HQ getVariable [QEGVAR(common,kIA),false]) exitWith {};

            private _Lpos = position (_HQ getVariable ["leaderHQ",(leader _HQ)]);
            if (_cycleC == 1) then {_HQ setVariable [QGVAR(fpos),_Lpos]};

            private _rds = 0;

            if (_HQ getVariable [QEGVAR(core,lRelocating),false]) then
                {
                _rds = 0;
                switch (_HQ getVariable [QEGVAR(core,nObj),1]) do
                    {
                    case (1) :
                        {
                        _Lpos = (_HQ getVariable [QGVAR(fpos),_Lpos]);
                        if ((_HQ getVariable ["leaderHQ",(leader _HQ)]) in (RydBBa_HQs + RydBBb_HQs)) then
                            {
                            _Lpos = position (_HQ getVariable ["leaderHQ",(leader _HQ)])
                            };

                        _rds = 0
                        };

                    case (2) : {_Lpos = position (_HQ getVariable [QEGVAR(core,obj1),(leader _HQ)])};
                    case (3) : {_Lpos = position (_HQ getVariable [QEGVAR(core,obj2),(leader _HQ)])};
                    default {_Lpos = position (_HQ getVariable [QEGVAR(core,obj3),(leader _HQ)])};
                    };
                };

            private _spd = "LIMITED";
            if ((_HQ getVariable [QEGVAR(core,progress),0]) == -1) then {_spd = "NORMAL"};
            _HQ setVariable [QEGVAR(core,progress),0];
            private _enemyN = false;

                {
                private _eLdr = vehicle (leader _x);
                private _eDst = _eLdr distance _Lpos;

                if (_eDst < 600) exitWith {_enemyN = true}
                }
            forEach _knownEG;

            if not (_enemyN) then
                {
                private _wp = [_HQ,_Lpos,"MOVE","AWARE","GREEN",_spd,["true",""],true,_rds,[0,0,0],"FILE"] call EFUNC(common,WPadd);
                if (isNull (assignedVehicle (_HQ getVariable ["leaderHQ",(leader _HQ)]))) then
                    {
                    if ((_HQ getVariable [QEGVAR(core,getHQInside),false])) then {[_wp] call EFUNC(common,goInside)}
                    };

                if (((_HQ getVariable [QEGVAR(core,lRelocating),false])) and {((_HQ getVariable [QEGVAR(core,nObj),1]) > 1) and {(_cycleC > 1)}}) then
                    {
                    private _code =
                        {
                        private _Lpos = _this select 0;
                        private _HQ = _this select 1;
                        private _knownEG = _this select 2;

                        private _eDst = 1000;
                        private _onPlace = false;
                        private _getBack = false;

                        waitUntil
                            {
                            sleep 10;

                                {
                                private _eLdr = vehicle (leader _x);
                                _eDst = _eLdr distance _Lpos;

                                if (_eDst < 600) exitWith {_getBack = true}
                                }
                            forEach _knownEG;

                            if (isNull _HQ) then
                                {
                                _onPlace = true
                                }
                            else
                                {
                                if not (_getBack) then
                                    {
                                    if ((((vehicle (_HQ getVariable ["leaderHQ",(leader _HQ)])) distance _LPos) < 30) or {(_HQ getVariable [QEGVAR(common,kIA),false])}) then {_onPlace = true}
                                    }
                                };

                            ((_getback) or {(_onPlace)})
                            };

                        if not (_onPlace) then
                            {
                            _rds = 30;
                            switch (true) do
                                {
                                case ((_HQ getVariable [QEGVAR(core,nObj),1]) <= 2) : {_Lpos = getPosATL (vehicle (_HQ getVariable ["leaderHQ",(leader _HQ)]));_rds = 0};
                                case ((_HQ getVariable [QEGVAR(core,nObj),1]) == 3) : {_Lpos = position (_HQ getVariable [QEGVAR(core,obj1),(leader _HQ)])};
                                case ((_HQ getVariable [QEGVAR(core,nObj),1]) >= 4) : {_Lpos = position (_HQ getVariable [QEGVAR(core,obj2),(leader _HQ)])};
                                };

                            _getBack = false;

                                {
                                private _eLdr = vehicle (leader _x);
                                _eDst = _eLdr distance _Lpos;

                                if (_eDst < 600) exitWith {_getBack = true}
                                }
                            forEach _knownEG;

                            if (_getBack) then {_Lpos = getPosATL (vehicle (_HQ getVariable ["leaderHQ",(leader _HQ)]));_rds = 0};

                            [_HQ] call CBA_fnc_clearWaypoints;if (_HQ getVariable [QEGVAR(common,kIA),false]) exitWith {};

                            private _spd = "NORMAL";
                            if not (((vehicle (_HQ getVariable ["leaderHQ",(leader _HQ)])) distance _LPos) < 50) then {_spd = "FULL"};
                            private _wp = [_HQ,_Lpos,"MOVE","AWARE","GREEN",_spd,["true",""],true,_rds,[0,0,0],"FILE"] call EFUNC(common,WPadd);
                            if (isNull (assignedVehicle (_HQ getVariable ["leaderHQ",(leader _HQ)]))) then
                                {
                                if (_HQ getVariable [QEGVAR(core,getHQInside),false]) then {[_wp] call EFUNC(common,goInside)}
                                };

                            _HQ setVariable ["onMove",true];
                            }
                        };

                    [[_Lpos,_HQ,_knownEG],_code] call EFUNC(common,spawn)
                    }
                }
            }
        }
    };
