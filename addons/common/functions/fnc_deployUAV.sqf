#include "..\script_component.hpp"
// Originally from HAC_fnc2.sqf (RYD_deployUAV)

/**
 * @description Attempts to deploy a UAV from a backpack carried by a unit in the group.
 *              Sets up observation waypoints, connects operator to terminal, and cleans up
 *              when the mission ends or the UAV is destroyed/lands.
 * @param {Group} Group containing potential UAV operator with backpack
 * @param {Array} Position to observe
 * @param {Group} HQ group reference (for excluded groups and UAV altitude setting)
 * @return {Boolean} True if a UAV was successfully deployed, false otherwise
 */

params ["_gp", "_pos", "_HQ"];

private _uav = objNull;
private _hasUAV = false;

{
    private _unit = _x;
    private _backpack = unitBackpack _unit;

    if (!isNull _backpack && { isNull objectParent _unit }) then {
        private _backPackClass = typeOf _backpack;
        private _assClass = configFile >> "CfgVehicles" >> _backPackClass >> "assembleInfo";

        if (isClass _assClass) then {
            private _uavClass = _assClass >> "assembleTo";

            if (isText _uavClass) then {
                _uavClass = getText _uavClass;
                _hasUAV = true;

                { doStop _x; if (!isPlayer _x) then { _x setUnitPos "MIDDLE" } } forEach (units _gp);

                sleep (5 + random 5);

                if (isNull _unit || { !alive _unit }) exitWith {};

                removeBackpack _unit;

                private _myPos = getPosATL _unit;
                private _ang = [_myPos, _pos, 20] call FUNC(angleTowards);
                private _sPos = [_myPos, _ang, 2] call FUNC(positionTowards2D);
                _sPos set [2, 0];

                _uav = createVehicle [_uavClass, _sPos, [], 0, "NONE"];
                createVehicleCrew _uav;

                private _gpUAV = group _uav;

                { _x setSkill ["spotDistance", 1]; _x setSkill ["spotTime", 1] } forEach (units _gpUAV);

                private _excl = _HQ getVariable [QGVAR(excluded), []];
                _excl pushBack _gpUAV;
                _HQ setVariable [QGVAR(excluded), _excl];

                private _alt = _HQ getVariable [QGVAR(uAVAlt), 150];
                private _mPos = [_pos, 50] call FUNC(positionAround);
                _mPos set [2, _alt];
                _uav flyInHeight _alt;

                deleteWaypoint [_gpUAV, 0];

                private _wp = _gpUAV addWaypoint [_mPos, 0];
                _wp setWaypointType "SAD";
                _wp setWaypointBehaviour "CARELESS";
                _wp setWaypointCombatMode "RED";
                _wp setWaypointSpeed "FULL";
                _wp setWaypointStatements ["true", "deletewaypoint [(group this), 0]"];
                _wp setWaypointTimeout [20, 30, 40];

                _wp = _gpUAV addWaypoint [_sPos, 0];
                _wp setWaypointType "MOVE";
                _wp setWaypointBehaviour "CARELESS";
                _wp setWaypointCombatMode "BLUE";
                _wp setWaypointSpeed "FULL";
                _wp setWaypointStatements ["true", "{ (vehicle _x) land 'LAND' } forEach (units (group this)); deletewaypoint [(group this), 0]"];

                _unit connectTerminalToUAV _uav;
                _uav doWatch _mPos;

                private _timer = time;
                private _alive = true;

                waitUntil {
                    sleep 1;
                    private _nE = _unit findNearestEnemy _unit;

                    switch (true) do {
                        case (isNull _uav):                                                              { _alive = false };
                        case (!alive _uav):                                                              { _alive = false };
                        case (!alive (assignedDriver _uav)):                                             { _alive = false };
                        case ((fuel _uav) == 0):                                                         { _alive = false };
                        case (!canMove _uav):                                                            { _alive = false };
                        case (isNull _unit):                                                             { _alive = false };
                        case (!alive _unit):                                                             { _alive = false };
                        case (!isNull _nE && { (_nE distance _unit < 100) || (_nE knowsAbout _unit > 1) }): { _alive = false };
                    };

                    !_alive || { isTouchingGround _uav && { ((toLower landResult _uav) isEqualTo "found") || { ((toLower landResult _uav) isEqualTo "notfound") || (time - _timer > 900) } } }
                };

                { deleteVehicle _x } forEach (crew _uav);
                deleteVehicle _uav;
                deleteGroup _gpUAV;

                { _x doMove (position _x); if (!isPlayer _x) then { _x setUnitPos "AUTO" } } forEach (units _gp);

                if (!_alive || { time - _timer > 900 }) exitWith {};
                if ((_unit distance _sPos) > 100) exitWith {};

                _unit addBackpack _backPackClass;
            };
        };
    };

    if (_hasUAV) exitWith {};
} forEach (units _gp);

_hasUAV
