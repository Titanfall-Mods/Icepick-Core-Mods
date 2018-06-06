global function ModelPicker_Server_Init;

global struct ModelPickerSettingsStruct
{
	entity CameraOverride,
	entity PreviewProp,
	string LastPreviewedModel
};

global ModelPickerSettingsStruct ModelPickerSettings;

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
	switch( GetMapName() )
	{
		case "sp_boomtown_start":
			return < 11655.3, -8851.05, 10683.07 >;
		case "mp_black_water_canal":
			return < 88.1168, 5288.33, 1555.969 >;
		case "mp_grave":
			return < 5433.05, -4426.21, 3877.47 >;
		case "mp_crashsite3":
			return < -8343.11, -3094.12, 2218.41 >;
		case "mp_complex3":
			return < -805.766, 3449.01, 2808.385 >;
		case "mp_drydock":
			return < 1682.05, -10180.9, 1101.8 >;
		case "mp_eden":
			return < -6403.65, -2748.85, 2803.27 >;
		case "mp_thaw":
			return < 3880.11, -4584.75, 1249.053 >;
		case "mp_forwardbase_kodai":
			return < 3451.86, 1384.98, 3927.44 >;
		case "mp_homestead":
			return < 5716.53, 3623.48, 4570.34 >;
		case "mp_colony02":
			return < -2235.56, -3248.43, 4365.329 >;
		case "mp_angel_city":
			return < 2131.72, 4069.52, 4672.031 >;
		case "mp_glitch":
			return < -3952.24, -2269.55, 2688.031 >;
		case "mp_relic02":
			return < 5121.97, -6259.3, 2337.787 >;
		case "mp_wargames":
			return < -702.811, -635.186, 1920.03 >;
		case "mp_rise":
			return < 2402.45, 3702.15, 1278.031 >;
		case "mp_lf_stacks":
			return < 968.648, 1975.66, 496.031 >;
		case "mp_lf_meadow":
			return < 404.394, -658.635, 544.407 >;
		case "mp_lf_township":
			return < -443.169, 584.615, 463.126 >;
		case "mp_lf_deck":
			return < -211.785, 1655.26, 472.031 >;
		case "mp_lf_traffic":
			return < 1192.02, 1889.8, 493.73 >;
		case "mp_lf_uma":
			return < 645.804, -1407.35, 428.031 >;
		case "mp_coliseum":
			return < -394.56, 778.094, 600.96875 >;
		case "mp_coliseum_column":
			return < 785.444, 630.161, 600.14665 >;
	}
	return < 0.0, 0.0, 0.0 >;
}

vector function ModelPicker_GetPreviewAngles()
{
	switch( GetMapName() )
	{
		case "sp_boomtown_start":
			return < 28.1506, 167.353, 0.0 >;
		case "mp_black_water_canal":
			return < 35.1524, -90.6716, 0.0 >;
		case "mp_grave":
			return < 23.7806, 162.243, 0.0 >;
		case "mp_crashsite3":
			return < 35.2903, 126.539, 0.0 >;
		case "mp_complex3":
			return < 6.79972, 88.9815, 0.0 >;
		case "mp_drydock":
			return < 17.0187, -76.4908, 0.0 >;
		case "mp_eden":
			return < 15.5712, 137.405, 0.0 >;
		case "mp_thaw":
			return < 22.6431, -39.7904, 0.0 >;
		case "mp_forwardbase_kodai":
			return < 31.043, 41.4838, 0.0 >;
		case "mp_homestead":
			return < 16.2512, -125.091, 0.0 >;
		case "mp_colony02":
			return < 14.8233, 51.1735, 0.0 >;
		case "mp_angel_city":
			return < 11.3555, -135.474, 0.0 >;
		case "mp_glitch":
			return < 20.3893, 40.4784, 0.0 >;
		case "mp_relic02":
			return < 13.4633, 135.764, 0.0 >;
		case "mp_wargames":
			return < 31.4717, -48.5798, 0.0 >;
		case "mp_rise":
			return < 26.646, -112.061, 0.0 >;
		case "mp_lf_stacks":
			return < 14.9593, -139.36, 0.0 >;
		case "mp_lf_meadow":
			return < 15.4353, -104.461, 0.0 >;
		case "mp_lf_township":
			return < 21.4869, 32.2982, 0.0 >;
		case "mp_lf_deck":
			return < 18.5359, -41.0362, 0.0 >;
		case "mp_lf_traffic":
			return < 12.4434, -138.981, 0.0 >;
		case "mp_lf_uma":
			return < 19.651, 143.627, 0.0 >;
		case "mp_coliseum":
			return < 19.651, -63.0053, 0.0 >;
		case "mp_coliseum_column":
			return < 19.0272, -139.698, 0.0 >;
	}
	return < 0.0, 0.0, 0.0 >;
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

	EnableExternalSpawnMode();

	PrecacheModel( PreviewAsset );

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

	DisableExternalSpawnMode();

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
	ModelPickerSettings.LastPreviewedModel = AssetStr;

	return true;
}

bool function ClientCommand_ModelPicker_ClearPreview( entity player, array<string> args )
{
	ModelPicker_ClearPreview();
	ModelPickerSettings.LastPreviewedModel = "";
	return true;
}
