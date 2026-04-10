#include "..\script_component.hpp"
// Originally from nr6_hal/Boss_fnc.sqf:576 (RYD_TopoAnalize)
/**
 * @description Analyzes topographic suitability of sectors for infantry and vehicle movement
 * @param {Array} _sectors Array of sector location objects with Topo_* variables set
 * @return {Array} [filteredSectors, infFactor, vehFactor]
 */
params ["_sectors"];

private _sectors0 = _sectors;

private _infF = 0;
private _vehF = 0;
private _ct = 0;

{
    private _urbanF = _x getVariable "Topo_Urban";
    private _forestF = _x getVariable "Topo_Forest";
    private _hillsF = _x getVariable "Topo_Hills";
    private _flatF = _x getVariable "Topo_Flat";
    private _seaF = _x getVariable "Topo_Sea";
    private _roadsF = _x getVariable "Topo_Roads";
    private _grF = _x getVariable "Topo_Grd";

    if !(_seaF >= 90) then
        {
        //diag_log format ["L - U: %1 F: %2 H: %3, Fl: %4 S: %5 R: %6 G: %7 ",_urbanF,_forestF,_hillsF,_flatF,_seaF,_roadsF,_grF];

        private _actInf = _urbanF + _forestF + _grF - _flatF - _hillsF;
        private _actVeh = _flatF + _hillsF + _roadsF - _urbanF - _forestF - _grF;

        _x setVariable ["InfFr",_actInf];
        _x setVariable ["VehFr",_actVeh];

        _infF = _infF + _actInf;
        _vehF = _vehF + _actVeh;

        //_txt = format ["Inf: %1 - Veh: %2",_urbanF + _forestF + _grF - _flatF - _hillsF,_flatF + _hillsF + _roadsF - _urbanF - _forestF - _grF];

        //_x setText _txt;
        _ct = _ct + 1
        }
    else
        {
        _sectors = _sectors - [_x];
        }
} forEach _sectors0;

if (_ct > 0) then {_infF = _infF/_ct};
if (_ct > 0) then {_vehF = _vehF/_ct};

[_sectors,_infF,_vehF]
