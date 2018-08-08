
table ToolGauntletCheckpoint = {};

void function Toolgun_RegisterTool_GauntletPlaceCheckpoint()
{

	// Create the tool
	ToolGauntletCheckpoint.id <- "gauntlet_checkpoint";

	ToolGauntletCheckpoint.GetName <- function()
	{
		return "Gauntlet Start Line";
	}

	ToolGauntletCheckpoint.GetHelp <- function()
	{
		return "Fire to place a checkpoint for a gauntlet track.";
	}

	ToolGauntletCheckpoint.OnFire <- function()
	{
	#if SERVER
		entity player = GetPlayerByIndex( 0 );
		Toolgun_Utils_FireToolTracer( player );

		vector eyePosition = player.EyePosition();
		vector viewVector = player.GetViewVector();
		TraceResults traceResults = TraceLineHighDetail( eyePosition, eyePosition + viewVector * 10000, player, TRACE_MASK_PLAYERSOLID | TRACE_MASK_TITANSOLID | TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_NONE );
		if( traceResults.hitEnt )
		{
			vector Angles = Vector(0, player.EyeAngles().y, 0);
			// ToolGauntletPlaceTrigger_CreateTriggerEnts( traceResults.endPos, Angles );
		}

		return true;
	#else
		return false;
	#endif
	}

	// Register the tool
	ToolGunTools.append( ToolGauntletCheckpoint );

}
