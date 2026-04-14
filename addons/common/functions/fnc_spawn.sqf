#include "..\script_component.hpp"
// Originally from HAC_fnc2.sqf (RYD_Spawn)

private ["_arguments","_script","_handle"];

_arguments = _this select 0;
_script = _this select 1;

_handle = _arguments spawn _script;

GVAR(handles) pushBack _handle;

    {
    if (isNil {_x}) then
        {
        GVAR(handles) set [_foreachIndex,0]
        }
    else
        {
        if (_x isNotEqualTo 0) then
            {
            if (scriptDone _x) then
                {
                GVAR(handles) set [_foreachIndex,0]
                }
            }
        }
    }
forEach GVAR(handles);

GVAR(handles) = GVAR(handles) - [0];
