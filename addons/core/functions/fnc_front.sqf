#include "..\script_component.hpp"

private _fnc_updateMarker = {
    params ["_HQ", "_front", "_ia"];

	while {!(isNull _HQ)} do {
		sleep 5;

		_ia setMarkerPosLocal (position _front);
		_ia setMarkerDirLocal (direction _front);
		_ia setMarkerSize (size _front);

		if (_HQ getVariable ["RydHQ_KIA", false]) exitWith {};
	};

	deleteMarker _ia;
};

private _code = {
    params ["_HQ", "_front", "_isRectangle", "_position", "_xAxis", "_yAxis", "_direction", "_code"];

	private _alive = true;

	waitUntil {
		sleep 5;

		_alive = true;

		switch (true) do {
			case (isNil "_HQ") : {_alive = false};
			case (isNull _HQ) : {_alive = false};
			case (({alive _x} count (units _HQ)) < 1) : {_alive = false};
		};

		_debug = _HQ getVariable "RydHQ_Debug";

		(!(isNil "_debug") || !(_alive))
	};

	if !(_alive) exitWith {};

	if (_HQ getVariable ["RydHQ_Debug", false]) then {
		private _shape = "ELLIPSE";
		if (_isRectangle) then {_shape = "RECTANGLE"};

		private _ia = "markFront" + (str _HQ);
		_ia = createMarker [_ia,_pos];
		_ia setMarkerColorLocal "ColorRed";
		_ia setMarkerShapeLocal _shape;
		_ia setMarkerSizeLocal [_XAxis, _YAxis];
		_ia setMarkerDirLocal _dir;
		_ia setMarkerBrushLocal "Border";
		_ia setMarkerColor "ColorKhaki";
		[[_HQ, _front, _ia], _fnc_updateMarker] call RYD_Spawn;
	};
};


{
    private _front = _x getVariable [QGVAR(front), objNull];
    if !(isNull _front) then {
        private _position = position _front;
        private _area = triggerArea _front;

        _area params ["_xAxis","_yAxis", "_direction","_isRectangle"];

        _front = createLocation ["Name", _position, _xAxis, _yAxis];
        _front setDirection _direction;
        _front setRectangular _isRectangle;

        _x setVariable [QGVAR(front), _front];

        [[_x, _front, _isRectangle, _position, _xAxis, _yAxis, _direction, _fnc_updateMarker], _code] call RYD_Spawn;
    };
} forEach GVAR(allHQ);
