#include "..\script_component.hpp"
// Originally from nr6_hal/HAC_fnc.sqf:1276-1741 (RYD_Dispatcher)

/**
 * @description Dispatches a force from the HQ's available pool against a threat by scoring
 *              candidate force types against kind, then composing and invoking an attack order
 *              via HAL_GoAtt* value-dispatch.
 * @param {Array} _threat Threat array describing the detected enemy cluster
 * @param {String} _kind Threat kind (Recon/ATInf/Inf/Armor/Cars/Art/Air/Static/Naval)
 * @param {Group} _HQ The HQ group issuing the dispatch
 * @param {Number} _ATriskResign1 AT risk resign threshold, tier 1
 * @param {Number} _ATriskResign2 AT risk resign threshold, tier 2
 * @param {Number} _AAriskResign AA risk resign threshold
 * @param {Number} _AAthreat AA threat score
 * @param {Number} _ATthreat AT threat score
 * @param {Number} _armorATthreat Armor-vs-AT threat score
 * @param {Array} _Fpool Force pool - 20-element array of classified force sub-arrays
 * @return {nil}
 */
params ["_threat", "_kind", "_HQ", "_ATriskResign1", "_ATriskResign2", "_AAriskResign", "_AAthreat", "_ATthreat", "_armorATthreat", "_Fpool"];

private _SCRname = "Dispatcher";

private _SnipersG = _Fpool select 0;
private _NCrewInfG = _Fpool select 1;
private _air = _Fpool select 2;
private _LArmorG = _Fpool select 3;
private _HArmorG = _Fpool select 4;
private _cars = _Fpool select 5;
private _LArmorATG = _Fpool select 6;
private _ATInfG = _Fpool select 7;
private _AAInfG = _Fpool select 8;
private _reck = _Fpool select 9;
private _attackAv = _Fpool select 10;
private _garrison = _Fpool select 11;
private _garrR = _Fpool select 12;
private _flankAv = _Fpool select 13;
private _allAir = _Fpool select 14;
private _NCVeh = _Fpool select 15;
private _allNaval = _Fpool select 16;
private _airCAS = _Fpool select 17;
private _airCAP = _Fpool select 18;
private _BAir = _Fpool select 19;

private _pool = [];
private _force = [];
private _range = 0;
private _pattern = "";
private _SortedForce = [];
private _tPos = [];
private _limit = 0;
private _avF = [];
private _trg = objNull;
private _ix = 0;
private _infEnough = 3;
private _armEnough = 2;
private _airEnough = 1;
private _sum = 0;
private _handled = [];
private _chosen = grpNull;
private _ammo = 0;
private _topo = [];
private _sCity = 0;
private _sForest = 0;
private _sHills = 0;
private _sMeadow = 0;
private _sGr = 0;
private _sVal = 0;
private _mpl = 0;
private _Airmpl = 0;
private _attackAvL = [];
private _busy = false;
private _positive = false;
private _ATRR1 = 0;
private _ATRR2 = 0;
private _thRep = [];
private _isClose = false;
private _clstE = [];
private _enDst = 0;
private _thFct = 0;
private _chVP = [];
private _FTFinPool = [];
private _snpEnough = 2;
private _navEnough = 3;
private _cntInf = 0;
private _cntArm = 0;
private _cntAir = 0;
private _cntSnp = 0;
private _cntNav = 0;
private _Unable = false;
private _fr = locationNull;

{
    if not (_x in (_airCAS)) then {_airCAS pushBack _x;};
} forEach _BAir;

{
    if not (_x in (_airCAP + _airCAS)) then {_airCAS pushBack _x; _airCAP pushBack _x;};
} forEach _air;

