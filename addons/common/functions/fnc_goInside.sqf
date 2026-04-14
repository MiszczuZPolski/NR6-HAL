#include "..\script_component.hpp"

private ["_waypoint","_pos","_nearestHouses","_nearestHouse","_posAll","_posAct","_chosen","_enterable","_stat","_oldStat","_isRoof"];

params ["_waypoint"];

private _pos = waypointPosition _waypoint;

private _posAll = [];
private _chosen = -1;

private _nearestHouses = _pos nearObjects ["House", 100];

private _nearestHouse = objNull;

if (_nearestHouses isNotEqualTo []) then {
    _nearestHouse = _nearestHouses select (floor (random (count _nearestHouses)));
    _nearestHouses = _nearestHouses - [_nearestHouse];

    private _enterable = true;
    if (((_nearestHouse buildingPos 0) distance [0,0,0]) <= 1) then {_enterable = false};

    if !(_enterable) then {
        while {((count _nearestHouses) > 0)} do {
            _nearestHouse = _nearestHouses select (floor (random (count _nearestHouses)));
            _nearestHouses = _nearestHouses - [_nearestHouse];

            _enterable = true;
            if (((_nearestHouse buildingPos 0) distance [0,0,0]) <= 1) then {_enterable = false};
            if (_enterable) exitWith {}
        };
    };

    if (_enterable) then {
        private _posAct = [1,1,1];

        private _i = 0;
        while {((_posAct distance [0,0,0]) > 0)} do {
            _posAct = _nearestHouse buildingPos _i;
            _i = _i + 1;
            if ((_posAct distance [0,0,0]) > 0) then {
                _isRoof = [ATLToASL _posAct, 20] call FUNC(roofOver);

                if (_isRoof) then {
                    _posAll pushBack _posAct
                };
            };
        };
    };

    if (_posAll isNotEqualTo []) then {
        _chosen = _posAll select (floor (random (count _posAll)));

        _waypoint setWaypointPosition [_chosen, 0];
        private _stat = "this doMove " + (str _chosen);
        private _oldStat = (waypointStatements _waypoint) select 1;
        _stat = _stat + ";" + _oldStat;
        _waypoint setWaypointStatements ["true", _stat];
    };
};

[_nearestHouse, _chosen]
