
global function Toolgun_RegisterTool_GauntletPlaceStart
#if SERVER
global function CustomGauntlet_CreateStartLine
#endif
global function CustomGauntlet_StartLine_Think

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
			const START_LINE_SPACING = 200.0;
			const TRIGGER_HEIGHT = 100.0;

			vector origin = traceResults.endPos;
			vector angles = Vector( 0, player.EyeAngles().y, 0 );

			vector left = origin + AnglesToRight( angles ) * START_LINE_SPACING * 0.5 * -1.0;
			vector right = origin + AnglesToRight( angles ) * START_LINE_SPACING * 0.5;

			CustomGauntlet_CreateStartLine( left, right, TRIGGER_HEIGHT );
		}

		return true;
	#else
		return false;
	#endif
	}

	// Register the tool
	ToolGunTools.append( ToolGauntletStart );

}

#if SERVER
void function CustomGauntlet_CreateStartLine( vector leftOrigin, vector rightOrigin, float height )
{
	entity left = CreateSmallAnchorEntity( leftOrigin, < 0, 0, 0 > );
	entity right = CreateSmallAnchorEntity( rightOrigin, < 0, 0, 0 > );
	vector heightOffset = < 0, 0, height >;

	array<entity> lowerRopes = CustomGauntletCreateRope( left.GetOrigin(), right.GetOrigin() );
	lowerRopes[0].SetParent( left );
	lowerRopes[1].SetParent( right );

	array<entity> upperRopes = CustomGauntletCreateRope( left.GetOrigin() + heightOffset, right.GetOrigin() + heightOffset );
	upperRopes[0].SetParent( left );
	upperRopes[1].SetParent( right );

	array<entity> leftRopes = CustomGauntletCreateRope( left.GetOrigin(), left.GetOrigin() + heightOffset );
	leftRopes[0].SetParent( left );
	leftRopes[1].SetParent( left );

	array<entity> rightRopes = CustomGauntletCreateRope( right.GetOrigin(), right.GetOrigin() + heightOffset );
	rightRopes[0].SetParent( right );
	rightRopes[1].SetParent( right );

	GauntletTriggerLine startLine;
	startLine.left = left;
	startLine.right = right;
	startLine.triggerHeight = height;
	CustomGauntletsGlobal.DevelopmentTrack.Starts.append( startLine );

	thread CustomGauntlet_StartLine_Think( startLine );
	thread SendStartLineToClient( startLine );
}

void function SendStartLineToClient( GauntletTriggerLine startLine )
{
	wait 0.2;
	Remote_CallFunction_NonReplay( GetPlayerByIndex( 0 ), "ServerCallback_CustomGauntlet_SendStartFinishLine", 0, startLine.left.GetEncodedEHandle(), startLine.right.GetEncodedEHandle(), startLine.triggerHeight );
}
#endif

void function CustomGauntlet_StartLine_Think( GauntletTriggerLine startLine )
{
	EndSignal( startLine.left, "OnDestroy" );
	EndSignal( startLine.right, "OnDestroy" );

	OnThreadEnd(
		function() : ( startLine )
		{
			#if SERVER
			if( IsValid( startLine.left ) )
			{
				startLine.left.Destroy();
			}
			if( IsValid( startLine.right ) )
			{
				startLine.right.Destroy();
			}
			#endif

			for( int i = CustomGauntletsGlobal.DevelopmentTrack.Starts.len() - 1; i >= 0; --i )
			{
				if( startLine == CustomGauntletsGlobal.DevelopmentTrack.Starts[i] )
				{
					CustomGauntletsGlobal.DevelopmentTrack.Starts.remove( i );
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
