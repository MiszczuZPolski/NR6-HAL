#include "..\script_component.hpp"
// Originally from nr6_hal/HAC_fnc2.sqf:849-1099 (RYD_StatusQuo, block S6)

/**
 * @description Panic/flee resolution, enemy knowledge reveal, cycle-1 personality roll
 *              (AAO, EBDoctrine), and arty prep. Returns updated AAO/EBT doctrine flags.
 * @param {Group} _HQ The HQ group
 * @param {Array} _friends Current friendly groups array
 * @param {Array} _knownE Known enemy units array
 * @param {Array} _knownEG Known enemy groups array
 * @param {Array} _SpecForG Special forces groups array
 * @param {Array} _ArtG Artillery groups array
 * @param {Number} _morale Current morale value
 * @param {Number} _cycleC Current cycle counter
 * @param {Number} _CCurrent Current friendly unit count
 * @return {Array} [_AAO, _EBT] doctrine flags
 */
params ["_HQ", "_friends", "_knownE", "_knownEG", "_SpecForG", "_ArtG", "_morale", "_cycleC", "_CCurrent"];

// Flee/panic calculation
if (_HQ getVariable [QEGVAR(core,flee),true]) then
    {
    private _AllCow = 0;
    private _AllPanic = 0;

        {
        private _cow = _x getVariable ("Cow" + (str _x));
        if (isNil ("_cow")) then {_cow = 0};

        _AllCow = _AllCow + _cow;

        private _panic = _x getVariable ("inPanic" + (str _x));
        if (isNil ("_panic")) then {_panic = false};

        if (_panic) then {_AllPanic = _AllPanic + 1};
        }
    forEach _friends;

    if (_AllPanic == 0) then {_AllPanic = 1};
    private _midCow = 0;
    if not ((count _friends) == 0) then {_midCow = _AllCow/(count _friends)};

        {
        private _cowF = ((- _morale)/(50 + (random 25))) + (random (2 * _midCow)) - _midCow;
        _cowF = _cowF * (_HQ getVariable [QEGVAR(core,muu),1]);
        if (_x in _SpecForG) then {_cowF = _cowF - 0.8};
        if (_cowF < 0) then {_cowF = 0};
        if (_cowF > 1) then {_cowF = 1};
        private _i = "";
        if (_cowF > 0.5) then
            {
            private _UL = leader _x;
            if not (isPlayer _UL) then
                {
                private _inDanger = _x getVariable ["NearE",0];
                if (isNil "_inDanger") then {_inDanger = 0};
                if (_inDanger > 0.05) then
                    {
                    if ((random 100) < EGVAR(core,aIChatDensity)) then {[_UL,GVAR(aIC_InFear),"InFear"] call EFUNC(common,AIChatter)}
                    }
                }
            };

        if (((random ((20 + (_morale/5))/_AllPanic)) < _cowF) and {((random 100) > (100/(_AllPanic + 1)))}) then
            {
            private _dngr = _x getVariable ["NearE",0];
            if (isNil "_dngr") then {_dngr = 0};
            if (_dngr < (0.3 - (random 0.15) - (random 0.15))) exitWith {};

            [_x] call CBA_fnc_clearWaypoints;
            _x setVariable [("inPanic" + (str _x)), true];

            if (_HQ getVariable [QEGVAR(core,debugII),false]) then
                {
                private _signum = _HQ getVariable [QEGVAR(core,codeSign),"X"];
                _i = [(getPosATL (vehicle (leader _x))),_x,"markPanic","ColorYellow","ICON","mil_dot",_signum + "!",_signum + "!",[0.5,0.5]] call EFUNC(common,mark)
                };

            _x setVariable [("Busy" + (str _x)), true];

            private _UL = leader _x;
            if not (isPlayer _UL) then
                {
                if ((random 100) < EGVAR(core,aIChatDensity)) then {[_UL,GVAR(aIC_InPanic),"InPanic"] call EFUNC(common,AIChatter)}
                };

            if (_HQ getVariable [QEGVAR(core,surr),false]) then
                {
                private _dngr = _x getVariable ["NearE",0];
                if (isNil "_dngr") then {_dngr = 0};
                if (_dngr < (0.5 + (random 0.5))) exitWith {};
                if ((random 100) > 0) then
                    {
                    if (_HQ getVariable [QEGVAR(core,debugII),false]) then
                        {
                        private _signum = _HQ getVariable [QEGVAR(core,codeSign),"X"];
                        _i setMarkerColorLocal "ColorPink";
                        _i setMarkerText (_signum + "!!!")
                        };

                    private _isCaptive = _x getVariable ("isCaptive" + (str _x));
                    if (isNil "_isCaptive") then {_isCaptive = false};
                    if not (_isCaptive) then
                        {
                        [_x] spawn
                            {
                            private _gp = _this select 0;
                            _gp setVariable [("isCaptive" + (str _gp)), true];
                            _gp setVariable [QEGVAR(common,mIA), true];

                            (units _gp) orderGetIn false;
                            (units _gp) allowGetIn false;

                                {
                                [_x] spawn
                                    {
                                    private _unit = _this select 0;

                                    sleep (random 1);
                                    if (isPlayer _unit) exitWith {[_unit] join grpNull};

                                    _unit setCaptive true;
                                    unassignVehicle _unit;

                                    for [{_a = 0},{_a < (count (weapons _unit))},{_a = _a + 1}] do
                                        {
                                        private _weapon = (weapons _unit) select _a;
                                        private _weaponHolder = "GroundWeaponHolder" createVehicle getPosATL _unit;
                                        _unit action ["dropWeapon", _weaponHolder, _weapon]
                                        };

                                    _unit playAction "Surrender";
                                    }
                                }
                            forEach (units _gp)
                            }
                        }
                    }
                }
            };

        private _panic = _x getVariable ("inPanic" + (str _x));
        if (isNil ("_panic")) then {_panic = false};

        if not (_panic) then
            {
            _x allowFleeing _cowF;
            _x setVariable [("Cow" + (str _x)),_cowF,true];
            }
        else
            {
            _x allowFleeing 1;
            _x setVariable [("Cow" + (str _x)),1,true];
            if ((random 1.1) > _cowF) then
                {
                private _isCaptive = _x getVariable ("isCaptive" + (str _x));
                if (isNil "_isCaptive") then {_isCaptive = false};
                _x setVariable [("inPanic" + (str _x)), false];
                if not (_isCaptive) then {_x setVariable [("Busy" + (str _x)), false]};
                }
            }
        }
    forEach _friends
    };

