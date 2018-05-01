
#if CLIENT

void function CustomGauntlet_UpdateStatBoards( GauntletTrack Track, bool Finished, float FinalTime, float BestTime, float MissedTargetsPenalty, int NumTargets, int KilledTargets )
{
	for( int i = Track.StatsBoards.len() - 1; i >= 0; --i )
	{
		GauntletWorldUI CurrentUI = Track.StatsBoards[i];

		RuiSetBool( CurrentUI.Rui, "runFinished", Finished );
		RuiSetFloat( CurrentUI.Rui, "finalTime", FinalTime );
		RuiSetFloat( CurrentUI.Rui, "bestTime", BestTime );
		RuiSetFloat( CurrentUI.Rui, "enemiesMissedTimePenalty", MissedTargetsPenalty );
		RuiSetInt( CurrentUI.Rui, "numEnemies", NumTargets );
		RuiSetInt( CurrentUI.Rui, "enemiesKilled", KilledTargets );
	}
}

void function CustomGauntlet_RandomizeStatBoardTips( GauntletTrack Track )
{
	for( int i = Track.StatsBoards.len() - 1; i >= 0; --i )
	{
		GauntletWorldUI CurrentUI = Track.StatsBoards[i];

		if( Track.Tips.len() > 0 )
		{
			// Actual game uses the same for all boards to keep the loop illusion, but we'll just randomize all of them
			int RandIdx = RandomIntRange( 0, Track.Tips.len() - 1 );
			RuiSetString( CurrentUI.Rui, "tipString", Track.Tips[RandIdx] );
			RuiSetGameTime( CurrentUI.Rui, "tipResetTime", Time() );
		}
		else
		{
			RuiSetString( CurrentUI.Rui, "tipString", "No tips for gauntlet '" + Track.TrackName + "'" );
			RuiSetGameTime( CurrentUI.Rui, "tipResetTime", Time() );
		}
	}
}

void function CustomGauntlet_SetStatsBoardFloat( GauntletTrack Track, string ValueName, float Value )
{
	for( int i = Track.StatsBoards.len() - 1; i >= 0; --i )
	{
		GauntletWorldUI CurrentUI = Track.StatsBoards[i];
		RuiSetFloat( CurrentUI.Rui, ValueName, Value );
	}
}

void function CustomGauntlet_SetStatsBoardInt( GauntletTrack Track, string ValueName, int Value )
{
	for( int i = Track.StatsBoards.len() - 1; i >= 0; --i )
	{
		GauntletWorldUI CurrentUI = Track.StatsBoards[i];
		RuiSetInt( CurrentUI.Rui, ValueName, Value );
	}
}

#endif
