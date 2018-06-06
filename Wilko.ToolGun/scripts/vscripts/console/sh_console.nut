global function Console_Shared_Init
global function RegisterConVar
global function SetConVarValue
global function GetConVarValue

global struct ConCommand
{
	string Command,
	string AutocompleteText,
	string HelpText,
	void functionref( array<string>, string ) Func
}

global struct ConsoleDataStruct
{
	array<ConCommand> Commands,
	table< string, float > FloatConVars,
}

global ConsoleDataStruct ConsoleData

void function Console_Shared_Init()
{
#if CLIENT
	Console_Client_Init();
#elseif SERVER
	Console_Server_Init();
#endif
	Console_RegisterFunctions();
}

void function Console_RegisterFunctions()
{
	Console_RegisterFunc( "mylocation", Console_Command_PrintPlayerLocation, "mylocation", "Prints current player location to the external console" );
	Console_RegisterFunc( "currentmap", Console_Command_PrintCurrentMap, "currentmap", "Prints current map to the console" );
	Console_RegisterFunc( "teleport", Console_Command_TeleportToLocation, "teleport x y z", "Teleports the player to the specified coordinates" );
	Console_RegisterFunc( "kill_npcs", Console_Command_KillAllNPCs, "kill_npcs", "Removes all NPCs currently in the level" );
	Console_RegisterFunc( "give", Console_Command_GiveWeapon, "give weapon_name", "Gives the player the specified weapon" );
	Console_RegisterFunc( "list_weapons", Console_Command_ListPrecachedWeapons, "list_weapons", "Lists available weapons for this level in the console" );
	Console_RegisterFunc( "play", Console_Command_PlaySound, "play sound_name", "Play the sound on the local player" );

	Console_RegisterFunc( "concmd", Console_Command_ConCommand, "concmd original_command arg", "Perform a standard console command" );
	Console_RegisterFunc( "cc", Console_Command_ConCommand, "cc original_command arg", "Perform a standard console command" );
	Console_RegisterFunc( "firstperson", Console_Command_FirstPerson, "firstperson", "Enable first person mode" );
	Console_RegisterFunc( "thirdperson", Console_Command_ThirdPerson, "thirdperson", "Enable third person mode. Enables cheats!" );

	Console_RegisterFunc( "changelevel", Console_Command_ChangeLevel, "changelevel map startpoint", "Change to the specified level" );

	Console_RegisterFunc( "save", Console_Command_DumpSpawnedEnts, "save [name]", "Save all player spawned entities to a file in the Titanfall folder" );
	Console_RegisterFunc( "load_ents", Console_Command_LoadEntsFromFile, "load_ents", "Load all ents from a file in the Toolgun mod" );
}

void function Console_RegisterFunc( string command, void functionref( array<string>, string ) func, string autocompleteHelp, string helpText )
{
	ConCommand cmd
	cmd.Command = command
	cmd.AutocompleteText = autocompleteHelp
	cmd.HelpText = helpText
	cmd.Func = func
	ConsoleData.Commands.append( cmd )
}

void function RegisterConVar( string VarName, float InitialValue, string AutocompleteHelp, string HelpText )
{
	ConsoleData.FloatConVars[VarName] <- InitialValue;

	ConCommand cmd;
	cmd.Command = VarName;
	cmd.AutocompleteText = AutocompleteHelp;
	cmd.HelpText = "[ConVar] " + HelpText;
	cmd.Func = Console_Command_UpdateConVar;
	ConsoleData.Commands.append( cmd );
}

void function SetConVarValue( string VarName, float NewValue )
{
#if CLIENT
	// Update convar value on client
	ConsoleData.FloatConVars[VarName] <- NewValue;

	// Send convar value to server
	string InputString = VarName + " " + NewValue;
	GetLocalClientPlayer().ClientCommand( "Console_RunCommand " + InputString );
#endif
#if SERVER
	printc("[Error] SetConVarValue should not be used on the server as it doesn't do anything!");
#endif
}

float function GetConVarValue( string VarName, float DefaultValue )
{
	if( VarName in ConsoleData.FloatConVars )
	{
		return ConsoleData.FloatConVars[ VarName ];
	}
	else
	{
		printc("[Warning] " + VarName + " does not exist as a convar!");
		return DefaultValue;
	}
	unreachable;
}

