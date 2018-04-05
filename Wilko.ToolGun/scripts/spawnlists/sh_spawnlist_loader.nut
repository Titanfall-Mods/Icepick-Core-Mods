
// Code chunk to include that will load the listed models and ignore any ones that we know can cause crashes

bool PrintPrecacheLoading = true;
bool PrecacheSafeMode = true; // Dev setting for creating reliable spawnlists
array<string> PotentialCrashes = [
	"_anims_workspace.mdl",
	"_reactions.mdl",
	"_core.mdl",
	"_traverse.mdl",
	"_scripted.mdl",
	"_synced.mdl",

	// Specific models that always cause crashes
	"models/vehicle/dropship/dropship_common.mdl",
	"models/weapons/arms/petepov_workspace.mdl",
	"models/humans/pete/pilot_shared.mdl",
	"models/humans/pete/pete_agents.mdl",
	"models/humans/pete/pete_core.mdl",
	"models/humans/pete/pete_menu.mdl",
	"models/humans/pete/pete_poses.mdl",
	"models/humans/pete/pete_reactions.mdl",
	"models/humans/pete/pete_scripted.mdl",
	"models/humans/pete/pete_scripted_beacon.mdl",
	"models/humans/pete/pete_scripted_boss_intros.mdl",
	"models/humans/pete/pete_scripted_intro.mdl",
	"models/humans/pete/pete_scripted_r1.mdl",
	"models/humans/pete/pete_scripted_sewers.mdl",
	"models/humans/pete/pete_scripted_ship2ship.mdl",
	"models/humans/pete/pete_scripted_skyway.mdl",
	"models/humans/pete/pete_scripted_timeshift.mdl",
	"models/humans/pete/pete_scripted_wilds.mdl",
	"models/humans/pete/pete_skits.mdl",
	"models/weapons/arms/pov_pete_core.mdl"
	"models/robots/marvin/marvin_anims.mdl",
	"models/titans/medium/titan_medium_anims_workspace.mdl", 
	"models/titans/medium/titan_medium_battery_static.mdl", 
	"models/titans/medium/titan_medium_mp_core.mdl", 
	"models/titans/medium/titan_medium_mp_embark.mdl", 
	"models/titans/medium/titan_medium_mp_hotdrop_ajax.mdl", 
	"models/titans/medium/titan_medium_mp_hotdrop_wraith.mdl", 
	"models/titans/medium/titan_medium_mp_melee.mdl", 
	"models/titans/medium/titan_medium_mp_reactions.mdl", 
	"models/titans/medium/titan_medium_mp_scripted.mdl", 
	"models/titans/medium/titan_medium_mp_synced.mdl", 
	"models/titans/medium/titan_medium_rodeo_battery.mdl", 
	"models/titans/medium/titan_medium_sp_core.mdl", 
	"models/titans/light/titan_light_anims_workspace.mdl", 
	"models/titans/light/titan_light_mp_core.mdl", 
	"models/titans/light/titan_light_mp_embark.mdl", 
	"models/titans/light/titan_light_mp_melee.mdl", 
	"models/titans/light/titan_light_mp_reactions.mdl", 
	"models/titans/light/titan_light_mp_scripted.mdl", 
	"models/titans/light/titan_light_mp_synced.mdl", 
	"models/titans/light/titan_light_rodeo_battery.mdl", 
	"models/titans/light/titan_light_sp_core.mdl",
	"models/titans/heavy/titan_heavy_anims_workspace.mdl", 
	"models/titans/heavy/titan_heavy_mp_core.mdl", 
	"models/titans/heavy/titan_heavy_mp_embark.mdl", 
	"models/titans/heavy/titan_heavy_mp_melee.mdl", 
	"models/titans/heavy/titan_heavy_mp_reactions.mdl", 
	"models/titans/heavy/titan_heavy_mp_scripted.mdl", 
	"models/titans/heavy/titan_heavy_mp_synced.mdl", 
	"models/titans/heavy/titan_heavy_rodeo_battery.mdl", 
	"models/titans/heavy/titan_heavy_sp_core.mdl", 
	"models/titans/buddy/titan_buddy_anims_workspace.mdl", 
	"models/titans/buddy/titan_buddy_embark.mdl", 
	"models/titans/buddy/titan_buddy_melee.mdl", 
	"models/titans/buddy/titan_buddy_mp_core.mdl", 
	"models/titans/buddy/titan_buddy_reactions.mdl", 
	"models/titans/buddy/titan_buddy_scripted.mdl", 
	"models/titans/buddy/titan_buddy_scripted_beacon.mdl", 
	"models/titans/buddy/titan_buddy_scripted_s2s.mdl", 
	"models/titans/buddy/titan_buddy_scripted_timeshift.mdl", 
	"models/titans/buddy/titan_buddy_scripted_wilds.mdl", 
	"models/titans/buddy/titan_buddy_sp_core.mdl", 
	"models/vehicle/straton/straton_anims.mdl", 
];

// Iterate all models
for( int i = PrecacheList.len() - 1; i >= 0; --i )
{
	if( PrintPrecacheLoading )
	{
		print( "Load model: " + i + " (" + PrecacheList[i] + ")" );
	}
	bool bPrecache = true;

	// Look to see if we should skip loading this asset
	if( PrecacheSafeMode )
	{
		string AssetName = "" + PrecacheList[i];
		for( int k = 0; k < PotentialCrashes.len(); ++k )
		{
			if( AssetName.find( PotentialCrashes[k] ) != null )
			{
				if( PrintPrecacheLoading )
				{
					print("... skipping, contains potential crash! (" + PotentialCrashes[k] + ")")
				}
				bPrecache = false;
				PrecacheList.remove( i );
			}
		}
	}

	// Precache the asset
	if( bPrecache )
	{
		#if SERVER
		if( !ModelIsPrecached( PrecacheList[i] ) )
		{
			PrecacheModel( PrecacheList[i] );
		}
		#endif
		if( PrintPrecacheLoading )
		{
			print("... done!");
		}
	}
}

// Update the spawn list
CurrentLevelSpawnList = PrecacheList;
