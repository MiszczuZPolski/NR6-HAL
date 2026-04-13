#include "..\script_component.hpp"
// Originally from nr6_hal/HAC_fnc2.sqf:44-215 (RYD_StatusQuo, block S2)

/**
 * @description allGroups scan to populate enemies/friends/subOrd arrays;
 *              subordination-sync logic; radio channel management; known-enemy
 *              tracking for AI chatter. Returns updated state arrays.
 * @param {Group} _HQ The HQ group
 * @param {Array} _civF Array of civilian faction names
 * @param {Array} _excl Previously excluded groups
 * @return {Array} [_enemies, _friends, _excl, _knownE, _knownEG, _KnEnPos,
 *                  _cInitial, _CCurrent, _CLast, _checkFriends]
 */
params ["_HQ", "_civF", "_excl"];

private _SidePLY = [];
private _IgnoredPLY = [];
private _RydMarks = [];
private _MarkGrps = [];
private _checkFriends = [];

private _enemies = _HQ getVariable [QGVAR(enemies),[]];
private _friends = _HQ getVariable [QEGVAR(core,friends),[]];

if (EGVAR(core,aIChatDensity) > 0) then
    {
    private _varName1 = "HAC_AIChatRep";
    private _varName2 = "_West";

    switch ((side _HQ)) do
        {
        case (east) : {_varName2 = "_East"};
        case (resistance) : {_varName2 = "_Guer"};
        };

    missionNamespace setVariable [_varName1 + _varName2,0];

    _varName1 = "HAC_AIChatLT";

    missionNamespace setVariable [_varName1 + _varName2,[0,""]]
    };

_HQ setVariable [QGVAR(lastSub),_HQ getVariable [QEGVAR(core,subordinated),[]]];
_HQ setVariable [QEGVAR(core,subordinated),[]];

_enemies = _HQ getVariable [QGVAR(enemies),[]];
_friends = _HQ getVariable [QEGVAR(core,friends),[]];

    {
    private _isCaptive = _x getVariable ("isCaptive" + (str _x));
    if (isNil "_isCaptive") then {_isCaptive = false};

    if not (_isCaptive) then
        {
        _isCaptive = captive (leader _x)
        };

    private _isCiv = false;
    if ((faction (leader _x)) in _civF) then
        {
        _isCiv = true
        }
    else
        {
        if ((side _x) in [civilian]) then
            {
            _isCiv = true
            }
        };

    if not ((isNull ((_HQ getVariable ["leaderHQ",(leader _HQ)]))) and {not (isNull _x) and {(alive ((_HQ getVariable ["leaderHQ",(leader _HQ)]))) and {(alive (leader _x)) and {not (_isCaptive)}}}}) then
        {
        if (not ((_HQ getVariable [QEGVAR(core,frontA),false])) and {((side _x) getFriend (side _HQ) < 0.6) and {not (_isCiv)}}) then
            {
            if not (_x in _enemies) then
                {
                _enemies pushBack _x
                }
            };

        private _front = true;
        private _fr = _HQ getVariable [QEGVAR(common,front),locationNull];
        if not (isNull _fr) then
            {
            _front = ((getPosATL (vehicle (leader _x))) in _fr)
            };

        if ((_HQ getVariable [QEGVAR(core,frontA),false]) and {((side _x) getFriend (side _HQ) < 0.6) and {(_front) and {not (_isCiv)}}}) then
            {
            if not (_x in _enemies) then
                {
                _enemies pushBack _x;
                }
            };

        if ((_HQ getVariable [QEGVAR(core,subAll),true])) then
            {
            if not ((side _x) getFriend (side _HQ) < 0.6) then
                {
                if (not (_x in _friends) and {not (((leader _x) in (_HQ getVariable [QEGVAR(common,excluded),[]])) or {(_isCiv)})}) then
                    {
                    _friends pushBack _x
                    }
                };
            };
        }
    }
forEach allGroups;

_HQ setVariable [QGVAR(enemies),_enemies];

_excl = [];
    {
    _excl pushBack _x
    }
    forEach (_HQ getVariable [QEGVAR(common,excluded),[]]);

_HQ setVariable [QGVAR(excl),_excl];

private _subOrd = [];

if (_HQ getVariable [QEGVAR(core,subSynchro),false]) then
    {
        {
        if ((_x in (_HQ getVariable [QGVAR(lastSub),[]])) and {not ((leader _x) in (synchronizedObjects (_HQ getVariable ["leaderHQ",(leader _HQ)]))) and {(_HQ getVariable [QEGVAR(core,subSynchro),false])}}) then
            {
            _subOrd pushBack _x
            };

        if (not (_x in _subOrd) and {(({(_x in (synchronizedObjects (_HQ getVariable ["leaderHQ",(leader _HQ)])))} count (units _x)) > 0)}) then
            {
            _subOrd pushBack _x
            };
        }
    forEach allGroups;
    };

if (_HQ getVariable [QEGVAR(core,subNamed),false]) then
    {
    private _signum = _HQ getVariable [QEGVAR(core,codeSign),"X"];
    if (_signum in ["A","X"]) then {_signum = ""};

        {
        for [{_i = 1},{_i <= (_HQ getVariable [QEGVAR(core,nameLimit),100])},{_i = _i + 1}] do
            {
            if (not (_x in _subOrd) and {((str (leader _x)) == ("Ryd" + _signum + str (_i)))}) then
                {
                _subOrd pushBack _x
                };
            };
        }
    forEach allGroups;
    };