// Known enemy reveal
for [{_z = 0},{_z < (count _knownE)},{_z = _z + 1}] do
    {
    private _KnEnemy = _knownE select _z;
        {
        if ((_x knowsAbout _KnEnemy) > 0.01) then {_HQ reveal [_KnEnemy,2]}
        }
    forEach _friends
    };

// Cycle 1: personality roll + arty prep
if (_cycleC == 1) then
    {
    private _Recklessness = _HQ getVariable [QEGVAR(core,recklessness),0.5];
    private _Activity = _HQ getVariable [QEGVAR(core,activity),0.5];
    private _Fineness = _HQ getVariable [QEGVAR(core,fineness),0.5];
    private _Circumspection = _HQ getVariable [QEGVAR(core,circumspection),0.5];
    private _Consistency = _HQ getVariable [QEGVAR(core,consistency),0.5];

    if (_HQ getVariable [QEGVAR(core,aAO),false]) then
        {
        private _AAO = ((((0.1 + _Recklessness + _Fineness + (_Activity * 1.5))/((1 + _Circumspection) max 1)) min 1.8) max 0.05) > ((random 1) + (random 1));
        _HQ setVariable [QEGVAR(boss,chosenAAO),_AAO];
        };

    if (_HQ getVariable [QEGVAR(core,eBDoctrine),false]) then
        {
        private _EBT = ((((_Activity + _Recklessness)/(2 + _Fineness)) min 0.8) max 0.01) > ((random 0.5) + (random 0.5));

        _HQ setVariable [QGVAR(chosenEBDoctrine),_EBT]
        };

    if ((_HQ getVariable [QEGVAR(core,artyShells),1]) > 0) then
        {
        [_ArtG,(_HQ getVariable [QEGVAR(core,artyShells),1])] call EFUNC(common,artyPrep);
        };

    if ((EGVAR(missionmodules,active)) and ((_HQ getVariable ["leaderHQ",(leader _HQ)]) in (RydBBa_HQs + RydBBb_HQs))) then
        {
        _HQ setVariable [QGVAR(readyForBB),true];
        _HQ setVariable [QEGVAR(core,pending),false];
        if ((_HQ getVariable ["leaderHQ",(leader _HQ)]) in RydBBa_HQs) then
            {
            waitUntil {sleep 0.1;(RydBBa_InitDone)}
            };

        if ((_HQ getVariable ["leaderHQ",(leader _HQ)]) in RydBBb_HQs) then
            {
            waitUntil {sleep 0.1;(RydBBb_InitDone)}
            }
        }
    };

// Subsequent cycles: occasional AAO reroll
if (_cycleC > 1) then
    {
    if (_HQ getVariable [QEGVAR(core,aAO),false]) then
        {
        private _Consistency = _HQ getVariable [QEGVAR(core,consistency),0.5];

        if ((random 100) > (((90 + ((0.5 + _Consistency) * 4.5)) min 99) max 90)) then
            {
            private _Recklessness = _HQ getVariable [QEGVAR(core,recklessness),0.5];
            private _Activity = _HQ getVariable [QEGVAR(core,activity),0.5];
            private _Fineness = _HQ getVariable [QEGVAR(core,fineness),0.5];
            private _Circumspection = _HQ getVariable [QEGVAR(core,circumspection),0.5];

            private _AAO = (((((0.1 + _Recklessness + _Fineness + (_Activity * 1.5))/((1 + _Circumspection) max 1)) min 1.8) max 0.05) > ((random 1) + (random 1)));
            _HQ setVariable [QEGVAR(boss,chosenAAO),_AAO];
            }
        }
    };

private _AAO = _HQ getVariable [QEGVAR(boss,chosenAAO),false];
private _EBT = _HQ getVariable [QGVAR(chosenEBDoctrine),false];

if ((abs _morale) > (0.1 + (random 10) + (random 10) + (random 10) + (random 10) + (random 10))) then {_AAO = false};

if not (_AAO) then {_AAO = _HQ getVariable [QEGVAR(core,forceAAO),false]};
if not (_EBT) then {_EBT = _HQ getVariable [QEGVAR(core,forceEBDoctrine),false]};

if (_EBT) then {_AAO = true};

_HQ setVariable [QGVAR(chosenEBDoctrine),_EBT];
_HQ setVariable [QEGVAR(boss,chosenAAO),_AAO];

[_AAO, _EBT]
