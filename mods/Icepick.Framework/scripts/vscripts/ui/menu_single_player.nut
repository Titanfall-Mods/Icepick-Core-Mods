global function InitSinglePlayerMenu
global function NewGameSelected
global function LoadLastCheckpoint
global function HasStartedGameEver
global function TrainingModeSelect
global function TrialMissionSelect
global function SPTrialMission_Start
global function ServerCallback_GetObjectiveReminderOnLoad
global function ServerCallback_ClearObjectiveReminderOnLoad
global function ScriptCallback_Beacon_FreeTrialOverMessage

struct SPLevelStartStruct
{
	int levelNum
	string levelBsp
	string startPoint
	string levelId
	string levelName
	string levelDesc
	asset levelImage = $""
	bool showLions
	bool alwaysUnlocked
}

struct
{
	var menu
	GridMenuData gridData
	bool isGridInitialized = false
	array<SPLevelStartStruct> mainLevels
	table< int, array<SPLevelStartStruct> > allLevels
	int lastLevelSelected = 0
	int lastLevelUnlocked = 0
	int difficulty = DIFFICULTY_NORMAL
	int selectedLevelNum = -1
	string selectedLevel = ""
	string selectedStartPoint = ""
	bool playIntro = false
	int currentBackground = 0
	bool addObjectiveReminderOnSaveLoad
	array<void functionref()> levelPartSelectFunc
	int focusedElemNum = 0

	// @icepick
	string gamemode = "solo"
} file

