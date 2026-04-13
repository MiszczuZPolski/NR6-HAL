#include "..\script_component.hpp"
// Originally from nr6_hal/Boss_fnc.sqf:1887 (RYD_Cluster)
/**
 * @description Two-pass clustering: first nearest-neighbor pairs (ClusterB), then proximity merge (ClusterA) of cluster centers
 * @param {Array} _points Array of positions to cluster
 * @return {Array} Final merged clusters of points
 */
params ["_points"];

private _clusters = [_points] call FUNC(clusterB);

private _centers = [];

{
    private _cluster = _x;

    private _midX = 0;
    private _midY = 0;

    {
        _midX = _midX + (_x select 0);
        _midY = _midY + (_x select 1);
    } forEach _cluster;

    private _center = [_midX/(count _cluster),_midY/(count _cluster),0];
    _centers pushBack _center;
} forEach _clusters;

_clusters pushBack _centers;

private _clustersC = [_centers,500] call FUNC(clusterA);

private _newClusters = [];

{
    private _newCluster = [];
    private _clusterNearby = [];

    {
        private _centerC = _x;

        {
            if (((_centers select _foreachIndex) select 0) == (_centerC select 0)) then {_clusterNearby pushBack (_clusters select _foreachIndex)}
        } forEach _clusters
    } forEach _x;

    {
        {
            _newCluster pushBack _x
        } forEach _x
    } forEach _clusterNearby;

    _newClusters pushBack _newCluster
} forEach _clustersC;

_clusters = _newClusters;

_clusters
