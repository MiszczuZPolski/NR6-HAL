#include "..\script_component.hpp"
// Originally from nr6_hal/HAC_fnc2.sqf:411-514 (RYD_StatusQuo, block S3a - friendly classification)

/**
 * @description Classifies friendly forces into typed arrays (Inf, Armor, Air, etc.)
 *              by inspecting each unit's typeOf against the RYD_WS_* class arrays.
 *              Writes results directly to HQ setVariable slots.
 * @param {Group} _HQ The HQ group
 * @param {Array} _friends Array of friendly groups to classify
 * @param {Number} _FValue Starting friendly force-value score
 * @return {Array} [_FValue, _SpecFor, _recon, _FO, _snipers, _ATinf, _AAinf, _Inf, _Art,
 *                  _HArmor, _MArmor, _LArmor, _LArmorAT, _Cars, _Air, _BAir, _RAir, _NCAir,
 *                  _Naval, _Static, _StaticAA, _StaticAT, _Support, _Cargo, _NCCargo, _Other,
 *                  _Crew, _NCrewInf,
 *                  _SpecForG, _reconG, _FOG, _snipersG, _ATinfG, _AAinfG, _InfG, _ArtG,
 *                  _HArmorG, _MArmorG, _LArmorG, _LArmorATG, _CarsG, _AirG, _BAirG, _RAirG,
 *                  _NCAirG, _NavalG, _StaticG, _StaticAAG, _StaticATG, _SupportG, _CargoG,
 *                  _NCCargoG, _OtherG, _CrewG, _NCrewInfG]
 */
params ["_HQ", "_friends", "_FValue"];

private _specFor_class = EGVAR(data,wS_specFor_class);
private _recon_class = EGVAR(data,wS_recon_class);
private _FO_class = EGVAR(data,wS_FO_class);
private _snipers_class = EGVAR(data,wS_snipers_class);
private _ATinf_class = EGVAR(data,wS_ATinf_class);
private _AAinf_class = EGVAR(data,wS_AAinf_class);
private _Inf_class = EGVAR(data,wS_Inf_class);
private _Art_class = EGVAR(data,wS_Art_class);
private _HArmor_class = EGVAR(data,wS_HArmor_class);
private _MArmor_class = EGVAR(data,wS_MArmor_class);
private _LArmor_class = EGVAR(data,wS_LArmor_class);
private _LArmorAT_class = EGVAR(data,wS_LArmorAT_class);
private _Cars_class = EGVAR(data,wS_Cars_class);
private _Air_class = EGVAR(data,wS_Air_class);
private _BAir_class = EGVAR(data,wS_BAir_class);
private _RAir_class = EGVAR(data,wS_RAir_class);
private _NCAir_class = EGVAR(data,wS_NCAir_class);
private _Naval_class = EGVAR(data,wS_Naval_class);
private _Static_class = EGVAR(data,wS_Static_class);
private _StaticAA_class = EGVAR(data,wS_StaticAA_class);
private _StaticAT_class = EGVAR(data,wS_StaticAT_class);
private _Cargo_class = EGVAR(data,wS_Cargo_class);
private _NCCargo_class = EGVAR(data,wS_NCCargo_class);
private _Crew_class = EGVAR(data,wS_Crew_class);
private _NCrewInf_class = _Inf_class - _Crew_class;
private _Support_class = EGVAR(data,wS_Support_class);

private _SpecFor = [];
private _recon = [];
private _FO = [];
private _snipers = [];
private _ATinf = [];
private _AAinf = [];
private _Inf = [];
private _Art = [];
private _HArmor = [];
private _MArmor = [];
private _LArmor = [];
private _LArmorAT = [];
private _Cars = [];
private _Air = [];
private _BAir = [];
private _RAir = [];
private _NCAir = [];
private _Naval = [];
private _Static = [];
private _StaticAA = [];
private _StaticAT = [];
private _Support = [];
private _Cargo = [];
private _NCCargo = [];
private _Other = [];
private _Crew = [];
private _NCrewInf = [];

