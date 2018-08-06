
global function Toolgun_RegisterTool_GauntletPlaceFinish
#if SERVER
global function CustomGauntlet_CreateFinishLine
#endif

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
		TraceResults traceResults = TraceLineHighDetail( eyePosition, eyePosition + viewVector * 10000, player, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER );
		if( traceResults.hitEnt )
		{
			const START_LINE_SPACING = 200.0;
			const TRIGGER_HEIGHT = 100.0;
			
			vector origin = traceResults.endPos;
			vector angles = Vector( 0, player.EyeAngles().y, 0 );

			vector left = origin + AnglesToRight( angles ) * START_LINE_SPACING * 0.5 * -1.0;
			vector right = origin + AnglesToRight( angles ) * START_LINE_SPACING * 0.5;

			CustomGauntlet_CreateFinishLine( left, right, TRIGGER_HEIGHT );
		}

		return true;
	#else
		return false;
	#endif
	}

	// Register the tool
	ToolGunTools.append( ToolGauntletFinish );

}

#if SERVER
void function CustomGauntlet_CreateFinishLine( vector leftOrigin, vector rightOrigin, float height )
{
	entity left = CreateSmallAnchorEntity( leftOrigin, < 0, 0, 0 > );
	entity right = CreateSmallAnchorEntity( rightOrigin, < 0, 0, 0 > );
	vector heightOffset = < 0, 0, height >;
	string cable = "cable/tether.vmt";

	array<entity> lowerRopes = CustomGauntletCreateRope( left.GetOrigin(), right.GetOrigin(), cable );
	lowerRopes[0].SetParent( left );
	lowerRopes[1].SetParent( right );

	array<entity> upperRopes = CustomGauntletCreateRope( left.GetOrigin() + heightOffset, right.GetOrigin() + heightOffset, cable );
	upperRopes[0].SetParent( left );
	upperRopes[1].SetParent( right );

	array<entity> leftRopes = CustomGauntletCreateRope( left.GetOrigin(), left.GetOrigin() + heightOffset, cable );
	leftRopes[0].SetParent( left );
	leftRopes[1].SetParent( left );

	array<entity> rightRopes = CustomGauntletCreateRope( right.GetOrigin(), right.GetOrigin() + heightOffset, cable );
	rightRopes[0].SetParent( right );
	rightRopes[1].SetParent( right );

	GauntletTriggerLine finishLine;
	finishLine.left = left;
	finishLine.right = right;
	finishLine.triggerHeight = height;
	CustomGauntletsGlobal.DevelopmentTrack.Finishes.append( finishLine );

	thread CustomGauntlet_FinishLine_Think( finishLine );
}

void function CustomGauntlet_FinishLine_Think( GauntletTriggerLine finishLine )
{
	EndSignal( finishLine.left, "OnDestroy" );
	EndSignal( finishLine.right, "OnDestroy" );

	OnThreadEnd(
		function() : ( finishLine )
		{
			if( IsValid( finishLine.left ) )
			{
				finishLine.left.Destroy();
			}
			if( IsValid( finishLine.right ) )
			{
				finishLine.right.Destroy();
			}

			for( int i = CustomGauntletsGlobal.DevelopmentTrack.Finishes.len() - 1; i >= 0; --i )
			{
				if( finishLine == CustomGauntletsGlobal.DevelopmentTrack.Finishes[i] )
				{
					CustomGauntletsGlobal.DevelopmentTrack.Finishes.remove( i );
					break;
				}
			}
		}
	)

	while( true )
	{
		wait 1.0;
	}
}
#endif
