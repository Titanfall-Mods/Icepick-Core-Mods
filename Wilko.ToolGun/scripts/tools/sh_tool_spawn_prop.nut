
bool function Toolgun_Func_SpawnProp( entity player, array<string> args )
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
	Toolgun_Func_SpawnAsset( Asset, Pos, Ang );

	Toolgun_Utils_FireToolTracer( player );
	return true
#else
	return false
#endif
}

#if SERVER
void function Toolgun_Func_SpawnAsset( asset Asset, vector Pos, vector Ang )
{
	thread Toolgun_Func_SpawnAssetThreaded( Asset, Pos, Ang );
}

void function Toolgun_Func_SpawnAssetThreaded( asset Asset, vector Pos, vector Ang )
{
	ToolgunData.LastSpawnTime = Time();

	PrecacheModel( Asset );
	while( !ModelIsPrecached( Asset ) )
	{
		wait 0.5;
	}

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
}
#endif
