
table ToolPropInfo = {};

void function Toolgun_RegisterTool_PropInfo()
{
	// Create the tool
	ToolPropInfo.id <- "prop_info";

	ToolPropInfo.GetName <- function()
	{
		return "Prop Info";
	}

	ToolPropInfo.GetHelp <- function()
	{
		return "Fire to print info on a prop to the console.";
	}

	ToolPropInfo.OnSelected <- function()
	{
	}

	ToolPropInfo.OnDeselected <- function()
	{
	}

	ToolPropInfo.OnFire <- function()
	{
	#if SERVER
		entity player = GetPlayerByIndex( 0 );
		Toolgun_Utils_FireToolTracer( player );
		return false;
	#else
		entity player = GetLocalClientPlayer();
		vector eyePosition = player.EyePosition()
		vector viewVector = player.GetViewVector()
		TraceResults traceResults = TraceLineHighDetail( eyePosition, eyePosition + viewVector * 10000, player, TRACE_MASK_PLAYERSOLID | TRACE_MASK_TITANSOLID | TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_NONE )
		if( traceResults.hitEnt )
		{
			AddPlayerHint( 2.0, 0.25, $"", "Output " + traceResults.hitEnt.GetModelName() + " to console" )
			printc( "Model: ", traceResults.hitEnt.GetModelName(), "\n", "Class: ", traceResults.hitEnt.GetClassName() )
			return true
		}
		return false
	#endif
	}

	// Register the tool
	ToolGunTools.append( ToolPropInfo );

}
