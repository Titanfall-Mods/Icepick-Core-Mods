
const ENEMY_HOLOGRAM_MODEL = $"models/humans/grunts/imc_grunt_rifle.mdl"
const FX_HOLOGRAM_HEX_EFFECT = $"P_ar_holopilot_hextrail"

const float GAUNTLET_TARGET_DISSOLVE_TIME = 0.25 * 1000
const int GAUNTLET_LEADERBOARD_MAX_ENTRIES = 10
const float GAUNTLET_ENEMY_MISSED_TIME_PENALTY = 2.0

struct WorldPoint
{
	vector Location,
	vector Rotation
}

struct GauntletPlayerSpeedTracker
{
	float startTime 	= -1
	float topSpeed 		= 0.0
	float avgSpeed 		= 0.0
	float highSpeedTime = 0.0
	int highSpeedKills 	= 0
	float totalHours 	= 0.0
	float totalMiles 	= 0.0
}

struct
{
	bool IsActive,
	bool Started,
	bool Finished,

	float StartTime,
	float LastRunTime,
	float BestRunTime = -1.0,

	WorldPoint StartPoint,
	WorldPoint FinishPoint,
	array<WorldPoint> TargetPoints,
	WorldPoint LeaderboardPoint,
	WorldPoint ResultsPoint,

	var StartDisplayTopology,
	var StartDisplayRui,
	var FinishDisplayTopology,
	var FinishDisplayRui,
	array<var> TargetRuis,
	var LeaderboardTopology,
	var LeaderboardRui,
	var ResultsTopology,
	var ResultsRui,
	var SplashRui,

	var IsActiveRui

	array<entity> SpawnedTargets,
	int NumberOfTargetsAlive,
	int NumberOfTargetsKilled,

#if CLIENT
	array<entity> TargetModels,

	int TipIdx,
	array<string> Tips,
	var HUDRui,
#endif

	var STRUCT_MAX

} CustomGauntlet;

void function CustomGauntlet_Shared_Init()
{
	PrecacheModel( ENEMY_HOLOGRAM_MODEL );
	PrecacheParticleSystem( FX_HOLOGRAM_HEX_EFFECT );

	CustomGauntlet_Shared_RegisterTools();

	#if SERVER
	CustomGauntlet_Server_Init();
	#endif

	#if CLIENT
	CustomGauntlet_Client_Init();
	CustomGauntlet_UI_Init();
	#endif
}

void function CustomGauntlet_Shared_RegisterTools()
{
	table ToolGauntletStart = {}
	ToolGauntletStart.id <- "gauntlet_place_start"
	ToolGauntletStart.name <- "Gauntlet Start"
	ToolGauntletStart.help <- "Left click to place the start for a gauntlet"
	ToolGunTools.append( ToolGauntletStart )
	ToolGunToolFunctions.append( Toolgun_Func_Gauntlet_PlaceStart )

	table ToolGauntletFinish = {}
	ToolGauntletFinish.id <- "gauntlet_place_finish"
	ToolGauntletFinish.name <- "Gauntlet Finish"
	ToolGauntletFinish.help <- "Left click to place the finish for a gauntlet"
	ToolGunTools.append( ToolGauntletFinish )
	ToolGunToolFunctions.append( Toolgun_Func_Gauntlet_PlaceFinish )

	table ToolGauntletTarget = {}
	ToolGauntletTarget.id <- "gauntlet_place_target"
	ToolGauntletTarget.name <- "Gauntlet Target"
	ToolGauntletTarget.help <- "Left click to place a target for a gauntlet"
	ToolGunTools.append( ToolGauntletTarget )
	ToolGunToolFunctions.append( Toolgun_Func_Gauntlet_PlaceTarget )

	table ToolGauntletLeaderboard = {}
	ToolGauntletLeaderboard.id <- "gauntlet_place_leaderboard"
	ToolGauntletLeaderboard.name <- "Gauntlet Leaderboard"
	ToolGauntletLeaderboard.help <- "Left click to place a leaderboard for a gauntlet"
	ToolGunTools.append( ToolGauntletLeaderboard )
	ToolGunToolFunctions.append( Toolgun_Func_Gauntlet_PlaceLeaderboard )

	table ToolGauntletResults = {}
	ToolGauntletResults.id <- "gauntlet_place_results"
	ToolGauntletResults.name <- "Gauntlet Results Board"
	ToolGauntletResults.help <- "Left click to place a results board for a gauntlet"
	ToolGunTools.append( ToolGauntletResults )
	ToolGunToolFunctions.append( Toolgun_Func_Gauntlet_PlaceResults )
	
}
