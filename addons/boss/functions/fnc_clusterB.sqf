#include "..\script_component.hpp"
// Originally from nr6_hal/Boss_fnc.sqf:1811 (RYD_ClusterB)
/**
 * @description Groups points into pairs/clusters by nearest-neighbor assignment
 * @param {Array} _points Array of positions to cluster
 * @return {Array} Array of clusters, each cluster contains points grouped by proximity
 */
params ["_points"];

private _clusters = [];

{
    private _point = _x;
    private _sumC = (_point select 0) + (_point select 1);

    private _added = false;
    private _inside = false;

    {
        {
            private _sum = (_x select 0) + (_x select 1);
            if (_sum == _sumC) exitWith {_inside = true}
        } forEach _x;

        if (_inside) exitWith {}
    } forEach _clusters;

    if !(_inside) then
        {
        private _sumMin = _sumC;
        private _pointMin = _point;
        private _dstMin = 100000;

        {
            private _sum = (_x select 0) + (_x select 1);

            if !(_sumC == _sum) then
                {
                private _dstAct = _point distance _x;
                if (_dstAct < _dstMin) then
                    {
                    _dstMin = _dstAct;
                    _pointMin = _x;
                    _sumMin = _sum;
                    }
                }
        } forEach _points;

        {
            private _cluster = _x;

            {
                private _sumS = (_x select 0) + (_x select 1);
                if (_sumS == _sumMin) exitWith
                    {
                    _added = true;
                    _cluster pushBack _point
                    };
            } forEach _cluster;

            if (_added) exitWith {}
        } forEach _clusters;

        if !(_added) then
            {
            _clusters pushBack [_point,_pointMin];
            };
        }
} forEach _points;

_clusters
