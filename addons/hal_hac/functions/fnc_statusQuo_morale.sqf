#include "..\script_component.hpp"
// Originally from nr6_hal/HAC_fnc2.sqf:322-408 (RYD_StatusQuo, block S5)

/**
 * @description Loss tracking and weighted morale delta computation. Calculates per-cycle
 *              losses, updates weighted loss array, applies morale deltas based on
 *              friendly count vs enemy knowledge and loss percentage.
 * @param {Group} _HQ The HQ group
 * @param {Number} _cInitial Friendly unit count at start of this cycle
 * @param {Number} _CCurrent Current friendly unit count
 * @param {Number} _CLast Friendly unit count at start of previous cycle
 * @param {Array} _knownE Known enemy units array
 * @return {Number} Updated morale value (clamped to [-50, 0])
 */
params ["_HQ", "_cInitial", "_CCurrent", "_CLast", "_knownE"];

private _lossFinal = _cInitial - _CCurrent;

if (_lossFinal < 0) then
    {
    _lossFinal = 0;
    _cInitial = _CCurrent;
    _HQ setVariable ["RydHQ_CInitial",_CCurrent];
    };

private _morale = _HQ getVariable ["RydHQ_Morale",0];

if not (_HQ getVariable ["RydHQ_Init",true]) then
    {
    private _lossP = _lossFinal/_cInitial;

    _HQ setVariable ["RydHQ_LTotal",_lossP];

    private _lostU = _CLast - _CCurrent;

    if not (_lostU == 0) then
        {
        private _lossArr = _HQ getVariable ["RydHQ_LossArr",[]];
        _lossArr pushBack [_lostU,time];

        if ((count _lossArr) > 200) then
            {
            _lossArr set [0,0];
            _lossArr = _lossArr - [0];
            };

        _HQ setVariable ["RydHQ_LossArr",_lossArr]
        };

    private _lossWeight = 0;

        {
        private _loss = _x select 0;
        private _when = _x select 1;
        private _age = ((time - _when)/30) max 6;

        _lossWeight = _lossWeight + ((_loss/(_age^1.15)) * (0.75 + (random 0.125) + (random 0.125) + (random 0.125) + (random 0.125)))
        }
    forEach (_HQ getVariable ["RydHQ_LossArr",[]]);

    private _balanceF = (((random 5) + (random 5))/((1 + _lossP)^2)) - ((random 1) + (random 1)) - (((random 1.5) + (random 1.5)) * ((count _knownE)/_CCurrent));

    _morale = _morale + ((_balanceF - _lossWeight)/(_HQ getVariable ["RydHQ_MoraleConst",1]));

    if (_lossP > (0.4 + (random 0.2))) then
        {
        private _diff = ((-_morale)/50) - _lossP;
        if (_diff > 0) then
            {
            _morale = _morale - ((random (_diff * 10))/(_HQ getVariable ["RydHQ_MoraleConst",1]))
            }
        };
    };

if (_morale < -50) then {_morale = -50};
if (_morale > 0) then {_morale = 0};

_HQ setVariable ["RydHQ_Morale",_morale];

_HQ setVariable ["RydHQ_TotalLossP",(round (((_lossFinal/_cInitial) * 100) * 10)/10)];

if (_HQ getVariable ["RydHQ_Debug",false]) then
    {
    private _signum = _HQ getVariable ["RydHQ_CodeSign","X"];
    private _mdbg = format ["Morale %5 (%2): %1 - losses: %3 percent (%4)",_morale,(_HQ getVariable ["RydHQ_Personality","OTHER"]),(round (((_lossFinal/_cInitial) * 100) * 10)/10),_lossFinal,_signum];
    diag_log _mdbg;
    (_HQ getVariable ["leaderHQ",(leader _HQ)]) globalChat _mdbg;

    private _cl = "<t color='#007f00'>%4 -> M: %1 - L: %2%3</t>";

    switch (side _HQ) do
        {
        case (west) : {_cl = "<t color='#0d81c4'>%4 -> M: %1 - L: %2%3</t>"};
        case (east) : {_cl = "<t color='#ff0000'>%4 -> M: %1 - L: %2%3</t>"};
        };

    private _dbgMon = parseText format [_cl,(round (_morale * 10))/10,(round (((_lossFinal/_cInitial) * 100) * 10)/10),"%",_signum];

    _HQ setVariable ["DbgMon",_dbgMon];
    };

_HQ setVariable ["RydHQ_Init",false];

_morale