private _SpecForG = [];
private _reconG = [];
private _FOG = [];
private _snipersG = [];
private _ATinfG = [];
private _AAinfG = [];
private _InfG = [];
private _ArtG = [];
private _HArmorG = [];
private _MArmorG = [];
private _LArmorG = [];
private _LArmorATG = [];
private _CarsG = [];
private _AirG = [];
private _BAirG = [];
private _RAirG = [];
private _NCAirG = [];
private _NavalG = [];
private _StaticG = [];
private _StaticAAG = [];
private _StaticATG = [];
private _SupportG = [];
private _CargoG = [];
private _NCCargoG = [];
private _OtherG = [];
private _CrewG = [];
private _NCrewInfG = [];

    {
        {
        private _SpecForcheck = false;
        private _reconcheck = false;
        private _FOcheck = false;
        private _sniperscheck = false;
        private _ATinfcheck = false;
        private _AAinfcheck = false;
        private _Infcheck = false;
        private _Artcheck = false;
        private _HArmorcheck = false;
        private _MArmorcheck = false;
        private _LArmorcheck = false;
        private _LArmorATcheck = false;
        private _Carscheck = false;
        private _Aircheck = false;
        private _BAircheck = false;
        private _RAircheck = false;
        private _NCAircheck = false;
        private _Navalcheck = false;
        private _Staticcheck = false;
        private _StaticAAcheck = false;
        private _StaticATcheck = false;
        private _Supportcheck = false;
        private _Cargocheck = false;
        private _NCCargocheck = false;
        private _Othercheck = true;

        private _Crewcheck = false;
        private _NCrewInfcheck = false;

        private _tp = toLower (typeOf _x);
        private _grp = group _x;
        private _vh = vehicle _x;
        if (_x == _vh) then {_vh = objNull};
        private _asV = assignedVehicle _x;
        private _grpD = group (driver _vh);
        private _grpG = group (gunner _vh);
        if (isNull _grpD) then {_grpD = _grpG};
        private _Tvh = toLower (typeOf _vh);
        private _TasV = toLower (typeOf _asV);

            if (((_grp == _grpD) and {(_Tvh in _specFor_class)}) or {(_tp in _specFor_class)}) then {_SpecForcheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _recon_class)}) or {(_tp in _recon_class)}) then {_reconcheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _FO_class)}) or {(_tp in _FO_class)}) then {_FOcheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _snipers_class)}) or {(_tp in _snipers_class)}) then {_sniperscheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _ATinf_class)}) or {(_tp in _ATinf_class)}) then {_ATinfcheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _AAinf_class)}) or {(_tp in _AAinf_class)}) then {_AAinfcheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _Inf_class)}) or {(_tp in _Inf_class)}) then {_Infcheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _Art_class)}) or {(_tp in _Art_class)}) then {_Artcheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _HArmor_class)}) or {(_tp in _HArmor_class)}) then {_HArmorcheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _MArmor_class)}) or {(_tp in _MArmor_class)}) then {_MArmorcheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _LArmor_class)}) or {(_tp in _LArmor_class)}) then {_LArmorcheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _LArmorAT_class)}) or {(_tp in _LArmorAT_class)}) then {_LArmorATcheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _Cars_class)}) or {(_tp in _Cars_class)}) then {_Carscheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _Air_class)}) or {(_tp in _Air_class)}) then {_Aircheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _BAir_class)}) or {(_tp in _BAir_class)}) then {_BAircheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _RAir_class)}) or {(_tp in _RAir_class)}) then {_RAircheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _NCAir_class)}) or {(_tp in _NCAir_class)}) then {_NCAircheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _Naval_class)}) or {(_tp in _Naval_class)}) then {_Navalcheck = true;_Othercheck = false};
            if (((_grp == _grpG) and {(_Tvh in _Static_class)}) or {(_tp in _Static_class)}) then {_Staticcheck = true;_Othercheck = false};
            if (((_grp == _grpG) and {(_Tvh in _StaticAA_class)}) or {(_tp in _StaticAA_class)}) then {_StaticAAcheck = true;_Othercheck = false};
            if (((_grp == _grpG) and {(_Tvh in _StaticAT_class)}) or {(_tp in _StaticAT_class)}) then {_StaticATcheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _Cargo_class)}) or {(_tp in _Cargo_class)}) then {_Cargocheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _NCCargo_class)}) or {(_tp in _NCCargo_class)}) then {_NCCargocheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _Crew_class)}) or {(_tp in _Crew_class)}) then {_Crewcheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _NCrewInf_class)}) or {(_tp in _NCrewInf_class)}) then {_NCrewInfcheck = true;_Othercheck = false};
            if (((_grp == _grpD) and {(_Tvh in _Support_class)}) or {(_tp in _Support_class)}) then {_Supportcheck = true;_NCrewInfcheck = false;_Othercheck = false};

            if ((_Tvh in _NCCargo_class) and {(_x == (assignedDriver _asV)) and {((count (units (group _x))) == 1) and {not ((_ATinfcheck) or {(_AAinfcheck) or {(_reconcheck) or {(_FOcheck) or {(_sniperscheck)}}}})}}}) then {_NCrewInfcheck = false;_Othercheck = false};

            _vh = vehicle _x;

            if (_SpecForcheck) then {if not (_vh in _SpecFor) then {_SpecFor pushBack _vh};if not (_grp in _SpecForG) then {_SpecForG pushBack _grp}};
            if (_reconcheck) then {if not (_vh in _recon) then {_recon pushBack _vh};if not (_grp in _reconG) then {_reconG pushBack _grp}};
            if (_FOcheck) then {if not (_vh in _FO) then {_FO pushBack _vh};if not (_grp in _FOG) then {_FOG pushBack _grp}};
            if (_sniperscheck) then {if not (_vh in _snipers) then {_snipers pushBack _vh};if not (_grp in _snipersG) then {_snipersG pushBack _grp}};
            if (_ATinfcheck) then {if not (_vh in _ATinf) then {_ATinf pushBack _vh};if not (_grp in _ATinfG) then {_ATinfG pushBack _grp}};
            if (_AAinfcheck) then {if not (_vh in _AAinf) then {_AAinf pushBack _vh};if not (_grp in _AAinfG) then {_AAinfG pushBack _grp}};
            if (_Infcheck) then {if not (_vh in _Inf) then {_FValue = _FValue + 1;_Inf pushBack _vh};if not (_grp in _InfG) then {_InfG pushBack _grp}};
            if (_Artcheck) then {if not (_vh in _Art) then {_FValue = _FValue + 3;_Art pushBack _vh};if not (_grp in _ArtG) then {_ArtG pushBack _grp}};
            if (_HArmorcheck) then {if not (_vh in _HArmor) then {_FValue = _FValue + 10;_HArmor pushBack _vh};if not (_grp in _HArmorG) then {_HArmorG pushBack _grp}};
            if (_MArmorcheck) then {if not (_vh in _MArmor) then {_MArmor pushBack _vh};if not (_grp in _MArmorG) then {_MArmorG pushBack _grp}};
            if (_LArmorcheck) then {if not (_vh in _LArmor) then {_FValue = _FValue + 5;_LArmor pushBack _vh};if not (_grp in _LArmorG) then {_LArmorG pushBack _grp}};
            if (_LArmorATcheck) then {if not (_vh in _LArmorAT) then {_LArmorAT pushBack _vh};if not (_grp in _LArmorATG) then {_LArmorATG pushBack _grp}};
            if (_Carscheck) then {if not (_vh in _Cars) then {_FValue = _FValue + 3;_Cars pushBack _vh};if not (_grp in _CarsG) then {_CarsG pushBack _grp}};
            if (_Aircheck) then {if not (_vh in _Air) then {_FValue = _FValue + 15;_Air pushBack _vh};if not (_grp in _AirG) then {_AirG pushBack _grp}};
            if (_BAircheck) then {if not (_vh in _BAir) then {_BAir pushBack _vh};if not (_grp in _BAirG) then {_BAirG pushBack _grp}};
            if (_RAircheck) then {if not (_vh in _RAir) then {_RAir pushBack _vh};if not (_grp in _RAirG) then {_RAirG pushBack _grp}};
            if (_NCAircheck) then {if not (_vh in _NCAir) then {_NCAir pushBack _vh};if not (_grp in _NCAirG) then {_NCAirG pushBack _grp}};
            if (_Navalcheck) then {if not (_vh in _Naval) then {_Naval pushBack _vh};if not ((group _vh) in _NavalG) then {_NavalG pushBackUnique (group _vh)}};
            if (_Staticcheck) then {if not (_vh in _Static) then {_FValue = _FValue + 1;_Static pushBack _vh};if not (_grp in _StaticG) then {_StaticG pushBack _grp}};
            if (_StaticAAcheck) then {if not (_vh in _StaticAA) then {_StaticAA pushBack _vh};if not (_grp in _StaticAAG) then {_StaticAAG pushBack _grp}};
            if (_StaticATcheck) then {if not (_vh in _StaticAT) then {_StaticAT pushBack _vh};if not (_grp in _StaticATG) then {_StaticATG pushBack _grp}};
            if (_Supportcheck) then {if not (_vh in _Support) then {_Support pushBack _vh};if not (_grp in _SupportG) then {_SupportG pushBack _grp}};
            if (_Cargocheck) then {if not (_vh in _Cargo) then {_Cargo pushBack _vh};if not (_grp in _CargoG) then {_CargoG pushBack _grp}};
            if (_NCCargocheck) then {if not (_vh in _NCCargo) then {_NCCargo pushBack _vh};if not (_grp in _NCCargoG) then {_NCCargoG pushBack _grp}};
            if (_Crewcheck) then {if not (_vh in _Crew) then {_Crew pushBack _vh};if not (_grp in _CrewG) then {_CrewG pushBack _grp}};
            if (_NCrewInfcheck) then {if not (_vh in _NCrewInf) then {_NCrewInf pushBack _vh};if not (_grp in _NCrewInfG) then {_NCrewInfG pushBack _grp}};

        }
    forEach (units _x)
    }
