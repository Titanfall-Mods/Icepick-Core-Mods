global function CustomGauntlet_Server_Init

const float GAUNTLET_ENEMY_MISSED_TIME_PENALTY = 2.0;
const float GAUNTLET_TARGET_DISSOLVE_TIME = 1.0 * 100;

global enum GauntletTriggerEntity
{
	StartLine,
	FinishLine,
	Target,
	Leaderboard,
	Stats,
	MAX
}

struct 
{
	float StartTime,
	array<entity> SpawnedTargets
} GauntletRuntimeData;

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
	CustomGauntlet_UpdateTriggerLineSavedPosition( CustomGauntletsGlobal.DevelopmentTrack.StartLine, GauntletTriggerEntity.StartLine, "0 140 255" );
	CustomGauntlet_UpdateTriggerLineSavedPosition( CustomGauntletsGlobal.DevelopmentTrack.FinishLine, GauntletTriggerEntity.FinishLine, "255 180 0" );
	for( int i = CustomGauntletsGlobal.DevelopmentTrack.Checkpoints.len() - 1; i >= 0; --i )
	{
		CustomGauntlet_UpdateTriggerLineSavedPosition( CustomGauntletsGlobal.DevelopmentTrack.Checkpoints[i], GauntletTriggerEntity.Checkpoint, "190 230 160" );
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

void function CustomGauntlet_UpdateTriggerLineSavedPosition( GauntletTriggerLine TriggerLine, int TriggerType, string BeamColorString )
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
			switch( TriggerType )
			{
				case GauntletTriggerEntity.StartLine:
					TriggerLine.BeamHelper.Laser.ConnectOutput( "OnTouchedByEntity", CustomGauntlet_StartLine_OnTouchedByEntity );
					TriggerLine.BeamHelper.Laser2.ConnectOutput( "OnTouchedByEntity", CustomGauntlet_StartLine_OnTouchedByEntity );
					break;
				case GauntletTriggerEntity.FinishLine:
					TriggerLine.BeamHelper.Laser.ConnectOutput( "OnTouchedByEntity", CustomGauntlet_FinishLine_OnTouchedByEntity );
					TriggerLine.BeamHelper.Laser2.ConnectOutput( "OnTouchedByEntity", CustomGauntlet_FinishLine_OnTouchedByEntity );
					break;
				case GauntletTriggerEntity.Checkpoint:
					TriggerLine.BeamHelper.Laser.ConnectOutput( "OnTouchedByEntity", CustomGauntlet_Checkpoint_OnTouchedByEntity );
					TriggerLine.BeamHelper.Laser2.ConnectOutput( "OnTouchedByEntity", CustomGauntlet_Checkpoint_OnTouchedByEntity );
					break;
			}
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

	if( CustomGauntletsGlobal.HasStarted && !CustomGauntletsGlobal.HasFinished )
	{
		entity player = GetPlayerByIndex( 0 );
		EmitSoundOnEntityOnlyToPlayer( player, player, "training_scr_gaunlet_abort" );
	}
	CustomGauntlet_Server_Reset();
	return true;
}

// -----------------------------------------------------------------------------

void function CustomGauntlet_StartLine_OnTouchedByEntity( entity self, entity activator, entity caller, var value )
{
	if( !CustomGauntletsGlobal.EditModeActive && activator.IsPlayer() )
	{
		GauntletTrack ParentTrack = CustomGauntlet_FindParentTrack( self );
		if( !CustomGauntletsGlobal.HasStarted && ParentTrack.Id != "" )
		{
			CustomGauntlet_Server_Start( ParentTrack );
		}
	}
}

void function CustomGauntlet_FinishLine_OnTouchedByEntity( entity self, entity activator, entity caller, var value )
{
	if( !CustomGauntletsGlobal.EditModeActive && activator.IsPlayer() )
	{
		GauntletTrack ParentTrack = CustomGauntlet_FindParentTrack( self );
		if( CustomGauntletsGlobal.HasStarted && !CustomGauntletsGlobal.HasFinished && ParentTrack.Id != "" && CustomGauntletsGlobal.ActiveTrack.Id == ParentTrack.Id )
		{
			CustomGauntlet_Server_Finish();
		}
	}
}

