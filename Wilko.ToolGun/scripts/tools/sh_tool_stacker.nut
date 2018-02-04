
enum StackDirection
{
	Up,
	Down,
	Left,
	Right,
	Forward,
	Backward,
	MAX
}

table ToolStackProp = {};

void function Toolgun_RegisterTool_Stacker()
{
	// Register convars
	RegisterConVar( "stacker_dir", 0, "stacker_dir direction", "Set direction of the Stacker tool" );

	// Create the tool
	ToolStackProp.id <- "stack_prop";
	ToolStackProp.StackDir <- StackDirection.Up;

	ToolStackProp.GetName <- function()
	{
		string Direction = "None";
		int StackDirValue = floor( GetConVarValue( "stacker_dir", 0 ) ).tointeger();
		switch ( StackDirValue )
		{
			case StackDirection.Up:
				Direction = "Up";
				break;
			case StackDirection.Down:
				Direction = "Down";
				break;
			case StackDirection.Left:
				Direction = "Left";
				break;
			case StackDirection.Right:
				Direction = "Right";
				break;
			case StackDirection.Forward:
				Direction = "Forward";
				break;
			case StackDirection.Backward:
				Direction = "Backward";
				break;
		}

		return "Stacker - " + Direction;
	}

	ToolStackProp.GetHelp <- function()
	{
		return "Fire to duplicate a prop on its surface.\nTab to change stack direction.";
	}

	ToolStackProp.OnSelected <- function()
	{
	#if CLIENT
		RegisterButtonPressedCallback( KEY_TAB, ToolStackProp_ToggleStackSurface );
	#endif
	}

	ToolStackProp.OnDeselected <- function()
	{
	#if CLIENT
		DeregisterButtonPressedCallback( KEY_TAB, ToolStackProp_ToggleStackSurface );
	#endif
	}

	ToolStackProp.OnThink <- function()
	{
	#if SERVER
		entity player = GetPlayerByIndex( 0 );
	#endif
	}

	ToolStackProp.OnFire <- function()
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

			// Spawn duplicate prop
			entity prop_dynamic = CreateEntity( "prop_dynamic" );
			prop_dynamic.SetValueForModelKey( traceResults.hitEnt.GetModelName() );
			prop_dynamic.kv.fadedist = -1;
			prop_dynamic.kv.renderamt = 255;
			prop_dynamic.kv.rendercolor = "255 255 255";
			prop_dynamic.kv.solid = 6; // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
			SetTeam( prop_dynamic, TEAM_BOTH );	// need to have a team other then 0 or it won't take impact damage

			prop_dynamic.SetOrigin( traceResults.hitEnt.GetOrigin() );
			prop_dynamic.SetAngles( traceResults.hitEnt.GetAngles() );
			DispatchSpawn( prop_dynamic );

			// Register undo
			ToolgunData.SpawnedEntities.append( prop_dynamic );

			// Get stacking info
			int StackDirValue = floor( GetConVarValue( "stacker_dir", 0 ) ).tointeger();
			float StackDist = 0.0;
			vector BoundMins = prop_dynamic.GetBoundingMins();
			vector BoundMaxs = prop_dynamic.GetBoundingMaxs();
			switch ( StackDirValue )
			{
				case StackDirection.Up:
				case StackDirection.Down:
					StackDist = fabs( BoundMaxs.z - BoundMins.z );
					break;
				case StackDirection.Left:
				case StackDirection.Right:
					StackDist = fabs( BoundMaxs.y - BoundMins.y );
					break;
				case StackDirection.Forward:
				case StackDirection.Backward:
					StackDist = fabs( BoundMaxs.x - BoundMins.x );
					break;
			}

			vector StackDir = Vector( 0, 0, 0 );
			switch ( StackDirValue )
			{
				case StackDirection.Up:
					StackDir = prop_dynamic.GetUpVector();
					break;
				case StackDirection.Down:
					StackDir = prop_dynamic.GetUpVector() * -1;
					break;
				case StackDirection.Left:
					StackDir = prop_dynamic.GetRightVector() * -1;
					break;
				case StackDirection.Right:
					StackDir = prop_dynamic.GetRightVector();
					break;
				case StackDirection.Forward:
					StackDir = prop_dynamic.GetForwardVector();
					break;
				case StackDirection.Backward:
					StackDir = prop_dynamic.GetForwardVector() * -1;
					break;
			}

			// Move to stack position
			vector EntPos = traceResults.hitEnt.GetOrigin() + (StackDir * StackDist);
			prop_dynamic.SetOrigin( EntPos );
			
			return true;
		}
		return false;
	#else
		return false;
	#endif
	}

	// Register the tool
	ToolGunTools.append( ToolStackProp );
	
}

void function ToolStackProp_ToggleStackSurface( var button )
{
#if CLIENT
	float NewStackDir = floor( GetConVarValue( "stacker_dir", 0 ) ) + 1;
	if( NewStackDir >= StackDirection.MAX )
	{
		NewStackDir = 0;
	}
	SetConVarValue( "stacker_dir", NewStackDir );

	EmitSoundOnEntity( GetLocalClientPlayer(), "menu_click" );
#endif
}
