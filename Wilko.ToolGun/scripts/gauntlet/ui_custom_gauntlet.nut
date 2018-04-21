
#if CLIENT

struct 
{
	var EditModeRui
} CustomGauntletsUI;

void function CustomGauntlet_UI_Init()
{
	var rui = RuiCreate( $"ui/cockpit_console_text_top_right.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, 0 );
	RuiSetInt( rui, "maxLines", 1 );
	RuiSetInt( rui, "lineNum", 1 );
	RuiSetFloat2( rui, "msgPos", <0.115, 0.035, 0.0> );
	RuiSetString( rui, "msgText", "Edit Mode" );
	RuiSetFloat( rui, "msgFontSize", 28.0 );
	RuiSetFloat( rui, "msgAlpha", 0.9 );
	RuiSetFloat( rui, "thicken", 0.0 );
	RuiSetFloat3( rui, "msgColor", <0.5, 0.5, 0.5> );
	CustomGauntletsUI.EditModeRui = rui;

	thread CustomGauntlet_UI_Think();
}

void function CustomGauntlet_UI_Think()
{
	while( true )
	{
		if( CustomGauntletsUI.EditModeRui != null )
		{
			RuiSetFloat( CustomGauntletsUI.EditModeRui, "msgAlpha", CustomGauntletsGlobal.EditModeActive ? 0.9 : 0.0 );
		}

		WaitFrame();
	}
}

#endif