// -----------------------------------------------------------------------------

void function Console_Command_TeleportToLocation( array<string> args, string command )
{
	#if CLIENT
	AddPlayerHint( 1.0, 0.25, $"", "Teleported to location" );
	#elseif SERVER
	float x = args[0].tofloat();
	float y = args[1].tofloat();
	float z = args[2].tofloat();
	GetPlayerByIndex( 0 ).SetOrigin( <x, y, z> );
	#endif
}

void function Console_Command_PrintPlayerLocation( array<string> args, string command )
{
	#if CLIENT
	printc( "Location: " + GetLocalClientPlayer().GetOrigin() + "\nEye angles: " + GetLocalClientPlayer().EyeAngles() );
	AddPlayerHint( 1.0, 0.25, $"", "Location printed to console" );
	#endif
}

void function Console_Command_PrintCurrentMap( array<string> args, string command )
{
	#if CLIENT
	printc( "Map: " + GetMapName() );
	AddPlayerHint( 1.0, 0.25, $"", "Map printed to console" );
	#endif
}

void function Console_Command_KillAllNPCs( array<string> args, string command )
{
	#if CLIENT
	AddPlayerHint( 1.0, 0.25, $"", "NPCs killed" );
	#elseif SERVER
	Console_Command_KillAllNPCClass( "npc_titan" );
	Console_Command_KillAllNPCClass( "npc_soldier" );
	Console_Command_KillAllNPCClass( "npc_soldier_shield_captain" );
	Console_Command_KillAllNPCClass( "npc_soldier_specialist" );
	Console_Command_KillAllNPCClass( "npc_spectre" );
	Console_Command_KillAllNPCClass( "npc_stalker" );
	Console_Command_KillAllNPCClass( "npc_turret_mega" );
	Console_Command_KillAllNPCClass( "npc_super_spectre" );
	Console_Command_KillAllNPCClass( "npc_drone_rocket" );
	Console_Command_KillAllNPCClass( "npc_prowler" );
	Console_Command_KillAllNPCClass( "npc_drone" );
	Console_Command_KillAllNPCClass( "npc_frag_drone" );
	Console_Command_KillAllNPCClass( "npc_drone_plasma" );
	Console_Command_KillAllNPCClass( "npc_drone_worker" );
	Console_Command_KillAllNPCClass( "npc_dropship" );
	Console_Command_KillAllNPCClass( "npc_marvin" );
	Console_Command_KillAllNPCClass( "npc_spectre" );
	Console_Command_KillAllNPCClass( "npc_stalker" );
	Console_Command_KillAllNPCClass( "npc_stalker_zombie" );
	Console_Command_KillAllNPCClass( "npc_super_spectre" );
	Console_Command_KillAllNPCClass( "npc_titan_atlas_tracker" );
	Console_Command_KillAllNPCClass( "npc_titan_stryder_leadwall" );
	Console_Command_KillAllNPCClass( "npc_titan_stryder_rocketeer" );
	Console_Command_KillAllNPCClass( "npc_titan_vanguard" );
	#endif
}

#if SERVER
void function Console_Command_KillAllNPCClass( string classname )
{
	array<entity> ents = GetEntArrayByClass_Expensive( classname )
	foreach ( ent in ents )
	{
		ent.Destroy()
	}
}
#endif