switch (_kind) do
    {
    case ("Recon") :
        {
        _pool = [[_SnipersG,0.5,"SNP"],[_NCrewInfG,0.5,"INF"]]
        };

    case ("ATInf") :
        {
        _pool = [[_SnipersG,0.5,"SNP"],[_airCAS,2,"AIR"],[_NCrewInfG,0.5,"INF"]]
        };

    case ("Inf") :
        {
        _pool = [[_LArmorG,1,"ARM"],[_HArmorG,1,"ARM"],[_SnipersG,0.5,"SNP"],[_cars,1,"INF"],[_airCAS,2,"AIR"],[_NCrewInfG,0.5,"INF"]]
        };

    case ("Armor") :
        {
        _pool = [[_airCAS,2,"AIR"],[_HArmorG,1,"ARM"],[_LArmorATG,1,"ARM"],[_ATInfG,0.5,"INF"]]
        };

    case ("Cars") :
        {
        _pool = [[_LArmorG,1,"ARM"],[_cars,1,"INF"],[_HArmorG,1,"ARM"],[_airCAS,2,"AIR"],[_NCrewInfG,0.5,"INF"]]
        };

    case ("Art") :
        {
        _pool = [[_airCAS,2,"AIR"],[_LArmorG,1,"ARM"],[_cars,1,"INF"],[_HArmorG,1,"ARM"],[_NCrewInfG,0.5,"INF"]]
        };

    case ("Air") :
        {
        _pool = [[_airCAP,2,"AIRCAP"],[_AAInfG,0.5,"INF"]]
        };

    case ("Static") :
        {
        _pool = [[_airCAS,2,"AIR"],[_LArmorG,1,"ARM"],[_SnipersG,0.5,"SNP"],[_cars,1,"INF"],[_HArmorG,1,"ARM"],[_NCrewInfG,0.5,"INF"]]
        };

    case ("Naval") :
        {
        _pool = [[_allNaval,2,"NAVAL"]]
        };
    };

_limit = 3;
_infEnough = 3;
_armEnough = 2;
_airEnough = 1;
_snpEnough = 2;
_navEnough = 3;

_cntInf = {(_x in ((_NCrewInfG - _cars) + _cars))} count _attackAv;
_cntArm = {(_x in ((_HArmorG + _LArmorG) - (_NCrewInfG + _air)))} count _attackAv;
_cntAir = {(_x in (_air - (_NCrewInfG)))} count _attackAv;
_cntNav = {(_x in (_allNaval - (_NCrewInfG)))} count _attackAv;
_cntSnp = {((_x in (_SnipersG)) and ((count (units _x)) <= 2))} count _attackAv;

    {
    if (_x >= 0) then
        {
        switch (_foreachIndex) do
            {
            case (0) : {_infEnough = ceil (_cntInf * _x)};
            case (1) : {_armEnough = ceil (_cntArm * _x)};
            case (2) : {_airEnough = ceil (_cntAir * _x)};
            case (3) : {_snpEnough = ceil (_cntSnp * _x)};
            case (4) : {_navEnough = ceil (_cntNav * _x)};
            }
        }
    }
forEach GVAR(mARatio);

