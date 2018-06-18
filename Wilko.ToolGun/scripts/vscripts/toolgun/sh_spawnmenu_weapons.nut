
global function Spawnmenu_Init_Weapons

void function Spawnmenu_Init_Weapons()
{
#if SERVER
	RegisterSpawnmenuPage( "weapons", "Weapons" );

	RegisterPageCategory( "weapons", "wep_tools", "Tools", "Spawnmenu_GiveWeapon" );
	RegisterCategoryItem( "wep_tools", "mp_weapon_shotgun_pistol", "Toolgun" );

	RegisterPageCategory( "weapons", "wep_pilot_primary", "Pilot - Primaries", "Spawnmenu_GiveWeapon" );
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_rspn101", "R-201 Carbine");
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_rspn101_og", "R-101 Carbine");
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_hemlok", "Hemlok BF-R");
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_g2", "G2A5");
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_vinson", "V-47 Flatline");
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_car", "CAR");
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_alternator_smg", "Alternator");
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_hemlok_smg", "Volt");
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_r97", "R-47");
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_lmg", "Spitfire");
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_lstar", "L_STAR");
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_esaw", "X-55 Devotion");
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_sniper", "Kraber-AP Sniper");
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_doubletake", "D-2 Double Take");
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_dmr", "Longbow-DMR");
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_shotgun", "EVA-8 Auto");
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_mastiff", "Mastiff");
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_smr", "Sidewinder SMR");
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_epg", "EPG-1");
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_softball", "R-6P Softball");
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_pulse_lmg", "EM-4 Cold War");
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_wingman_n", "Wingman Elite");
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_shotgun_pistol", "SA-3 Mozambique");

	RegisterPageCategory( "weapons", "wep_pilot_secondary", "Pilot - Secondary", "Spawnmenu_GiveWeapon" );
	RegisterCategoryItem( "wep_pilot_secondary", "mp_weapon_semipistol", "Hammond P2016" );
	RegisterCategoryItem( "wep_pilot_secondary", "mp_weapon_autopistol", "RE-45 Auto" );
	RegisterCategoryItem( "wep_pilot_secondary", "mp_weapon_wingman", "B3 Wingman" );
	RegisterCategoryItem( "wep_pilot_secondary", "mp_weapon_defender", "Charge Rifle" );
	RegisterCategoryItem( "wep_pilot_secondary", "mp_weapon_mgl", "MGL Mag Launcher" );
	RegisterCategoryItem( "wep_pilot_secondary", "mp_weapon_arc_launcher", "LG-97 Thunderbolt" );
	RegisterCategoryItem( "wep_pilot_secondary", "mp_weapon_rocket_launcher", "Archer" );

	RegisterPageCategory( "weapons", "wep_pilot_abilities", "Pilot Abilities", "Spawnmenu_GiveAbility" );
	RegisterCategoryItem( "wep_pilot_abilities", "mp_ability_cloak", "Cloak" );
	RegisterCategoryItem( "wep_pilot_abilities", "mp_ability_grapple", "Grapple" );
	RegisterCategoryItem( "wep_pilot_abilities", "mp_ability_heal", "Stim" );
	RegisterCategoryItem( "wep_pilot_abilities", "mp_ability_holopilot", "Holopilot" );
	RegisterCategoryItem( "wep_pilot_abilities", "mp_ability_shifter", "Phase Shift" );
	RegisterCategoryItem( "wep_pilot_abilities", "mp_weapon_grenade_sonar", "Pulse Blade" );
	RegisterCategoryItem( "wep_pilot_abilities", "mp_weapon_deployable_cover", "A-Wall" );
	RegisterCategoryItem( "wep_pilot_abilities", "mp_ability_timeshift", "Timeshift [Effect and Cause]" );
	RegisterCategoryItem( "wep_pilot_abilities", "mp_ability_arc_blast", "Arcblast [Dev]" );
	RegisterCategoryItem( "wep_pilot_abilities", "mp_ability_shifter_super", "Super Phase Shift [Dev]" );

	RegisterPageCategory( "weapons", "wep_pilot_ordnance", "Pilot Ordnances", "Spawnmenu_GiveGrenade" );
	RegisterCategoryItem( "wep_pilot_ordnance", "mp_weapon_frag_grenade", "Frag Grenade" );
	RegisterCategoryItem( "wep_pilot_ordnance", "mp_weapon_thermite_grenade", "Firestar" );
	RegisterCategoryItem( "wep_pilot_ordnance", "mp_weapon_grenade_electric_smoke", "Electric Smoke Grenade" );
	RegisterCategoryItem( "wep_pilot_ordnance", "mp_weapon_grenade_emp", "Arc Grenade" );
	RegisterCategoryItem( "wep_pilot_ordnance", "mp_weapon_grenade_gravity", "Gravity Star" );
	RegisterCategoryItem( "wep_pilot_ordnance", "mp_weapon_satchel", "Satchel" );

	RegisterPageCategory( "weapons", "wep_pilot_melee", "Pilot Melees", "Spawnmenu_GiveMelee" );
	RegisterCategoryItem( "wep_pilot_melee", "melee_pilot_emptyhanded", "Standard Melee" );
	RegisterCategoryItem( "wep_pilot_melee", "melee_pilot_sword", "Sword Melee" );
#endif
}
