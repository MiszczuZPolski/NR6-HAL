#include "..\script_component.hpp"

/**
 * @description Sets up patrol routes between building positions for garrison groups
 * @param {Object} Group to set up patrol
 * @param {Array} Positions to patrol between
 * @param {Object} HQ object
 * @return {Nothing} None
 */
params ["_group", "_patrolPositions", "_HQ"];

// Exit if group is player-controlled
if (isPlayer (leader _group)) exitWith {};

// Clean waypoints
[_group] call EFUNC(common,deleteWaypoint);

// Make sure group is aware and ready to move
_group setBehaviour "AWARE";
_group setSpeedMode "LIMITED";
_group setCombatMode "YELLOW";

// Get a reasonable number of positions (no more than 6)
private _maxPositions = (count _patrolPositions) min 6;
private _finalPositions = [];

// Select random positions from available list
for "_i" from 1 to _maxPositions do {
    if (count _patrolPositions == 0) exitWith {};
    
    private _rnd = floor random count _patrolPositions;
    private _pos = _patrolPositions select _rnd;
    _finalPositions pushBack _pos;
    _patrolPositions deleteAt _rnd;
};

// Create move waypoints between the positions
private _wpCount = count _finalPositions;

{
    private _wp = _group addWaypoint [_x, 0];
    _wp setWaypointType "MOVE";
    _wp setWaypointCompletionRadius 3;
    
    // Add delays at waypoints
    if (_forEachIndex == 0) then {
        _wp setWaypointTimeout [10, 15, 20];
    } else {
        _wp setWaypointTimeout [20, 30, 40];
    };
    
    // Last waypoint cycles back to first
    if (_forEachIndex == (_wpCount - 1)) then {
        _wp setWaypointType "CYCLE";
    };
} forEach _finalPositions;

// Make first waypoint active 
_group setCurrentWaypoint [_group, 0]; 