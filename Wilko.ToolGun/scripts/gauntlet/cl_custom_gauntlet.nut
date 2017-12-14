
#if CLIENT

void function CustomGauntlet_Client_Init()
{
	RegisterButtonPressedCallback( KEY_BACKSLASH, KeyPress_TestGauntlet );

	CustomGauntlet.Tips.append( "#GAUNTLET_TIP_0" );
	CustomGauntlet.Tips.append( "#GAUNTLET_TIP_1" );
	CustomGauntlet.Tips.append( "#GAUNTLET_TIP_2" );
	CustomGauntlet.Tips.append( "#GAUNTLET_TIP_3" );
	CustomGauntlet.Tips.append( "#GAUNTLET_TIP_4" );
	CustomGauntlet.Tips.append( "#GAUNTLET_TIP_5" );
	CustomGauntlet.Tips.append( "#GAUNTLET_TIP_6" );
	CustomGauntlet.Tips.append( "#GAUNTLET_TIP_7" );
	CustomGauntlet.Tips.append( "#GAUNTLET_TIP_8" );
	CustomGauntlet.Tips.append( "#GAUNTLET_TIP_9" );
	CustomGauntlet.Tips.randomize();

	thread CustomGauntlet_Client_Think();
}

void function CustomGauntlet_Client_Think()
{
	while( true )
	{
		WaitFrame()
	}
}

// -----------------------------------------------------------------------------

void function CustomGauntlet_PlaceStartLine( vector Pos, vector Ang )
{
	CustomGauntlet.StartPoint.Location = Pos;
	CustomGauntlet.StartPoint.Rotation = Pos;

	CustomGauntlet_DestroyStartLine();

	CustomGauntlet.StartDisplayTopology = CustomGauntlet_CreateCentredTopology( Pos, Ang, 60, 30 );
	CustomGauntlet.StartDisplayRui = RuiCreate( $"ui/gauntlet_starting_line.rpak", CustomGauntlet.StartDisplayTopology, RUI_DRAW_WORLD, 0 )
	RuiSetString( CustomGauntlet.StartDisplayRui, "displayText", "#GAUNTLET_START_TEXT" );

	CustomGauntlet_SendEntityToServer( "start_point", Pos, Ang );
}

void function CustomGauntlet_PlaceFinishLine( vector Pos, vector Ang )
{
	CustomGauntlet.FinishPoint.Location = Pos;
	CustomGauntlet.FinishPoint.Rotation = Pos;

	CustomGauntlet_DestroyFinishLine();

	CustomGauntlet.FinishDisplayTopology = CustomGauntlet_CreateCentredTopology( Pos, Ang, 60, 30 );
	CustomGauntlet.FinishDisplayRui = RuiCreate( $"ui/gauntlet_starting_line.rpak", CustomGauntlet.FinishDisplayTopology, RUI_DRAW_WORLD, 0 )
	RuiSetString( CustomGauntlet.FinishDisplayRui, "displayText", "#GAUNTLET_FINISH_TEXT" );

	CustomGauntlet_SendEntityToServer( "finish_point", Pos, Ang );
}

void function CustomGauntlet_PlaceTarget( vector Pos, vector Ang )
{
	WorldPoint TargetPoint;
	TargetPoint.Location = Pos;
	TargetPoint.Rotation = Ang;
	CustomGauntlet.TargetPoints.append( TargetPoint );

	var TargetTopology = CustomGauntlet_CreateCentredTopology( Pos, Ang, 60, 30 );
	var TargetRui = RuiCreate( $"ui/gauntlet_starting_line.rpak", TargetTopology, RUI_DRAW_WORLD, 0 )
	RuiSetString( TargetRui, "displayText", "Target" );
	CustomGauntlet.TargetRuis.append( TargetRui );

	CustomGauntlet_SendEntityToServer( "target", Pos, Ang );
}

