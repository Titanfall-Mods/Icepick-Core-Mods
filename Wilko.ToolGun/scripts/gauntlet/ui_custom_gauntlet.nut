
#if CLIENT

void function CustomGauntlet_UI_Init()
{
	var rui = RuiCreate( $"ui/cockpit_console_text_top_right.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, 0 );
	RuiSetInt( rui, "maxLines", 1 );
	RuiSetInt( rui, "lineNum", 1 );
	RuiSetFloat2( rui, "msgPos", <0.95, 0.05, 0.0> );
	RuiSetString( rui, "msgText", "Gauntlet Active" );
	RuiSetFloat( rui, "msgFontSize", 48.0 );
	RuiSetFloat( rui, "msgAlpha", 0.9 );
	RuiSetFloat( rui, "thicken", 0.0 );
	RuiSetFloat3( rui, "msgColor", <1.0, 1.0, 1.0> );
	CustomGauntlet.IsActiveRui = rui;

	thread CustomGauntlet_UI_Think();
}

void function CustomGauntlet_UI_Think()
{
	while( true )
	{
		if( CustomGauntlet.IsActiveRui != null )
		{
			if( CustomGauntlet.IsActive )
				RuiSetFloat( CustomGauntlet.IsActiveRui, "msgAlpha", 0.9 );
			else
				RuiSetFloat( CustomGauntlet.IsActiveRui, "msgAlpha", 0.0 );
		}

		WaitFrame()
	}
}

// -----------------------------------------------------------------------------

void function CustomGauntlet_CreatePlayerHUD()
{
	CustomGauntlet_DestroyPlayerHUD();

	CustomGauntlet.HUDRui = RuiCreate( $"ui/gauntlet_hud.rpak", clGlobal.topoCockpitHud, RUI_DRAW_COCKPIT, 0 );
	RuiSetGameTime( CustomGauntlet.HUDRui, "startTime", Time() );

	if ( CustomGauntlet.BestRunTime > 0.0 )
	{
		RuiSetFloat( CustomGauntlet.HUDRui, "bestTime", CustomGauntlet.BestRunTime );
	}
}

void function CustomGauntlet_DestroyPlayerHUD()
{
	if ( CustomGauntlet.HUDRui != null )
	{
		RuiDestroyIfAlive( CustomGauntlet.HUDRui );
	}
	CustomGauntlet.HUDRui = null;
}

void function CustomGauntlet_FinishRun_PlayerHUD_Think( RunTime, BestRunTime, MissedEnemiesPenalty )
{
	if ( CustomGauntlet.HUDRui != null )
	{
		RuiSetBool( CustomGauntlet.HUDRui, "runFinished", true );
		RuiSetFloat( CustomGauntlet.HUDRui, "finalTime", RunTime );
		RuiSetFloat( CustomGauntlet.HUDRui, "bestTime", BestRunTime );
		RuiSetFloat( CustomGauntlet.HUDRui, "enemiesMissedTimePenalty", MissedEnemiesPenalty );

		wait 4.0;
		CustomGauntlet_DestroyPlayerHUD();
	}
}

#endif