void function InitSinglePlayerMenu()
{
	var menu = GetMenu( "SinglePlayerMenu" )
	file.menu = menu

	file.levelPartSelectFunc.append( LevelPartSelect_Pt1 )
	file.levelPartSelectFunc.append( LevelPartSelect_Pt2 )
	file.levelPartSelectFunc.append( LevelPartSelect_Pt3 )

	var dataTable = GetDataTable( $"datatable/sp_levels.rpak" )
	int numRows = GetDatatableRowCount( dataTable )

	for ( int i=0; i<numRows; i++ )
	{
		bool isMain = GetDataTableBool( dataTable, i, GetDataTableColumnByName( dataTable, "mainEntry" ) )
		SPLevelStartStruct data
		data.levelBsp = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "level" ) )
		data.startPoint = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "startPoint" ) )
		data.levelId = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "levelId" ) )
		data.levelNum = GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "levelNum" ) )
		data.levelName = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "title" ) )
		data.levelDesc = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "desc" ) )
		data.levelImage = GetDataTableAsset( dataTable, i, GetDataTableColumnByName( dataTable, "missionSelectImage" ) )
		data.showLions = GetDataTableBool( dataTable, i, GetDataTableColumnByName( dataTable, "showLions" ) )

		if ( isMain )
		{
			file.mainLevels.append( data )
		}

		if (!( data.levelNum in file.allLevels ))
		{
			file.allLevels[ data.levelNum ] <- []
		}

		file.allLevels[ data.levelNum ].append( data )
	}

	AddMPMapToMenu( "mp_black_water_canal", "Black Water Canal", "An IMC fueling station nestled deep in the rocky canals of the planet Cibus.", $"loadscreens/mp_black_water_canal_lobby" );
	AddMPMapToMenu( "mp_grave", "Boomtown", "An underground IMC Simulation Dome, one of many hidden throughout the Frontier.", $"loadscreens/mp_grave_lobby" );
	AddMPMapToMenu( "mp_crashsite3", "Crash Site", "The wreckage of the MCS James MacAllan on the planet Typhon.", $"loadscreens/mp_crashsite3_lobby" );
	AddMPMapToMenu( "mp_complex3", "Complex", "An IMC research complex on Typhon, used to test the effects of the Fold Weapon and the Ark.", $"loadscreens/mp_complex3_lobby" );
	AddMPMapToMenu( "mp_drydock", "Drydock", "A drydock for spacefaring vessels controlled by the IMC.", $"loadscreens/mp_drydock_lobby" );
	AddMPMapToMenu( "mp_eden", "Eden", "A dilapidated residential community for IMC employees, ravaged by years of fracking.", $"loadscreens/mp_eden_lobby" );
	AddMPMapToMenu( "mp_thaw", "Exoplanet", "A biological research station on a remote Frontier planet.", $"loadscreens/mp_thaw_lobby" );
	AddMPMapToMenu( "mp_forwardbase_kodai", "Forwardbase Kodai", "A facility overlooking one of Typhon's interstellar beacons.", $"loadscreens/mp_forwardbase_kodai_lobby" );
	AddMPMapToMenu( "mp_homestead", "Homestead", "A farming colony occupied by the IMC.", $"loadscreens/mp_homestead_lobby" );
	AddMPMapToMenu( "mp_colony02", "Colony", "A disputed town on the planet Troy, fought over by the Militia and IMC.", $"loadscreens/mp_colony02_lobby" );
	AddMPMapToMenu( "mp_angel_city", "Angel City", "One of the largest human settlements in the Frontier. It is tightly controlled by the IMC.", $"loadscreens/mp_angle_city_r2_lobby" );
	AddMPMapToMenu( "mp_glitch", "Glitch", "A VR simulation based on the planet Harmony.", $"loadscreens/mp_glitch_lobby" );
	AddMPMapToMenu( "mp_relic02", "Relic", "The wreck of the IMS Odyssey, stripped for materials by it's former crew to build their new colony.", $"loadscreens/mp_relic02_lobby" );
	AddMPMapToMenu( "mp_wargames", "War Games", "A VR simulation based on Angel City and Airbase Sierra, corrupted by heavy interference.", $"loadscreens/mp_wargames_lobby" );
	AddMPMapToMenu( "mp_rise", "Rise", "A long range desert partol output setup in an abandoned IMC reservoir.", $"loadscreens/mp_rise_lobby" );
	AddMPMapToMenu( "mp_lf_stacks", "Livefire: Stacks", "A combat simulation facility with many shipping containers and construction platforms.", $"loadscreens/mp_stacks_lobby" );
	AddMPMapToMenu( "mp_lf_meadow", "Livefire: Meadow", "A rural combat simulation facility.", $"loadscreens/mp_meadow_lobby" );
	AddMPMapToMenu( "mp_lf_township", "Livefire: Township", "A combat simulation facility focused on urban combat.", $"loadscreens/mp_lf_township_lobby" );
	AddMPMapToMenu( "mp_lf_deck", "Livefire: Deck", "A combat simulation facility that specializes in urban and close quarters combat.", $"loadscreens/mp_lf_deck_lobby" );
	AddMPMapToMenu( "mp_lf_traffic", "Livefire: Traffic", "A combat simulation facility with many vehicles for cover.", $"loadscreens/mp_lf_traffic_lobby" );
	AddMPMapToMenu( "mp_lf_uma", "Livefire: UMA", "A combat simulation facility with tight corridors and small open spaces.", $"loadscreens/mp_lf_uma_lobby" );
	AddMPMapToMenu( "mp_coliseum", "Coliseum", "A simulated arena where pilots compete to prove their combat skills.", $"loadscreens/mp_coliseum_lobby" );
	AddMPMapToMenu( "mp_coliseum_column", "Pillars", "A simulated arena, with three vertical pillars, where pilots compete to prove their combat skills.", $"loadscreens/mp_coliseum_column_lobby" );

	file.gridData.rows = 2
	file.gridData.columns = 5
	file.gridData.paddingVert = 5
	file.gridData.paddingHorz = 5
	file.gridData.numElements = file.mainLevels.len()
	file.gridData.pageType = eGridPageType.HORIZONTAL
	file.gridData.tileWidth = Grid_GetMaxWidthForSettings( menu, file.gridData )

	float tileHeight = ( file.gridData.tileWidth * 9.0 ) / 21.0

	file.gridData.tileHeight = minint( Grid_GetMaxHeightForSettings( menu, file.gridData ), int( tileHeight ) + 80 )
	file.gridData.initCallback = SPButtonInit
	file.gridData.buttonFadeCallback = SP_FadeDefaultElementChildren
	file.gridData.getFocusCallback = SPButton_GetFocus
	file.gridData.clickCallback = SPButton_Click

	var elem = Hud_GetChild( menu, "MasterIcon" )
	var rui = Hud_GetRui( elem )
	RuiSetImage( rui, "basicImage", $"rui/menu/level_select/master_badge" )

	elem = Hud_GetChild( menu, "CollectiblesIcon" )
	rui = Hud_GetRui( elem )
	RuiSetImage( rui, "basicImage", $"rui/menu/level_select/lion_badge" )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnOpenSinglePlayerMenu )

	AddMenuFooterOption( menu, BUTTON_A, "#A_BUTTON_SELECT", "" )
	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
}

