
untyped

global function Icepick_RegisterGamemodes
global function CreateNewGamemode

global struct IcepickGamemodeGlobalsStruct
{
	bool hasRegisteredGamemodes
	array<string> allSingleplayerLevels = [
		"sp_training",
		"sp_crashsite",
		"sp_sewers1",
		"sp_boomtown_start",
		"sp_boomtown",
		"sp_boomtown_end",
		"sp_hub_timeshift",
		"sp_timeshift_spoke02",
		"sp_hub_timeshift",
		"sp_beacon",
		"sp_beacon_spoke0",
		"sp_tday",
		"sp_s2s",
		"sp_skyway_v1",
	]
	array<string> allMultiplayerLevels = [
		"mp_black_water_canal",
		"mp_grave",
		"mp_crashsite3",
		"mp_complex3",
		"mp_drydock",
		"mp_eden",
		"mp_thaw",
		"mp_forwardbase_kodai",
		"mp_homestead",
		"mp_colony02",
		"mp_angel_city",
		"mp_glitch",
		"mp_relic02",
		"mp_wargames",
		"mp_rise",
		"mp_lf_stacks",
		"mp_lf_meadow",
		"mp_lf_township",
		"mp_lf_deck",
		"mp_lf_traffic",
		"mp_lf_uma",
		"mp_coliseum",
		"mp_coliseum_column",
	]
};
global IcepickGamemodeGlobalsStruct IcepickGamemodeGlobals; // @note: this naming is shit, but it works and nobody should be using IcepickGamemodeGlobalsStruct anywhere anyway

global struct IcepickGamemode
{
	string id
	string name
	string description
	array<string> validLevels
};
global array<IcepickGamemode> GlobalGamemodes;

void function Icepick_RegisterGamemodes()
{
	if( IcepickGamemodeGlobals.hasRegisteredGamemodes )
	{
		return;
	}
	IcepickGamemodeGlobals.hasRegisteredGamemodes = true;

	// Register gamemodes from Icepick
	// @note: do these first so that we can override some aspects in script if we want
	foreach( gamemodeData in GetIcepickGamemodes() )
	{
		string id = string(gamemodeData[0]);
		string name = string(gamemodeData[1]);
		string desc = string(gamemodeData[2]);

		IcepickGamemode newGamemode = CreateNewGamemode();
		newGamemode.id = id;
		newGamemode.name = name;
		newGamemode.description = desc;

		// @todo
		newGamemode.validLevels.extend( IcepickGamemodeGlobals.allSingleplayerLevels );
		newGamemode.validLevels.extend( IcepickGamemodeGlobals.allMultiplayerLevels );

		GlobalGamemodes.append( newGamemode );
	}

	// Register scripted gamemodes
	RegisterBaseGamemode();
	RegisterCampaignGamemode();
	RegisterSandboxGamemode();

	// Sort gamemodes alphabetically
	GlobalGamemodes.sort( SortGamemodesAlphabetically );
}

int function SortGamemodesAlphabetically( IcepickGamemode a, IcepickGamemode b )
{
	if ( a.name > b.name )
		return 1;
	if ( a.name < b.name )
		return -1;
	return 0;
}

IcepickGamemode function CreateNewGamemode()
{
	IcepickGamemode Base;
	Base.id = "base";
	Base.name = "Base Gamemode";
	Base.description = "The base gamemode. This should not appear selectable to a player.";
	Base.validLevels = [];

	return Base;
}

function RegisterBaseGamemode()
{
	IcepickGamemode BaseGamemode = CreateNewGamemode();

	GlobalGamemodes.append( BaseGamemode );
}

// @todo: move these into their own files
function RegisterCampaignGamemode()
{
	IcepickGamemode Campaign = CreateNewGamemode();
	Campaign.id = "campaign";
	Campaign.name = "Campaign";
	Campaign.description = "Play the Titanfall campaign normally.\nSome mods will still be active.";
	Campaign.validLevels.extend( IcepickGamemodeGlobals.allSingleplayerLevels );

	GlobalGamemodes.append( Campaign );
}

function RegisterSandboxGamemode()
{
	IcepickGamemode Sandbox = CreateNewGamemode();
	Sandbox.id = "sandbox";
	Sandbox.name = "Sandbox";
	Sandbox.description = "Play with the Sandbox gamemode.";
	Sandbox.validLevels.extend( IcepickGamemodeGlobals.allSingleplayerLevels );
	Sandbox.validLevels.extend( IcepickGamemodeGlobals.allMultiplayerLevels );

	GlobalGamemodes.append( Sandbox );
}
