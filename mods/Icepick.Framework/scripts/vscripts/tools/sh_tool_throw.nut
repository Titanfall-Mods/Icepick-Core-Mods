untyped

global function Toolgun_RegisterTool_TitanThrow

table ToolTitanThrow = {};

void function Toolgun_RegisterTool_TitanThrow()
{
	// Create the tool
	ToolTitanThrow.id <- "titan_thrower";
	ToolTitanThrow.titanEntity <- null;
	ToolTitanThrow.targetEntity <- null;

	ToolTitanThrow.GetName <- function()
	{
		return "Titan Throw";
	}

	ToolTitanThrow.GetHelp <- function()
	{
		return "Fire to select throw target.";
	}

	ToolTitanThrow.OnSelected <- function()
	{
	}

	ToolTitanThrow.OnDeselected <- function()
	{
	}

	ToolTitanThrow.Reset <- function()
	{
	}

	ToolTitanThrow.OnFire <- function()
	{
	#if SERVER
		entity player = GetPlayerByIndex( 0 );
		Toolgun_Utils_FireToolTracer( player );

		vector eyePosition = player.EyePosition();
		vector viewVector = player.GetViewVector();
		TraceResults traceResults = TraceLine( eyePosition, eyePosition + viewVector * 10000, player, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER );

		entity titanEntity = null;
		entity targetEntity = null;

		titanEntity = CreateInfoTarget( player.GetOrigin(), player.GetAngles() );
		targetEntity = CreateInfoTarget( traceResults.endPos );

		thread DoThrowThread( titanEntity, targetEntity )
	#endif
		return true;
	}

	// Register the tool
	ToolGunTools.append( ToolTitanThrow );
}

#if SERVER

void function DoThrowThread( entity titanNode, entity targetNode )
{
	entity player = GetPlayerByIndex( 0 );
	Embark_Disallow( player )

	// Wait for BT to exist since we may be disembarking
	entity bt = player.GetPetTitan()
	while ( !IsValid( bt ) )
	{
		bt = player.GetPetTitan()
		WaitFrame()
	}

	// after done, don't go back to start point, facing away from player
	bt.AssaultSetGoalRadius( 1024 )

	// waitthread RunToAndPlayAnim( bt, "bt_beacon_fastball_throw_start", titanNode, false )
	// WaittillAnimDone( bt )

	titanNode = CreateInfoTarget( bt.GetOrigin(), player.GetAngles() );
	// PlayBTDialogue( "BT_Nag_ClimbIntoMyHand" )

	// BT Gets ready to throw the player
	SetFastballAnims( "", "bt_beacon_fastball_throw_idle", "bt_beacon_fastball_throw_end", "ptpov_beacon_fastball_throw_end", "pt_beacon_fastball_throw_end" )
	thread ScriptedTitanFastball( player, bt, titanNode, targetNode )

	WaitSignal( bt, "fastball_release" )
	Embark_Allow( player )
}

#endif