void function AddMPMapToMenu( string MapBSP, string Name, string Desc, asset Image )
{
	SPLevelStartStruct newMap
	newMap.levelBsp = MapBSP;
	newMap.startPoint = "0";
	newMap.levelId = MapBSP;
	newMap.levelNum = file.allLevels.len();
	newMap.levelName = "[MP] " + Name;
	newMap.levelDesc = Desc;
	newMap.levelImage = Image;
	newMap.showLions = false;
	newMap.alwaysUnlocked = true;

	file.mainLevels.append( newMap );

	if (!( newMap.levelNum in file.allLevels ))
	{
		file.allLevels[ newMap.levelNum ] <- [];
	}
	file.allLevels[ newMap.levelNum ].append( newMap );
}


bool function SPButtonInit( var button, int elemNum )
{
	var rui = Hud_GetRui( button )

	SPLevelStartStruct data = file.mainLevels[ elemNum ]

	asset levelImage = data.levelImage

	RuiSetImage( rui, "itemImage", levelImage )

	UpdateButtonData( button, elemNum )

	return true
}

void function UpdateButtonData( var button, int elemNum )
{
	SPLevelStartStruct data = file.mainLevels[ elemNum ]
	var rui = Hud_GetRui( button )
	string bspName = data.levelBsp
	string levelName = data.levelName
	if ( elemNum > file.lastLevelUnlocked && !data.alwaysUnlocked )
	{
		RuiSetString( rui, "title", "#MENU_ITEM_LOCKED" )
		Hud_SetLocked( button, true )
	}
	else
	{
		RuiSetString( rui, "title", levelName )
		Hud_SetLocked( button, false )
	}

	int foundLions = GetCombinedCollectiblesFoundForLevel( bspName )
	int maxLions = GetCombinedLionsInLevel( bspName )

	bool completedMaster = GetCompletedMasterForLevel( elemNum )
	RuiSetInt( rui, "blueLionCount", foundLions )
	RuiSetInt( rui, "blueLionTotal", maxLions )
	RuiSetBool( rui, "finishedMaster", completedMaster )

	if ( elemNum == 0 )
		RuiSetBool( rui, "showMaster", false )
	else
		RuiSetBool( rui, "showMaster", true )
}

void function SPButton_GetFocus( var button, int elemNum )
{
	file.focusedElemNum = elemNum

	SPLevelStartStruct data = file.mainLevels[ elemNum ]
	string levelName = data.levelName
	string desc = data.levelDesc

	if ( elemNum > file.lastLevelUnlocked && !data.alwaysUnlocked )
	{
		levelName = "#MENU_ITEM_LOCKED"
		desc = "#MENU_ITEM_LOCKED"
	}
	else
	{
		file.lastLevelSelected = elemNum
	}

	HudElem_SetText( GetMenuChild( file.menu, "ContentDescriptionTitle" ), levelName )
	HudElem_SetText( GetMenuChild( file.menu, "ContentDescription" ), desc )

	string difficulty = GetBestCompletedDifficultyForLevel( elemNum )

	if ( difficulty == "" || elemNum == 0 )
	{
		HudElem_SetText( GetMenuChild( file.menu, "CompletedDescription" ), "" )
	}
	else
	{
		HudElem_SetText( GetMenuChild( file.menu, "CompletedDescription" ), Localize( "#MENU_COMPLETED", Localize( difficulty ) ) )
	}
}

