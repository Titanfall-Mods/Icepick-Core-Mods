
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

	Console_RegisterFunc( "save_ents", Console_Command_DumpSpawnedEnts, "save_ents", "Save all player spawned entities to a file in the Titanfall folder" );
	Console_RegisterFunc( "load_ents", Console_Command_LoadEntsFromFile, "load_ents", "Load all ents from a file in the Toolgun mod" );
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
	string AssetsOut = "\narray<asset> ToolgunSavedEnts_Assets = [\n";
	string LocationsOut = "\narray<vector> ToolgunSavedEnts_Locations = [\n";
	string AnglesOut = "\narray<vector> ToolgunSavedEnts_Angles = [\n";
	int NumEnts = ToolgunData.SpawnedEntities.len();

	for( int i = 0; i < NumEnts; ++i )
	{
		entity ent = ToolgunData.SpawnedEntities[i];
		string LineEndChar = (i == NumEnts - 1 ? "\n" : ", \n");
		AssetsOut += "\t" + ent.GetModelName() + LineEndChar;
		LocationsOut += "\t" + ent.GetOrigin() + LineEndChar;
		AnglesOut += "\t" + ent.GetAngles() + LineEndChar;
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

void function Console_Command_LoadEntsFromFile( array<string> args )
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
