#include "..\script_component.hpp"
// Originally from nr6_hal/HAC_fnc2.sqf:1176-1288 (RYD_StatusQuo, block S8)

/**
 * @description Morale vs enemy-value decision gate. Chooses attack or defend stance
 *              and calls EFUNC(hac,hqOrders) or EFUNC(hac,hqOrdersDef) accordingly. Also handles
 *              SF attack dispatch against high-value targets.
 * @param {Group} _HQ The HQ group
 * @param {Array} _objs Remaining untaken objectives array
 * @param {Array} _SpecForG Special forces groups array
 * @param {Array} _knownEG Known enemy groups array
 * @param {Array} _EnHArmor Enemy heavy armor units array
 * @param {Array} _EnMArmor Enemy medium armor units array
 * @param {Array} _EnLArmor Enemy light armor units array
 * @param {Array} _EnArtG Enemy artillery groups array
 * @param {Array} _EnStaticG Enemy static weapons groups array
 * @param {Number} _FValue Friendly force value score
 * @param {Number} _EValue Enemy force value score
 * @param {Number} _morale Current morale value
 * @param {Boolean} _AAO All-attack-order doctrine flag
 * @param {Number} _cycleC Current cycle counter
 * @param {Number} _delay Computed dispatch delay in seconds
 * @return {nil}
 */
params ["_HQ", "_objs", "_SpecForG", "_knownEG", "_EnHArmor", "_EnMArmor", "_EnLArmor",
        "_EnArtG", "_EnStaticG", "_FValue", "_EValue", "_morale", "_AAO", "_cycleC", "_delay"];

private _gauss100 = (random 10) + (random 10) + (random 10) + (random 10) + (random 10) + (random 10) + (random 10) + (random 10) + (random 10) + (random 10);
private _obj = _HQ getVariable QEGVAR(core,obj);

private _moraleInfl = (_gauss100 * (_HQ getVariable [QEGVAR(core,offTend),1])) + (_HQ getVariable [QEGVAR(core,inertia),0]) + _morale;
private _enemyInfl = (_EValue/(_FValue max 1)) * 40;

if (((_moraleInfl > _enemyInfl) and not ((count _objs) < 1) and {not ((_HQ getVariable [QEGVAR(core,order),"ATTACK"]) in ["DEFEND"])}) or {(_HQ getVariable [QEGVAR(core,berserk),false])} or {(_moraleInfl > _enemyInfl) and (_HQ getVariable ["LastStance","At"] == "De") and ((((75)*(_HQ getVariable [QEGVAR(core,recklessness),0.5])*(count (_HQ getVariable [QEGVAR(common,knEnemiesG),[]]))) >= (random 100)) or ((_HQ getVariable [QEGVAR(core,attackAlways),false]) and (_HQ getVariable ["LastStance","At"] == "De") and ((count (_HQ getVariable [QEGVAR(common,knEnemiesG),[]])) > 0)))}) then
    {
    private _lastS = _HQ getVariable ["LastStance","At"];
    if ((_lastS == "De") or (_cycleC == 1)) then
        {
        if ((random 100) < EGVAR(core,aIChatDensity)) then {[(_HQ getVariable ["leaderHQ",(leader _HQ)]),GVAR(aIC_OffStance),"OffStance"] call EFUNC(common,AIChatter)};
        };

    _HQ setVariable ["LastStance","At"];
    _HQ setVariable [QEGVAR(core,inertia),30 * (0.5 + (_HQ getVariable [QEGVAR(core,consistency),0.5]))*(0.5 + (_HQ getVariable [QEGVAR(core,activity),0.5]))];
    [_HQ] call EFUNC(hac,hqOrders)
    }
else
    {
    private _lastS = _HQ getVariable ["LastStance","De"];
    if ((_lastS == "At") or (_cycleC == 1)) then
        {
        if ((random 100) < EGVAR(core,aIChatDensity)) then {[(_HQ getVariable ["leaderHQ",(leader _HQ)]),GVAR(aIC_DefStance),"DefStance"] call EFUNC(common,AIChatter)};
        };

    _HQ setVariable ["LastStance","De"];
    _HQ setVariable [QEGVAR(core,inertia), - (30 * (0.5 + (_HQ getVariable [QEGVAR(core,consistency),0.5])))/(0.5 + (_HQ getVariable [QEGVAR(core,activity),0.5]))];
    [_HQ] call EFUNC(hac,hqOrdersDef)
    };

// SF attack dispatch
if (((((_HQ getVariable [QEGVAR(core,circumspection),0.5]) + (_HQ getVariable [QEGVAR(core,fineness),0.5]))/2) + 0.1) > (random 1.2)) then
    {
    private _SFcount = {not (_x getVariable ["Busy" + (str _x),false]) and not (_x getVariable ["Unable",false]) and not (_x getVariable ["Resting" + (str _x),false])} count (_SpecForG - (_HQ getVariable [QEGVAR(core,sFBodyGuard),[]]));

    if (_SFcount > 0) then
        {
        private _isNight = [] call EFUNC(common,isNight);
        private _SFTgts = [];
        private _chance = 40 + (60 * (_HQ getVariable [QEGVAR(core,activity),0.5]));

            {
            private _HQtmp = group _x;
            if (_HQtmp in _knownEG) then
                {
                _SFTgts pushBack _HQtmp
                }
            }
        forEach (EGVAR(core,allLeaders) - [(_HQ getVariable ["leaderHQ",(leader _HQ)])]);

        if (_SFTgts isEqualTo []) then
            {
            _chance = _chance/2;
            _SFTgts = _EnArtG
            };

        if (_SFTgts isEqualTo []) then
            {
            _chance = _chance/3;
            _SFTgts = _EnStaticG
            };

        if (_isNight) then
            {
            _chance = _chance + 25
            };

        if ((count _SFTgts) > 0) then
            {
            _chance = _chance + (((2 * _SFcount) - (8/(0.75 + ((_HQ getVariable [QEGVAR(core,recklessness),0.5])/2)))) * 20);
            private _trgG = _SFTgts select (floor (random (count _SFTgts)));
            private _alreadyAttacked = {_x == _trgG} count (_HQ getVariable [QEGVAR(core,sFTargets),[]]);
            _chance = _chance/(1 + _alreadyAttacked);
            if (_chance < _SFcount) then
                {
                _chance = _SFcount
                }
            else
                {
                if (_chance > (85 + _SFcount)) then
                    {
                    _chance = 85 + _SFcount
                    }
                };

            if ((random 100) < _chance) then
                {
                private _SFAv = [];

                    {
                    private _isBusy = _x getVariable ["Busy" + (str _x),false];

                    if not (_isBusy) then
                        {
                        private _isResting = _x getVariable ["Resting" + (str _x),false];

                        if not (_isResting) then
                            {
                            if not (_x in (_HQ getVariable [QEGVAR(core,sFBodyGuard),[]])) then
                                {
                                _SFAv pushBack _x
                                }
                            }
                        }
                    }
                forEach _SpecForG;

                private _team = _SFAv select (floor (random (count _SFAv)));
                private _trg = vehicle (leader _trgG);
                if (not ((toLower (typeOf _trg)) in (_EnHArmor + _EnLArmor)) or ((random 100) > (90 - ((_HQ getVariable [QEGVAR(core,recklessness),0.5]) * 10)))) then
                    {
                    [[_team,_trg,_trgG,_HQ],FUNC(goSFAttack)] call EFUNC(common,spawn);
                    }
                }
            }
        }
    };
