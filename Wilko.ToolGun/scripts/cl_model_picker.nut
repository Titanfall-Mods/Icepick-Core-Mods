
#if CLIENT

const int MAX_MODEL_PICKER_RESULTS = 10;
const float MODEL_PICKER_TEXT_SIZE = 32.0;

struct {
	bool IsInputting,
	int IsShiftDown,
	string SearchString,
	array<string> SearchResults
} ModelPickerSettings;

struct {
	var InputRui,
	array<var> ResultsRuis
} ModelPickerUi;

void function ModelPicker_Client_Init()
{
	RegisterButtonPressedCallback( KEY_INSERT, KeyPress_ModelPickerToggleEnabled );
	RegisterButtonPressedCallback( KEY_BACKSPACE, KeyPress_ModelPicker_Backspace );

	RegisterButtonPressedCallback( KEY_LSHIFT, KeyPress_ModelPicker_ShiftPressed );
	RegisterButtonPressedCallback( KEY_RSHIFT, KeyPress_ModelPicker_ShiftPressed );
	RegisterButtonReleasedCallback( KEY_LSHIFT, KeyPress_ModelPicker_ShiftReleased );
	RegisterButtonReleasedCallback( KEY_RSHIFT, KeyPress_ModelPicker_ShiftReleased );

	// Jesus christ, find out if there's a better way to handle this shit
	RegisterButtonPressedCallback( KEY_1, KeyPress_ModelPicker_KEY_1 );
	RegisterButtonPressedCallback( KEY_2, KeyPress_ModelPicker_KEY_2 );
	RegisterButtonPressedCallback( KEY_3, KeyPress_ModelPicker_KEY_3 );
	RegisterButtonPressedCallback( KEY_4, KeyPress_ModelPicker_KEY_4 );
	RegisterButtonPressedCallback( KEY_5, KeyPress_ModelPicker_KEY_5 );
	RegisterButtonPressedCallback( KEY_6, KeyPress_ModelPicker_KEY_6 );
	RegisterButtonPressedCallback( KEY_7, KeyPress_ModelPicker_KEY_7 );
	RegisterButtonPressedCallback( KEY_8, KeyPress_ModelPicker_KEY_8 );
	RegisterButtonPressedCallback( KEY_9, KeyPress_ModelPicker_KEY_9 );
	RegisterButtonPressedCallback( KEY_0, KeyPress_ModelPicker_KEY_0 );
	RegisterButtonPressedCallback( KEY_A, KeyPress_ModelPicker_KEY_A );
	RegisterButtonPressedCallback( KEY_B, KeyPress_ModelPicker_KEY_B );
	RegisterButtonPressedCallback( KEY_C, KeyPress_ModelPicker_KEY_C );
	RegisterButtonPressedCallback( KEY_D, KeyPress_ModelPicker_KEY_D );
	RegisterButtonPressedCallback( KEY_E, KeyPress_ModelPicker_KEY_E );
	RegisterButtonPressedCallback( KEY_F, KeyPress_ModelPicker_KEY_F );
	RegisterButtonPressedCallback( KEY_G, KeyPress_ModelPicker_KEY_G );
	RegisterButtonPressedCallback( KEY_H, KeyPress_ModelPicker_KEY_H );
	RegisterButtonPressedCallback( KEY_I, KeyPress_ModelPicker_KEY_I );
	RegisterButtonPressedCallback( KEY_J, KeyPress_ModelPicker_KEY_J );
	RegisterButtonPressedCallback( KEY_K, KeyPress_ModelPicker_KEY_K );
	RegisterButtonPressedCallback( KEY_L, KeyPress_ModelPicker_KEY_L );
	RegisterButtonPressedCallback( KEY_M, KeyPress_ModelPicker_KEY_M );
	RegisterButtonPressedCallback( KEY_N, KeyPress_ModelPicker_KEY_N );
	RegisterButtonPressedCallback( KEY_O, KeyPress_ModelPicker_KEY_O );
	RegisterButtonPressedCallback( KEY_P, KeyPress_ModelPicker_KEY_P );
	RegisterButtonPressedCallback( KEY_Q, KeyPress_ModelPicker_KEY_Q );
	RegisterButtonPressedCallback( KEY_R, KeyPress_ModelPicker_KEY_R );
	RegisterButtonPressedCallback( KEY_S, KeyPress_ModelPicker_KEY_S );
	RegisterButtonPressedCallback( KEY_T, KeyPress_ModelPicker_KEY_T );
	RegisterButtonPressedCallback( KEY_U, KeyPress_ModelPicker_KEY_U );
	RegisterButtonPressedCallback( KEY_V, KeyPress_ModelPicker_KEY_V );
	RegisterButtonPressedCallback( KEY_W, KeyPress_ModelPicker_KEY_W );
	RegisterButtonPressedCallback( KEY_X, KeyPress_ModelPicker_KEY_X );
	RegisterButtonPressedCallback( KEY_Y, KeyPress_ModelPicker_KEY_Y );
	RegisterButtonPressedCallback( KEY_Z, KeyPress_ModelPicker_KEY_Z );
	RegisterButtonPressedCallback( KEY_PAD_DIVIDE, KeyPress_ModelPicker_KEY_PAD_DIVIDE );
	RegisterButtonPressedCallback( KEY_PAD_MULTIPLY, KeyPress_ModelPicker_KEY_PAD_MULTIPLY );
	RegisterButtonPressedCallback( KEY_PAD_MINUS, KeyPress_ModelPicker_KEY_PAD_MINUS );
	RegisterButtonPressedCallback( KEY_PAD_PLUS, KeyPress_ModelPicker_KEY_PAD_PLUS );
	RegisterButtonPressedCallback( KEY_PAD_DECIMAL, KeyPress_ModelPicker_KEY_PAD_DECIMAL );
	RegisterButtonPressedCallback( KEY_SEMICOLON, KeyPress_ModelPicker_KEY_SEMICOLON );
	RegisterButtonPressedCallback( KEY_APOSTROPHE, KeyPress_ModelPicker_KEY_APOSTROPHE );
	RegisterButtonPressedCallback( KEY_BACKQUOTE, KeyPress_ModelPicker_KEY_BACKQUOTE );
	RegisterButtonPressedCallback( KEY_COMMA, KeyPress_ModelPicker_KEY_COMMA );
	RegisterButtonPressedCallback( KEY_PERIOD, KeyPress_ModelPicker_KEY_PERIOD );
	RegisterButtonPressedCallback( KEY_SLASH, KeyPress_ModelPicker_KEY_SLASH );
	RegisterButtonPressedCallback( KEY_BACKSLASH, KeyPress_ModelPicker_KEY_BACKSLASH );
	RegisterButtonPressedCallback( KEY_MINUS, KeyPress_ModelPicker_KEY_MINUS );
	RegisterButtonPressedCallback( KEY_EQUAL, KeyPress_ModelPicker_KEY_EQUAL );
	RegisterButtonPressedCallback( KEY_SPACE, KeyPress_ModelPicker_KEY_SPACE );

	// Select from results using the keypad
	RegisterButtonPressedCallback( KEY_PAD_0, KeyPress_ModelPicker_KEY_PAD_0 );
	RegisterButtonPressedCallback( KEY_PAD_1, KeyPress_ModelPicker_KEY_PAD_1 );
	RegisterButtonPressedCallback( KEY_PAD_2, KeyPress_ModelPicker_KEY_PAD_2 );
	RegisterButtonPressedCallback( KEY_PAD_3, KeyPress_ModelPicker_KEY_PAD_3 );
	RegisterButtonPressedCallback( KEY_PAD_4, KeyPress_ModelPicker_KEY_PAD_4 );
	RegisterButtonPressedCallback( KEY_PAD_5, KeyPress_ModelPicker_KEY_PAD_5 );
	RegisterButtonPressedCallback( KEY_PAD_6, KeyPress_ModelPicker_KEY_PAD_6 );
	RegisterButtonPressedCallback( KEY_PAD_7, KeyPress_ModelPicker_KEY_PAD_7 );
	RegisterButtonPressedCallback( KEY_PAD_8, KeyPress_ModelPicker_KEY_PAD_8 );
	RegisterButtonPressedCallback( KEY_PAD_9, KeyPress_ModelPicker_KEY_PAD_9 );

	ModelPicker_UI_Init();
}

