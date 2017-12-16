
#if CLIENT

struct ConCommand
{
	string Command,
	void functionref( array<string> ) Func
}

struct {
	bool IsInputting,
	int IsShiftDown,
	string InputString,
	array<ConCommand> Commands
} ConsoleSettings;

struct {
	var InputRui
} ConsoleUi;

void function Console_Client_Init()
{
	RegisterButtonPressedCallback( KEY_BACKQUOTE, Console_ToggleEnabled );
	RegisterButtonPressedCallback( KEY_ENTER, Console_RunCommand );

	RegisterButtonPressedCallback( KEY_BACKSPACE, KeyPress_Console_Backspace );
	RegisterButtonPressedCallback( KEY_LSHIFT, KeyPress_Console_ShiftPressed );
	RegisterButtonPressedCallback( KEY_RSHIFT, KeyPress_Console_ShiftPressed );
	RegisterButtonReleasedCallback( KEY_LSHIFT, KeyPress_Console_ShiftReleased );
	RegisterButtonReleasedCallback( KEY_RSHIFT, KeyPress_Console_ShiftReleased );

	// Jesus christ, find out if there's a better way to handle this shit
	RegisterButtonPressedCallback( KEY_1, KeyPress_Console_KEY_1 );
	RegisterButtonPressedCallback( KEY_2, KeyPress_Console_KEY_2 );
	RegisterButtonPressedCallback( KEY_3, KeyPress_Console_KEY_3 );
	RegisterButtonPressedCallback( KEY_4, KeyPress_Console_KEY_4 );
	RegisterButtonPressedCallback( KEY_5, KeyPress_Console_KEY_5 );
	RegisterButtonPressedCallback( KEY_6, KeyPress_Console_KEY_6 );
	RegisterButtonPressedCallback( KEY_7, KeyPress_Console_KEY_7 );
	RegisterButtonPressedCallback( KEY_8, KeyPress_Console_KEY_8 );
	RegisterButtonPressedCallback( KEY_9, KeyPress_Console_KEY_9 );
	RegisterButtonPressedCallback( KEY_0, KeyPress_Console_KEY_0 );
	RegisterButtonPressedCallback( KEY_A, KeyPress_Console_KEY_A );
	RegisterButtonPressedCallback( KEY_B, KeyPress_Console_KEY_B );
	RegisterButtonPressedCallback( KEY_C, KeyPress_Console_KEY_C );
	RegisterButtonPressedCallback( KEY_D, KeyPress_Console_KEY_D );
	RegisterButtonPressedCallback( KEY_E, KeyPress_Console_KEY_E );
	RegisterButtonPressedCallback( KEY_F, KeyPress_Console_KEY_F );
	RegisterButtonPressedCallback( KEY_G, KeyPress_Console_KEY_G );
	RegisterButtonPressedCallback( KEY_H, KeyPress_Console_KEY_H );
	RegisterButtonPressedCallback( KEY_I, KeyPress_Console_KEY_I );
	RegisterButtonPressedCallback( KEY_J, KeyPress_Console_KEY_J );
	RegisterButtonPressedCallback( KEY_K, KeyPress_Console_KEY_K );
	RegisterButtonPressedCallback( KEY_L, KeyPress_Console_KEY_L );
	RegisterButtonPressedCallback( KEY_M, KeyPress_Console_KEY_M );
	RegisterButtonPressedCallback( KEY_N, KeyPress_Console_KEY_N );
	RegisterButtonPressedCallback( KEY_O, KeyPress_Console_KEY_O );
	RegisterButtonPressedCallback( KEY_P, KeyPress_Console_KEY_P );
	RegisterButtonPressedCallback( KEY_Q, KeyPress_Console_KEY_Q );
	RegisterButtonPressedCallback( KEY_R, KeyPress_Console_KEY_R );
	RegisterButtonPressedCallback( KEY_S, KeyPress_Console_KEY_S );
	RegisterButtonPressedCallback( KEY_T, KeyPress_Console_KEY_T );
	RegisterButtonPressedCallback( KEY_U, KeyPress_Console_KEY_U );
	RegisterButtonPressedCallback( KEY_V, KeyPress_Console_KEY_V );
	RegisterButtonPressedCallback( KEY_W, KeyPress_Console_KEY_W );
	RegisterButtonPressedCallback( KEY_X, KeyPress_Console_KEY_X );
	RegisterButtonPressedCallback( KEY_Y, KeyPress_Console_KEY_Y );
	RegisterButtonPressedCallback( KEY_Z, KeyPress_Console_KEY_Z );
	RegisterButtonPressedCallback( KEY_PAD_DIVIDE, KeyPress_Console_KEY_PAD_DIVIDE );
	RegisterButtonPressedCallback( KEY_PAD_MULTIPLY, KeyPress_Console_KEY_PAD_MULTIPLY );
	RegisterButtonPressedCallback( KEY_PAD_MINUS, KeyPress_Console_KEY_PAD_MINUS );
	RegisterButtonPressedCallback( KEY_PAD_PLUS, KeyPress_Console_KEY_PAD_PLUS );
	RegisterButtonPressedCallback( KEY_PAD_DECIMAL, KeyPress_Console_KEY_PAD_DECIMAL );
	RegisterButtonPressedCallback( KEY_SEMICOLON, KeyPress_Console_KEY_SEMICOLON );
	RegisterButtonPressedCallback( KEY_APOSTROPHE, KeyPress_Console_KEY_APOSTROPHE );
	RegisterButtonPressedCallback( KEY_COMMA, KeyPress_Console_KEY_COMMA );
	RegisterButtonPressedCallback( KEY_PERIOD, KeyPress_Console_KEY_PERIOD );
	RegisterButtonPressedCallback( KEY_SLASH, KeyPress_Console_KEY_SLASH );
	RegisterButtonPressedCallback( KEY_BACKSLASH, KeyPress_Console_KEY_BACKSLASH );
	RegisterButtonPressedCallback( KEY_MINUS, KeyPress_Console_KEY_MINUS );
	RegisterButtonPressedCallback( KEY_EQUAL, KeyPress_Console_KEY_EQUAL );
	RegisterButtonPressedCallback( KEY_SPACE, KeyPress_Console_KEY_SPACE );
	RegisterButtonPressedCallback( KEY_PAD_0, KeyPress_Console_KEY_PAD_0 );
	RegisterButtonPressedCallback( KEY_PAD_1, KeyPress_Console_KEY_PAD_1 );
	RegisterButtonPressedCallback( KEY_PAD_2, KeyPress_Console_KEY_PAD_2 );
	RegisterButtonPressedCallback( KEY_PAD_3, KeyPress_Console_KEY_PAD_3 );
	RegisterButtonPressedCallback( KEY_PAD_4, KeyPress_Console_KEY_PAD_4 );
	RegisterButtonPressedCallback( KEY_PAD_5, KeyPress_Console_KEY_PAD_5 );
	RegisterButtonPressedCallback( KEY_PAD_6, KeyPress_Console_KEY_PAD_6 );
	RegisterButtonPressedCallback( KEY_PAD_7, KeyPress_Console_KEY_PAD_7 );
	RegisterButtonPressedCallback( KEY_PAD_8, KeyPress_Console_KEY_PAD_8 );
	RegisterButtonPressedCallback( KEY_PAD_9, KeyPress_Console_KEY_PAD_9 );

	Console_UI_Init();
	Console_RegisterFunctions();
}

