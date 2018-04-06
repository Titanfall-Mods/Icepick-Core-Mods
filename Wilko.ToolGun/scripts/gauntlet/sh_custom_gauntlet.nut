
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
	string EnemyType
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
} CustomGauntletsGlobal;

void function CustomGauntlet_Shared_Init()
{
#if SERVER
	CustomGauntlet_Server_Init();
#endif
#if CLIENT
	CustomGauntlet_Client_Init();
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
		// Update all trigger helper positions
		CustomGauntlet_UpdateTriggerLineSavedPosition( CustomGauntletsGlobal.DevelopmentTrack.StartLine, "0 140 255" );
		CustomGauntlet_UpdateTriggerLineSavedPosition( CustomGauntletsGlobal.DevelopmentTrack.FinishLine, "255 180 0" );
		for( int i = CustomGauntletsGlobal.DevelopmentTrack.Checkpoints.len() - 1; i >= 0; --i )
		{
			CustomGauntlet_UpdateTriggerLineSavedPosition( CustomGauntletsGlobal.DevelopmentTrack.Checkpoints[i], "190 230 160" );
		}

		// Check if any trigger helper entities were removed
		CustomGauntlet_WatchForTriggerLineCleanup( CustomGauntletsGlobal.DevelopmentTrack.StartLine );
		CustomGauntlet_WatchForTriggerLineCleanup( CustomGauntletsGlobal.DevelopmentTrack.FinishLine );
		for( int i = CustomGauntletsGlobal.DevelopmentTrack.Checkpoints.len() - 1; i >= 0; --i )
		{
			if( CustomGauntlet_WatchForTriggerLineCleanup( CustomGauntletsGlobal.DevelopmentTrack.Checkpoints[i] ) )
			{
				CustomGauntletsGlobal.DevelopmentTrack.Checkpoints.remove( i );
			}
		}

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

bool function CustomGauntlet_WatchForTriggerLineCleanup( GauntletTriggerLine TriggerLine )
{
#if SERVER
	if( !IsValid( TriggerLine.FromEnt ) || !IsValid( TriggerLine.ToEnt ) )
	{
		if( IsValid( TriggerLine.FromEnt ) )
		{
			TriggerLine.FromEnt.Destroy();
			TriggerLine.FromEnt = null;
		}
		if( IsValid( TriggerLine.ToEnt ) )
		{
			TriggerLine.ToEnt.Destroy();
			TriggerLine.ToEnt = null;
		}
		DestroyBeam( TriggerLine.BeamHelper );
		TriggerLine.IsValid = false;
		return true;
	}
#endif
	return false;
}

void function CustomGauntlet_UpdateTriggerLineSavedPosition( GauntletTriggerLine TriggerLine, string BeamColorString )
{
#if SERVER
	if( IsValid( TriggerLine.FromEnt ) && IsValid( TriggerLine.ToEnt ) )
	{
		TriggerLine.From = TriggerLine.FromEnt.GetOrigin() + TriggerLineOffset;
		TriggerLine.To = TriggerLine.ToEnt.GetOrigin() + TriggerLineOffset;
		TriggerLine.IsValid = true;

		// Update visualizer beam
		if( !IsBeamEntityValid( TriggerLine.BeamHelper ) )
		{
			CreateBeamHelper( TriggerLine.BeamHelper, BeamColorString, TriggerLine.FromEnt, TriggerLine.ToEnt );
		}
		else
		{
			UpdateBeamEmitterPosition( TriggerLine.BeamHelper, TriggerLine.From );
			UpdateBeamTargetPosition( TriggerLine.BeamHelper, TriggerLine.To );
		}

	}
#endif
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


