#include "..\script_component.hpp"
// Originally from nr6_hal/HAL/HQOrdersEast.sqf

private ["_HQ","_ReconAv","_attackAv","_objectives","_clusters","_targets","_cnt","_pX","_pY","_pos","_reconDvs","_attackDvs","_amnt","_rDiv","_aDiv","_recAm","_attAm","_center","_initialPositions","_recDiv",
	"_attDiv","_angle","_pointsAm","_echelons","_echDst","_echelonP","_settingPoints","_lWing","_rWing"];

_HQ = _this select 0;
_ReconAv = _this select 1;
_attackAv = _this select 2;

_knownEnemy = _HQ getVariable [QEGVAR(common,knEnemiesG),[]];

_objectives = _HQ getVariable [QEGVAR(core,objectives),[]];

_objectives = +_objectives;
	
_clusters = [_objectives,300] call EFUNC(common,clusterC);

_targets = [];

	{
	_cnt = count _x;
	
	if (_cnt > 0) then
		{
		_pX = 0;
		_pY = 0;
		
			{
			_pos = getPosATL _x;
			_pX = _pX + (_pos select 0);
			_pY = _pY + (_pos select 1);
			}
		forEach _x;

		_pos = [_pX/_cnt,_pY/_cnt,0];
		
			{
			_x setPosATL _pos
			}
		forEach _x;
		
		_targets pushBack (_x select 0)
		}
	}
forEach _clusters;

_amnt = (count _targets);

_recAm = (floor ((count _ReconAv)/_amnt)) - 1;
_attAm = (floor ((count _attackAv)/_amnt)) - 1;

_reconDvs = [];
_attackDvs = [];

for "_i" from 1 to _amnt do
	{
	_rDiv = [];
	for "_j" from 0 to _recAm do
		{
		_rDiv pushBack (_ReconAv select _j);
		_reconAv set [_j,0]
		};
		
	_reconAv = _reconAv - [0];
		
	_reconDvs pushBack _rDiv;
	
	_aDiv = [];
		
	for "_j" from 0 to _attAm do
		{
		_aDiv pushBack (_attackAv select _j);
		_attackAv set [_j,0]
		};
		
	_attackAv = _attackAv - [0];
	
	_attackDvs pushBack _aDiv;
	};
	
_center = getPosATL (vehicle (leader _HQ));

_initialPositions = [];

	{
	_angle = [_center,getPosATL _x,0] call EFUNC(common,angleTowards);
	
	_recDiv = _reconDvs select _foreachIndex;
	
	_pointsAm = count _recDiv;
	
	_attDiv = _attackDvs select _foreachIndex;
	
	_pointsAm = _pointsAm + (count _recDiv);
	
	_echelons = [];
	_echDst = 100;
	
	for "_i" from 1 to (ceil(_pointsAm)/3) do
		{
		_echelonP = [_center,_angle,_echDst] call EFUNC(common,positionTowards2D);
		_echDst = _echDst + 100;
		_echelons pushBack _echelonP
		};
		
	_settingPoints = [];
	
		{
		_lWing = [_x,_angle - 90,150] call EFUNC(common,positionTowards2D);
		_rWing = [_x,_angle + 90,150] call EFUNC(common,positionTowards2D);
		
		_settingPoints pushBack [_lWing,_x,_rWing];
		}
	forEach _echelons;
	
	_initialPositions pushBack _settingPoints;
	}
forEach _targets;

_noCombat = (_HQ getVariable [QEGVAR(boss,nCAirG),[]]) + (_HQ getVariable [QEGVAR(core,nCCargoG),[]]) + (_HQ getVariable [QGVAR(ammoSupportG),[]]) + (_HQ getVariable [QGVAR(repSupportG),[]]) + (_HQ getVariable [QGVAR(medSupportG),[]]) + (_HQ getVariable [QGVAR(fuelSupportG),[]]);
_airRecon = (_HQ getVariable [QGVAR(rAirG),[]]);
_armored = (_HQ getVariable [QEGVAR(boss,hArmorG),[]]) - _noCombat; 
_mechanized = ((_HQ getVariable [QGVAR(mArmorG),[]]) + (_HQ getVariable [QEGVAR(boss,lArmorG),[]]) + (_HQ getVariable [QEGVAR(boss,carsG),[]])) - _noCombat;
_static = ((_HQ getVariable [QGVAR(staticG),[]]) + (_HQ getVariable [QEGVAR(core,artG),[]])) - _noCombat;
_air = ((_HQ getVariable [QEGVAR(core,airG),[]]) - _airRecon) - _noCombat;
_naval = _HQ getVariable [QEGVAR(core,navalG),[]];
_onFoot = ((_HQ getVariable [QEGVAR(core,nCrewInfG),[]]) - (_HQ getVariable [QGVAR(specForG),[]])) - (_armored + _mechanized + _static + _air + _naval + _airRecon);

_all = _ReconAv + _attackAv;

	{
	_kind = _x;
	
		{
		if not (_x in _all) then
			{
			_kind set [_foreachIndex,0]
			}
		}
	forEach _kind;
	
	_kind = _kind - [0]
	}
forEach [_airRecon,_armored,_mechanized,_static,_air,_onFoot];

_enRoute = _ReconAv + _attackAv;
