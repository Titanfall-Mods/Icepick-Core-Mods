global function SpawnList_Shared_Init

void function SpawnList_Shared_Init()
{
	bool bLoadPrecompiledSpawnlist = true;
	if( bLoadPrecompiledSpawnlist )
	{
		SpawnList_Shared_LoadCompiledSpawnlist(); // Use the precompiled spawn list that loads fast
	}
	else
	{
		//SpawnList_Shared_SlowLoadSpawnlist(); // Compile a spawnlist from individual maps spawnlists
	}
}

// void function SpawnList_Shared_SlowLoadSpawnlist()
// {
// 	array<asset> PrecacheList = [];
// 	CurrentLevelSpawnList.clear();

// 	// Define these outside of sh_spawnlist_loader as otherwise causes issues with too many locals
// 	string AssetName = "";
// 	bool bPrecache = true;
// 	bool bPreexists = false;
// 	string ExistingAssetName = "";

// 	bool PrintPrecacheLoading = true;
// 	bool PrecacheSafeMode = true; // Dev setting for creating reliable spawnlists
// 	array<string> PotentialCrashes = [
// 		"_anims_workspace.mdl",
// 		"_reactions.mdl",
// 		"_core.mdl",
// 		"_traverse.mdl",
// 		"_scripted.mdl",
// 		"_synced.mdl",

// 		// Specific models that always cause crashes
// 		"models/vehicle/dropship/dropship_common.mdl",
// 		"models/weapons/arms/petepov_workspace.mdl",
// 		"models/humans/pete/pilot_shared.mdl",
// 		"models/humans/pete/pete_agents.mdl",
// 		"models/humans/pete/pete_core.mdl",
// 		"models/humans/pete/pete_menu.mdl",
// 		"models/humans/pete/pete_poses.mdl",
// 		"models/humans/pete/pete_reactions.mdl",
// 		"models/humans/pete/pete_scripted.mdl",
// 		"models/humans/pete/pete_scripted_beacon.mdl",
// 		"models/humans/pete/pete_scripted_boss_intros.mdl",
// 		"models/humans/pete/pete_scripted_intro.mdl",
// 		"models/humans/pete/pete_scripted_r1.mdl",
// 		"models/humans/pete/pete_scripted_sewers.mdl",
// 		"models/humans/pete/pete_scripted_ship2ship.mdl",
// 		"models/humans/pete/pete_scripted_skyway.mdl",
// 		"models/humans/pete/pete_scripted_timeshift.mdl",
// 		"models/humans/pete/pete_scripted_wilds.mdl",
// 		"models/humans/pete/pete_skits.mdl",
// 		"models/weapons/arms/pov_pete_core.mdl"
// 		"models/robots/marvin/marvin_anims.mdl",
// 		"models/titans/medium/titan_medium_anims_workspace.mdl", 
// 		"models/titans/medium/titan_medium_battery_static.mdl", 
// 		"models/titans/medium/titan_medium_mp_core.mdl", 
// 		"models/titans/medium/titan_medium_mp_embark.mdl", 
// 		"models/titans/medium/titan_medium_mp_hotdrop_ajax.mdl", 
// 		"models/titans/medium/titan_medium_mp_hotdrop_wraith.mdl", 
// 		"models/titans/medium/titan_medium_mp_melee.mdl", 
// 		"models/titans/medium/titan_medium_mp_reactions.mdl", 
// 		"models/titans/medium/titan_medium_mp_scripted.mdl", 
// 		"models/titans/medium/titan_medium_mp_synced.mdl", 
// 		"models/titans/medium/titan_medium_rodeo_battery.mdl", 
// 		"models/titans/medium/titan_medium_sp_core.mdl", 
// 		"models/titans/light/titan_light_anims_workspace.mdl", 
// 		"models/titans/light/titan_light_mp_core.mdl", 
// 		"models/titans/light/titan_light_mp_embark.mdl", 
// 		"models/titans/light/titan_light_mp_melee.mdl", 
// 		"models/titans/light/titan_light_mp_reactions.mdl", 
// 		"models/titans/light/titan_light_mp_scripted.mdl", 
// 		"models/titans/light/titan_light_mp_synced.mdl", 
// 		"models/titans/light/titan_light_rodeo_battery.mdl", 
// 		"models/titans/light/titan_light_sp_core.mdl",
// 		"models/titans/heavy/titan_heavy_anims_workspace.mdl", 
// 		"models/titans/heavy/titan_heavy_mp_core.mdl", 
// 		"models/titans/heavy/titan_heavy_mp_embark.mdl", 
// 		"models/titans/heavy/titan_heavy_mp_melee.mdl", 
// 		"models/titans/heavy/titan_heavy_mp_reactions.mdl", 
// 		"models/titans/heavy/titan_heavy_mp_scripted.mdl", 
// 		"models/titans/heavy/titan_heavy_mp_synced.mdl", 
// 		"models/titans/heavy/titan_heavy_rodeo_battery.mdl", 
// 		"models/titans/heavy/titan_heavy_sp_core.mdl", 
// 		"models/titans/buddy/titan_buddy_anims_workspace.mdl", 
// 		"models/titans/buddy/titan_buddy_embark.mdl", 
// 		"models/titans/buddy/titan_buddy_melee.mdl", 
// 		"models/titans/buddy/titan_buddy_mp_core.mdl", 
// 		"models/titans/buddy/titan_buddy_reactions.mdl", 
// 		"models/titans/buddy/titan_buddy_scripted.mdl", 
// 		"models/titans/buddy/titan_buddy_scripted_beacon.mdl", 
// 		"models/titans/buddy/titan_buddy_scripted_s2s.mdl", 
// 		"models/titans/buddy/titan_buddy_scripted_timeshift.mdl", 
// 		"models/titans/buddy/titan_buddy_scripted_wilds.mdl", 
// 		"models/titans/buddy/titan_buddy_sp_core.mdl", 
// 		"models/vehicle/straton/straton_anims.mdl", 
// 	];

