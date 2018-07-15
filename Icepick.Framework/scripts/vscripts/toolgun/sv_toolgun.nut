untyped
global function Toolgun_Server_Init
global function Toolgun_Utils_FireToolTracer
global function Toolgun_IsHoldingToolgun

global struct ToolgunDataStruct {
	array<entity> SpawnedEntities,
	float LastSpawnTime,
	bool HasRegisteredToolgunTools
}

global ToolgunDataStruct ToolgunData

struct {
	entity GrabbedEntity,
	vector GrabOffset,
	float GrabDistance,
	bool IsRotating,
	vector LockViewAngle,

	entity GrabBeamEffect,
	entity GrabBeamTarget
} ToolgunGrab;

void function Toolgun_Server_Init()
{
	AddSpawnCallback( "player", ToolgunSv_OnPlayerSpawned );

	AddClientCommandCallback( "Toolgun_ToggleEnabled", ClientCommand_Toolgun_ToggleEnabled )
	AddClientCommandCallback( "Toolgun_SetMode", ClientCommand_Toolgun_SetMode )
	AddClientCommandCallback( "Toolgun_PrimaryAttack", ClientCommand_Toolgun_PrimaryAttack )
	AddClientCommandCallback( "Toolgun_GrabEntity", ClientCommand_Toolgun_GrabEntity )
	AddClientCommandCallback( "Toolgun_ReleaseEntity", ClientCommand_Toolgun_ReleaseEntity )
	AddClientCommandCallback( "Toolgun_Grab_StartRotate", ClientCommand_Toolgun_Grab_StartRotate )
	AddClientCommandCallback( "Toolgun_Grab_StopRotate", ClientCommand_Toolgun_Grab_StopRotate )
	AddClientCommandCallback( "Toolgun_Grab_PerformRotation", ClientCommand_Toolgun_Grab_PerformRotation )
	AddClientCommandCallback( "Toolgun_ChangeModel", ClientCommand_Toolgun_ChangeModel )
	AddClientCommandCallback( "Toolgun_UndoSpawn", ClientCommand_Toolgun_UndoSpawn )
}

void function ToolgunSv_OnPlayerSpawned( entity player )
{
	if( ToolgunData.HasRegisteredToolgunTools )
	{
		return;
	}

	ClearTools(); // Clear tools from previous session

	for( int i = 0; i < ToolGunTools.len(); ++i )
	{
		var tool = ToolGunTools[i];

		// Register each tool
		var name = tool.GetName();
		if( "GetRawName" in tool )
		{
			name = tool.GetRawName();
		}
		RegisterTool( tool.id, name, tool.GetHelp() );

		// Register tool options
		if( "RegisterOptions" in tool )
		{
			tool.RegisterOptions();
		}
	}

	// Only register tools once
	ToolgunData.HasRegisteredToolgunTools = true;
}

bool function Toolgun_IsHoldingToolgun()
{
	entity player = GetPlayerByIndex( 0 );
	if( player )
	{
		entity plyWeapon = player.GetActiveWeapon();
		if( plyWeapon != null )
		{
			return plyWeapon.GetWeaponClassName() == "mp_weapon_shotgun_pistol";
		}
	}
	return false;
}

