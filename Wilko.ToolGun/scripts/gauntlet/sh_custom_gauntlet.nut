
const vector TriggerLineOffset = < 0.0, 0.0, 46.0 >;

enum GauntletWorldUIType
{
	Scoreboard,
	StatsBoard,
	MAX
}

struct GauntletTriggerLine
{
	bool IsValid,
	vector From,
	vector To,

	entity FromEnt,
	entity ToEnt,
	BeamEntity BeamHelper
};

struct TargetEnemy
{
	vector Position,
	vector Rotation,
	string EnemyType,
	entity SpawnedEnemy
};

struct GauntletWorldUI
{
	vector Position,
	vector Rotation,
	int UIType,
	var Topology,
	var Rui,
	entity ReferenceEnt
};

struct GauntletHighscore
{
	string Name,
	float Time
}

struct GauntletTrack
{
	string Id = "",
	string TrackName = "Unnamed",

	GauntletTriggerLine StartLine,
	GauntletTriggerLine FinishLine,
	array<GauntletTriggerLine> Checkpoints,
	array<TargetEnemy> Targets,
	array<GauntletWorldUI> Scoreboards,
	array<GauntletWorldUI> StatsBoards,

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

struct
{
	array<GauntletTrack> RegisteredTracks,
	GauntletTrack DevelopmentTrack,

	bool EditModeActive = true,
	GauntletTrack &ActiveTrack,

	bool HasStarted = false,
	bool HasFinished = false,

} CustomGauntletsGlobal;

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

	CustomGauntlet_Shared_RegisterTools();

	thread CustomGauntlet_Shared_Think();
}

void function CustomGauntlet_Shared_RegisterTools()
{
	Toolgun_RegisterTool_GauntletPlaceTrigger();
}

void function CustomGauntlet_Shared_Think()
{
	while( true )
	{
		WaitFrame();
	}
}

// #includefolder scripts/gauntlet/tools/sh_*.nut

// -----------------------------------------------------------------------------

bool function CustomGauntlet_HasTriggerLine( GauntletTriggerLine TriggerLine )
{
	return TriggerLine.From != ZERO_VECTOR || TriggerLine.To != ZERO_VECTOR;
}

bool function CustomGauntlet_HasTriggerLineEntities( GauntletTriggerLine TriggerLine )
{
	return IsValid( TriggerLine.FromEnt ) || IsValid( TriggerLine.ToEnt );
}

// -----------------------------------------------------------------------------

bool function CustomGauntlet_HasStartLine( GauntletTrack Track )
{
	return CustomGauntlet_HasTriggerLine( Track.StartLine );
}

bool function CustomGauntlet_HasStartLineEntities( GauntletTrack Track )
{
	return CustomGauntlet_HasTriggerLineEntities( Track.StartLine );
}

// -----------------------------------------------------------------------------

bool function CustomGauntlet_HasFinishLine( GauntletTrack Track )
{
	return CustomGauntlet_HasTriggerLine( Track.FinishLine );
}

bool function CustomGauntlet_HasFinishLineEntities( GauntletTrack Track )
{
	return CustomGauntlet_HasTriggerLineEntities( Track.FinishLine );
}

// -----------------------------------------------------------------------------

bool function CustomGauntlet_HasScoreboard( GauntletTrack Track )
{
	return Track.Scoreboards.len() > 0;
}

// -----------------------------------------------------------------------------

bool function CustomGauntlet_HasStatsBoards( GauntletTrack Track )
{
	return Track.StatsBoards.len() > 0;
}

// -----------------------------------------------------------------------------

GauntletTrack function CustomGauntlet_FindParentTrack( entity SearchEnt )
{
	if( CustomGauntlet_IsEntPartOfTrack( CustomGauntletsGlobal.DevelopmentTrack, SearchEnt ) )
	{
		return CustomGauntletsGlobal.DevelopmentTrack;
	}

	for( int i = 0; i < CustomGauntletsGlobal.RegisteredTracks.len(); ++i )
	{
		if( CustomGauntlet_IsEntPartOfTrack( CustomGauntletsGlobal.RegisteredTracks[i], SearchEnt ) )
		{
			return CustomGauntletsGlobal.RegisteredTracks[i];
		}
	}
	
	GauntletTrack InvalidTrack;
	InvalidTrack.TrackName = "Invalid";
	return InvalidTrack;
}

bool function CustomGauntlet_IsEntPartOfTrack( GauntletTrack Track, entity SearchEnt )
{
	if( CustomGauntlet_IsEntPartOfGauntletTriggerLine( Track.FinishLine, SearchEnt ) )
		return true;
	if( CustomGauntlet_IsEntPartOfGauntletTriggerLine( Track.StartLine, SearchEnt ) )
		return true;

	for( int i = 0; i < Track.Checkpoints.len(); ++i )
	{
		if( CustomGauntlet_IsEntPartOfGauntletTriggerLine( Track.Checkpoints[i], SearchEnt ) )
			return true;
	}

	for( int i = 0; i < Track.Targets.len(); ++i )
	{
		if( Track.Targets[i].SpawnedEnemy == SearchEnt )
		{
			return true;
		}
	}

	return false;
}

bool function CustomGauntlet_IsEntPartOfGauntletTriggerLine( GauntletTriggerLine TriggerLine, entity SearchEnt )
{
	if( TriggerLine.FromEnt == SearchEnt )
		return true;
	if( TriggerLine.ToEnt == SearchEnt )
		return true;
	if( TriggerLine.BeamHelper.Laser == SearchEnt )
		return true;
	if( TriggerLine.BeamHelper.Laser2 == SearchEnt )
		return true;

	return false;
}
