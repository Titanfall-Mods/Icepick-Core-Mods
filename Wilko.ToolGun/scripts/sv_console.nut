
#if SERVER

void function Console_Server_Init()
{
	AddClientCommandCallback( "Console_RunCommand", ClientCommand_Console_RunCommand );
}

bool function ClientCommand_Console_RunCommand( entity player, array<string> args )
{
	string command = args[0];
	array<string> CommandArgs;
	for( int i = 1; i < args.len(); ++i )
	{
		CommandArgs.append( args[i] );
	}

	foreach( cmd in ConsoleData.Commands )
	{
		if( cmd.Command == command )
		{
			cmd.Func( CommandArgs );
			return true;
		}
	}
	return false;
}

#endif
