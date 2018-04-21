
enum ToolCameraType
{
	Static,
	Tracking,
	MAX
}

struct PlacedCamera
{
	bool IsValid,
	vector Position,
	vector Rotation,
	int CameraType,
	entity DisplayEntity
};

const int MAX_CAMERAS = 10;
array<string> CAMERA_COLORS = [
	"255 255 255",
	"255 0 0",
	"0 255 0",
	"0 0 255",
	"255 255 0",
	"255 0 255",
	"0 255 255",
	"255 96 0",
	"128 0 255",
	"128 255 0"
];

table ToolCamera = {};

struct
{
	table< int, PlacedCamera > Cameras,
	entity ViewControlOverride
} ToolCameraData;

void function Toolgun_RegisterTool_CameraPlacer()
{
	// Register convars
	RegisterConVar( "camera_id", 0, "camera_id [0/1/2/3/4/5/6/7/8/9]", "Set the id for the camera placed" );
	RegisterConVar( "camera_type", 0, "camera_type type", "Set camera type of the Camera tool" );
#if SERVER
	AddClientCommandCallback( "CameraTool_ViewCamera", ClientCommand_CameraTool_ViewCamera );
#endif

	// Register camera input
#if CLIENT
	RegisterButtonPressedCallback( KEY_PAD_0, ToolCameraPlacer_SetCameraID_0 );
	RegisterButtonPressedCallback( KEY_PAD_1, ToolCameraPlacer_SetCameraID_1 );
	RegisterButtonPressedCallback( KEY_PAD_2, ToolCameraPlacer_SetCameraID_2 );
	RegisterButtonPressedCallback( KEY_PAD_3, ToolCameraPlacer_SetCameraID_3 );
	RegisterButtonPressedCallback( KEY_PAD_4, ToolCameraPlacer_SetCameraID_4 );
	RegisterButtonPressedCallback( KEY_PAD_5, ToolCameraPlacer_SetCameraID_5 );
	RegisterButtonPressedCallback( KEY_PAD_6, ToolCameraPlacer_SetCameraID_6 );
	RegisterButtonPressedCallback( KEY_PAD_7, ToolCameraPlacer_SetCameraID_7 );
	RegisterButtonPressedCallback( KEY_PAD_8, ToolCameraPlacer_SetCameraID_8 );
	RegisterButtonPressedCallback( KEY_PAD_9, ToolCameraPlacer_SetCameraID_9 );
#endif

	// Create the tool
	ToolCamera.id <- "camera";
	ToolCamera.CameraModel <- $"models/humans/pilots/pilot_light_ged_m_head_gib.mdl";
	ToolCamera.IsEquipped <- false;
	ToolCamera.IsViewing <- -1;

	ToolCamera.GetName <- function()
	{
		float CameraId = floor( GetConVarValue( "camera_id", 0 ) );
		float CameraType = floor( GetConVarValue( "camera_type", 0 ) );

		string Name = "Camera";
		Name += " [" + CameraId + "]";
		switch ( CameraType )
		{
			case ToolCameraType.Static:
				Name += " - Static";
				break;
			case ToolCameraType.Tracking:
				Name += " - Player Tracking";
				break;
		}
		return Name;
	}

	ToolCamera.GetRawName <- function()
	{
		return "Camera";
	}

	ToolCamera.GetHelp <- function()
	{
		return "Fire to place a camera that you can look through.\nUse numpad to select camera ID.\nTab to change camera type.";
	}

	ToolCamera.OnSelected <- function()
	{
		ToolCamera.IsEquipped <- true;

	#if SERVER
		PrecacheModel( ToolCamera.CameraModel );
	#endif

	#if CLIENT
		RegisterButtonPressedCallback( KEY_TAB, ToolCameraPlacer_ToggleCameraType );
	#endif
	}

	ToolCamera.OnDeselected <- function()
	{
		ToolCamera.IsEquipped <- false;

	#if CLIENT
		DeregisterButtonPressedCallback( KEY_TAB, ToolCameraPlacer_ToggleCameraType );
	#endif
	}

	ToolCamera.OnFire <- function()
	{
	#if SERVER
		entity player = GetPlayerByIndex( 0 );
		vector eyePosition = player.EyePosition();
		vector eyeAngles = player.EyeAngles();

		int CameraId = floor( GetConVarValue( "camera_id", 0 ) ).tointeger();
		int CameraType = floor( GetConVarValue( "camera_type", 0 ) ).tointeger();

		// Remove previous camera if it exists
		if( CameraId in ToolCameraData.Cameras )
		{
			PlacedCamera PrevCamera = ToolCameraData.Cameras[ CameraId ];
			if( IsValid( PrevCamera.DisplayEntity ) )
			{
				PrevCamera.DisplayEntity.Destroy();
				PrevCamera.DisplayEntity = null;
			}
			PrevCamera.IsValid = false;
		}

		// Create display entity
		entity prop_dynamic = CreateEntity( "prop_dynamic" );
		prop_dynamic.SetValueForModelKey( ToolCamera.CameraModel );
		prop_dynamic.kv.fadedist = -1;
		prop_dynamic.kv.renderamt = 255;
		prop_dynamic.kv.rendercolor = CAMERA_COLORS[CameraId]; //"255 255 255";
		prop_dynamic.kv.solid = 0; // No collision
		// prop_dynamic.SetSkin( 2 );
		SetTeam( prop_dynamic, TEAM_BOTH );

		prop_dynamic.SetOrigin( eyePosition );
		prop_dynamic.SetAngles( eyeAngles );
		DispatchSpawn( prop_dynamic );

		// Setup camera data
		PlacedCamera NewCamera;
		NewCamera.Position = eyePosition;
		NewCamera.Rotation = eyeAngles;
		NewCamera.CameraType = CameraType;
		NewCamera.DisplayEntity = prop_dynamic;
		NewCamera.IsValid = true;
		ToolCameraData.Cameras[ CameraId ] <- NewCamera;

		return false;
	#else
		return false;
	#endif
	}

	// Register the tool
	ToolGunTools.append( ToolCamera );

	#if SERVER
	// Start updating camera rotations
	thread ToolCameraPlacer_Think();
	#endif

}

