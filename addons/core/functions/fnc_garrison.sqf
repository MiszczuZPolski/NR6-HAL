#include "..\script_component.hpp"

/**
 * @description Assigns AI groups to garrison and defend buildings in their area
 * @param {Object} HQ The headquarters object
 * @param {Array} excludedUnitTypes Array of unit types that should not be assigned to static weapons
 * @return {Nothing} None
 */
params ["_HQ", "_excludedUnitTypes"];

private _garrison = _HQ getVariable ["RydHQ_Garrison", []];
private _garrisonRange = _HQ getVariable ["RydHQ_GarrRange", 1];
private _isV2Mode = missionNamespace getVariable ["RydxHQ_GarrisonV2", false];
private _isDebugMode = _HQ getVariable ["RydHQ_Debug", false];
private _chatDensity = missionNamespace getVariable ["RydxHQ_AIChatDensity", 0];
private _disableVehicles = _HQ getVariable ["RydHQ_GarrVehAb", false];
private _codeSign = _HQ getVariable ["RydHQ_CodeSign", "X"];

// Clean up any ungarrisoned groups
{
    if (_x getVariable [("NOGarrisoned" + (str _x)), false]) then {
        _x setVariable [("Garrisoned" + (str _x)), false];
        _x setVariable [("NOGarrisoned" + (str _x)), false];
        _garrison set [_forEachIndex, objNull];
    };
} forEach _garrison;

_garrison = _garrison - [objNull];
_HQ setVariable ["RydHQ_Garrison", _garrison];

// Track position assignments to avoid duplicates
private _posTaken = missionNamespace getVariable ["PosTaken", []];
if (isNil "_posTaken") then {
    _posTaken = [];
    missionNamespace setVariable ["PosTaken", _posTaken];
};

