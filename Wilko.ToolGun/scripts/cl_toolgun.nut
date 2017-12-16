
#if CLIENT

struct {
	entity GrabbedEntity,
	bool IsRotating,
	float OriginalSensitivity,
	vector LastEyeAngles
} ToolgunGrab;

void function Toolgun_Client_Init()
{
	RegisterButtonPressedCallback( KEY_PAD_MINUS, KeyPress_ToolgunPrevMode );
	RegisterButtonPressedCallback( KEY_PAD_PLUS, KeyPress_ToolgunNextMode );

	RegisterButtonPressedCallback( KEY_PAD_ENTER, KeyPress_ToolgunRandomProp );

	RegisterButtonPressedCallback( MOUSE_RIGHT, MousePress_ToolgunGrab );
	RegisterButtonReleasedCallback( MOUSE_RIGHT, MouseRelease_ToolgunGrab );

	RegisterButtonPressedCallback( KEY_BACKSPACE, KeyPress_Toolgun_UndoSpawn );

#if TOOLGUN_ENABLE_MOUSE_ROTATE
	// Renable for toolgun mouse rotation
	RegisterButtonPressedCallback( KEY_E, KeyPress_ToolgunRotate );
	RegisterButtonReleasedCallback( KEY_E, KeyRelease_ToolgunRotate );
#endif

	// todo: better prop rotation
	RegisterButtonPressedCallback( KEY_PAD_8, KeyPress_ToolgunRotate_PitchUp );
	RegisterButtonPressedCallback( KEY_PAD_2, KeyPress_ToolgunRotate_PitchDown );
	RegisterButtonPressedCallback( KEY_PAD_4, KeyPress_ToolgunRotate_YawLeft );
	RegisterButtonPressedCallback( KEY_PAD_6, KeyPress_ToolgunRotate_YawRight );
	RegisterButtonPressedCallback( KEY_PAD_7, KeyPress_ToolgunRotate_RollLeft );
	RegisterButtonPressedCallback( KEY_PAD_9, KeyPress_ToolgunRotate_RollRight );
	RegisterButtonPressedCallback( KEY_PAD_5, KeyPress_ToolgunRotate_Reset );
}

bool function Toolgun_Client_PrimaryAttack( entity player )
{
	if( Toolgun_GetCurrentModeFunction() != null )
	{
		array<string> args = [];
		Toolgun_GetCurrentModeFunction()( player, args );
		return true
	}
	return false
}

void function KeyPress_ToolgunNextMode( var button )
{
	Toolgun_Client_ChangeTool( 1 );
}

void function KeyPress_ToolgunPrevMode( var button )
{
	Toolgun_Client_ChangeTool( -1 );
}

void function Toolgun_Client_ChangeTool( int Change )
{
	ToolGunSettings.CurrentModeIdx = ToolGunSettings.CurrentModeIdx + Change;
	if(ToolGunSettings.CurrentModeIdx == ToolGunTools.len())
	{
		ToolGunSettings.CurrentModeIdx = 0;
	}
	if(ToolGunSettings.CurrentModeIdx < 0)
	{
		ToolGunSettings.CurrentModeIdx = ToolGunTools.len() - 1;
	}

	EmitSoundOnEntity( GetLocalClientPlayer(), "menu_focus" );
	GetLocalClientPlayer().ClientCommand( "Toolgun_SetMode " + ToolGunSettings.CurrentModeIdx );
}

void function MousePress_ToolgunGrab( var button )
{
	AddPlayerHint( 0.5, 0.25, $"", "Toolgun Grab" );

	entity player = GetLocalClientPlayer();
	vector eyePosition = player.EyePosition();
	vector viewVector = player.GetViewVector();
	TraceResults traceResults = TraceLine( eyePosition, eyePosition + viewVector * 10000, player, TRACE_MASK_PLAYERSOLID | TRACE_MASK_TITANSOLID | TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_NONE )
	if( traceResults.hitEnt )
	{
		ToolgunGrab.GrabbedEntity = traceResults.hitEnt;
		if( ToolgunGrab.GrabbedEntity != null )
		{
			var GrabDistance = Length(traceResults.endPos - eyePosition);
			vector GrabOffset = ToolgunGrab.GrabbedEntity.GetOrigin() - traceResults.endPos;
			var cmd = "Toolgun_GrabEntity " + ToolgunGrab.GrabbedEntity.GetEntIndex() + " " + GrabOffset.x + " " + GrabOffset.y + " " + GrabOffset.z + " " + GrabDistance;
			GetLocalClientPlayer().ClientCommand( cmd );
			thread ToolgunGrab_Think();
		}
	}
}

