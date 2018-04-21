
const asset SPAWN_MODEL = $"models/imc_base/cargo_container_imc_01_red.mdl"

// const EMP_GRENADE_BEAM_EFFECT = $"wpn_arc_cannon_beam"
const EMP_GRENADE_BEAM_EFFECT = $"P_wpn_charge_tool_beam"
const TOOLGUN_GRAB_EFFECT = $"P_wpn_hand_laser_beam"

array<table> ToolGunTools = [];

struct
{
	int CurrentMode,
	int CurrentModeIdx,
	asset SelectedModel,
	entity LastSpawnedEntity
} ToolGunSettings;

void function Toolgun_Shared_Init()
{
	PrecacheModel( SPAWN_MODEL );
	PrecacheParticleSystem( EMP_GRENADE_BEAM_EFFECT );
	PrecacheParticleSystem( TOOLGUN_GRAB_EFFECT );
	PrecacheParticleSystem( $"P_wpn_lasertrip_beam" );

	for (int i = 0; i < CurrentLevelSpawnList.len(); i++)
	{
		PrecacheModel( CurrentLevelSpawnList[i] );
	}

	Toolgun_RegisterTools();
	#if SERVER
	Toolgun_Server_Init();
	#endif
	#if CLIENT
	Toolgun_Client_Init();
	Toolgun_UI_Init();
	#endif

	thread Toolgun_Shared_Think();
}

void function Toolgun_RegisterTools()
{
	Toolgun_RegisterTool_SpawnProp();
	Toolgun_RegisterTool_RemoveProp();
	Toolgun_RegisterTool_NudgeProp();
	Toolgun_RegisterTool_Stacker();
	Toolgun_RegisterTool_TimeshiftMirror();
	Toolgun_RegisterTool_ZiplineSpawner();
	Toolgun_RegisterTool_CameraPlacer();
	Toolgun_RegisterTool_PropInfo();
}

table function Toolgun_GetCurrentMode()
{
	return ToolGunTools[ ToolGunSettings.CurrentModeIdx ]
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

// #includefolder scripts/tools/sh_*.nut
