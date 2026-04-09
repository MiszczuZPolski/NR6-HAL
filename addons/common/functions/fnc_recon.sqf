#include "..\script_component.hpp"
// Originally from HAC_fnc.sqf (RYD_Recon)

/**
 * @description Filters a list of groups to find suitable recon assets, then returns them
 *              sorted by distance from the target. Excludes garrisoned, exhausted, busy,
 *              flanking, cargo-only, and under-ammo groups.
 * @param {Array} Groups to evaluate
 * @param {String} Recon type - "NR" to skip recon-availability check
 * @param {Array} Availability arrays [garrA, recAv, flankAv, AOnlyA, exhA, nCargo, trg, NCVeh]
 * @param {Number} Maximum distance limit for sorting
 * @param {Boolean} True if recon asset may be airborne (skips ammo check)
 * @return {Array} Filtered and distance-sorted array of suitable groups
 */

params ["_gps", "_IR", "_rcArr", "_lmt", "_isRAir"];

_rcArr params ["_garrA", "_recAv", "_flankAv", "_AOnlyA", "_exhA", "_nCargo", "_trg", "_NCVeh"];

private _final = [];

{
    private _pass = true;

    if !((_x in _recAv) || (_IR == "NR")) then {
        _pass = false;
    } else {
        if (_x in _AOnlyA) then {
            _pass = false;
        } else {
            if (_x in _exhA) then {
                _pass = false;
            } else {
                if (_x in _garrA) then {
                    _pass = false;
                } else {
                    if ((_x in _nCargo) && {(count (units _x)) <= 1} && {((assignedVehicle (leader _x)) emptyPositions "Cargo") > 4}) then {
                        _pass = false;
                    } else {
                        private _ammo = [_x, _NCVeh] call FUNC(ammoCount);
                        if ((_ammo == 0) && !_isRAir) then {
                            _pass = false;
                        } else {
                            private _busy = _x getVariable ["Busy" + str _x, false];
                            private _unable = _x getVariable ["Unable", false];
                            if (_busy || _unable) then {
                                _pass = false;
                            } else {
                                if (_x in _flankAv) then { _pass = false };
                            };
                        };
                    };
                };
            };
        };
    };

    if (_pass) then { _final pushBack _x };
} forEach _gps;

if (_final isNotEqualTo []) then {
    _final = _final select { (vehicle (leader _x)) distance _trg < _lmt };
    _final = [_final, [], { (vehicle (leader _x)) distance _trg }, "ASCEND"] call BIS_fnc_sortBy;
};

_final
