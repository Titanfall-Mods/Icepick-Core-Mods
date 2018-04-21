
table ToolZipline = {};

void function Toolgun_RegisterTool_ZiplineSpawner()
{
	// Create the tool
	ToolZipline.id <- "zipline_spawner";
	ToolZipline.StartLocationSet <- false;
	ToolZipline.StartLocation <- Vector( 0, 0, 0 );
	ToolZipline.EndLocation <- Vector( 0, 0, 0 );

	ToolZipline.GetName <- function()
	{
		return "Zipline";
	}

	ToolZipline.GetHelp <- function()
	{
		if( !ToolZipline.StartLocationSet )
		{
			return "Fire to place the start point of a zipline.";
		}
		else
		{
			return "Fire to place the end point of the zipline.";
		}
	}

	ToolZipline.OnSelected <- function()
	{
		ToolZipline.Reset();
	}

	ToolZipline.OnDeselected <- function()
	{
		ToolZipline.Reset();
	}

	ToolZipline.Reset <- function()
	{
		ToolZipline.StartLocationSet = false;
		ToolZipline.StartLocation = Vector( 0, 0, 0 );
		ToolZipline.EndLocation = Vector( 0, 0, 0 );
	}

	ToolZipline.OnFire <- function()
	{
	#if SERVER
		entity player = GetPlayerByIndex( 0 );
		Toolgun_Utils_FireToolTracer( player );
		return false;
	#else
		// Perform a trace
		entity player = GetLocalClientPlayer();
		vector eyePosition = player.EyePosition();
		vector viewVector = player.GetViewVector();
		TraceResults traceResults = TraceLine( eyePosition, eyePosition + viewVector * 10000, player, TRACE_MASK_PLAYERSOLID | TRACE_MASK_TITANSOLID | TRACE_MASK_NPCWORLDSTATIC | TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE );

		// Check which location we're setting
		if( ToolZipline.StartLocationSet )
		{
			ToolZipline.EndLocation = traceResults.endPos;

			// Send to server
			string StartStr = ToolZipline.StartLocation.x + " " + ToolZipline.StartLocation.y + " " + ToolZipline.StartLocation.z;
			string EndStr = ToolZipline.EndLocation.x + " " + ToolZipline.EndLocation.y + " " + ToolZipline.EndLocation.z;
			player.ClientCommand( "ToolZipline_AddZipline " + StartStr + " " + EndStr );

			ToolZipline.Reset();
		}
		else
		{
			ToolZipline.StartLocation = traceResults.endPos;
			ToolZipline.StartLocationSet = true;
		}

		return true;
	#endif
	}

	// Register the tool
	ToolGunTools.append( ToolZipline );

	#if SERVER
	AddClientCommandCallback( "ToolZipline_AddZipline", ClientCommand_ToolZipline_AddZipline );
	#endif

}

#if SERVER
bool function ClientCommand_ToolZipline_AddZipline( entity player, array<string> args )
{
	vector StartPos = Vector( float(args[0]), float(args[1]), float(args[2]) );
	vector EndPos = Vector( float(args[3]), float(args[4]), float(args[5]) );

	print("Zipline from " + StartPos + " to " + EndPos);

	ZipLine z = CreateZipLine( StartPos, EndPos, 150, 1.0 );

	return true;
}
#endif
