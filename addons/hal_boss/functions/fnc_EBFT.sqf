#include "..\script_component.hpp"
// Originally from nr6_hal/HAC_fnc2.sqf:3029-3119 (HAL_EBFT)

/**
 * @description Enemy Battle-Field Tracking — maintains enemy marker display on the map.
 *              Spawned once per cycle from inside fnc_statusQuo_scanFriends.sqf.
 * @param {Group} _HQ The HQ group
 * @return {nil}
 */
params ["_HQ"];

private _OldMarkGrps = _HQ getVariable ["RydMarkGrpE",[]];
private _OldRydMarks = _HQ getVariable ["RydMarksE",[]];

private _MarkGrps = [];
private _RydMarks = [];

if (_HQ getVariable [QEGVAR(core,infoMarkers),false]) then {

    _MarkGrps = (_HQ getVariable [QEGVAR(common,knEnemiesG),[]]);

        {
            private _mrk = _x getVariable "FirstMarkE";
            if (isNil "_mrk") then {_mrk = createMarker ["markE" + (str _x),(leader _x)];_x setVariable ["FirstMarkE",_mrk];};
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

            private "_mrk2";
            if not (_mrksize == -1) then {

                _mrk2 = _x getVariable "FirstMarkE2";
                if (isNil "_mrk2") then {_mrk2 = createMarker ["markE2" + (str _x),(leader _x)];_x setVariable ["FirstMarkE2",_mrk2];};
                _mrk2 setMarkerTypeLocal ("group_" + (str _mrksize));

            };

            private _mrktext = _x getVariable ["Ryd_MarkText",nil];

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

    };

    {
        _x setVariable ["FirstMarkE",nil];
        _x setVariable ["FirstMarkE2",nil];
    } forEach (_OldMarkGrps - (_MarkGrps - [grpNull]));

    {
        deleteMarker _x;
    } forEach (_OldRydMarks - _RydMarks);

    _HQ setVariable ["RydMarkGrpE",_MarkGrps];
    _HQ setVariable ["RydMarksE",_RydMarks];
