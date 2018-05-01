
#if CLIENT

void function CustomGauntlet_AddLeaderboardTime( GauntletTrack Track, float FinalTime, string PlayerName )
{
	// Find where to put the highscore
	int InsertIdx = -1;

	if( Track.Highscores.len() < 1 )
	{
		InsertIdx = 0;
	}

	for( int i = 0; i < Track.Highscores.len(); ++i )
	{
		if( FinalTime < Track.Highscores[i].Time )
		{
			InsertIdx = i;
			break;
		}
	}

	if( InsertIdx > -1 )
	{
		// Insert the highscore
		GauntletHighscore NewHighscore;
		NewHighscore.Time = FinalTime;
		NewHighscore.Name = PlayerName;
		Track.Highscores.insert( InsertIdx, NewHighscore );

		// Update connected leaderboards
		CustomGauntlet_UpdateLeaderboards( Track );
	}
}

void function CustomGauntlet_UpdateLeaderboards( GauntletTrack Track )
{
	for( int i = Track.Scoreboards.len() - 1; i >= 0; --i )
	{
		GauntletWorldUI CurrentUI = Track.Scoreboards[i];

		for( int entry = 0; entry < Track.Highscores.len(); entry++ )
		{
			string nameArg = "entry" + entry + "Name";
			string timeArg = "entry" + entry + "Time";
			RuiSetString( CurrentUI.Rui, nameArg, Track.Highscores[entry].Name );
			RuiSetFloat( CurrentUI.Rui, timeArg, Track.Highscores[entry].Time );
		}

	}

	// RuiSetInt( CustomGauntlet.LeaderboardRui, "highlightNameIdx", leaderboardIdx );
}

#endif
