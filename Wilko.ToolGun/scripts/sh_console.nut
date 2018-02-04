
struct ConCommand
{
	string Command,
	string AutocompleteText,
	string HelpText,
	void functionref( array<string>, string ) Func
};

struct
{
	array<ConCommand> Commands,
	table< string, float > FloatConVars,
} ConsoleData;

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
	Console_RegisterFunc( "teleport", Console_Command_TeleportToLocation, "teleport x y z", "Teleports the player to the specified coordinates" );
	Console_RegisterFunc( "kill_npcs", Console_Command_KillAllNPCs, "kill_npcs", "Removes all NPCs currently in the level" );
	Console_RegisterFunc( "give", Console_Command_GiveWeapon, "give weapon_name", "Gives the player the specified weapon" );
	Console_RegisterFunc( "list_weapons", Console_Command_ListPrecachedWeapons, "list_weapons", "Lists available weapons for this level in the console" );

	Console_RegisterFunc( "save_ents", Console_Command_DumpSpawnedEnts, "save_ents", "Save all player spawned entities to a file in the Titanfall folder" );
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

void function Console_Command_DumpSpawnedEnts( array<string> args, string command )
{
	#if SERVER
	string AssetsOut = "\narray<asset> ToolgunSavedEnts_Assets = [\n";
	string LocationsOut = "\narray<vector> ToolgunSavedEnts_Locations = [\n";
	string AnglesOut = "\narray<vector> ToolgunSavedEnts_Angles = [\n";
	int NumEnts = ToolgunData.SpawnedEntities.len();

	for( int i = 0; i < NumEnts; ++i )
	{
		entity ent = ToolgunData.SpawnedEntities[i];
		string LineEndChar = (i == NumEnts - 1 ? "\n" : ", \n");
		vector Pos = ent.GetOrigin();
		vector Ang = ent.GetAngles();

		AssetsOut += "\t" + ent.GetModelName() + LineEndChar;
		LocationsOut += "\t< " + Pos.x + ", " + Pos.y + ", " + Pos.z + " >" + LineEndChar;
		AnglesOut += "\t< " + Ang.x + ", " + Ang.y + ", " + Ang.z + " >" + LineEndChar;
	}

	AssetsOut += "];";
	LocationsOut += "];";
	AnglesOut += "];";

	DevTextBufferClear();
	DevTextBufferWrite( AssetsOut );
	DevTextBufferWrite( LocationsOut );
	DevTextBufferWrite( AnglesOut );
	DevTextBufferDumpToFile( "../spawned_ents.txt" );
	DevTextBufferClear();
	#elseif CLIENT
	AddPlayerHint( 2.0, 0.25, $"", "Dumped to spawned_ents.txt" );
	#endif
}

void function Console_Command_LoadEntsFromFile( array<string> args, string command )
{
	#if SERVER
	for(int i = 0; i < ToolgunSavedEnts_Assets.len(); ++i)
	{
		asset Asset = ToolgunSavedEnts_Assets[i];
		vector Pos = ToolgunSavedEnts_Locations[i];
		vector Ang = ToolgunSavedEnts_Angles[i];
		Toolgun_Func_SpawnAsset( Asset, Pos, Ang );
	}
	#elseif CLIENT
	AddPlayerHint( 2.0, 0.25, $"", "Loaded ents from file spawned_ents" );
	#endif
}

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

void function Console_Command_UpdateConVar( array<string> args, string command )
{
	string ConvarName = command;
	float Value = args[0].tofloat();
	ConsoleData.FloatConVars[ConvarName] <- Value;
}
