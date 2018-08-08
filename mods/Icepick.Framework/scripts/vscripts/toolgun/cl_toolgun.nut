untyped
global function Toolgun_Client_Init
global function Toolgun_Client_SelectTool
global function Toolgun_Client_ChangeTool
global function Toolgun_Client_PrimaryAttack
global function Toolgun_CanUseKeyboardInput
global function Toolgun_Client_ToggleEditMode
global function ServerCallback_Toolgun_RegisterTools;
global function Toolgun_IsHoldingToolgun
global function Toolgun_IsHoldingToolgun_IgnoreEnabled

global struct ToolgunGrabStruct {
	entity GrabbedEntity,
	bool IsRotating,
	float OriginalSensitivity,
	vector LastEyeAngles
};

global ToolgunGrabStruct ToolgunGrab;

void function Toolgun_Client_Init()
{
	RegisterConCommandTriggeredCallback( "toggle_toolgun", KeyPress_ToolgunToggleEnabled );

	RegisterConCommandTriggeredCallback( "+zoom", MousePress_ToolgunGrab );
	RegisterConCommandTriggeredCallback( "-zoom", MouseRelease_ToolgunGrab );

	RegisterConCommandTriggeredCallback( "undo", KeyPress_Toolgun_UndoSpawn );

	// Toolgun mouse rotation
	RegisterConCommandTriggeredCallback( "+use", KeyPress_ToolgunRotate );
	RegisterConCommandTriggeredCallback( "-use", KeyRelease_ToolgunRotate );
	RegisterConCommandTriggeredCallback( "+speed", KeyPress_ToolgunRotateSnap );
	RegisterConCommandTriggeredCallback( "-speed", KeyRelease_ToolgunRotateSnap );

	RegisterButtonReleasedCallback( MOUSE_WHEEL_UP, KeyPress_ScrollUp );
	RegisterButtonReleasedCallback( MOUSE_WHEEL_DOWN, KeyPress_ScrollDown );

	// Fine rotation using numpad
	RegisterButtonPressedCallback( KEY_PAD_8, KeyPress_ToolgunRotate_PitchUp );
	RegisterButtonPressedCallback( KEY_PAD_2, KeyPress_ToolgunRotate_PitchDown );
	RegisterButtonPressedCallback( KEY_PAD_4, KeyPress_ToolgunRotate_YawLeft );
	RegisterButtonPressedCallback( KEY_PAD_6, KeyPress_ToolgunRotate_YawRight );
	RegisterButtonPressedCallback( KEY_PAD_7, KeyPress_ToolgunRotate_RollLeft );
	RegisterButtonPressedCallback( KEY_PAD_9, KeyPress_ToolgunRotate_RollRight );
	RegisterButtonPressedCallback( KEY_PAD_5, KeyPress_ToolgunRotate_Reset );
}

bool function Toolgun_CanUseKeyboardInput()
{
	return true;
}

bool function Toolgun_Client_PrimaryAttack( entity player )
{
	if( "OnFire" in Toolgun_GetCurrentMode() )
	{
		Toolgun_GetCurrentMode().OnFire();
	}
	return false;
}

void function KeyPress_ToolgunToggleEnabled( var button )
{
	Toolgun_Client_ToggleEditMode();
}

void function Toolgun_Client_ToggleEditMode()
{
	ToolgunModeEnabled = !ToolgunModeEnabled;
	GetLocalClientPlayer().ClientCommand( "Toolgun_ToggleEnabled " + (ToolgunModeEnabled ? 1 : 0) );
	EmitSoundOnEntity( GetLocalClientPlayer(), "menu_click" );
}

void function Toolgun_Client_SelectTool( string id )
{
	for( int i = 0; i < ToolGunTools.len(); ++i )
	{
		if( ToolGunTools[i].id == id )
		{
			Toolgun_Client_ChangeTool( i - ToolGunSettings.CurrentModeIdx );
			break;
		}
	}
}

