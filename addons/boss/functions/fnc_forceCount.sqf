#include "..\script_component.hpp"
// Originally from nr6_hal/Boss_fnc.sqf:418 (RYD_ForceCount)
/**
 * @description Calculates force composition report for a single HQ and its enemy knowledge
 * @param {Array} _friends Friendly groups array
 * @param {Array} _inf Infantry groups
 * @param {Array} _car Car/wheeled vehicle groups
 * @param {Array} _arm Armor groups
 * @param {Array} _air Air groups
 * @param {Array} _nc Non-combat groups
 * @param {Number} _current Current unit count
 * @param {Number} _initial Initial unit count
 * @param {Number} _value Force value
 * @param {Number} _morale Force morale
 * @param {Array} _enemies Known enemy groups
 * @param {Array} _einf Enemy infantry groups
 * @param {Array} _ecar Enemy car groups
 * @param {Array} _earm Enemy armor groups
 * @param {Array} _eair Enemy air groups
 * @param {Array} _enc Enemy non-combat groups
 * @param {Number} _evalue Enemy force value
 * @param {Array} _frArr Accumulator for friendly force reports
 * @param {Array} _enArr Accumulator for enemy force reports
 * @param {Array} _enG Engaged/excluded enemy groups
 * @param {Group} _gpHQ HQ group to store the force report on
 * @return {Array} [_frArr, _enArr] updated accumulators
 */
params ["_friends","_inf","_car","_arm","_air","_nc","_current","_initial","_value","_morale","_enemies","_einf","_ecar","_earm","_eair","_enc","_evalue","_frArr","_enArr","_enG","_gpHQ"];

private _eInfG = [];
private _eCarG = [];
private _eArmG = [];
private _eAirG = [];
private _eNCG = [];

private _eInfP = 0;
private _eCarP = 0;
private _eArmP = 0;
private _eAirP = 0;
private _eNCP = 0;

private _infP = 0;
private _carP = 0;
private _armP = 0;
private _airP = 0;
private _ncP = 0;

if ((count _enemies) > 0) then
    {
    {
        if (!(_x in _enG) and (_x in _einf)) then {_eInfG pushBack _x};
        if (!(_x in _enG) and (_x in _ecar)) then {_eCarG pushBack _x};
        if (!(_x in _enG) and (_x in _earm)) then {_eArmG pushBack _x};
        if (!(_x in _enG) and (_x in _eair)) then {_eAirG pushBack _x};
        if (!(_x in _enG) and (_x in _enc)) then {_eNCG pushBack _x};
    } forEach _enemies;

    private _eAllP = {!(_x in _enG)} count _enemies;

    if (_eAllP > 0) then
        {
        _eInfP = (count _eInf)/_eAllP;
        _eCarP = (count _eCar)/_eAllP;
        _eArmP = (count _eArm)/_eAllP;
        _eAirP = (count _eAir)/_eAllP;
        _eNCP = (count _eNC)/_eAllP
        }
    };

private _allP = count _friends;

if (_allP > 0) then
    {
    _infP = (count _inf)/_allP;
    _carP = (count _car)/_allP;
    _armP = (count _arm)/_allP;
    _airP = (count _air)/_allP;
    _ncP = (count _nc)/_allP
    };

private _frRep = [_allP,_current,_current - _initial,_value,_morale,[_infP,_carP,_armP,_airP,_ncP]];//liczba grup-liczba jednostek-straty-wartosc-morale-rozklad
private _enRep = [count _enemies,_evalue,[_eInfP,_eCarP,_eArmP,_eAirP,_eNCP]];//liczba grup-wartosc-rozklad

_gpHQ setVariable ["ForceRep",[_frRep,_enRep]];

_frArr pushBack _frRep;
_enArr pushBack _enRep;

[_frArr,_enArr]