forEach _friends;

_HQ setVariable [QEGVAR(boss,fValue),_FValue];

_HQ setVariable [QGVAR(specFor),_SpecFor];
_HQ setVariable [QGVAR(recon),_recon];
_HQ setVariable [QGVAR(fO),_FO];
_HQ setVariable [QGVAR(snipers),_snipers];
_HQ setVariable [QGVAR(aTinf),_ATinf];
_HQ setVariable [QGVAR(aAinf),_AAinf];
_HQ setVariable [QGVAR(art),_Art];
_HQ setVariable [QGVAR(hArmor),_HArmor];
_HQ setVariable [QGVAR(mArmor),_MArmor];
_HQ setVariable [QGVAR(lArmor),_LArmor];
_HQ setVariable [QGVAR(lArmorAT),_LArmorAT];
_HQ setVariable [QGVAR(cars),_Cars];
_HQ setVariable [QGVAR(air),_Air];
_HQ setVariable [QGVAR(bAir),_BAir];
_HQ setVariable [QGVAR(rAir),_RAir];
_HQ setVariable [QGVAR(nCAir),_NCAir];
_HQ setVariable [QGVAR(naval),_Naval];
_HQ setVariable [QGVAR(static),_Static];
_HQ setVariable [QGVAR(staticAA),_StaticAA];
_HQ setVariable [QGVAR(staticAT),_StaticAT];
_HQ setVariable [QGVAR(support),_Support];
_HQ setVariable [QGVAR(cargo),_Cargo];
_HQ setVariable [QGVAR(nCCargo),_NCCargo];
_HQ setVariable [QGVAR(other),_Other];
_HQ setVariable [QGVAR(crew),_Crew];

