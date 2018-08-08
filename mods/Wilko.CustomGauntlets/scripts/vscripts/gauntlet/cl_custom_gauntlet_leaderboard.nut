untyped

global function CustomGauntlet_UpdateLeaderboards

void function CustomGauntlet_UpdateLeaderboards( GauntletTrack Track )
{
	for( int i = Track.Scoreboards.len() - 1; i >= 0; --i )
	{
		GauntletWorldUI CurrentUI = Track.Scoreboards[i];
		int max = Track.Highscores.len() > CUSTOM_GAUNTLET_LEADERBOARD_MAX_ENTRIES ? CUSTOM_GAUNTLET_LEADERBOARD_MAX_ENTRIES : Track.Highscores.len();
		for( int entry = 0; entry < max; entry++ )
		{
			string nameArg = "entry" + entry + "Name";
			string timeArg = "entry" + entry + "Time";
			RuiSetString( CurrentUI.Rui, nameArg, Track.Highscores[entry].Name );
			RuiSetFloat( CurrentUI.Rui, timeArg, Track.Highscores[entry].Time );
		}

	}

	// RuiSetInt( CustomGauntlet.LeaderboardRui, "highlightNameIdx", leaderboardIdx );
}
