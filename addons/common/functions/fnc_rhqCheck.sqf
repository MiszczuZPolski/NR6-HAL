#include "..\script_component.hpp"
// Originally from HAC_fnc.sqf (RYD_RHQCheck)

/**
 * @description Validates that all unit/vehicle classes present in the mission are registered
 *              in the RHQ (Reinforcement HQ) configuration. Logs missing classes to the RPT
 *              and shows a summary hint to the player.
 */

private _civF = ["CIV_F","CIV","CIV_RU","BIS_TK_CIV","BIS_CIV_special"];

private _specFor  = EGVAR(data,specFor)  + EGVAR(data,wS_specFor_class)  - RHQs_SpecFor;
private _recon    = EGVAR(data,recon)    + EGVAR(data,wS_recon_class)    - RHQs_Recon;
private _FO       = EGVAR(data,fO)       + EGVAR(data,wS_FO_class)       - RHQs_FO;
private _snipers  = EGVAR(data,snipers)  + EGVAR(data,wS_snipers_class)  - RHQs_Snipers;
private _ATinf    = EGVAR(data,aTInf)    + EGVAR(data,wS_ATinf_class)    - RHQs_ATInf;
private _AAinf    = EGVAR(data,aAInf)    + EGVAR(data,wS_AAinf_class)    - RHQs_AAInf;
private _Inf      = EGVAR(data,inf)      + EGVAR(data,wS_Inf_class)      - RHQs_Inf;
private _Art      = EGVAR(data,art)      + EGVAR(data,wS_Art_class)      - RHQs_Art;
private _HArmor   = EGVAR(data,hArmor)   + EGVAR(data,wS_HArmor_class)   - RHQs_HArmor;
private _MArmor   = EGVAR(data,mArmor)   + EGVAR(data,wS_MArmor_class)   - RHQs_MArmor;
private _LArmor   = EGVAR(data,lArmor)   + EGVAR(data,wS_LArmor_class)   - RHQs_LArmor;
private _LArmorAT = EGVAR(data,lArmorAT) + EGVAR(data,wS_LArmorAT_class) - RHQs_LArmorAT;
private _Cars     = EGVAR(data,cars)     + EGVAR(data,wS_Cars_class)      - RHQs_Cars;
private _Air      = EGVAR(data,air)      + EGVAR(data,wS_Air_class)       - RHQs_Air;
private _BAir     = EGVAR(data,bAir)     + EGVAR(data,wS_BAir_class)      - RHQs_BAir;
private _RAir     = EGVAR(data,rAir)     + EGVAR(data,wS_RAir_class)      - RHQs_RAir;
private _NCAir    = EGVAR(data,nCAir)    + EGVAR(data,wS_NCAir_class)     - RHQs_NCAir;
private _Naval    = EGVAR(data,naval)    + EGVAR(data,wS_Naval_class)      - RHQs_Naval;
private _Static   = EGVAR(data,static)   + EGVAR(data,wS_Static_class)    - RHQs_Static;
private _StaticAA = EGVAR(data,staticAA) + EGVAR(data,wS_StaticAA_class)  - RHQs_StaticAA;
private _StaticAT = EGVAR(data,staticAT) + EGVAR(data,wS_StaticAT_class)  - RHQs_StaticAT;
private _Support  = EGVAR(data,support)  + EGVAR(data,wS_Support_class)   - RHQs_Support;
private _Cargo    = EGVAR(data,cargo)    + EGVAR(data,wS_Cargo_class)      - RHQs_Cargo;
private _NCCargo  = EGVAR(data,nCCargo)  + EGVAR(data,wS_NCCargo_class)   - RHQs_NCCargo;
private _Crew     = EGVAR(data,crew)     + EGVAR(data,wS_Crew_class)       - RHQs_Crew;
private _Other    = EGVAR(data,other)    + EGVAR(data,wS_Other_class);
private _ammo     = EGVAR(data,ammo)     + EGVAR(data,wS_ammo)            - RHQs_Ammo;
private _fuel     = EGVAR(data,fuel)     + EGVAR(data,wS_fuel)             - RHQs_Fuel;
private _med      = EGVAR(data,med)      + EGVAR(data,wS_med)              - RHQs_Med;
private _rep      = EGVAR(data,rep)      + EGVAR(data,wS_rep)              - RHQs_Rep;

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
