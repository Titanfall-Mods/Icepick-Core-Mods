
const asset SPAWN_MODEL = $"models/imc_base/cargo_container_imc_01_red.mdl"

// const EMP_GRENADE_BEAM_EFFECT = $"wpn_arc_cannon_beam"
const EMP_GRENADE_BEAM_EFFECT = $"P_wpn_charge_tool_beam"
const TOOLGUN_GRAB_EFFECT = $"P_wpn_hand_laser_beam"

array<table> ToolGunTools = [];
array<bool functionref( entity, array<string> )> ToolGunToolFunctions = [];

struct
{
	int CurrentMode,
	int CurrentModeIdx,
	asset SelectedModel,
	entity LastSpawnedEntity
} ToolGunSettings;

void function Toolgun_Shared_Init()
{
	PrecacheModel( SPAWN_MODEL )
	PrecacheParticleSystem( EMP_GRENADE_BEAM_EFFECT )
	PrecacheParticleSystem( TOOLGUN_GRAB_EFFECT )

	for (var i = 0; i < SpawnList.len(); i++)
	{
		PrecacheModel( SpawnList[i] );
	}

	Toolgun_RegisterTools()
	#if SERVER
	Toolgun_Server_Init()
	#endif
	#if CLIENT
	ModelPicker_Client_Init()
	Toolgun_Client_Init()
	Toolgun_UI_Init()
	#endif

	CustomGauntlet_Shared_Init()
}

void function Toolgun_RegisterTools()
{
	table ToolSpawnProp = {}
	ToolSpawnProp.id <- "spawn_prop"
	ToolSpawnProp.name <- "Spawn Prop"
	ToolSpawnProp.help <- "Left click to spawn a prop"
	ToolGunTools.append( ToolSpawnProp )
	ToolGunToolFunctions.append( Toolgun_Func_SpawnProp )

	table ToolRemoveProp = {}
	ToolRemoveProp.id <- "remove_prop"
	ToolRemoveProp.name <- "Remove Prop"
	ToolRemoveProp.help <- "Left click to remove a prop"
	ToolGunTools.append( ToolRemoveProp )
	ToolGunToolFunctions.append( Toolgun_Func_RemoveProp )

	table ToolPropInfo = {}
	ToolPropInfo.id <- "prop_info"
	ToolPropInfo.name <- "Prop Info"
	ToolPropInfo.help <- "Left click to print info on a prop to the console"
	ToolGunTools.append( ToolPropInfo )
	ToolGunToolFunctions.append( Toolgun_Func_PropInfo )

	table ToolMirrorProp = {}
	ToolMirrorProp.id <- "mirror_prop"
	ToolMirrorProp.name <- "Mirror Prop"
	ToolMirrorProp.help <- "Left click to mirror a prop to the other timeline"
	ToolGunTools.append( ToolMirrorProp )
	ToolGunToolFunctions.append( Toolgun_Func_TimeshiftMirror )
}

table function Toolgun_GetCurrentMode()
{
	return ToolGunTools[ ToolGunSettings.CurrentModeIdx ]
}

bool functionref( entity, array<string> ) function Toolgun_GetCurrentModeFunction()
{
	return ToolGunToolFunctions[ ToolGunSettings.CurrentModeIdx ]
}
