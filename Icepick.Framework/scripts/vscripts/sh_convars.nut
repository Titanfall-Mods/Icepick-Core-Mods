
global function RegisterConVar
global function SetConVarValue
global function GetConVarValue

global struct ConsoleDataStruct
{
	table< string, float > FloatConVars
}
global ConsoleDataStruct ConsoleData

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
