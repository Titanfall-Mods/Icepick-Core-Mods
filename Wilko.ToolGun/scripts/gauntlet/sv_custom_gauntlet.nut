
#if SERVER

void function CustomGauntlet_Server_Init()
{
	AddClientCommandCallback( "CustomGauntlet_SetEditMode", ClientCommand_CustomGauntlet_SetEditMode );

	thread CustomGauntlet_Server_Think();
}

void function CustomGauntlet_Server_Think()
{
	while( true )
	{
		if( CustomGauntletsGlobal.EditModeActive )
		{
			CustomGauntlet_Server_Think_EditMode();
		}
		else
		{
			CustomGauntlet_Server_Think_PlayMode();
		}
		WaitFrame();
	}
}

void function CustomGauntlet_Server_Think_EditMode()
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

	// Remove any targets that've been removed
	for( int i = CustomGauntletsGlobal.DevelopmentTrack.Targets.len() - 1; i >= 0; --i )
	{
		if( !IsValid( CustomGauntletsGlobal.DevelopmentTrack.Targets[i].SpawnedEnemy ) )
		{
			CustomGauntletsGlobal.DevelopmentTrack.Targets.remove( i );
		}
	}
}

void function CustomGauntlet_Server_Think_PlayMode()
{

}

bool function CustomGauntlet_WatchForTriggerLineCleanup( GauntletTriggerLine TriggerLine )
{
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
	return false;
}

void function CustomGauntlet_UpdateTriggerLineSavedPosition( GauntletTriggerLine TriggerLine, string BeamColorString )
{
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
}

bool function ClientCommand_CustomGauntlet_SetEditMode( entity player, array<string> args )
{
	bool active = args[0] == "1";
	CustomGauntletsGlobal.EditModeActive = active;
	return true;
}

// -----------------------------------------------------------------------------



#endif
