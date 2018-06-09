
global function Spawnmenu_Init
global function Spawnmenu_SelectTool
global function Spawnmenu_GiveWeapon
global function Spawnmenu_GiveAbility
global function Spawnmenu_GiveGrenade
global function Spawnmenu_GiveMelee
global function Spawnmenu_SpawnModel


global function Spawnmenu_SpawnGrunt

struct
{
	bool isSpawnMenuOpen
} file


void function Spawnmenu_Init()
{
	#if CLIENT
	RegisterButtonPressedCallback( KEY_F1, Spawnmenu_ToggleOpen );
	#endif
	#if SERVER
	AddClientCommandCallback( "Spawnmenu_PerformSpawnModel", ClientCommand_Spawnmenu_PerformSpawnModel );
	#endif
}

#if CLIENT
void function Spawnmenu_ToggleOpen( var button )
{
	file.isSpawnMenuOpen = !file.isSpawnMenuOpen;
	if( file.isSpawnMenuOpen )
	{
		ShowCursor();
	}
	else
	{
		HideCursor();
	}
}
#endif

void function Spawnmenu_SelectTool( string toolId )
{
#if CLIENT
	Toolgun_Client_SelectTool( toolId );
#endif
}

void function Spawnmenu_GiveWeapon( string weaponId )
{
#if SERVER
	entity player = GetPlayerByIndex( 0 );
	player.TakeWeaponNow( player.GetActiveWeapon().GetWeaponClassName() );
	player.GiveWeapon( weaponId );
	player.SetActiveWeaponByName( weaponId );
#endif
}

void function Spawnmenu_GiveAbility( string abilityId )
{
#if SERVER
	entity player = GetPlayerByIndex( 0 );
	entity weapon = player.GetOffhandWeapon( OFFHAND_SPECIAL );
	player.TakeWeaponNow( weapon.GetWeaponClassName() );
	player.GiveOffhandWeapon( abilityId, OFFHAND_SPECIAL );
#endif
}

void function Spawnmenu_GiveGrenade( string abilityId )
{
#if SERVER
	entity player = GetPlayerByIndex( 0 );
	entity weapon = player.GetOffhandWeapon( OFFHAND_ORDNANCE );
	printt("take", weapon.GetWeaponClassName());
	if( weapon.GetWeaponClassName() != abilityId )
	{
		printt("take weapon >:(");
		player.TakeWeaponNow( weapon.GetWeaponClassName() );
		player.GiveOffhandWeapon( abilityId, OFFHAND_ORDNANCE );
	}
	else if( weapon.GetWeaponPrimaryClipCount() < weapon.GetWeaponPrimaryClipCountMax() )
	{
		weapon.SetWeaponPrimaryClipCount( weapon.GetWeaponPrimaryClipCount() + 1 );
	}
#endif
}

void function Spawnmenu_GiveMelee( string abilityId )
{
#if SERVER
	entity player = GetPlayerByIndex( 0 );
	entity weapon = player.GetOffhandWeapon( OFFHAND_MELEE );
	player.TakeWeaponNow( weapon.GetWeaponClassName() );
	player.GiveOffhandWeapon( abilityId, OFFHAND_MELEE );
#endif
}

void function Spawnmenu_SpawnGrunt( string gruntId )
{
#if SERVER
	entity player = GetPlayerByIndex( 0 );
	vector origin = player.EyePosition()
	vector angles = player.EyeAngles()
	vector forward = AnglesToForward( angles )
	TraceResults result = TraceLine( origin, origin + forward * 2000, player )
	angles.x = 0
	angles.z = 0

	int team = gruntId == "imc" ? TEAM_IMC : TEAM_MILITIA;
	entity guy = CreateSoldier( team, result.endPos, angles )
	DispatchSpawn( guy )
#endif
}

void function Spawnmenu_SpawnModel( string modelName )
{
#if CLIENT
	// HACK: bullshit way to get around issue where spawning from SDK code directly doesn't override precaching
	GetLocalClientPlayer().ClientCommand( "Spawnmenu_PerformSpawnModel \"" + modelName + "\"" );
#endif
}

bool function ClientCommand_Spawnmenu_PerformSpawnModel( entity player, array<string> args )
{
#if SERVER
	string modelName = args[0];
	asset spawnAsset = $"";
	// HACK: Awful, slow way to find asset
	foreach( a in CurrentLevelSpawnList )
	{
		string assetName = "" + a;
		if( assetName.find( modelName ) != null )
		{
			spawnAsset = a;
		}
	}

	if( spawnAsset == $"" )
	{
		return false;
	}

	entity player = GetPlayerByIndex( 0 );
	vector origin = player.EyePosition();
	vector angles = player.EyeAngles();
	vector forward = AnglesToForward( angles );
	TraceResults traceResults = TraceLine( origin, angles + forward * 10000, player, TRACE_MASK_PLAYERSOLID | TRACE_MASK_TITANSOLID | TRACE_MASK_NPCWORLDSTATIC | TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE );

	vector Pos = traceResults.endPos;
	vector Ang = Vector( 0, player.EyeAngles().y, 0 );
	
	EnableExternalSpawnMode();

	entity prop_dynamic = CreateEntity( "prop_dynamic" );
	prop_dynamic.SetValueForModelKey( spawnAsset );
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
#endif
	return true;
}