void function SPButton_Click( var button, int elemNum )
{
	SPLevelStartStruct data = file.mainLevels[ elemNum ]
	file.selectedLevelNum = elemNum
	file.selectedLevel = data.levelBsp
	file.selectedStartPoint = data.startPoint
	file.playIntro = false

	if ( elemNum > file.lastLevelUnlocked && !data.alwaysUnlocked )
	{
		return
	}

	if ( DevStartPoints() )
	{
		if ( Dev_CommandLineHasParm( STARTPOINT_DEV_STRING ) )
			Dev_CommandLineRemoveParm( STARTPOINT_DEV_STRING )
	}

	// @todo: allow gamemode selecting here
	if ( elemNum == 0 )
	{
		TrainingModeSelect()
		return
	}
	else if ( GetLastLevelUnlocked() > elemNum && !data.alwaysUnlocked  )
	{
		if ( LevelPartSelect( elemNum ) )
			return
	}

	// DifficultyMenuPopUp()
	// @icepick
	GamemodeMenuPopUp()
}

bool function LevelPartSelect( int levelNum )
{
	array<SPLevelStartStruct> parts = file.allLevels[ levelNum ]

	if ( parts.len() <= 1 )
		return false

	DialogData dialogData
	dialogData.header = Localize( "#MENU_SP_CHAPTER_SELECT_TITLE_MSG", Localize( file.mainLevels[ levelNum ].levelName ) )
	dialogData.message = "#MENU_SP_CHAPTER_SELECT_TITLE"

	for ( int i=0; i<parts.len(); i++ )
	{
		SPLevelStartStruct data = parts[i]

		string baseString = "#MENU_MISSION_SELECT_CHAPTER"

		if ( data.showLions )
		{
			if ( GetCompletedMasterForLevelId( data.levelId ) )
			{
				baseString = "#MENU_MISSION_SELECT_CHAPTER_MASTER"
			}
			else
			{
				baseString = "#MENU_MISSION_SELECT_CHAPTER"
			}
		}
		else
		{
			if ( GetCompletedMasterForLevelId( data.levelId ) )
			{
				baseString = "#MENU_MISSION_SELECT_CHAPTER_NOLION_MASTER"
			}
			else
			{
				baseString = "#MENU_MISSION_SELECT_CHAPTER_NOLION"
			}
		}

		if ( data.showLions )
			AddDialogButton( dialogData, Localize( baseString, (i+1), GetCollectiblesFoundForLevel( data.levelBsp ), GetMaxLionsInLevel( data.levelBsp ) ), file.levelPartSelectFunc[i] )
		else
			AddDialogButton( dialogData, Localize( baseString, (i+1) ), file.levelPartSelectFunc[i] )
	}

	AddDialogPCBackButton( dialogData )
	AddDialogFooter( dialogData, "#A_BUTTON_ACCEPT" )
	AddDialogFooter( dialogData, "#B_BUTTON_BACK" )

	OpenDialog( dialogData )

	return true
}

void function TrialMissionSelect()
{
	if ( GetConVarInt( "sp_unlockedMission" ) < 1 )
		TrainingStart_NormalMode()

	DialogData dialogData
	dialogData.header = "#SP_TRIAL_MENU_MISSION"
	dialogData.message = "#SP_TRIAL_MENU_MISSION_MSG"

	AddDialogButton( dialogData, "#SP_TRIAL_START_MISSION", LaunchSPTrialMission )

	if ( HasValidSaveGame() )
		AddDialogButton( dialogData, "#SP_TRIAL_CONTINUE_MISSION", LaunchSPContinue )

	AddDialogFooter( dialogData, "#A_BUTTON_ACCEPT" )
	AddDialogFooter( dialogData, "#B_BUTTON_BACK" )

	OpenDialog( dialogData )
}

