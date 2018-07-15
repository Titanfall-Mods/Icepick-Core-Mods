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
	vector RotatePivot,
	float GrabDistance,
	bool IsRotating,
	bool IsSnapping,
	vector SnapAccumulatedAngles,

	entity GrabBeamEffect,
	entity GrabBeamTarget

	array<string> WeaponsTakenFromPlayer
} ToolgunGrab;

void function Toolgun_Server_Init()
{
	AddSpawnCallback( "player", ToolgunSv_OnPlayerSpawned );

	AddClientCommandCallback( "Toolgun_ToggleEnabled", ClientCommand_Toolgun_ToggleEnabled );
	AddClientCommandCallback( "Toolgun_SetMode", ClientCommand_Toolgun_SetMode );
	AddClientCommandCallback( "Toolgun_PrimaryAttack", ClientCommand_Toolgun_PrimaryAttack );
	AddClientCommandCallback( "Toolgun_GrabEntity", ClientCommand_Toolgun_GrabEntity );
	AddClientCommandCallback( "Toolgun_ReleaseEntity", ClientCommand_Toolgun_ReleaseEntity );
	AddClientCommandCallback( "Toolgun_Grab_StartRotate", ClientCommand_Toolgun_Grab_StartRotate );
	AddClientCommandCallback( "Toolgun_Grab_StopRotate", ClientCommand_Toolgun_Grab_StopRotate );
	AddClientCommandCallback( "Toolgun_Grab_RotateSnap", ClientCommand_Toolgun_Grab_RotateSnap );
	AddClientCommandCallback( "Toolgun_Grab_PerformRotation", ClientCommand_Toolgun_Grab_PerformRotation );
	AddClientCommandCallback( "Toolgun_Grab_MoveForward", ClientCommand_Toolgun_Grab_MoveForward );
	AddClientCommandCallback( "Toolgun_ChangeModel", ClientCommand_Toolgun_ChangeModel );
	AddClientCommandCallback( "Toolgun_UndoSpawn", ClientCommand_Toolgun_UndoSpawn );
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

		// Remove player non-toolgun weapons and give them back after stop moving prop
		ToolgunGrab.WeaponsTakenFromPlayer.clear();
		array<entity> weapons = player.GetMainWeapons();
		foreach ( weapon in weapons )
		{
			if( weapon != player.GetActiveWeapon() )
			{
				string weaponClassName = weapon.GetWeaponClassName();
				player.TakeWeaponNow( weaponClassName );
				ToolgunGrab.WeaponsTakenFromPlayer.append( weaponClassName );
			}
		}

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

	// Give weapons back to player
	foreach( weapon in ToolgunGrab.WeaponsTakenFromPlayer )
	{
		player.GiveWeapon( weapon );
	}
	ToolgunGrab.WeaponsTakenFromPlayer.clear();

	return true;
}

bool function ClientCommand_Toolgun_Grab_StartRotate( entity player, array<string> args )
{
	vector eyePosition = player.EyePosition();
	vector viewVector = player.GetViewVector();
	TraceResults traceResults = TraceLine( eyePosition, eyePosition + viewVector * 10000, player, TRACE_MASK_PLAYERSOLID | TRACE_MASK_TITANSOLID | TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_NONE )
	if( traceResults.hitEnt )
	{
		ToolgunGrab.RotatePivot = traceResults.endPos;
	}
	ToolgunGrab.IsRotating = true;
	return true;
}

bool function ClientCommand_Toolgun_Grab_StopRotate( entity player, array<string> args )
{
	ToolgunGrab.IsRotating = false;
	return true;
}

bool function ClientCommand_Toolgun_Grab_RotateSnap( entity player, array<string> args )
{
	ToolgunGrab.IsSnapping = args[0] == "1";
	ToolgunGrab.SnapAccumulatedAngles = Vector( 0, 0, 0 );
	return true;
}

