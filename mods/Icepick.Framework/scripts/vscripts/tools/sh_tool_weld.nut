untyped

global function Toolgun_RegisterTool_Welder

table ToolWelder = {};

void function Toolgun_RegisterTool_Welder()
{
	// Create the tool
	ToolWelder.id <- "welder";
	ToolWelder.targetEntity <- null;
	ToolWelder.parentEntity <- null;

	ToolWelder.GetName <- function()
	{
		return "Welder";
	}

	ToolWelder.GetHelp <- function()
	{
		if( !IsValid( ToolWelder.targetEntity ) )
		{
			return "Fire to select a prop to weld.";
		}
		else
		{
			return "Fire to select what prop to weld it to.";
		}
	}

	ToolWelder.OnSelected <- function()
	{
		ToolWelder.Reset();
	}

	ToolWelder.OnDeselected <- function()
	{
		ToolWelder.Reset();
	}

	ToolWelder.Reset <- function()
	{
		ToolWelder.targetEntity = null;
		ToolWelder.parentEntity = null;
	}

	ToolWelder.OnFire <- function()
	{
	#if SERVER
		entity player = GetPlayerByIndex( 0 );
		Toolgun_Utils_FireToolTracer( player );
	#else
		entity player = GetLocalClientPlayer();
	#endif

		vector eyePosition = player.EyePosition();
		vector viewVector = player.GetViewVector();
		TraceResults traceResults = TraceLine( eyePosition, eyePosition + viewVector * 10000, player, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER );
		if( traceResults.hitEnt != null )
		{
			if( !IsValid( ToolWelder.targetEntity ) )
			{
				ToolWelder.targetEntity = traceResults.hitEnt;
			}
			else
			{
				ToolWelder.parentEntity = traceResults.hitEnt;
				WeldProps( expect entity( ToolWelder.targetEntity ), expect entity( ToolWelder.parentEntity ) );
			}
		}

		return true;
	}

	// Register the tool
	ToolGunTools.append( ToolWelder );
}

void function WeldProps( entity a, entity b )
{
#if SERVER
	a.SetParent( b );
#endif
	ToolWelder.Reset();
}
