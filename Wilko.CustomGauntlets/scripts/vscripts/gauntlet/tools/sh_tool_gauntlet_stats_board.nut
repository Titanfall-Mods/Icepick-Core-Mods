
global function Toolgun_RegisterTool_GauntletPlaceStats

table ToolGauntletStats = {};

void function Toolgun_RegisterTool_GauntletPlaceStats()
{

	// Create the tool
	ToolGauntletStats.id <- "gauntlet_stats";

	ToolGauntletStats.GetName <- function()
	{
		return "Gauntlet Results";
	}

	ToolGauntletStats.GetHelp <- function()
	{
		return "Fire to place a results board for a gauntlet track.";
	}

	ToolGauntletStats.OnFire <- function()
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
			
			entity StatsEnt = ToolGauntlet_CreateTriggerEntity( Pos, Angles, 0.0 );

			GauntletWorldUI NewStatsBoard;
			NewStatsBoard.UIType = GauntletWorldUIType.StatsBoard;
			NewStatsBoard.Position = Pos;
			NewStatsBoard.Rotation = Angles;
			NewStatsBoard.ReferenceEnt = StatsEnt;
			CustomGauntletsGlobal.DevelopmentTrack.Scoreboards.append( NewStatsBoard );

			thread ToolGauntlet_DelayedTransmit( "ServerCallback_CustomGauntlet_SendStatsBoardEnt", StatsEnt );
		}

		return true;
	#else
		return false;
	#endif
	}

	// Register the tool
	ToolGunTools.append( ToolGauntletStats );

}
