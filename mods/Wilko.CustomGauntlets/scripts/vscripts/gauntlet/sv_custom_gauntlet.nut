
global function CustomGauntlet_Server_Init
global function CustomGauntletCreateRope

const float GAUNTLET_ENEMY_MISSED_TIME_PENALTY = 2.0;
const float GAUNTLET_TARGET_DISSOLVE_TIME = 1.0 * 100;
const float GAUNTLET_WEAPON_RESPAWN_TIME = 2.2;

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

	AddCallback_OnLoadSaveGame( CustomGauntlet_OnLoadSaveGame );
	AddOnPlayerInstantRespawnedCallback( CustomGauntlet_OnPlayerInstantRespawned );

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
	// Remove any targets that've been removed
	for( int i = CustomGauntletsGlobal.DevelopmentTrack.Targets.len() - 1; i >= 0; --i )
	{
		if( !IsValid( CustomGauntletsGlobal.DevelopmentTrack.Targets[i].SpawnedEnemy ) )
		{
			CustomGauntletsGlobal.DevelopmentTrack.Targets.remove( i );
		}
	}

	// Remove any scoreboards that've been removed
	for( int i = CustomGauntletsGlobal.DevelopmentTrack.Scoreboards.len() - 1; i >= 0; --i )
	{
		if( !IsValid( CustomGauntletsGlobal.DevelopmentTrack.Scoreboards[i].ReferenceEnt ) )
		{
			CustomGauntletsGlobal.DevelopmentTrack.Scoreboards.remove( i );
		}
	}

	// Remove any results boards that've been removed
	for( int i = CustomGauntletsGlobal.DevelopmentTrack.StatsBoards.len() - 1; i >= 0; --i )
	{
		if( !IsValid( CustomGauntletsGlobal.DevelopmentTrack.StatsBoards[i].ReferenceEnt ) )
		{
			CustomGauntletsGlobal.DevelopmentTrack.StatsBoards.remove( i );
		}
	}

	// Remove any respawning weapons that've been deleted
	for( int i = CustomGauntletsGlobal.DevelopmentTrack.RespawningWeapons.len() - 1; i >= 0; --i )
	{
		GauntletWeapon respawningWeapon = CustomGauntletsGlobal.DevelopmentTrack.RespawningWeapons[i];
		if( !IsValid( respawningWeapon.ReferenceEnt ) )
		{
			// Remove the spawned weapon
			entity ent = respawningWeapon.ReferenceEnt;
			if( ent.e.attachedEnts.len() && IsValid( ent.e.attachedEnts[0] ) )
			{
				entity weaponEnt = ent.e.attachedEnts[0];
				if( IsValid( weaponEnt ) && !weaponEnt.GetOwner() )
				{
					weaponEnt.Destroy();
				}
			}

			// Remove the weapon spawner
			CustomGauntletsGlobal.DevelopmentTrack.RespawningWeapons.remove( i );
		}
	}

}

void function CustomGauntlet_Server_Think_PlayMode()
{
	entity player = GetPlayerByIndex( 0 );

	if( !CustomGauntletsGlobal.HasStarted )
	{
		ListenForPlayerStartGauntlet( player );
	}
	else if( !CustomGauntletsGlobal.HasFinished )
	{
		ListenForPlayerFinishGauntlet( player );
	}
}

void function ListenForPlayerStartGauntlet( entity player )
{
	foreach( startLine in CustomGauntletsGlobal.DevelopmentTrack.Starts )
	{
		if ( IsPlayerInGauntletTrigger( player, startLine ) )
		{
			CustomGauntlet_Server_Start( CustomGauntletsGlobal.DevelopmentTrack );
			break;
		}
	}
}

void function ListenForPlayerFinishGauntlet( entity player )
{
	foreach( finishLine in CustomGauntletsGlobal.DevelopmentTrack.Finishes )
	{
		if ( IsPlayerInGauntletTrigger( player, finishLine ) )
		{
			CustomGauntlet_Server_Finish();
			break;
		}
	}
}

bool function IsPlayerInGauntletTrigger( entity player, GauntletTriggerLine trigger )
{
	entity pylon1 = trigger.left;
	entity pylon2 = trigger.right;

	vector p1Org = pylon1.GetOrigin();
	vector p2Org = pylon2.GetOrigin();
	float pylonDist = Length( p2Org - p1Org );

	vector triggerOBBOrigin = ( p1Org + p2Org ) / 2.0;
	vector triggerOOBAngles = VectorToAngles( p2Org - p1Org );
	vector triggerOOBMins = < pylonDist * -0.5, -8.0, 0.0 >;
	vector triggerOOBMaxs = < pylonDist * 0.5, 8.0, trigger.triggerHeight >;

	return OBBIntersectsOBB( triggerOBBOrigin, triggerOOBAngles, triggerOOBMins, triggerOOBMaxs, player.GetOrigin(), <0.0,0.0,0.0>, player.GetBoundingMins(), player.GetBoundingMaxs(), 0.0 );
}

bool function ClientCommand_CustomGauntlet_SetEditMode( entity player, array<string> args )
{
	bool active = args[0] == "1";
	CustomGauntletsGlobal.EditModeActive = active;

	CustomGauntlet_Server_Reset();
	return true;
}

