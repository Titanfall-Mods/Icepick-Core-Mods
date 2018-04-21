
const vector TriggerLineOffset = < 0.0, 0.0, 46.0 >;

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

struct GauntletTrack
{
	GauntletTriggerLine StartLine,
	GauntletTriggerLine FinishLine,
	array<GauntletTriggerLine> Checkpoints,
	array<TargetEnemy> Targets,
};

struct
{
	array<GauntletTrack> RegisteredTracks,
	GauntletTrack DevelopmentTrack,

	bool EditModeActive = true,
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