_HQ setVariable [QEGVAR(core,subordinated),_subOrd];

_friends = _friends + _subOrd + (_HQ getVariable [QEGVAR(core,included),[]]) - ((_HQ getVariable [QEGVAR(common,excluded),[]]) + _excl + [_HQ]);
_HQ setVariable [QGVAR(noWayD),allGroups - (_HQ getVariable [QEGVAR(core,lastFriends),[]])];

private _channel = _HQ getVariable [QGVAR(myChannel),-1];

if not (_channel < 0) then
    {
    _channel radioChannelRemove ((allUnits - (units _HQ)) + allDeadMen);
    private _toAdd = [];

        {
            {
            if (isPlayer _x) then
                {
                _toAdd pushBack _x
                }
            }
        forEach (units _x)
        }
    forEach _friends;

    _channel radioChannelAdd _toAdd
    };

_checkFriends = _friends;

{
    if ((({alive _x} count (units _x)) == 0) or (_x == grpNull)) then {_friends = _friends - [_x]};
} forEach _checkFriends;

_friends = [_friends] call EFUNC(common,randomOrd);

_HQ setVariable [QEGVAR(core,friends),_friends];

    {
    [_x] call CBA_fnc_clearWaypoints;
    }
forEach (((_HQ getVariable [QEGVAR(common,excluded),[]]) + _excl) - (_HQ getVariable [QGVAR(noWayD),[]]));

private _cInitial = 0;

if (_HQ getVariable [QEGVAR(core,init),true]) then
    {
        {
        _cInitial = _cInitial + (count (units _x));
        if (GVAR(camV)) then
            {

                {
                if (_x in ([player] + (switchableUnits - [player]))) then {[_x,_HQ] call EFUNC(common,liveFeed)}
                }
            forEach (units _x)
            }
        }
    forEach (_friends + [_HQ])
    };

_HQ setVariable [QEGVAR(core,cInitial),_cInitial];

_HQ setVariable [QEGVAR(core,cLast),(_HQ getVariable [QEGVAR(core,cCurrent),0])];
private _CLast = (_HQ getVariable [QEGVAR(core,cCurrent),0]);
private _CCurrent = 0;

    {
    _CCurrent = _CCurrent + (count (units _x))
    }
forEach (_friends + [_HQ]);

_HQ setVariable [QEGVAR(core,cCurrent),_CCurrent];

private _Ex = [];

if (_HQ getVariable [QEGVAR(core,exInfo),false]) then
    {
    _Ex = _excl + (_HQ getVariable [QEGVAR(common,excluded),[]])
    };

private _knownE = [];
private _knownEG = [];

    {
    for [{_a = 0},{_a < count (units _x)},{_a = _a + 1}] do
        {
        private _enemyU = vehicle ((units _x) select _a);

            {
            if (((_x knowsAbout _enemyU) >= 0.05) and not (_x getVariable ["Ryd_NoReports",false])) exitWith
                {
                if not (_enemyU in _knownE) then
                    {
                    _knownE pushBack _enemyU;
                    (vehicle _enemyU) setVariable [QEGVAR(common,myFO),(leader _x)];
                    };

                if not ((group _enemyU) in _knownEG) then
                    {
                    private _already = missionNamespace getVariable ["AlreadySpotted",[]];
                    _knownEG pushBack (group _enemyU);
                    if not ((group _enemyU) in _already) then
                        {
                        private _UL = (leader _x);if not (isPlayer _UL) then {if ((random 100) < EGVAR(core,aIChatDensity)) then {[_UL,GVAR(aIC_EnemySpot),"EnemySpot"] call EFUNC(common,AIChatter)}};
                        }
                    }
                }
            }
        forEach (_friends + [_HQ] + _Ex)
        }
    }
forEach _enemies;

private _alwaysKn = ((_HQ getVariable [QEGVAR(core,alwaysKnownU),[]]) - (_HQ getVariable [QEGVAR(core,alwaysUnKnownU),[]])) - _knownE;

_knownE = (_knownE + _alwaysKn) - (_HQ getVariable [QEGVAR(core,alwaysUnKnownU),[]]);

    {
    private _gp = group _x;
    if not (_gp in _knownEG) then {_knownEG pushBack _gp};
    }
forEach _alwaysKn;

_HQ setVariable [QEGVAR(core,knEnemies),_knownE];
_HQ setVariable [QEGVAR(common,knEnemiesG),_knownEG];
_HQ setVariable [QGVAR(ex),_Ex];

[_HQ] spawn EFUNC(boss,EBFT);

private _already = missionNamespace getVariable ["AlreadySpotted",[]];

    {
    if not (_x in _already) then
        {
        _already pushBack _x
        }
    }
forEach _knownEG;

missionNamespace setVariable ["AlreadySpotted",_already];

private _KnEnPos = _HQ getVariable [QEGVAR(boss,knEnPos),[]];

    {
    _KnEnPos pushBack (getPosATL (vehicle (leader _x)));
    if ((count _KnEnPos) >= 100) then {_KnEnPos = _KnEnPos - [_KnEnPos select 0]};
    }
forEach _knownEG;

_HQ setVariable [QEGVAR(boss,knEnPos),_KnEnPos];

[_enemies, _friends, _excl, _knownE, _knownEG, _KnEnPos, _cInitial, _CCurrent, _CLast, _checkFriends]
