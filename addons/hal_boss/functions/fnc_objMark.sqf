#include "..\script_component.hpp"
// Originally from nr6_hal/Boss_fnc.sqf:1723 (RYD_ObjMark)
/**
 * @description Creates and maintains visual map markers for strategic objective areas
 * @param {Array} _strArea Array of strategic areas [pos, value, isTaken]
 * @param {String} _BBSide Side identifier ("A" or "B")
 * @return {Nothing} Runs as persistent loop while RydBB_Active and RydBB_Debug
 */
_SCRName = "ObjMark";

_strArea = _this select 0;
_BBSide = _this select 1;

_markers = [];

{
    _posStr = _x select 0;
    _valStr = _x select 1;
    _taken = _x select 2;
    _mark = "StrArea" + (str (random 1000));
    _color = "ColorYellow";
    _alpha = 0.1;
    if ((_taken) and (_BBSide == "A")) then {_color = "ColorBlue";_alpha = 0.5};
    if ((_taken) and (_BBSide == "B")) then {_color = "ColorRed";_alpha = 0.5};
    _mark = [_mark,_posStr,_color,"ICON",[_valStr/2,_valStr/2],0,_alpha,"mil_dot",(str _valStr)] call FUNC(marker);
    _markers pushBack _mark
} forEach _strArea;

while {((RydBB_Active) and {(RydBB_Debug)})} do
    {
    sleep 10;
    if !(RydBB_Active) exitWith {};

    {
        _obj = _x;
        _taken = _obj select 2;
        _color = "ColorYellow";
        _alpha = 0.1;

        if ((_taken) and (_BBSide == "A")) then {_color = "ColorBlue";_alpha = 0.5};
        if ((_taken) and (_BBSide == "B")) then {_color = "ColorRed";_alpha = 0.5};

        _mark = _markers select _foreachIndex;

        _mark setMarkerColor _color;
        _mark setMarkerAlpha _alpha;
    } forEach _strArea;
    };
