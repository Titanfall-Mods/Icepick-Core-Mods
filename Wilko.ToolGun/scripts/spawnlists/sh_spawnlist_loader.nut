
// Code chunk to include that will load the listed models and ignore any ones that we know can cause crashes

array<string> PotentialCrashes = [
	"_anims_workspace.mdl",
	"_reactions.mdl",
	"_core.mdl",
	"_traverse.mdl",
	"_scripted.mdl",
	"_synced.mdl",

	// Specific models that always cause crashes
	"models/vehicle/dropship/dropship_common.mdl",
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
];

// Iterate all models
for( int i = PrecacheList.len() - 1; i >= 0; --i )
{
	print( "Load model: " + i + " (" + PrecacheList[i] + ")" );
	bool bPrecache = true;

	// Look to see if we should skip loading this asset
	string AssetName = "" + PrecacheList[i];
	for( int k = 0; k < PotentialCrashes.len(); ++k )
	{
		if( AssetName.find( PotentialCrashes[k] ) != null )
		{
			print("... skipping, contains potential crash! (" + PotentialCrashes[k] + ")")
			bPrecache = false;
			PrecacheList.remove( i );
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
		print("... done!");
	}
}

// Update the spawn list
CurrentLevelSpawnList = PrecacheList;
