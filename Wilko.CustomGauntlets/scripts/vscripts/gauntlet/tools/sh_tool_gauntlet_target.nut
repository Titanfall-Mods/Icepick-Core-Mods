
global function Toolgun_RegisterTool_GauntletPlaceTarget
global function CustomGauntlets_SpawnTarget

table ToolGauntletTarget = {};

void function Toolgun_RegisterTool_GauntletPlaceTarget()
{

	// Create the tool
	ToolGauntletTarget.id <- "gauntlet_targets";

	ToolGauntletTarget.GetName <- function()
	{
		return "Gauntlet Target";
	}

	ToolGauntletTarget.GetHelp <- function()
	{
		return "Fire to place a target grunt for a gauntlet track.";
	}

	ToolGauntletTarget.OnFire <- function()
	{
	#if SERVER
		entity player = GetPlayerByIndex( 0 );
		Toolgun_Utils_FireToolTracer( player );

		vector eyePosition = player.EyePosition();
		vector viewVector = player.GetViewVector();
		TraceResults traceResults = TraceLineHighDetail( eyePosition, eyePosition + viewVector * 10000, player, TRACE_MASK_PLAYERSOLID | TRACE_MASK_TITANSOLID | TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_NONE );
		if( traceResults.hitEnt )
		{
			vector Pos = traceResults.endPos;
			vector Angles = Vector(0, player.EyeAngles().y, 0) + < 0.0, 180.0, 0.0 >;
			CustomGauntlets_SpawnTarget( "grunt", Pos, Angles );
		}

		return true;
	#else
		return false;
	#endif
	}

	// Register the tool
	ToolGunTools.append( ToolGauntletTarget );

}

void function CustomGauntlets_SpawnTarget( string type, vector position, vector angles )
{
#if SERVER

	entity HologramGrunt = CreateSoldier( TEAM_IMC, position, angles );
	DispatchSpawn( HologramGrunt );

	Highlight_SetEnemyHighlightWithParam1( HologramGrunt, "gauntlet_target_highlight", HologramGrunt.EyePosition() );
	HologramGrunt.SetSkin( 1 );
	HologramGrunt.SetHealth( 1 );
	HologramGrunt.SetCanBeMeleeExecuted( false );
	HologramGrunt.SetNoTarget( true );
	HologramGrunt.SetEfficientMode( true );
	HologramGrunt.SetHologram();
	HologramGrunt.SetDeathActivity( "ACT_DIESIMPLE" );
	if( !HologramGrunt.IsFrozen() )
	{
		HologramGrunt.Freeze();
	}
	TakeAllWeapons( HologramGrunt );

	TargetEnemy newTarget;
	newTarget.Position = HologramGrunt.GetOrigin();
	newTarget.Rotation = HologramGrunt.GetAngles();
	newTarget.EnemyType = "grunt";
	newTarget.SpawnedEnemy = HologramGrunt;
	CustomGauntletsGlobal.DevelopmentTrack.Targets.append( newTarget );

#endif
}
