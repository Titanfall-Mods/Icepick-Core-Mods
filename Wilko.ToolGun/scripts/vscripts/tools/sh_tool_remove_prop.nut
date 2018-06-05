untyped
global function Toolgun_RegisterTool_RemoveProp

table ToolRemoveProp = {};

void function Toolgun_RegisterTool_RemoveProp()
{
	// Create the tool
	ToolRemoveProp.id <- "remove_prop";

	ToolRemoveProp.GetName <- function()
	{
		return "Remover";
	}

	ToolRemoveProp.GetHelp <- function()
	{
		return "Fire to remove a prop.";
	}

	ToolRemoveProp.OnSelected <- function()
	{
	}

	ToolRemoveProp.OnDeselected <- function()
	{
	}

	ToolRemoveProp.OnFire <- function()
	{
	#if SERVER
		entity player = GetPlayerByIndex( 0 );
		vector eyePosition = player.EyePosition()
		vector viewVector = player.GetViewVector()
		TraceResults traceResults = TraceLine( eyePosition, eyePosition + viewVector * 10000, player, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )

		if( traceResults.hitEnt )
		{
			Toolgun_Utils_FireToolTracer( player );
			
			if( traceResults.hitEnt.GetClassName() == "worldspawn" )
			{
				return false;
			}

			for( int i = 0; i < ToolgunData.SpawnedEntities.len(); ++i )
			{
				if( ToolgunData.SpawnedEntities[i] == traceResults.hitEnt )
				{
					ToolgunData.SpawnedEntities.remove( i );
					break;
				}
			}
			traceResults.hitEnt.Destroy();
			
			return true
		}
		return false
	#else
		return false
	#endif
	}

	// Register the tool
	ToolGunTools.append( ToolRemoveProp );

}
