#include "..\script_component.hpp"
// Originally from nr6_hal/Boss_fnc.sqf:2000 (RYD_BBSimpleD)
/**
 * @description Big Boss simplified display — draws HQ movement arrows and battle markers on the map
 * @param {Array} _HQs Array of HQ groups to track
 * @param {String} _BBSide Side identifier ("A" or "B")
 * @return {Nothing} Runs as persistent loop while any HQ alive
 */
params ["_HQs", "_BBSide"];

sleep 60;

while {(({!(isNull _x)} count _HQs) > 0)} do
    {
    if (({!(isNull _x)} count _HQs) == 0) exitWith {};
    if !(EGVAR(missionmodules,active)) exitWith {};

    private _enPos = [];
    private _frCenters = [];

    {
        private _HQ = _x;
        private _alive = true;

        switch (true) do
            {
            case (isNil "_HQ") : {_alive = false};
            case (isNull _HQ) : {_alive = false};
            case (({alive _x} count (units _HQ)) < 1) : {_alive = false};
            };

        if (_alive) then
            {
            private _ens = _x getVariable [QGVAR(knEnPos),[]];
            private _frs = _x getVariable [QEGVAR(core,friends),[]];

            _enPos = _enPos + _ens;

            private "_lPos";
            _lPos = _x getVariable "LastCenter";
            private _frCenter = getPosATL (vehicle (leader _x));
            if !(isNil "_lPos") then {_frCenter = _lPos};

            private _midX = 0;
            private _midY = 0;

            {
                _midX = _midX + ((getPosATL (vehicle (leader _x))) select 0);
                _midY = _midY + ((getPosATL (vehicle (leader _x))) select 1);
            } forEach _frs;

            if ((count _frs) > 0) then
                {
                if ([[_midX/(count _frs),_midY/(count _frs)]] call FUNC(isOnMap)) then
                    {
                    _frCenter = [_midX/(count _frs),_midY/(count _frs),0]
                    }
                else
                    {
                    if (isNil "_lPos") then
                        {
                        _frCenter = getPosATL (vehicle (leader _x));
                        }
                    }
                };

            _x setVariable ["LastCenter",_frCenter];

            _frCenters pushBack _frCenter;

            private _colorArr = "ColorBlue";
            if (_BBSide == "B") then {_colorArr = "ColorRed"};

            if !(isNil "_lPos") then
                {
                private _lng = _lPos distance _frCenter;

                if (_lng > 100) then
                    {
                    private _angle = [_lPos,_frCenter,5] call EFUNC(common,angleTowards);

                    private _arrow = _x getVariable ["ArrowMark",""];

                    if (_arrow == "") then
                        {
                        _arrow = [_frCenter,_x,"markArrow",_colorArr,"ICON","mil_arrow","","",[({(({alive _x} count (units _x)) > 0)} count _frs)/10,_lng/500],_angle] call EFUNC(common,mark);
                        _x setVariable ["ArrowMark",_arrow];
                        }
                    else
                        {
                        _arrow setMarkerPosLocal _frCenter;
                        _arrow setMarkerDirLocal _angle;
                        _arrow setMarkerSize [({(({alive _x} count (units _x)) > 0)} count _frs)/10,_lng/500]
                        }
                    }
                };

            private _HQPosMark = _x getVariable ["HQPosMark",""];
            if (_HQPosMark == "") then
                {
                _HQPosMark = [(getPosATL (vehicle (leader _x))),_x,"HQMark",_colorArr,"ICON","mil_box","Position of " + (str (leader _x)),"",[0.5,0.5]] call EFUNC(common,mark);
                _x setVariable ["HQPosMark",_HQPosMark]
                }
            else
                {
                _HQPosMark setMarkerPos (getPosATL (vehicle (leader _x)));
                }
            }
        else
            {
            deleteMarker ("HQMark" + (str _x))
            }
    } forEach _HQs;

    private _midX = 0;
    private _midY = 0;

    {
        _midX = _midX + (_x select 0);
        _midY = _midY + (_x select 1);
    } forEach _frCenters;

    private _mainCenter = [_midX/(count _HQs),_midY/(count _HQs),0];

    private _clusters = [];

    if ((count _enPos) > 0) then {_clusters = [_enPos] call FUNC(cluster)};

    private _centers = [];
    private _amounts = [];

    {
        private _amount = count _x;

        if (_amount > 2) then
            {
            _midX = 0;
            _midY = 0;

            {
                _midX = _midX + (_x select 0);
                _midY = _midY + (_x select 1);
            } forEach _x;

            _centers pushBack [_midX/(count _x),_midY/(count _x),0];
            _amounts pushBack _amount;
            }
    } forEach _clusters;

    private _battles = missionNamespace getVariable ["Battlemarks",[]];
    private _battle = "";

    {
        private _center = _x;
        if ([_center] call FUNC(isOnMap)) then
            {
            private _tooClose = false;

            {
                private _mPos = getMarkerPos _x;
                private _mSize = getMarkerSize _x;
                _mSize = ((_mSize select 0) + (_mSize select 1)) * 100;
                private _dstAct = _center distance _mPos;

                if (_mSize > _dstAct) exitWith {_tooClose = true;_battle = _x}
            } forEach _battles;

            private _colorBatt = "ColorBlue";
            if (_BBSide == "B") then {_colorBatt = "ColorRed"};
            private _sizeBatt = (_amounts select _foreachIndex)/6;
            if (_sizeBatt > 5) then {_sizeBatt = 5};

            private _angleBatt = [_mainCenter,_x,0] call EFUNC(common,angleTowards);

            if !(_tooClose) then
                {
                _battle = [_x,(random 10000),"markBattle",_colorBatt,"ICON","mil_ambush","","",[_sizeBatt,_sizeBatt],_angleBatt - 90] call EFUNC(common,mark);
                _battles pushBack _battle;
                missionNamespace setVariable ["Battlemarks",_battles];
                }
            else
                {
                private _oldSize = getMarkerSize _battle;
                _oldSize = _oldSize select 0;

                if (_sizeBatt > _oldSize) then
                    {
                    _battle setMarkerColorLocal _colorBatt;
                    _battle setMarkerSizeLocal [_sizeBatt,_sizeBatt];
                    _battle setMarkerDir (_angleBatt - 90)
                    }
                }
            }
    } forEach _centers;

    sleep 300
    }