void function Console_Command_GiveWeapon( array<string> args, string command )
{
	#if SERVER
	entity player = GetPlayerByIndex( 0 );
	string weaponName = args[0];
	switch (weaponName)
	{
		case "toolgun":
		case "mozambique":
			weaponName = "mp_weapon_shotgun_pistol";
			break;
		case "car":
			weaponName = "mp_weapon_car";
			break;
		case "re45":
			weaponName = "mp_weapon_autopistol";
			break;
		case "charge_rifle":
			weaponName = "mp_weapon_defender";
			break;
		case "longbow":
		case "dmr":
			weaponName = "mp_weapon_dmr";
			break;
		case "doubletake":
			weaponName = "mp_weapon_doubletake";
			break;
		case "epg":
			weaponName = "mp_weapon_epg";
			break;
		case "devotion":
			weaponName = "mp_weapon_esaw";
			break;
		case "g2":
			weaponName = "mp_weapon_g2";
			break;
		case "hemlok":
			weaponName = "mp_weapon_hemlok";
			break;
		case "spitfire":
			weaponName = "mp_weapon_lmg";
			break;
		case "mastiff":
			weaponName = "mp_weapon_mastiff";
			break;
		case "mgl":
			weaponName = "mp_weapon_mgl";
			break;
		case "r101":
			weaponName = "mp_weapon_rspn101";
			break;
		case "r97":
			weaponName = "mp_weapon_r97";
			break;
		case "lstar":
			weaponName = "mp_weapon_lstar";
			break;
		case "shotgun":
			weaponName = "mp_weapon_shotgun";
			break;
		case "smart_pistol":
		case "sp":
			weaponName = "mp_weapon_smart_pistol";
			break;
		case "smr":
		case "sidewinder":
			weaponName = "mp_weapon_smr";
			break;
		case "sniper":
		case "kraber":
			weaponName = "mp_weapon_sniper";
			break;
		case "softball":
			weaponName = "mp_weapon_softball";
			break;
		case "flatline":
			weaponName = "mp_weapon_vinson";
			break;
		case "coldwar":
			weaponName = "mp_weapon_pulse_lmg";
			break;
		case "wingman":
			weaponName = "mp_weapon_wingman";
			break;
		case "pistol":
		case "p2011":
			weaponName = "mp_weapon_semipistol";
			break;
		case "archer":
			weaponName = "mp_weapon_rocket_launcher";
			break;
		case "alternator":
			weaponName = "mp_weapon_alternator_smg";
			break;
		case "volt":
			weaponName = "mp_weapon_hemlok_smg";
			break;
	}

	if( PlayerHasWeapon( player, weaponName ) )
	{
		printc( "Player already has weapon, " + weaponName );
		return;
	}
	if( GetAllPrecachedSPWeapons().find( weaponName ) == -1 )
	{
		printc( "Could not use weapon " + weaponName + " as it is not precached in this level." );
		return;
	}
	player.TakeWeaponNow( player.GetActiveWeapon().GetWeaponClassName() );
	player.GiveWeapon( weaponName );
	player.SetActiveWeaponByName( weaponName );
	#endif
}

void function Console_Command_PlaySound( array<string> args, string command )
{
	#if SERVER
	entity player = GetPlayerByIndex( 0 );
	EmitSoundOnEntity( player, args[0] );
	#endif
}

void function Console_Command_ListPrecachedWeapons( array<string> args, string command )
{
	#if SERVER
	string Output = "";
	foreach( weapon in GetAllPrecachedSPWeapons() )
	{
		Output += weapon + "\n";
	}
	printc( Output );
	#endif
}

void function Console_Command_ConCommand( array<string> args, string command )
{
	#if CLIENT
	string FullArgs = "";
	for( int i = 0; i < args.len(); ++i )
	{
		if( i > 0 )
		{
			FullArgs += " ";
		}
		FullArgs += args[i];
	}
	GetLocalClientPlayer().ClientCommand( FullArgs );
	#endif
}

void function Console_Command_FirstPerson( array<string> args, string command )
{
	#if CLIENT
	entity player = GetLocalClientPlayer();
	player.ClientCommand( "firstperson" );
	#endif
}

void function Console_Command_ThirdPerson( array<string> args, string command )
{
	#if CLIENT
	entity player = GetLocalClientPlayer();
	player.ClientCommand( "sv_cheats 1" );
	player.ClientCommand( "thirdperson" );
	player.ClientCommand( "thirdperson_mayamode 1" );
	player.ClientCommand( "thirdperson_screenspace 1" );
	#endif
}

void function Console_Command_ChangeLevel( array<string> args, string command )
{
	#if SERVER
	entity player = GetPlayerByIndex( 0 );
	LevelTransitionStruct trans;
	if( args.len() < 2 )
	{
		PlayerTransitionsToLevel( player, args[0], "", trans );
	}
	else
	{
		PlayerTransitionsToLevel( player, args[0], args[1], trans );
	}
	#endif
}

void function Console_Command_UpdateConVar( array<string> args, string command )
{
	string ConvarName = command;
	float Value = args[0].tofloat();
	ConsoleData.FloatConVars[ConvarName] <- Value;
}