void function TrainingModeSelect()
{
	if ( GetConVarInt( "sp_unlockedMission" ) < 1 )
		TrainingStart_NormalMode()

	DialogData dialogData
	dialogData.header = "#TRAINING_SELECT_TITLE"
	dialogData.message = "#TRAINING_SELECT_MSG"

	AddDialogButton( dialogData, "#TRAINING_SELECT_BTN_GAUNTLET_MODE", TrainingStart_GauntletMode )
	AddDialogButton( dialogData, "#TRAINING_SELECT_BTN_NORMAL_MODE", TrainingStart_NormalMode )

	AddDialogFooter( dialogData, "#A_BUTTON_ACCEPT" )
	AddDialogFooter( dialogData, "#B_BUTTON_BACK" )

	OpenDialog( dialogData )
}

void function TrainingStart_NormalMode()
{
	if ( DevStartPoints() )
	{
		if ( Dev_CommandLineHasParm( STARTPOINT_DEV_STRING ) )
			Dev_CommandLineRemoveParm( STARTPOINT_DEV_STRING )
	}

	PreCacheLevelDuringVideo( "sp_training" )
	file.selectedLevel = "sp_training"
	file.selectedStartPoint = "Pod Intro"
	file.playIntro = true
	StartLevelNormal()

	if ( uiGlobal.activeMenu == file.menu )
		CloseActiveMenu()
}

void function TrainingStart_GauntletMode()
{
	file.selectedLevel = "sp_training"
	file.selectedStartPoint = "Gauntlet Mode"
	LoadSPLevel()
	if ( uiGlobal.activeMenu == file.menu )
		CloseActiveMenu()
}


void function NewGameSelected()
{
	// only do this if we detect existing data
	if ( HasValidSaveGame() )
		NewGame_ConfirmStart()
	else
		NewGame_Start()
}

void function SPTrialMission_Start()
{
	file.selectedLevel = "sp_beacon"
	file.selectedStartPoint = "Level Start"
	file.playIntro = false

	// DifficultyMenuPopUp()
	// @icepick
	GamemodeMenuPopUp()
}

void function NewGame_ConfirmStart()
{
	DialogData dialogData
	dialogData.header = "#MENU_NEW_GAME_CONFIRM_TITLE"
	dialogData.message = "#MENU_NEW_GAME_CONFIRM_MSG"

	AddDialogButton( dialogData, "#YES", NewGame_DoubleConfirmStart )
	AddDialogButton( dialogData, "#CANCEL" )

	AddDialogFooter( dialogData, "#A_BUTTON_ACCEPT" )
	AddDialogFooter( dialogData, "#B_BUTTON_BACK" )

	OpenDialog( dialogData )
}

void function NewGame_DoubleConfirmStart()
{
	DialogData dialogData
	dialogData.header = "#MENU_NEW_GAME_DOUBLE_CONFIRM_TITLE"
	dialogData.message = "#MENU_NEW_GAME_DOUBLE_CONFIRM_MSG"

	AddDialogButton( dialogData, "#MENU_NEW_GAME_DOUBLE_CONFIRM_BTN_OK", NewGame_Start )
	AddDialogButton( dialogData, "#CANCEL" )

	AddDialogFooter( dialogData, "#A_BUTTON_ACCEPT" )
	AddDialogFooter( dialogData, "#B_BUTTON_BACK" )

	OpenDialog( dialogData )
}

void function NewGame_Start()
{
	if ( DevStartPoints() )
	{
		if ( Dev_CommandLineHasParm( STARTPOINT_DEV_STRING ) )
			Dev_CommandLineRemoveParm( STARTPOINT_DEV_STRING )
	}

	NewGame_ResetCampaignProgress()
	PreCacheLevelDuringVideo( "sp_training" )

	file.selectedLevel = "sp_training"
	file.selectedStartPoint = "Pod Intro"
	file.playIntro = true

	StartLevelNormal()
	//DifficultyMenuPopUp()
}

void function NewGame_ResetCampaignProgress()
{
	// lock mission select
	SetConVarInt( "sp_unlockedMission", 0 )

	// reset collectibles
	ResetCollectiblesProgress_All()

	// reset unlocked titan loadouts
	SetConVarInt( "sp_titanLoadoutsSelected", 0 )
}

