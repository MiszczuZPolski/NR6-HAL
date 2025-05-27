#include "..\script_component.hpp"

private ["_pos","_radius","_roads","_chosen","_dist","_distC"];
params ["pos","radius"];

private _chosen = objNull;

private _roads = _pos nearRoads _radius;

if ((count _roads) > 0) then {
    _chosen = _roads select 0;
    private _distC = (getPosATL _chosen) distance _pos;
    private _dist = 0;

    {
        _dist = (getPosATL _x) distance _pos;
        if (_dist <_distC) then {_chosen = _x; _distC = _dist;};
    } forEach _roads;
};

_chosen
