
#if CLIENT

void function CustomGauntlet_Client_Init()
{
	RegisterButtonPressedCallback( KEY_HOME, KeyPress_CustomGauntlet_ToggleEditMode );

	thread CustomGauntlet_Think_Topology();
}

void function ServerCallback_CustomGauntlet_SendScoreboardEnt( var EntHandle )
{
	entity RefEnt = GetEntityFromEncodedEHandle( EntHandle );
	if( IsValid( RefEnt ) )
	{
		GauntletWorldUI NewScoreboard;
		NewScoreboard.UIType = GauntletWorldUIType.Scoreboard;
		NewScoreboard.Position = RefEnt.GetOrigin();
		NewScoreboard.Rotation = RefEnt.GetAngles();
		NewScoreboard.ReferenceEnt = RefEnt;
		CustomGauntletsGlobal.DevelopmentTrack.Scoreboards.append( NewScoreboard );
	}
	else
	{
		print("[Error] Received an invalid scoreboard entity handle from the server!");
	}
}

void function ServerCallback_CustomGauntlet_SendStatsBoardEnt( var EntHandle )
{
	entity RefEnt = GetEntityFromEncodedEHandle( EntHandle );
	if( IsValid( RefEnt ) )
	{
		GauntletWorldUI NewStatsBoard;
		NewStatsBoard.UIType = GauntletWorldUIType.StatsBoard;
		NewStatsBoard.Position = RefEnt.GetOrigin();
		NewStatsBoard.Rotation = RefEnt.GetAngles();
		NewStatsBoard.ReferenceEnt = RefEnt;
		CustomGauntletsGlobal.DevelopmentTrack.StatsBoards.append( NewStatsBoard );
	}
	else
	{
		print("[Error] Received an invalid stats board entity handle from the server!");
	}
}

void function ServerCallback_CustomGauntlet_ShowError( int ErrorIdx )
{
	switch ( ErrorIdx )
	{
		case 1:
			CustomGauntlet_ShowError( "Remove the existing start line to place a new one!" );
			break;
		case 2:
			CustomGauntlet_ShowError( "Remove the existing finish line to place a new one!" );
			break;
	}
}

void function CustomGauntlet_ShowError( string Message )
{
	SmartAmmo_SetStatusWarning( Message, 2.0 );
}

void function KeyPress_CustomGauntlet_ToggleEditMode( var button )
{
	CustomGauntletsGlobal.EditModeActive = !CustomGauntletsGlobal.EditModeActive;
	string ActiveStr = CustomGauntletsGlobal.EditModeActive ? "1" : "0";
	GetLocalClientPlayer().ClientCommand( "CustomGauntlet_SetEditMode " + ActiveStr );
}

#endif
