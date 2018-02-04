
#if SERVER

struct {
	entity GrabbedEntity,
	vector GrabOffset,
	float GrabDistance,
	bool IsRotating,
	vector LockViewAngle,

	entity GrabBeamEffect,
	entity GrabBeamTarget
} ToolgunGrab;

struct {
	array<entity> SpawnedEntities,
	float LastSpawnTime
} ToolgunData;

void function Toolgun_Server_Init()
{
	AddClientCommandCallback( "Toolgun_SetMode", ClientCommand_Toolgun_SetMode )
	AddClientCommandCallback( "Toolgun_PrimaryAttack", ClientCommand_Toolgun_PrimaryAttack )
	AddClientCommandCallback( "Toolgun_GrabEntity", ClientCommand_Toolgun_GrabEntity )
	AddClientCommandCallback( "Toolgun_ReleaseEntity", ClientCommand_Toolgun_ReleaseEntity )
	AddClientCommandCallback( "Toolgun_Grab_StartRotate", ClientCommand_Toolgun_Grab_StartRotate )
	AddClientCommandCallback( "Toolgun_Grab_StopRotate", ClientCommand_Toolgun_Grab_StopRotate )
	AddClientCommandCallback( "Toolgun_Grab_PerformRotation", ClientCommand_Toolgun_Grab_PerformRotation )
	AddClientCommandCallback( "Toolgun_ChangeModel", ClientCommand_Toolgun_ChangeModel )
	AddClientCommandCallback( "Toolgun_UndoSpawn", ClientCommand_Toolgun_UndoSpawn )

	// Test_RemoveTriggers( "trigger_cylinder" )
	// Test_RemoveTriggers( "trigger_multiple" )
	// Test_RemoveTriggers( "trigger_once" )
	// Test_RemoveTriggers( "trigger_flag_set" )
	// Test_RemoveTriggers( "trigger_flag_clear" )
	// Test_RemoveTriggers( "trigger_flag_touching" )
	// Test_RemoveTriggers( "trigger_movetarget" )
	// Test_RemoveTriggers( "trigger_checkpoint" )
	// Test_RemoveTriggers( "trigger_checkpoint_silent" )
	// Test_RemoveTriggers( "trigger_checkpoint_safe" )
	// Test_RemoveTriggers( "trigger_checkpoint_forced" )
	// Test_RemoveTriggers( "trigger_checkpoint_to_safe_spots" )
	// Test_RemoveTriggers( "trigger_teleporter" )
	// Test_RemoveTriggers( "trigger_quickdeath_checkpoint" )
	// Test_RemoveTriggers( "trigger_quickdeath" )
	// Test_RemoveTriggers( "trigger_hurt" )
	// Test_RemoveTriggers( "trigger_out_of_bounds" )
	// Test_RemoveTriggers( "trigger_level_transition" )
}

void function Test_RemoveTriggers( string classname )
{
	array<entity> triggers = GetEntArrayByClass_Expensive( classname )
	foreach ( trigger in triggers )
	{
		trigger.Destroy()
	}
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
	else if( Toolgun_GetCurrentModeFunction() != null )
	{
		Toolgun_GetCurrentModeFunction()( player, args );
		return true
	}
	return false
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
	ToolgunGrab.IsRotating = true;
	ToolgunGrab.LockViewAngle = Vector( args[0].tofloat(), args[1].tofloat(), args[2].tofloat() );
	return true;
}

bool function ClientCommand_Toolgun_Grab_StopRotate( entity player, array<string> args )
{
	ToolgunGrab.IsRotating = false;
	return true;
}

bool function ClientCommand_Toolgun_Grab_PerformRotation( entity player, array<string> args )
{
	if( ToolgunGrab.GrabbedEntity != null )
	{
#if TOOLGUN_ENABLE_MOUSE_ROTATE
		// bad but working mouse rotation
		/*
		vector rotation = Vector( args[0].tofloat() * 100, args[1].tofloat() * 100, args[2].tofloat() * 100 );
		vector angles = AnglesCompose( ToolgunGrab.GrabbedEntity.GetAngles(), Vector( 0.0, args[1].tofloat() * 10.0, 0.0 ) );
		angles = AnglesCompose( angles, Vector( args[0].tofloat() * 10.0, 0.0, 0.0 ) );
		*/

		// better, but still bad mouse rotation
		float xInput = args[0].tofloat() * 50;
		float yInput = args[1].tofloat() * 50;
		vector entAngles = ToolgunGrab.GrabbedEntity.GetAngles();
		if ( fabs( xInput ) + fabs( yInput ) >= 0.05 )
		{
			if ( fabs( yInput ) > fabs( xInput ) )
				entAngles = AnglesCompose( entAngles, Vector( xInput, 0.0, 0.0 ) )
			else
				entAngles = AnglesCompose( entAngles, Vector( 0.0, yInput, 0.0 ) )

			ToolgunGrab.GrabbedEntity.SetAngles( entAngles )
		}
#else
		float pitchInput = args[0].tofloat();
		float yawInput = args[1].tofloat();
		float rollInput = args[2].tofloat();

		if(pitchInput == -1 && yawInput == -1 && rollInput == -1)
		{
			ToolgunGrab.GrabbedEntity.SetAngles( Vector(0, 0, 0) );
		}
		else
		{
			float rotateSpeed = 15;
			vector rotationInput = Vector( pitchInput, yawInput, rollInput ) * rotateSpeed;

			vector entAngles = ToolgunGrab.GrabbedEntity.GetAngles();
			entAngles = AnglesCompose( entAngles, rotationInput );
			ToolgunGrab.GrabbedEntity.SetAngles( entAngles );
		}
#endif

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

		wait 0.016;
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

#endif
