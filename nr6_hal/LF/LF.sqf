switch (RydxHQ_LFActive) do
	{
	case (false) : 
		{
		RydxHQ_LFActive = true;
		_this spawn hal_hac_fnc_LF_Loop
		};
		
	case (true) : {RydxHQ_LFActive = false};
	};
