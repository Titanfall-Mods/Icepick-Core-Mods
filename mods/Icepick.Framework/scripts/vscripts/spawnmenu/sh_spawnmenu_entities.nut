
global function Spawnmenu_Init_Entities

void function Spawnmenu_Init_Entities()
{
	#if CLIENT
	RegisterSpawnmenuPage( "entities", "Entities" );

	RegisterPageCategory( "entities", "npcs_humans_imc", "Humans (IMC)", "Spawnmenu_SpawnNpc" );
	RegisterCategoryItem( "npcs_humans_imc", "npc_soldier", Localize("#NPC_SOLDIER") );
	RegisterCategoryItem( "npcs_humans_imc", "npc_soldier_shotgun", Localize("#NPC_SOLDIER") + " (Shotgun)" );
	RegisterCategoryItem( "npcs_humans_imc", "npc_soldier_smg", Localize("#NPC_SOLDIER") + " (SMG)" );

	// these need the space on the end otherwise they don't spawn properly????
	RegisterPageCategory( "entities", "npcs_humans_militia", "Humans (Militia)", "Spawnmenu_SpawnNpc" );
	RegisterCategoryItem( "npcs_humans_militia", "npc_soldier#militia", Localize("#NPC_SOLDIER") + " " );
	RegisterCategoryItem( "npcs_humans_militia", "npc_soldier_shotgun#militia", Localize("#NPC_SOLDIER") + " (Shotgun)" + " "  );
	RegisterCategoryItem( "npcs_humans_militia", "npc_soldier_smg#militia", Localize("#NPC_SOLDIER") + " (SMG)" + " "  );
	
	RegisterPageCategory( "entities", "npcs_robots_imc", "Robots (IMC)", "Spawnmenu_SpawnNpc" );
	RegisterCategoryItem( "npcs_robots_imc", "npc_spectre", Localize("#NPC_SPECTRE") );
	RegisterCategoryItem( "npcs_robots_imc", "npc_stalker", Localize("#NPC_STALKER") );
	RegisterCategoryItem( "npcs_robots_imc", "npc_stalker_zombie", Localize("#NPC_STALKER_ZOMBIE") );
	RegisterCategoryItem( "npcs_robots_imc", "npc_stalker_zombie_mossy", Localize("#NPC_STALKER_ZOMBIE_MOSSY") );
	RegisterCategoryItem( "npcs_robots_imc", "npc_super_spectre", Localize("#NPC_SUPER_SPECTRE") );
	RegisterCategoryItem( "npcs_robots_imc", "npc_drone", Localize("#NPC_DRONE") );
	RegisterCategoryItem( "npcs_robots_imc", "npc_drone_rocket", Localize("#NPC_DRONE_ROCKET") );
	RegisterCategoryItem( "npcs_robots_imc", "npc_drone_plasma", Localize("#NPC_DRONE_PLASMA") );
	RegisterCategoryItem( "npcs_robots_imc", "npc_drone_worker", Localize("#NPC_DRONE_WORKER") );
	RegisterCategoryItem( "npcs_robots_imc", "npc_frag_drone", Localize("#WPN_FRAG_DRONE") );

	RegisterPageCategory( "entities", "npcs_robots_militia", "Robots (Militia)", "Spawnmenu_SpawnNpc" );
	RegisterCategoryItem( "npcs_robots_militia", "npc_spectre#militia", Localize("#NPC_SPECTRE") + " " );
	RegisterCategoryItem( "npcs_robots_militia", "npc_stalker#militia", Localize("#NPC_STALKER") + " " );
	RegisterCategoryItem( "npcs_robots_militia", "npc_stalker_zombie#militia", Localize("#NPC_STALKER_ZOMBIE") + " " );
	RegisterCategoryItem( "npcs_robots_militia", "npc_stalker_zombie_mossy#militia", Localize("#NPC_STALKER_ZOMBIE_MOSSY") + " " );
	RegisterCategoryItem( "npcs_robots_militia", "npc_super_spectre#militia", Localize("#NPC_SUPER_SPECTRE") + " " );
	RegisterCategoryItem( "npcs_robots_militia", "npc_drone#militia", Localize("#NPC_DRONE") + " " );
	RegisterCategoryItem( "npcs_robots_militia", "npc_drone_rocket#militia", Localize("#NPC_DRONE_ROCKET") + " " );
	RegisterCategoryItem( "npcs_robots_militia", "npc_drone_plasma#militia", Localize("#NPC_DRONE_PLASMA") + " " );
	RegisterCategoryItem( "npcs_robots_militia", "npc_drone_worker#militia", Localize("#NPC_DRONE_WORKER") + " " );
	RegisterCategoryItem( "npcs_robots_militia", "npc_frag_drone#militia", Localize("#WPN_FRAG_DRONE") + " " );
	
	RegisterPageCategory( "entities", "npcs_titans", "Titans", "Spawnmenu_SpawnTitan" );
	RegisterCategoryItem( "npcs_titans", "npc_titan_atlas_tracker", "Tone" );
	RegisterCategoryItem( "npcs_titans", "npc_titan_atlas_tracker_fd_sniper", "Tone (Sniper)" );
	RegisterCategoryItem( "npcs_titans", "npc_titan_atlas_tracker_mortar", "Tone (Mortar)" );
	RegisterCategoryItem( "npcs_titans", "npc_titan_atlas_tracker_boss_fd", "Tone (Boss)" );
	RegisterCategoryItem( "npcs_titans", "npc_titan_atlas_vanguard", "Monarch" );
	RegisterCategoryItem( "npcs_titans", "npc_titan_atlas_vanguard_boss_fd", "Monarch (Boss)" );
	RegisterCategoryItem( "npcs_titans", "npc_titan_ogre_meteor", "Scorch" );
	RegisterCategoryItem( "npcs_titans", "npc_titan_ogre_meteor_boss_fd", "Scorch (Boss)" );
	RegisterCategoryItem( "npcs_titans", "npc_titan_ogre_meteor_nuke", "Scorch (Nuke)" );
	RegisterCategoryItem( "npcs_titans", "npc_titan_ogre_minigun", "Legion" );
	RegisterCategoryItem( "npcs_titans", "npc_titan_ogre_minigun_boss_fd", "Legion (Boss)" );
	RegisterCategoryItem( "npcs_titans", "npc_titan_ogre_minigun_nuke", "Legion (Nuke)" );
	RegisterCategoryItem( "npcs_titans", "npc_titan_stryder_leadwall", "Ronin" );
	RegisterCategoryItem( "npcs_titans", "npc_titan_stryder_leadwall_arc", "Ronin (Arc)" );
	RegisterCategoryItem( "npcs_titans", "npc_titan_stryder_leadwall_boss_fd", "Ronin (Boss)" );
	RegisterCategoryItem( "npcs_titans", "npc_titan_stryder_leadwall_shift_core", "Ronin (Core)" );
	RegisterCategoryItem( "npcs_titans", "npc_titan_stryder_rocketeer", "Brute" );
	RegisterCategoryItem( "npcs_titans", "npc_titan_stryder_rocketeer_dash_core", "Brute (Boss)" );
	RegisterCategoryItem( "npcs_titans", "npc_titan_stryder_sniper", "Northstar" );
	RegisterCategoryItem( "npcs_titans", "npc_titan_stryder_sniper_boss_fd", "Northstar (Boss)" );
	RegisterCategoryItem( "npcs_titans", "npc_titan_stryder_sniper_fd", "Northstar (Sniper)" );
	RegisterCategoryItem( "npcs_titans", "npc_titan_atlas_stickybomb", "Ion" );
	RegisterCategoryItem( "npcs_titans", "npc_titan_atlas_stickybomb_boss_fd", "Ion (Boss)" );

	RegisterPageCategory( "entities", "npcs_titans_militia", "Titans (Militia)", "Spawnmenu_SpawnTitan" );
	RegisterCategoryItem( "npcs_titans_militia", "npc_titan_atlas_tracker#militia", "Tone" + " " );
	RegisterCategoryItem( "npcs_titans_militia", "npc_titan_atlas_tracker_fd_sniper#militia", "Tone (Sniper)" + " " );
	RegisterCategoryItem( "npcs_titans_militia", "npc_titan_atlas_tracker_mortar#militia", "Tone (Mortar)" + " " );
	RegisterCategoryItem( "npcs_titans_militia", "npc_titan_atlas_tracker_boss_fd#militia", "Tone (Boss)" + " " );
	RegisterCategoryItem( "npcs_titans_militia", "npc_titan_atlas_vanguard#militia", "Monarch" + " " );
	RegisterCategoryItem( "npcs_titans_militia", "npc_titan_atlas_vanguard_boss_fd#militia", "Monarch (Boss)" + " " );
	RegisterCategoryItem( "npcs_titans_militia", "npc_titan_ogre_meteor#militia", "Scorch" + " " );
	RegisterCategoryItem( "npcs_titans_militia", "npc_titan_ogre_meteor_boss_fd#militia", "Scorch (Boss)" + " " );
	RegisterCategoryItem( "npcs_titans_militia", "npc_titan_ogre_minigun#militia", "Legion" + " " );
	RegisterCategoryItem( "npcs_titans_militia", "npc_titan_ogre_minigun_boss_fd#militia", "Legion (Boss)" + " " );
	RegisterCategoryItem( "npcs_titans_militia", "npc_titan_ogre_minigun_nuke#militia", "Legion (Nuke)" + " " );
	RegisterCategoryItem( "npcs_titans_militia", "npc_titan_stryder_leadwall#militia", "Ronin" + " " );
	RegisterCategoryItem( "npcs_titans_militia", "npc_titan_stryder_leadwall_arc#militia", "Ronin (Arc)" + " " );
	RegisterCategoryItem( "npcs_titans_militia", "npc_titan_stryder_leadwall_boss_fd#militia", "Ronin (Boss)" + " " );
	RegisterCategoryItem( "npcs_titans_militia", "npc_titan_stryder_leadwall_shift_core#militia", "Ronin (Core)" + " " );
	RegisterCategoryItem( "npcs_titans_militia", "npc_titan_stryder_rocketeer#militia", "Brute" + " " );
	RegisterCategoryItem( "npcs_titans_militia", "npc_titan_stryder_rocketeer_dash_core#militia", "Brute (Boss)" + " " );
	RegisterCategoryItem( "npcs_titans_militia", "npc_titan_stryder_sniper#militia", "Northstar" + " " );
	RegisterCategoryItem( "npcs_titans_militia", "npc_titan_stryder_sniper_boss_fd#militia", "Northstar (Boss)" + " " );
	RegisterCategoryItem( "npcs_titans_militia", "npc_titan_stryder_sniper_fd#militia", "Northstar (Sniper)" + " " );
	RegisterCategoryItem( "npcs_titans_militia", "npc_titan_atlas_stickybomb#militia", "Ion" + " " );
	RegisterCategoryItem( "npcs_titans_militia", "npc_titan_atlas_stickybomb_boss_fd#militia", "Ion (Boss)" + " " );

	RegisterPageCategory( "entities", "npcs_bosses", "Bosses", "Spawnmenu_SpawnBossTitan" );
	RegisterCategoryItem( "npcs_bosses", "Kane", Localize("#BOSSNAME_KANE") );
	RegisterCategoryItem( "npcs_bosses", "Ash", Localize("#BOSSNAME_ASH") );
	RegisterCategoryItem( "npcs_bosses", "Richter", Localize("#BOSSNAME_RICHTER") );
	RegisterCategoryItem( "npcs_bosses", "Viper", Localize("#BOSSNAME_VIPER") );
	RegisterCategoryItem( "npcs_bosses", "Slone", Localize("#BOSSNAME_SLONE") );
	RegisterCategoryItem( "npcs_bosses", "Blisk", Localize("#BOSSNAME_BLISK") );
	#endif
}
