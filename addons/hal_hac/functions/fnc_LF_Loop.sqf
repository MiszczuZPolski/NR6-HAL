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

while {RydxHQ_LFActive} do
    {
    if (not (isNil "BIS_liveFeed") and not (RydHQ_LF)) exitWith {RydxHQ_LFActive = false};

    switch (isNil "RydHQ_CamVOnly") do
        {
        case (true) : {_friends = (_HQ getVariable ["RydHQ_Friends",[]]) + (RydHQ_CamVIncluded - (_HQ getVariable ["RydHQ_Friends",[]]))};
        case (false) : {_friends = RydHQ_CamVOnly};
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
                    private _units = (units _x) - RydHQ_CamVExcluded;
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

    private _currentS = _HQ getVariable ["RydHQ_LFSource",objNull];

    if not (isNull _newS) then
        {
        _wasNull = false;
        if not (_newS == _currentS) then
            {
            if ((_maxD > 0) or ((random 100) > 75)) then
                {
                _HQ setVariable ["RydHQ_LFSource",_newS];
                _currentS = _HQ getVariable ["RydHQ_LFSource",objNull];

                private _dName = getText (configFile >> "CfgVehicles" >> (typeOf (vehicle _newS)) >> "displayName");

                if (RydHQ_LF) then
                    {
                    _leader groupChat "Terminating current video link...";
                    private _cSFin = _HQ getVariable ["RydHQ_LFSourceFin",_newS];
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
            case ((isNull (_HQ getVariable ["RydHQ_LFSourceFin",(vehicle _newS)])) and not (_wasNull)) : {_alive = false};
            case ((not (alive (_HQ getVariable ["RydHQ_LFSourceFin",(vehicle _newS)]))) and not (_wasNull)) : {_alive = false};
            case ((_newG getVariable ["RydHQ_MIA",false]) and not (_wasNull)) : {_alive = false};
            case (_HQ getVariable ["RydHQ_KIA",false]) : {_alive = false};
            };

        if (_alive) then
            {
            if not (_maxD > 0) then
                {
                if ((time - _stoper2) > 5) then
                    {
                    if ((_was0) or (_wasNull) or not (_maxd > 0)) then
                        {
                        if ((count (_HQ getVariable ["RydHQ_Friends",[]])) > 0) then
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

        if not (_alive) then {RydxHQ_LFActive = false};

        (not (RydxHQ_LFActive) or ((time - _stoper) > 30))
        };
    };

if not (isNil "BIS_liveFeed") then
    {
    _leader groupChat "Terminating current video link...";
    private _currentS = _HQ getVariable ["RydHQ_LFSourceFin",objNull];
    [_currentS,_leader] call EFUNC(common,LF);
    waitUntil {(isNil "BIS_liveFeed")};
    _leader groupChat "Video link terminated.";
    };
