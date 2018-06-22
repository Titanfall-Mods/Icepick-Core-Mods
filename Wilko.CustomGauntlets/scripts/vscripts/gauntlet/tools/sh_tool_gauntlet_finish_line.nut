
global function Toolgun_RegisterTool_GauntletPlaceFinish

table ToolGauntletFinish = {};

void function Toolgun_RegisterTool_GauntletPlaceFinish()
{

	// Create the tool
	ToolGauntletFinish.id <- "gauntlet_finish";

	ToolGauntletFinish.GetName <- function()
	{
		return "Gauntlet Finish Line";
	}

	ToolGauntletFinish.GetHelp <- function()
	{
		return "Fire to place the finish line for a gauntlet track.";
	}

	ToolGauntletFinish.OnFire <- function()
	{
	#if SERVER
		entity player = GetPlayerByIndex( 0 );
		Toolgun_Utils_FireToolTracer( player );

		vector eyePosition = player.EyePosition();
		vector viewVector = player.GetViewVector();
		TraceResults traceResults = TraceLineHighDetail( eyePosition, eyePosition + viewVector * 10000, player, TRACE_MASK_PLAYERSOLID | TRACE_MASK_TITANSOLID | TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_NONE );
		if( traceResults.hitEnt )
		{
			vector Pos = traceResults.endPos;
			vector Angles = Vector(0, player.EyeAngles().y, 0);

			if( CustomGauntlet_HasFinishLineEntities( CustomGauntletsGlobal.DevelopmentTrack ) )
			{
				Remote_CallFunction_NonReplay( GetPlayerByIndex( 0 ), "ServerCallback_CustomGauntlet_ShowError", 2 );
			}
			else
			{
				CustomGauntletsGlobal.DevelopmentTrack.FinishLine.FromEnt = ToolGauntlet_CreateTriggerEntity( Pos, Angles, 100.0 );
				CustomGauntletsGlobal.DevelopmentTrack.FinishLine.ToEnt = ToolGauntlet_CreateTriggerEntity( Pos, Angles, -100.0 );
			}
		}

		return true;
	#else
		return false;
	#endif
	}

	// Register the tool
	ToolGunTools.append( ToolGauntletFinish );

}
