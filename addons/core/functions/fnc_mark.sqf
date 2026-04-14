#include "..\script_component.hpp"
// hal_core proxy — forwards to EFUNC(common,mark)
// fnc_EnemyScan.sqf calls FUNC(mark) which resolves to hal_core_fnc_mark;
// the real implementation lives in hal_common_fnc_mark.

/**
 * @description Proxy: forwards all arguments to EFUNC(common,mark).
 * @param {Any} All parameters passed through to hal_common_fnc_mark
 * @return {String} Created marker name (forwarded from hal_common_fnc_mark)
 */
_this call EFUNC(common,mark)
