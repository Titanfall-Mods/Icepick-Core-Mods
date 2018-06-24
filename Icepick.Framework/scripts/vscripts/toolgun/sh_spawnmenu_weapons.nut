
global function Spawnmenu_Init_Weapons

void function Spawnmenu_Init_Weapons()
{
#if CLIENT
	RegisterSpawnmenuPage( "weapons", "Weapons" );

	RegisterPageCategory( "weapons", "wep_tools", "Tools", "Spawnmenu_GiveWeapon" );
	RegisterCategoryItem( "wep_tools", "mp_weapon_shotgun_pistol", "Toolgun" );

	RegisterPageCategory( "weapons", "wep_pilot_primary", "Pilot - Primaries", "Spawnmenu_GiveWeapon" );
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_rspn101", Localize("#WPN_RSPN101") );
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_rspn101_og", Localize("#WPN_RSPN101_OG") );
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_hemlok", Localize("#WPN_HEMLOK") );
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_g2", Localize("#WPN_G2") );
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_vinson", Localize("#WPN_VINSON") );
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_car", Localize("#WPN_CAR") );
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_alternator_smg", Localize("#WPN_ALTERNATOR_SMG") );
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_hemlok_smg", Localize("#WPN_HEMLOK_SMG") );
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_r97", Localize("#WPN_R97") );
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_lmg", Localize("#WPN_LMG") );
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_lstar", Localize("#WPN_LSTAR") );
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_esaw", Localize("#WPN_ESAW") );
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_sniper", Localize("#WPN_SNIPER") );
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_doubletake", Localize("#WPN_SNIPER") );
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_dmr", Localize("#WPN_DMR") );
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_shotgun", Localize("#WPN_SHOTGUN") );
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_mastiff", Localize("#WPN_MASTIFF") );
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_smr", Localize("#WPN_SMR") );
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_epg", Localize("#WPN_EPG") );
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_softball", Localize("#WPN_SOFTBALL") );
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_pulse_lmg", Localize("#WPN_PULSE_LMG") );
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_wingman_n", Localize("#WPN_WINGMAN_N") );
	RegisterCategoryItem( "wep_pilot_primary", "mp_weapon_shotgun_pistol", Localize("#WPN_SHOTGUN_PISTOL") );

	RegisterPageCategory( "weapons", "wep_pilot_secondary", "Pilot - Secondary", "Spawnmenu_GiveWeapon" );
	RegisterCategoryItem( "wep_pilot_secondary", "mp_weapon_semipistol", Localize("#WPN_P2011") );
	RegisterCategoryItem( "wep_pilot_secondary", "mp_weapon_autopistol", Localize("#WPN_RE45_AUTOPISTOL") );
	RegisterCategoryItem( "wep_pilot_secondary", "mp_weapon_wingman", Localize("#WPN_WINGMAN") );
	RegisterCategoryItem( "wep_pilot_secondary", "mp_weapon_defender", Localize("#WPN_CHARGE_RIFLE") );
	RegisterCategoryItem( "wep_pilot_secondary", "mp_weapon_mgl", Localize("#WPN_MGL") );
	RegisterCategoryItem( "wep_pilot_secondary", "mp_weapon_arc_launcher", Localize("#WPN_ARC_LAUNCHER") );
	RegisterCategoryItem( "wep_pilot_secondary", "mp_weapon_rocket_launcher", Localize("#WPN_ROCKET_LAUNCHER") );

	RegisterPageCategory( "weapons", "wep_pilot_abilities", "Pilot Abilities", "Spawnmenu_GiveAbility" );
	RegisterCategoryItem( "wep_pilot_abilities", "mp_ability_cloak", Localize("#WPN_CLOAK") );
	RegisterCategoryItem( "wep_pilot_abilities", "mp_ability_grapple", Localize("#WPN_GRAPPLE") );
	RegisterCategoryItem( "wep_pilot_abilities", "mp_ability_heal", Localize("#WPN_STIM") );
	RegisterCategoryItem( "wep_pilot_abilities", "mp_ability_holopilot", Localize("#WPN_HOLOPILOT") );
	RegisterCategoryItem( "wep_pilot_abilities", "mp_ability_holopilot_nova", Localize("#WPN_HOLOPILOT_NOVA") );
	RegisterCategoryItem( "wep_pilot_abilities", "mp_ability_shifter", Localize("#WPN_SHIFTER") );
	RegisterCategoryItem( "wep_pilot_abilities", "mp_weapon_grenade_sonar", Localize("#WPN_GRENADE_SONAR") );
	RegisterCategoryItem( "wep_pilot_abilities", "mp_weapon_deployable_cover", Localize("#WPN_DEPLOYABLE_COVER") );
	RegisterCategoryItem( "wep_pilot_abilities", "mp_ability_timeshift", "Timeshift [Effect and Cause]" );
	RegisterCategoryItem( "wep_pilot_abilities", "mp_ability_arc_blast", "Arcblast [Dev]" );
	RegisterCategoryItem( "wep_pilot_abilities", "mp_ability_shifter_super", "Super Phase Shift [Dev]" );

	RegisterPageCategory( "weapons", "wep_pilot_ordnance", "Pilot Ordnances", "Spawnmenu_GiveGrenade" );
	RegisterCategoryItem( "wep_pilot_ordnance", "mp_weapon_frag_grenade", Localize("#WPN_FRAG_GRENADE") );
	RegisterCategoryItem( "wep_pilot_ordnance", "mp_weapon_thermite_grenade", Localize("#WPN_THERMITE_GRENADE") );
	RegisterCategoryItem( "wep_pilot_ordnance", "mp_weapon_grenade_electric_smoke", Localize("#WPN_GRENADE_ELECTRIC_SMOKE") );
	RegisterCategoryItem( "wep_pilot_ordnance", "mp_weapon_grenade_emp", Localize("#WPN_GRENADE_EMP") );
	RegisterCategoryItem( "wep_pilot_ordnance", "mp_weapon_grenade_gravity", Localize("#WPN_GRENADE_GRAVITY") );
	RegisterCategoryItem( "wep_pilot_ordnance", "mp_weapon_satchel", Localize("#WPN_SATCHEL") );

	RegisterPageCategory( "weapons", "wep_pilot_melee", "Pilot Melees", "Spawnmenu_GiveMelee" );
	RegisterCategoryItem( "wep_pilot_melee", "melee_pilot_emptyhanded", "Fists" );
	RegisterCategoryItem( "wep_pilot_melee", "melee_pilot_sword", "Sword" );

	RegisterPageCategory( "weapons", "wep_titan_defensive", "Titan Defensive Abilities", "Spawnmenu_GiveTitanDefensive" );
	RegisterCategoryItem( "wep_titan_defensive", "mp_titanability_gun_shield", Localize("#WPN_TITAN_GUN_SHIELD") );
	RegisterCategoryItem( "wep_titan_defensive", "mp_titanweapon_vortex_shield", Localize("#WPN_TITAN_VORTEX_SHIELD") );
	RegisterCategoryItem( "wep_titan_defensive", "mp_titanweapon_heat_shield", Localize("#WPN_TITAN_HEAT_SHIELD") );
	RegisterCategoryItem( "wep_titan_defensive", "mp_titanability_tether_trap", Localize("#WPN_TITAN_TETHER_TRAP") );
	RegisterCategoryItem( "wep_titan_defensive", "mp_titanability_basic_block", Localize("#WPN_TITAN_BASIC_BLOCK") );
	RegisterCategoryItem( "wep_titan_defensive", "mp_titanability_particle_wall", Localize("#WPN_TITAN_SHIELD_WALL") );
	RegisterCategoryItem( "wep_titan_defensive", "mp_titanweapon_stun_laser", Localize("#WPN_TITAN_STUN_LASER") );
	RegisterCategoryItem( "wep_titan_defensive", "mp_titanability_timeshift", "Timeshift [Effect and Cause]" );

	RegisterPageCategory( "weapons", "wep_titan_ordnance", "Titan Ordnances", "Spawnmenu_GiveGrenade" );
	RegisterCategoryItem( "wep_titan_ordnance", "mp_titanweapon_flame_wall", Localize("#WPN_TITAN_FIREWALL") );
	RegisterCategoryItem( "wep_titan_ordnance", "mp_titanweapon_laser_lite", Localize("#WPN_TITAN_LASER_LITE") );
	RegisterCategoryItem( "wep_titan_ordnance", "mp_titanweapon_arc_wave", Localize("#WPN_TITAN_ARC_WAVE") );
	RegisterCategoryItem( "wep_titan_ordnance", "mp_titanweapon_tracker_rockets", Localize("#WPN_TITAN_TRACKER_ROCKETS") );
	RegisterCategoryItem( "wep_titan_ordnance", "mp_titanweapon_dumbfire_rockets", Localize("#WPN_TITAN_DUMB_SHOULDER_ROCKETS") );
	RegisterCategoryItem( "wep_titan_ordnance", "mp_titanweapon_shoulder_rockets", Localize("#WPN_TITAN_SHOULDER_ROCKETS") );
	RegisterCategoryItem( "wep_titan_ordnance", "mp_titanability_power_shot", Localize("#WPN_TITAN_POWER_SHOT") );
	RegisterCategoryItem( "wep_titan_ordnance", "mp_titanweapon_salvo_rockets", Localize("#WPN_TITAN_SALVO_ROCKETS") );

	RegisterPageCategory( "weapons", "wep_titan_tactical", "Titan Tactical Abilities", "Spawnmenu_GiveTitanTactical" );
	RegisterCategoryItem( "wep_titan_tactical", "mp_titanability_ammo_swap", Localize("#WPN_TITAN_AMMO_SWAP") );
	RegisterCategoryItem( "wep_titan_tactical", "mp_titanability_slow_trap", Localize("#WPN_TITAN_SLOW_TRAP") );
	RegisterCategoryItem( "wep_titan_tactical", "mp_titanability_laser_trip", Localize("#WPN_TITAN_TRIPWIRE") );
	RegisterCategoryItem( "wep_titan_tactical", "mp_titanability_phase_dash", Localize("#WPN_TITAN_PHASE_DASH") );
	RegisterCategoryItem( "wep_titan_tactical", "mp_titanability_sonar_pulse", Localize("#WPN_TITANABILITY_SONAR_PULSE") );
	RegisterCategoryItem( "wep_titan_tactical", "mp_titanability_hover", Localize("#WPN_TITAN_HOVER") );
	RegisterCategoryItem( "wep_titan_tactical", "mp_titanability_rearm", Localize("#WPN_TITANABILITY_REARM") );
	RegisterCategoryItem( "wep_titan_tactical", "mp_titanability_electric_smoke", Localize("#WPN_TITAN_ELECTRIC_SMOKE") );

	RegisterPageCategory( "weapons", "wep_titan_core", "Titan Cores", "Spawnmenu_GiveCore" );
	RegisterCategoryItem( "wep_titan_core", "recharge", "Recharge Core" );
	RegisterCategoryItem( "wep_titan_core", "mp_titancore_laser_cannon", Localize("#WPN_CHEST_LASER") );
	RegisterCategoryItem( "wep_titan_core", "mp_titancore_salvo_core", Localize("#WPN_TITAN_SALVO_CORE") );
	RegisterCategoryItem( "wep_titan_core", "mp_titancore_flame_wave", Localize("#TITANCORE_FLAME_WAVE") );
	RegisterCategoryItem( "wep_titan_core", "mp_titancore_siege_mode", Localize("#TITANCORE_SIEGE_MODE") );
	RegisterCategoryItem( "wep_titan_core", "mp_titancore_flight_core", Localize("#TITANCORE_FLIGHT") );
	RegisterCategoryItem( "wep_titan_core", "mp_titancore_shift_core", Localize("#WPN_TITAN_SWORD") );
	RegisterCategoryItem( "wep_titan_core", "mp_titancore_upgrade", Localize("#WPN_TITAN_UPGRADE_CORE") );
	RegisterCategoryItem( "wep_titan_core", "mp_titancore_amp_core", Localize("#TITANCORE_AMP_CORE") );

	RegisterPageCategory( "weapons", "wep_titan_melee", "Titan Melees", "Spawnmenu_GiveMelee" );
	RegisterCategoryItem( "wep_titan_melee", "melee_titan_punch", "Titan Punch" );
	RegisterCategoryItem( "wep_titan_melee", "melee_titan_sword", "Titan Sword" );
#endif
}
