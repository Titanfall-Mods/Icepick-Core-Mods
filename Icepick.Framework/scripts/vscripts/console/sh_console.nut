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
	string giveType = args.len() > 0 ? args[0] : "none";
	string giveName = args.len() > 1 ? args[1] : "none";
	array<string> giveMods;
	for( int i = 2; i < args.len(); ++i )
	{
		giveMods.append( args[i] );
	}

	bool IsOffhand = giveType == "ability" || giveType == "grenade";

	switch (giveName)
	{
		// Weapons
		case "toolgun":
		case "mozambique":
			giveName = "mp_weapon_shotgun_pistol";
			giveType = "weapon";
			break;
		case "car":
			giveName = "mp_weapon_car";
			giveType = "weapon";
			break;
		case "re45":
			giveName = "mp_weapon_autopistol";
			giveType = "weapon";
			break;
		case "charge_rifle":
			giveName = "mp_weapon_defender";
			giveType = "weapon";
			break;
		case "longbow":
		case "dmr":
			giveName = "mp_weapon_dmr";
			giveType = "weapon";
			break;
		case "doubletake":
			giveName = "mp_weapon_doubletake";
			giveType = "weapon";
			break;
		case "epg":
			giveName = "mp_weapon_epg";
			giveType = "weapon";
			break;
		case "devotion":
			giveName = "mp_weapon_esaw";
			giveType = "weapon";
			break;
		case "g2":
			giveName = "mp_weapon_g2";
			giveType = "weapon";
			break;
		case "hemlok":
			giveName = "mp_weapon_hemlok";
			giveType = "weapon";
			break;
		case "spitfire":
			giveName = "mp_weapon_lmg";
			giveType = "weapon";
			break;
		case "mastiff":
			giveName = "mp_weapon_mastiff";
			giveType = "weapon";
			break;
		case "mgl":
			giveName = "mp_weapon_mgl";
			giveType = "weapon";
			break;
		case "r101":
			giveName = "mp_weapon_rspn101";
			giveType = "weapon";
			break;
		case "r97":
			giveName = "mp_weapon_r97";
			giveType = "weapon";
			break;
		case "lstar":
			giveName = "mp_weapon_lstar";
			giveType = "weapon";
			break;
		case "shotgun":
			giveName = "mp_weapon_shotgun";
			giveType = "weapon";
			break;
		case "smart_pistol":
		case "sp":
			giveName = "mp_weapon_smart_pistol";
			giveType = "weapon";
			break;
		case "smr":
		case "sidewinder":
			giveName = "mp_weapon_smr";
			giveType = "weapon";
			break;
		case "sniper":
		case "kraber":
			giveName = "mp_weapon_sniper";
			giveType = "weapon";
			break;
		case "softball":
			giveName = "mp_weapon_softball";
			giveType = "weapon";
			break;
		case "flatline":
			giveName = "mp_weapon_vinson";
			giveType = "weapon";
			break;
		case "coldwar":
			giveName = "mp_weapon_pulse_lmg";
			giveType = "weapon";
			break;
		case "wingman":
			giveName = "mp_weapon_wingman";
			giveType = "weapon";
			break;
		case "pistol":
		case "p2011":
			giveName = "mp_weapon_semipistol";
			giveType = "weapon";
			break;
		case "archer":
			giveName = "mp_weapon_rocket_launcher";
			giveType = "weapon";
			break;
		case "alternator":
			giveName = "mp_weapon_alternator_smg";
			giveType = "weapon";
			break;
		case "volt":
			giveName = "mp_weapon_hemlok_smg";
			giveType = "weapon";
			break;

		// Abilities
		case "cloak":
			giveName = "mp_ability_cloak";
			giveType = IsOffhand ? giveType : "ability";
			break;
		case "grapple":
			giveName = "mp_ability_grapple";
			giveType = IsOffhand ? giveType : "ability";
			break;
		case "heal":
		case "stim":
			giveName = "mp_ability_heal";
			giveType = IsOffhand ? giveType : "ability";
			break;
		case "holopilot":
			giveName = "mp_ability_holopilot";
			giveType = IsOffhand ? giveType : "ability";
			break;
		case "phase":
		case "phaseshift":
			giveName = "mp_ability_shifter";
			giveType = IsOffhand ? giveType : "ability";
			break;
		case "phaseshiftsuper":
			giveName = "mp_ability_shifter_super";
			giveType = IsOffhand ? giveType : "ability";
			break;
		case "timeshift":
			giveName = "mp_ability_timeshift";
			giveType = IsOffhand ? giveType : "ability";
			break;
		case "arcblast":
			giveName = "mp_ability_arc_blast";
			giveType = IsOffhand ? giveType : "ability";
			break;
		case "sonar":
		case "pulse":
		case "pulseblade":
			giveName = "mp_weapon_grenade_sonar";
			giveType = IsOffhand ? giveType : "ability";
			break;
		case "cover":
		case "deployablecover":
			giveName = "mp_weapon_deployable_cover";
			giveType = IsOffhand ? giveType : "grenade";
			break;

		// Grenades
		case "grenade":
		case "frag":
		case "fraggrenade":
			giveName = "mp_weapon_frag_grenade";
			giveType = IsOffhand ? giveType : "grenade";
			break;
		case "firestar":
			giveName = "mp_weapon_thermite_grenade";
			giveType = IsOffhand ? giveType : "grenade";
			break;
		case "electricsmoke":
		case "esmoke":
			giveName = "mp_weapon_grenade_electric_smoke";
			giveType = IsOffhand ? giveType : "grenade";
			break;
		case "empgrenade":
		case "emp":
		case "arc":
		case "arcgrenade":
			giveName = "mp_weapon_grenade_emp";
			giveType = IsOffhand ? giveType : "grenade";
			break;
		case "gravity":
		case "gravitystar":
			giveName = "mp_weapon_grenade_gravity";
			giveType = IsOffhand ? giveType : "grenade";
			break;
		case "satchel":
		case "c4":
			giveName = "mp_weapon_satchel";
			giveType = IsOffhand ? giveType : "grenade";
			break;

		// Melee
		case "melee_sword":
			giveName = "melee_pilot_sword";
			giveType = "melee";
			break;
		case "melee":
			giveName = "melee_pilot_emptyhanded";
			giveType = "melee";
			break;
	}

	if( giveType == "weapon" )
	{
		player.TakeWeaponNow( player.GetActiveWeapon().GetWeaponClassName() );
		player.GiveWeapon( giveName, giveMods );
		player.SetActiveWeaponByName( giveName );
	}
	else if( giveType == "ability" )
	{
		entity weapon = player.GetOffhandWeapon( OFFHAND_SPECIAL );
		player.TakeWeaponNow( weapon.GetWeaponClassName() );
		player.GiveOffhandWeapon( giveName, OFFHAND_SPECIAL, giveMods );
	}
	else if( giveType == "grenade" )
	{
		entity weapon = player.GetOffhandWeapon( OFFHAND_ORDNANCE );
		player.TakeWeaponNow( weapon.GetWeaponClassName() );
		player.GiveOffhandWeapon( giveName, OFFHAND_ORDNANCE, giveMods );
	}
	else if( giveType == "melee" )
	{
		entity weapon = player.GetOffhandWeapon( OFFHAND_MELEE );
		player.TakeWeaponNow( weapon.GetWeaponClassName() );
		player.GiveOffhandWeapon( giveName, OFFHAND_MELEE, giveMods );
	}
	else
	{
		printt( "Could not give item to player, unsupported type!", giveName, giveType );
	}

	// weapon.SetWeaponSkin( storedWeapon.skinIndex )
	// weapon.SetWeaponCamo( storedWeapon.camoIndex )
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