// Process each group to be garrisoned
{
    private _group = _x;
    
    // Skip if already processed
    if (_group getVariable ["Garrisoned" + (str _group), false] || 
        _group getVariable ["NOGarrisoned" + (str _group), false] || 
        _group getVariable ["Unable", false] || 
        _group getVariable ["Busy" + (str _group), false]) then {
        continue;
    };
    
    // Get leader and position information
    private _leader = leader _group;
    private _leaderPosition = getPosATL (vehicle _leader);
    private _assignedVehicle = assignedVehicle _leader;
    
    // Clear existing waypoints
    [_group] call EFUNC(common,deleteWaypoint);
    
    // Mark group as garrisoned
    _group setVariable ["Garrisoned" + (str _group), true];
    
    // Send confirmation message to AI if appropriate
    if (!isPlayer _leader && {random 100 < _chatDensity}) then {
        [_leader, (missionNamespace getVariable ["RydxHQ_AIC_OrdConf", ["SentGenericConfirm"]]), "OrdConf"] call EFUNC(common,AIChatter);
    };
    
    // Create debug marker if needed
    if (_isDebugMode || isPlayer _leader) then {
        private _marker = [
            _leaderPosition, 
            _group, 
            "markGarrison", 
            "ColorBrown", 
            "ICON", 
            "mil_box", 
            "Garr " + _codeSign, 
            " - GARRISON", 
            [0.5, 0.5]
        ] call EFUNC(common,mark);
    };
    
    // Handle vehicle disembarkation if needed
    if (_disableVehicles && !isPlayer _leader) then {
        (units _group) orderGetIn false;
        (units _group) allowGetIn false;
        sleep 5;
    };
    
    // If group has vehicle and vehicles are allowed, set sentry waypoint and exit
    if (!isNull _assignedVehicle && !_disableVehicles) exitWith {
        private _formation = [formation _group, "DIAMOND"] select (!isPlayer _leader);
        [
            _group, 
            position _leader, 
            "SENTRY", 
            "AWARE", 
            "YELLOW", 
            "NORMAL", 
            ["true", "deletewaypoint [(group this), 0];"], 
            false, 
            0, 
            [0,0,0], 
            _formation
        ] call EFUNC(common,addWaypoint);
    };
    
    // Handle different garrison modes
    if (_isV2Mode) then {
        // Modern CBA garrison mode (V2)
        if (_group getVariable ["Busy" + (str _group), false]) then {
            _group setVariable ["Break", true];
            waitUntil {sleep 1; !(_group getVariable ["Break", false])};
        };
        
        // Add debug marker
        if (_isDebugMode) then {
            private _marker = [
                _leaderPosition, 
                _group, 
                "markGarrison", 
                "ColorBlack", 
                "ICON", 
                "mil_box", 
                "GARR " + (groupId _group) + " " + _codeSign, 
                " - GARRISON", 
                [0.5, 0.5]
            ] call EFUNC(common,mark);
        };
        
        // Add task for player-led groups
        private _task = [
            _leader, 
            ["Setup Garrison", "Setup a garrison and defend the area.", ""], 
            _leaderPosition, 
            "defend"
        ] call EFUNC(common,addTask);
        
        // Use CBA defend function
        [_group, _leaderPosition, 150, 1, 0.5, 0, false] remoteExecCall ["NR6_fnc_CBA_Defend", _leader];
    } 
    else {
        // Legacy garrison mode
        private _units = (units _group) - [_leader];
        
        if (!isPlayer _leader) then {
            // Find and assign static weapons
            private _staticWeapons = [];
            {
                if (_x emptyPositions "gunner" > 0) then {
                    _staticWeapons pushBack _x;
                };
            } forEach (_leaderPosition nearObjects ["StaticWeapon", 300 * _garrisonRange]);
            
            // Assign units to static weapons
            {
                if (count _units > 0) then {
                    private _unit = _units select ((count _units) - 1);
                    
                    if (random 1 > 0.1 && {!(toLower (typeOf _unit) in _excludedUnitTypes)}) then {
                        _unit assignAsGunner _x;
                        [_unit] orderGetIn true;
                        _units resize ((count _units) - 1);
                    };
                };
            } forEach _staticWeapons;
            
            // Find buildings and their positions
            private _buildings = _leaderPosition nearObjects ["House", 300 * _garrisonRange];
            private _allPositions = [];
            
            {
                private _building = _x;
                if (_building distance _leader <= 300 * _garrisonRange) then {
                    private _buildingIndex = 0;
                    private _buildingPos = _building buildingPos _buildingIndex;
                    
                    while {(_buildingPos distance [0,0,0]) > 0} do {
                        // Check if position is already taken
                        private _isTaken = false;
                        
                        {
                            if (typeName _x == typeName [] && {(_x select 0) + (_x select 1) == (_buildingPos select 0) + (_buildingPos select 1)}) exitWith {
                                _isTaken = true;
                            };
                        } forEach _posTaken;
                        
                        if (!_isTaken) then {
                            _allPositions pushBack [_buildingPos, _building];
                        };
                        
                        _buildingIndex = _buildingIndex + 1;
                        _buildingPos = _building buildingPos _buildingIndex;
                    };
                };
            } forEach _buildings;
            
            // Make a copy of all positions for patrol route generation
            private _allPositionsCopy = +_allPositions;
            
            // Assign units to building positions
            {
                if (count _allPositions > 0) then {
                    private _posIndex = floor (random (count _allPositions));
                    private _posInfo = _allPositions select _posIndex;
                    private _position = _posInfo select 0;
                    private _building = _posInfo select 1;
                    
                    // Skip if position is too far
                    if (_position distance _leaderPosition > 350 * _garrisonRange) then {
                        continue;
                    };
                    
                    // 80% chance to use position
                    if (random 100 > 20) then {
                        // Check if position is taken
                        private _isTaken = false;
                        private _posSum = (_position select 0) + (_position select 1);
                        
                        {
                            if (typeName _x == typeName [] && {(_x select 0) + (_x select 1) == _posSum}) exitWith {
                                _isTaken = true;
                            };
                        } forEach _posTaken;
                        
                        if (!_isTaken) then {
                            // Remove position from available list
                            _allPositions set [_posIndex, 0];
                            _allPositions = _allPositions - [0];
                            
                            // Add to taken positions
                            private _posIndex = count _posTaken;
                            _posTaken pushBack _position;
                            _posTaken = _posTaken - [0];
                            missionNamespace setVariable ["PosTaken", _posTaken];
                            
                            // Send unit to position
                            [[_x, _position, _building, [_posTaken, _posIndex], _HQ], FUNC(garrisonSingle)] call CBA_fnc_directCall;
                            _units = _units - [_x];
                        };
                    };
                };
            } forEach _units;
            
            // Generate patrol routes from remaining positions
            private _patrolPositions = [];
            {
                private _pos = _x select 0;
                if (typeName _pos == typeName []) then {
                    // Skip positions that are too high
                    if (_pos select 2 > 16) then {
                        continue;
                    };
                    
                    // Check distance from existing patrol positions
                    private _isGood = true;
                    {
                        if (_x distance _pos < 16) then {
                            _isGood = false;
                        };
                    } forEach _patrolPositions;
                    
                    // Add if good position
                    if (_isGood) then {
                        _patrolPositions pushBack _pos;
                    };
                };
            } forEach _allPositionsCopy;
            
            // Set up patrol or sentry based on available positions
            if (count _patrolPositions > 1) then {
                [[_group, _patrolPositions, _HQ], FUNC(garrisonPatrol)] call CBA_fnc_directCall;
            } else {
                private _formation = [formation _group, "DIAMOND"] select (!isPlayer _leader);
                [
                    _group, 
                    position _leader, 
                    "SENTRY", 
                    "AWARE", 
                    "YELLOW", 
                    "NORMAL", 
                    ["true", "deletewaypoint [(group this), 0];"], 
                    false, 
                    0, 
                    [0,0,0], 
                    _formation
                ] call EFUNC(common,addWaypoint);
            };
        };
    };
} forEach _garrison; 