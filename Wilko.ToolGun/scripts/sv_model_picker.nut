
#if SERVER

struct
{
	entity CameraOverride,
	entity PreviewProp,
	string LastPreviewedModel
} ModelPickerSettings;

void function ModelPicker_Server_Init()
{
	AddClientCommandCallback( "ModelPicker_OnOpenPicker", ClientCommand_ModelPicker_Open );
	AddClientCommandCallback( "ModelPicker_OnClosePicker", ClientCommand_ModelPicker_Close );
	AddClientCommandCallback( "ModelPicker_UpdatePreviewModel", ClientCommand_ModelPicker_UpdatePreview );
	AddClientCommandCallback( "ModelPicker_ClearPreviewModel", ClientCommand_ModelPicker_ClearPreview );

	thread ModelPicker_Server_Think();
}

void function ModelPicker_Server_Think()
{
	while( true )
	{
		if( IsValid( ModelPickerSettings.PreviewProp ) )
		{
			// Slowly rotate the preview object
			vector Ang = ModelPickerSettings.PreviewProp.GetAngles() + Vector( 0.0, 10.0 * FrameTime(), 0.0 );
			ModelPickerSettings.PreviewProp.SetAngles( Ang );

			// Destroy if the preview camera has been destroyed
			if( !IsValid( ModelPickerSettings.CameraOverride ) )
			{
				ModelPicker_ClearPreview();
			}
		}
		WaitFrame();
	}
}

void function ModelPicker_ClearPreview()
{
	if( IsValid( ModelPickerSettings.PreviewProp ) )
	{
		ModelPickerSettings.PreviewProp.Destroy();
		ModelPickerSettings.PreviewProp = null;
	}
}

vector function ModelPicker_GetPreviewLocation()
{
	return <11655.3, -8851.05, 10683.07>; // @todo: set these per level
}

vector function ModelPicker_GetPreviewAngles()
{
	return <28.1506, 167.353, 0.0>;
}

bool function ClientCommand_ModelPicker_Open( entity player, array<string> args )
{
	entity Camera = CreateEntity( "point_viewcontrol" );
	Camera.kv.spawnflags = 56; // infinite hold time, snap to goal angles, make player non-solid
	Camera.SetOrigin( ModelPicker_GetPreviewLocation() );
	Camera.SetAngles( ModelPicker_GetPreviewAngles() );
	DispatchSpawn( Camera );

	player.SetVelocity( < 0,0,0 > )
	player.MakeInvisible()
	HolsterAndDisableWeapons( player )
	AddCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD  )
	AddCinematicFlag( player, CE_FLAG_TITAN_3P_CAM )
	player.SetViewEntity( Camera, true )

	ModelPickerSettings.CameraOverride = Camera;
	return true;
}

bool function ClientCommand_ModelPicker_Close( entity player, array<string> args )
{
	if( IsValid( ModelPickerSettings.CameraOverride ) )
	{
		ModelPickerSettings.CameraOverride.Destroy();
		ModelPickerSettings.CameraOverride = null;
		if ( IsValid( player ) )
		{
			player.ClearViewEntity();
			player.MakeVisible();
			DeployAndEnableWeapons( player )
			RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD );
			RemoveCinematicFlag( player, CE_FLAG_TITAN_3P_CAM );
			return true;
		}
	}
	ModelPicker_ClearPreview();
	return false;
}

bool function ClientCommand_ModelPicker_UpdatePreview( entity player, array<string> args )
{
	if( args.len() == 0 )
	{
		return false; // No asset to preview
	}
	string AssetStr = args[0];
	asset PreviewAsset = $"";

	//  Hack: Can't convert string to asset(?), so find the asset based on a string search in the spawn list
	string CompareAssetStr = "$\"" + AssetStr + "\"";
	for( int i = 0; i < CurrentLevelSpawnList.len(); i++ )
	{
		string CurrentAssetName = "" + CurrentLevelSpawnList[i];
	    if( CurrentAssetName == CompareAssetStr )
	    {
	    	PreviewAsset = CurrentLevelSpawnList[i];
	    	break;
	    }
	}
	if( PreviewAsset == $"" )
	{
		return false; // Couldn't find a valid asset for the preview
	}

	if( IsValid( ModelPickerSettings.PreviewProp ) )
	{
		// Don't need to recreate preview if it hasn't changed
		if( AssetStr == ModelPickerSettings.LastPreviewedModel )
		{
			return false;
		}

		// Remove old preview model
		ModelPicker_ClearPreview();
	}

	thread ModelPicker_Server_LoadPreview( PreviewAsset, AssetStr );
	return true;
}

void function ModelPicker_Server_LoadPreview( asset PreviewAsset, string PreviewAssetStr )
{
	PrecacheModel( PreviewAsset );
	while( !ModelIsPrecached( PreviewAsset ) )
	{
		wait 0.1;
	}

	entity prop_dynamic = CreateEntity( "prop_dynamic" );
	prop_dynamic.SetValueForModelKey( PreviewAsset );
	prop_dynamic.kv.fadedist = -1;
	prop_dynamic.kv.renderamt = 255;
	prop_dynamic.kv.rendercolor = "255 255 255";
	prop_dynamic.kv.solid = 6; // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
	SetTeam( prop_dynamic, TEAM_BOTH );	// need to have a team other then 0 or it won't take impact damage

	prop_dynamic.SetOrigin( ModelPicker_GetPreviewLocation() );
	prop_dynamic.SetAngles( <0.0, 0.0, 0.0> );
	DispatchSpawn( prop_dynamic );

	// Create a preview position based on size of the prop
	vector BoundMaxs = prop_dynamic.GetBoundingMaxs();
	float BiggestBound = max( fabs(BoundMaxs.x), max( fabs(BoundMaxs.y), fabs(BoundMaxs.z) ) );
	BiggestBound = max( BiggestBound, 50.0 );

	vector Angles = ModelPicker_GetPreviewAngles();
	vector Pos = ModelPicker_GetPreviewLocation() + AnglesToForward( Angles ) * BiggestBound * 2.0;

	prop_dynamic.SetOrigin( Pos );
	prop_dynamic.SetAngles( <0.0, 0.0, 0.0> );

	// Assign prop
	ModelPickerSettings.PreviewProp = prop_dynamic;
	ModelPickerSettings.LastPreviewedModel = PreviewAssetStr;
}

bool function ClientCommand_ModelPicker_ClearPreview( entity player, array<string> args )
{
	ModelPicker_ClearPreview();
	ModelPickerSettings.LastPreviewedModel = "";
	return true;
}

#endif
