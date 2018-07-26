
global function Convars_Shared_Init
global function RegisterConVar
global function SetConVarValue
global function GetConVarValue

global struct ConsoleDataStruct
{
	table< string, float > FloatConVars
}
global ConsoleDataStruct ConsoleData

void function Convars_Shared_Init()
{
#if SERVER
	AddClientCommandCallback( "ConvarUpdate", ClientCommand_ConvarUpdate );
#endif
}

#if SERVER
bool function ClientCommand_ConvarUpdate( entity player, array<string> args )
{
	string ConvarName = args[0];
	float Value = args[1].tofloat();

	if( ConvarName in ConsoleData.FloatConVars )
	{
		ConsoleData.FloatConVars[ ConvarName ] = Value;
		return true;
	}
	return false;
}
#endif

void function RegisterConVar( string VarName, float InitialValue, string AutocompleteHelp, string HelpText )
{
	ConsoleData.FloatConVars[VarName] <- InitialValue;
}

void function SetConVarValue( string VarName, float NewValue )
{
#if CLIENT
	// Update convar value on client
	ConsoleData.FloatConVars[VarName] <- NewValue;

	// Send convar value to server
	string InputString = VarName + " " + NewValue;
	GetLocalClientPlayer().ClientCommand( "ConvarUpdate " + InputString );
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
