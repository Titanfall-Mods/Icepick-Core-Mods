
global function IcepickAllowSpawnmenu
global function IcepickAllowNoclip

global function Spawnmenu_Init
global function Spawnmenu_SelectTool
global function Spawnmenu_GiveWeapon
global function Spawnmenu_GiveWeaponMod
global function Spawnmenu_GiveAbility
global function Spawnmenu_GiveGrenade
global function Spawnmenu_GiveMelee
global function Spawnmenu_GiveTitanDefensive
global function Spawnmenu_GiveTitanTactical
global function Spawnmenu_GiveCore
global function Spawnmenu_SpawnModel
global function Spawnmenu_SpawnModelWithParams
global function Spawnmenu_SpawnModelAssetWithParams
global function Spawnmenu_SpawnNpc
global function Spawnmenu_SpawnTitan
global function Spawnmenu_SpawnBossTitan
global function Spawnmenu_SaveGame
global function Spawnmenu_SaveGameToFile
global function Spawnmenu_SaveCheckpoint
global function Spawnmenu_ChangePlayerInvincibility

global function Spawnmenu_ToggleEditMode
global function AddOnEditModeChangedCallback

global function AddOnToolOptionUpdateCallback
global function Spawnmenu_UpdateToolOption

#if SERVER
global function AddOnPlayerInstantRespawnedCallback
#endif

struct
{
	bool isSpawnMenuOpen
	array<void functionref(string id, var value)> onToolOptionChangedCallbacks
	array<void functionref()> onToolEditModeChangedCallbacks
	array<void functionref(entity player)> onPlayerInstantlyRespawnedCallbacks
} file

void function Spawnmenu_Init()
{
	#if CLIENT
	ClearSpawnmenu(); // Clear spawnmenu items from previous session
	#endif

	#if SERVER
	AddSpawnCallback( "player", Spawnmenu_OnPlayerSpawnedCallback );

	AddClientCommandCallback( "do_instant_respawn", ClientCommand_Spawnmenu_OnPlayerInstantRespawn );
	#endif
}

void function IcepickAllowSpawnmenu()
{
#if CLIENT
	RegisterConCommandTriggeredCallback( "+showscores", Spawnmenu_ToggleOpen );
	RegisterConCommandTriggeredCallback( "instant_respawn", Spawnmenu_Cl_InstantRespawn );
#endif
}

void function IcepickAllowNoclip()
{
#if SERVER
	// IsNoclipping only exists on the server, so serve noclip requests by sending them to the server first
	// Command is bound and activated from scripts/kb_act.lst
	AddClientCommandCallback( "toggle_noclip", ClientCommand_Spawnmenu_RequestNoclipToggle );
#endif
}

#if CLIENT
void function Spawnmenu_ToggleOpen( entity player )
{
	if( IsSpawnMenuOpen() == 0 )
	{
		GetLocalClientPlayer().ClientCommand( "show_icepick_menu" );
	}
	else
	{
		GetLocalClientPlayer().ClientCommand( "hide_icepick_menu" );
	}
}
#endif

#if SERVER
void function Spawnmenu_OnPlayerSpawnedCallback( entity player )
{
	thread Spawnmenu_OnPlayerSpawnedCallback_Thread( player );
}

void function Spawnmenu_OnPlayerSpawnedCallback_Thread( entity player )
{
	wait 1.0;
	Spawnmenu_ChangePlayerInvincibility( IsInvincibilityEnabled() == 1 );
}

bool function ClientCommand_Spawnmenu_RequestNoclipToggle( entity player, array<string> args )
{
	if( player.IsNoclipping() )
	{
		ClientCommand( player, "noclip_disable" );
	}
	else
	{
		ClientCommand( player, "noclip_enable" );
	}
	return true;
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
	array<entity> weapons = player.GetMainWeapons()
	string weaponToSwitch = player.GetLatestPrimaryWeapon().GetWeaponClassName()

	if ( player.GetActiveWeapon() != player.GetAntiTitanWeapon() )
	{
		foreach ( weapon in weapons )
		{
			string weaponClassName = weapon.GetWeaponClassName()
			if ( weaponClassName == weaponId )
			{
				weaponToSwitch = weaponClassName
				break
			}
		}
	}

	player.TakeWeaponNow( weaponToSwitch )
	player.GiveWeapon( weaponId )
	player.SetActiveWeaponByName( weaponId )

#endif
}

