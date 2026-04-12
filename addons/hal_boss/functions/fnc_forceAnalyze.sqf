#include "..\script_component.hpp"
// Originally from nr6_hal/Boss_fnc.sqf:513 (RYD_ForceAnalyze)
/**
 * @description Aggregates force composition across multiple HQ groups for strategic analysis
 * @param {Array} _HQarr Array of HQ groups to analyze
 * @return {Array} [frArr, enArr, HQs] - friendly reports, enemy reports, valid HQ list
 */
params ["_HQarr"];

private _frArr = [];
private _enArr = [];

private _frG = [];
private _enG = [];

private _HQs = [];

{
    private _HQ = _x;
    if !(isNil "_HQ") then
        {
        if !(isNull _HQ) then
            {
            private _arr =
                [
                (_HQ getVariable [QEGVAR(core,friends),[]]),
                (_HQ getVariable [QEGVAR(core,nCrewInfG),[]]),
                (_HQ getVariable [QGVAR(carsG),[]]),
                (_HQ getVariable [QGVAR(hArmorG),[]]) + (_HQ getVariable [QGVAR(lArmorG),[]]),
                (_HQ getVariable [QEGVAR(core,airG),[]]),
                (_HQ getVariable [QGVAR(nCAirG),[]]) + ((_HQ getVariable [QEGVAR(core,nCCargoG),[]]) - (_HQ getVariable [QGVAR(nCAirG),[]])) + ((_HQ getVariable [QEGVAR(core,supportG),[]]) - ((_HQ getVariable [QGVAR(nCAirG),[]]) + ((_HQ getVariable [QEGVAR(core,nCCargoG),[]]) - (_HQ getVariable [QGVAR(nCAirG),[]])))),
                (_HQ getVariable [QEGVAR(core,cCurrent),0]),
                (_HQ getVariable [QEGVAR(core,cInitial),0]),
                (_HQ getVariable [QGVAR(fValue),0]),
                (_HQ getVariable [QEGVAR(core,morale),0]),
                (_HQ getVariable [QEGVAR(common,knEnemiesG),[]]),
                (_HQ getVariable [QGVAR(enInfG),[]]),
                (_HQ getVariable [QGVAR(enCarsG),[]]),
                (_HQ getVariable [QGVAR(enHArmorG),[]]) + (_HQ getVariable [QGVAR(enLArmorG),[]]),
                (_HQ getVariable [QGVAR(enAirG),[]]),
                (_HQ getVariable [QGVAR(enNCAirG),[]]) + ((_HQ getVariable [QGVAR(enNCCargoG),[]]) - (_HQ getVariable [QGVAR(enNCAirG),[]])) + ((_HQ getVariable [QGVAR(enSupportG),[]]) - ((_HQ getVariable [QGVAR(enNCAirG),[]]) + ((_HQ getVariable [QGVAR(enNCCargoG),[]]) - (_HQ getVariable [QGVAR(enNCAirG),[]])))),
                (_HQ getVariable [QGVAR(eValue),0])
                ];

            _arr = (_arr + [_frArr,_enArr,_enG,_HQ]) call FUNC(forceCount);
            _frArr = _arr select 0;
            _enArr = _arr select 1;

            _HQs pushBack _x;
            _frG = _frG + (_HQ getVariable [QEGVAR(core,friends),[]]) - (_HQ getVariable [QEGVAR(core,exhausted),[]]);

            {
                if !(_x in _enG) then {_enG pushBack _x};
            } forEach (_HQ getVariable [QEGVAR(common,knEnemiesG),[]])
            }
        }
} forEach _HQarr;

_frArr pushBack _frG;
_enArr pushBack _enG;

[_frArr,_enArr,_HQs]