void function CustomGauntlet_Checkpoint_OnTouchedByEntity( entity self, entity activator, entity caller, var value )
{
	if( !CustomGauntletsGlobal.EditModeActive && activator.IsPlayer() )
	{
		GauntletTrack ParentTrack = CustomGauntlet_FindParentTrack( self );
		if( ParentTrack.Id != "" && CustomGauntletsGlobal.ActiveTrack.Id == ParentTrack.Id )
		{
			// Do checkpoint
		}
	}
}

// -----------------------------------------------------------------------------

void function CustomGauntlet_Server_Reset()
{
	CustomGauntletsGlobal.HasStarted = false;
	CustomGauntletsGlobal.HasFinished = false;
	CustomGauntlet_Server_ClearTargets();
	thread CustomGauntlet_ClearDroppedWeapons();

	print( "Reset gauntlet track!" );
}

void function CustomGauntlet_ClearDroppedWeapons()
{
	// HACK: Wait 10 frames to remove, wait isn't working correctly here?
	for( int i = 0; i < 10; ++i )
	{
		WaitFrame();
	}

	bool onlyNotOwnedWeapons = true  // don't get the ones in guys' hands
	array<entity> weapons = GetWeaponArray( onlyNotOwnedWeapons )

	foreach ( weapon in weapons )
	{
		// don't clean up weapon pickups that were placed in leveled
		int spawnflags = expect string( weapon.kv.spawnflags ).tointeger()
		if ( spawnflags & SF_WEAPON_START_CONSTRAINED )
			continue

		weapon.Destroy()
	}
}

void function CustomGauntlet_Server_Start( GauntletTrack Track )
{
	CustomGauntlet_Server_Reset();

	CustomGauntletsGlobal.ActiveTrack = Track;
	CustomGauntlet_Server_SpawnTargets();

	GauntletRuntimeData.StartTime = Time();
	CustomGauntletsGlobal.HasStarted = true;

	entity player = GetPlayerByIndex( 0 );
	Remote_CallFunction_Replay( player, "ServerCallback_CustomGauntlet_Start" );
	EmitSoundOnEntityOnlyToPlayer( player, player, "training_scr_gaunlet_start" );
	player.SetPlayerNetInt( "CGEnemiesKilled", 0 );

	print( "Started track: " + CustomGauntletsGlobal.ActiveTrack.TrackName + "!" );
}

void function CustomGauntlet_Server_Finish()
{
	CustomGauntletsGlobal.HasFinished = true;

	// Calculate run stats
	float TimeBeforePenalties = Time() - GauntletRuntimeData.StartTime;
	int TotalNumTargets = GauntletRuntimeData.SpawnedTargets.len();
	int NumTargetsMissed = CustomGauntlet_Server_NumAliveTargets();
	float MissedTargetsPenalty = NumTargetsMissed * GAUNTLET_ENEMY_MISSED_TIME_PENALTY;
	float TotalTime = TimeBeforePenalties + MissedTargetsPenalty;

	// Check for new best time
	bool SetNewBestTime = false;
	float BestTime = CustomGauntletsGlobal.ActiveTrack.BestTime;
	if( CustomGauntletsGlobal.ActiveTrack.BestTime < 0.0 || TotalTime < BestTime )
	{
		SetNewBestTime = true;
		BestTime = TotalTime;
		CustomGauntletsGlobal.ActiveTrack.BestTime = TotalTime;
	}

	// Send data to player
	entity player = GetPlayerByIndex( 0 );
	Remote_CallFunction_Replay( player, "ServerCallback_CustomGauntlet_Finish", TotalTime, BestTime, TotalNumTargets, NumTargetsMissed, MissedTargetsPenalty );
	EmitSoundOnEntityOnlyToPlayer( player, player, SetNewBestTime ? "training_scr_gaunlet_high_score" : "training_scr_gaunlet_end" );

	// Finish and reset gauntlet
	print( "Finished track!" );
	CustomGauntlet_Server_Reset();
}

// -----------------------------------------------------------------------------

