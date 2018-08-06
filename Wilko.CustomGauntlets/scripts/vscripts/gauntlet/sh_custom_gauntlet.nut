
global function CustomGauntlet_Shared_Init
global function CustomGauntlet_AddLeaderboardTime
global function ToolGauntlet_CreateTriggerEntity
global function ToolGauntlet_DelayedTransmit

global const CUSTOM_GAUNTLET_LEADERBOARD_MAX_ENTRIES = 10;

global struct GauntletTriggerLine
{
	entity left,
	entity right,
	float triggerHeight,

	var topo,
	var rui
};

global struct TargetEnemy
{
	vector Position,
	vector Rotation,
	string EnemyType,
	entity SpawnedEnemy
};

global struct GauntletWorldUI
{
	int UIType,
	var Topology,
	var Rui,
	entity ReferenceEnt
};

global struct GauntletWeapon
{
	string WeaponClass,
	float TimeToRespawn = -1.0,
	entity ReferenceEnt
};

global struct GauntletHighscore
{
	string Name,
	float Time
}

global struct GauntletTrack
{
	string Id = "",
	string TrackName = "Unnamed",

	array<GauntletTriggerLine> Starts,
	array<GauntletTriggerLine> Finishes,
	array<GauntletTriggerLine> Checkpoints,

	array<TargetEnemy> Targets,
	array<GauntletWorldUI> Scoreboards,
	array<GauntletWorldUI> StatsBoards,
	array<GauntletWeapon> RespawningWeapons,

	array<string> Tips = [ // Keep tips part of the track data so we can add custom ones
		"#GAUNTLET_TIP_0",
		"#GAUNTLET_TIP_1",
		"#GAUNTLET_TIP_2",
		"#GAUNTLET_TIP_3",
		"#GAUNTLET_TIP_4",
		"#GAUNTLET_TIP_5",
		"#GAUNTLET_TIP_6",
		"#GAUNTLET_TIP_7",
		"#GAUNTLET_TIP_8",
		"#GAUNTLET_TIP_9"
	],
	array<GauntletHighscore> Highscores,
	float BestTime = -1.0,
};

global struct CustomGauntletsGlobalStruct
{
	array<GauntletTrack> RegisteredTracks,
	GauntletTrack DevelopmentTrack,

	bool EditModeActive = true,
	GauntletTrack &ActiveTrack,

	bool HasStarted = false,
	bool HasFinished = false,
	
};

global CustomGauntletsGlobalStruct CustomGauntletsGlobal;

global enum GauntletWorldUIType
{
	Scoreboard,
	StatsBoard,
	MAX
}

global const vector TriggerLineOffset = < 0.0, 0.0, 46.0 >;

void function CustomGauntlet_Shared_Init()
{
#if SERVER
	CustomGauntlet_Server_Init();
#endif
#if CLIENT
	CustomGauntlet_Client_Init();
	CustomGauntlet_UI_Init();
#endif

	// Set development track valid
	CustomGauntletsGlobal.DevelopmentTrack.Id = RandomIntRange( 0, 99999 ).tostring();
	CustomGauntletsGlobal.DevelopmentTrack.TrackName = "Development Track";

	thread CustomGauntlet_Shared_Think();
}

void function CustomGauntlet_Shared_Think()
{
	while( true )
	{
		WaitFrame();
	}
}

// -----------------------------------------------------------------------------

void function CustomGauntlet_AddLeaderboardTime( GauntletTrack Track, float FinalTime, string PlayerName )
{
	// Find where to put the highscore
	int InsertIdx = -1;

	if( Track.Highscores.len() < 1 )
	{
		InsertIdx = 0;
	}
	else
	{
		for( int i = 0; i < Track.Highscores.len(); ++i )
		{
			if( FinalTime < Track.Highscores[i].Time )
			{
				InsertIdx = i;
				break;
			}
		}
	}

	// Didn't find a slower time, so check if we can just add it to the end
	if( InsertIdx == -1 && Track.Highscores.len() <= 10 )
	{
		InsertIdx = Track.Highscores.len();
	}

	if( InsertIdx > -1 )
	{
		// Insert the highscore
		GauntletHighscore NewHighscore;
		NewHighscore.Time = FinalTime;
		NewHighscore.Name = PlayerName;
		Track.Highscores.insert( InsertIdx, NewHighscore );

#if CLIENT
		// Update connected leaderboards
		CustomGauntlet_UpdateLeaderboards( Track );
#endif
	}
}

entity function ToolGauntlet_CreateTriggerEntity( vector Pos, vector Angles, float Offset, asset ModelAsset = $"models/weapons/titan_trip_wire/titan_trip_wire.mdl" )
{
#if SERVER
	EnableExternalSpawnMode();

	entity prop_dynamic = CreateEntity( "prop_dynamic" );
	prop_dynamic.SetValueForModelKey( ModelAsset );
	prop_dynamic.kv.fadedist = -1;
	prop_dynamic.kv.renderamt = 255;
	prop_dynamic.kv.rendercolor = "255 255 255";
	prop_dynamic.kv.solid = 6; // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
	SetTeam( prop_dynamic, TEAM_BOTH );	// need to have a team other then 0 or it won't take impact damage

	prop_dynamic.SetOrigin( Pos - AnglesToRight( Angles ) * Offset );
	prop_dynamic.SetAngles( Angles );
	DispatchSpawn( prop_dynamic );
	
	DisableExternalSpawnMode();

	return prop_dynamic;
#endif
#if CLIENT
	return null;
#endif
}

void function ToolGauntlet_DelayedTransmit( string CallbackFuncName, entity Ent )
{
#if SERVER
	WaitFrame(); // Wait one frame to transmit to client or else the entity is not valid yet
	Remote_CallFunction_NonReplay( GetPlayerByIndex( 0 ), CallbackFuncName, Ent.GetEncodedEHandle() );
#endif
}