void function Toolgun_Utils_FireToolTracer( entity player )
{
	var lifeDuration = 0.1

	vector eyePosition = player.EyePosition()
	vector viewVector = player.GetViewVector()
	TraceResults traceResult = TraceLine( eyePosition, eyePosition + viewVector * 10000, player, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )

	// Control point sets the end position of the effect
	entity cpEnd = CreateEntity( "info_placement_helper" )
	SetTargetName( cpEnd, UniqueString( "emp_grenade_beam_cpEnd" ) )
	cpEnd.SetOrigin( traceResult.endPos )
	DispatchSpawn( cpEnd )

	vector forward2D = < viewVector.x, viewVector.y, 0 >
	entity zapBeam = CreateEntity( "info_particle_system" )
	zapBeam.kv.cpoint1 = cpEnd.GetTargetName()
	zapBeam.SetValueForEffectNameKey( EMP_GRENADE_BEAM_EFFECT )
	zapBeam.kv.start_active = 0
	zapBeam.SetOrigin( eyePosition + forward2D * 5 )
	DispatchSpawn( zapBeam )

	zapBeam.Fire( "Start" )
	zapBeam.Fire( "StopPlayEndCap", "", lifeDuration )
	zapBeam.Kill_Deprecated_UseDestroyInstead( lifeDuration )
	cpEnd.Kill_Deprecated_UseDestroyInstead( lifeDuration )
}

bool function ClientCommand_Toolgun_ToggleEnabled( entity player, array<string> args )
{
	ToolgunModeEnabled = args[0] == "1";

	// Set edit mode in the SDK so we can toggle it using a menu item
	if( ToolgunModeEnabled )
	{
		EnableEditMode();
	}
	else
	{
		DisableEditMode();
	}

	return true;
}

bool function ClientCommand_Toolgun_SetMode( entity player, array<string> args )
{
	// Deselect previous tool
	table OldTool = ToolGunTools[ToolGunSettings.CurrentModeIdx];
	if( "OnDeselected" in OldTool )
	{
		OldTool.OnDeselected();
	}

	// Change tool
	int ToolIdx = args[0].tointeger();
	ToolGunSettings.CurrentModeIdx = ToolIdx;

	// Select new tool
	table NewTool = ToolGunTools[ToolGunSettings.CurrentModeIdx];
	if( "OnSelected" in NewTool )
	{
		NewTool.OnSelected();
	}

	return true;
}

bool function ClientCommand_Toolgun_PrimaryAttack( entity player, array<string> args )
{
	if( "OnFire" in Toolgun_GetCurrentMode() )
	{
		Toolgun_GetCurrentMode().OnFire();
	}
	return false;
}

bool function ClientCommand_Toolgun_GrabEntity( entity player, array<string> args )
{
	ToolgunGrab.GrabbedEntity = GetEntByIndex( args[0].tointeger() );
	if( ToolgunGrab.GrabbedEntity != null )
	{
		ToolgunGrab.GrabOffset = Vector( args[1].tofloat(), args[2].tofloat(), args[3].tofloat() );
		ToolgunGrab.GrabDistance = args[4].tofloat();

		/*
		entity cpEnd = CreateEntity( "info_placement_helper" )
		SetTargetName( cpEnd, UniqueString( "emp_grenade_beam_cpEnd" ) )
		cpEnd.SetOrigin( ToolgunGrab.GrabbedEntity.GetOrigin() + ToolgunGrab.GrabOffset )
		DispatchSpawn( cpEnd )
		ToolgunGrab.GrabBeamTarget = cpEnd;

		entity zapBeam = CreateEntity( "info_particle_system" )
		zapBeam.kv.cpoint1 = cpEnd.GetTargetName()
		zapBeam.SetValueForEffectNameKey( TOOLGUN_GRAB_EFFECT )
		zapBeam.kv.start_active = 0
		zapBeam.SetOrigin( player.EyePosition() )
		DispatchSpawn( zapBeam )
		zapBeam.Fire( "Start" )
		ToolgunGrab.GrabBeamEffect = zapBeam;
		*/

		thread ToolgunGrab_Think( player );
		return true;
	}
	return false;
}

bool function ClientCommand_Toolgun_ReleaseEntity( entity player, array<string> args )
{
	ToolgunGrab.GrabbedEntity = null;
	// ToolgunGrab.GrabBeamEffect.Destroy();
	// ToolgunGrab.GrabBeamTarget.Destroy();

	return true;
}

