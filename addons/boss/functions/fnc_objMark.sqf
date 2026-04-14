#include "..\script_component.hpp"
// Originally from nr6_hal/Boss_fnc.sqf:1723 (RYD_ObjMark)
/**
 * @description Creates and maintains visual map markers for strategic objective areas
 * @param {Array} _strArea Array of strategic areas [pos, value, isTaken]
 * @param {String} _BBSide Side identifier ("A" or "B")
 * @return {Nothing} Runs as persistent loop while RydBB_Active and RydBB_Debug
 */
params ["_strArea", "_BBSide"];

private _markers = [];

{
    private _posStr = _x select 0;
    private _valStr = _x select 1;
    private _taken = _x select 2;
    private _mark = "StrArea" + (str (random 1000));
    private _color = "ColorYellow";
    private _alpha = 0.1;
    if ((_taken) and (_BBSide == "A")) then {_color = "ColorBlue";_alpha = 0.5};
    if ((_taken) and (_BBSide == "B")) then {_color = "ColorRed";_alpha = 0.5};
    _mark = [_mark,_posStr,_color,"ICON",[_valStr/2,_valStr/2],0,_alpha,"mil_dot",(str _valStr)] call FUNC(marker);
    _markers pushBack _mark
} forEach _strArea;

while {((EGVAR(missionmodules,active)) and {(EGVAR(missionmodules,debug))})} do
    {
    sleep 10;
    if !(EGVAR(missionmodules,active)) exitWith {};

    {
        private _obj = _x;
        private _taken = _obj select 2;
        private _color = "ColorYellow";
        private _alpha = 0.1;

        if ((_taken) and (_BBSide == "A")) then {_color = "ColorBlue";_alpha = 0.5};
        if ((_taken) and (_BBSide == "B")) then {_color = "ColorRed";_alpha = 0.5};

        private _mark = _markers select _foreachIndex;

        _mark setMarkerColorLocal _color;
        _mark setMarkerAlpha _alpha;
    } forEach _strArea;
    };