// -----------------------------------------------------------------------------

void function _Write( string str )
{
	DevTextBufferWrite( str + "\n" );
}

void function Console_Command_DumpSpawnedEnts( array<string> args, string command )
{
	#if SERVER
	string OutputName = args.len() > 0 ? args[0] : "NoName";
	string OutputCodeName = args.len() > 0 ? args[0] : "NoName";
	string OutputFolder = "../ExportedGauntlet/";

	// Save spawned props
	DevTextBufferClear();
	_Write( "untyped" );
	_Write( "" );
	_Write( "globalize_all_functions" );
	_Write( "" );
	_Write( "struct SavedProp" );
	_Write( "{" );
	_Write( "	asset Asset," );
	_Write( "	vector Location," );
	_Write( "	vector Rotation" );
	_Write( "}" );
	_Write( "" );
	_Write( "array< SavedProp > " + OutputCodeName + "_SavedProps;" );
	_Write( "" );
	_Write( "void function " + OutputCodeName + "_InitProps()" );
	_Write( "{" );

	for( int i = 0; i < ToolgunData.SpawnedEntities.len(); ++i )
	{
		entity ent = ToolgunData.SpawnedEntities[i];
		string PropIdx = "prop" + i;

		_Write( "	" + "SavedProp " + PropIdx + ";" );
		_Write( "	" + PropIdx + ".Asset = " + ent.GetModelName() + ";" );
		_Write( "	" + PropIdx + ".Location = " + ent.GetOrigin() + ";" );
		_Write( "	" + PropIdx + ".Rotation = " + ent.GetAngles() + ";" );
		_Write( "	" + OutputCodeName + "_SavedProps.append( " + PropIdx + " );" );
		_Write( "" );
	}

	_Write( "}" );
	DevTextBufferDumpToFile( OutputFolder + "saved_props.nut" );

	// Save spawned ziplines
	DevTextBufferClear();
	_Write( "untyped" );
	_Write( "" );
	_Write( "globalize_all_functions" );
	_Write( "" );
	_Write( "struct SavedZipline" );
	_Write( "{" );
	_Write( "	vector Start," );
	_Write( "	vector End" );
	_Write( "}" );
	_Write( "" );
	_Write( "array< SavedZipline > " + OutputCodeName + "_SavedZiplines;" );
	_Write( "" );
	_Write( "void function " + OutputCodeName + "_InitZipline()" );
	_Write( "{" );

	for( int i = 0; i < PlacedZiplines.len(); ++i )
	{
		string ZipIdx = "zipline" + i;

		_Write( "	" + "SavedZipline " + ZipIdx + ";" );
		_Write( "	" + ZipIdx + ".Start = " + PlacedZiplines[i].StartLocation + ";" );
		_Write( "	" + ZipIdx + ".End = " + PlacedZiplines[i].EndLocation + ";" );
		_Write( "	" + OutputCodeName + "_SavedZiplines.append( " + ZipIdx + " );" );
		_Write( "" );
	}

	_Write( "}" );
	DevTextBufferDumpToFile( OutputFolder + "saved_ziplines.nut" );

	// Save spawned gauntlet entities
	DevTextBufferClear();
	_Write( "untyped" );
	_Write( "" );
	_Write( "globalize_all_functions" );
	_Write( "" );
	_Write( "void function " + OutputCodeName + "_InitGauntlet()" );
	_Write( "{" );

	_Write( "	GauntletTrack NewTrack;" );
	_Write( "	NewTrack.Id = \"" + CustomGauntletsGlobal.DevelopmentTrack.Id + "\";" );
	_Write( "	NewTrack.TrackName = \"" + CustomGauntletsGlobal.DevelopmentTrack.TrackName + "\";" );
	_Write( "	NewTrack.Tips = [" );
	for( int i = 0; i < CustomGauntletsGlobal.DevelopmentTrack.Tips.len(); ++i )
	{
		_Write( "		\"" + CustomGauntletsGlobal.DevelopmentTrack.Tips[i] + "\"," );
	}
	_Write( "	];" );
	_Write( "" );

	if( CustomGauntletsGlobal.DevelopmentTrack.StartLine.IsValid )
	{
		_Write( "	GauntletTriggerLine StartLine;" );
		_Write( "	StartLine.From = " + CustomGauntletsGlobal.DevelopmentTrack.StartLine.From + ";" );
		_Write( "	StartLine.To = " + CustomGauntletsGlobal.DevelopmentTrack.StartLine.To + ";" );
		_Write( "	NewTrack.StartLine = StartLine;" );
	}
	else
	{
		_Write( "	// No Start Line" );
	}
	_Write( "" );

	if( CustomGauntletsGlobal.DevelopmentTrack.FinishLine.IsValid )
	{
		_Write( "	GauntletTriggerLine FinishLine;" );
		_Write( "	FinishLine.From = " + CustomGauntletsGlobal.DevelopmentTrack.FinishLine.From + ";" );
		_Write( "	FinishLine.To = " + CustomGauntletsGlobal.DevelopmentTrack.FinishLine.To + ";" );
		_Write( "	NewTrack.FinishLine = FinishLine;" );
	}
	else
	{
		_Write( "	// No Finish Line" );
	}
	_Write( "" );

	for( int i = 0; i < CustomGauntletsGlobal.DevelopmentTrack.Targets.len(); ++i )
	{
		string EnemyIdx = "Enemy" + i;

		_Write( "	TargetEnemy " + EnemyIdx + ";" );
		_Write( "	" + EnemyIdx + ".Position = " + CustomGauntletsGlobal.DevelopmentTrack.Targets[i].Position + ";" );
		_Write( "	" + EnemyIdx + ".Rotation = " + CustomGauntletsGlobal.DevelopmentTrack.Targets[i].Rotation + ";" );
		_Write( "	" + EnemyIdx + ".EnemyType = \"" + CustomGauntletsGlobal.DevelopmentTrack.Targets[i].EnemyType + "\";" );
		_Write( "	NewTrack.Targets.append( " + EnemyIdx + " );" );
		_Write( "" );
	}
	if( CustomGauntletsGlobal.DevelopmentTrack.Targets.len() == 0 )
	{
		_Write( "	// No Targets" );
	}
	_Write( "" );

	_Write( "}" );
	DevTextBufferDumpToFile( OutputFolder + "saved_gauntlet.nut" );

	// Save mod file
	DevTextBufferClear();
	_Write( "{" );
	_Write( "	\"Name\" : \"" + OutputCodeName + " Gauntlet\"," );
	_Write( "	\"Description\" : \"" + OutputCodeName + " Gauntlet\"," );
	_Write( "	\"Authors\" : [" );
	_Write( "		\"" + GetPlayerByIndex( 0 ).GetPlayerName() + "\"" );
	_Write( "	]," );
	_Write( "	\"Contacts\" : [" );
	_Write( "		\"" + GetPlayerByIndex( 0 ).GetPlayerName() + "\"" );
	_Write( "	]," );
	_Write( "	\"Version\" : 1.0," );
	_Write( "	" );
	_Write( "	\"Files\" : [" );
	_Write( "		{" );
	_Write( "			\"Chunk\" : \"sp/_sp_sh_init.gnut\"," );
	_Write( "			\"Appends\" : [" );
	_Write( "				\"saved_props.nut\"," );
	_Write( "				\"saved_ziplines.nut\"," );
	_Write( "				\"saved_gauntlet.nut\"" );
	_Write( "			]" );
	_Write( "		}" );
	_Write( "	]" );
	_Write( "}" );
	DevTextBufferDumpToFile( OutputFolder + "mod.json" );

	#elseif CLIENT
	AddPlayerHint( 2.0, 0.25, $"", "Dumped to Titanfall 2 directory!" );
	#endif
}

void function Console_Command_LoadEntsFromFile( array<string> args, string command )
{
	#if SERVER
	// for(int i = 0; i < ToolgunSavedEnts_Assets.len(); ++i)
	// {
	// 	asset Asset = ToolgunSavedEnts_Assets[i];
	// 	vector Pos = ToolgunSavedEnts_Locations[i];
	// 	vector Ang = ToolgunSavedEnts_Angles[i];
	// 	Toolgun_Func_SpawnAsset( Asset, Pos, Ang );
	// }
	#elseif CLIENT
	AddPlayerHint( 2.0, 0.25, $"", "Loaded ents from file spawned_ents" );
	#endif
}
