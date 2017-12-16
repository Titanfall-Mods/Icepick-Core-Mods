
struct ConCommand
{
	string Command,
	string AutocompleteText,
	string HelpText,
	void functionref( array<string> ) Func
};

struct
{
	array<ConCommand> Commands
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

	Console_RegisterFunc( "dump_spawned_ents", Console_Command_DumpSpawnedEnts, "dump_spawned_ents", "Save all player spawned entities to a file in the Titanfall game folder" );
}

void function Console_RegisterFunc( string command, void functionref( array<string> ) func, string autocompleteHelp, string helpText )
{
	ConCommand cmd
	cmd.Command = command
	cmd.AutocompleteText = autocompleteHelp
	cmd.HelpText = helpText
	cmd.Func = func
	ConsoleData.Commands.append( cmd )
}

// -----------------------------------------------------------------------------

void function Console_Command_TeleportToLocation( array<string> args )
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

void function Console_Command_PrintPlayerLocation( array<string> args )
{
	#if CLIENT
	printc( "Location: " + GetLocalClientPlayer().GetOrigin() + "\nEye angles: " + GetLocalClientPlayer().EyeAngles() );
	AddPlayerHint( 1.0, 0.25, $"", "Location printed to console" );
	#endif
}

void function Console_Command_KillAllNPCs( array<string> args )
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

void function Console_Command_DumpSpawnedEnts( array<string> args )
{
	#if SERVER
	string Output = "\n";
	Output += "array<array<var>> SavedEnts = [";
	// foreach( ent in ToolgunData.SpawnedEntities )
	int MaxNum = ToolgunData.SpawnedEntities.len();
	for( int i = 0; i < MaxNum; ++i )
	{
		entity ent = ToolgunData.SpawnedEntities[i];
		Output += "\n";
		Output += "\t[";
		Output += "" + ent.GetModelName();
		Output += ", ";
		Output += "" + ent.GetOrigin();
		Output += ", ";
		Output += "" + ent.GetAngles();
		Output += "]";
		Output += (i == MaxNum - 1 ? "" : ", ");
	}
	Output += "\n];";
	Output += "\n";

	DevTextBufferClear();
	DevTextBufferWrite( Output );
	DevTextBufferDumpToFile( "../spawned_ents.txt" );
	DevTextBufferClear();
	#elseif CLIENT
	AddPlayerHint( 2.0, 0.25, $"", "Dumped to spawned_ents.txt" );
	#endif
}