_HQ setVariable [QGVAR(specForG),_SpecForG];
_HQ setVariable [QGVAR(reconG),_reconG];
_HQ setVariable [QGVAR(fOG),_FOG];
_HQ setVariable [QGVAR(snipersG),_snipersG];
_HQ setVariable [QGVAR(aTinfG),_ATinfG];
_HQ setVariable [QGVAR(aAinfG),_AAinfG];
_HQ setVariable [QEGVAR(core,artG),_ArtG];
_HQ setVariable [QEGVAR(boss,hArmorG),_HArmorG];
_HQ setVariable [QGVAR(mArmorG),_MArmorG];
_HQ setVariable [QEGVAR(boss,lArmorG),_LArmorG];
_HQ setVariable [QGVAR(lArmorATG),_LArmorATG];
_HQ setVariable [QEGVAR(boss,carsG),_CarsG];
_HQ setVariable [QEGVAR(core,airG),_AirG];
_HQ setVariable [QGVAR(bAirG),_BAirG];
_HQ setVariable [QGVAR(rAirG),_RAirG];
_HQ setVariable [QEGVAR(boss,nCAirG),_NCAirG];
_HQ setVariable [QEGVAR(core,navalG),_NavalG];
_HQ setVariable [QGVAR(staticG),_StaticG];
_HQ setVariable [QGVAR(staticAAG),_StaticAAG];
_HQ setVariable [QGVAR(staticATG),_StaticATG];
_HQ setVariable [QEGVAR(core,nCCargoG),_NCCargoG];
_HQ setVariable [QGVAR(otherG),_OtherG];
_HQ setVariable [QGVAR(crewG),_CrewG];

