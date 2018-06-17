untyped
global function Toolgun_RegisterTool_NudgeProp

table ToolNudgeProp = {};

void function Toolgun_RegisterTool_NudgeProp()
{
	// Register convars
	RegisterConVar( "nudge_distance", 1, "nudge_distance distance", "Set distance of the Nudge tool" );
	AddOnToolOptionUpdateCallback( ToolNudgeProp_UpdateToolOption );

	// Create the tool
	ToolNudgeProp.id <- "nudge_prop";
	ToolNudgeProp.NudgeDistances <- [ 1, 2, 5, 10 ];
	ToolNudgeProp.NudgeDistanceIdx <- 0;

	ToolNudgeProp.Options <- [
		[ 2, "nudge_distance", "Distance", 5, 1, 100 ]
	];

	ToolNudgeProp.GetName <- function()
	{
		return "Nudger - " + GetConVarValue( "nudge_distance", 1 ) + " units";
	}

	ToolNudgeProp.GetRawName <- function()
	{
		return "Nudger";
	}

	ToolNudgeProp.GetHelp <- function()
	{
		return "Fire to nudge a prop in the opposite direction.";
	}

	ToolNudgeProp.OnFire <- function()
	{
	#if SERVER
		entity player = GetPlayerByIndex( 0 );
		vector eyePosition = player.EyePosition()
		vector viewVector = player.GetViewVector()
		TraceResults traceResults = TraceLine( eyePosition, eyePosition + viewVector * 10000, player, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )

		if( traceResults.hitEnt )
		{
			Toolgun_Utils_FireToolTracer( player );
			
			if( traceResults.hitEnt.GetClassName() == "worldspawn" )
			{
				return false;
			}

			traceResults.hitEnt.SetOrigin( traceResults.hitEnt.GetOrigin() + (traceResults.surfaceNormal * GetConVarValue( "nudge_distance", 1 ) * -1) );
			
			return true;
		}
		return false;
	#else
		return false;
	#endif
	}

	// Register the tool
	ToolGunTools.append( ToolNudgeProp );
}

void function ToolNudgeProp_UpdateToolOption( string id, var value )
{
#if CLIENT
	if( id == "nudge_distance" )
	{
		SetConVarValue( "nudge_distance", float(value) );
	}
#endif
}