_sVal = 0;
_mpl = 1 + _reck;

    {
    _handled = _x getVariable "HAC_Attacked";

    _sum = 0;

    if (isNil "_handled") then
        {
        _sum = 6;
        _infEnough = 3;
        _armEnough = 2;
        _airEnough = 1;
        _snpEnough = 2;
        _navEnough = 3;

            {
            if (_x >= 0) then
                {
                switch (_foreachIndex) do
                    {
                    case (0) : {_infEnough = ceil (_cntInf * _x)};
                    case (1) : {_armEnough = ceil (_cntArm * _x)};
                    case (2) : {_airEnough = ceil (_cntAir * _x)};
                    case (3) : {_snpEnough = ceil (_cntSnp * _x)};
                    case (4) : {_navEnough = ceil (_cntNav * _x)};
                    }
                }
            }
        forEach GVAR(mARatio);
        }
    else
        {
        {_sum = _sum + _x} forEach _handled;
        _infEnough = _handled select 0;
        _armEnough = _handled select 1;
        _airEnough = _handled select 2;
        _snpEnough = _handled select 3;
        _navEnough = _handled select 4;
        };

    if not (alive (leader _x)) then {_sum = 0};
    if (isNull (leader _x)) then {_sum = 0};

    _fr = _HQ getVariable [QEGVAR(common,front),locationNull];
    if not (isNull _fr) then
        {
        if not ((getPosATL (vehicle (leader _x))) in _fr) then {_sum = 0}
        };

    if (_sum > 0) then
        {
        _trg = vehicle (leader _x);
        _tPos = getPosATL _trg;

        _topo = [_trg,5] call EFUNC(common,terraCognita);

        _sCity = 100 * (_topo select 0);
        _sForest = 100 * (_topo select 1);
        _sHills = 100 * (_topo select 2);
        _sMeadow = 100 * (_topo select 3);
        _sGr = _topo select 5;

            {
            _pattern = _x select 2;

            switch (true) do
                {
                case (_pattern in ["ARM"]) : {_limit = _armEnough};
                case (_pattern in ["AIR","AIRCAP"]) : {_limit = _airEnough};
                case (_pattern in ["SNP"]) : {_limit = _snpEnough};
                case (_pattern in ["NAVAL"]) : {_limit = _navEnough};
                default {_limit = _infEnough};
                };

            if (_limit >= 1) then
                {
                _force = _x select 0;
                _range = _x select 1;

                _FTFinPool = [];

                if ((count (_HQ getVariable [QEGVAR(core,firstToFight),[]])) > 0) then
                    {

                        {
                        if (_x in (_HQ getVariable [QEGVAR(core,firstToFight),[]])) then
                            {
                            _FTFinPool pushBack _x
                            }
                        }
                    forEach _force;
                    };

                _SortedForce = [_force,_tPos,10000*_range] call EFUNC(common,distOrd);

                _SortedForce = _FTFinPool + (_SortedForce - _FTFinPool);

                _avF = _SortedForce;

                _ix = 0;

                while {((_limit > 0) and ((count _avF) > 0) and (_ix < (count _SortedForce)))} do
                    {
                    _chosen = _SortedForce select _ix;
                    _chVP = getPosATL (vehicle (leader _chosen));
                    _ix = _ix + 1;

                    _positive = true;

                    _ammo = [_chosen,_NCVeh] call EFUNC(common,ammoCount);

                    switch (true) do
                        {
                        case (_pattern in ["SNP"]) : {_sVal = ((((2 * _sHills) + (2 * _sMeadow) + (_sGr/5)) * _mpl) - (((_sCity/2) + _sForest)/_mpl))};
                        case (_pattern in ["ARM"]) : {_sVal = ((((5 * _sMeadow) + (_sHills)) * _mpl) - (((_sCity/2) + (3 * _sForest) + _sGr)/_mpl))};
                        case (_pattern in ["AIR","AIRCAP"]) : {_sVal = ((((4 * _sMeadow) + (_sHills)) * _mpl) - (((_sCity) + (2 * _sForest) + (_SGr/5))/_mpl))};
                        case (_pattern in ["NAVAL"]) : {_sVal = 120};
                        default {_sVal = (0.5 + _sCity + (2 * _sForest) + (_sGr/10)) * (0.5 * _mpl) - ((0.05 + (2 * _sMeadow)) * (0.5/_mpl))};
                        };

                    if (_sVal < (5 + (10 * _reck))) then {_sVal = (5 + (10 * _reck))};

                    _busy = _chosen getVariable ("Busy" + (str _chosen));
                    if (isNil "_busy") then {_busy = false};
                    _Unable = _chosen getVariable "Unable";
                    if (isNil "_Unable") then {_Unable= false};

                    if (_busy) then
                        {
                        _positive = false
                        }
                    else
                        {
                        if (_Unable) then
                            {
                            _positive = false
                            }
                        else
                            {
                            if (_ammo == 0) then
                                {
                                _positive = false
                                }
                            else
                                {
                                if ((random 100) > _sVal) then
                                    {
                                    _positive = false
                                    }
                                else
                                    {
                                    if ((_chosen in _garrison) and (((vehicle (leader _chosen)) distance _tPos) > _garrR)) then
                                        {
                                        _positive = false
                                        }
                                    else
                                        {
                                        if not (_chosen in _attackAv) then
                                            {
                                            _positive = false
                                            }
                                        else
                                            {
                                            if (_chosen in _flankAv) then
                                                {
                                                _positive = false
                                                }
                                            else
                                                {
                                                if (_pattern in ["AIR","AIRCAP"]) then
                                                    {
                                                    _Airmpl = 0;
                                                    if ([] call EFUNC(common,isNight)) then {_Airmpl = 3};
                                                    if ((((random 100) * (1 + _reck)) < ((_Airmpl + overcast) * 30)) and not ((random 100) > 95)) then
                                                        {
                                                        _positive = false
                                                        }
                                                    }
                                                else
                                                    {
                                                    if (_pattern in ["SNP","INF"]) then
                                                        {
                                                        if (_pattern in ["SNP"]) then
                                                            {
                                                            if ((count (units _chosen)) > 2) then
                                                                {
                                                                _positive = false
                                                                }
                                                            };

                                                        if ((_chosen in _allAir) and ((count _AAthreat) > 0)) then
                                                            {
                                                            _thRep = [_chVP,_AAthreat,25000] call EFUNC(common,closeEnemyB);
                                                            _isClose = _thRep select 0;
                                                            _clstE = getPosATL (vehicle (leader (_thRep select 2)));
                                                            _enDst = [_chVP,_tPos,_clstE] call EFUNC(common,pointToSecondaryDistance);

                                                            if ((_isClose) and (_enDst > 0) and (_enDst < 1500)) then
                                                                {
                                                                _thFct = (2500/(sqrt _enDst))/(0.5 + (2 * _reck));//diag_log format ["Grp: %1 endst: %2 thFct: %3",typeOf (vehicle (leader _chosen)),_enDst,_thFct];
                                                                if (((random 100) < _thFct) and not (((random 100) > (90 - (_reck * 10))) and (_thFct >= (95 - (_reck * 10))))) then
                                                                    {
                                                                    _positive = false
                                                                    }
                                                                }
                                                            }
                                                        else
                                                            {
                                                            if ((_chosen in (_LArmorG + _HArmorG)) and ((count _ATthreat) > 0)) then
                                                                {
                                                                _thRep = [_chVP,_ATthreat,25000] call EFUNC(common,closeEnemyB);
                                                                _isClose = _thRep select 0;
                                                                _clstE = getPosATL (vehicle (leader (_thRep select 2)));
                                                                _enDst = [_chVP,_tPos,_clstE] call EFUNC(common,pointToSecondaryDistance);

                                                                if ((_isClose) and (_enDst > 0) and (_enDst < 1500)) then
                                                                    {
                                                                    _thFct = (2500/(sqrt _enDst))/(0.5 + (2 * _reck));//diag_log format ["Grp: %1 endst: %2 thFct: %3",typeOf (vehicle (leader _chosen)),_enDst,_thFct];
                                                                    if (((random 100) < _thFct) and not (((random 100) > (95 - (_reck * 10))) and (_thFct >= (95 - (_reck * 10))))) then
                                                                        {
                                                                        _positive = false
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        };

                    _ATRR1 = _ATriskResign1;
                    _ATRR2 = _ATriskResign2;
                    if (_chosen in _LArmorG) then
                        {
                        _ATRR1 = _ATRR1 + 10;
                        _ATRR2 = _ATRR2 + 10;
                        };

                    if (_positive) then
                        {
                        if (_pattern in ["ARM"]) then
                            {
                            if ((count _ATthreat) > 0) then
                                {
                                _thRep = [_chVP,_ATthreat,25000] call EFUNC(common,closeEnemyB);
                                _isClose = _thRep select 0;
                                _clstE = getPosATL (vehicle (leader (_thRep select 2)));
                                _enDst = [_chVP,_tPos,_clstE] call EFUNC(common,pointToSecondaryDistance);

                                if ((_isClose) and (_enDst > 0) and (_enDst < 1500)) then
                                    {
                                    _thFct = ((_ATRR1 * 40)/(sqrt _enDst))/(0.5 + (2 * _reck));//diag_log format ["Grp: %1 endst: %2 thFct: %3",typeOf (vehicle (leader _chosen)),_enDst,_thFct];
                                    if (((random 100) < _thFct) and not (((random 100) > (95 - (_reck * 10))) and (_thFct >= (95 - (_reck * 10))))) then
                                        {
                                        _positive = false
                                        }
                                    }
                                }
                            else
                                {
                                if ((count _armorATthreat) > 0) then
                                    {
                                    _thRep = [_chVP,_ATthreat,25000] call EFUNC(common,closeEnemyB);
                                    _isClose = _thRep select 0;
                                    _clstE = getPosATL (vehicle (leader (_thRep select 2)));
                                    _enDst = [_chVP,_tPos,_clstE] call EFUNC(common,pointToSecondaryDistance);

                                    if ((_isClose) and (_enDst > 0) and (_enDst < 1500)) then
                                        {
                                        _thFct = ((_ATRR2 * 40)/(sqrt _enDst))/(0.5 + (2 * _reck));//diag_log format ["Grp: %1 endst: %2 thFct: %3",typeOf (vehicle (leader _chosen)),_enDst,_thFct];
                                        if (((random 100) < _thFct) and not (((random 100) > (95 - (_reck * 10))) and (_thFct >= (95 - (_reck * 10))))) then
                                            {
                                            _positive = false
                                            }
                                        }
                                    }
                                }
                            };

                        if (_pattern in ["AIR","AIRCAP"]) then
                            {
                            if ((count _AAthreat) > 0) then
                                {
                                _thRep = [_chVP,_ATthreat,25000] call EFUNC(common,closeEnemyB);
                                _isClose = _thRep select 0;
                                _clstE = getPosATL (vehicle (leader (_thRep select 2)));
                                _enDst = [_chVP,_tPos,_clstE] call EFUNC(common,pointToSecondaryDistance);

                                if ((_isClose) and (_enDst > 0) and (_enDst < 1500)) then
                                    {
                                    _thFct = ((_AAriskResign * 40)/(sqrt _enDst))/(0.5 + (2 * _reck));//diag_log format ["Grp: %1 endst: %2 thFct: %3",typeOf (vehicle (leader _chosen)),_enDst,_thFct];
                                    if (((random 100) < _thFct) and not (((random 100) > (95 - (_reck * 10))) and (_thFct >= (95 - (_reck * 10))))) then
                                        {
                                        _positive = false
                                        }
                                    }
                                }
                            }
                        };


                    if (_positive) then
                        {
                        _chosen setVariable ["Busy" + (str _chosen),true];
                        _HQ setVariable [QGVAR(attackAv),(_HQ getVariable [QGVAR(attackAv),[]]) - [_chosen]];
                        //[_chosen,_trg,_HQ] spawn ([_pattern] call RYD_GoLaunch);

                        [[_chosen,_trg,_HQ],([_pattern] call EFUNC(common,goLaunch))] call EFUNC(common,spawn);
                        _limit = _limit - 1
                        };

                    _avF = _avF - [_chosen]
                    };

                switch (true) do
                    {
                    case (_pattern in ["ARM"]) : {_armEnough = _limit};
                    case (_pattern in ["AIR","AIRCAP"]) : {_airEnough = _limit};
                    case (_pattern in ["SNP"]) : {_snpEnough = _limit};
                    case (_pattern in ["NAVAL"]) : {_navEnough = _limit};
                    default {_infEnough = _limit};
                    }
                }

            }
        forEach _pool;

        _x setVariable ["HAC_Attacked",[_infEnough,_armEnough,_airEnough,_snpEnough,_navEnough]]
        }
    }
forEach _threat;
