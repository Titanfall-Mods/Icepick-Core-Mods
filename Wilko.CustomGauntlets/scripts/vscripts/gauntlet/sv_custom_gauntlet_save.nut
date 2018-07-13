
global function CustomGauntlet_Server_SaveInit

void function CustomGauntlet_Server_SaveInit()
{
	AddOnIcepickSaveCallback( OnIcepickSave );
}

// Add custom gauntlet entities when creating a save
void function OnIcepickSave()
{
	AddSaveItem( IcepickSaveOutput( "gauntlet.id", CustomGauntletsGlobal.DevelopmentTrack.Id ) );
	AddSaveItem( IcepickSaveOutput( "gauntlet.name", CustomGauntletsGlobal.DevelopmentTrack.TrackName ) );

	for( int i = 0; i < CustomGauntletsGlobal.DevelopmentTrack.Tips.len(); ++i )
	{
		AddSaveItem( IcepickSaveOutput( "gauntlet.tip", CustomGauntletsGlobal.DevelopmentTrack.Tips[i] ) );
	}

	for( int i = 0; i < CustomGauntletsGlobal.DevelopmentTrack.Highscores.len(); ++i )
	{
		GauntletHighscore highscore = CustomGauntletsGlobal.DevelopmentTrack.Highscores[i];
		AddSaveItem( IcepickSaveOutput( "gauntlet.highscore", highscore.Name, highscore.Time ) );
	}

	if( CustomGauntletsGlobal.DevelopmentTrack.StartLine.IsValid )
	{
		vector start = CustomGauntletsGlobal.DevelopmentTrack.StartLine.From;
		vector end = CustomGauntletsGlobal.DevelopmentTrack.StartLine.To;
		string entry = IcepickSaveOutput( "gauntlet.start", start.x, start.y, start.z, end.x, end.y, end.z );
		AddSaveItem( entry );
	}

	if( CustomGauntletsGlobal.DevelopmentTrack.FinishLine.IsValid )
	{
		vector start = CustomGauntletsGlobal.DevelopmentTrack.FinishLine.From;
		vector end = CustomGauntletsGlobal.DevelopmentTrack.FinishLine.To;
		string entry = IcepickSaveOutput( "gauntlet.end", start.x, start.y, start.z, end.x, end.y, end.z );
		AddSaveItem( entry );
	}

	for( int i = 0; i < CustomGauntletsGlobal.DevelopmentTrack.Targets.len(); ++i )
	{
		string enemyType = CustomGauntletsGlobal.DevelopmentTrack.Targets[i].EnemyType;
		vector pos = CustomGauntletsGlobal.DevelopmentTrack.Targets[i].Position;
		vector rot = CustomGauntletsGlobal.DevelopmentTrack.Targets[i].Rotation;
		string entry = IcepickSaveOutput( "gauntlet.target", enemyType, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z );
		AddSaveItem( entry );
	}

	for( int i = 0; i < CustomGauntletsGlobal.DevelopmentTrack.Scoreboards.len(); ++i )
	{
		GauntletWorldUI worldUi = CustomGauntletsGlobal.DevelopmentTrack.Scoreboards[i];
		vector pos = worldUi.Position;
		vector rot = worldUi.Rotation;
		AddSaveItem( IcepickSaveOutput( "gauntlet.scoreboard", worldUi.UIType, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z ) );
	}

	for( int i = 0; i < CustomGauntletsGlobal.DevelopmentTrack.StatsBoards.len(); ++i )
	{
		GauntletWorldUI worldUi = CustomGauntletsGlobal.DevelopmentTrack.StatsBoards[i];
		vector pos = worldUi.Position;
		vector rot = worldUi.Rotation;
		AddSaveItem( IcepickSaveOutput( "gauntlet.statsboard", worldUi.UIType, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z ) );
	}
}
