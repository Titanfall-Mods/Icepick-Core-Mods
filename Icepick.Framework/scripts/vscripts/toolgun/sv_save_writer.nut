
global function IcepickSave
global function IcepickSaveOutput
global function AddOnIcepickSaveCallback

const float LATEST_ICEPICK_SAVE_VERSION = 1.0;

struct
{
	array<void functionref()> onIcepickSaveCallbacks
} file

void function IcepickSave( string saveName = "SaveGame" )
{
	ClearSaveBuffer();

	// Save the current map
	AddSaveItem( IcepickSaveOutput( "icepick.save-version", LATEST_ICEPICK_SAVE_VERSION ) );
	AddSaveItem( IcepickSaveOutput( "map", GetMapName() ) );

	// Save all props placed by players
	for( int i = 0; i < ToolgunData.SpawnedEntities.len(); ++i )
	{
		entity ent = ToolgunData.SpawnedEntities[i];
		string entry = IcepickSaveOutput( "prop", ent.GetModelName(), ent.GetOrigin().x, ent.GetOrigin().y, ent.GetOrigin().z, ent.GetAngles().x, ent.GetAngles().y, ent.GetAngles().z );
		AddSaveItem( entry );
	}

	// Save ziplines placed
	for( int i = 0; i < PlacedZiplines.len(); ++i )
	{
		vector start = PlacedZiplines[i].StartLocation;
		vector end = PlacedZiplines[i].EndLocation;
		string entry = IcepickSaveOutput( "zipline", start.x, start.y, start.z, end.x, end.y, end.z );
		AddSaveItem( entry );
	}

	// Write any custom data from mods
	foreach ( callbackFunc in file.onIcepickSaveCallbacks )
	{
		callbackFunc();
	}

	// Write the save to file
	string saveSuffix = "." + GetMapName() + ".txt";
	if( saveName.find( saveSuffix ) == null )
	{
		saveName += saveSuffix;
	}
	WriteSaveBufferToFile( saveName );
}

string function IcepickSaveOutput( ... )
{
	string out = "";
	for ( int i = 0; i < vargc; i++ )
	{
		out = out + (out == "" ? "" : ";") + string( vargv[ i ] );
	}
	return out;
}

void function AddOnIcepickSaveCallback( void functionref() callbackFunc )
{
	Assert( !file.onIcepickSaveCallbacks.contains( callbackFunc ), "Already added " + string( callbackFunc ) + " with AddOnIcepickSaveCallback" );
	file.onIcepickSaveCallbacks.append( callbackFunc );
}