void function ModelPicker_UI_Init()
{
	var rui = RuiCreate( $"ui/cockpit_console_text_top_right.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, 0 );
	RuiSetInt( rui, "maxLines", 1 );
	RuiSetInt( rui, "lineNum", 1 );
	RuiSetFloat2( rui, "msgPos", <0.95, 0.05, 0.0> );
	RuiSetString( rui, "msgText", "> " );
	RuiSetFloat( rui, "msgFontSize", MODEL_PICKER_TEXT_SIZE );
	RuiSetFloat( rui, "msgAlpha", 1.0 );
	RuiSetFloat( rui, "thicken", 0.0 );
	RuiSetFloat3( rui, "msgColor", <1.0, 1.0, 1.0> );
	ModelPickerUi.InputRui = rui;

	thread ModelPicker_UI_Think();
}

void function ModelPicker_UI_Think()
{
	while( true )
	{
		if( ModelPickerUi.InputRui != null )
		{
			RuiSetFloat( ModelPickerUi.InputRui, "msgAlpha", ModelPickerSettings.IsInputting ? 1.0 : 0.0 );
		}
		WaitFrame();
	}
}

void function ModelPicker_ToggleEnabled()
{
	ModelPickerSettings.IsInputting = !ModelPickerSettings.IsInputting;
	ModelPickerSettings.SearchString = "";

	if( ModelPickerSettings.IsInputting )
	{
		GetLocalClientPlayer().ClientCommand( "ModelPicker_OnOpenPicker" );
		GetLocalClientPlayer().FreezeControlsOnClient();
		ModelPicker_UpdateSearch();
	}
	else
	{
		GetLocalClientPlayer().ClientCommand( "ModelPicker_OnClosePicker" );
		GetLocalClientPlayer().UnfreezeControlsOnClient();
		ModelPicker_ClearUi();
	}
}

void function KeyPress_ModelPickerToggleEnabled( var button )
{
	ModelPicker_ToggleEnabled();
}

void function ModelPicker_Input( string char, string shiftChar )
{
	string finalChar = (ModelPickerSettings.IsShiftDown > 0) ? shiftChar : char;
	if( ModelPickerSettings.IsInputting )
	{
		ModelPickerSettings.SearchString += finalChar;
		ModelPicker_UpdateSearch();
	}
}

void function KeyPress_ModelPicker_Backspace( var button )
{
	int SearchLength = ModelPickerSettings.SearchString.len();
	if( ModelPickerSettings.IsInputting && SearchLength > 0 )
	{
		ModelPickerSettings.SearchString = ModelPickerSettings.SearchString.slice( 0, SearchLength - 1 );
		ModelPicker_UpdateSearch();
	}
}

void function KeyPress_ModelPicker_ShiftPressed( var button )
{
	ModelPickerSettings.IsShiftDown++;
}

void function KeyPress_ModelPicker_ShiftReleased( var button )
{
	ModelPickerSettings.IsShiftDown--;
}

void function ModelPicker_SelectResultIndex( int idx )
{
	if( ModelPickerSettings.IsInputting && idx >= 0 && idx < ModelPickerSettings.SearchResults.len() )
	{
		string assetName = ModelPickerSettings.SearchResults[idx];

		int FoundIdx = -1;
		for( int i = 0; i < CurrentLevelSpawnList.len(); ++i )
		{
			string searchName = "" + CurrentLevelSpawnList[i];
			if( assetName == searchName )
			{
				FoundIdx = i;
				break;
			}
		}

		if( FoundIdx >= 0 )
		{
			printc( "Selected prop " + assetName + "(" + FoundIdx + ")" );
			GetLocalClientPlayer().ClientCommand( "Toolgun_ChangeModel " + FoundIdx );
			ModelPicker_ToggleEnabled();
		}
		else
		{
			printc("[Red] Could not find index for asset! (" + assetName + ")");
		}

	}
}

// -----------------------------------------------------------------------------

void function ModelPicker_UpdateSearch()
{
	ModelPickerSettings.SearchResults.clear();
	if( ModelPickerSettings.SearchString.len() > 0 )
	{
		foreach( a in CurrentLevelSpawnList )
		{
			string assetName = "" + a;
			if( assetName.find( ModelPickerSettings.SearchString ) != null )
			{
				ModelPickerSettings.SearchResults.append( assetName );
				if( ModelPickerSettings.SearchResults.len() >= MAX_MODEL_PICKER_RESULTS )
				{
					break; // Can only show first 10 results
				}
			}
		}
	}

	if( ModelPickerSettings.SearchResults.len() > 0 )
	{
		string AssetName = "" + ModelPickerSettings.SearchResults[0]; // Hack: convert to string easily
		AssetName = AssetName.slice( 2, AssetName.len() - 1 ); // Cutoff the $""
		GetLocalClientPlayer().ClientCommand( "ModelPicker_UpdatePreviewModel " + AssetName );
	}
	else
	{
		GetLocalClientPlayer().ClientCommand( "ModelPicker_ClearPreviewModel" );
	}

	ModelPicker_UpdateUi();
}

void function ModelPicker_UpdateUi()
{
	ModelPicker_ClearUi();

	if( ModelPickerUi.InputRui != null )
	{
		RuiSetString( ModelPickerUi.InputRui, "msgText", "> " + ModelPickerSettings.SearchString );
	}

	int NumResults = ModelPickerSettings.SearchResults.len();
	if( NumResults > 0 )
	{
		// Add new search results
		int MaxLines = NumResults + 2;
		int Idx = 0;
		foreach( string result in ModelPickerSettings.SearchResults )
		{
			var rui = RuiCreate( $"ui/cockpit_console_text_top_right.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, 0 );
			RuiSetInt( rui, "maxLines", MaxLines );
			RuiSetInt( rui, "lineNum", Idx + 2 );
			RuiSetFloat2( rui, "msgPos", <0.95, 0.05, 0.0> );
			RuiSetString( rui, "msgText", "[" + Idx + "] " + result );
			RuiSetFloat( rui, "msgFontSize", MODEL_PICKER_TEXT_SIZE );
			RuiSetFloat( rui, "msgAlpha", 1.0 );
			RuiSetFloat( rui, "thicken", 0.0 );
			RuiSetFloat3( rui, "msgColor", Idx == 0 ? <1.0, 1.0, 0.0> : <1.0, 1.0, 1.0> );
			ModelPickerUi.ResultsRuis.append(rui);
			Idx++;
		}
	}
	else
	{
		// Add help text if no input was given or no results
		string HelpString = ModelPickerSettings.SearchString.len() > 0 ? "No Results" : "Type to search available models";
		var rui = RuiCreate( $"ui/cockpit_console_text_top_right.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, 0 );
		RuiSetInt( rui, "maxLines", 2 );
		RuiSetInt( rui, "lineNum", 2 );
		RuiSetFloat2( rui, "msgPos", <0.95, 0.05, 0.0> );
		RuiSetString( rui, "msgText", HelpString );
		RuiSetFloat( rui, "msgFontSize", MODEL_PICKER_TEXT_SIZE );
		RuiSetFloat( rui, "msgAlpha", 1.0 );
		RuiSetFloat( rui, "thicken", 0.0 );
		RuiSetFloat3( rui, "msgColor", <1.0, 1.0, 1.0> );
		ModelPickerUi.ResultsRuis.append(rui);
	}
}

void function ModelPicker_ClearUi()
{
	foreach( rui in ModelPickerUi.ResultsRuis )
	{
		RuiDestroyIfAlive( rui );
	}
	ModelPickerUi.ResultsRuis.clear();
}

// -----------------------------------------------------------------------------

void function KeyPress_ModelPicker_KEY_1( var button ){ ModelPicker_Input("1", "!"); }
void function KeyPress_ModelPicker_KEY_2( var button ){ ModelPicker_Input("2", "@"); }
void function KeyPress_ModelPicker_KEY_3( var button ){ ModelPicker_Input("3", "#"); }
void function KeyPress_ModelPicker_KEY_4( var button ){ ModelPicker_Input("4", "$"); }
void function KeyPress_ModelPicker_KEY_5( var button ){ ModelPicker_Input("5", "%"); }
void function KeyPress_ModelPicker_KEY_6( var button ){ ModelPicker_Input("6", "^"); }
void function KeyPress_ModelPicker_KEY_7( var button ){ ModelPicker_Input("7", "&"); }
void function KeyPress_ModelPicker_KEY_8( var button ){ ModelPicker_Input("8", "*"); }
void function KeyPress_ModelPicker_KEY_9( var button ){ ModelPicker_Input("9", "("); }
void function KeyPress_ModelPicker_KEY_0( var button ){ ModelPicker_Input("0", ")"); }
void function KeyPress_ModelPicker_KEY_A( var button ){ ModelPicker_Input("a", "A"); }
void function KeyPress_ModelPicker_KEY_B( var button ){ ModelPicker_Input("b", "B"); }
void function KeyPress_ModelPicker_KEY_C( var button ){ ModelPicker_Input("c", "C"); }
void function KeyPress_ModelPicker_KEY_D( var button ){ ModelPicker_Input("d", "D"); }
void function KeyPress_ModelPicker_KEY_E( var button ){ ModelPicker_Input("e", "E"); }
void function KeyPress_ModelPicker_KEY_F( var button ){ ModelPicker_Input("f", "F"); }
void function KeyPress_ModelPicker_KEY_G( var button ){ ModelPicker_Input("g", "G"); }
void function KeyPress_ModelPicker_KEY_H( var button ){ ModelPicker_Input("h", "H"); }
void function KeyPress_ModelPicker_KEY_I( var button ){ ModelPicker_Input("i", "I"); }
void function KeyPress_ModelPicker_KEY_J( var button ){ ModelPicker_Input("j", "J"); }
void function KeyPress_ModelPicker_KEY_K( var button ){ ModelPicker_Input("k", "K"); }
void function KeyPress_ModelPicker_KEY_L( var button ){ ModelPicker_Input("l", "L"); }
void function KeyPress_ModelPicker_KEY_M( var button ){ ModelPicker_Input("m", "M"); }
void function KeyPress_ModelPicker_KEY_N( var button ){ ModelPicker_Input("n", "N"); }
void function KeyPress_ModelPicker_KEY_O( var button ){ ModelPicker_Input("o", "O"); }
void function KeyPress_ModelPicker_KEY_P( var button ){ ModelPicker_Input("p", "P"); }
void function KeyPress_ModelPicker_KEY_Q( var button ){ ModelPicker_Input("q", "Q"); }
void function KeyPress_ModelPicker_KEY_R( var button ){ ModelPicker_Input("r", "R"); }
void function KeyPress_ModelPicker_KEY_S( var button ){ ModelPicker_Input("s", "S"); }
void function KeyPress_ModelPicker_KEY_T( var button ){ ModelPicker_Input("t", "T"); }
void function KeyPress_ModelPicker_KEY_U( var button ){ ModelPicker_Input("u", "U"); }
void function KeyPress_ModelPicker_KEY_V( var button ){ ModelPicker_Input("v", "V"); }
void function KeyPress_ModelPicker_KEY_W( var button ){ ModelPicker_Input("w", "W"); }
void function KeyPress_ModelPicker_KEY_X( var button ){ ModelPicker_Input("x", "X"); }
void function KeyPress_ModelPicker_KEY_Y( var button ){ ModelPicker_Input("y", "Y"); }
void function KeyPress_ModelPicker_KEY_Z( var button ){ ModelPicker_Input("z", "Z"); }
void function KeyPress_ModelPicker_KEY_PAD_DIVIDE( var button ){ ModelPicker_Input("/", "/"); }
void function KeyPress_ModelPicker_KEY_PAD_MULTIPLY( var button ){ ModelPicker_Input("*", "*"); }
void function KeyPress_ModelPicker_KEY_PAD_MINUS( var button ){ ModelPicker_Input("-", "-"); }
void function KeyPress_ModelPicker_KEY_PAD_PLUS( var button ){ ModelPicker_Input("+", "+"); }
void function KeyPress_ModelPicker_KEY_PAD_DECIMAL( var button ){ ModelPicker_Input(".", "."); }
void function KeyPress_ModelPicker_KEY_SEMICOLON( var button ){ ModelPicker_Input(";", ":"); }
void function KeyPress_ModelPicker_KEY_APOSTROPHE( var button ){ ModelPicker_Input("'", "\""); }
void function KeyPress_ModelPicker_KEY_BACKQUOTE( var button ){ ModelPicker_Input("`", "~"); }
void function KeyPress_ModelPicker_KEY_COMMA( var button ){ ModelPicker_Input(",", "<"); }
void function KeyPress_ModelPicker_KEY_PERIOD( var button ){ ModelPicker_Input(".", ">"); }
void function KeyPress_ModelPicker_KEY_SLASH( var button ){ ModelPicker_Input("/", "?"); }
void function KeyPress_ModelPicker_KEY_BACKSLASH( var button ){ ModelPicker_Input("\\", "|"); }
void function KeyPress_ModelPicker_KEY_MINUS( var button ){ ModelPicker_Input("-", "_"); }
void function KeyPress_ModelPicker_KEY_EQUAL( var button ){ ModelPicker_Input("=", "+"); }
void function KeyPress_ModelPicker_KEY_SPACE( var button ){ ModelPicker_Input(" ", " "); }

void function KeyPress_ModelPicker_KEY_PAD_0( var button ){ ModelPicker_SelectResultIndex( 0 ); }
void function KeyPress_ModelPicker_KEY_PAD_1( var button ){ ModelPicker_SelectResultIndex( 1 ); }
void function KeyPress_ModelPicker_KEY_PAD_2( var button ){ ModelPicker_SelectResultIndex( 2 ); }
void function KeyPress_ModelPicker_KEY_PAD_3( var button ){ ModelPicker_SelectResultIndex( 3 ); }
void function KeyPress_ModelPicker_KEY_PAD_4( var button ){ ModelPicker_SelectResultIndex( 4 ); }
void function KeyPress_ModelPicker_KEY_PAD_5( var button ){ ModelPicker_SelectResultIndex( 5 ); }
void function KeyPress_ModelPicker_KEY_PAD_6( var button ){ ModelPicker_SelectResultIndex( 6 ); }
void function KeyPress_ModelPicker_KEY_PAD_7( var button ){ ModelPicker_SelectResultIndex( 7 ); }
void function KeyPress_ModelPicker_KEY_PAD_8( var button ){ ModelPicker_SelectResultIndex( 8 ); }
void function KeyPress_ModelPicker_KEY_PAD_9( var button ){ ModelPicker_SelectResultIndex( 9 ); }

#endif
