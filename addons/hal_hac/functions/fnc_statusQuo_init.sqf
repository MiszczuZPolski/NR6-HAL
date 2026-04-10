#include "..\script_component.hpp"
// Originally from nr6_hal/HAC_fnc2.sqf:1-43 (RYD_StatusQuo, block S1)

/**
 * @description Cycle-count gate, on-demand reset spawn, and HQ state variable reset.
 *              Resets Enemies/Friends/FValue/EValue each cycle. Handles timed and on-demand
 *              HQ reset via HAL_HQReset.
 * @param {Group} _HQ The HQ group
 * @param {Number} _cycleC Current cycle counter
 * @param {Number} _lastReset Time of last HQ reset
 * @return {Number} Updated _lastReset value
 */
params ["_HQ", "_cycleC", "_lastReset"];

private _SCRname = "SQ";
private _orderFirst = _HQ getVariable "RydHQ_Orderfirst";

if (isNil ("_orderFirst")) then
    {
    _HQ setVariable ["RydHQ_Orderfirst",true];
    _HQ setVariable ["RydHQ_FlankReady",false];
    };

if (_cycleC > 1) then
    {
    if not (_HQ getVariable ["RydHQ_ResetOnDemand",false]) then
        {
        if ((time - _lastReset) > (_HQ getVariable ["RydHQ_ResetTime",600])) then
            {
            _lastReset = time;
            [_HQ] call HAL_HQReset
            }
        }
    else
        {
        private _code =
            {
            _HQ = _this select 0;

            waitUntil
                {
                sleep 1;
                ((_HQ getVariable ["RydHQ_ResetNow",false]) or (_HQ getVariable ["RydHQ_KIA",false]))
                };

            _HQ setVariable ["RydHQ_ResetNow",false];
            [_HQ] call HAL_HQReset
            };

        [[_HQ],_code] call EFUNC(common,spawn);
        };

    };

_HQ setVariable ["RydHQ_Friends",[]];
_HQ setVariable ["RydHQ_Enemies",[]];
_HQ setVariable ["RydHQ_KnEnemies",[]];
_HQ setVariable ["RydHQ_KnEnemiesG",[]];
_HQ setVariable ["RydHQ_FValue",0];
_HQ setVariable ["RydHQ_EValue",0];

_lastReset
