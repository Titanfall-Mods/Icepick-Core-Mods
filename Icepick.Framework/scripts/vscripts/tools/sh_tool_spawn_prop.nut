untyped
global function Toolgun_RegisterTool_SpawnProp;

table ToolSpawnProp = {};

void function Toolgun_RegisterTool_SpawnProp()
{
	// Create the tool
	ToolSpawnProp.id <- "spawn_prop";

	ToolSpawnProp.GetName <- function()
	{
		return "Spawner";
	}

	ToolSpawnProp.GetHelp <- function()
	{
		return "Fire to spawn a prop.";
	}

	ToolSpawnProp.OnSelected <- function()
	{
	}

	ToolSpawnProp.OnDeselected <- function()
	{
	}

	ToolSpawnProp.OnFire <- function()
	{
	#if SERVER

		// HACK: stop props from being spawned too quick, fixes issue where server will start to spawn multiple of the same prop after a while?
		if( Time() - ToolgunData.LastSpawnTime < 0.25 )
		{
			return false;
		}

		entity player = GetPlayerByIndex( 0 );
		vector origin = player.EyePosition();
		vector angles = player.EyeAngles();
		vector forward = AnglesToForward( angles );

		asset Asset = IsValid(ToolGunSettings.SelectedModel) ? ToolGunSettings.SelectedModel : CurrentLevelSpawnList[0];
		vector Pos = origin + forward * 200;
		vector Ang = Vector(0, player.EyeAngles().y, 0);
		
		EnableExternalSpawnMode();

		entity prop_dynamic = CreateEntity( "prop_dynamic" );
		prop_dynamic.SetValueForModelKey( Asset );
		prop_dynamic.kv.fadedist = -1;
		prop_dynamic.kv.renderamt = 255;
		prop_dynamic.kv.rendercolor = "255 255 255";
		prop_dynamic.kv.solid = 6; // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
		SetTeam( prop_dynamic, TEAM_BOTH );	// need to have a team other then 0 or it won't take impact damage

		prop_dynamic.SetOrigin( Pos );
		prop_dynamic.SetAngles( Ang );
		DispatchSpawn( prop_dynamic );
		
		ToolgunData.SpawnedEntities.append( prop_dynamic );

		DisableExternalSpawnMode();

		Toolgun_Utils_FireToolTracer( player );
		return true;

	#else
		return false;
	#endif
	}

	// Register the tool
	ToolGunTools.append( ToolSpawnProp );
	
}
