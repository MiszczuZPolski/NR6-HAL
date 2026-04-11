#include "..\script_component.hpp"
// Originally from HAC_fnc.sqf (RYD_RHQCheck)

/**
 * @description Validates that all unit/vehicle classes present in the mission are registered
 *              in the RHQ (Reinforcement HQ) configuration. Logs missing classes to the RPT
 *              and shows a summary hint to the player.
 */

private _civF = ["CIV_F","CIV","CIV_RU","BIS_TK_CIV","BIS_CIV_special"];

private _specFor  = EGVAR(hal_data,specFor)  + EGVAR(hal_data,wS_specFor_class)  - RHQs_SpecFor;
private _recon    = EGVAR(hal_data,recon)    + EGVAR(hal_data,wS_recon_class)    - RHQs_Recon;
private _FO       = EGVAR(hal_data,fO)       + EGVAR(hal_data,wS_FO_class)       - RHQs_FO;
private _snipers  = EGVAR(hal_data,snipers)  + EGVAR(hal_data,wS_snipers_class)  - RHQs_Snipers;
private _ATinf    = EGVAR(hal_data,aTInf)    + EGVAR(hal_data,wS_ATinf_class)    - RHQs_ATInf;
private _AAinf    = EGVAR(hal_data,aAInf)    + EGVAR(hal_data,wS_AAinf_class)    - RHQs_AAInf;
private _Inf      = EGVAR(hal_data,inf)      + EGVAR(hal_data,wS_Inf_class)      - RHQs_Inf;
private _Art      = EGVAR(hal_data,art)      + EGVAR(hal_data,wS_Art_class)      - RHQs_Art;
private _HArmor   = EGVAR(hal_data,hArmor)   + EGVAR(hal_data,wS_HArmor_class)   - RHQs_HArmor;
private _MArmor   = EGVAR(hal_data,mArmor)   + EGVAR(hal_data,wS_MArmor_class)   - RHQs_MArmor;
private _LArmor   = EGVAR(hal_data,lArmor)   + EGVAR(hal_data,wS_LArmor_class)   - RHQs_LArmor;
private _LArmorAT = EGVAR(hal_data,lArmorAT) + EGVAR(hal_data,wS_LArmorAT_class) - RHQs_LArmorAT;
private _Cars     = EGVAR(hal_data,cars)     + EGVAR(hal_data,wS_Cars_class)      - RHQs_Cars;
private _Air      = EGVAR(hal_data,air)      + EGVAR(hal_data,wS_Air_class)       - RHQs_Air;
private _BAir     = EGVAR(hal_data,bAir)     + EGVAR(hal_data,wS_BAir_class)      - RHQs_BAir;
private _RAir     = EGVAR(hal_data,rAir)     + EGVAR(hal_data,wS_RAir_class)      - RHQs_RAir;
private _NCAir    = EGVAR(hal_data,nCAir)    + EGVAR(hal_data,wS_NCAir_class)     - RHQs_NCAir;
private _Naval    = EGVAR(hal_data,naval)    + EGVAR(hal_data,wS_Naval_class)      - RHQs_Naval;
private _Static   = EGVAR(hal_data,static)   + EGVAR(hal_data,wS_Static_class)    - RHQs_Static;
private _StaticAA = EGVAR(hal_data,staticAA) + EGVAR(hal_data,wS_StaticAA_class)  - RHQs_StaticAA;
private _StaticAT = EGVAR(hal_data,staticAT) + EGVAR(hal_data,wS_StaticAT_class)  - RHQs_StaticAT;
private _Support  = EGVAR(hal_data,support)  + EGVAR(hal_data,wS_Support_class)   - RHQs_Support;
private _Cargo    = EGVAR(hal_data,cargo)    + EGVAR(hal_data,wS_Cargo_class)      - RHQs_Cargo;
private _NCCargo  = EGVAR(hal_data,nCCargo)  + EGVAR(hal_data,wS_NCCargo_class)   - RHQs_NCCargo;
private _Crew     = EGVAR(hal_data,crew)     + EGVAR(hal_data,wS_Crew_class)       - RHQs_Crew;
private _Other    = EGVAR(hal_data,other)    + EGVAR(hal_data,wS_Other_class);
private _ammo     = EGVAR(hal_data,ammo)     + EGVAR(hal_data,wS_ammo)            - RHQs_Ammo;
private _fuel     = EGVAR(hal_data,fuel)     + EGVAR(hal_data,wS_fuel)             - RHQs_Fuel;
private _med      = EGVAR(hal_data,med)      + EGVAR(hal_data,wS_med)              - RHQs_Med;
private _rep      = EGVAR(hal_data,rep)      + EGVAR(hal_data,wS_rep)              - RHQs_Rep;

private _basicrhq      = _Inf + _Art + _HArmor + _LArmor + _Cars + _Air + _Naval + _Static;
private _Additionalrhq = _Other + _specFor + _recon + _FO + _snipers + _ATinf + _AAinf + _LArmorAT
                       + _NCAir + _StaticAA + _StaticAT + _Cargo + _NCCargo + _Crew + _MArmor
                       + _BAir + _RAir + _ammo + _fuel + _med + _rep;
private _total = _basicrhq + _Additionalrhq;

private _noInBasic      = [];
private _noInAdditional = [];
private _noInTotal      = [];

{
    if !((faction _x) in _civF) then {
        private _type = toLower (typeOf _x);
        if !((_type in _basicrhq)      || (_type in _noInBasic))      then { _noInBasic      pushBack _type };
        if !((_type in _Additionalrhq) || (_type in _noInAdditional)) then { _noInAdditional pushBack _type };
        if !((_type in _total)         || (_type in _noInTotal))       then { _noInTotal      pushBack _type };
    };
} forEach (allUnits + vehicles);

diag_log "-------------------------------------------------------------------------";
diag_log "-----------------------------RHQCHECK REPORT-----------------------------";
diag_log "-------------------------------------------------------------------------";
diag_log "Types not added to basic RHQ:";
{ diag_log format ["%1", _x] } forEach _noInBasic;
diag_log "-------------------------------------------------------------------------";
diag_log "Types not added to exact RHQ (not all must be):";
{ diag_log format ["%1", _x] } forEach _noInAdditional;
diag_log "-------------------------------------------------------------------------";
diag_log "Types not added anywhere:";
{ diag_log format ["%1", _x] } forEach _noInTotal;
diag_log "-------------------------------------------------------------------------";
diag_log "-------------------------END OF RHQCHECK REPORT--------------------------";
diag_log "-------------------------------------------------------------------------";

"RHQ CHECK" hintC format [
    "Forgotten classes: %1\nClasses not present in basic categories: %2\n(see RPT file for detailed forgotten classes list)",
    count _noInTotal,
    count _noInBasic
];
