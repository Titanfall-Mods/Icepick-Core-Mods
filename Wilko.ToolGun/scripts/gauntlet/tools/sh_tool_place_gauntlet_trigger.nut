
enum GauntletTriggerPlacement
{
	StartLine,
	FinishLine,
	Checkpoint,
	MAX
}

table ToolGauntletTrigger = {};

void function Toolgun_RegisterTool_GauntletPlaceTrigger()
{
	// Create convars
	RegisterConVar( "gauntlet_trigger_mode", 0, "gauntlet_trigger_mode mode_idx", "Set the mode used on the Gauntlet Trigger tool" );

	// Create the tool
	ToolGauntletTrigger.id <- "gauntlet_trigger";

	ToolGauntletTrigger.GetName <- function()
	{
		string Name = "[Invalid]";
		int PlacementModeValue = floor( GetConVarValue( "gauntlet_trigger_mode", 0 ) ).tointeger();
		switch ( PlacementModeValue )
		{
			case GauntletTriggerPlacement.StartLine:
				Name = "Start Line";
				break;
			case GauntletTriggerPlacement.FinishLine:
				Name = "Finish Line";
				break;
			case GauntletTriggerPlacement.Checkpoint:
				Name = "Checkpoint";
				break;
		}
		return "Gauntlet " + Name;
	}

	ToolGauntletTrigger.GetRawName <- function()
	{
		return "Gauntlet Trigger";
	}

	ToolGauntletTrigger.GetHelp <- function()
	{
		return "Fire to create a gauntlet trigger.\nTab to change the trigger type.";
	}

	ToolGauntletTrigger.OnSelected <- function()
	{
	#if CLIENT
		RegisterButtonPressedCallback( KEY_TAB, ToolGauntletPlaceTrigger_ToggleMode );
	#endif
	}

	ToolGauntletTrigger.OnDeselected <- function()
	{
	#if CLIENT
		DeregisterButtonPressedCallback( KEY_TAB, ToolGauntletPlaceTrigger_ToggleMode );
	#endif
	}

	ToolGauntletTrigger.OnFire <- function()
	{
	#if SERVER
		entity player = GetPlayerByIndex( 0 );
		Toolgun_Utils_FireToolTracer( player );

		vector eyePosition = player.EyePosition();
		vector viewVector = player.GetViewVector();
		TraceResults traceResults = TraceLineHighDetail( eyePosition, eyePosition + viewVector * 10000, player, TRACE_MASK_PLAYERSOLID | TRACE_MASK_TITANSOLID | TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_NONE );
		if( traceResults.hitEnt )
		{
			vector Angles = Vector(0, player.EyeAngles().y, 0);
			ToolGauntletPlaceTrigger_CreateTriggerEnts( traceResults.endPos, Angles );
		}

		return true;
	#else
		return false;
	#endif
	}

	// Register the tool
	ToolGunTools.append( ToolGauntletTrigger );
	
}

void function ToolGauntletPlaceTrigger_ToggleMode( var button )
{
#if CLIENT
	float NewModeValue = floor( GetConVarValue( "gauntlet_trigger_mode", 0 ) ) + 1;
	if( NewModeValue >= GauntletTriggerPlacement.MAX )
	{
		NewModeValue = 0;
	}
	SetConVarValue( "gauntlet_trigger_mode", NewModeValue );

	EmitSoundOnEntity( GetLocalClientPlayer(), "menu_click" );
#endif
}

void function ToolGauntletPlaceTrigger_CreateTriggerEnts( vector Pos, vector Angles )
{
#if SERVER
	int PlacementModeValue = floor( GetConVarValue( "gauntlet_trigger_mode", 0 ) ).tointeger();
	switch ( PlacementModeValue )
	{
		case GauntletTriggerPlacement.StartLine:
			ToolGauntletPlaceTrigger_SetupStartLine( Pos, Angles );
			break;
		case GauntletTriggerPlacement.FinishLine:
			ToolGauntletPlaceTrigger_SetupFinishLine( Pos, Angles );
			break;
		case GauntletTriggerPlacement.Checkpoint:
			ToolGauntletPlaceTrigger_SetupCheckpointLine( Pos, Angles );
			break;
	}
#endif
}

entity function ToolGauntletPlaceTrigger_CreateTriggerEntity( vector Pos, vector Angles, float Offset )
{
#if SERVER
	entity prop_dynamic = CreateEntity( "prop_dynamic" );
	prop_dynamic.SetValueForModelKey( $"models/weapons/titan_trip_wire/titan_trip_wire.mdl" );
	prop_dynamic.kv.fadedist = -1;
	prop_dynamic.kv.renderamt = 255;
	prop_dynamic.kv.rendercolor = "255 255 255";
	prop_dynamic.kv.solid = 6; // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
	SetTeam( prop_dynamic, TEAM_BOTH );	// need to have a team other then 0 or it won't take impact damage

	prop_dynamic.SetOrigin( Pos - AnglesToRight( Angles ) * Offset );
	prop_dynamic.SetAngles( Angles );
	DispatchSpawn( prop_dynamic );
	return prop_dynamic;
#endif
#if CLIENT
	return null;
#endif
}

void function ToolGauntletPlaceTrigger_SetupStartLine( vector Pos, vector Angles )
{
#if SERVER
	if( CustomGauntlet_HasStartLineEntities( CustomGauntletsGlobal.DevelopmentTrack ) )
	{
		Remote_CallFunction_NonReplay( GetPlayerByIndex( 0 ), "ServerCallback_CustomGauntlet_ShowError", 1 );
	}
	else
	{
		CustomGauntletsGlobal.DevelopmentTrack.StartLine.FromEnt = ToolGauntletPlaceTrigger_CreateTriggerEntity( Pos, Angles, 100.0 );
		CustomGauntletsGlobal.DevelopmentTrack.StartLine.ToEnt = ToolGauntletPlaceTrigger_CreateTriggerEntity( Pos, Angles, -100.0 );
	}
#endif
}

void function ToolGauntletPlaceTrigger_SetupFinishLine( vector Pos, vector Angles )
{
#if SERVER
	if( CustomGauntlet_HasFinishLineEntities( CustomGauntletsGlobal.DevelopmentTrack ) )
	{
		Remote_CallFunction_NonReplay( GetPlayerByIndex( 0 ), "ServerCallback_CustomGauntlet_ShowError", 2 );
	}
	else
	{
		CustomGauntletsGlobal.DevelopmentTrack.FinishLine.FromEnt = ToolGauntletPlaceTrigger_CreateTriggerEntity( Pos, Angles, 100.0 );
		CustomGauntletsGlobal.DevelopmentTrack.FinishLine.ToEnt = ToolGauntletPlaceTrigger_CreateTriggerEntity( Pos, Angles, -100.0 );
	}
#endif
}

void function ToolGauntletPlaceTrigger_SetupCheckpointLine( vector Pos, vector Angles )
{
#if SERVER
	GauntletTriggerLine NewTrigger;
	NewTrigger.FromEnt = ToolGauntletPlaceTrigger_CreateTriggerEntity( Pos, Angles, 100.0 );
	NewTrigger.ToEnt = ToolGauntletPlaceTrigger_CreateTriggerEntity( Pos, Angles, -100.0 );
	CustomGauntletsGlobal.DevelopmentTrack.Checkpoints.append( NewTrigger );
#endif
}
