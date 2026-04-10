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
                (_HQ getVariable ["RydHQ_Friends",[]]),
                (_HQ getVariable ["RydHQ_NCrewInfG",[]]),
                (_HQ getVariable ["RydHQ_CarsG",[]]),
                (_HQ getVariable ["RydHQ_HArmorG",[]]) + (_HQ getVariable ["RydHQ_LArmorG",[]]),
                (_HQ getVariable ["RydHQ_AirG",[]]),
                (_HQ getVariable ["RydHQ_NCAirG",[]]) + ((_HQ getVariable ["RydHQ_NCCargoG",[]]) - (_HQ getVariable ["RydHQ_NCAirG",[]])) + ((_HQ getVariable ["RydHQ_SupportG",[]]) - ((_HQ getVariable ["RydHQ_NCAirG",[]]) + ((_HQ getVariable ["RydHQ_NCCargoG",[]]) - (_HQ getVariable ["RydHQ_NCAirG",[]])))),
                (_HQ getVariable ["RydHQ_CCurrent",0]),
                (_HQ getVariable ["RydHQ_CInitial",0]),
                (_HQ getVariable ["RydHQ_FValue",0]),
                (_HQ getVariable ["RydHQ_Morale",0]),
                (_HQ getVariable ["RydHQ_KnEnemiesG",[]]),
                (_HQ getVariable ["RydHQ_EnInfG",[]]),
                (_HQ getVariable ["RydHQ_EnCarsG",[]]),
                (_HQ getVariable ["RydHQ_EnHArmorG",[]]) + (_HQ getVariable ["RydHQ_EnLArmorG",[]]),
                (_HQ getVariable ["RydHQ_EnAirG",[]]),
                (_HQ getVariable ["RydHQ_EnNCAirG",[]]) + ((_HQ getVariable ["RydHQ_EnNCCargoG",[]]) - (_HQ getVariable ["RydHQ_EnNCAirG",[]])) + ((_HQ getVariable ["RydHQ_EnSupportG",[]]) - ((_HQ getVariable ["RydHQ_EnNCAirG",[]]) + ((_HQ getVariable ["RydHQ_EnNCCargoG",[]]) - (_HQ getVariable ["RydHQ_EnNCAirG",[]])))),
                (_HQ getVariable ["RydHQ_EValue",0])
                ];

            _arr = (_arr + [_frArr,_enArr,_enG,_HQ]) call FUNC(forceCount);
            _frArr = _arr select 0;
            _enArr = _arr select 1;

            _HQs pushBack _x;
            _frG = _frG + (_HQ getVariable ["RydHQ_Friends",[]]) - (_HQ getVariable ["RydHQ_Exhausted",[]]);

            {
                if !(_x in _enG) then {_enG pushBack _x};
            } forEach (_HQ getVariable ["RydHQ_KnEnemiesG",[]])
            }
        }
} forEach _HQarr;

_frArr pushBack _frG;
_enArr pushBack _enG;

[_frArr,_enArr,_HQs]
