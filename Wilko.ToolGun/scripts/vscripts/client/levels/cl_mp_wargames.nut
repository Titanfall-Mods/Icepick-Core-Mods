
global function ClientCodeCallback_MapInit

global function ServerCallback_StopWargamesPodAmbienceSound
global function ServerCallback_SpawnIMCFactionLeaderForIntro
global function ServerCallback_SpawnMilitiaFactionLeaderForIntro
global function ServerCallback_ClearFactionLeaderIntro
global function ServerCallback_PlayPodTransitionScreenFX



struct
{
	array<entity> factionLeaderIntroEnts
	bool factionLeaderSpawned = false
} file


void function ClientCodeCallback_MapInit()
{
	ClCarrier_Init() //Not actually sure if we want skyshows in wargames, but they were in the first game. Easy to remove at any rate.

	if ( !IsMultiplayerPlaylist() )
		return

	if ( !ShouldDoTrainingPodIntro() )
		return

	RegisterSignal( "StopWargamesPodAmbienceSound" )

	// ClassicMP_Client_SetGameStateEnterFunc_WaitingForPlayers( WarGames_GameStateEnterFunc_WaitingForPlayers )
	// ClassicMP_Client_SetGameStateEnterFunc_PickLoadOut( WarGames_GameStateEnterFunc_PickLoadout )
}

void function WarGames_GameStateEnterFunc_WaitingForPlayers( entity player ) //Copy of ClassicMP_JumpingToLocation_GameStateEnterFunc_WaitingForPlayers
{
	// ClassicMP_DefaultCreateJumpInRui( player )
	// ClassicMP_SetJumpInRuiText( "#WARGAMES_INTRO_BOOTING_POD" )
}

void function WarGames_GameStateEnterFunc_PickLoadout( entity player ) //Almost a direct copy of ClassicMP_Dropship_GameStateEnterFunc_PickLoadOut, minus the dropship sounds
{
	// ClassicMP_DefaultCreateJumpInRui( player )
	// ClassicMP_SetJumpInRuiText( "#WARGAMES_INTRO_BOOTING_POD" )
	HidePermanentCockpitRui()

	SetShouldShowFriendIcon( false )

	thread TrainingPodAmbienceSounds( player )
}

void function TrainingPodAmbienceSounds( entity player ) //Somewhat awkward, structured this way just to make sure sound is played and killed in one function.
{
	if ( GetGameState() >= eGameState.Playing )
		return

	EmitSoundOnEntity( player, "Amb_Wargames_Pod_Ambience" )

	player.EndSignal( "StopWargamesPodAmbienceSound" )

	OnThreadEnd(
	function() : ( player )
		{
			if ( !IsValid( player ) )
				return

			//printt( "Stopping ambience sound" )

			FadeOutSoundOnEntityByName( player, "Amb_Wargames_Pod_Ambience", 0.13 )
		}
	)

	WaitForever()
}

void function ServerCallback_StopWargamesPodAmbienceSound()
{
	entity player = GetLocalClientPlayer()
	player.Signal( "StopWargamesPodAmbienceSound" )
}

void function ServerCallback_SpawnIMCFactionLeaderForIntro( float animStartTime, int podEHandle ) //podEHandle not used, just added for parity with the milita side function that does use it.
{
}

void function ServerCallback_SpawnMilitiaFactionLeaderForIntro( float animStartTime, int militiaPodEHandle )
{
}

void function ServerCallback_ClearFactionLeaderIntro()
{
}

void function ServerCallback_PlayPodTransitionScreenFX()
{
	entity viewPlayer = GetLocalViewPlayer()

	int fxID = GetParticleSystemIndex( FX_POD_SCREEN_IN )

	//StartParticleEffectOnEntity( viewPlayer, fxID )

	StartParticleEffectInWorld( fxID, <0,0,0>, <0,0,0> )
}