var function CustomGauntlet_CreateCentredTopology( vector Pos, vector Ang, float Width = 60, float Height = 30 )
{
	// adjust so the RUI is drawn with the org as its center point
	Pos += ( (AnglesToRight( Ang )*-1) * (Width*0.5) );
	Pos += ( AnglesToUp( Ang ) * (Height*0.5) );

	// right and down vectors that get added to base org to create the display size
	vector right = ( AnglesToRight( Ang ) * Width );
	vector down = ( (AnglesToUp( Ang )*-1) * Height );
	return RuiTopology_CreatePlane( Pos, right, down, true );
}

void function CustomGauntlet_DestroyStartLine()
{
	if( CustomGauntlet.StartDisplayRui != null )
	{
		RuiDestroyIfAlive( CustomGauntlet.StartDisplayRui );
		CustomGauntlet.StartDisplayRui = null;
	}
}

void function CustomGauntlet_DestroyFinishLine()
{
	if( CustomGauntlet.FinishDisplayRui != null )
	{
		RuiDestroyIfAlive( CustomGauntlet.FinishDisplayRui );
		CustomGauntlet.FinishDisplayRui = null;
	}
}

void function KeyPress_TestGauntlet( var button )
{
	CustomGauntlet.IsActive = !CustomGauntlet.IsActive;
	GetLocalClientPlayer().ClientCommand( "CustomGauntlet_DevToggleActive " + (CustomGauntlet.IsActive ? 1 : 0) );
}

// -----------------------------------------------------------------------------

void function CustomGauntlet_PlaceLeaderboard( vector Pos, vector Ang )
{
	if( CustomGauntlet.LeaderboardRui != null )
	{
		RuiDestroyIfAlive( CustomGauntlet.LeaderboardRui );
	}

	CustomGauntlet.LeaderboardPoint.Location = Pos;
	CustomGauntlet.LeaderboardPoint.Rotation = Ang;

	float Size = 120.0;
	CustomGauntlet.LeaderboardTopology = CustomGauntlet_CreateCentredTopology( Pos, Ang, Size, Size );
	CustomGauntlet.LeaderboardRui = RuiCreate( $"ui/gauntlet_leaderboard.rpak", CustomGauntlet.LeaderboardTopology, RUI_DRAW_WORLD, 0 )

	for(int i = 0; i < GAUNTLET_LEADERBOARD_MAX_ENTRIES; ++i)
	{
		CustomGauntlet_SetLeaderboardEntry( i, "Person " + i, i * 10.0, i == 3 );
	}

	CustomGauntlet_SendEntityToServer( "leaderboard", Pos, Ang );
}

void function CustomGauntlet_SetLeaderboardEntry( int leaderboardIdx, string name, float time, bool highlight )
{
	string nameArg = "entry" + leaderboardIdx + "Name";
	string timeArg = "entry" + leaderboardIdx + "Time";

	RuiSetString( CustomGauntlet.LeaderboardRui, nameArg, name );
	RuiSetFloat( CustomGauntlet.LeaderboardRui, timeArg, time );

	if ( highlight )
	{
		RuiSetInt( CustomGauntlet.LeaderboardRui, "highlightNameIdx", leaderboardIdx );
	}
}

// -----------------------------------------------------------------------------

void function CustomGauntlet_PlaceResults( vector Pos, vector Ang )
{
	if( CustomGauntlet.ResultsRui != null )
	{
		RuiDestroyIfAlive( CustomGauntlet.ResultsRui );
		CustomGauntlet.ResultsRui = null;
	}

	CustomGauntlet.ResultsPoint.Location = Pos;
	CustomGauntlet.ResultsPoint.Rotation = Ang;

	float Size = 120.0;
	CustomGauntlet.ResultsTopology = CustomGauntlet_CreateCentredTopology( Pos, Ang, Size, Size * 0.6 );
	CustomGauntlet.ResultsRui = RuiCreate( $"ui/gauntlet_results_display.rpak", CustomGauntlet.ResultsTopology, RUI_DRAW_WORLD, 0 );

	CustomGauntlet_SendEntityToServer( "results", Pos, Ang );
}

// -----------------------------------------------------------------------------

