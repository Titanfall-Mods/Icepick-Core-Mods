
global function Spawnmenu_Init_Entities

void function Spawnmenu_Init_Entities()
{
	#if CLIENT
	RegisterSpawnmenuPage( "entities", "Entities" );

	RegisterPageCategory( "entities", "npcs_humans", "Humans", "Spawnmenu_SpawnNpc" );
	RegisterCategoryItem( "npcs_humans", "npc_soldier", "Rifle Grunt" );
	RegisterCategoryItem( "npcs_humans", "npc_soldier_shotgun", "Shotgun Grunt" );
	RegisterCategoryItem( "npcs_humans", "npc_soldier_smg", "SMG Grunt" );

	RegisterPageCategory( "entities", "npcs_robots", "Robots", "Spawnmenu_SpawnNpc" );
	RegisterCategoryItem( "npcs_robots", "npc_spectre", "Spectre" );
	RegisterCategoryItem( "npcs_robots", "npc_stalker", "Stalker" );
	RegisterCategoryItem( "npcs_robots", "npc_stalker_zombie", "Zombie Stalker" );
	RegisterCategoryItem( "npcs_robots", "npc_stalker_zombie_mossy", "Zombie Stalker (Mossy)" );
	RegisterCategoryItem( "npcs_robots", "npc_super_spectre", "Reaper" );
	RegisterCategoryItem( "npcs_robots", "npc_drone", "Drone" );
	RegisterCategoryItem( "npcs_robots", "npc_drone_rocket", "Rocket Drone" );
	RegisterCategoryItem( "npcs_robots", "npc_drone_plasma", "Plasma Drone" );
	RegisterCategoryItem( "npcs_robots", "npc_drone_worker", "Worker Drone" );
	RegisterCategoryItem( "npcs_robots", "npc_frag_drone", "Tick" );
	RegisterCategoryItem( "npcs_robots", "npc_marvin", "Marvin" );

	RegisterPageCategory( "entities", "npcs_titans", "Titans", "Spawnmenu_SpawnNpc" );
	RegisterCategoryItem( "npcs_titans", "npc_titan_bt", "BT-7274" );
	RegisterCategoryItem( "npcs_titans", "npc_titan_bt_spare", "BT-7274 2" );
	RegisterCategoryItem( "npcs_titans", "npc_titan_atlas", "Atlas" );
	RegisterCategoryItem( "npcs_titans", "npc_titan_stryder", "Stryder" );
	RegisterCategoryItem( "npcs_titans", "npc_titan_ogre", "Ogre" );
	#endif
}