bool function ClientCommand_Toolgun_Grab_PerformRotation( entity player, array<string> args )
{
	if( ToolgunGrab.GrabbedEntity != null )
	{
		float pitchInput = args[0].tofloat();
		float yawInput = args[1].tofloat();
		float rollInput = args[2].tofloat();

		if(pitchInput == -1 && yawInput == -1 && rollInput == -1)
		{
			ToolgunGrab.GrabbedEntity.SetAngles( Vector(0, 0, 0) );
		}
		else
		{
			float rotateSpeed = GetConVarValue( "physgun_sensitivity", 0.05 );
			float snapAngle = GetConVarValue( "physgun_snap", 30 );
			vector rotationInput = Vector( pitchInput, yawInput, rollInput ) * rotateSpeed;

			if( ToolgunGrab.IsSnapping )
			{
				ToolgunGrab.SnapAccumulatedAngles += rotationInput;
				float ax = ToolgunGrab.SnapAccumulatedAngles.x;
				float ay = ToolgunGrab.SnapAccumulatedAngles.y;
				float az = ToolgunGrab.SnapAccumulatedAngles.z;

				rotationInput = Vector( 0, 0, 0 );

				if( fabs( ToolgunGrab.SnapAccumulatedAngles.x ) > snapAngle )
				{
					float sign = ax > 0 ? 1.0 : -1.0;
					rotationInput.x = snapAngle * sign;
					ax -= snapAngle * sign;
				}
				if( fabs( ToolgunGrab.SnapAccumulatedAngles.y ) > snapAngle )
				{
					float sign = ay > 0 ? 1.0 : -1.0;
					rotationInput.y = snapAngle * sign;
					ay -= snapAngle * sign;
				}
				if( fabs( ToolgunGrab.SnapAccumulatedAngles.z ) > snapAngle )
				{
					float sign = az > 0 ? 1.0 : -1.0;
					rotationInput.z = snapAngle * sign;
					az -= snapAngle * sign;
				}

				ToolgunGrab.SnapAccumulatedAngles = Vector( ax, ay, az );
			}

			vector rotXAxis = Vector( 0, 0, 1 );
			vector rotYAxis = AnglesToRight( player.EyeAngles() );
			Quaternion rotXQuat = Quaternion_AngleAxis( rotationInput.y, rotXAxis );
			Quaternion rotYQuat = Quaternion_AngleAxis( rotationInput.x, rotYAxis );

			vector delta = ToolgunGrab.GrabbedEntity.GetOrigin() - ToolgunGrab.RotatePivot;
			Quaternion combinedQuat = Quaternion_Multiply( rotXQuat, rotYQuat );
			ToolgunGrab.GrabOffset = Quaternion_VectorMultiply( combinedQuat , ToolgunGrab.GrabOffset );
            vector newPos = ToolgunGrab.RotatePivot + Quaternion_VectorMultiply( combinedQuat, delta );
            
            ToolgunGrab.GrabbedEntity.SetOrigin( newPos );

			vector entAngles = ToolgunGrab.GrabbedEntity.GetAngles();
			Quaternion entQuat = toQuaternion( entAngles );
			Quaternion invEntQuat = Quaternion_Invert( entQuat );

			vector transRotXAxis = Quaternion_VectorMultiply( invEntQuat, rotXAxis );
			vector transRotYAxis = Quaternion_VectorMultiply( invEntQuat, rotYAxis );
			Quaternion transRotXQuat = Quaternion_AngleAxis( rotationInput.y, transRotXAxis );
			Quaternion transRotYQuat = Quaternion_AngleAxis( rotationInput.x, transRotYAxis );

			Quaternion result = Quaternion_Multiply( Quaternion_Multiply( entQuat, transRotXQuat ), transRotYQuat );
			vector newAngles = Quaternion_Angles( result );
			if( ToolgunGrab.IsSnapping )
			{
				newAngles.x = RoundToNearestMultiple( newAngles.x, snapAngle );
				newAngles.y = RoundToNearestMultiple( newAngles.y, snapAngle );
				newAngles.z = RoundToNearestMultiple( newAngles.z, snapAngle );
			}

			ToolgunGrab.GrabbedEntity.SetAngles( newAngles );
		}

	}
	return true;
}

// Alsmot duplicate of RoundToNearestMultiplier, but that doesn't handle negative numbers correctly for the rotation
float function RoundToNearestMultiple( float value, float multiplier )
{
	float remainder = value % multiplier;
	remainder = remainder >= 0 ? remainder : multiplier - fabs(remainder);

	value -= remainder;

	if ( remainder >= ( multiplier / 2 ) )
		value += multiplier

	return value
}

bool function ClientCommand_Toolgun_Grab_MoveForward( entity player, array<string> args )
{
	float direction = args[0] == "1" ? 1.0 : -1.0;
	ToolgunGrab.GrabDistance += direction * GetConVarValue( "physgun_speed", 30.0 );
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

		if( ToolgunGrab.IsRotating )
		{
			// vector entAngles = ToolgunGrab.GrabbedEntity.GetAngles();
			// entAngles.y = (entAngles.y + 45 * FrameTime()) % 360.0
			// ToolgunGrab.GrabbedEntity.SetAngles( entAngles );
		}
		else
		{
			ToolgunGrab.GrabbedEntity.SetOrigin( origin + forward * ToolgunGrab.GrabDistance + ToolgunGrab.GrabOffset )
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
