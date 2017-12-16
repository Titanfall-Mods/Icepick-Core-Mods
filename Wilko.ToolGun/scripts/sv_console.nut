
#if SERVER

struct ConCommand
{
	string Command,
	void functionref( array<string> ) Func
}

struct
{
	array<ConCommand> Commands
} ConsoleSettings

void function Console_Server_Init()
{
	AddClientCommandCallback( "Console_RunCommand", ClientCommand_Console_RunCommand );

	Console_RegisterFunc( "teleport", Console_Command_TeleportToLocation );
	Console_RegisterFunc( "kill_npcs", Console_Command_KillAllNPCs );
}

void function Console_RegisterFunc( string command, void functionref( array<string> ) func )
{
	ConCommand cmd
	cmd.Command = command
	cmd.Func = func
	ConsoleSettings.Commands.append( cmd )
}

bool function ClientCommand_Console_RunCommand( entity player, array<string> args )
{
	string command = args[0];
	array<string> CommandArgs;
	for( int i = 1; i < args.len(); ++i )
	{
		CommandArgs.append( args[i] );
	}

	foreach( cmd in ConsoleSettings.Commands )
	{
		if( cmd.Command == command )
		{
			cmd.Func( CommandArgs );
			return true;
		}
	}
	return false;
}

// -----------------------------------------------------------------------------

void function Console_Command_TeleportToLocation( array<string> args )
{
	float x = args[0].tofloat();
	float y = args[1].tofloat();
	float z = args[2].tofloat();
	GetPlayerByIndex( 0 ).SetOrigin( <x, y, z> );
}

void function Console_Command_KillAllNPCs( array<string> args )
{
	Console_Command_KillAllEnemyClass( "npc_titan" );
	Console_Command_KillAllEnemyClass( "npc_soldier" );
	Console_Command_KillAllEnemyClass( "npc_soldier_shield_captain" );
	Console_Command_KillAllEnemyClass( "npc_soldier_specialist" );
	Console_Command_KillAllEnemyClass( "npc_spectre" );
	Console_Command_KillAllEnemyClass( "npc_stalker" );
	Console_Command_KillAllEnemyClass( "npc_turret_mega" );
	Console_Command_KillAllEnemyClass( "npc_super_spectre" );
	Console_Command_KillAllEnemyClass( "npc_drone_rocket" );
	Console_Command_KillAllEnemyClass( "npc_prowler" );
	Console_Command_KillAllEnemyClass( "npc_frag_drone" );
	Console_Command_KillAllEnemyClass( "npc_drone_plasma" );
	Console_Command_KillAllEnemyClass( "npc_drone_worker" );
	Console_Command_KillAllEnemyClass( "npc_dropship" );
	Console_Command_KillAllEnemyClass( "npc_marvin" );
	Console_Command_KillAllEnemyClass( "npc_spectre" );
	Console_Command_KillAllEnemyClass( "npc_stalker" );
	Console_Command_KillAllEnemyClass( "npc_stalker_zombie" );
	Console_Command_KillAllEnemyClass( "npc_super_spectre" );
	Console_Command_KillAllEnemyClass( "npc_titan_atlas_tracker" );
	Console_Command_KillAllEnemyClass( "npc_titan_stryder_leadwall" );
	Console_Command_KillAllEnemyClass( "npc_titan_stryder_rocketeer" );
	Console_Command_KillAllEnemyClass( "npc_titan_vanguard" );
}

void function Console_Command_KillAllEnemyClass( string classname )
{
	array<entity> ents = GetEntArrayByClass_Expensive( classname )
	foreach ( ent in ents )
	{
		ent.Destroy()
	}
}

#endif
