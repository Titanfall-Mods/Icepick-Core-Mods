
global function Spawnmenu_Init
global function Spawnmenu_SelectTool
global function Spawnmenu_GiveWeapon
global function Spawnmenu_GiveAbility
global function Spawnmenu_GiveGrenade
global function Spawnmenu_GiveMelee
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
}

#if CLIENT
void function Spawnmenu_ToggleOpen( var button )
{
	file.isSpawnMenuOpen = !file.isSpawnMenuOpen;
	if( file.isSpawnMenuOpen )
	{
		printt("open spawnmenu");
		ShowCursor();
	}
	else
	{
		printt("close spawnmenu");
		HideCursor();
	}
}
#endif

void function Spawnmenu_SelectTool( string toolId )
{

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
	player.TakeWeaponNow( weapon.GetWeaponClassName() );
	player.GiveOffhandWeapon( abilityId, OFFHAND_ORDNANCE );
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
