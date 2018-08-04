
const float CUSTOM_GAUNTLET_SAVE_VERSION = 1.0;

#if CLIENT
global function CustomGauntlet_Client_SaveInit
#endif

#if SERVER
global function CustomGauntlet_Server_SaveInit
global function CleanupGauntlets
#endif

#if CLIENT
void function CustomGauntlet_Client_SaveInit()
{
	RegisterCategoryItem( "utilities", "cleanup.gauntlet", "Cleanup Gauntlets" );
}
#endif

#if SERVER
void function CustomGauntlet_Server_SaveInit()
{
	AddOnSpawnmenuUtilityCallback( OnUtilityCallback );
	AddOnIcepickSaveCallback( OnIcepickSave );
}

void function OnUtilityCallback( string utility )
{
	switch( utility )
	{
		case "cleanup.all":
		case "cleanup.gauntlet":
			CleanupGauntlets();
			break;
	}
}

void function CleanupGauntlets()
{
	if( CustomGauntletsGlobal.DevelopmentTrack.StartLine.IsValid )
	{
		CustomGauntletsGlobal.DevelopmentTrack.StartLine.FromEnt.Destroy(); // Only destroy one entity and let the think cleanup the rest automatically
	}
	if( CustomGauntletsGlobal.DevelopmentTrack.FinishLine.IsValid )
	{
		CustomGauntletsGlobal.DevelopmentTrack.FinishLine.FromEnt.Destroy(); // Only destroy one entity and let the think cleanup the rest automatically
	}
	for( int i = 0; i < CustomGauntletsGlobal.DevelopmentTrack.Targets.len(); ++i )
	{
		CustomGauntletsGlobal.DevelopmentTrack.Targets[i].SpawnedEnemy.Destroy();
	}
	for( int i = 0; i < CustomGauntletsGlobal.DevelopmentTrack.RespawningWeapons.len(); ++i )
	{
		CustomGauntletsGlobal.DevelopmentTrack.RespawningWeapons[i].ReferenceEnt.Destroy();
	}
	for( int i = 0; i < CustomGauntletsGlobal.DevelopmentTrack.Scoreboards.len(); ++i )
	{
		CustomGauntletsGlobal.DevelopmentTrack.Scoreboards[i].ReferenceEnt.Destroy();
	}
	for( int i = 0; i < CustomGauntletsGlobal.DevelopmentTrack.StatsBoards.len(); ++i )
	{
		CustomGauntletsGlobal.DevelopmentTrack.StatsBoards[i].ReferenceEnt.Destroy();
	}
}

// Add custom gauntlet entities when creating a save
void function OnIcepickSave()
{
	AddSaveItem( IcepickSaveOutput( "gauntlet.save-version", CUSTOM_GAUNTLET_SAVE_VERSION ) );
	AddSaveItem( IcepickSaveOutput( "gauntlet.id", CustomGauntletsGlobal.DevelopmentTrack.Id ) );
	AddSaveItem( IcepickSaveOutput( "gauntlet.name", CustomGauntletsGlobal.DevelopmentTrack.TrackName ) );

	for( int i = 0; i < CustomGauntletsGlobal.DevelopmentTrack.Tips.len(); ++i )
	{
		AddSaveItem( IcepickSaveOutput( "gauntlet.tip", CustomGauntletsGlobal.DevelopmentTrack.Tips[i] ) );
	}

	for( int i = 0; i < CustomGauntletsGlobal.DevelopmentTrack.Highscores.len(); ++i )
	{
		GauntletHighscore highscore = CustomGauntletsGlobal.DevelopmentTrack.Highscores[i];
		AddSaveItem( IcepickSaveOutput( "gauntlet.highscore", highscore.Name, highscore.Time ) );
	}

	if( CustomGauntletsGlobal.DevelopmentTrack.StartLine.IsValid )
	{
		vector start = CustomGauntletsGlobal.DevelopmentTrack.StartLine.FromEnt.GetOrigin();
		vector end = CustomGauntletsGlobal.DevelopmentTrack.StartLine.ToEnt.GetOrigin();
		string entry = IcepickSaveOutput( "gauntlet.start", start.x, start.y, start.z, end.x, end.y, end.z );
		AddSaveItem( entry );
	}

	if( CustomGauntletsGlobal.DevelopmentTrack.FinishLine.IsValid )
	{
		vector start = CustomGauntletsGlobal.DevelopmentTrack.FinishLine.FromEnt.GetOrigin();
		vector end = CustomGauntletsGlobal.DevelopmentTrack.FinishLine.ToEnt.GetOrigin();
		string entry = IcepickSaveOutput( "gauntlet.end", start.x, start.y, start.z, end.x, end.y, end.z );
		AddSaveItem( entry );
	}

	for( int i = 0; i < CustomGauntletsGlobal.DevelopmentTrack.Targets.len(); ++i )
	{
		string enemyType = CustomGauntletsGlobal.DevelopmentTrack.Targets[i].EnemyType;
		vector pos = CustomGauntletsGlobal.DevelopmentTrack.Targets[i].Position;
		vector rot = CustomGauntletsGlobal.DevelopmentTrack.Targets[i].Rotation;
		string entry = IcepickSaveOutput( "gauntlet.target", enemyType, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z );
		AddSaveItem( entry );
	}

	for( int i = 0; i < CustomGauntletsGlobal.DevelopmentTrack.Scoreboards.len(); ++i )
	{
		GauntletWorldUI worldUi = CustomGauntletsGlobal.DevelopmentTrack.Scoreboards[i];
		vector pos = worldUi.ReferenceEnt.GetOrigin();
		vector rot = worldUi.ReferenceEnt.GetAngles();
		AddSaveItem( IcepickSaveOutput( "gauntlet.scoreboard", pos.x, pos.y, pos.z, rot.x, rot.y, rot.z ) );
	}

	for( int i = 0; i < CustomGauntletsGlobal.DevelopmentTrack.StatsBoards.len(); ++i )
	{
		GauntletWorldUI worldUi = CustomGauntletsGlobal.DevelopmentTrack.StatsBoards[i];
		vector pos = worldUi.ReferenceEnt.GetOrigin();
		vector rot = worldUi.ReferenceEnt.GetAngles();
		AddSaveItem( IcepickSaveOutput( "gauntlet.statsboard", pos.x, pos.y, pos.z, rot.x, rot.y, rot.z ) );
	}

	for( int i = 0; i < CustomGauntletsGlobal.DevelopmentTrack.RespawningWeapons.len(); ++i )
	{
		GauntletWeapon respawningWeapon = CustomGauntletsGlobal.DevelopmentTrack.RespawningWeapons[i];
		vector pos = respawningWeapon.ReferenceEnt.GetOrigin();
		vector rot = respawningWeapon.ReferenceEnt.GetAngles();
		AddSaveItem( IcepickSaveOutput( "gauntlet.weapon", respawningWeapon.WeaponClass, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z ) );
	}	
}
#endif
