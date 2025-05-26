


params ["_array"];

private _biggest = grpNull;

if ((count _array) > 0) then {
    _biggest = _array select 0;
    private _index = 0;
    private _clIndex = 0;
    private _valMax = count (units _biggest);

    {
        _valAct = count (units _x);

        if (_valAct > _valMax) then {
            _biggest = _x;
            _valMax = _valAct;
            _clIndex = _index
        };

        _index = _index + 1
    } forEach _array
};

[_biggest, _clIndex]
