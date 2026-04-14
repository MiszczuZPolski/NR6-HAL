#include "..\script_component.hpp"
// Originally from nr6_hal/HAC_fnc2.sqf:1-43 (RYD_StatusQuo, block S1)

/**
 * @description Cycle-count gate, on-demand reset spawn, and HQ state variable reset.
 *              Resets Enemies/Friends/FValue/EValue each cycle. Handles timed and on-demand
 *              HQ reset via EFUNC(hac,hqReset).
 * @param {Group} _HQ The HQ group
 * @param {Number} _cycleC Current cycle counter
 * @param {Number} _lastReset Time of last HQ reset
 * @return {Number} Updated _lastReset value
 */
params ["_HQ", "_cycleC", "_lastReset"];

private _SCRname = "SQ";
private _orderFirst = _HQ getVariable QGVAR(orderfirst);

if (isNil ("_orderFirst")) then
    {
    _HQ setVariable [QGVAR(orderfirst),true];
    _HQ setVariable [QGVAR(flankReady),false];
    };

if (_cycleC > 1) then
    {
    if not (_HQ getVariable [QEGVAR(core,resetOnDemand),false]) then
        {
        if ((time - _lastReset) > (_HQ getVariable [QEGVAR(core,resetTime),600])) then
            {
            _lastReset = time;
            [_HQ] call EFUNC(hac,hqReset)
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
                ((_HQ getVariable [QEGVAR(core,resetNow),false]) or (_HQ getVariable [QEGVAR(common,kIA),false]))
                };

            _HQ setVariable [QEGVAR(core,resetNow),false];
            [_HQ] call EFUNC(hac,hqReset)
            };

        [[_HQ],_code] call EFUNC(common,spawn);
        };

    };

_HQ setVariable [QEGVAR(core,friends),[]];
_HQ setVariable [QGVAR(enemies),[]];
_HQ setVariable [QEGVAR(core,knEnemies),[]];
_HQ setVariable [QEGVAR(common,knEnemiesG),[]];
_HQ setVariable [QEGVAR(boss,fValue),0];
_HQ setVariable [QEGVAR(boss,eValue),0];

_lastReset