void function ServerCallback_Gauntlet_StartRun()
{
	if( CustomGauntlet.SplashRui != null && IsValid( CustomGauntlet.SplashRui ) )
	{
		RuiDestroyIfAlive( CustomGauntlet.SplashRui );
		CustomGauntlet.SplashRui = null;
	}
	var splashRUI = RuiCreate( $"ui/gauntlet_splash.rpak", clGlobal.topoCockpitHud, RUI_DRAW_COCKPIT, 0 );
	RuiSetFloat( splashRUI, "duration", 1.8 );
	RuiSetString( splashRUI, "message", "#GAUNTLET_START_TEXT");
	CustomGauntlet.SplashRui = splashRUI;

	CustomGauntlet.StartTime = Time();
	CustomGauntlet_CreatePlayerHUD();

	if( CustomGauntlet.ResultsRui != null )
	{
		RuiSetBool( CustomGauntlet.ResultsRui, "runFinished", false );
		RuiSetGameTime( CustomGauntlet.ResultsRui, "startTime", Time() );
	}

}

void function ServerCallback_Gauntlet_FinishRun( float RunTime, float BestRunTime, float MissedEnemiesPenalty, int TotalEnemies, int EnemiesKilled )
{
	if( CustomGauntlet.SplashRui != null && IsValid( CustomGauntlet.SplashRui ) )
	{
		RuiDestroyIfAlive( CustomGauntlet.SplashRui );
		CustomGauntlet.SplashRui = null;
	}
	var splashRUI = RuiCreate( $"ui/gauntlet_splash.rpak", clGlobal.topoCockpitHud, RUI_DRAW_COCKPIT, 0 );
	RuiSetFloat( splashRUI, "duration", 1.8 );
	RuiSetString( splashRUI, "message", "#GAUNTLET_FINISH_TEXT");
	CustomGauntlet.SplashRui = splashRUI;

	CustomGauntlet.LastRunTime = RunTime;
	CustomGauntlet.BestRunTime = BestRunTime;

	if( CustomGauntlet.ResultsRui != null )
	{
		RuiSetBool( CustomGauntlet.ResultsRui, "runFinished", true );
		RuiSetFloat( CustomGauntlet.ResultsRui, "finalTime", RunTime );
		RuiSetFloat( CustomGauntlet.ResultsRui, "bestTime", BestRunTime );
		RuiSetFloat( CustomGauntlet.ResultsRui, "enemiesMissedTimePenalty", MissedEnemiesPenalty );
		RuiSetInt( CustomGauntlet.ResultsRui, "numEnemies", TotalEnemies );
		RuiSetInt( CustomGauntlet.ResultsRui, "enemiesKilled", EnemiesKilled );

		CustomGauntlet.TipIdx++;
		if ( CustomGauntlet.TipIdx >= CustomGauntlet.Tips.len() )
		{
			CustomGauntlet.TipIdx = 0;
		}
		RuiSetString( CustomGauntlet.ResultsRui, "tipString", CustomGauntlet.Tips[CustomGauntlet.TipIdx] );
		RuiSetGameTime( CustomGauntlet.ResultsRui, "tipResetTime", Time() );
	}

	thread CustomGauntlet_FinishRun_PlayerHUD_Think( RunTime, BestRunTime, MissedEnemiesPenalty );
}

void function ServerCallback_Gauntlet_UpdateEnemiesKilled( int TotalEnemies, int EnemiesKilled )
{
	if( CustomGauntlet.ResultsRui != null )
	{
		RuiSetInt( CustomGauntlet.ResultsRui, "numEnemies", TotalEnemies );
		RuiSetInt( CustomGauntlet.ResultsRui, "enemiesKilled", EnemiesKilled );
	}
}

// -----------------------------------------------------------------------------

void function CustomGauntlet_SendEntityToServer( string Type, vector Pos, vector Ang )
{
	GetLocalClientPlayer().ClientCommand( "CustomGauntlet_PlaceEntity " + Type + " " + Pos.x + " " + Pos.y + " " + Pos.z + " " + Ang.x + " " + Ang.y + " " + Ang.z );
}

#endif
