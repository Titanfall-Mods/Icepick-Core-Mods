
#if CLIENT

void function CustomGauntlet_Client_Init()
{
	RegisterButtonPressedCallback( KEY_BACKSLASH, KeyPress_TestGauntlet );

	thread CustomGauntlet_Client_Think();
}

void function CustomGauntlet_UI_Init()
{
	var rui = RuiCreate( $"ui/cockpit_console_text_top_right.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, 0 );
	RuiSetInt( rui, "maxLines", 1 );
	RuiSetInt( rui, "lineNum", 1 );
	RuiSetFloat2( rui, "msgPos", <0.95, 0.05, 0.0> );
	RuiSetString( rui, "msgText", "Gauntlet Active" );
	RuiSetFloat( rui, "msgFontSize", 48.0 );
	RuiSetFloat( rui, "msgAlpha", 0.9 );
	RuiSetFloat( rui, "thicken", 0.0 );
	RuiSetFloat3( rui, "msgColor", <1.0, 1.0, 1.0> );
	CustomGauntlet.IsActiveRui = rui;
}

void function CustomGauntlet_Client_Think()
{
	while( true )
	{

		if( CustomGauntlet.IsActive )
		{
			entity player = GetLocalClientPlayer();

			float DistanceToStart = Length( player.GetOrigin() - CustomGauntlet.StartPoint.Location );
			if( DistanceToStart < 100 )
			{
				CustomGauntlet_Start();
			}

			float DistanceToFinish = Length( player.GetOrigin() - CustomGauntlet.FinishPoint.Location );
			if( DistanceToFinish < 100 )
			{
				CustomGauntlet_Finish();
			}
		}

		if( CustomGauntlet.IsActiveRui != null )
		{
			if( CustomGauntlet.IsActive )
				RuiSetFloat( CustomGauntlet.IsActiveRui, "msgAlpha", 0.9 );
			else
				RuiSetFloat( CustomGauntlet.IsActiveRui, "msgAlpha", 0.0 );
		}

		WaitFrame()
	}
}

void function CustomGauntlet_Start_Client()
{
	var splashRUI = RuiCreate( $"ui/gauntlet_splash.rpak", clGlobal.topoCockpitHud, RUI_DRAW_COCKPIT, 0 )
	RuiSetFloat( splashRUI, "duration", 1.8 )
	RuiSetString( splashRUI, "message", "#GAUNTLET_START_TEXT")

	// Network to the server
	GetLocalClientPlayer().ClientCommand( "CustomGauntlet_Start" );
}

void function CustomGauntlet_Finish_Client()
{
	var splashRUI = RuiCreate( $"ui/gauntlet_splash.rpak", clGlobal.topoCockpitHud, RUI_DRAW_COCKPIT, 0 )
	RuiSetFloat( splashRUI, "duration", 1.8 )
	RuiSetString( splashRUI, "message", "#GAUNTLET_FINISH_TEXT")

	// Network to the server
	GetLocalClientPlayer().ClientCommand( "CustomGauntlet_Finish" );
}

void function CustomGauntlet_PlaceStartLine( vector Pos, vector Ang )
{
	CustomGauntlet.StartPoint.Location = Pos;
	CustomGauntlet.StartPoint.Rotation = Pos;

	CustomGauntlet_DestroyStartLine();

	CustomGauntlet.StartDisplayTopology = CustomGauntlet_CreateCentredTopology( Pos, Ang, 60, 30 );
	CustomGauntlet.StartDisplayRui = RuiCreate( $"ui/gauntlet_starting_line.rpak", CustomGauntlet.StartDisplayTopology, RUI_DRAW_WORLD, 0 )
	RuiSetString( CustomGauntlet.StartDisplayRui, "displayText", "#GAUNTLET_START_TEXT" );
}

void function CustomGauntlet_PlaceFinishLine( vector Pos, vector Ang )
{
	CustomGauntlet.FinishPoint.Location = Pos;
	CustomGauntlet.FinishPoint.Rotation = Pos;

	CustomGauntlet_DestroyFinishLine();

	CustomGauntlet.FinishDisplayTopology = CustomGauntlet_CreateCentredTopology( Pos, Ang, 60, 30 );
	CustomGauntlet.FinishDisplayRui = RuiCreate( $"ui/gauntlet_starting_line.rpak", CustomGauntlet.FinishDisplayTopology, RUI_DRAW_WORLD, 0 )
	RuiSetString( CustomGauntlet.FinishDisplayRui, "displayText", "#GAUNTLET_FINISH_TEXT" );
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

	GetLocalClientPlayer().ClientCommand( "CustomGauntlet_AddTarget " + Pos.x + " " + Pos.y + " " + Pos.z + " " + Ang.x + " " + Ang.y + " " + Ang.z );
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
	CustomGauntlet_Reset();
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
	}

	CustomGauntlet.ResultsPoint.Location = Pos;
	CustomGauntlet.ResultsPoint.Rotation = Ang;

	float Size = 120.0;
	CustomGauntlet.ResultsTopology = CustomGauntlet_CreateCentredTopology( Pos, Ang, Size, Size * 0.6 );
	CustomGauntlet.ResultsRui = RuiCreate( $"ui/gauntlet_results_display.rpak", CustomGauntlet.ResultsTopology, RUI_DRAW_WORLD, 0 )

	RuiSetInt( CustomGauntlet.ResultsRui, "numEnemies", 10 )
	RuiSetInt( CustomGauntlet.ResultsRui, "enemiesKilled", 6 )
}

#endif