// -----------------------------------------------------------------------------

void function CustomGauntlet_Server_Reset()
{
	if( CustomGauntletsGlobal.HasStarted && !CustomGauntletsGlobal.HasFinished )
	{
		entity player = GetPlayerByIndex( 0 );
		EmitSoundOnEntityOnlyToPlayer( player, player, "training_scr_gaunlet_abort" );
		Remote_CallFunction_Replay( player, "ServerCallback_CustomGauntlet_Finish", -1, -1, 0, 0, 0 );
	}
	
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
	SetGlobalForcedDialogueOnly( true );

	CustomGauntletsGlobal.ActiveTrack = Track;
	CustomGauntlet_Server_SpawnTargets();

	GauntletRuntimeData.StartTime = Time();
	CustomGauntletsGlobal.HasStarted = true;

	entity player = GetPlayerByIndex( 0 );
	Remote_CallFunction_Replay( player, "ServerCallback_CustomGauntlet_Start" );
	EmitSoundOnEntityOnlyToPlayer( player, player, "training_scr_gaunlet_start" );
	player.SetPlayerNetInt( "CGEnemiesKilled", 0 );
	RestockPlayerAmmo( player );

	print( "Started track: " + CustomGauntletsGlobal.ActiveTrack.TrackName + "!" );
}

void function CustomGauntlet_Server_Finish()
{
	CustomGauntletsGlobal.HasFinished = true;
	SetGlobalForcedDialogueOnly( false );

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
	CustomGauntlet_AddLeaderboardTime( CustomGauntletsGlobal.ActiveTrack, TotalTime, GetPlayerByIndex( 0 ).GetPlayerName() );

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

void function CustomGauntlet_OnLoadSaveGame( entity player )
{
	thread CustomGauntlet_OnLoadSaveGame_Thread( player );
}

void function CustomGauntlet_OnLoadSaveGame_Thread( entity player )
{
	wait 1.0;
	thread CustomGauntlet_PlayerConnected( player );
}

void function CustomGauntlet_PlayerConnected( entity player )
{
	// Resend scoreboards and results boards as they get lost on a world restart
	for( int i = CustomGauntletsGlobal.DevelopmentTrack.Scoreboards.len() - 1; i >= 0; --i )
	{
		thread ToolGauntlet_DelayedTransmit( "ServerCallback_CustomGauntlet_SendScoreboardEnt", CustomGauntletsGlobal.DevelopmentTrack.Scoreboards[i].ReferenceEnt );
	}
	for( int i = CustomGauntletsGlobal.DevelopmentTrack.StatsBoards.len() - 1; i >= 0; --i )
	{
		thread ToolGauntlet_DelayedTransmit( "ServerCallback_CustomGauntlet_SendStatsBoardEnt", CustomGauntletsGlobal.DevelopmentTrack.StatsBoards[i].ReferenceEnt );
	}

	wait 0.1;
	for( int i = CustomGauntletsGlobal.DevelopmentTrack.Highscores.len() - 1; i >= 0; --i )
	{
		Remote_CallFunction_Replay( player, "ServerCallback_CustomGauntlet_SendScoreboardTime", CustomGauntletsGlobal.DevelopmentTrack.Highscores[i].Time );
	}
	foreach( line in CustomGauntletsGlobal.DevelopmentTrack.Starts )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_CustomGauntlet_SendStartFinishLine", 0, line.left.GetEncodedEHandle(), line.right.GetEncodedEHandle(), line.triggerHeight );
	}
	foreach( line in CustomGauntletsGlobal.DevelopmentTrack.Finishes )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_CustomGauntlet_SendStartFinishLine", 1, line.left.GetEncodedEHandle(), line.right.GetEncodedEHandle(), line.triggerHeight );
	}
}

array<entity> function CustomGauntletCreateRope( vector origin, vector target, string cable = "cable/cable_selfillum.vmt" )
{
	int movespeed = 64
	int subdivisions = 0 // 25
	int slack = -100
	string endpointName = UniqueString( "rope_endpoint" )

	entity rope_start = CreateEntity( "move_rope" )
	rope_start.kv.NextKey = endpointName
	rope_start.kv.MoveSpeed = movespeed
	rope_start.kv.Slack = slack
	rope_start.kv.Subdiv = subdivisions
	rope_start.kv.Width = "2"
	rope_start.kv.TextureScale = "1"
	rope_start.kv.RopeMaterial = cable
	rope_start.kv.PositionInterpolator = 2
	rope_start.DisableHibernation()
	rope_start.SetOrigin( origin )

	entity rope_end = CreateEntity( "keyframe_rope" )
	SetTargetName( rope_end, endpointName )
	rope_end.kv.MoveSpeed = movespeed
	rope_end.kv.Slack = slack
	rope_end.kv.Subdiv = subdivisions
	rope_end.kv.Width = "2"
	rope_end.kv.TextureScale = "1"
	rope_end.kv.RopeMaterial = cable
	rope_end.DisableHibernation()
	rope_end.SetOrigin( target )

	DispatchSpawn( rope_start )
	DispatchSpawn( rope_end )

	return [ rope_start, rope_end ];
}

void function CustomGauntlet_OnPlayerInstantRespawned( entity player )
{
	CustomGauntlet_Server_Reset();
}
