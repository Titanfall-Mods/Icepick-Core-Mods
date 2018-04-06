
#if CLIENT

array<var> ruis = [];
array<var> grabModeRuis = [];
var ruiToolgunMode = null;
var ruiToolgunHelp = null;

struct
{
	int ChangingTool = 0,
	int ChangeToolDir = 0
} ToolgunUISettings;

struct ToolNameRui
{
	var Rui,
	vector Position
}

struct 
{
	array<ToolNameRui> ToolNames = []
} ToolgunUIRuis;

void function Toolgun_UI_Init()
{
	thread Toolgun_UI_DelayedInit();
}

void function Toolgun_UI_DelayedInit()
{
	// Wait a single frame at the start so that all tools for the toolgun can be created and added by extensions
	WaitFrame();

	RegisterButtonPressedCallback( KEY_TAB, ToolgunUI_KeyPressed_ToggleToolUI );
	RegisterButtonReleasedCallback( KEY_TAB, ToolgunUI_KeyReleased_ToggleToolUI );
	RegisterButtonPressedCallback( KEY_W, ToolgunUI_KeyPressed_NextTool );
	RegisterButtonPressedCallback( KEY_S, ToolgunUI_KeyPressed_PrevTool );
	thread ToolgunUI_Think();

	var rui;

	// Tool select ui
	for ( int i = 0; i < ToolGunTools.len(); i++ )
	{
		vector Pos = <0.0, 0.0 + 0.05 * i, 0.0>;
		var rui = RuiCreate( $"ui/cockpit_console_text_center.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 10000 )
		RuiSetInt( rui, "maxLines", 1 )
		RuiSetInt( rui, "lineNum", 1 )
		RuiSetFloat2( rui, "msgPos", Pos )
		RuiSetString( rui, "msgText", ToolGunTools[i].GetName() )
		RuiSetFloat( rui, "msgFontSize", 36.0 )
		RuiSetFloat( rui, "msgAlpha", 0.9 )
		RuiSetFloat( rui, "thicken", 0.0 )
		RuiSetFloat3( rui, "msgColor", <1.0, 1.0, 1.0> )

		ToolNameRui NewToolName;
		NewToolName.Rui = rui;
		NewToolName.Position = Pos;
		ToolgunUIRuis.ToolNames.append( NewToolName );
	}
	
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
	ruis.append(rui)

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

	thread Toolgun_UI_UpdateToolgunHelp()
}

bool function Toolgun_IsHoldingToolgun()
{
	entity player = GetLocalClientPlayer()
	if( player )
	{
		entity plyWeapon = player.GetActiveWeapon()
		if( plyWeapon != null )
		{
			return plyWeapon.GetWeaponClassName() == "mp_weapon_shotgun_pistol";
		}
	}
	return false;
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
		if( Toolgun_IsHoldingToolgun() )
		{

			for ( int i = 0; i < ToolgunUIRuis.ToolNames.len(); i++ )
			{
				ToolNameRui ToolRui = ToolgunUIRuis.ToolNames[i];
				ToolRui.Position = VectorStepTowards( ToolRui.Position, <0.0, 0.0 + 0.05 * (i - ToolGunSettings.CurrentModeIdx), 0.0>, 1.0 * FrameTime() );
				float Alpha = 0.9 - clamp( abs(ToolGunSettings.CurrentModeIdx - i), 0, 5) * 0.1;
				float FontSize = 36 - clamp( abs(ToolGunSettings.CurrentModeIdx - i), 0, 5) * 2;
				var Name = ToolGunTools[i].GetName();
				if( "GetRawName" in ToolGunTools[i] )
				{
					Name = ToolGunTools[i].GetRawName();
				}

				RuiSetFloat( ToolRui.Rui, "msgAlpha", (ToolgunUISettings.ChangingTool > 0) ? Alpha : 0.0 )
				RuiSetFloat3( ToolRui.Rui, "msgColor", (ToolGunSettings.CurrentModeIdx == i) ? <1.0, 1.0, 0.0> : <1.0, 1.0, 1.0> )
				RuiSetFloat2( ToolRui.Rui, "msgPos", ToolRui.Position )
				RuiSetFloat( ToolRui.Rui, "msgFontSize", FontSize )
				if( i == ToolGunSettings.CurrentModeIdx + 1 )
				{
					RuiSetString( ToolRui.Rui, "msgText", "[S] " + Name )
				}
				else if( i == ToolGunSettings.CurrentModeIdx - 1 )
				{
					RuiSetString( ToolRui.Rui, "msgText", "[W] " + Name )
				}
				else
				{
					RuiSetString( ToolRui.Rui, "msgText", Name )
				}
			}

			if( ToolgunUISettings.ChangingTool > 0 && ToolgunUISettings.ChangeToolDir != 0 )
			{
				Toolgun_Client_ChangeTool( ToolgunUISettings.ChangeToolDir );
				ToolgunUISettings.ChangeToolDir = 0;
			}

		}
		else
		{
			// Hide selection UI
			for ( int i = 0; i < ToolgunUIRuis.ToolNames.len(); i++ )
			{
				ToolNameRui ToolRui = ToolgunUIRuis.ToolNames[i];
				RuiSetFloat( ToolRui.Rui, "msgAlpha", 0.0 )
			}
		}
		WaitFrame();
	}
}

void function ToolgunUI_KeyPressed_ToggleToolUI( var button )
{
	ToolgunUISettings.ChangingTool++;
}

void function ToolgunUI_KeyReleased_ToggleToolUI( var button )
{
	ToolgunUISettings.ChangingTool--;
}

void function ToolgunUI_KeyPressed_NextTool( var button )
{
	if( ToolgunUISettings.ChangingTool > 0 )
	{
		ToolgunUISettings.ChangeToolDir = -1
	}
}

void function ToolgunUI_KeyPressed_PrevTool( var button )
{
	if( ToolgunUISettings.ChangingTool > 0 )
	{
		ToolgunUISettings.ChangeToolDir = 1
	}
}

#endif
