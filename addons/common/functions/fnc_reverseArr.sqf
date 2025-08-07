#include "..\script_component.hpp"

// Originally from HAC_fnc.sqf (RYD_ReverseArr)
// Reverses an array and returns a new reversed array.

/*
	Description:
		Reverses the order of elements in an array and returns a new array.
		The original array is not modified.

	Parameter(s):
		_this select 0: ARRAY - The array to be reversed.
					   (Handled by `params` in the improved version)

	Returns:
		ARRAY - A new array with elements in reverse order.
				Returns an empty array if the input was not a valid array (due to `params` behavior).
*/

params [["_arrayToReverse", [], [[]]]]; // Ensures input is an array, defaults to [] if not or if no param

// Create a shallow copy of the input array
private _reversedArray = +_arrayToReverse;

// Reverse the copy in-place
reverse _reversedArray;

// Return the reversed copy
_reversedArray
