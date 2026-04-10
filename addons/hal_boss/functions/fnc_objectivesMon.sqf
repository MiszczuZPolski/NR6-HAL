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
_SCRName = "ObjectivesMon";

private ["_area","_BBSide","_isTaken","_HQ","_AllV","_Civs","_AllV2","_Civs2","_NearAllies","_NearEnemies","_trg","_AllV0","_AllV20","_mChange","_HQs","_enArea","_enPos","_BBProg","_SideAllies","_SideEnemies"];

_area = _this select 0;
_BBSide = _this select 1;
_HQ = _this select 2;
_HQs = _this select 3;


while {(RydBB_Active)} do
    {
    sleep 15;//60
    if !(RydBB_Active) exitWith {};

    _SideAllies = [];
    _SideEnemies = [];

    {
        if (((side _HQ) getFriend _x) >= 0.6) then {_SideAllies pushBack _x} else {_SideEnemies pushBack _x};
    } forEach [west,east,resistance];

    {
        _isTaken = _x select 2;
        _trg = _x select 0;

        _trg = [_trg select 0,_trg select 1,0];

        if (_isTaken) then
            {
            _AllV = _trg nearEntities [["AllVehicles"],500];
            _Civs = _trg nearEntities [["Civilian"],500];
            _AllV2 = _trg nearEntities [["AllVehicles"],300];
            _Civs2 = _trg nearEntities [["Civilian"],300];

            _AllV = _AllV - _Civs;
            _AllV2 = _AllV2 - _Civs2;

            _AllV0 = _AllV;
            _AllV20 = _AllV2;

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
            _NearAllies = ({(side _x) in _SideAllies} count _AllV);
            //_NearEnemies = (leader _HQ) countenemy _AllV2;
            _NearEnemies = ({(side _x) in _SideEnemies} count _AllV2);

            if (_NearAllies < _NearEnemies) then
                {
                _x set [2,false];
                if (_BBSide == "A") then {RydBBa_Urgent = true} else {RydBBb_Urgent = true};

                _mChange = 10/(count _HQs);

                {
                    _morale = _x getVariable ["RydHQ_Morale",0];
                    _x setVariable ["RydHQ_Morale",_morale - _mChange]
                } forEach _HQs
                }
            }
        else
            {
            _AllV = _trg nearEntities [["AllVehicles"],300];
            _Civs = _trg nearEntities [["Civilian"],300];
            _AllV2 = _trg nearEntities [["AllVehicles"],500];
            _Civs2 = _trg nearEntities [["Civilian"],500];

            _AllV = _AllV - _Civs;
            _AllV2 = _AllV2 - _Civs2;

            _AllV0 = _AllV;
            _AllV20 = _AllV2;

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
            _NearAllies = ({(side _x) in _SideAllies} count _AllV);
            //_NearEnemies = (leader _HQ) countenemy _AllV2;
            _NearEnemies = ({(side _x) in _SideEnemies} count _AllV2);

            if ((_NearAllies >= (_HQ getVariable ["RydHQ_CaptLimit",10])) and (_NearEnemies <= (0 + (((_HQ getVariable ["RydHQ_Recklessness",0.5])/(0.5 + (_HQ getVariable ["RydHQ_Consistency",0.5])))*10)))) then
                {
                _x set [2,true];

                _enArea = missionNamespace getVariable ["B_SAreas",[]];
                if (_BBSide == "B") then {_enArea = missionNamespace getVariable ["A_SAreas",[]]};

                {
                    _enPos = _x select 0;
                    _enPos = [_enPos select 0,_enPos select 1,0];
                    if ((_enPos distance _trg) < 50) exitWith
                        {
                        _x set [2,false]
                        }
                } forEach _enArea;

                if (_BBSide == "A") then {RydBBb_Urgent = true} else {RydBBa_Urgent = true};

                _mChange = 20/(count _HQs);

                {
                    _morale = _x getVariable ["RydHQ_Morale",0];
                    _x setVariable ["RydHQ_Morale",_morale + _mChange]
                } forEach _HQs
                }
            }
    } forEach _area
    }
