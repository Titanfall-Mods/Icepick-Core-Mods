
#if SERVER

void function CustomGauntlet_Server_Init()
{
	AddClientCommandCallback( "CustomGauntlet_DevToggleActive", ClientCommand_CustomGauntlet_DevToggleActive )
	AddClientCommandCallback( "CustomGauntlet_PlaceEntity", ClientCommand_CustomGauntlet_PlaceGauntletEntity )

	thread CustomGauntlet_Server_Think();
}

void function CustomGauntlet_Server_Think()
{
	while( true )
	{
		if( CustomGauntlet.IsActive )
		{
			entity player = GetPlayerByIndex( 0 );

			float DistanceToStart = Length( player.GetOrigin() - CustomGauntlet.StartPoint.Location );
			if( DistanceToStart < 100 )
			{
				CustomGauntlet_Start_Server();
			}

			float DistanceToFinish = Length( player.GetOrigin() - CustomGauntlet.FinishPoint.Location );
			if( DistanceToFinish < 100 )
			{
				CustomGauntlet_Finish_Server();
			}
		}

		WaitFrame()
	}
}

void function CustomGauntlet_Reset_Server()
{
	CustomGauntlet.Started = false;
	CustomGauntlet.Finished = false;

	entity player = GetPlayerByIndex( 0 );
	Remote_CallFunction_NonReplay( player, "ServerCallback_Gauntlet_Reset" );
}

void function CustomGauntlet_Start_Server()
{
	if( CustomGauntlet.Started || CustomGauntlet.Finished )
	{
		return;
	}

	CustomGauntlet.Started = true;
	CustomGauntlet.StartTime = Time();

	entity player = GetPlayerByIndex( 0 );
	RestockPlayerAmmo( player );
	EmitSoundOnEntityOnlyToPlayer( player, player, "training_scr_gaunlet_start" );

	CustomGauntlet_SpawnTargetNPCs();

	Remote_CallFunction_Replay( player, "ServerCallback_Gauntlet_StartRun" );
}

void function CustomGauntlet_Finish_Server()
{
	if( CustomGauntlet.Finished || !CustomGauntlet.Started )
	{
		return;
	}

	CustomGauntlet.Finished = true;

	int TotalEnemies = CustomGauntlet_GetTotalNumberOfEnemies();
	int EnemiesKilled = TotalEnemies - CustomGauntlet.NumberOfTargetsAlive;
	float MissedEnemiesPenalty = CustomGauntlet.NumberOfTargetsAlive * GAUNTLET_ENEMY_MISSED_TIME_PENALTY;
	float RunTime = Time() - CustomGauntlet.StartTime + MissedEnemiesPenalty;

	if( CustomGauntlet.BestRunTime == -1.0 || RunTime < CustomGauntlet.BestRunTime )
	{
		CustomGauntlet.BestRunTime = RunTime;
	}

	entity player = GetPlayerByIndex( 0 );
	RestockPlayerAmmo( player );
	EmitSoundOnEntityOnlyToPlayer( player, player, "training_scr_gaunlet_end" );

	CustomGauntlet_ClearTargetNPCs();
	thread ClearDroppedWeapons( GAUNTLET_TARGET_DISSOLVE_TIME * 1.25 );

	Remote_CallFunction_Replay( player, "ServerCallback_Gauntlet_FinishRun", RunTime, CustomGauntlet.BestRunTime, MissedEnemiesPenalty, TotalEnemies, EnemiesKilled );
	CustomGauntlet_UpdateNumberOfEnemiesKilled();
}

int function CustomGauntlet_GetTotalNumberOfEnemies()
{
	return CustomGauntlet.TargetPoints.len();
}

