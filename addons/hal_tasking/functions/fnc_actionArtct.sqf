#include "..\\script_component.hpp"
// Originally from nr6_hal/TaskInitNR6.sqf:1393 (ActionArtct)
/**
 * @description Artillery support task condition handler - presents fire mission UI to player
 * @param {Object} _unit - The unit this action applies to (_this select 0)
 * @return {nil}
 */

	private ["_unitvar","_chosen","_HQ","_dist"];

	if not (isNil {(_this select 0) getVariable "HALArtPos"}) exitWith {hint "Artillery Request Already In Progress";};

	_HQ = grpNull;
	_Arts = [];
	_ArtyFriends = [];
	_Marks = false;

	if (not (isNil "LeaderHQ") and not (isNil "ArtyFriendsA")) then {if ((group (_this select 0)) in (ArtyFriendsA)) then {_HQ = (group LeaderHQ); _Arts = ArtyArtGA;}};
	if (not (isNil "LeaderHQB") and not (isNil "ArtyFriendsB")) then {if ((group (_this select 0)) in (ArtyFriendsB)) then {_HQ = (group LeaderHQB);_Arts = ArtyArtGB;}};
	if (not (isNil "LeaderHQC") and not (isNil "ArtyFriendsC")) then {if ((group (_this select 0)) in (ArtyFriendsC)) then {_HQ = (group LeaderHQC);_Arts = ArtyArtGC;}};
	if (not (isNil "LeaderHQD") and not (isNil "ArtyFriendsD")) then {if ((group (_this select 0)) in (ArtyFriendsD)) then {_HQ = (group LeaderHQD);_Arts = ArtyArtGD;}};
	if (not (isNil "LeaderHQE") and not (isNil "ArtyFriendsE")) then {if ((group (_this select 0)) in (ArtyFriendsE)) then {_HQ = (group LeaderHQE);_Arts = ArtyArtGE;}};
	if (not (isNil "LeaderHQF") and not (isNil "ArtyFriendsF")) then {if ((group (_this select 0)) in (ArtyFriendsF)) then {_HQ = (group LeaderHQF);_Arts = ArtyArtGF;}};
	if (not (isNil "LeaderHQG") and not (isNil "ArtyFriendsG")) then {if ((group (_this select 0)) in (ArtyFriendsG)) then {_HQ = (group LeaderHQG);_Arts = ArtyArtGG;}};
	if (not (isNil "LeaderHQH") and not (isNil "ArtyFriendsH")) then {if ((group (_this select 0)) in (ArtyFriendsH)) then {_HQ = (group LeaderHQH);_Arts = ArtyArtGH;}};

	(_this select 0) onMapSingleClick "_this setvariable ['HALArtPos',_pos,true]; _this onMapSingleClick ''; hint 'Fire Mission Coordinates Selected'";

	openMap true;

	_reqArtyMarks = [];

	{
		_lPiece = (vehicle (leader _x));
		_veh = toLower (typeOf _lPiece);
		_pos = position _lPiece;
		if ((vehicle (leader _x)) == (leader _x)) exitWith {};
		_MrkTxt = (getText (configFile >> "CfgVehicles" >> typeOf (vehicle (leader _x)) >> "displayName")) + " (" + (groupId _x) + ")";
		_minRange = missionNamespace getVariable ["RHQ_ClassRangeMin" + str (_veh),0];
		_maxRange = missionNamespace getVariable ["RHQ_ClassRangeMax" + str (_veh),0];

		_ctrPosMrk = createMarkerLocal ["ctrMark" + (str _x), position _lPiece];
		_ctrPosMrk setMarkerTypeLocal "mil_triangle";
		_ctrPosMrk setMarkerColorLocal "ColorRed";
		_ctrPosMrk setMarkerTextLocal _MrkTxt;
		_reqArtyMarks pushBack _ctrPosMrk;

		if (_minRange > 0) then {
			_minRangeMrk = createMarkerLocal ["minMark" + (str _x), position _lPiece]; 
			_minRangeMrk setMarkerShapeLocal "ELLIPSE"; 
			_minRangeMrk setMarkerSizeLocal [_minRange, _minRange];
			_minRangeMrk setMarkerBrushLocal "Border";
			_minRangeMrk setMarkerColorLocal "ColorBlue";
			_reqArtyMarks pushBack _minRangeMrk;
		};
		
		if (_maxRange > 0) then {
			_maxRangeMrk = createMarkerLocal ["maxMark" + (str _x), position _lPiece]; 
			_maxRangeMrk setMarkerShapeLocal "ELLIPSE"; 
			_maxRangeMrk setMarkerSizeLocal [_maxRange, _maxRange];
			_maxRangeMrk setMarkerBrushLocal "Border";
			_maxRangeMrk setMarkerColorLocal "ColorRed";
			_reqArtyMarks pushBack _maxRangeMrk;
		};

	} forEach _Arts;

	hintC "Select artillery strike coordinates. Closing the map will cancel the request.";

	waitUntil {sleep 0.2; (not isNil {(_this select 0) getVariable "HALArtPos"} or not (alive (_this select 0)) or not ((_this select 0) == (leader (group (_this select 0)))) or not (visibleMap))};

	if (isNil {(_this select 0) getVariable "HALArtPos"}) exitWith {hint "Artillery Request Cancelled";(_this select 0) setVariable ["HALArtPos",nil,true];{deleteMarkerLocal _x} forEach _reqArtyMarks;};

	if (not (visibleMap)) exitWith {hint "Artillery Request Cancelled";(_this select 0) setVariable ["HALArtPos",nil,true];{deleteMarkerLocal _x} forEach _reqArtyMarks;};

	_ArtyMenu = [["Artillery Pieces",false]];
	_ArtyOptions = [];
	_selectedPiece = grpNull;

	{
	
	_ArtyOptions pushBack [(count _ArtyMenu),_x];
	_ArtyMenu pushBack [ (getText (configFile >> "CfgVehicles" >> typeOf (vehicle (leader _x)) >> "displayName")) + " (" + (groupId _x) + ")" , [((count _ArtyMenu) + 1)] , "", -5, [["expression", "player setvariable ['HALArtPiece'," + (str (count _ArtyMenu)) +",true]"]], "1", "1"];

	} forEach _Arts;

	_ArtyMenu pushBack ["Cancel Fire Mission", [((count _ArtyMenu) + 1)] , "", -5, [["expression", "player setvariable ['HALArtPiece',0,true]"]], "1", "1"];

	showCommandingMenu "#USER:_ArtyMenu";

	waitUntil {sleep 0.2; (not (isNil {(_this select 0) getVariable "HALArtPiece"}) or not (alive (_this select 0)) or not ((_this select 0) == (leader (group (_this select 0)))) or not (visibleMap) or not (commandingMenu == "#USER:_ArtyMenu"))};

	if (isNil {(_this select 0) getVariable "HALArtPiece"}) exitWith {hint "Artillery Request Cancelled";(_this select 0) setVariable ["HALArtPos",nil,true];{deleteMarkerLocal _x} forEach _reqArtyMarks;};

	if (not (visibleMap)) exitWith {hint "Artillery Request Cancelled";(_this select 0) setVariable ["HALArtPiece",nil,true];(_this select 0) setVariable ["HALArtPos",nil,true];{deleteMarkerLocal _x} forEach _reqArtyMarks;};

	if (((_this select 0) getVariable "HALArtPiece") isEqualTo 0) exitWith {hint "Artillery Request Cancelled";(_this select 0) setVariable ["HALArtPiece",nil,true];(_this select 0) setVariable ["HALArtPos",nil,true];{deleteMarkerLocal _x} forEach _reqArtyMarks;};

	{
		if ((_x select 0) isEqualTo ((_this select 0) getVariable "HALArtPiece")) exitWith {_selectedPiece = (_x select 1);(_this select 0) setVariable ["HALArtPiece",nil,true];};

	} forEach _ArtyOptions;

	{deleteMarkerLocal _x} forEach _reqArtyMarks;

	_ArtyMenuOrd = [["Ordnance Options",false]];
	_OrdOptions = [];
	_selectedOrd = "";


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

	} forEach RydHQ_OtherArty;

	if ((count _ArtyMenuOrd) == 1) then {_OrdOptions = [[1,"HE"]];_ArtyMenuOrd pushBack ["High Explosive", [((count _ArtyMenuOrd) + 1)] , "", -5, [["expression", "player setvariable ['HALArtord',1,true]"]], "1", "1"];};

	_ArtyMenuOrd pushBack ["Cancel Fire Mission", [((count _ArtyMenuOrd) + 1)] , "", -5, [["expression", "player setvariable ['HALArtord',0,true]"]], "1", "1"];

	showCommandingMenu "#USER:_ArtyMenuOrd";

	waitUntil {sleep 0.2; (not (isNil {(_this select 0) getVariable "HALArtord"}) or not (alive (_this select 0)) or not ((_this select 0) == (leader (group (_this select 0)))) or not (visibleMap) or not (commandingMenu == "#USER:_ArtyMenuOrd"))};

	if (isNil {(_this select 0) getVariable "HALArtord"}) exitWith {hint "Artillery Request Cancelled";(_this select 0) setVariable ["HALArtPos",nil,true];(_this select 0) setVariable ["HALArtPiece",nil,true]};

	if (not (visibleMap)) exitWith {hint "Artillery Request Cancelled";(_this select 0) setVariable ["HALArtord",nil,true];(_this select 0) setVariable ["HALArtPiece",nil,true];(_this select 0) setVariable ["HALArtPos",nil,true]};

	if (((_this select 0) getVariable "HALArtord") isEqualTo 0) exitWith {hint "Artillery Request Cancelled";(_this select 0) setVariable ["HALArtord",nil,true];(_this select 0) setVariable ["HALArtPiece",nil,true];(_this select 0) setVariable ["HALArtPos",nil,true]};

	{
		if ((_x select 0) isEqualTo ((_this select 0) getVariable "HALArtord")) exitWith {_selectedOrd = (_x select 1);(_this select 0) setVariable ["HALArtord",nil,true];};

	} forEach _OrdOptions;
	

	_ArtyMenuAmnt = [["Ordnance Strength",false]];

	{

	_ArtyMenuAmnt pushBack [(str _x), [((count _ArtyMenuAmnt) + 1)] , "", -5, [["expression", "player setvariable ['HALArtAmnt'," + (str _x) +",true]"]], "1", "1"];

	} forEach [1,2,3,4,5,6,7,8,9];

	_ArtyMenuAmnt pushBack ["Cancel Fire Mission", [((count _ArtyMenuAmnt) + 1)] , "", -5, [["expression", "player setvariable ['HALArtAmnt',0,true]"]], "1", "1"];

	showCommandingMenu "#USER:_ArtyMenuAmnt";

	waitUntil {sleep 0.2; (not (isNil {((_this select 0) getVariable "HALArtAmnt")}) or not (alive (_this select 0)) or not ((_this select 0) == (leader (group (_this select 0)))) or not (visibleMap) or not (commandingMenu == "#USER:_ArtyMenuAmnt"))};

	if (isNil {(_this select 0) getVariable "HALArtAmnt"}) exitWith {hint "Artillery Request Cancelled";(_this select 0) setVariable ["HALArtPos",nil,true];(_this select 0) setVariable ["HALArtord",nil,true];(_this select 0) setVariable ["HALArtPiece",nil,true]};

	if (not (visibleMap)) exitWith {hint "Artillery Request Cancelled";(_this select 0) setVariable ["HALArtAmnt",nil,true];(_this select 0) setVariable ["HALArtord",nil,true];(_this select 0) setVariable ["HALArtPiece",nil,true];(_this select 0) setVariable ["HALArtPos",nil,true]};

	if (((_this select 0) getVariable "HALArtAmnt") == 0) exitWith {hint "Artillery Request Cancelled";(_this select 0) setVariable ["HALArtAmnt",nil,true];(_this select 0) setVariable ["HALArtord",nil,true];(_this select 0) setVariable ["HALArtPiece",nil,true];(_this select 0) setVariable ["HALArtPos",nil,true]};



	[(_this select 0), "Command, requesting fire support at GRID: " + (mapGridPosition ((_this select 0) getVariable ["HALArtPos",nil])) + " - Over"] remoteExecCall ["RYD_MP_Sidechat"];

	[_HQ,(_this select 0),(_this select 0) getVariable ["HALArtPos",nil],_selectedPiece,_selectedOrd,(_this select 0) getVariable ["HALArtAmnt",nil]] remoteExec ["hal_tasking_fnc_actionArt2ct",2];


	(_this select 0) setVariable ["HALArtAmnt",nil,true];
	(_this select 0) setVariable ["HALArtord",nil,true];
	(_this select 0) setVariable ["HALArtPiece",nil,true];
//	(_this select 0) setvariable ["HALArtPos",nil,true];
