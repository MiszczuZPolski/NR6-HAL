#include "..\script_component.hpp"

/**
 * @description Positions a single unit in a building for garrison duty
 * @param {Object} Unit to place
 * @param {Array} Position to move to
 * @param {Object} Building object
 * @param {Array} PosTaken info array
 * @param {Object} HQ object
 * @return {Nothing} None
 */
params ["_unit", "_position", "_building", "_posInfo", "_HQ"];

// Check if unit is player-controlled
if (isPlayer _unit) exitWith {};

// Get position index in taken array for later reference
private _posTaken = _posInfo select 0;
private _posIndex = _posInfo select 1;

// Disable unit AI temporarily
_unit disableAI "TARGET";
_unit disableAI "AUTOTARGET";
_unit disableAI "FSM";
_unit disableAI "MOVE";
_unit disableAI "COVER";

// Move unit to position
_unit setPos _position;

// Set stance and direction
_unit setUnitPos "UP";
doStop _unit;

// Have unit face in a reasonable direction (out from building center)
private _buildingPos = getPosATL _building;
private _dirToBuildingCenter = (_position getDir _buildingPos) + 180;
_unit setDir _dirToBuildingCenter;

// Re-enable AI, but keep unit from moving
sleep 5;
_unit enableAI "TARGET";
_unit enableAI "AUTOTARGET"; 
_unit enableAI "FSM";
_unit enableAI "COVER";

// Create doWatch threads to make unit more vigilant
[_unit, _building, _position] spawn {
    params ["_unit", "_building", "_position"];
    
    if (!alive _unit) exitWith {};
    
    // Get position of building to determine watch sectors
    private _buildingPos = getPosATL _building;
    private _dirToBuildingCenter = (_position getDir _buildingPos) + 180;
    
    while {alive _unit && {!isNull _unit} && {!isPlayer _unit}} do {
        // Check if unit has moved too far from position (>5m)
        if (_unit distance _position > 5) then {
            _unit setPos _position;
            doStop _unit;
        };
        
        // Make unit scan for enemies
        private _watchDir = _dirToBuildingCenter + (random 70) - 35;
        private _watchPos = _position getPos [50, _watchDir];
        _unit doWatch _watchPos;
        
        sleep (5 + random 15);
    };
}; 