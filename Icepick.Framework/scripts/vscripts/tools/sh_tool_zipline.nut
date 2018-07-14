untyped
global function Toolgun_RegisterTool_ZiplineSpawner

#if SERVER
global function ToolZipline_DestroyZipline
#endif

global struct PlacedZipline
{
	entity start,
	entity mid,
	entity end,

	entity AnchorStart,
	entity AnchorEnd,
	vector StartLocation,
	vector EndLocation
}

global array< PlacedZipline > PlacedZiplines;

const vector ZIPLINE_ANCHOR_OFFSET = Vector( 0.0, 0.0, 50.0 );
const int ZIPLINE_autoDetachDistance = 150;
const float ZIPLINE_MoveSpeedScale = 1.0;

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
		TraceResults traceResults = TraceLine( eyePosition, eyePosition + player.GetViewVector() * 10000, player, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER );

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

	thread ToolZipline_UpdateZiplines();
	#endif

}

#if SERVER
bool function ClientCommand_ToolZipline_AddZipline( entity player, array<string> args )
{
	vector StartPos = Vector( float(args[0]), float(args[1]), float(args[2]) );
	vector EndPos = Vector( float(args[3]), float(args[4]), float(args[5]) );

	entity AnchorStart = ToolZipline_CreateAnchorEntity( StartPos, Vector( 0, 0, 0 ), 0.0 );
	entity AnchorEnd = ToolZipline_CreateAnchorEntity( EndPos, Vector( 0, 0, 0 ), 0.0 );
	ZipLine z = CreateZipLine( StartPos + ZIPLINE_ANCHOR_OFFSET, EndPos + ZIPLINE_ANCHOR_OFFSET, ZIPLINE_autoDetachDistance, ZIPLINE_MoveSpeedScale );

	PlacedZipline NewZipline;
	NewZipline.StartLocation = StartPos;
	NewZipline.EndLocation = EndPos;
	NewZipline.AnchorStart = AnchorStart;
	NewZipline.AnchorEnd = AnchorEnd;
	NewZipline.start = z.start;
	NewZipline.mid = z.mid;
	NewZipline.end = z.end;
	PlacedZiplines.append( NewZipline );

	return true;
}

entity function ToolZipline_CreateAnchorEntity( vector Pos, vector Angles, float Offset )
{
	entity prop_dynamic = CreateEntity( "prop_dynamic" );
	prop_dynamic.SetValueForModelKey( $"models/weapons/titan_trip_wire/titan_trip_wire.mdl" );
	prop_dynamic.kv.fadedist = -1;
	prop_dynamic.kv.renderamt = 255;
	prop_dynamic.kv.rendercolor = "255 255 255";
	prop_dynamic.kv.solid = 6; // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
	SetTeam( prop_dynamic, TEAM_BOTH );	// need to have a team other then 0 or it won't take impact damage

	prop_dynamic.SetOrigin( Pos - AnglesToRight( Angles ) * Offset );
	prop_dynamic.SetAngles( Angles );
	DispatchSpawn( prop_dynamic );
	return prop_dynamic;
}

void function ToolZipline_UpdateZiplines()
{
	while( true )
	{
		for( int i = PlacedZiplines.len() - 1; i >= 0; --i )
		{
			PlacedZipline CurrentZipline = PlacedZiplines[i];
			if( !IsValid( CurrentZipline.AnchorStart ) || !IsValid( CurrentZipline.AnchorEnd ) )
			{
				ToolZipline_DestroyZipline( CurrentZipline, true );
				PlacedZiplines.remove( i );
			}
			else
			{
				if( CurrentZipline.AnchorStart.GetOrigin() != CurrentZipline.StartLocation || CurrentZipline.AnchorEnd.GetOrigin() != CurrentZipline.EndLocation )
				{
					ToolZipline_DestroyZipline( CurrentZipline );

					CurrentZipline.StartLocation = CurrentZipline.AnchorStart.GetOrigin();
					CurrentZipline.EndLocation = CurrentZipline.AnchorEnd.GetOrigin();

					ZipLine z = CreateZipLine( CurrentZipline.StartLocation + ZIPLINE_ANCHOR_OFFSET, CurrentZipline.EndLocation + ZIPLINE_ANCHOR_OFFSET, ZIPLINE_autoDetachDistance, ZIPLINE_MoveSpeedScale );
					CurrentZipline.start = z.start;
					CurrentZipline.mid = z.mid;
					CurrentZipline.end = z.end;
				}
			}
		}

		WaitFrame();
	}
}

void function ToolZipline_DestroyZipline( PlacedZipline zip, bool completeDestroy = false )
{
	if( IsValid( zip.start ) )
	{
		zip.start.Destroy();
	}
	if( IsValid( zip.mid ) )
	{
		zip.mid.Destroy();
	}
	if( IsValid( zip.end ) )
	{
		zip.end.Destroy();
	}
	if( completeDestroy )
	{
		if( IsValid( zip.AnchorStart ) )
		{
			zip.AnchorStart.Destroy();
		}
		if( IsValid( zip.AnchorEnd ) )
		{
			zip.AnchorEnd.Destroy();
		}
	}
}
#endif
