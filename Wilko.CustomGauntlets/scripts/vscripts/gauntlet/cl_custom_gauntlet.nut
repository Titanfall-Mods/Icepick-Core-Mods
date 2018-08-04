untyped

global function CustomGauntlet_Client_Init
global function ServerCallback_CustomGauntlet_Start;
global function ServerCallback_CustomGauntlet_Finish;
global function ServerCallback_CustomGauntlet_SendScoreboardTime;
global function ServerCallback_CustomGauntlet_ShowError;
global function ServerCallback_CustomGauntlet_SendScoreboardEnt;
global function ServerCallback_CustomGauntlet_SendStatsBoardEnt;
global function ServerCallback_CustomGauntlet_RefreshWorldTopos;
global function CustomGauntlet_DoTopologiesNeedRefreshing;

global struct GauntletRuntimeDataStruct
{
	bool IsActive,
	GauntletTrack & ActiveTrack,
};

struct
{
	float timeSinceTopologiesRefresh
} file;

global GauntletRuntimeDataStruct GauntletRuntimeData;

void function CustomGauntlet_Client_Init()
{
	AddOnEditModeChangedCallback( OnToolgunEditModeChanged );

	thread CustomGauntlet_Think_Topology();
}

void function ServerCallback_CustomGauntlet_SendScoreboardEnt( var EntHandle )
{
	entity RefEnt = GetEntityFromEncodedEHandle( EntHandle );
	if( IsValid( RefEnt ) )
	{
		GauntletWorldUI NewScoreboard;
		NewScoreboard.UIType = GauntletWorldUIType.Scoreboard;
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

// -----------------------------------------------------------------------------

void function ServerCallback_CustomGauntlet_Start()
{
	GauntletRuntimeData.IsActive = true;
	GauntletRuntimeData.ActiveTrack = CustomGauntletsGlobal.DevelopmentTrack;
	
	thread CustomGauntlet_DoGauntletSplash( "#GAUNTLET_START_TEXT" );
	CustomGauntlet_UI_CreatePlayerHud();
	thread CustomGauntlet_TrackPlayerSpeed();
}

void function ServerCallback_CustomGauntlet_Finish( float TotalTime, float BestTime, int TotalNumTargets, int NumTargetsMissed, float MissedTargetsPenalty )
{
	if( TotalTime > 0 )
	{
		thread CustomGauntlet_DoGauntletSplash( "#GAUNTLET_FINISH_TEXT" );
		thread CustomGauntlet_UI_EndOfRun( TotalTime, BestTime, MissedTargetsPenalty );

		int NumKilledTargets = TotalNumTargets - NumTargetsMissed;
		CustomGauntlet_UpdateStatBoards( GauntletRuntimeData.ActiveTrack, true, TotalTime, BestTime, MissedTargetsPenalty, TotalNumTargets, NumKilledTargets );
		CustomGauntlet_RandomizeStatBoardTips( GauntletRuntimeData.ActiveTrack );
		CustomGauntlet_AddLeaderboardTime( GauntletRuntimeData.ActiveTrack, TotalTime, GetLocalClientPlayer().GetPlayerName() );
	}
	else
	{
		CustomGauntlet_UI_RemovePlayerHud();
	}
	GauntletRuntimeData.IsActive = false;
}

void function ServerCallback_CustomGauntlet_SendScoreboardTime( float Time )
{
	CustomGauntlet_AddLeaderboardTime( CustomGauntletsGlobal.DevelopmentTrack, Time, "Pilot" );
}

void function OnToolgunEditModeChanged()
{
	CustomGauntletsGlobal.EditModeActive = ToolgunModeEnabled;
	string ActiveStr = CustomGauntletsGlobal.EditModeActive ? "1" : "0";
	GetLocalClientPlayer().ClientCommand( "CustomGauntlet_SetEditMode " + ActiveStr );
}

// -----------------------------------------------------------------------------

void function ServerCallback_CustomGauntlet_RefreshWorldTopos()
{
	file.timeSinceTopologiesRefresh = Time();
}

bool function CustomGauntlet_DoTopologiesNeedRefreshing()
{
	return Time() - file.timeSinceTopologiesRefresh < 1.0;
}

