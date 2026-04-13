#include "..\script_component.hpp"
// Originally from nr6_hal/HAC_fnc2.sqf:2871-3027 (HAL_FBFTLOOP)

/**
 * @description Friendly Battle-Field Tracking loop — maintains HQ marker groups
 *              for visual unit tracking on the map. Runs continuously while HQ is alive.
 * @param {Group} _HQ The HQ group to track
 * @return {nil}
 */
params ["_HQ"];

private _SidePLY = [];
private _IgnoredPLY = [];
private _RydMarks = [];
private _MarkGrps = [];
private _checkFriends = [];
private _OldMarkGrps = [];
private _mrk = "";
private _mrk2 = "";
private _OldRydMarks = [];
private _RydOrd = [];
private _OldRydOrd = [];
private _RydMarksOrd = [];
private _OldRydMarksOrd = [];

while {not (isNull _HQ)} do {

    _SidePLY = [];
    _IgnoredPLY = [];

    {
        if ((side _x) == (side _HQ)) then {_SidePLY pushBack _x};
        if ((group _x) in (_HQ getVariable [QEGVAR(core,friends),[]])) then  {_IgnoredPLY pushBack (group _x)};

    } forEach allPlayers;

    _OldMarkGrps = _HQ getVariable ["RydMarkGrpF",[]];
    _OldRydMarks = _HQ getVariable ["RydMarksF",[]];

    _OldRydOrd = _HQ getVariable ["RydOrdnances",[]];
    _OldRydMarksOrd = _HQ getVariable ["RydMarksOrd",[]];

    _MarkGrps = [];
    _RydMarks = [];

    _RydOrd = [];
    _RydMarksOrd = [];

    if (_HQ getVariable [QEGVAR(core,infoMarkers),false]) then {

        _MarkGrps = ((_HQ getVariable [QEGVAR(core,friends),[]]) - _IgnoredPLY);
        _RydOrd = _HQ getVariable [QGVAR(ordnanceDrops),[]];

            {
                private "_mrk";
                private "_mrk2";
                private "_mrktext";

                _mrk = _x getVariable "FirstMarkF";
                if (isNil "_mrk") then {_mrk = createMarker ["markF" + (str _x),(leader _x)];_x setVariable ["FirstMarkF",_mrk];};
                private _mrkcolor = format ["Color%1", side _x];
                private _mrktype = _x call HAL_fnc_getType;
                private _mrksize = [_x,units _x,_mrktype] call HAL_fnc_getSize;

                switch (side _x) do {

                    case west : {_mrktype = "b_" + _mrktype};
                    case east : {_mrktype = "o_" + _mrktype};
                    case resistance : {_mrktype = "n_" + _mrktype};
                    default {_mrktype = "Empty"};

                };

                _mrk setMarkerTypeLocal _mrktype;
                _mrk setMarkerColorLocal _mrkcolor;

                if not (_mrksize == -1) then {

                    _mrk2 = _x getVariable "FirstMarkF2";
                    if (isNil "_mrk2") then {_mrk2 = createMarker ["markF2" + (str _x),(leader _x)];_x setVariable ["FirstMarkF2",_mrk2];};
                    _mrk2 setMarkerTypeLocal ("group_" + (str _mrksize));

                };

                _mrktext = _x getVariable ["Ryd_MarkText",nil];

                if (isNil "_mrktext") then {

                    if ((EGVAR(core,infoMarkersID)) and ((side _x) == (side _HQ))) then {_mrk setMarkerText (groupId _x)};

                } else {

                    if ((side _x) == (side _HQ)) then {_mrk setMarkerText _mrktext};

                };

                _mrk setMarkerSizeLocal [0.75,0.75];
                if not (_mrksize == -1) then {

                    if ((side _x) == east) then {_mrk2 setMarkerSizeLocal [0.85,1.15]};
                    if ((side _x) == west) then {_mrk2 setMarkerSizeLocal [0.85,0.85]};
                    if ((side _x) == resistance) then {_mrk2 setMarkerSizeLocal [0.85,1.05]};
                    _mrk2 setMarkerPos (position (leader _x));
                    _RydMarks pushBack _mrk2;

                };

                _RydMarks pushBack _mrk;
                _mrk setMarkerPos (position (leader _x));

            } forEach _MarkGrps;

            {
                private "_mrk";
                private "_mrktype";

                _mrk = _x getVariable "FirstMarkOrd";
                if (isNil "_mrk") then {_mrk = createMarker ["markOrd" + (str _x),_x];_x setVariable ["FirstMarkOrd",_mrk];};
                private _mrkcolor = format ["Color%1", side (leader _HQ)];

                switch (side (leader _HQ)) do {

                    case west : {_mrktype = "b_" + "Ordnance"};
                    case east : {_mrktype = "o_" + "Ordnance"};
                    case resistance : {_mrktype = "n_" + "Ordnance"};
                    default {_mrktype = "Empty"};

                };

                _mrk setMarkerTypeLocal _mrktype;
                _mrk setMarkerColorLocal _mrkcolor;

                _mrk setMarkerSizeLocal [0.75,0.75];

                _RydMarksOrd pushBack _mrk;
                _mrk setMarkerPos (position _x);

            } forEach _RydOrd;

    };

    {
        _x setVariable ["FirstMarkF",nil];
        _x setVariable ["FirstMarkF2",nil];
    } forEach (_OldMarkGrps - (_MarkGrps - [grpNull]));

    {
        deleteMarker _x;
    } forEach (_OldRydMarks - _RydMarks);

    {
        _x setVariable ["FirstMarkOrd",nil];
    } forEach (_OldRydOrd - (_RydOrd - [objNull]));

    {
        deleteMarker _x;
    } forEach (_OldRydMarksOrd - _RydMarksOrd);

    _HQ setVariable ["RydMarkGrpF",_MarkGrps];
    _HQ setVariable ["RydMarksF",_RydMarks];

    _HQ setVariable ["RydOrdnances",_RydOrd];
    _HQ setVariable ["RydMarksOrd",_RydMarksOrd];

    sleep 5;

};
