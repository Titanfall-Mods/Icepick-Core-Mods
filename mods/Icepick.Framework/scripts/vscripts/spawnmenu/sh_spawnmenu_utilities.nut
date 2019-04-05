
global function Spawnmenu_Init_Utils

#if SERVER
global function Spawnmenu_PerformUtility
global function AddOnSpawnmenuUtilityCallback
#endif

struct
{
	array<void functionref(string id)> onPerformUtilityCallback,
} file

void function Spawnmenu_Init_Utils()
{
	#if CLIENT
	RegisterSpawnmenuPage( "utilities", "Utilities" );

	// Add some utility functions for cleaning up the map
	RegisterPageCategory( "utilities", "utilities", "Utilities", "Spawnmenu_PerformUtility" );
	RegisterCategoryItem( "utilities", "cleanup.all", "Cleanup Everything" );
	RegisterCategoryItem( "utilities", "cleanup.props", "Cleanup Props" );
	RegisterCategoryItem( "utilities", "cleanup.ziplines", "Cleanup Ziplines" );
	RegisterCategoryItem( "utilities", "cleanup.teleporters", "Cleanup Teleporters" );
	RegisterCategoryItem( "utilities", "cleanup.spawnpoints", "Cleanup Spawn Points" );
	RegisterCategoryItem( "utilities", "cleanup.weapons", "Cleanup Weapons" );
	RegisterCategoryItem( "utilities", "cleanup.npcs", "Cleanup NPCs" );
	#endif
}

#if SERVER

void function AddOnSpawnmenuUtilityCallback( void functionref(string id) callbackFunc )
{
	Assert( !file.onPerformUtilityCallback.contains( callbackFunc ), "Already added " + string( callbackFunc ) + " with AddOnSpawnmenuUtilityCallback" );
	file.onPerformUtilityCallback.append( callbackFunc );
}

void function Spawnmenu_PerformUtility( string utility )
{
	switch( utility )
	{
		case "cleanup.all":
			Cleanup_All();
			break;
		case "cleanup.props":
			Cleanup_Props();
			break;
		case "cleanup.ziplines":
			Cleanup_Ziplines();
			break;
		case "cleanup.teleporters":
			Cleanup_Teleporters();
			break;
		case "cleanup.spawnpoints":
			Cleanup_SpawnPoints();
			break;
		case "cleanup.weapons":
			Cleanup_Weapons();
			break;
		case "cleanup.npcs":
			Cleanup_NPCs();
			break;
	}

	foreach ( callbackFunc in file.onPerformUtilityCallback )
	{
		callbackFunc( utility );
	}
}

void function Cleanup_All()
{
	Cleanup_Props();
	Cleanup_Ziplines();
	Cleanup_Teleporters();
	Cleanup_SpawnPoints();
	Cleanup_Weapons();
	Cleanup_NPCs();
}

void function Cleanup_Props()
{
	for( int i = 0; i < ToolgunData.SpawnedEntities.len(); ++i )
	{
		ToolgunData.SpawnedEntities[i].Destroy();
	}
	ToolgunData.SpawnedEntities.clear();
}

void function Cleanup_Ziplines()
{
	for( int i = 0; i < PlacedZiplines.len(); ++i )
	{
		ToolZipline_DestroyZipline( PlacedZiplines[i], true );
	}
	PlacedZiplines.clear();
}

void function Cleanup_Teleporters()
{
	for( int i = PlacedTeleporters.len() - 1; i >= 0; --i )
	{
		PlacedTeleporter teleporter = PlacedTeleporters[i];
		if( IsValid(teleporter.entryEnt) )
		{
			teleporter.entryEnt.Destroy();
		}
		if( IsValid(teleporter.entryEnt) )
		{
			teleporter.exitEnt.Destroy();
		}
	}
	
	PlacedTeleporters.clear();
}

void function Cleanup_SpawnPoints()
{
	for( int i = PlacedSpawnPoints.len() - 1; i >= 0; --i )
	{
		CustomSpawnPoint spawn = PlacedSpawnPoints[i];
		spawn.anchorEnt.Destroy();
	}

	PlacedSpawnPoints.clear();
}

void function Cleanup_Weapons()
{
	foreach ( weapon in GetWeaponArray( true ) )
	{
		// don't clean up weapon pickups that were placed in leveled
		int spawnflags = expect string( weapon.kv.spawnflags ).tointeger();
		if ( spawnflags & SF_WEAPON_START_CONSTRAINED )
		{
			continue;
		}
		weapon.Destroy();
	}
}

void function Cleanup_NPCs()
{
	foreach ( npc in GetNPCArrayOfTeam( TEAM_IMC ) )
	{
		npc.Destroy();
	}
}

#endif