#if CLIENT
void function ToolCameraPlacer_ToggleCameraType( var button )
{
	float NewCameraType = floor( GetConVarValue( "camera_type", 0 ) ) + 1;
	if( NewCameraType >= ToolCameraType.MAX )
	{
		NewCameraType = 0;
	}
	SetConVarValue( "camera_type", NewCameraType );

	EmitSoundOnEntity( GetLocalClientPlayer(), "menu_click" );
}

void function ToolCameraPlacer_NumpadInput( int id )
{
	if( Toolgun_CanUseKeyboardInput() )
	{
		if( Toolgun_IsHoldingToolgun() && ToolCamera.IsEquipped )
		{
			// Camera tool is equipped, so set the camera id
			SetConVarValue( "camera_id", id.tofloat() );
		}
		else
		{
			// Camera tool is not equipped, so set view to the camera
			ToolCameraPlacer_ToggleCamera( id );
		}
	}
}

void function ToolCameraPlacer_SetCameraID_0( var button ){ ToolCameraPlacer_NumpadInput( 0 ); }
void function ToolCameraPlacer_SetCameraID_1( var button ){ ToolCameraPlacer_NumpadInput( 1 ); }
void function ToolCameraPlacer_SetCameraID_2( var button ){ ToolCameraPlacer_NumpadInput( 2 ); }
void function ToolCameraPlacer_SetCameraID_3( var button ){ ToolCameraPlacer_NumpadInput( 3 ); }
void function ToolCameraPlacer_SetCameraID_4( var button ){ ToolCameraPlacer_NumpadInput( 4 ); }
void function ToolCameraPlacer_SetCameraID_5( var button ){ ToolCameraPlacer_NumpadInput( 5 ); }
void function ToolCameraPlacer_SetCameraID_6( var button ){ ToolCameraPlacer_NumpadInput( 6 ); }
void function ToolCameraPlacer_SetCameraID_7( var button ){ ToolCameraPlacer_NumpadInput( 7 ); }
void function ToolCameraPlacer_SetCameraID_8( var button ){ ToolCameraPlacer_NumpadInput( 8 ); }
void function ToolCameraPlacer_SetCameraID_9( var button ){ ToolCameraPlacer_NumpadInput( 9 ); }

