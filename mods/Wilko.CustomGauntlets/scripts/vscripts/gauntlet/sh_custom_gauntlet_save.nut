
global const float CUSTOM_GAUNTLET_SAVE_VERSION = 2.0;

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
	for( int i = 0; i < CustomGauntletsGlobal.DevelopmentTrack.Starts.len(); ++i )
	{
		CustomGauntletsGlobal.DevelopmentTrack.Starts[i].left.Destroy();
	}
	for( int i = 0; i < CustomGauntletsGlobal.DevelopmentTrack.Finishes.len(); ++i )
	{
		CustomGauntletsGlobal.DevelopmentTrack.Finishes[i].left.Destroy();
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

	for( int i = 0; i < CustomGauntletsGlobal.DevelopmentTrack.Starts.len(); ++i )
	{
		GauntletTriggerLine start = CustomGauntletsGlobal.DevelopmentTrack.Starts[i];
		string leftOrigin = PackVectorToString( start.left.GetOrigin() );
		string rightOrigin = PackVectorToString( start.right.GetOrigin() );
		string entry = IcepickSaveOutput( "gauntlet.start", leftOrigin, rightOrigin, start.triggerHeight );
		AddSaveItem( entry );
	}

	for( int i = 0; i < CustomGauntletsGlobal.DevelopmentTrack.Finishes.len(); ++i )
	{
		GauntletTriggerLine finish = CustomGauntletsGlobal.DevelopmentTrack.Finishes[i];
		string leftOrigin = PackVectorToString( finish.left.GetOrigin() );
		string rightOrigin = PackVectorToString( finish.right.GetOrigin() );
		string entry = IcepickSaveOutput( "gauntlet.end", leftOrigin, rightOrigin, finish.triggerHeight );
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
