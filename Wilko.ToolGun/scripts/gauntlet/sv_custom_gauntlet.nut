
#if SERVER

void function CustomGauntlet_Server_Init()
{
	AddClientCommandCallback( "CustomGauntlet_Start", ClientCommand_CustomGauntlet_Start )
	AddClientCommandCallback( "CustomGauntlet_Finish", ClientCommand_CustomGauntlet_Finish )
	AddClientCommandCallback( "CustomGauntlet_Reset", ClientCommand_CustomGauntlet_Reset )

	AddClientCommandCallback( "CustomGauntlet_AddTarget", ClientCommand_CustomGauntlet_AddTarget )
}

void function CustomGauntlet_Start_Server()
{
	entity player = GetPlayerByIndex( 0 );
	RestockPlayerAmmo( player );
	EmitSoundOnEntityOnlyToPlayer( player, player, "training_scr_gaunlet_start" );

	CustomGauntlet_SpawnTargetNPCs();
}

void function CustomGauntlet_Finish_Server()
{
	entity player = GetPlayerByIndex( 0 );
	RestockPlayerAmmo( player );
	EmitSoundOnEntityOnlyToPlayer( player, player, "training_scr_gaunlet_end" );

	CustomGauntlet_ClearTargetNPCs();
	thread ClearDroppedWeapons( GAUNTLET_TARGET_DISSOLVE_TIME * 1.25 );

	printc("SERVER finish");
}

void function CustomGauntlet_SpawnTargetNPCs()
{
	CustomGauntlet_ClearTargetNPCs();

	CustomGauntlet.NumberOfTargetsAlive = 0;
	for( int i = 0; i < CustomGauntlet.TargetPoints.len(); ++i )
	{
		entity SpawnedGrunt = CreateSoldier( TEAM_IMC, CustomGauntlet.TargetPoints[i].Location, CustomGauntlet.TargetPoints[i].Rotation + <0, 180, 0> );
		DispatchSpawn( SpawnedGrunt );

		Highlight_SetEnemyHighlightWithParam1( SpawnedGrunt, "gauntlet_target_highlight", SpawnedGrunt.EyePosition() );
		SpawnedGrunt.SetHealth( 1 );
		SpawnedGrunt.SetCanBeMeleeExecuted( false );
		SpawnedGrunt.SetNoTarget( true );
		SpawnedGrunt.SetEfficientMode( true );
		SpawnedGrunt.SetHologram();
		SpawnedGrunt.SetDeathActivity( "ACT_DIESIMPLE" );
		SpawnedGrunt.Freeze();

		AddEntityCallback_OnDamaged( SpawnedGrunt, CustomGauntlet_NPC_Damaged );

		CustomGauntlet.SpawnedTargets.append( SpawnedGrunt );
		CustomGauntlet.NumberOfTargetsAlive++;
	}
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
	}
}

// -----------------------------------------------------------------------------

bool function ClientCommand_CustomGauntlet_Start( entity player, array<string> args )
{
	CustomGauntlet_Start();
	return true;
}

bool function ClientCommand_CustomGauntlet_Finish( entity player, array<string> args )
{
	CustomGauntlet_Finish();
	return true;
}

bool function ClientCommand_CustomGauntlet_Reset( entity player, array<string> args )
{
	CustomGauntlet_Reset();
	return true;
}

bool function ClientCommand_CustomGauntlet_AddTarget( entity player, array<string> args )
{
	vector Pos = Vector( args[0].tofloat(), args[1].tofloat(), args[2].tofloat() );
	vector Ang = Vector( args[3].tofloat(), args[4].tofloat(), args[5].tofloat() );

	WorldPoint TargetPoint;
	TargetPoint.Location = Pos;
	TargetPoint.Rotation = Ang;
	CustomGauntlet.TargetPoints.append( TargetPoint );

	return true;
}

#endif
