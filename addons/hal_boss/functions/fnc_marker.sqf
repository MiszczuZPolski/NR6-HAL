#include "..\script_component.hpp"
// Originally from nr6_hal/Boss_fnc.sqf:1 (RYD_Marker)
/**
 * @description Creates a named marker on the map with specified visual properties
 * @param {String} _name Marker name/ID
 * @param {Array} _pos Position [x,y] or [x,y,z]
 * @param {String} _cl Marker color
 * @param {String} _shape Marker shape ("ICON", "RECTANGLE", etc.)
 * @param {Array} _size Marker size [width, height]
 * @param {Number} _dir Marker direction
 * @param {Number} _alpha Marker alpha (transparency)
 * @param {String} _typeOrBrush Marker type (for ICON) or brush (for other shapes)
 * @param {String} _text Marker text label
 * @return {String} Marker name
 */
params ["_name","_pos","_cl","_shape","_size","_dir","_alpha","_typeOrBrush","_text"];

private _type = "";
private _brush = "";

_shape = toUpper (_shape);

if !(_shape == "ICON") then {_brush = _typeOrBrush} else {_type = _typeOrBrush};

if !((typeName _pos) == "ARRAY") exitWith {};
if ((_pos select 0) == 0) exitWith {};
if ((count _pos) < 2) exitWith {};
//diag_log format ["BB mark: %1 pos: %2 col: %3 size: %4 dir: %5 text: %6",_name,_pos,_cl,_size,_dir,_text];
if (isNil "_pos") exitWith {};

private _i = _name;
_i = createMarker [_i,_pos];
_i setMarkerColor _cl;
_i setMarkerShape _shape;
_i setMarkerSize _size;
_i setMarkerDir _dir;
if !(_shape == "ICON") then {_i setMarkerBrush _brush} else {_i setMarkerType _type};
_i setMarkerAlpha _alpha;
_i setMarkerText _text;

RydxHQ_Markers set [(count RydxHQ_Markers),_i];

_i