void function MouseRelease_ToolgunGrab( var button )
{
	AddPlayerHint( 0.5, 0.25, $"", "Toolgun Release" );
	ToolgunGrab.GrabbedEntity = null;
	GetLocalClientPlayer().ClientCommand( "Toolgun_ReleaseEntity" );
}

void function KeyPress_ToolgunRotate( var button )
{
	AddPlayerHint( 0.5, 0.25, $"", "Toolgun rotate on" );

	ToolgunGrab.IsRotating = true;

#if TOOLGUN_ENABLE_MOUSE_ROTATE
	ToolgunGrab.OriginalSensitivity = GetConVarFloat( "mouse_sensitivity_zoomed" );
	SetConVarFloat( "mouse_sensitivity_zoomed", 0.001 );
#endif

	entity player = GetLocalClientPlayer();
	vector angles = player.EyeAngles();
	ToolgunGrab.LastEyeAngles = angles;

	GetLocalClientPlayer().ClientCommand( "Toolgun_Grab_StartRotate " + angles.x + " " + angles.y + " " + angles.z );
}

void function KeyRelease_ToolgunRotate( var button )
{
	AddPlayerHint( 0.5, 0.25, $"", "Toolgun rotate off" );

#if TOOLGUN_ENABLE_MOUSE_ROTATE
	SetConVarFloat( "mouse_sensitivity_zoomed", ToolgunGrab.OriginalSensitivity );
#endif

	ToolgunGrab.IsRotating = false;
	GetLocalClientPlayer().ClientCommand( "Toolgun_Grab_StopRotate" );
}

void function Toolgun_PerformRotate( float x, float y, float z )
{
	// AddPlayerHint( 0.5, 0.25, $"", "Rotate " + x + " " + y + " " + z );
	GetLocalClientPlayer().ClientCommand( "Toolgun_Grab_PerformRotation " + x + " " + y + " " + z );
}

void function KeyPress_ToolgunRotate_PitchUp( var button )
{
	Toolgun_PerformRotate( 1, 0, 0 );
}

void function KeyPress_ToolgunRotate_PitchDown( var button )
{
	Toolgun_PerformRotate( -1, 0, 0 );
}

void function KeyPress_ToolgunRotate_YawLeft( var button )
{
	Toolgun_PerformRotate( 0, -1, 0 );
}

void function KeyPress_ToolgunRotate_YawRight( var button )
{
	Toolgun_PerformRotate( 0, 1, 0 );
}

void function KeyPress_ToolgunRotate_RollLeft( var button )
{
	Toolgun_PerformRotate( 0, 0, -1 );
}

void function KeyPress_ToolgunRotate_RollRight( var button )
{
	Toolgun_PerformRotate( 0, 0, 1 );
}

void function KeyPress_ToolgunRotate_Reset( var button )
{
	Toolgun_PerformRotate( -1, -1, -1 );
}

void function KeyPress_ToolgunRandomProp( var button )
{
	int RandomIndex = RandomIntRange( 0, SpawnList.len() - 1 );
	ToolGunSettings.SelectedModel = SpawnList[ RandomIndex ];

	PrecacheModel( ToolGunSettings.SelectedModel );
	AddPlayerHint( 0.5, 0.15, $"", "Spawning: " + ToolGunSettings.SelectedModel );
	GetLocalClientPlayer().ClientCommand( "Toolgun_ChangeModel " + RandomIndex );
}

void function ToolgunGrab_Think()
{
	while( ToolgunGrab.GrabbedEntity != null )
	{
		entity player = GetLocalClientPlayer();
		vector origin = player.EyePosition();
		vector angles = player.EyeAngles();
		vector forward = AnglesToForward( angles );

#if TOOLGUN_ENABLE_MOUSE_ROTATE
		if( ToolgunGrab.IsRotating )
		{
			vector diff = ToolgunGrab.LastEyeAngles - angles;
			player.ClientCommand( "Toolgun_Grab_PerformRotation " + diff.x + " " + diff.y + " " + diff.z );
		}
#endif

		WaitFrame();
	}
}

void function KeyPress_Toolgun_UndoSpawn( var button )
{
	if( Toolgun_CanUseKeyboardInput() )
	{
		AddPlayerHint( 0.5, 0.15, $"", "Undo Spawn" );
		GetLocalClientPlayer().ClientCommand( "Toolgun_UndoSpawn" );
	}
}


#endif
