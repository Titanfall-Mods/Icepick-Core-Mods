
global function AddOnHandleLoadTokenCallback
global function Spawnmenu_LoadSave

struct
{
	array<void functionref(string id, array<string> data)> onHandleLoadTokenCallback
} file

void function AddOnHandleLoadTokenCallback( void functionref(string id, array<string> data) callbackFunc )
{
	Assert( !file.onHandleLoadTokenCallback.contains( callbackFunc ), "Already added " + string( callbackFunc ) + " with AddOnHandleLoadTokenCallback" );
	file.onHandleLoadTokenCallback.append( callbackFunc );
}

void function Spawnmenu_LoadSave( string saveName )
{
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
