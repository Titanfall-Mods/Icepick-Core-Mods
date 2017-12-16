
// DisablePrecacheErrors()
// wait 0.5

bool function Toolgun_Func_SpawnProp( entity player, array<string> args )
{
#if SERVER
	/*
	entity prop_dynamic = CreateEntity( "prop_dynamic" )
	prop_dynamic.SetValueForModelKey( ToolGunSettings.SelectedModel )
	prop_dynamic.kv.fadedist = -1
	prop_dynamic.kv.renderamt = 255
	prop_dynamic.kv.rendercolor = "255 255 255"
	prop_dynamic.kv.solid = 6 // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
	SetTeam( prop_dynamic, TEAM_BOTH )	// need to have a team other then 0 or it won't take impact damage

	entity player = GetPlayerByIndex( 0 )
	vector origin = player.EyePosition()
	vector angles = player.EyeAngles()
	vector forward = AnglesToForward( angles )

	prop_dynamic.SetOrigin( origin + forward * 200 )
	// prop_dynamic.SetAngles( Vector(RandomFloat(360), RandomFloat(360), RandomFloat(360)) )
	prop_dynamic.SetAngles( Vector(0, player.EyeAngles().y, 0) );
	DispatchSpawn( prop_dynamic )
	*/

	thread Toolgun_Func_SpawnProp_Precache();
	Toolgun_Utils_FireToolTracer( player );

	return true
#else
	return false
#endif
}

#if SERVER
void function Toolgun_Func_SpawnProp_Precache()
{

	// DisablePrecacheErrors()
	// wait 0.5
	PrecacheModel( ToolGunSettings.SelectedModel )
	// wait 0.5

	while( !ModelIsPrecached( ToolGunSettings.SelectedModel ) )
	{
		wait 0.5
	}

	entity prop_dynamic = CreateEntity( "prop_dynamic" )
	// prop_dynamic.SetValueForModelKey( SPAWN_MODEL )
	prop_dynamic.SetValueForModelKey( ToolGunSettings.SelectedModel )
	prop_dynamic.kv.fadedist = -1
	prop_dynamic.kv.renderamt = 255
	prop_dynamic.kv.rendercolor = "255 255 255"
	prop_dynamic.kv.solid = 6 // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
	SetTeam( prop_dynamic, TEAM_BOTH )	// need to have a team other then 0 or it won't take impact damage

	entity player = GetPlayerByIndex( 0 )
	vector origin = player.EyePosition()
	vector angles = player.EyeAngles()
	vector forward = AnglesToForward( angles )

	prop_dynamic.SetOrigin( origin + forward * 200 )
	// prop_dynamic.SetAngles( Vector(RandomFloat(360), RandomFloat(360), RandomFloat(360)) )
	prop_dynamic.SetAngles( Vector(0, player.EyeAngles().y, 0) );
	DispatchSpawn( prop_dynamic )

	ToolGunSettings.LastSpawnedEntity = prop_dynamic;

}
#endif
