untyped
global function Toolgun_RegisterTool_PropSpawner

table ToolPropSpawner = {};

void function Toolgun_RegisterTool_PropSpawner()
{
	// Create the tool
	ToolPropSpawner.id <- "prop_spawner";

	ToolPropSpawner.GetName <- function()
	{
		return "Prop Spawner";
	}

	ToolPropSpawner.GetHelp <- function()
	{
		string help = "Spawns the prop you last spawned at your aiming location.";
		if( ToolGunSettings.LastSpawnedModel != "" )
		{
			help += "\nSpawning: " + ToolGunSettings.LastSpawnedModel;
		}
		return help;
	}

	ToolPropSpawner.OnSelected <- function()
	{
	}

	ToolPropSpawner.OnDeselected <- function()
	{
	}

	ToolPropSpawner.OnFire <- function()
	{
	#if SERVER
		if( ToolGunSettings.LastSpawnedModel != "" )
		{
			entity player = GetPlayerByIndex( 0 );
			Toolgun_Utils_FireToolTracer( player );

			Spawnmenu_SpawnModel( ToolGunSettings.LastSpawnedModel );
		}
	#endif
		return false;
	}

	// Register the tool
	ToolGunTools.append( ToolPropSpawner );

}
