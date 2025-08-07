#include "..\script_component.hpp"

/**
 * @description Calculates flanking positions for AI groups based on enemy positions
 * @param {Object} HQ The headquarters object that has references to all groups and enemies
 * @return {Nothing} None
 */
params ["_HQ"];

// Cache frequently used variables
private _leader = vehicle (leader _HQ);
private _fineness = _HQ getVariable ["RydHQ_Fineness", 0.5];
private _obj = _HQ getVariable ["RydHQ_Obj", _leader];
private _knownEnemies = _HQ getVariable ["RydHQ_KnEnemies", []];
private _flankingAvailable = _HQ getVariable ["RydHQ_FlankAv", []];

// Check for Area of Operations objective modification
private _isAAO = _HQ getVariable ["RydHQ_ChosenAAO", false];
if (_isAAO) then {
    private _notTakenObjectives = (_HQ getVariable ["RydHQ_Objectives", []]) - (_HQ getVariable ["RydHQ_Taken", []]);
    if (count _notTakenObjectives < 1) then {
        _notTakenObjectives = _HQ getVariable ["RydHQ_Objectives", []];
    };
    
    if (count _notTakenObjectives > 0) then {
        _obj = _notTakenObjectives select 0;
    };
};

// Default position
private _defaultPos = getPosATL _obj;
if (_isAAO) then {
    _defaultPos = _HQ getVariable ["RydHQ_EyeOfBattle", _defaultPos];
};

// Early exit if no enemies or no flanking groups available
if (count _knownEnemies == 0 || {count _flankingAvailable == 0}) exitWith {
    _HQ setVariable ["RydHQ_FlankingDone", true];
    _HQ setVariable ["RydHQ_FlankAv", []];
};

// Extract X and Y positions of all known enemies for analysis
private _enemyPosX = [];
private _enemyPosY = [];

{
    private _enemyPos = getPosATL _x;
    _enemyPosX pushBack (_enemyPos select 0);
    _enemyPosY pushBack (_enemyPos select 1);
} forEach _knownEnemies;

// Find extremes on X axis
private _maxX = _defaultPos select 0;
private _minX = _defaultPos select 0;
private _maxXIndex = 0;
private _minXIndex = 0;

{
    if (_forEachIndex == 0) then {
        _minX = _x;
        _maxX = _x;
        _minXIndex = 0;
        _maxXIndex = 0;
    } else {
        if (_x < _minX) then {
            _minX = _x;
            _minXIndex = _forEachIndex;
        };
        if (_x > _maxX) then {
            _maxX = _x;
            _maxXIndex = _forEachIndex;
        };
    };
} forEach _enemyPosX;

// Find extremes on Y axis
private _maxY = _defaultPos select 1;
private _minY = _defaultPos select 1;
private _maxYIndex = 0;
private _minYIndex = 0;

{
    if (_forEachIndex == 0) then {
        _minY = _x;
        _maxY = _x;
        _minYIndex = 0;
        _maxYIndex = 0;
    } else {
        if (_x < _minY) then {
            _minY = _x;
            _minYIndex = _forEachIndex;
        };
        if (_x > _maxY) then {
            _maxY = _x;
            _maxYIndex = _forEachIndex;
        };
    };
} forEach _enemyPosY;

// Define the enemy units at the extremes
private _maxXEnemy = [_obj, _knownEnemies select _maxXIndex] select (count _knownEnemies > 0);
private _minXEnemy = [_obj, _knownEnemies select _minXIndex] select (count _knownEnemies > 0);
private _maxYEnemy = [_obj, _knownEnemies select _maxYIndex] select (count _knownEnemies > 0);
private _minYEnemy = [_obj, _knownEnemies select _minYIndex] select (count _knownEnemies > 0);

// Calculate midpoints
private _midpointX = (_minX + _maxX) / 2;
private _midpointY = (_minY + _maxY) / 2;

// Calculate angle for flanking direction
private _deltaX = _midpointX - (getPosATL _leader select 0);
private _deltaY = _midpointY - (getPosATL _leader select 1);
private _angle = _deltaX atan2 _deltaY;

if (_angle < 0) then {
    _angle = _angle + 360;
};

// Determine boundary enemies for flanking
private _boundaryEnemyA = [];
private _boundaryEnemyB = [];

if ((_angle <= 45) || (_angle > 135 && _angle <= 225) || (_angle > 315)) then {
    _boundaryEnemyA = getPosATL _minXEnemy;
    _boundaryEnemyB = getPosATL _maxXEnemy;
} else {
    _boundaryEnemyA = getPosATL _minYEnemy;
    _boundaryEnemyB = getPosATL _maxYEnemy;
};

// Determine flanking strategy based on fineness parameter
private _useMinFlank = false;
private _useMaxFlank = false;
private _useBothFlanks = false;
private _randomValue1 = random 100;
private _randomValue2 = random 100;
private _finenessModifier = 0.5 + _fineness;

switch (true) do {
    case (_randomValue1 >= (10/_finenessModifier) && _randomValue1 < (55/_finenessModifier) && _randomValue2 < 50): {
        _useMinFlank = true;
    };
    case (_randomValue1 >= (10/_finenessModifier) && _randomValue1 < (55/_finenessModifier) && _randomValue2 >= 50): {
        _useMaxFlank = true;
    };
    case (_randomValue1 >= (55/_finenessModifier)): {
        _useBothFlanks = true;
    };
};

// Filter out invalid flanking groups (e.g., those in garrison)
private _validFlankingGroups = [];
{
    if (!isNull _x && {!(_x in (_HQ getVariable ["RydHQ_Garrison", []]))}) then {
        _validFlankingGroups pushBack _x;
    };
} forEach _flankingAvailable;

// Execute flanking based on determined strategy
switch (true) do {
    case (_useMinFlank || _useMaxFlank): {
        {
            if (_useMinFlank) then {
                [[_x, _boundaryEnemyA, _midpointX, _midpointY, _angle, true, _HQ], FUNC(goFlank)] call CBA_fnc_directCall;
            } else {
                [[_x, _boundaryEnemyB, _midpointX, _midpointY, _angle, false, _HQ], FUNC(goFlank)] call CBA_fnc_directCall;
            };
        } forEach _validFlankingGroups;
    };
    
    case (_useBothFlanks): {
        {
            // Alternating groups between flanks
            if (_forEachIndex % 2 == 0) then {
                [[_x, _boundaryEnemyA, _midpointX, _midpointY, _angle, true, _HQ], FUNC(goFlank)] call CBA_fnc_directCall;
            } else {
                [[_x, _boundaryEnemyB, _midpointX, _midpointY, _angle, false, _HQ], FUNC(goFlank)] call CBA_fnc_directCall;
            };
        } forEach _validFlankingGroups;
    };
};

// Mark flanking as complete and clear available flanking groups
_HQ setVariable ["RydHQ_FlankingDone", true];
_HQ setVariable ["RydHQ_FlankAv", []]; 