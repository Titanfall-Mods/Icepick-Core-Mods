untyped
global function Toolgun_RegisterTool_NudgeProp

table ToolNudgeProp = {};

void function Toolgun_RegisterTool_NudgeProp()
{
	// Register convars
	RegisterConVar( "nudge_distance", 1, "nudge_distance distance", "Set distance of the Nudge tool" );

	// Create the tool
	ToolNudgeProp.id <- "nudge_prop";
	ToolNudgeProp.NudgeDistances <- [ 1, 2, 5, 10 ];
	ToolNudgeProp.NudgeDistanceIdx <- 0;

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
		return "Fire to nudge a prop in the opposite direction.\nTab to change nudge size.";
	}

	ToolNudgeProp.OnSelected <- function()
	{
		#if CLIENT
		RegisterButtonPressedCallback( KEY_TAB, ToolNudgeProp_ToggleNudgeDistance );
		#endif
	}

	ToolNudgeProp.OnDeselected <- function()
	{
		#if CLIENT
		DeregisterButtonPressedCallback( KEY_TAB, ToolNudgeProp_ToggleNudgeDistance );
		#endif
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

void function ToolNudgeProp_ToggleNudgeDistance( var button )
{
#if CLIENT
	ToolNudgeProp.NudgeDistanceIdx += 1;
	if( ToolNudgeProp.NudgeDistanceIdx >= ToolNudgeProp.NudgeDistances.len() )
	{
		ToolNudgeProp.NudgeDistanceIdx = 0;
	}

	float NudgeDistance = float( ToolNudgeProp.NudgeDistances[ ToolNudgeProp.NudgeDistanceIdx ] );
	SetConVarValue( "nudge_distance", NudgeDistance );

	EmitSoundOnEntity( GetLocalClientPlayer(), "menu_click" );
#endif
}
