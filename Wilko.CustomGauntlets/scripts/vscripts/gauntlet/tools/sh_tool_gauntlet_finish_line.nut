
global function Toolgun_RegisterTool_GauntletPlaceFinish
#if SERVER
global function CustomGauntlet_CreateFinishLine
#endif
global function CustomGauntlet_FinishLine_Think

table ToolGauntletFinish = {};

void function Toolgun_RegisterTool_GauntletPlaceFinish()
{
	RegisterConVar( "gauntlet_finish_height", 100, "gauntlet_finish_height height", "Set the height for the gauntlet finish line" );
	AddOnToolOptionUpdateCallback( ToolGauntletFinish_UpdateToolOption );

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

	ToolGauntletFinish.RegisterOptions <- function()
	{
		#if CLIENT
		AddTextOption( "gauntlet_finish", "You can place the finish line for a gauntlet with this tool. Passing through the gate while Edit Mode is disabled will finish your gauntlet run." );
		AddTextOption( "gauntlet_finish", "Changing the Height will change how tall the gate is. You can move the anchors of the gate to change the width and orientation." );
		AddSliderOption( "gauntlet_finish", "gauntlet_finish_height", "Height", 100, 20, 1000 );
		#endif
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
			float TRIGGER_HEIGHT = GetConVarValue( "gauntlet_finish_height", 100.0 );
			
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

void function ToolGauntletFinish_UpdateToolOption( string id, var value )
{
#if CLIENT
	float newHeight = -1.0;
	switch( id )
	{
		case "gauntlet_finish_height":
			newHeight = expect float( value );
			break;
	}
	if( newHeight > 0 )
	{
		SetConVarValue( "gauntlet_finish_height", newHeight );
	}
#endif
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
	thread SendFinishLineToClient( finishLine );
}

void function SendFinishLineToClient( GauntletTriggerLine finishLine )
{
	wait 0.2;
	Remote_CallFunction_NonReplay( GetPlayerByIndex( 0 ), "ServerCallback_CustomGauntlet_SendStartFinishLine", 1, finishLine.left.GetEncodedEHandle(), finishLine.right.GetEncodedEHandle(), finishLine.triggerHeight );
}
#endif

void function CustomGauntlet_FinishLine_Think( GauntletTriggerLine finishLine )
{
	EndSignal( finishLine.left, "OnDestroy" );
	EndSignal( finishLine.right, "OnDestroy" );

	OnThreadEnd(
		function() : ( finishLine )
		{
			#if SERVER
			if( IsValid( finishLine.left ) )
			{
				finishLine.left.Destroy();
			}
			if( IsValid( finishLine.right ) )
			{
				finishLine.right.Destroy();
			}
			#endif

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