void function Toolgun_Client_ChangeTool( int Change )
{
	if( Toolgun_CanUseKeyboardInput() )
	{
		// Deselect previous tool
		table OldTool = ToolGunTools[ToolGunSettings.CurrentModeIdx];
		if( "OnDeselected" in OldTool )
		{
			OldTool.OnDeselected();
		}

		// Change tool
		ToolGunSettings.CurrentModeIdx = ToolGunSettings.CurrentModeIdx + Change;
		if(ToolGunSettings.CurrentModeIdx == ToolGunTools.len())
		{
			ToolGunSettings.CurrentModeIdx = 0;
		}
		if(ToolGunSettings.CurrentModeIdx < 0)
		{
			ToolGunSettings.CurrentModeIdx = ToolGunTools.len() - 1;
		}

		// Select new tool
		table NewTool = ToolGunTools[ToolGunSettings.CurrentModeIdx];
		if( "OnSelected" in NewTool )
		{
			NewTool.OnSelected();
		}
	
		EmitSoundOnEntity( GetLocalClientPlayer(), "menu_focus" );
		GetLocalClientPlayer().ClientCommand( "Toolgun_SetMode " + ToolGunSettings.CurrentModeIdx );
	}
}

void function MousePress_ToolgunGrab( var button )
{
	// AddPlayerHint( 0.5, 0.25, $"", "Toolgun Grab" );

	if( Toolgun_IsHoldingToolgun() )
	{
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
}

void function MouseRelease_ToolgunGrab( var button )
{
	Toolgun_StopRotation();
	ToolgunGrab.GrabbedEntity = null;
	GetLocalClientPlayer().ClientCommand( "Toolgun_ReleaseEntity" );
}

void function KeyPress_ToolgunRotate( var button )
{
	if( IsValid( ToolgunGrab.GrabbedEntity ) )
	{
		ToolgunGrab.IsRotating = true;

		entity player = GetLocalClientPlayer();
		vector angles = player.EyeAngles();
		ToolgunGrab.LastEyeAngles = angles;

		GetLocalClientPlayer().FreezeControlsOnClient();

		GetLocalClientPlayer().ClientCommand( "Toolgun_Grab_StartRotate " + angles.x + " " + angles.y + " " + angles.z );
	}
}

void function KeyRelease_ToolgunRotate( var button )
{
	if( IsValid( ToolgunGrab.GrabbedEntity ) )
	{
		Toolgun_StopRotation();
	}
}

void function KeyPress_ToolgunRotateSnap( var button )
{
	if( IsValid( ToolgunGrab.GrabbedEntity ) )
	{
		GetLocalClientPlayer().ClientCommand( "Toolgun_Grab_RotateSnap 1" );
	}
}

void function KeyRelease_ToolgunRotateSnap( var button )
{
	GetLocalClientPlayer().ClientCommand( "Toolgun_Grab_RotateSnap 0" );
}

void function KeyPress_ScrollUp( var button )
{
	GetLocalClientPlayer().ClientCommand( "Toolgun_Grab_MoveForward 1" );
}

void function KeyPress_ScrollDown( var button )
{
	GetLocalClientPlayer().ClientCommand( "Toolgun_Grab_MoveForward -1" );
}

void function Toolgun_StopRotation()
{
	ToolgunGrab.IsRotating = false;
	GetLocalClientPlayer().ClientCommand( "Toolgun_Grab_StopRotate" );
	GetLocalClientPlayer().UnfreezeControlsOnClient();
}

void function Toolgun_PerformRotate( float x, float y, float z )
{
	if( Toolgun_CanUseKeyboardInput() )
	{
		GetLocalClientPlayer().ClientCommand( "Toolgun_Grab_PerformRotation " + x + " " + y + " " + z );
	}
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

void function ToolgunGrab_Think()
{
	while( ToolgunGrab.GrabbedEntity != null )
	{
		entity player = GetLocalClientPlayer();
		vector origin = player.EyePosition();
		vector angles = player.EyeAngles();
		vector forward = AnglesToForward( angles );

		if( ToolgunGrab.IsRotating )
		{
			float deltaX = GetMouseDeltaX() * 1.0;
			float deltaY = GetMouseDeltaY() * 1.0;

			player.ClientCommand( "Toolgun_Grab_PerformRotation " + deltaY + " " + deltaX + " " + 0 );
		}

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

void function ServerCallback_Toolgun_RegisterTools()
{
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
}

bool function Toolgun_IsHoldingToolgun()
{
	return Toolgun_IsHoldingToolgun_IgnoreEnabled() && ToolgunModeEnabled;
}

bool function Toolgun_IsHoldingToolgun_IgnoreEnabled()
{
	entity player = GetLocalClientPlayer()
	if( player )
	{
		entity plyWeapon = player.GetActiveWeapon()
		if( plyWeapon != null )
		{
			return plyWeapon.GetWeaponClassName() == "mp_weapon_shotgun_pistol";
		}
	}
	return false;
}