void function CustomGauntlet_SpawnTargetNPCs()
{
	CustomGauntlet_ClearTargetNPCs();

	CustomGauntlet.NumberOfTargetsAlive = 0;
	for( int i = 0; i < CustomGauntlet.TargetPoints.len(); ++i )
	{
		entity SpawnedGrunt = CreateSoldier( TEAM_IMC, CustomGauntlet.TargetPoints[i].Location, CustomGauntlet.TargetPoints[i].Rotation );
		DispatchSpawn( SpawnedGrunt );

		Highlight_SetEnemyHighlightWithParam1( SpawnedGrunt, "gauntlet_target_highlight", SpawnedGrunt.EyePosition() );
		SpawnedGrunt.SetHealth( 1 );
		SpawnedGrunt.SetCanBeMeleeExecuted( false );
		SpawnedGrunt.SetNoTarget( true );
		SpawnedGrunt.SetEfficientMode( true );
		SpawnedGrunt.SetHologram();
		SpawnedGrunt.SetDeathActivity( "ACT_DIESIMPLE" );
		if( !SpawnedGrunt.IsFrozen() )
		{
			SpawnedGrunt.Freeze();
		}

		AddEntityCallback_OnDamaged( SpawnedGrunt, CustomGauntlet_NPC_Damaged );

		CustomGauntlet.SpawnedTargets.append( SpawnedGrunt );
		CustomGauntlet.NumberOfTargetsAlive++;
	}

	CustomGauntlet_UpdateNumberOfEnemiesKilled();
}

void function CustomGauntlet_ClearTargetNPCs()
{
	for( int i = 0; i < CustomGauntlet.SpawnedTargets.len(); ++i )
	{
		entity npc = CustomGauntlet.SpawnedTargets[i];
		if( IsValid( npc ) && IsAlive( npc ) )
		{
			if ( npc.IsFrozen() )
			{
				npc.Unfreeze()
			}
			npc.Die();
		}
	}
}

void function CustomGauntlet_NPC_Damaged( entity npc, var damageInfo )
{
	float dmg = DamageInfo_GetDamage( damageInfo )
	float finalHealth = npc.GetHealth() - dmg
	if ( finalHealth <= 0 && npc.IsFrozen() )
	{
		npc.Unfreeze()
		EmitSoundAtPosition( TEAM_UNASSIGNED, npc.GetOrigin(), "holopilot_impacts_training" )
		npc.Dissolve( ENTITY_DISSOLVE_PHASESHIFT, Vector( 0, 0, 0 ), GAUNTLET_TARGET_DISSOLVE_TIME )
		CustomGauntlet.NumberOfTargetsAlive--;
		CustomGauntlet_UpdateNumberOfEnemiesKilled();
	}
}

void function CustomGauntlet_UpdateNumberOfEnemiesKilled()
{
	entity player = GetPlayerByIndex( 0 );
	int TotalEnemies = CustomGauntlet_GetTotalNumberOfEnemies();
	int EnemiesKilled = TotalEnemies - CustomGauntlet.NumberOfTargetsAlive;
	Remote_CallFunction_Replay( player, "ServerCallback_Gauntlet_UpdateEnemiesKilled", TotalEnemies, EnemiesKilled );
}

// -----------------------------------------------------------------------------

bool function ClientCommand_CustomGauntlet_DevToggleActive( entity player, array<string> args )
{
	bool active = (args[0] == "1");
	CustomGauntlet.IsActive = active;
	CustomGauntlet_Reset_Server();
	return true;
}

bool function ClientCommand_CustomGauntlet_PlaceGauntletEntity( entity player, array<string> args )
{
	string EntId = args[0];
	vector Pos = Vector( args[1].tofloat(), args[2].tofloat(), args[3].tofloat() );
	vector Ang = Vector( args[4].tofloat(), args[5].tofloat(), args[6].tofloat() );

	switch (EntId)
	{
		case "start_point":
			CustomGauntlet.StartPoint.Location = Pos;
			CustomGauntlet.StartPoint.Rotation = Ang;
			break;
		case "finish_point":
			CustomGauntlet.FinishPoint.Location = Pos;
			CustomGauntlet.FinishPoint.Rotation = Ang;
			break;
		case "target":
			WorldPoint TargetPoint;
			TargetPoint.Location = Pos;
			TargetPoint.Rotation = Ang;
			CustomGauntlet.TargetPoints.append( TargetPoint );
			break;
		case "leaderboard":
			CustomGauntlet.LeaderboardPoint.Location = Pos;
			CustomGauntlet.LeaderboardPoint.Rotation = Ang;
			break;
		case "results":
			CustomGauntlet.ResultsPoint.Location = Pos;
			CustomGauntlet.ResultsPoint.Rotation = Ang;
			break;
		default:
			return false;
	}
	return true;
}

#endif