#endif

#if SERVER
bool function ClientCommand_CameraTool_ViewCamera( entity player, array<string> args )
{
	int CameraId = args[0].tointeger();
	ToolCameraPlacer_ToggleCamera( CameraId );
	return true;
}
#endif

void function ToolCameraPlacer_ToggleCamera( int id )
{
#if CLIENT
	GetLocalClientPlayer().ClientCommand( "CameraTool_ViewCamera " + id );
#endif

#if SERVER
	entity player = GetPlayerByIndex( 0 );

	if( ToolCamera.IsViewing != -1 )
	{
		// Detach player
		if ( IsValid( player ) )
		{
			player.ClearViewEntity();
			RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD );
			RemoveCinematicFlag( player, CE_FLAG_TITAN_3P_CAM );
			RemoveCinematicFlag( player, CE_FLAG_EMBARK );
		}

		// Destroy previous view control
		if( IsValid( ToolCameraData.ViewControlOverride ) )
		{
			ToolCameraData.ViewControlOverride.Destroy();
			ToolCameraData.ViewControlOverride = null;
		}

		// Show all camera models
		ToolCameraPlacer_SetCameraModelsVisible( true );
	}

	// Check if is valid
	bool IsValid = false;
	PlacedCamera ViewingCamera;
	if( id in ToolCameraData.Cameras )
	{
		ViewingCamera = ToolCameraData.Cameras[ id ];
		IsValid = ViewingCamera.IsValid;
	}

	if( IsValid && ToolCamera.IsViewing != id )
	{
		// Create new view control
		entity Camera = CreateEntity( "point_viewcontrol" );
		Camera.kv.spawnflags = 56; // infinite hold time, snap to goal angles, make player non-solid
		Camera.SetOrigin( ViewingCamera.Position );
		Camera.SetAngles( ViewingCamera.Rotation );
		DispatchSpawn( Camera );

		AddCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD  );
		AddCinematicFlag( player, CE_FLAG_TITAN_3P_CAM );
		AddCinematicFlag( player, CE_FLAG_EMBARK );
		player.SetViewEntity( Camera, true );

		ToolCameraData.ViewControlOverride = Camera;

		// Hide all camera models
		ToolCameraPlacer_SetCameraModelsVisible( false );
	}

	if( ToolCamera.IsViewing == id )
	{
		// Toggle back to player
		ToolCamera.IsViewing = -1;
	}
	else
	{
		// Select new camera
		ToolCamera.IsViewing = id;
	}
#endif
}

#if SERVER
void function ToolCameraPlacer_SetCameraModelsVisible( bool visible )
{
	for( int i = 0; i < MAX_CAMERAS; ++i )
	{
		if( i in ToolCameraData.Cameras )
		{
			PlacedCamera Cam = ToolCameraData.Cameras[ i ];
			if( IsValid( Cam.DisplayEntity ) )
			{
				if( visible )
				{
					Cam.DisplayEntity.Show();
				}
				else
				{
					Cam.DisplayEntity.Hide();
				}
			}
		}
	}
}
#endif

#if SERVER
void function ToolCameraPlacer_Think()
{
	while( true )
	{
		entity player = GetPlayerByIndex( 0 );
		if( IsValid( player ) )
		{
			for( int i = 0; i < MAX_CAMERAS; ++i )
			{
				if( i in ToolCameraData.Cameras )
				{
					PlacedCamera Cam = ToolCameraData.Cameras[ i ];
					if( Cam.CameraType == ToolCameraType.Tracking && IsValid( Cam.DisplayEntity ) )
					{
						// Update cameras
						vector LookAtAngles = VectorToAngles( player.GetOrigin() - Cam.DisplayEntity.GetOrigin() );
						Cam.DisplayEntity.SetAngles( LookAtAngles );
						Cam.Rotation = LookAtAngles;

						// If player is viewing this camera then update it too
						if( ToolCamera.IsViewing == i && IsValid( ToolCameraData.ViewControlOverride ) )
						{
							ToolCameraData.ViewControlOverride.SetAngles( LookAtAngles );
						}
					}
				}
			}
		}
		WaitFrame();
	}
}
#endif
