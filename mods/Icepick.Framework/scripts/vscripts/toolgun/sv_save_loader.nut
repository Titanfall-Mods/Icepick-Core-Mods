
global function AddOnHandleLoadTokenCallback
global function Spawnmenu_LoadSave

struct
{
	array<void functionref(string id, array<string> data)> onHandleLoadTokenCallback,
	array<CustomSpawnPoint> loadedCustomSpawns
} file

void function AddOnHandleLoadTokenCallback( void functionref(string id, array<string> data) callbackFunc )
{
	Assert( !file.onHandleLoadTokenCallback.contains( callbackFunc ), "Already added " + string( callbackFunc ) + " with AddOnHandleLoadTokenCallback" );
	file.onHandleLoadTokenCallback.append( callbackFunc );
}

void function Spawnmenu_LoadSave( string saveName )
{
	thread Spawnmenu_LoadSave_Thread( saveName );
}

void function Spawnmenu_LoadSave_Thread( string saveName )
{
	ShowLoadingModal();
	wait 0.2;

	// Clear temporary data
	file.loadedCustomSpawns.clear();

	// Load the file
	string saveContents = LoadSaveFileContents( saveName );

	// Split the file into lines and tokens and handle each line individually
	array<string> lines = split( saveContents, "\n" );
	foreach( line in lines )
	{
		array<string> tokens = split( line, ";" );
		string id = tokens[0];
		tokens.remove( 0 );
		HandleLoadToken( id, tokens );
	}

	// Move to a random custom spawn point if any were loaded
	if( file.loadedCustomSpawns.len() > 0 )
	{
		CustomSpawnPoint customSpawn = file.loadedCustomSpawns[RandomIntRange( 0, file.loadedCustomSpawns.len() )];
		entity player = GetPlayerByIndex( 0 );
		player.SetOrigin( customSpawn.anchorEnt.GetOrigin() + < 0, 0, 8 > );
		player.SetAngles( customSpawn.anchorEnt.GetAngles() );
	}

	wait 0.2;
	HideLoadingModal();
}

void function HandleLoadToken( string id, array<string> data )
{
	switch( id )
	{
		case "prop":
			HandleLoadProp( data );
			break;
		case "zipline":
			HandleLoadZipline( data );
			break;
		case "teleporter":
			HandleLoadTeleporter( data );
			break;
		case "spawnpoint":
			HandleLoadSpawnPoint( data );
			break;
	}

	foreach ( callbackFunc in file.onHandleLoadTokenCallback )
	{
		callbackFunc( id, data );
	}
}

void function HandleLoadProp( array<string> data )
{
	string assetName = data[0];
	vector position = Vector( data[1].tofloat(), data[2].tofloat(), data[3].tofloat() );
	vector angle = Vector( data[4].tofloat(), data[5].tofloat(), data[6].tofloat() );

	Spawnmenu_SpawnModelWithParams( assetName, position, angle );
}

void function HandleLoadZipline( array<string> data )
{
	string from = data[0] + " " + data[1] + " " + data[2];
	string to = data[3] + " " + data[4] + " " + data[5];
	ClientCommand( GetPlayerByIndex( 0 ), "ToolZipline_AddZipline " + from + " " + to );
}

void function HandleLoadTeleporter( array<string> data )
{
	vector entryOrigin = Vector( data[0].tofloat(), data[1].tofloat(), data[2].tofloat() );
	vector entryAngles = Vector( data[3].tofloat(), data[4].tofloat(), data[5].tofloat() );
	vector exitOrigin = Vector( data[6].tofloat(), data[7].tofloat(), data[8].tofloat() );
	vector exitAngles = Vector( data[9].tofloat(), data[10].tofloat(), data[11].tofloat() );

	Toolgun_CreateTeleporter( GetPlayerByIndex( 0 ), entryOrigin, entryAngles, exitOrigin, exitAngles, true );
}

void function HandleLoadSpawnPoint( array<string> data )
{
	vector origin = UnpackStringToVector( data[0] );
	vector angles = UnpackStringToVector( data[1] );
	CustomSpawnPoint newSpawn = ToolSpawnPoint_AddSpawn( origin, angles );
	file.loadedCustomSpawns.append( newSpawn );
}
