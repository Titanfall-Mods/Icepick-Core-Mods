global function CustomGauntlet_UI_Init
global function CustomGauntlet_UI_CreatePlayerHud
global function CustomGauntlet_UI_EndOfRun
global function CustomGauntlet_UI_RemovePlayerHud
global function CustomGauntlet_DoGauntletSplash

global struct CustomGauntletsUIStruct
{
	var EditModeRui,
	var PlayerHudRui
};

global CustomGauntletsUIStruct CustomGauntletsUI;

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

void function CustomGauntlet_UI_CreatePlayerHud()
{
	CustomGauntlet_UI_RemovePlayerHud();

	CustomGauntletsUI.PlayerHudRui = RuiCreate( $"ui/gauntlet_hud.rpak", clGlobal.topoCockpitHud, RUI_DRAW_COCKPIT, 0 );
	RuiSetGameTime( CustomGauntletsUI.PlayerHudRui, "startTime", Time() );
}

void function CustomGauntlet_UI_RemovePlayerHud()
{
	if( CustomGauntletsUI.PlayerHudRui != null )
	{
		RuiDestroyIfAlive( CustomGauntletsUI.PlayerHudRui );
	}
	CustomGauntletsUI.PlayerHudRui = null;
}

void function CustomGauntlet_UI_EndOfRun( float TotalTime, float BestTime, float MissedTargetsPenalty )
{
	if( CustomGauntletsUI.PlayerHudRui != null )
	{
		RuiSetBool( CustomGauntletsUI.PlayerHudRui, "runFinished", true );
		RuiSetFloat( CustomGauntletsUI.PlayerHudRui, "finalTime", TotalTime );
		RuiSetFloat( CustomGauntletsUI.PlayerHudRui, "bestTime", BestTime );
		RuiSetFloat( CustomGauntletsUI.PlayerHudRui, "enemiesMissedTimePenalty", MissedTargetsPenalty );
	}

	wait 4.0;
	CustomGauntlet_UI_RemovePlayerHud();
}

// -----------------------------------------------------------------------------

void function CustomGauntlet_DoGauntletSplash( string MessageText )
{
	float Duration = 1.8;

	var splashRUI = RuiCreate( $"ui/gauntlet_splash.rpak", clGlobal.topoCockpitHud, RUI_DRAW_COCKPIT, 0 );
	RuiSetFloat( splashRUI, "duration", Duration );
	RuiSetString( splashRUI, "message", MessageText );
	
	wait Duration + 0.1;
	RuiDestroyIfAlive( splashRUI );
}