void function Console_UI_Init()
{
	var rui = RuiCreate( $"ui/cockpit_console_text_top_right.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, 0 );
	RuiSetInt( rui, "maxLines", 1 );
	RuiSetInt( rui, "lineNum", 1 );
	RuiSetFloat2( rui, "msgPos", <0.95, 0.05, 0.0> );
	RuiSetString( rui, "msgText", "> " );
	RuiSetFloat( rui, "msgFontSize", 24.0 );
	RuiSetFloat( rui, "msgAlpha", 1.0 );
	RuiSetFloat( rui, "thicken", 0.0 );
	RuiSetFloat3( rui, "msgColor", <1.0, 1.0, 1.0> );
	ConsoleUi.InputRui = rui;

	thread Console_UI_Think();
}

void function Console_UI_Think()
{
	while( true )
	{
		if( ConsoleUi.InputRui != null )
		{
			RuiSetFloat( ConsoleUi.InputRui, "msgAlpha", ConsoleSettings.IsInputting ? 1.0 : 0.0 );
			RuiSetString( ConsoleUi.InputRui, "msgText", "~" + ConsoleSettings.InputString );
		}
		WaitFrame();
	}
}

// -----------------------------------------------------------------------------

void function Console_RunCommand( var button )
{
	if( ConsoleSettings.InputString.len() > 0 )
	{
		string InputString = ConsoleSettings.InputString.tolower();
		array<string> args = split( InputString, " " );
		string Command = args[0];
		array<string> CommandArgs;
		for( int i = 1; i < args.len(); ++i )
		{
			CommandArgs.append( args[i] );
		}

		bool FoundCommand = false;
		foreach( cmd in ConsoleSettings.Commands )
		{
			if( cmd.Command == Command )
			{
				cmd.Func( CommandArgs );
				GetLocalClientPlayer().ClientCommand( "Console_RunCommand " + InputString );
				FoundCommand = true;
				break;
			}
		}
		if( !FoundCommand )
		{
			AddPlayerHint( 1.0, 0.25, $"", "Command '" + InputString + "' could not be found!" );
		}
	}

	// Stop inputting text
	ConsoleSettings.IsInputting = false;
	ConsoleSettings.InputString = "";
	GetLocalClientPlayer().UnfreezeControlsOnClient();
}

void function Console_ToggleEnabled( var button )
{
	ConsoleSettings.IsInputting = !ConsoleSettings.IsInputting;
	ConsoleSettings.InputString = "";

	if( ConsoleSettings.IsInputting )
	{
		GetLocalClientPlayer().FreezeControlsOnClient();
	}
	else
	{
		GetLocalClientPlayer().UnfreezeControlsOnClient();
	}
}

void function Console_Input( string char, string shiftChar )
{
	string finalChar = (ConsoleSettings.IsShiftDown > 0) ? shiftChar : char;
	if( ConsoleSettings.IsInputting )
	{
		ConsoleSettings.InputString += finalChar;
	}
}

void function KeyPress_Console_Backspace( var button )
{
	int InputLength = ConsoleSettings.InputString.len();
	if( ConsoleSettings.IsInputting && InputLength > 0 )
	{
		ConsoleSettings.InputString = ConsoleSettings.InputString.slice( 0, InputLength - 1 );
	}
}

void function KeyPress_Console_ShiftPressed( var button )
{
	ConsoleSettings.IsShiftDown++;
}

void function KeyPress_Console_ShiftReleased( var button )
{
	ConsoleSettings.IsShiftDown--;
}

// -----------------------------------------------------------------------------

void function KeyPress_Console_KEY_1( var button ){ Console_Input("1", "!"); }
void function KeyPress_Console_KEY_2( var button ){ Console_Input("2", "@"); }
void function KeyPress_Console_KEY_3( var button ){ Console_Input("3", "#"); }
void function KeyPress_Console_KEY_4( var button ){ Console_Input("4", "$"); }
void function KeyPress_Console_KEY_5( var button ){ Console_Input("5", "%"); }
void function KeyPress_Console_KEY_6( var button ){ Console_Input("6", "^"); }
void function KeyPress_Console_KEY_7( var button ){ Console_Input("7", "&"); }
void function KeyPress_Console_KEY_8( var button ){ Console_Input("8", "*"); }
void function KeyPress_Console_KEY_9( var button ){ Console_Input("9", "("); }
void function KeyPress_Console_KEY_0( var button ){ Console_Input("0", ")"); }
void function KeyPress_Console_KEY_A( var button ){ Console_Input("a", "A"); }
void function KeyPress_Console_KEY_B( var button ){ Console_Input("b", "B"); }
void function KeyPress_Console_KEY_C( var button ){ Console_Input("c", "C"); }
void function KeyPress_Console_KEY_D( var button ){ Console_Input("d", "D"); }
void function KeyPress_Console_KEY_E( var button ){ Console_Input("e", "E"); }
void function KeyPress_Console_KEY_F( var button ){ Console_Input("f", "F"); }
void function KeyPress_Console_KEY_G( var button ){ Console_Input("g", "G"); }
void function KeyPress_Console_KEY_H( var button ){ Console_Input("h", "H"); }
void function KeyPress_Console_KEY_I( var button ){ Console_Input("i", "I"); }
void function KeyPress_Console_KEY_J( var button ){ Console_Input("j", "J"); }
void function KeyPress_Console_KEY_K( var button ){ Console_Input("k", "K"); }
void function KeyPress_Console_KEY_L( var button ){ Console_Input("l", "L"); }
void function KeyPress_Console_KEY_M( var button ){ Console_Input("m", "M"); }
void function KeyPress_Console_KEY_N( var button ){ Console_Input("n", "N"); }
void function KeyPress_Console_KEY_O( var button ){ Console_Input("o", "O"); }
void function KeyPress_Console_KEY_P( var button ){ Console_Input("p", "P"); }
void function KeyPress_Console_KEY_Q( var button ){ Console_Input("q", "Q"); }
void function KeyPress_Console_KEY_R( var button ){ Console_Input("r", "R"); }
void function KeyPress_Console_KEY_S( var button ){ Console_Input("s", "S"); }
void function KeyPress_Console_KEY_T( var button ){ Console_Input("t", "T"); }
void function KeyPress_Console_KEY_U( var button ){ Console_Input("u", "U"); }
void function KeyPress_Console_KEY_V( var button ){ Console_Input("v", "V"); }
void function KeyPress_Console_KEY_W( var button ){ Console_Input("w", "W"); }
void function KeyPress_Console_KEY_X( var button ){ Console_Input("x", "X"); }
void function KeyPress_Console_KEY_Y( var button ){ Console_Input("y", "Y"); }
void function KeyPress_Console_KEY_Z( var button ){ Console_Input("z", "Z"); }
void function KeyPress_Console_KEY_PAD_DIVIDE( var button ){ Console_Input("/", "/"); }
void function KeyPress_Console_KEY_PAD_MULTIPLY( var button ){ Console_Input("*", "*"); }
void function KeyPress_Console_KEY_PAD_MINUS( var button ){ Console_Input("-", "-"); }
void function KeyPress_Console_KEY_PAD_PLUS( var button ){ Console_Input("+", "+"); }
void function KeyPress_Console_KEY_PAD_DECIMAL( var button ){ Console_Input(".", "."); }
void function KeyPress_Console_KEY_SEMICOLON( var button ){ Console_Input(";", ":"); }
void function KeyPress_Console_KEY_APOSTROPHE( var button ){ Console_Input("'", "\""); }
void function KeyPress_Console_KEY_COMMA( var button ){ Console_Input(",", "<"); }
void function KeyPress_Console_KEY_PERIOD( var button ){ Console_Input(".", ">"); }
void function KeyPress_Console_KEY_SLASH( var button ){ Console_Input("/", "?"); }
void function KeyPress_Console_KEY_BACKSLASH( var button ){ Console_Input("\\", "|"); }
void function KeyPress_Console_KEY_MINUS( var button ){ Console_Input("-", "_"); }
void function KeyPress_Console_KEY_EQUAL( var button ){ Console_Input("=", "+"); }
void function KeyPress_Console_KEY_SPACE( var button ){ Console_Input(" ", " "); }
void function KeyPress_Console_KEY_PAD_0( var button ){ Console_Input("0", "0"); }
void function KeyPress_Console_KEY_PAD_1( var button ){ Console_Input("1", "1"); }
void function KeyPress_Console_KEY_PAD_2( var button ){ Console_Input("2", "2"); }
void function KeyPress_Console_KEY_PAD_3( var button ){ Console_Input("3", "3"); }
void function KeyPress_Console_KEY_PAD_4( var button ){ Console_Input("4", "4"); }
void function KeyPress_Console_KEY_PAD_5( var button ){ Console_Input("5", "5"); }
void function KeyPress_Console_KEY_PAD_6( var button ){ Console_Input("6", "6"); }
void function KeyPress_Console_KEY_PAD_7( var button ){ Console_Input("7", "7"); }
void function KeyPress_Console_KEY_PAD_8( var button ){ Console_Input("8", "8"); }
void function KeyPress_Console_KEY_PAD_9( var button ){ Console_Input("9", "9"); }

// -----------------------------------------------------------------------------

void function Console_RegisterFunctions()
{
	Console_RegisterFunc( "print_loc", Console_Command_PrintPlayerLocation );
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

void function Console_Command_TeleportToLocation( array<string> args )
{
	// Handled by server
}

void function Console_Command_PrintPlayerLocation( array<string> args )
{
	printc( "Location: " + GetLocalClientPlayer().GetOrigin() + "\nEye angles: " + GetLocalClientPlayer().EyeAngles() );
	AddPlayerHint( 0.5, 0.25, $"", "Position print to console" );
}

void function Console_Command_KillAllNPCs( array<string> args )
{
	AddPlayerHint( 0.5, 0.25, $"", "NPCs killed" );
}

#endif
