#include "..\script_component.hpp"
// Originally from nr6_hal/HAC_fnc2.sqf:1780-1930 (RYD_LF_Loop)
// Active caller: nr6_hal/LF/LF.sqf:6 (_this spawn RYD_LF_Loop)

/**
 * @description Live-feed camera loop — cycles through the most-threatened friendly unit
 *              as the live-feed camera source. Runs while RydxHQ_LFActive is true.
 * @param {Object} _leader HQ leader unit (_this select 0)
 * @param {Object} _src Unused (_this select 1, _this select 2)
 * @param {Group} _HQ The HQ group ((_this select 3) select 0)
 * @return {nil}
 */
params ["_leader", "", "", "_hqArr"];
private _HQ = _hqArr select 0;
private _maxD = -1;
private _friends = [];

while {EGVAR(common,lFActive)} do
    {
    if (not (isNil "BIS_liveFeed") and not (EGVAR(common,lF))) exitWith {EGVAR(common,lFActive) = false};

    switch (isNil QGVAR(camVOnly)) do
        {
        case (true) : {_friends = (_HQ getVariable [QEGVAR(core,friends),[]]) + (GVAR(camVIncluded) - (_HQ getVariable [QEGVAR(core,friends),[]]))};
        case (false) : {_friends = GVAR(camVOnly)};
        };

    private _newS = objNull;
    private _newG = grpNull;
    private _was0 = true;
    private _wasNull = true;

    if ((count _friends) > 0) then
        {
        _was0 = false;
        _maxD = -1;

            {
            private _alive = true;
            switch (true) do
                {
                case (isNil {_x}) : {_alive = false};
                case (isNull _x) : {_alive = false};
                case (({(alive _x)} count (units _x)) < 1) : {_alive = false};
                };

            if (_alive) then
                {
                private _dngr = _x getVariable ["NearE",0];
                if ((abs (speed (vehicle (leader _x)))) > 0.1) then {_dngr = _dngr + 0.0001};
                if (_x getVariable ["Busy" + (str _x),false]) then {_dngr = 2 * _dngr};
                if (_dngr > _maxD) then
                    {
                    _maxD = _dngr;
                    private _units = (units _x) - GVAR(camVExcluded);
                    if ((count _units) > 0) then
                        {
                        _newG = _x;
                        _newS = _units select (floor (random (count _units)));
                        }
                    }
                }

            }
        forEach _friends
        };

    private _currentS = _HQ getVariable [QGVAR(lFSource),objNull];

    if not (isNull _newS) then
        {
        _wasNull = false;
        if not (_newS == _currentS) then
            {
            if ((_maxD > 0) or ((random 100) > 75)) then
                {
                _HQ setVariable [QGVAR(lFSource),_newS];
                _currentS = _HQ getVariable [QGVAR(lFSource),objNull];

                private _dName = getText (configFile >> "CfgVehicles" >> (typeOf (vehicle _newS)) >> "displayName");

                if (EGVAR(common,lF)) then
                    {
                    _leader groupChat "Terminating current video link...";
                    private _cSFin = _HQ getVariable [QEGVAR(common,lFSourceFin),_newS];
                    [_cSFin,_leader] call EFUNC(common,LF);
                    waitUntil {(isNil "BIS_liveFeed")};
                    };

                _leader groupChat format ["Establishing new video link with %1...",_dName];
                [_newS,_leader] call EFUNC(common,LF);
                waitUntil {not (isNil "BIS_liveFeed")};
                _leader groupChat format ["Video link with %1 established.",_dName];
                }
            }
        };

    private _stoper = time;
    private _stoper2 = time;
    private _alive = true;
    private _mpl = 1;

    waitUntil
        {
        sleep 0.1;

        switch (true) do
            {
            case (isNull _HQ) : {_alive = false};
            case (({alive _x} count (units _HQ)) < 1) : {_alive = false};
            case (not (alive _leader)) : {_alive = false};
            case ((isNull (_HQ getVariable [QEGVAR(common,lFSourceFin),(vehicle _newS)])) and not (_wasNull)) : {_alive = false};
            case ((not (alive (_HQ getVariable [QEGVAR(common,lFSourceFin),(vehicle _newS)]))) and not (_wasNull)) : {_alive = false};
            case ((_newG getVariable [QEGVAR(common,mIA),false]) and not (_wasNull)) : {_alive = false};
            case (_HQ getVariable [QEGVAR(common,kIA),false]) : {_alive = false};
            };

        if (_alive) then
            {
            if not (_maxD > 0) then
                {
                if ((time - _stoper2) > 5) then
                    {
                    if ((_was0) or (_wasNull) or not (_maxd > 0)) then
                        {
                        if ((count (_HQ getVariable [QEGVAR(core,friends),[]])) > 0) then
                            {
                            _stoper = time - 31
                            }
                        };

                    _stoper2 = time
                    }
                }
            };

        private _dngr = _newG getVariable ["NearE",0];
        if ((abs (speed (vehicle (leader _newG)))) > 0.1) then {_dngr = _dngr + 0.0001};
        if (_newG getVariable ["Busy" + (str _newG),false]) then {_dngr = 2 * _dngr};

        if (_dngr > (((random 1) + _dngr) * _mpl)) then
            {
            _stoper = time - (10 * _mpl);
            _mpl = _mpl + 0.1
            };

        if not (_alive) then {EGVAR(common,lFActive) = false};

        (not (EGVAR(common,lFActive)) or ((time - _stoper) > 30))
        };
    };

if not (isNil "BIS_liveFeed") then
    {
    _leader groupChat "Terminating current video link...";
    private _currentS = _HQ getVariable [QEGVAR(common,lFSourceFin),objNull];
    [_currentS,_leader] call EFUNC(common,LF);
    waitUntil {(isNil "BIS_liveFeed")};
    _leader groupChat "Video link terminated.";
    };