_NCrewInfG = _NCrewInfG - (_RAirG + _StaticG);
_NCrewInf = _NCrewInf - (_RAir + _Static);
_InfG = _InfG - (_RAirG + _StaticG);
_Inf = _Inf - (_RAir + _Static);

private _CargoAirEx = [];
private _CargoLandEx = [];
if (_HQ getVariable [QEGVAR(core,noAirCargo),false]) then {_CargoAirEx = _AirG};
if (_HQ getVariable [QEGVAR(core,noLandCargo),false]) then {_CargoLandEx = (_CargoG - _AirG)};
_CargoG = _CargoG - (_CargoAirEx + _CargoLandEx + (_HQ getVariable [QEGVAR(core,ammoDrop),[]]));
_HQ setVariable [QGVAR(cargoAirEx),_CargoAirEx];
_HQ setVariable [QGVAR(cargoLandEx),_CargoLandEx];

    {
    if not (_x in _SupportG) then
        {
        _SupportG pushBack _x
        }
    }
forEach (_HQ getVariable [QEGVAR(core,ammoDrop),[]]);

_HQ setVariable [QGVAR(nCrewInf),_NCrewInf];
_HQ setVariable [QEGVAR(core,nCrewInfG),_NCrewInfG];
_HQ setVariable [QGVAR(inf),_Inf];
_HQ setVariable [QGVAR(infG),_InfG];
_HQ setVariable [QGVAR(cargoG),_CargoG];
_HQ setVariable [QEGVAR(core,supportG),_SupportG];

[_FValue, _SpecFor, _recon, _FO, _snipers, _ATinf, _AAinf, _Inf, _Art,
 _HArmor, _MArmor, _LArmor, _LArmorAT, _Cars, _Air, _BAir, _RAir, _NCAir,
 _Naval, _Static, _StaticAA, _StaticAT, _Support, _Cargo, _NCCargo, _Other,
 _Crew, _NCrewInf,
 _SpecForG, _reconG, _FOG, _snipersG, _ATinfG, _AAinfG, _InfG, _ArtG,
 _HArmorG, _MArmorG, _LArmorG, _LArmorATG, _CarsG, _AirG, _BAirG, _RAirG,
 _NCAirG, _NavalG, _StaticG, _StaticAAG, _StaticATG, _SupportG, _CargoG,
 _NCCargoG, _OtherG, _CrewG, _NCrewInfG]