// 	// #include scripts/spawnlists/sp_training.nut
// 	// #include scripts/spawnlists/sp_crashsite.nut
// 	// #include scripts/spawnlists/sp_sewers1.nut
// 	// #include scripts/spawnlists/sp_boomtown.nut
// 	// #include scripts/spawnlists/sp_timeshift_spoke.nut
// 	// #include scripts/spawnlists/sp_beacon_spoke0.nut
// 	// #include scripts/spawnlists/sp_tday.nut
// 	// #include scripts/spawnlists/sp_s2s.nut
// 	// #include scripts/spawnlists/sp_skyway_v1.nut

// 	// #include scripts/spawnlists/mp_angel_city.nut
// 	// #include scripts/spawnlists/mp_black_water_canal.nut
// 	// #include scripts/spawnlists/mp_coliseum.nut
// 	// #include scripts/spawnlists/mp_coliseum_columns.nut
// 	// #include scripts/spawnlists/mp_colony.nut
// 	// #include scripts/spawnlists/mp_common.nut
// 	// #include scripts/spawnlists/mp_complex.nut
// 	// #include scripts/spawnlists/mp_crashsite.nut
// 	// #include scripts/spawnlists/mp_drydock.nut
// 	// #include scripts/spawnlists/mp_eden.nut
// 	// #include scripts/spawnlists/mp_forward_base_kodai.nut
// 	// #include scripts/spawnlists/mp_glitch.nut
// 	// #include scripts/spawnlists/mp_grave.nut
// 	// #include scripts/spawnlists/mp_homestead.nut
// 	// #include scripts/spawnlists/mp_lf_deck.nut
// 	// #include scripts/spawnlists/mp_lf_meadow.nut
// 	// #include scripts/spawnlists/mp_lf_stacks.nut
// 	// #include scripts/spawnlists/mp_lf_township.nut
// 	// #include scripts/spawnlists/mp_lf_traffic.nut
// 	// #include scripts/spawnlists/mp_relic.nut
// 	// #include scripts/spawnlists/mp_rise.nut
// 	// #include scripts/spawnlists/mp_thaw.nut
// 	// #include scripts/spawnlists/mp_wargames.nut

// 	CurrentLevelSpawnList.sort( SortAssetAlphabetize );

// 	// Export
// 	DevTextBufferClear()
// 	DevTextBufferWrite( "\n" );
// 	DevTextBufferWrite( "PrecacheList = [\n" );
// 	for( int i = 0; i < CurrentLevelSpawnList.len(); ++i )
// 	{
// 		DevTextBufferWrite( "\t" + CurrentLevelSpawnList[i] + ",\n" );
// 	}
// 	DevTextBufferWrite( "];\n" );
// 	DevTextBufferDumpToFile( "../spmp_compiled_spawn_list.txt" );

// }