void function CustomGauntlet_Server_ClearTargets()
{
	// Reset reference enemies so we can see them again
	for( int i = 0; i < CustomGauntletsGlobal.ActiveTrack.Targets.len(); ++i )
	{
		TargetEnemy Target = CustomGauntletsGlobal.ActiveTrack.Targets[i];
		if( IsValid( Target.SpawnedEnemy ) )
		{
			Target.SpawnedEnemy.Show();
			Target.SpawnedEnemy.kv.solid = 6; // Hitbox collision
		}
	}

	// Remove any spawned enemies
	for( int i = 0; i < GauntletRuntimeData.SpawnedTargets.len(); ++i )
	{
		entity npc = GauntletRuntimeData.SpawnedTargets[i];
		if( IsValid( npc ) && IsAlive( npc ) )
		{
			if ( npc.IsFrozen() )
			{
				npc.Unfreeze();
			}
			npc.Die();
		}
	}
	GauntletRuntimeData.SpawnedTargets.clear();
}

int function CustomGauntlet_Server_NumAliveTargets()
{
	int Total = 0;
	for( int i = 0; i < GauntletRuntimeData.SpawnedTargets.len(); ++i )
	{
		entity npc = GauntletRuntimeData.SpawnedTargets[i];
		if( IsValid( npc ) && IsAlive( npc ) )
		{
			Total++;
		}
	}
	return Total;
}

void function CustomGauntlet_Server_SpawnTargets()
{
	for( int i = 0; i < CustomGauntletsGlobal.ActiveTrack.Targets.len(); ++i )
	{
		TargetEnemy Target = CustomGauntletsGlobal.ActiveTrack.Targets[i];

		// Make reference target enemies for editting invisible
		if( IsValid( Target.SpawnedEnemy ) )
		{
			Target.SpawnedEnemy.Hide();
			Target.SpawnedEnemy.kv.solid = 0; // No collision
		}

		// Spawn actual target enemies 
		entity SpawnedEnemy = null;
		switch( Target.EnemyType )
		{
			case "grunt":
				SpawnedEnemy = CreateSoldier( TEAM_IMC, Target.Position, Target.Rotation );
				break;
		}

		if( SpawnedEnemy != null )
		{
			DispatchSpawn( SpawnedEnemy );

			Highlight_SetEnemyHighlightWithParam1( SpawnedEnemy, "gauntlet_target_highlight", SpawnedEnemy.EyePosition() );
			SpawnedEnemy.SetHealth( 1 );
			SpawnedEnemy.SetCanBeMeleeExecuted( false );
			SpawnedEnemy.SetNoTarget( true );
			SpawnedEnemy.SetEfficientMode( true );
			SpawnedEnemy.SetHologram();
			SpawnedEnemy.SetDeathActivity( "ACT_DIESIMPLE" );
			if( !SpawnedEnemy.IsFrozen() )
			{
				SpawnedEnemy.Freeze();
			}
			AddEntityCallback_OnDamaged( SpawnedEnemy, CustomGauntlet_Server_NPC_Damaged );

			GauntletRuntimeData.SpawnedTargets.append( SpawnedEnemy );
		}
	}
}

void function CustomGauntlet_Server_NPC_Damaged( entity npc, var damageInfo )
{
	float dmg = DamageInfo_GetDamage( damageInfo );
	float finalHealth = npc.GetHealth() - dmg;
	if ( finalHealth <= 0 && npc.IsFrozen() )
	{
		npc.Unfreeze();
		EmitSoundAtPosition( TEAM_UNASSIGNED, npc.GetOrigin(), "holopilot_impacts_training" );
		npc.Dissolve( ENTITY_DISSOLVE_PHASESHIFT, Vector( 0, 0, 0 ), GAUNTLET_TARGET_DISSOLVE_TIME );

		// HACK: Sending an on killed event wasn't working, so use a netint to do it, works just as well
		entity player = DamageInfo_GetAttacker( damageInfo )
		if ( IsValid( player ) && player.IsPlayer()  )
		{
			int Killed = player.GetPlayerNetInt( "CGEnemiesKilled" );
			player.SetPlayerNetInt( "CGEnemiesKilled", Killed + 1 );
		}
	}
}
