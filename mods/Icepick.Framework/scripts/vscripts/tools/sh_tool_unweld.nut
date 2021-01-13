untyped

global function Toolgun_RegisterTool_Unwelder

table ToolUnwelder = {};

void function Toolgun_RegisterTool_Unwelder()
{
	// Create the tool
	ToolUnwelder.id <- "unwelder";

	ToolUnwelder.GetName <- function()
	{
		return "Unwelder";
	}

	ToolUnwelder.GetHelp <- function()
	{
		return "Fire to unweld a prop from its parent.";
	}

	ToolUnwelder.OnFire <- function()
	{
	#if SERVER
		entity player = GetPlayerByIndex( 0 );
		Toolgun_Utils_FireToolTracer( player );

		vector eyePosition = player.EyePosition();
		vector viewVector = player.GetViewVector();
		TraceResults traceResults = TraceLine( eyePosition, eyePosition + viewVector * 10000, player, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER );
		if( traceResults.hitEnt != null )
		{
			traceResults.hitEnt.ClearParent();
		}
	#endif

		return true;
	}

	// Register the tool
	ToolGunTools.append( ToolUnwelder );
}
