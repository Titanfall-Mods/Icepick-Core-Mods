untyped
global function Toolgun_Shared_Init
// const EMP_GRENADE_BEAM_EFFECT = $"wpn_arc_cannon_beam"
global const EMP_GRENADE_BEAM_EFFECT = $"P_wpn_charge_tool_beam"
global array<table> ToolGunTools = [];

global struct ToolGunSettingsStruct
{
	int CurrentMode,
	int CurrentModeIdx,
	asset SelectedModel,
	entity LastSpawnedEntity
};

global ToolGunSettingsStruct ToolGunSettings;
global function Toolgun_GetCurrentMode;

const asset SPAWN_MODEL = $"models/imc_base/cargo_container_imc_01_red.mdl"
const TOOLGUN_GRAB_EFFECT = $"P_wpn_hand_laser_beam"

void function Toolgun_Shared_Init()
{
	// Convars
	RegisterConVar( "physgun_sensitivity", 1.0, "physgun_sensitivity value", "Set the sensitivity of the physgun tool" );
	RegisterConVar( "physgun_snap", 30.0, "physgun_snap angle", "Set the angle to which the physgun should snap to" );
	RegisterConVar( "physgun_speed", 50.0, "physgun_speed speed", "Set how fast the phygsun moves the held prop back and forth" );

	// Allow late cache of props
	SetConVarInt("host_thread_mode", 0);
	SetConVarInt("script_precache_errors", 0);
	SetConVarInt("fs_report_sync_opens_fatal", 0);

	PrecacheModel( SPAWN_MODEL );
	PrecacheParticleSystem( EMP_GRENADE_BEAM_EFFECT );
	PrecacheParticleSystem( TOOLGUN_GRAB_EFFECT );
	PrecacheParticleSystem( $"P_wpn_lasertrip_beam" );
	
	#if SERVER
	Toolgun_Server_Init();
	#endif
	#if CLIENT
	Toolgun_Client_Init();
	Toolgun_UI_Init();
	#endif

	thread Toolgun_Shared_Think();
}

table function Toolgun_GetCurrentMode()
{
	table tool = {};
	if (ToolGunSettings.CurrentModeIdx < ToolGunTools.len())
	{
		tool = ToolGunTools[ ToolGunSettings.CurrentModeIdx ];
	}
	return tool;
}

void function Toolgun_Shared_Think()
{
	while( true )
	{
		if( "OnThink" in Toolgun_GetCurrentMode() )
		{
			Toolgun_GetCurrentMode().OnThink();
		}
		WaitFrame();
	}
}
