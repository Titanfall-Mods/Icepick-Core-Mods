
global function Toolgun_RegisterTool_GauntletPlaceLeaderboard

table ToolGauntletLeaderboard = {};

void function Toolgun_RegisterTool_GauntletPlaceLeaderboard()
{

	// Create the tool
	ToolGauntletLeaderboard.id <- "gauntlet_leaderboard";

	ToolGauntletLeaderboard.GetName <- function()
	{
		return "Gauntlet Leaderboard";
	}

	ToolGauntletLeaderboard.GetHelp <- function()
	{
		return "Fire to place a leaderboard for a gauntlet track.";
	}

	ToolGauntletLeaderboard.OnFire <- function()
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
			
			entity ScoreboardEnt = ToolGauntlet_CreateTriggerEntity( Pos, Angles, 0.0 );

			GauntletWorldUI NewScoreboard;
			NewScoreboard.UIType = GauntletWorldUIType.Scoreboard;
			NewScoreboard.Position = Pos;
			NewScoreboard.Rotation = Angles;
			NewScoreboard.ReferenceEnt = ScoreboardEnt;
			CustomGauntletsGlobal.DevelopmentTrack.Scoreboards.append( NewScoreboard );

			thread ToolGauntlet_DelayedTransmit( "ServerCallback_CustomGauntlet_SendScoreboardEnt", ScoreboardEnt );
		}

		return true;
	#else
		return false;
	#endif
	}

	// Register the tool
	ToolGunTools.append( ToolGauntletLeaderboard );

}