void function Spawnmenu_GiveWeaponMod( string modId )
{
#if SERVER
	entity player = GetPlayerByIndex( 0 );
	entity weapon = player.GetActiveWeapon();
	if( weapon != null )
	{
		string weaponId = weapon.GetWeaponClassName();
		array<string> mods = weapon.GetMods();

		bool removed = false;
		for( int i = 0; i < mods.len(); ++i )
		{
			if( mods[i] == modId )
			{
				mods.remove( i );
				removed = true;
				break;
			}
		}
		if( !removed )
		{
			mods.append( modId );
		}

		player.TakeWeaponNow( weaponId );
		player.GiveWeapon( weaponId, mods );
		player.SetActiveWeaponByName( weaponId );
	}
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
	if( weapon.GetWeaponClassName() != abilityId )
	{
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

void function Spawnmenu_GiveTitanDefensive( string abilityId )
{
#if SERVER
	entity player = GetPlayerByIndex( 0 );
	entity weapon = player.GetOffhandWeapon( OFFHAND_SPECIAL );
	player.TakeWeaponNow( weapon.GetWeaponClassName() );
	player.GiveOffhandWeapon( abilityId, OFFHAND_SPECIAL );
#endif
}

void function Spawnmenu_GiveTitanTactical( string abilityId )
{
#if SERVER
	entity player = GetPlayerByIndex( 0 );
	entity weapon = player.GetOffhandWeapon( OFFHAND_TITAN_CENTER );
	player.TakeWeaponNow( weapon.GetWeaponClassName() );
	player.GiveOffhandWeapon( abilityId, OFFHAND_TITAN_CENTER );
#endif
}

void function Spawnmenu_GiveCore( string abilityId )
{
	printt("Spawnmenu_GiveCore!", abilityId)
#if SERVER
	entity player = GetPlayerByIndex( 0 );
	entity titan =  player.GetPetTitan();

	if( abilityId == "recharge" )
	{
		// recharge titan core
		entity soul = titan.GetTitanSoul();
		SoulTitanCore_SetNextAvailableTime( soul, 0.0 );

		printt("RECHARGE CORE");
		return;
	}

	entity weapon = titan.GetOffhandWeapon( OFFHAND_EQUIPMENT );
	titan.TakeWeaponNow( weapon.GetWeaponClassName() );
	titan.GiveOffhandWeapon( abilityId, OFFHAND_EQUIPMENT );

	CoreActivate( player );

	printt("ACTIVATE CORE");
#endif
}

void function Spawnmenu_SpawnModel( string modelName )
{
#if SERVER
	entity player = GetPlayerByIndex( 0 );
	Toolgun_Utils_FireToolTracer( player );

	vector eyePosition = player.EyePosition();
	TraceResults traceResults = TraceLineHighDetail( eyePosition, eyePosition + player.GetViewVector() * 10000, player, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER );

	vector Pos = traceResults.endPos;
	vector Ang = Vector( 0, player.EyeAngles().y, 0 );
	
	Spawnmenu_SpawnModelWithParams( modelName, Pos, Ang );
#endif

	ToolGunSettings.LastSpawnedModel = modelName;
}

void function Spawnmenu_SpawnModelWithParams( string modelName, vector position, vector angles )
{
#if SERVER
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
		return;
	}

	Spawnmenu_SpawnModelAssetWithParams( spawnAsset, position, angles );
#endif
}

void function Spawnmenu_SpawnModelAssetWithParams( asset spawnAsset, vector position, vector angles )
{
#if SERVER
	EnableExternalSpawnMode();

	entity prop_dynamic = CreateEntity( "prop_dynamic_lightweight" );
	prop_dynamic.SetValueForModelKey( spawnAsset );
	prop_dynamic.kv.fadedist = -1;
	prop_dynamic.kv.renderamt = 255;
	prop_dynamic.kv.rendercolor = "255 255 255";
	prop_dynamic.kv.solid = 6; // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
	SetTeam( prop_dynamic, TEAM_BOTH );	// need to have a team other then 0 or it won't take impact damage

	prop_dynamic.SetOrigin( position );
	prop_dynamic.SetAngles( angles );
	DispatchSpawn( prop_dynamic );

	ToolgunData.SpawnedEntities.append( prop_dynamic );
	
	DisableExternalSpawnMode();
#endif
}

void function Spawnmenu_SpawnNpc( string npcId )
{
#if SERVER
	entity player = GetPlayerByIndex( 0 );
	vector eyePosition = player.EyePosition();
	vector angles = player.EyeAngles();
	TraceResults result = TraceLine( eyePosition, eyePosition + player.GetViewVector() * 10000, player, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER );

	angles.x = 0;
	angles.z = 0;

	vector spawnPos = result.endPos;
	vector spawnAng = angles;
	int team = TEAM_IMC;

	entity spawnNpc = null;
	switch( npcId )
	{
		case "npc_soldier":
			spawnNpc = CreateSoldier( team, spawnPos, spawnAng );
			break;
		case "npc_soldier_shotgun":
			spawnNpc = CreateSoldier( team, spawnPos, spawnAng );
			SetSpawnOption_Weapon( spawnNpc, "mp_weapon_shotgun" );
			break;
		case "npc_soldier_smg":
			spawnNpc = CreateSoldier( team, spawnPos, spawnAng );
			SetSpawnOption_Weapon( spawnNpc, "mp_weapon_car" );
			break;
		case "npc_soldier_sniper":
			spawnNpc = CreateSoldier( team, spawnPos, spawnAng );
			SetSpawnOption_Weapon( spawnNpc, "mp_weapon_dmr" );
			break;
		case "npc_spectre":
			spawnNpc = CreateSpectre( team, spawnPos, spawnAng );
			break;
		case "npc_stalker":
			spawnNpc = CreateStalker( team, spawnPos, spawnAng );
			break;
		case "npc_stalker_zombie":
			spawnNpc = CreateZombieStalker( team, spawnPos, spawnAng );
			break;
		case "npc_stalker_zombie_mossy":
			spawnNpc = CreateZombieStalkerMossy( team, spawnPos, spawnAng );
			break;
		case "npc_super_spectre":
			spawnNpc = CreateSuperSpectre( team, spawnPos, spawnAng );
			break;
		case "npc_frag_drone":
			spawnNpc = CreateFragDrone( team, spawnPos, spawnAng );
			break;
		case "npc_drone":
			spawnNpc = CreateGenericDrone( team, spawnPos, spawnAng );
			break;
		case "npc_drone_rocket":
			spawnNpc = CreateRocketDrone( team, spawnPos, spawnAng );
			break;
		case "npc_drone_shield":
			spawnNpc = CreateShieldDrone( team, spawnPos, spawnAng );
			break;
		case "npc_drone_plasma":
			spawnNpc = CreateRocketDrone( team, spawnPos, spawnAng );
			SetSpawnOption_Weapon( spawnNpc, "mp_weapon_droneplasma" );
			break;
		case "npc_drone_worker":
			spawnNpc = CreateWorkerDrone( team, spawnPos, spawnAng );
			break;
		case "npc_titan_bt":
			spawnNpc = CreateNPCTitan( "titan_buddy", TEAM_MILITIA, spawnPos, spawnAng, [] );
			SetSpawnOption_AISettings( spawnNpc, "npc_titan_buddy" );
			break;
		case "npc_titan_bt_spare":
			spawnNpc = CreateNPCTitan( "titan_buddy", TEAM_MILITIA, spawnPos, spawnAng, [] );
			SetSpawnOption_AISettings( spawnNpc, "npc_titan_buddy" );
			break;
	}
	DispatchSpawn( spawnNpc );
#endif
}

void function Spawnmenu_SpawnTitan( string titanId )
{
#if SERVER
	entity player = GetPlayerByIndex( 0 );
	vector origin = GetPlayerCrosshairOrigin( player );
	vector angles = player.EyeAngles();
	angles.x = 0;
	angles.z = 0;

	vector spawnPos = origin;
	vector spawnAng = angles;
	int team = TEAM_IMC;

	entity spawnNpc = CreateNPCTitan( "npc_titan", team, spawnPos, spawnAng, [] );
	SetSpawnOption_NPCTitan( spawnNpc, TITAN_HENCH );
	SetSpawnOption_AISettings( spawnNpc, titanId );
	DispatchSpawn( spawnNpc );
#endif
}

void function Spawnmenu_SpawnBossTitan( string bossId )
{
#if SERVER
	const CROSSHAIR_VERT_OFFSET = 32;

	TitanLoadoutDef ornull loadout = GetTitanLoadoutForBossCharacter( bossId );
	printt("loadout is null: ", loadout == null );
	if ( loadout == null )
	{
		return;
	}
	expect TitanLoadoutDef( loadout );
	string baseClass = "npc_titan";
	string aiSettings = GetNPCSettingsFileForTitanPlayerSetFile( loadout.setFile );

	entity player = GetPlayerByIndex( 0 );
	vector origin = GetPlayerCrosshairOrigin( player );
	vector angles = Vector( 0, 0, 0 );
	entity npc = CreateNPC( baseClass, TEAM_IMC, origin, angles );
	if ( IsTurret( npc ) )
	{
		npc.kv.origin -= Vector( 0, 0, CROSSHAIR_VERT_OFFSET );
	}
	SetSpawnOption_AISettings( npc, aiSettings );

	if ( npc.GetClassName() == "npc_titan" )
	{
		string builtInLoadout = expect string( Dev_GetAISettingByKeyField_Global( aiSettings, "npc_titan_player_settings" ) )
		SetTitanSettings( npc.ai.titanSettings, builtInLoadout );
		npc.ai.titanSpawnLoadout.setFile = builtInLoadout;
		OverwriteLoadoutWithDefaultsForSetFile( npc.ai.titanSpawnLoadout ); // get the entire loadout, including defensive and tactical
	}

	SetSpawnOption_NPCTitan( npc, TITAN_MERC );
	SetSpawnOption_TitanLoadout( npc, loadout );
	npc.ai.bossTitanPlayIntro = false;
	DispatchSpawn( npc );
#endif
}

void function Spawnmenu_ToggleEditMode()
{
#if CLIENT
	GetLocalClientPlayer().ClientCommand( "toggle_toolgun" );
	thread WaitAndToggleEditMode();	
#endif
}

#if CLIENT
void function WaitAndToggleEditMode()
{
	WaitFrame();

	foreach ( callbackFunc in file.onToolEditModeChangedCallbacks )
	{
		callbackFunc();
	}
}
#endif

void function AddOnEditModeChangedCallback( void functionref() callbackFunc )
{
	Assert( !file.onToolEditModeChangedCallbacks.contains( callbackFunc ), "Already added " + string( callbackFunc ) + " with AddOnEditModeChangedCallback" );
	file.onToolEditModeChangedCallbacks.append( callbackFunc );
}

void function Spawnmenu_SaveGame()
{
#if SERVER
	IcepickSave();
#endif
}

void function Spawnmenu_SaveGameToFile( string saveName )
{
#if SERVER
	IcepickSave( saveName );
#endif
}

void function Spawnmenu_SaveCheckpoint()
{
#if SERVER
	// Save the game using the inbuilt checkpoint system so that we can come back to things later
	CheckPoint_Forced();
#endif
}

void function AddOnToolOptionUpdateCallback( void functionref(string id, var value) callbackFunc )
{
	Assert( !file.onToolOptionChangedCallbacks.contains( callbackFunc ), "Already added " + string( callbackFunc ) + " with AddOnToolOptionUpdateCallback" );
	file.onToolOptionChangedCallbacks.append( callbackFunc );
}

void function Spawnmenu_UpdateToolOption( string id, var value )
{
	foreach ( callbackFunc in file.onToolOptionChangedCallbacks )
	{
		callbackFunc( id, value );
	}
}

void function Spawnmenu_ChangePlayerInvincibility( bool wantsInvincibility )
{
#if SERVER
	entity player = GetPlayerByIndex( 0 );

	if( wantsInvincibility )
	{
		EnableDemigod( player )
	}
	else
	{
		if( IsDemigod( player ) )
		{
			DisableDemigod( player );
		}
	}
#endif
}

#if CLIENT
// HACK: Listen to the concommand on the client and perform a new client command to get the command to actually trigger
void function Spawnmenu_Cl_InstantRespawn( var button )
{
	GetLocalClientPlayer().ClientCommand( "do_instant_respawn" );
}
#endif

#if SERVER
void function AddOnPlayerInstantRespawnedCallback( void functionref(entity) callbackFunc )
{
	Assert( !file.onPlayerInstantlyRespawnedCallbacks.contains( callbackFunc ), "Already added " + string( callbackFunc ) + " with AddOnPlayerInstantRespawnedCallback" );
	file.onPlayerInstantlyRespawnedCallbacks.append( callbackFunc );
}

bool function ClientCommand_Spawnmenu_OnPlayerInstantRespawn( entity player, array<string> args )
{
	// Teleport the player to a valid spawnpoint
	entity start = GetRandomStartPointFromAll();
	player.SetOrigin( start.GetOrigin() );
	player.SetAngles( start.GetAngles() );

	// Play some simple fx
	EmitSoundAtPosition( TEAM_UNASSIGNED, start.GetOrigin(), "training_scr_zen_player_fall" );

	// Perform a callback so we can listen to players returning
	foreach ( callbackFunc in file.onPlayerInstantlyRespawnedCallbacks )
	{
		callbackFunc( player );
	}

	return true;
}
#endif
