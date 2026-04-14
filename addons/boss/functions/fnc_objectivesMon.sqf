#include "..\script_component.hpp"
// Originally from nr6_hal/Boss_fnc.sqf:1578 (RYD_ObjectivesMon)
/**
 * @description Monitors strategic objective areas, tracking capture status and updating morale
 * @param {Array} _area Array of strategic areas [pos, value, isTaken]
 * @param {String} _BBSide Side identifier ("A" or "B")
 * @param {Group} _HQ The HQ commander group
 * @param {Array} _HQs All HQ groups for morale update propagation
 * @return {Nothing} Runs as persistent loop while RydBB_Active
 */
params ["_area", "_BBSide", "_HQ", "_HQs"];

while {(EGVAR(missionmodules,active))} do
    {
    sleep 15;//60
    if !(EGVAR(missionmodules,active)) exitWith {};

    private _SideAllies = [];
    private _SideEnemies = [];

    {
        if (((side _HQ) getFriend _x) >= 0.6) then {_SideAllies pushBack _x} else {_SideEnemies pushBack _x};
    } forEach [west,east,resistance];

    {
        private _isTaken = _x select 2;
        private _trg = _x select 0;

        _trg = [_trg select 0,_trg select 1,0];

        if (_isTaken) then
            {
            private _AllV = _trg nearEntities [["AllVehicles"],500];
            private _Civs = _trg nearEntities [["Civilian"],500];
            private _AllV2 = _trg nearEntities [["AllVehicles"],300];
            private _Civs2 = _trg nearEntities [["Civilian"],300];

            _AllV = _AllV - _Civs;
            _AllV2 = _AllV2 - _Civs2;

            private _AllV0 = _AllV;
            private _AllV20 = _AllV2;

            {
                if !(_x isKindOf "Man") then
                    {
                    if ((crew _x) isEqualTo []) then {_AllV = _AllV - [_x]}
                    }
            } forEach _AllV0;

            {
                if !(_x isKindOf "Man") then
                    {
                    if ((crew _x) isEqualTo []) then {_AllV2 = _AllV2 - [_x]}
                    }
            } forEach _AllV20;

            //_NearAllies = (leader _HQ) countfriendly _AllV;
            private _NearAllies = ({(side _x) in _SideAllies} count _AllV);
            //_NearEnemies = (leader _HQ) countenemy _AllV2;
            private _NearEnemies = ({(side _x) in _SideEnemies} count _AllV2);

            if (_NearAllies < _NearEnemies) then
                {
                _x set [2,false];
                if (_BBSide == "A") then {RydBBa_Urgent = true} else {RydBBb_Urgent = true};

                private _mChange = 10/(count _HQs);

                {
                    private _morale = _x getVariable [QEGVAR(core,morale),0];
                    _x setVariable [QEGVAR(core,morale),_morale - _mChange]
                } forEach _HQs
                }
            }
        else
            {
            private _AllV = _trg nearEntities [["AllVehicles"],300];
            private _Civs = _trg nearEntities [["Civilian"],300];
            private _AllV2 = _trg nearEntities [["AllVehicles"],500];
            private _Civs2 = _trg nearEntities [["Civilian"],500];

            _AllV = _AllV - _Civs;
            _AllV2 = _AllV2 - _Civs2;

            private _AllV0 = _AllV;
            private _AllV20 = _AllV2;

            {
                if !(_x isKindOf "Man") then
                    {
                    if ((crew _x) isEqualTo []) then {_AllV = _AllV - [_x]}
                    }
            } forEach _AllV0;

            {
                if !(_x isKindOf "Man") then
                    {
                    if ((crew _x) isEqualTo []) then {_AllV2 = _AllV2 - [_x]}
                    }
            } forEach _AllV20;

            //_NearAllies = (leader _HQ) countfriendly _AllV;
            private _NearAllies = ({(side _x) in _SideAllies} count _AllV);
            //_NearEnemies = (leader _HQ) countenemy _AllV2;
            private _NearEnemies = ({(side _x) in _SideEnemies} count _AllV2);

            if ((_NearAllies >= (_HQ getVariable [QEGVAR(core,captLimit),10])) and (_NearEnemies <= (0 + (((_HQ getVariable [QEGVAR(core,recklessness),0.5])/(0.5 + (_HQ getVariable [QEGVAR(core,consistency),0.5])))*10)))) then
                {
                _x set [2,true];

                private _enArea = missionNamespace getVariable ["B_SAreas",[]];
                if (_BBSide == "B") then {_enArea = missionNamespace getVariable ["A_SAreas",[]]};

                {
                    private _enPos = _x select 0;
                    _enPos = [_enPos select 0,_enPos select 1,0];
                    if ((_enPos distance _trg) < 50) exitWith
                        {
                        _x set [2,false]
                        }
                } forEach _enArea;

                if (_BBSide == "A") then {RydBBb_Urgent = true} else {RydBBa_Urgent = true};

                private _mChange = 20/(count _HQs);

                {
                    private _morale = _x getVariable [QEGVAR(core,morale),0];
                    _x setVariable [QEGVAR(core,morale),_morale + _mChange]
                } forEach _HQs
                }
            }
    } forEach _area
    }
