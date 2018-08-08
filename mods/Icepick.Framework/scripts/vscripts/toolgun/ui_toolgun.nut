
untyped

global function Toolgun_UI_Init

array<var> ruis = [];
array<var> grabModeRuis = [];
var ruiToolgunMode = null;
var ruiToolgunHelp = null;

struct 
{
	var ToolgunTitle
} ToolgunUIRuis;

void function Toolgun_UI_Init()
{
	thread Toolgun_UI_DelayedInit();
}

void function Toolgun_UI_DelayedInit()
{
	// Wait a single frame at the start so that all tools for the toolgun can be created and added by extensions
	WaitFrame();

	var rui;

	// Current tool ui
	rui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, 0 )
	RuiSetInt( rui, "maxLines", 1 )
	RuiSetInt( rui, "lineNum", 1 )
	RuiSetFloat2( rui, "msgPos", <0.05, 0.05, 0.0> )
	RuiSetString( rui, "msgText", "Toolgun" )
	RuiSetFloat( rui, "msgFontSize", 48.0 )
	RuiSetFloat( rui, "msgAlpha", 0.9 )
	RuiSetFloat( rui, "thicken", 0.0 )
	RuiSetFloat3( rui, "msgColor", <1.0, 1.0, 1.0> )
	ToolgunUIRuis.ToolgunTitle = rui;

	rui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, 0 )
	RuiSetInt( rui, "maxLines", 1 )
	RuiSetInt( rui, "lineNum", 1 )
	RuiSetFloat2( rui, "msgPos", <0.05, 0.1, 0.0> )
	RuiSetString( rui, "msgText", "Mode: None" )
	RuiSetFloat( rui, "msgFontSize", 32.0 )
	RuiSetFloat( rui, "msgAlpha", 0.9 )
	RuiSetFloat( rui, "thicken", 0.0 )
	RuiSetFloat3( rui, "msgColor", <1.0, 1.0, 1.0> )
	ruis.append(rui)
	ruiToolgunMode = rui

	rui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, 0 )
	RuiSetInt( rui, "maxLines", 2 )
	RuiSetInt( rui, "lineNum", 2 )
	RuiSetFloat2( rui, "msgPos", <0.05, 0.1, 0.0> )
	RuiSetString( rui, "msgText", "Help text" )
	RuiSetFloat( rui, "msgFontSize", 32.0 )
	RuiSetFloat( rui, "msgAlpha", 0.9 )
	RuiSetFloat( rui, "thicken", 0.0 )
	RuiSetFloat3( rui, "msgColor", <1.0, 1.0, 1.0> )
	ruis.append(rui)
	ruiToolgunHelp = rui

	// Physgun help ui
	float X = 0.80;
	float Y = 0.65;
	float W = 0.05;
	float H = 0.05;

	float _x = X;
	float _y = Y;

	_x = X;
	AddKeypadRuiSmall( "Num\nLock", < _x, _y, 0.0 >, <1.0, 1.0, 1.0> );
	_x += W;
	AddKeypadRui( "/", < _x, _y, 0.0 >, <1.0, 1.0, 1.0> );
	_x += W;
	AddKeypadRui( "*", < _x, _y, 0.0 >, <1.0, 1.0, 1.0> );
	_x += W;
	AddKeypadRui( "-", < _x, _y, 0.0 >, <1.0, 1.0, 1.0> );

	_x = X;
	_y += H;
	AddKeypadRui( "7\nR-", < _x, _y, 0.0 >, <0.0, 0.0, 1.0> );
	_x += W;
	AddKeypadRui( "8\nP+", < _x, _y, 0.0 >, <1.0, 0.0, 0.0> );
	_x += W;
	AddKeypadRui( "9\nR+", < _x, _y, 0.0 >, <0.0, 0.0, 1.0> );
	_x += W;
	_y += H * 0.5;
	AddKeypadRui( "+", < _x, _y, 0.0 >, <1.0, 1.0, 1.0> );

	_x = X;
	_y += H;
	AddKeypadRui( "4\nY-", < _x, _y, 0.0 >, <0.0, 1.0, 0.0> );
	_x += W;
	AddKeypadRui( "5\nRst", < _x, _y, 0.0 >, <1.0, 1.0, 1.0> );
	_x += W;
	AddKeypadRui( "6\nY+", < _x, _y, 0.0 >, <0.0, 1.0, 0.0> );
	_x += W;
	_y += H * 0.5;
	AddKeypadRuiSmall( "Enter", < _x, _y, 0.0 >, <1.0, 1.0, 1.0> );

	_x = X;
	_y += H;
	AddKeypadRui( "1", < _x, _y, 0.0 >, <1.0, 1.0, 1.0> );
	_x += W;
	AddKeypadRui( "2\nP-", < _x, _y, 0.0 >, <1.0, 0.0, 0.0> );
	_x += W;
	AddKeypadRui( "3", < _x, _y, 0.0 >, <1.0, 1.0, 1.0> );

	_x = X;
	_y += H;
	_x += W * 0.5;
	AddKeypadRui( "0", < _x, _y, 0.0 >, <1.0, 1.0, 1.0> );
	_x += W * 0.5;
	_x += W;
	AddKeypadRui( ".", < _x, _y, 0.0 >, <1.0, 1.0, 1.0> );

	thread Toolgun_UI_UpdateToolgunHelp();
	thread ToolgunUI_Think();
}

