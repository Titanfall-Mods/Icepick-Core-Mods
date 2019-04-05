
global function Spawnmenu_Init_Saves

#if CLIENT
global function Spawnmenu_OnSavedGameToFile
#endif

struct
{
	array<string> saveCategories,
	array<string> existingSaveFiles
} file

void function Spawnmenu_Init_Saves()
{
	#if CLIENT
	RegisterSpawnmenuPage( "saves", "Saves" );

	// Add categories where all our saves will be listed
	RegisterPageCategory( "saves", "saves-current", GetLocalizedMapName( GetMapName() ) + " Saves", "Spawnmenu_LoadSave" ); // Current map saves
	file.saveCategories.append( "saves-current" );

	// List save files in the saves folder
	array<string> saveNames = UntypedArrayToStringArray( GetSaveFiles() );
	foreach( saveFile in saveNames )
	{
		AddSaveFileToMenu( saveFile );
	}
	#endif
}

#if CLIENT
string function GetLocalizedMapName( string mapName )
{
	string mapLocalizationKey = "#" + mapName.toupper();
	string localized = Localize( mapLocalizationKey );

	// Campaign maps have different localization keys, so check for them if it fails
	if( localized == mapLocalizationKey )
	{
		localized = Localize( mapLocalizationKey + "_CAMPAIGN_NAME" );
	}

	// Append a map number for some campaign maps 
	switch( mapName )
	{
		case "sp_boomtown_start":
			localized += " Chapter 1";
			break;
		case "sp_boomtown":
			localized += " Chapter 2";
			break;
		case "sp_boomtown_end":
			localized += " Chapter 3";
			break;
		case "sp_beacon":
			localized += " Chapter 1/3";
			break;
		case "sp_beacon_spoke0":
			localized += " Chapter 2";
			break;
		case "sp_hub_timeshift":
			localized += " Chapter 1/3";
			break;
		case "sp_timeshift_spoke02":
			localized += " Chapter 2";
			break;
	}

	return localized;
}

void function AddSaveFileToMenu( string saveFile )
{
	// Make sure the file is unique when we refresh the list
	foreach( existingSave in file.existingSaveFiles )
	{
		if( existingSave == saveFile )
		{
			return;
		}
	}

	// Parse and add the file
	array<string> splitName = split( saveFile, "\\" );
	splitName = split( splitName[splitName.len() - 1], "." );

	string saveMap = splitName[ splitName.len() - 2 ];
	bool isCurrentMapSave = saveMap == GetMapName();
	string itemCategory = isCurrentMapSave ? "saves-current" : saveMap;

	// Create a category for every map so that people can easily find where their saves are
	if( file.saveCategories.find( itemCategory ) < 0 )
	{
		RegisterPageCategory( "saves", itemCategory, GetLocalizedMapName( saveMap ) + " Saves", "Spawnmenu_LoadSave" );
		file.saveCategories.append( itemCategory );
	}

	string fileName = "";
	string displayName = "";
	for( int i = 0; i < splitName.len(); ++i )
	{
		fileName += (fileName == "" ? "" : ".") + splitName[i];
		if( i < splitName.len() - 2 )
		{
			displayName += (displayName == "" ? "" : ".") + splitName[i];
		}
	}

	RegisterCategoryItem( itemCategory, fileName, displayName );

	// Record the file as existing so we don't get duplicates
	file.existingSaveFiles.append( saveFile );
}

void function Spawnmenu_OnSavedGameToFile( string fileName )
{
	AddSaveFileToMenu( fileName );
}
#endif
