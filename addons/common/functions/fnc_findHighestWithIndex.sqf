#include "..\script_component.hpp"


params ["_array","_ix"];

private _highest = [];
private _clIndex = 0;

if ((count _array) > 0) then {
    _highest = _array select 0;
    private _index = 0;
    private _valMax = _highest select _ix;

    {
        private _valAct = _x select _ix;

        if (_valAct > _valMax) then {
            _highest = _x;
            _valMax = _valAct;
            _clIndex = _index
        };

        _index = _index + 1;
    } forEach _array;
};

[_highest, _clIndex]