void function AddKeypadRui( string text, vector position, vector color )
{
	var rui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, 0 )
	RuiSetInt( rui, "maxLines", 1 )
	RuiSetInt( rui, "lineNum", 1 )
	RuiSetFloat2( rui, "msgPos", position )
	RuiSetString( rui, "msgText", text )
	RuiSetFloat( rui, "msgFontSize", 32.0 )
	RuiSetFloat( rui, "msgAlpha", 0.9 )
	RuiSetFloat( rui, "thicken", 0.0 )
	RuiSetFloat3( rui, "msgColor", color )
	grabModeRuis.append( rui );
}

void function AddKeypadRuiSmall( string text, vector position, vector color )
{
	var rui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, 0 )
	RuiSetInt( rui, "maxLines", 1 )
	RuiSetInt( rui, "lineNum", 1 )
	RuiSetFloat2( rui, "msgPos", position )
	RuiSetString( rui, "msgText", text )
	RuiSetFloat( rui, "msgFontSize", 24.0 )
	RuiSetFloat( rui, "msgAlpha", 0.9 )
	RuiSetFloat( rui, "thicken", 0.0 )
	RuiSetFloat3( rui, "msgColor", color )
	grabModeRuis.append( rui );
}

void function Toolgun_UI_UpdateToolgunHelp()
{
	while ( true )
	{
		bool displayUi = Toolgun_IsHoldingToolgun();
		foreach( rui in ruis )
		{
			if( displayUi )
			{
				RuiSetFloat( rui, "msgAlpha", 0.9 )
			}
			else
			{
				RuiSetFloat( rui, "msgAlpha", 0.0 )
			}
		}

		foreach( rui in grabModeRuis )
		{
			if( displayUi && ToolgunGrab.GrabbedEntity != null )
			{
				RuiSetFloat( rui, "msgAlpha", 0.9 )
			}
			else
			{
				RuiSetFloat( rui, "msgAlpha", 0.0 )
			}
		}

		if( "GetName" in Toolgun_GetCurrentMode() )
		{
			RuiSetString( ruiToolgunMode, "msgText", "Mode: " + Toolgun_GetCurrentMode().GetName() )
		}
		else
		{
			RuiSetString( ruiToolgunMode, "msgText", "Mode: Missing GetName function" )
		}
		
		if( "GetHelp" in Toolgun_GetCurrentMode() )
		{
			RuiSetString( ruiToolgunHelp, "msgText", Toolgun_GetCurrentMode().GetHelp() )
		}
		else
		{
			RuiSetString( ruiToolgunHelp, "msgText", "Missing GetHelp function" )
		}

		WaitFrame()
	}
}

// -----------------------------------------------------------------------------

void function ToolgunUI_Think()
{
	while( true )
	{
		if( Toolgun_IsHoldingToolgun_IgnoreEnabled() )
		{
			if( ToolgunModeEnabled )
			{
				RuiSetString( ToolgunUIRuis.ToolgunTitle, "msgText", "Toolgun" );
				RuiSetFloat( ToolgunUIRuis.ToolgunTitle, "msgFontSize", 48.0 );
				RuiSetFloat( ToolgunUIRuis.ToolgunTitle, "msgAlpha", 0.9 );
			}
			else
			{
				ToolgunUI_Think_HideUi();
				RuiSetString( ToolgunUIRuis.ToolgunTitle, "msgText", "Toolgun Disabled\nRe-enable it in the Spawn Menu" );
				RuiSetFloat( ToolgunUIRuis.ToolgunTitle, "msgFontSize", 24.0 );
				RuiSetFloat( ToolgunUIRuis.ToolgunTitle, "msgAlpha", 0.9 );
			}
		}
		else
		{
			ToolgunUI_Think_HideUi();
		}
		WaitFrame();
	}
}

void function ToolgunUI_Think_HideUi()
{
	RuiSetFloat( ToolgunUIRuis.ToolgunTitle, "msgAlpha", 0.0 );
	RuiSetFloat( ruiToolgunMode, "msgAlpha", 0.0 );
	RuiSetFloat( ruiToolgunHelp, "msgAlpha", 0.0 );
}