void function DifficultyMenuPopUp()
{
	DialogData dialogData
	dialogData.header = "#SP_DIFFICULTY_MISSION_SELECT_TITLE"

	AddDialogButton( dialogData, "#SP_DIFFICULTY_EASY_TITLE", StartLevelEasy, "#SP_DIFFICULTY_EASY_DESCRIPTION" )
	AddDialogButton( dialogData, "#SP_DIFFICULTY_NORMAL_TITLE", StartLevelNormal, "#SP_DIFFICULTY_NORMAL_DESCRIPTION" )
	AddDialogButton( dialogData, "#SP_DIFFICULTY_HARD_TITLE", StartLevelHard, "#SP_DIFFICULTY_HARD_DESCRIPTION" )
	AddDialogButton( dialogData, "#SP_DIFFICULTY_MASTER_TITLE", StartLevelMaster, "#SP_DIFFICULTY_MASTER_DESCRIPTION" )

	AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )
	AddDialogFooter( dialogData, "#B_BUTTON_BACK" )
	AddDialogPCBackButton( dialogData )

	OpenDialog( dialogData )
}

void function RunDifficulty()
{
	if ( file.selectedLevel == "" )
		return

	if ( file.selectedStartPoint == "" )
		return

	if ( file.playIntro )
	{
		SetMouseCursorVisible( false ) // restore done automatically on changing level/returning to main menu
		PlayVideoMenu( "intro", true, LoadSPLevel )
		StopMusic()
	}
	else
	{
		LoadSPLevel()
	}

	if ( uiGlobal.activeMenu == file.menu )
		CloseActiveMenu()
}

void function LoadSPLevel()
{
	// @icepick
	ClientCommand( "icepick_gamemode " + file.gamemode )
	ClientCommand( "reload_mods" )

	file.addObjectiveReminderOnSaveLoad = false
	SetConVarInt( "sp_titanLoadoutCurrent", -1 )
	SetConVarInt( "sp_difficulty", file.difficulty )
	SetLevelNameForLoading( file.selectedLevel )
	int idx = GetStartPointIndexFromName( file.selectedLevel, file.selectedStartPoint )
	ExecuteLoadingClientCommands_SetStartPoint( file.selectedLevel, idx )
	ClientCommand( "map " + file.selectedLevel )
}

void function StartLevelEasy()
{
	file.difficulty = DIFFICULTY_EASY
	thread RunDifficulty()
}

void function StartLevelNormal()
{
	file.difficulty = DIFFICULTY_NORMAL
	thread RunDifficulty()
}

void function StartLevelHard()
{
	file.difficulty = DIFFICULTY_HARD
	thread RunDifficulty()
}

void function StartLevelMaster()
{
	file.difficulty = DIFFICULTY_MASTER
	thread RunDifficulty()
}

void function OnOpenSinglePlayerMenu()
{
	if ( !file.isGridInitialized )
	{
		GridMenuInit( file.menu, file.gridData )
		file.isGridInitialized = true
	}

	file.lastLevelUnlocked = GetLastLevelUnlocked()

	Grid_InitPage( file.menu, file.gridData )

	int levelFocus = minint( file.lastLevelUnlocked, file.lastLevelSelected )

	int row = Grid_GetRowFromElementNumber( levelFocus, file.gridData )
	int col = Grid_GetColumnFromElementNumber( levelFocus, file.gridData )
	Hud_SetFocused( Grid_GetButtonAtRowColumn( file.menu, row, col ) )
}

bool function GetCompletedMasterForLevel( int elemNum )
{
	array<SPLevelStartStruct> datas = file.allLevels[ elemNum ]
	foreach( data in datas )
	{
		if ( !GetCompletedMasterForLevelId( data.levelId ) )
		{
			return false
		}
}

	return true
}

bool function GetCompletedMasterForLevelId( string levelId )
{
	return GetCompletedDifficultyForLevelId( levelId, "sp_missionMasterCompletion" )
}

