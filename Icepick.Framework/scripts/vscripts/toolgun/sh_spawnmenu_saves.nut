
global function Spawnmenu_Init_Saves

#if SERVER
global function Spawnmenu_PerformUtility
global function AddOnSpawnmenuUtilityCallback
#endif

struct
{
	array<void functionref(string id)> onPerformUtilityCallback
} file

void function Spawnmenu_Init_Saves()
{
	#if CLIENT
	RegisterSpawnmenuPage( "saves", "Saves" );

	// Add some utility functions for cleaning up the map
	RegisterPageCategory( "saves", "utilities", "Utilities", "Spawnmenu_PerformUtility" );
	RegisterCategoryItem( "utilities", "cleanup.all", "Cleanup Everything" );
	RegisterCategoryItem( "utilities", "cleanup.props", "Cleanup Props" );
	RegisterCategoryItem( "utilities", "cleanup.ziplines", "Cleanup Ziplines" );
	RegisterCategoryItem( "utilities", "cleanup.weapons", "Cleanup Weapons" );
	RegisterCategoryItem( "utilities", "cleanup.npcs", "Cleanup NPCs" );

	// Add categories where all our saves will be listed
	RegisterPageCategory( "saves", "saves-current", Localize("#" + GetMapName().toupper()) + " Saves", "Spawnmenu_LoadSave" ); // Current map saves
	RegisterPageCategory( "saves", "saves-all", "Saves for all other maps", "Spawnmenu_LoadSave" ); // Saves for all other maps just in case

	// List save files in the saves folder
	array<string> saveNames = UntypedArrayToStringArray( GetSaveFiles() );
	foreach( saveFile in saveNames )
	{
		array<string> splitName = split( saveFile, "\\" );
		splitName = split( splitName[splitName.len() - 1], "." );

		string saveMap = splitName[ splitName.len() - 2 ];
		bool isCurrentMapSave = saveMap == GetMapName();
		string itemCategory = isCurrentMapSave ? "saves-current" : "saves-all";

		string fileName = "";
		string displayName = "";
		for( int i = 0; i < splitName.len(); ++i )
		{
			fileName += (fileName == "" ? "" : ".") + splitName[i];
			if( i < splitName.len() - 2 )
			{
				displayName += (displayName == "" ? "" : ".") + splitName[i];
			}
		}

		if( !isCurrentMapSave )
		{
			displayName += " (" + Localize("#" + saveMap.toupper()) + ")";
		}

		RegisterCategoryItem( itemCategory, fileName, displayName );
	}
	#endif
}

#if SERVER

// -----------------------------------------------------------------------------

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
