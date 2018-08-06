
untyped

global function Toolgun_RegisterTool_SpawnPoint
#if SERVER
global function ToolSpawnPoint_AddSpawn
#endif

global struct CustomSpawnPoint
{
	entity anchorEnt,
	vector angles
}
global array< CustomSpawnPoint > PlacedSpawnPoints;

table ToolSpawnPoint = {};

void function Toolgun_RegisterTool_SpawnPoint()
{
	// Create the tool
	ToolSpawnPoint.id <- "spawn_point_spawner";

	ToolSpawnPoint.GetName <- function()
	{
		return "Spawn Point";
	}

	ToolSpawnPoint.GetHelp <- function()
	{
		return "Fire to place a Spawn Point at your location";
	}

	ToolSpawnPoint.OnFire <- function()
	{
	#if SERVER
		entity player = GetPlayerByIndex( 0 );
		
		vector origin = player.GetOrigin();
		vector angles = player.EyeAngles()
		ToolSpawnPoint_AddSpawn( origin, angles );

		return false;
	#else
		return true;
	#endif
	}

	// Register the tool
	ToolGunTools.append( ToolSpawnPoint );
}

#if SERVER
CustomSpawnPoint function ToolSpawnPoint_AddSpawn( vector origin, vector angles )
{
	vector spawnAngle = < 0, angles.y, 0 >;

	entity anchorEnt = CreateAnchorEntity( origin, spawnAngle, $"models/weapons/sentry_shield/sentry_shield_proj.mdl" );
	entity helmetEnt = CreateAnchorEntity( origin + AnglesToUp( spawnAngle ) * 15, spawnAngle, $"models/humans/heroes/mlt_hero_jack_helmet_static.mdl" );
	helmetEnt.SetParent( anchorEnt );

	CustomSpawnPoint newSpawn;
	newSpawn.anchorEnt = anchorEnt;
	newSpawn.angles = angles;
	PlacedSpawnPoints.append( newSpawn );

	printt("spawns: ", PlacedSpawnPoints.len());

	thread ToolSpawnPoint_SpawnThink( newSpawn );

	return newSpawn;
}

void function ToolSpawnPoint_SpawnThink( CustomSpawnPoint spawnPoint )
{
	EndSignal( spawnPoint.anchorEnt, "OnDestroy" );

	OnThreadEnd(
		function() : ( spawnPoint )
		{
			for( int i = 0; i < PlacedSpawnPoints.len(); ++i )
			{
				if( PlacedSpawnPoints[i] == spawnPoint )
				{
					PlacedSpawnPoints.remove( i );
					break;
				}
			}
		}
	)

	while( true )
	{
		wait 1.0; // Keep alive
	}
}

#endif
