#include "..\script_component.hpp"
// Originally from nr6_hal/Boss_fnc.sqf:1769 (RYD_ClusterA)
/**
 * @description Groups points into clusters where each point is within range of the first point in the cluster
 * @param {Array} _points Array of positions to cluster
 * @param {Number} _range Maximum distance for cluster membership
 * @return {Array} Array of clusters, each cluster is an array of points
 */
params ["_points","_range"];

private _clusters = [];
private _checked = [];
private _newCluster = [];

//_points2 = +_points;

{
    private _sum = (_x select 0) + (_x select 1);
    if !(_sum in _checked) then
        {
        _checked pushBack _sum;
        private _point = _x;
        _newCluster = [_point];

        {
            private _sum = (_x select 0) + (_x select 1);
            if !(_sum in _checked) then
                {
                if ((_point distance _x) <= _range) then
                    {
                    _checked pushBack _sum;
                    _newCluster pushBack _x;
                    }
                }
        } forEach _points;

        _clusters pushBack _newCluster
        }
} forEach _points;

_clusters
