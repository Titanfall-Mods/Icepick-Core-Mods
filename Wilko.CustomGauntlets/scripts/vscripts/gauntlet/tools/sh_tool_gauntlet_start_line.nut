
global function Toolgun_RegisterTool_GauntletPlaceStart

table ToolGauntletStart = {};

void function Toolgun_RegisterTool_GauntletPlaceStart()
{

	// Create the tool
	ToolGauntletStart.id <- "gauntlet_start";

	ToolGauntletStart.GetName <- function()
	{
		return "Gauntlet Start Line";
	}

	ToolGauntletStart.GetHelp <- function()
	{
		return "Fire to place the start line for a gauntlet track.";
	}

	ToolGauntletStart.OnFire <- function()
	{
	#if SERVER
		entity player = GetPlayerByIndex( 0 );
		Toolgun_Utils_FireToolTracer( player );

		vector eyePosition = player.EyePosition();
		vector viewVector = player.GetViewVector();
		TraceResults traceResults = TraceLineHighDetail( eyePosition, eyePosition + viewVector * 10000, player, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER );
		if( traceResults.hitEnt )
		{
			vector Pos = traceResults.endPos;
			vector Angles = Vector(0, player.EyeAngles().y, 0);
			
			if( CustomGauntlet_HasStartLineEntities( CustomGauntletsGlobal.DevelopmentTrack ) )
			{
				Remote_CallFunction_NonReplay( GetPlayerByIndex( 0 ), "ServerCallback_CustomGauntlet_ShowError", 1 );
			}
			else
			{
				CustomGauntletsGlobal.DevelopmentTrack.StartLine.FromEnt = ToolGauntlet_CreateTriggerEntity( Pos, Angles, 100.0 );
				CustomGauntletsGlobal.DevelopmentTrack.StartLine.ToEnt = ToolGauntlet_CreateTriggerEntity( Pos, Angles, -100.0 );
			}
		}

		return true;
	#else
		return false;
	#endif
	}

	// Register the tool
	ToolGunTools.append( ToolGauntletStart );

}
