#include "..\script_component.hpp"

params ["_array"];

private _biggest = grpNull;
private _biggestIndex = -1; // Default to -1 to indicate "not found" or "not applicable"

if ((count _array) > 0) then {
    _biggest = _array select 0;
    _biggestIndex = 0; // Index of the first element
    private _maxUnitCount = count (units _biggest);

    // Using _forEachIndex which is automatically provided by the forEachIndex command
    { // _x is the element (group), _forEachIndex is its index in _array
        private _currentUnitCount = count (units _x); 

        if (_currentUnitCount > _maxUnitCount) then {
            _biggest = _x;
            _maxUnitCount = _currentUnitCount;
            _biggestIndex = _forEachIndex; 
        };
    } forEach _array; // Note the change to forEachIndex
};

[_biggest, _biggestIndex]
