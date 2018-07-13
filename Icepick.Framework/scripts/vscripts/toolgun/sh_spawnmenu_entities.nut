
global function Spawnmenu_Init_Entities

void function Spawnmenu_Init_Entities()
{
	#if CLIENT
	RegisterSpawnmenuPage( "entities", "Entities" );

	RegisterPageCategory( "entities", "npcs_humans", "Humans", "Spawnmenu_SpawnNpc" );
	RegisterCategoryItem( "npcs_humans", "npc_soldier", Localize("#NPC_SOLDIER") );
	RegisterCategoryItem( "npcs_humans", "npc_soldier_shotgun", Localize("#NPC_SOLDIER") + " (Shotgun)" );
	RegisterCategoryItem( "npcs_humans", "npc_soldier_smg", Localize("#NPC_SOLDIER") + " (SMG)" );

	RegisterPageCategory( "entities", "npcs_robots", "Robots", "Spawnmenu_SpawnNpc" );
	RegisterCategoryItem( "npcs_robots", "npc_spectre", Localize("#NPC_SPECTRE") );
	RegisterCategoryItem( "npcs_robots", "npc_stalker", Localize("#NPC_STALKER") );
	RegisterCategoryItem( "npcs_robots", "npc_stalker_zombie", Localize("#NPC_STALKER_ZOMBIE") );
	RegisterCategoryItem( "npcs_robots", "npc_stalker_zombie_mossy", Localize("#NPC_STALKER_ZOMBIE_MOSSY") );
	RegisterCategoryItem( "npcs_robots", "npc_super_spectre", Localize("#NPC_SUPER_SPECTRE") );
	RegisterCategoryItem( "npcs_robots", "npc_drone", Localize("#NPC_DRONE") );
	RegisterCategoryItem( "npcs_robots", "npc_drone_rocket", Localize("#NPC_DRONE_ROCKET") );
	RegisterCategoryItem( "npcs_robots", "npc_drone_plasma", Localize("#NPC_DRONE_PLASMA") );
	RegisterCategoryItem( "npcs_robots", "npc_drone_worker", Localize("#NPC_DRONE_WORKER") );
	RegisterCategoryItem( "npcs_robots", "npc_frag_drone", Localize("#WPN_FRAG_DRONE") );
	RegisterCategoryItem( "npcs_robots", "npc_marvin", Localize("#NPC_MARVIN") );
	#endif
}
