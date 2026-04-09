#include "..\script_component.hpp"
// Originally from HAC_fnc2.sqf (RYD_ClusterC)

/**
 * @description Groups an array of points/objects into proximity-based clusters.
 *              Each cluster contains all points within the specified range of the cluster's seed point.
 * @param {Array} Array of points or objects to cluster
 * @param {Number} Distance range - points within this range of a seed are added to its cluster
 * @return {Array} Array of clusters, where each cluster is an array of points/objects
 */

params ["_points", "_range"];

private _clusters = [];
private _checked = [];

{
    if !(_x in _checked) then {
        _checked pushBack _x;
        private _point = _x;
        private _newCluster = [_point];

        {
            if ((_point distance _x) < _range) then {
                _checked pushBack _x;
                _newCluster pushBack _x;
            };
        } forEach _points;

        _clusters pushBack _newCluster;
    };
} forEach _points;

_clusters