bool function ClientCommand_Toolgun_Grab_StartRotate( entity player, array<string> args )
{
	// ToolgunGrab.IsRotating = true;
	// ToolgunGrab.LockViewAngle = Vector( args[0].tofloat(), args[1].tofloat(), args[2].tofloat() );
	return true;
}

bool function ClientCommand_Toolgun_Grab_StopRotate( entity player, array<string> args )
{
	// ToolgunGrab.IsRotating = false;
	return true;
}

bool function ClientCommand_Toolgun_Grab_PerformRotation( entity player, array<string> args )
{
	if( ToolgunGrab.GrabbedEntity != null )
	{
		float pitchInput = args[0].tofloat();
		float yawInput = args[1].tofloat();
		float rollInput = 0;

		if(pitchInput == -1 && yawInput == -1 && rollInput == -1)
		{
			ToolgunGrab.GrabbedEntity.SetAngles( Vector(0, 0, 0) );
		}
		else //if ( fabs( xInput ) + fabs( yInput ) >= 0.05 )
		{
			float rotateSpeed = 0.05;
			vector rotationInput = Vector( pitchInput, yawInput, rollInput ) * rotateSpeed;

			vector entAngles = ToolgunGrab.GrabbedEntity.GetAngles();
			Quaternion entQuat = toQuaternion( entAngles );
			Quaternion invEntQuat = Quaternion_Invert( entQuat );

			vector rotXAxis = Quaternion_VectorMultiply( invEntQuat, Vector( 0, 0, 1 ) );
			vector rotYAxis = Quaternion_VectorMultiply( invEntQuat, AnglesToRight( player.EyeAngles() ) );

			Quaternion rotXQuat = Quaternion_AngleAxis( rotationInput.y, rotXAxis );
			Quaternion rotYQuat = Quaternion_AngleAxis( rotationInput.x, rotYAxis );

			Quaternion result = Quaternion_Multiply( Quaternion_Multiply( entQuat, rotXQuat ), rotYQuat );
			vector newAngles = Quaternion_Angles( result );

			ToolgunGrab.GrabbedEntity.SetAngles( newAngles );
		}

	}
	return true;
}

bool function ClientCommand_Toolgun_ChangeModel( entity player, array<string> args )
{
	int Index = args[0].tointeger();
	ToolGunSettings.SelectedModel = CurrentLevelSpawnList[ Index ];
	return true;
}

void function ToolgunGrab_Think( entity player )
{
	while( ToolgunGrab.GrabbedEntity != null )
	{
		vector origin = player.EyePosition()
		vector angles = player.EyeAngles()
		vector forward = AnglesToForward( angles )
		ToolgunGrab.GrabbedEntity.SetOrigin( origin + forward * ToolgunGrab.GrabDistance + ToolgunGrab.GrabOffset )

		if( ToolgunGrab.IsRotating )
		{
			player.SnapEyeAngles( ToolgunGrab.LockViewAngle );

			// vector entAngles = ToolgunGrab.GrabbedEntity.GetAngles();
			// entAngles.y = (entAngles.y + 45 * FrameTime()) % 360.0
			// ToolgunGrab.GrabbedEntity.SetAngles( entAngles );
		}

		// ToolgunGrab.GrabBeamEffect.SetOrigin( player.EyePosition() + AnglesToRight( angles ) * 5 + AnglesToUp( angles ) * -5 )
		// ToolgunGrab.GrabBeamTarget.SetOrigin( origin + forward * ToolgunGrab.GrabDistance + ToolgunGrab.GrabOffset )

		WaitFrame();
	}
}

bool function ClientCommand_Toolgun_UndoSpawn( entity player, array<string> args )
{
	int NumEnts = ToolgunData.SpawnedEntities.len();
	if( NumEnts > 0 )
	{
		entity LastEnt = ToolgunData.SpawnedEntities.pop();
		if( IsValid( LastEnt ) )
		{
			LastEnt.Destroy();
		}
		return true;
	}
	return false;
}
