#include "..\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:1393 (ActionArtct)
/**
 * @description Artillery support task condition handler - presents fire mission UI to player
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

params ["_unit"];
private _grp = group _unit;

if not (isNil {_unit getVariable "HALArtPos"}) exitWith {hint "Artillery Request Already In Progress";};

private _HQ = grpNull;
private _Arts = [];
private _ArtyFriends = [];
private _Marks = false;

if (not (isNil "LeaderHQ") and not (isNil "ArtyFriendsA")) then {if (_grp in (ArtyFriendsA)) then {_HQ = (group LeaderHQ); _Arts = ArtyArtGA;}};
if (not (isNil "LeaderHQB") and not (isNil "ArtyFriendsB")) then {if (_grp in (ArtyFriendsB)) then {_HQ = (group LeaderHQB);_Arts = ArtyArtGB;}};
if (not (isNil "LeaderHQC") and not (isNil "ArtyFriendsC")) then {if (_grp in (ArtyFriendsC)) then {_HQ = (group LeaderHQC);_Arts = ArtyArtGC;}};
if (not (isNil "LeaderHQD") and not (isNil "ArtyFriendsD")) then {if (_grp in (ArtyFriendsD)) then {_HQ = (group LeaderHQD);_Arts = ArtyArtGD;}};
if (not (isNil "LeaderHQE") and not (isNil "ArtyFriendsE")) then {if (_grp in (ArtyFriendsE)) then {_HQ = (group LeaderHQE);_Arts = ArtyArtGE;}};
if (not (isNil "LeaderHQF") and not (isNil "ArtyFriendsF")) then {if (_grp in (ArtyFriendsF)) then {_HQ = (group LeaderHQF);_Arts = ArtyArtGF;}};
if (not (isNil "LeaderHQG") and not (isNil "ArtyFriendsG")) then {if (_grp in (ArtyFriendsG)) then {_HQ = (group LeaderHQG);_Arts = ArtyArtGG;}};
if (not (isNil "LeaderHQH") and not (isNil "ArtyFriendsH")) then {if (_grp in (ArtyFriendsH)) then {_HQ = (group LeaderHQH);_Arts = ArtyArtGH;}};

_unit onMapSingleClick "_this setvariable ['HALArtPos',_pos,true]; _this onMapSingleClick ''; hint 'Fire Mission Coordinates Selected'";

openMap true;

private _reqArtyMarks = [];

{
	private _lPiece = (vehicle (leader _x));
	private _veh = toLower (typeOf _lPiece);
	private _pos = position _lPiece;
	if ((vehicle (leader _x)) == (leader _x)) exitWith {};
	private _MrkTxt = (getText (configFile >> "CfgVehicles" >> typeOf (vehicle (leader _x)) >> "displayName")) + " (" + (groupId _x) + ")";
	private _minRange = missionNamespace getVariable [QEGVAR(data,classRangeMin) + str (_veh),0];
	private _maxRange = missionNamespace getVariable [QEGVAR(data,classRangeMax) + str (_veh),0];

	private _ctrPosMrk = createMarkerLocal ["ctrMark" + (str _x), position _lPiece];
	_ctrPosMrk setMarkerTypeLocal "mil_triangle";
	_ctrPosMrk setMarkerColorLocal "ColorRed";
	_ctrPosMrk setMarkerTextLocal _MrkTxt;
	_reqArtyMarks pushBack _ctrPosMrk;

	if (_minRange > 0) then {
		private _minRangeMrk = createMarkerLocal ["minMark" + (str _x), position _lPiece];
		_minRangeMrk setMarkerShapeLocal "ELLIPSE";
		_minRangeMrk setMarkerSizeLocal [_minRange, _minRange];
		_minRangeMrk setMarkerBrushLocal "Border";
		_minRangeMrk setMarkerColorLocal "ColorBlue";
		_reqArtyMarks pushBack _minRangeMrk;
	};

	if (_maxRange > 0) then {
		private _maxRangeMrk = createMarkerLocal ["maxMark" + (str _x), position _lPiece];
		_maxRangeMrk setMarkerShapeLocal "ELLIPSE";
		_maxRangeMrk setMarkerSizeLocal [_maxRange, _maxRange];
		_maxRangeMrk setMarkerBrushLocal "Border";
		_maxRangeMrk setMarkerColorLocal "ColorRed";
		_reqArtyMarks pushBack _maxRangeMrk;
	};

} forEach _Arts;

hintC "Select artillery strike coordinates. Closing the map will cancel the request.";

waitUntil {sleep 0.2; (not isNil {_unit getVariable "HALArtPos"} or not (alive _unit) or not (_unit == (leader _grp)) or not (visibleMap))};

if (isNil {_unit getVariable "HALArtPos"}) exitWith {hint "Artillery Request Cancelled";_unit setVariable ["HALArtPos",nil,true];{deleteMarkerLocal _x} forEach _reqArtyMarks;};

if (not (visibleMap)) exitWith {hint "Artillery Request Cancelled";_unit setVariable ["HALArtPos",nil,true];{deleteMarkerLocal _x} forEach _reqArtyMarks;};

private _ArtyMenu = [["Artillery Pieces",false]];
private _ArtyOptions = [];
private _selectedPiece = grpNull;

{

_ArtyOptions pushBack [(count _ArtyMenu),_x];
_ArtyMenu pushBack [ (getText (configFile >> "CfgVehicles" >> typeOf (vehicle (leader _x)) >> "displayName")) + " (" + (groupId _x) + ")" , [((count _ArtyMenu) + 1)] , "", -5, [["expression", "player setvariable ['HALArtPiece'," + (str (count _ArtyMenu)) +",true]"]], "1", "1"];

} forEach _Arts;

_ArtyMenu pushBack ["Cancel Fire Mission", [((count _ArtyMenu) + 1)] , "", -5, [["expression", "player setvariable ['HALArtPiece',0,true]"]], "1", "1"];

showCommandingMenu "#USER:_ArtyMenu";

waitUntil {sleep 0.2; (not (isNil {_unit getVariable "HALArtPiece"}) or not (alive _unit) or not (_unit == (leader _grp)) or not (visibleMap) or not (commandingMenu == "#USER:_ArtyMenu"))};

if (isNil {_unit getVariable "HALArtPiece"}) exitWith {hint "Artillery Request Cancelled";_unit setVariable ["HALArtPos",nil,true];{deleteMarkerLocal _x} forEach _reqArtyMarks;};

if (not (visibleMap)) exitWith {hint "Artillery Request Cancelled";_unit setVariable ["HALArtPiece",nil,true];_unit setVariable ["HALArtPos",nil,true];{deleteMarkerLocal _x} forEach _reqArtyMarks;};

if ((_unit getVariable "HALArtPiece") isEqualTo 0) exitWith {hint "Artillery Request Cancelled";_unit setVariable ["HALArtPiece",nil,true];_unit setVariable ["HALArtPos",nil,true];{deleteMarkerLocal _x} forEach _reqArtyMarks;};

{
	if ((_x select 0) isEqualTo (_unit getVariable "HALArtPiece")) exitWith {_selectedPiece = (_x select 1);_unit setVariable ["HALArtPiece",nil,true];};

} forEach _ArtyOptions;

{deleteMarkerLocal _x} forEach _reqArtyMarks;

private _ArtyMenuOrd = [["Ordnance Options",false]];
private _OrdOptions = [];
private _selectedOrd = "";


{
	if ((typeOf (vehicle (leader _selectedPiece))) in (_x select 0)) exitWith {

		if not (((_x select 1) select 0) isEqualTo "") then {
			_OrdOptions pushBack [(count _ArtyMenuOrd),"HE"];
			_ArtyMenuOrd pushBack ["High Explosive", [((count _ArtyMenuOrd) + 1)] , "", -5, [["expression", "player setvariable ['HALArtord'," + (str (count _ArtyMenuOrd)) +",true]"]], "1", "1"];
		};

		if not (((_x select 1) select 1) isEqualTo "") then {
			_OrdOptions pushBack [(count _ArtyMenuOrd),"SPECIAL"];
			_ArtyMenuOrd pushBack ["Special", [((count _ArtyMenuOrd) + 1)] , "", -5, [["expression", "player setvariable ['HALArtord'," + (str (count _ArtyMenuOrd)) +",true]"]], "1", "1"];
		};

		if not (((_x select 1) select 2) isEqualTo "") then {
			_OrdOptions pushBack [(count _ArtyMenuOrd),"SECONDARY"];
			_ArtyMenuOrd pushBack ["Guided/Secondary", [((count _ArtyMenuOrd) + 1)] , "", -5, [["expression", "player setvariable ['HALArtord'," + (str (count _ArtyMenuOrd)) +",true]"]], "1", "1"];
		};

		if not (((_x select 1) select 3) isEqualTo "") then {
			_OrdOptions pushBack [(count _ArtyMenuOrd),"SMOKE"];
			_ArtyMenuOrd pushBack ["Smoke", [((count _ArtyMenuOrd) + 1)] , "", -5, [["expression", "player setvariable ['HALArtord'," + (str (count _ArtyMenuOrd)) +",true]"]], "1", "1"];
		};

		if not (((_x select 1) select 4) isEqualTo "") then {
			_OrdOptions pushBack [(count _ArtyMenuOrd),"ILLUM"];
			_ArtyMenuOrd pushBack ["Illumination", [((count _ArtyMenuOrd) + 1)] , "", -5, [["expression", "player setvariable ['HALArtord'," + (str (count _ArtyMenuOrd)) +",true]"]], "1", "1"];
		};

	};

} forEach EGVAR(data,otherArty);

if ((count _ArtyMenuOrd) == 1) then {_OrdOptions = [[1,"HE"]];_ArtyMenuOrd pushBack ["High Explosive", [((count _ArtyMenuOrd) + 1)] , "", -5, [["expression", "player setvariable ['HALArtord',1,true]"]], "1", "1"];};

_ArtyMenuOrd pushBack ["Cancel Fire Mission", [((count _ArtyMenuOrd) + 1)] , "", -5, [["expression", "player setvariable ['HALArtord',0,true]"]], "1", "1"];

showCommandingMenu "#USER:_ArtyMenuOrd";

waitUntil {sleep 0.2; (not (isNil {_unit getVariable "HALArtord"}) or not (alive _unit) or not (_unit == (leader _grp)) or not (visibleMap) or not (commandingMenu == "#USER:_ArtyMenuOrd"))};

if (isNil {_unit getVariable "HALArtord"}) exitWith {hint "Artillery Request Cancelled";_unit setVariable ["HALArtPos",nil,true];_unit setVariable ["HALArtPiece",nil,true]};

if (not (visibleMap)) exitWith {hint "Artillery Request Cancelled";_unit setVariable ["HALArtord",nil,true];_unit setVariable ["HALArtPiece",nil,true];_unit setVariable ["HALArtPos",nil,true]};

if ((_unit getVariable "HALArtord") isEqualTo 0) exitWith {hint "Artillery Request Cancelled";_unit setVariable ["HALArtord",nil,true];_unit setVariable ["HALArtPiece",nil,true];_unit setVariable ["HALArtPos",nil,true]};

{
	if ((_x select 0) isEqualTo (_unit getVariable "HALArtord")) exitWith {_selectedOrd = (_x select 1);_unit setVariable ["HALArtord",nil,true];};

} forEach _OrdOptions;


private _ArtyMenuAmnt = [["Ordnance Strength",false]];

{

_ArtyMenuAmnt pushBack [(str _x), [((count _ArtyMenuAmnt) + 1)] , "", -5, [["expression", "player setvariable ['HALArtAmnt'," + (str _x) +",true]"]], "1", "1"];

} forEach [1,2,3,4,5,6,7,8,9];

_ArtyMenuAmnt pushBack ["Cancel Fire Mission", [((count _ArtyMenuAmnt) + 1)] , "", -5, [["expression", "player setvariable ['HALArtAmnt',0,true]"]], "1", "1"];

showCommandingMenu "#USER:_ArtyMenuAmnt";

waitUntil {sleep 0.2; (not (isNil {(_unit getVariable "HALArtAmnt")}) or not (alive _unit) or not (_unit == (leader _grp)) or not (visibleMap) or not (commandingMenu == "#USER:_ArtyMenuAmnt"))};

if (isNil {_unit getVariable "HALArtAmnt"}) exitWith {hint "Artillery Request Cancelled";_unit setVariable ["HALArtPos",nil,true];_unit setVariable ["HALArtord",nil,true];_unit setVariable ["HALArtPiece",nil,true]};

if (not (visibleMap)) exitWith {hint "Artillery Request Cancelled";_unit setVariable ["HALArtAmnt",nil,true];_unit setVariable ["HALArtord",nil,true];_unit setVariable ["HALArtPiece",nil,true];_unit setVariable ["HALArtPos",nil,true]};

if ((_unit getVariable "HALArtAmnt") == 0) exitWith {hint "Artillery Request Cancelled";_unit setVariable ["HALArtAmnt",nil,true];_unit setVariable ["HALArtord",nil,true];_unit setVariable ["HALArtPiece",nil,true];_unit setVariable ["HALArtPos",nil,true]};



[_unit, "Command, requesting fire support at GRID: " + (mapGridPosition (_unit getVariable ["HALArtPos",nil])) + " - Over"] remoteExecCall ["hal_common_fnc_MP_Sidechat"];

[_HQ,_unit,_unit getVariable ["HALArtPos",nil],_selectedPiece,_selectedOrd,_unit getVariable ["HALArtAmnt",nil]] remoteExec ["hal_tasking_fnc_actionArt2ct",2];


_unit setVariable ["HALArtAmnt",nil,true];
_unit setVariable ["HALArtord",nil,true];
_unit setVariable ["HALArtPiece",nil,true];
//	_unit setvariable ["HALArtPos",nil,true];
