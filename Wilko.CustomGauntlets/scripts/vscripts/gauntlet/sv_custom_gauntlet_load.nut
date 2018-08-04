
// @note: for now just load everything into development track until I work out how to go about differentiating dev and play tracks

global function CustomGauntlet_LoadInit

void function CustomGauntlet_LoadInit()
{
	AddOnHandleLoadTokenCallback( HandleLoadToken );
}

void function HandleLoadToken( string id, array<string> data )
{
	switch( id )
	{
		case "gauntlet.id":
			HandleLoadId( data );
			break;
		case "gauntlet.name":
			HandleLoadName( data );
			break;
		case "gauntlet.tip":
			HandleLoadTip( data );
			break;
		case "gauntlet.highscore":
			HandleLoadHighscore( data );
			break;
		case "gauntlet.start":
			HandleLoadStart( data );
			break;
		case "gauntlet.end":
			HandleLoadEnd( data );
			break;
		case "gauntlet.target":
			HandleLoadTarget( data );
			break;
		case "gauntlet.scoreboard":
			HandleLoadScoreboard( data );
			break;
		case "gauntlet.statsboard":
			HandleLoadStatsboard( data );
			break;
		case "gauntlet.weapon":
			HandleLoadWeapon( data );
			break;
	}
}

void function HandleLoadId( array<string> data )
{
	CleanupGauntlets(); // Clean up any existing gauntlet when loading a new one so we don't get two overlapping gauntlets
}

void function HandleLoadName( array<string> data )
{
}

void function HandleLoadTip( array<string> data )
{
}

void function HandleLoadHighscore( array<string> data )
{
	string name = data[0];
	float time = data[1].tofloat();
	CustomGauntlet_AddLeaderboardTime( CustomGauntletsGlobal.DevelopmentTrack, time, name );

	if( CustomGauntletsGlobal.DevelopmentTrack.BestTime < 0.0 || time < CustomGauntletsGlobal.DevelopmentTrack.BestTime )
	{
		CustomGauntletsGlobal.DevelopmentTrack.BestTime = time;
	}

	thread DelayTransmitScoreboardTime( time );
}

void function DelayTransmitScoreboardTime( float time )
{
	wait 3.0;
	Remote_CallFunction_Replay( GetPlayerByIndex( 0 ), "ServerCallback_CustomGauntlet_SendScoreboardTime", time );
}

void function HandleLoadStart( array<string> data )
{
	vector left = Vector( data[0].tofloat(), data[1].tofloat(), data[2].tofloat() );
	vector right = Vector( data[3].tofloat(), data[4].tofloat(), data[5].tofloat() );

	CustomGauntletsGlobal.DevelopmentTrack.StartLine.FromEnt = ToolGauntlet_CreateTriggerEntity( left, Vector( 0, 0, 0 ), 0.0 );
	CustomGauntletsGlobal.DevelopmentTrack.StartLine.ToEnt = ToolGauntlet_CreateTriggerEntity( right, Vector( 0, 0, 0 ), 0.0 );
}

void function HandleLoadEnd( array<string> data )
{
	vector left = Vector( data[0].tofloat(), data[1].tofloat(), data[2].tofloat() );
	vector right = Vector( data[3].tofloat(), data[4].tofloat(), data[5].tofloat() );

	CustomGauntletsGlobal.DevelopmentTrack.FinishLine.FromEnt = ToolGauntlet_CreateTriggerEntity( left, Vector( 0, 0, 0 ), 0.0 );
	CustomGauntletsGlobal.DevelopmentTrack.FinishLine.ToEnt = ToolGauntlet_CreateTriggerEntity( right, Vector( 0, 0, 0 ), 0.0 );
}

void function HandleLoadTarget( array<string> data )
{
	string targetType = data[0];
	vector position = Vector( data[1].tofloat(), data[2].tofloat(), data[3].tofloat() );
	vector angle = Vector( data[4].tofloat(), data[5].tofloat(), data[6].tofloat() );

	CustomGauntlets_SpawnTarget( targetType, position, angle );
}

void function HandleLoadScoreboard( array<string> data )
{
	vector position = Vector( data[0].tofloat(), data[1].tofloat(), data[2].tofloat() );
	vector angles = Vector( data[3].tofloat(), data[4].tofloat(), data[5].tofloat() );
	CustomGauntlets_SpawnLeaderboard( position, angles );
}

void function HandleLoadStatsboard( array<string> data )
{
	vector position = Vector( data[0].tofloat(), data[1].tofloat(), data[2].tofloat() );
	vector angles = Vector( data[3].tofloat(), data[4].tofloat(), data[5].tofloat() );
	CustomGauntlets_SpawnStatsboard( position, angles );
}

void function HandleLoadWeapon( array<string> data )
{
	string weaponClass = data[0];
	vector position = Vector( data[1].tofloat(), data[2].tofloat(), data[3].tofloat() );
	vector angle = Vector( data[4].tofloat(), data[5].tofloat(), data[6].tofloat() );
	CustomGauntlet_SpawnRespawningWeapon( weaponClass, position, angle );
}
