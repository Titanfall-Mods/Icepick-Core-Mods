
global function CustomGauntlet_GetConvertOneToTwo

const float DEFAULT_TRIGGER_HEIGHT = 100.0;

table< string, array<string> functionref( array<string> ) > function CustomGauntlet_GetConvertOneToTwo()
{
	table< string, array<string> functionref( array<string> ) > conversionFuncs = {};

	conversionFuncs["gauntlet.start"] <- array<string> function( array<string> data )
	{
		array<string> newData;
		newData.append( data[0] + "|" + data[1] + "|" + data[2] );
		newData.append( data[3] + "|" + data[4] + "|" + data[5] );
		newData.append( DEFAULT_TRIGGER_HEIGHT.tostring() );
		return newData;
	}

	conversionFuncs["gauntlet.end"] <- array<string> function( array<string> data )
	{
		array<string> newData;
		newData.append( data[0] + "|" + data[1] + "|" + data[2] );
		newData.append( data[3] + "|" + data[4] + "|" + data[5] );
		newData.append( DEFAULT_TRIGGER_HEIGHT.tostring() );
		return newData;
	}

	return conversionFuncs;
}