string function GetBestCompletedDifficultyForLevel( int elemNum )
{
	int lowestDifficulty = 999

	array<SPLevelStartStruct> datas = file.allLevels[ elemNum ]
	foreach( data in datas )
	{
		int d = GetBestCompletedDifficultyForLevelId( data.levelId )
		if ( d < lowestDifficulty )
			lowestDifficulty = d
	}

	switch ( lowestDifficulty )
	{
		case DIFFICULTY_MASTER:
			return "#SP_DIFFICULTY_MASTER_TITLE"
		case DIFFICULTY_HARD:
			return "#SP_DIFFICULTY_HARD_TITLE"
		case DIFFICULTY_NORMAL:
			return "#SP_DIFFICULTY_NORMAL_TITLE"
		case DIFFICULTY_EASY:
			return "#SP_DIFFICULTY_EASY_TITLE"
	}

	return ""
}

void function SP_FadeDefaultElementChildren( var elem, int fadeTarget, float fadeTime )
{

}

void function LoadLastCheckpoint()
{
	file.addObjectiveReminderOnSaveLoad = true

	if ( !HasValidSaveGame() )
		return

	printt( "SAVEGAME: Trying to load checkpoint from menu_single_player" )
	SaveGame_LoadWithStartPointFallback( DETENT_FORCE_ENABLE, COOPERS_LOG_FROM_STARTPOINT )
}

bool function HasStartedGameEver()
{
	return GetLastLevelUnlocked() > 0
}

void function ServerCallback_GetObjectiveReminderOnLoad()
{
	printt( "ServerCallback_GetObjectiveReminderOnLoad" )
	if ( !file.addObjectiveReminderOnSaveLoad )
		return

	printt( "SHOW OBJ" )
	ClientCommand( "ShowObjective" )
}

void function ServerCallback_ClearObjectiveReminderOnLoad()
{
	file.addObjectiveReminderOnSaveLoad = false
}

void function ScriptCallback_Beacon_FreeTrialOverMessage()
{
	thread Beacon_FreeTrialOverMessage()
}

void function Beacon_FreeTrialOverMessage()
{
	DialogData dialogData
	dialogData.header = "#SP_TRIAL_OVER_TITLE"
	dialogData.message = "#SP_TRIAL_OVER_MSG"
	dialogData.forceChoice = true

	AddDialogButton( dialogData, "#MENU_GET_THE_FULL_GAME", SP_Trial_LaunchGamePurchase )
	AddDialogButton( dialogData, "#CANCEL_AND_QUIT_TO_MAIN_MENU", Disconnect )

	AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )

	OpenDialog( dialogData )
}

void function LevelPartSelect_Pt1()
{
	LoadLevelPart( file.selectedLevelNum, 0 )
}

void function LevelPartSelect_Pt2()
{
	LoadLevelPart( file.selectedLevelNum, 1 )
}

void function LevelPartSelect_Pt3()
{
	LoadLevelPart( file.selectedLevelNum, 2 )
}

void function LoadLevelPart( int levelNum, int levelPart )
{
	array<SPLevelStartStruct> parts = file.allLevels[ levelNum ]
	SPLevelStartStruct data = parts[ levelPart ]
	file.selectedLevel = data.levelBsp
	file.selectedStartPoint = data.startPoint

	// DifficultyMenuPopUp()
	// @icepick
	GamemodeMenuPopUp()
}

bool function IsUnlockedChapterFocused()
{
	if ( file.focusedElemNum <= file.lastLevelUnlocked )
		return true

	return false
}

// @icepick
void function GamemodeMenuPopUp()
{
	DialogData dialogData
	dialogData.header = "Select Gamemode"

	// @note: since we're in the ui context we need to register them here so that we can make them appear in the menu
	Icepick_RegisterGamemodes()

	// Show all gamemodes
	foreach( IcepickGamemode gamemode in GlobalGamemodes )
	{
		if( gamemode.validLevels.contains(file.selectedLevel) )
		{
			void functionref() callbackFunc = void function() : ( gamemode ) 
			{
				file.gamemode = gamemode.id;
				DifficultyMenuPopUp();
			}

			AddDialogButton( dialogData, gamemode.name, callbackFunc, gamemode.description );
		}
	}

	AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )
	AddDialogFooter( dialogData, "#B_BUTTON_BACK" )
	AddDialogPCBackButton( dialogData )

	OpenDialog( dialogData )
}
