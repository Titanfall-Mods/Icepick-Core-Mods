
untyped

global function Toolgun_RegisterTool_TeleporterSpawner
#if SERVER
global function Toolgun_CreateTeleporter
#endif

global struct PlacedTeleporter
{
	entity entryEnt,
	entity exitEnt,
	entity beamFx,
	entity controlPoint,
}

global array< PlacedTeleporter > PlacedTeleporters;

const TELEPORTER_OFFSET_X = 56;
const TELEPORTER_OFFSET_Z = 50;
const TELEPORTER_CONNECTOR_OFFSET_Z = 120;
const TELEPORTER_TRIGGER_DISTANCE = 60;
const asset FX_TELEPORT = $"P_ar_holopulse_CP"
const asset LASER_TRIP_BEAM_FX = $"P_wpn_lasertrip_beam"

table ToolTeleporterSpawner = {};

void function Toolgun_RegisterTool_TeleporterSpawner()
{
	PrecacheParticleSystem( FX_TELEPORT );
	PrecacheParticleSystem( LASER_TRIP_BEAM_FX );

	// Create the tool
	ToolTeleporterSpawner.id <- "teleporter_spawner";
	ToolTeleporterSpawner.entryLocationSet <- false;
	ToolTeleporterSpawner.entryOrigin <- Vector( 0, 0, 0 );
	ToolTeleporterSpawner.entryAngles <- Vector( 0, 0, 0 );
	ToolTeleporterSpawner.exitOrigin <- Vector( 0, 0, 0 );
	ToolTeleporterSpawner.exitAngles <- Vector( 0, 0, 0 );

	ToolTeleporterSpawner.GetName <- function()
	{
		return "Teleporter";
	}

	ToolTeleporterSpawner.GetHelp <- function()
	{
		if( !ToolTeleporterSpawner.entryLocationSet )
		{
			return "Fire to place the entry point of a teleporter.";
		}
		else
		{
			return "Fire to place the exit point of the teleporter.";
		}
	}

	ToolTeleporterSpawner.OnSelected <- function()
	{
		ToolTeleporterSpawner.Reset();
	}

	ToolTeleporterSpawner.OnDeselected <- function()
	{
		ToolTeleporterSpawner.Reset();
	}

	ToolTeleporterSpawner.Reset <- function()
	{
		ToolTeleporterSpawner.entryLocationSet = false;
		ToolTeleporterSpawner.entryOrigin = Vector( 0, 0, 0 );
		ToolTeleporterSpawner.entryAngles = Vector( 0, 0, 0 );
		ToolTeleporterSpawner.exitOrigin = Vector( 0, 0, 0 );
		ToolTeleporterSpawner.exitAngles = Vector( 0, 0, 0 );
	}

	ToolTeleporterSpawner.OnFire <- function()
	{
	#if SERVER
		entity player = GetPlayerByIndex( 0 );
		Toolgun_Utils_FireToolTracer( player );
		return false;
	#else
		// Perform a trace
		entity player = GetLocalClientPlayer();
		vector eyePosition = player.EyePosition();
		vector viewVector = player.GetViewVector();
		TraceResults traceResults = TraceLine( eyePosition, eyePosition + player.GetViewVector() * 10000, player, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER );

		// Check which location we're setting
		if( ToolTeleporterSpawner.entryLocationSet )
		{
			ToolTeleporterSpawner.exitOrigin = traceResults.endPos;
			ToolTeleporterSpawner.exitAngles = Vector( 0, player.EyeAngles().y, 0 );

			// Send to server
			string entryOrigin = ToolTeleporterSpawner.entryOrigin.x + "|" + ToolTeleporterSpawner.entryOrigin.y + "|" + ToolTeleporterSpawner.entryOrigin.z;
			string entryAngles = ToolTeleporterSpawner.entryAngles.x + "|" + ToolTeleporterSpawner.entryAngles.y + "|" + ToolTeleporterSpawner.entryAngles.z;
			string exitOrigin = ToolTeleporterSpawner.exitOrigin.x + "|" + ToolTeleporterSpawner.exitOrigin.y + "|" + ToolTeleporterSpawner.exitOrigin.z;
			string exitAngles = ToolTeleporterSpawner.exitAngles.x + "|" + ToolTeleporterSpawner.exitAngles.y + "|" + ToolTeleporterSpawner.exitAngles.z;

			string command = "ToolTeleporterSpawner_AddTeleporter " + entryOrigin + " " + entryAngles + " " + exitOrigin + " " + exitAngles;
			player.ClientCommand( command );

			ToolTeleporterSpawner.Reset();
		}
		else
		{
			ToolTeleporterSpawner.entryOrigin = traceResults.endPos;
			ToolTeleporterSpawner.entryAngles = Vector( 0, player.EyeAngles().y, 0 );
			ToolTeleporterSpawner.entryLocationSet = true;
		}

		return true;
	#endif
	}

	// Register the tool
	ToolGunTools.append( ToolTeleporterSpawner );

	#if SERVER
	AddClientCommandCallback( "ToolTeleporterSpawner_AddTeleporter", ClientCommand_ToolTeleporterSpawner_AddTeleporter );
	#endif
}

#if SERVER
bool function ClientCommand_ToolTeleporterSpawner_AddTeleporter( entity player, array<string> args )
{
	vector entryOrigin = StringToVector( args[0], "|" );
	vector entryAngles = StringToVector( args[1], "|" );
	vector exitOrigin = StringToVector( args[2], "|" );
	vector exitAngles = StringToVector( args[3], "|" );

	Toolgun_CreateTeleporter( player, entryOrigin, entryAngles, exitOrigin, exitAngles );

	return true;
}

void function Toolgun_CreateTeleporter( entity player, vector entryOrigin, vector entryAngles, vector exitOrigin, vector exitAngles )
{
	entryOrigin = entryOrigin + AnglesToRight( entryAngles ) * TELEPORTER_OFFSET_X * -1;
	exitOrigin = exitOrigin + AnglesToRight( exitAngles ) * TELEPORTER_OFFSET_X * -1;

	// Create entry and exit gates
	entity entryEnt = CreateTeleporterEntity( entryOrigin, entryAngles );
	entity exitEnt = CreateTeleporterEntity( exitOrigin, exitAngles );

	// Create the entry fx
	vector fxOrigin = entryEnt.GetOrigin() + AnglesToRight( entryEnt.GetAngles() ) * TELEPORTER_OFFSET_X + AnglesToUp( entryEnt.GetAngles() ) * TELEPORTER_OFFSET_Z;
	entity entryFx = CreateTeleporterEntity( fxOrigin, entryAngles, $"models/fx/core_energy.mdl" );
	entryFx.SetParent( entryEnt );

	// Create the linking fx
	entity cpEnd = CreateEntity( "info_placement_helper" )
	SetTargetName( cpEnd, UniqueString( "laser_pylon_cpEnd" ) )
	cpEnd.SetOrigin( entryEnt.GetOrigin() + AnglesToRight( entryEnt.GetAngles() ) * TELEPORTER_OFFSET_X + AnglesToUp( entryEnt.GetAngles() ) * TELEPORTER_CONNECTOR_OFFSET_Z )
	cpEnd.SetParent( entryEnt )
	DispatchSpawn( cpEnd )

	entity beamFX = CreateEntity( "info_particle_system" )
	beamFX.kv.cpoint1 = cpEnd.GetTargetName()
	beamFX.SetValueForEffectNameKey( LASER_TRIP_BEAM_FX )
	beamFX.kv.start_active = 1
	beamFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
	beamFX.SetOrigin( exitEnt.GetOrigin() + AnglesToRight( exitEnt.GetAngles() ) * TELEPORTER_OFFSET_X + AnglesToUp( exitEnt.GetAngles() ) * TELEPORTER_CONNECTOR_OFFSET_Z )
	vector cpEndPoint = cpEnd.GetOrigin()
	beamFX.SetAngles( VectorToAngles( cpEndPoint - exitEnt.GetOrigin() ) )
	beamFX.SetParent( exitEnt )
	DispatchSpawn( beamFX )

	// Track teleporter and wait for teleporting
	PlacedTeleporter newTeleporter;
	newTeleporter.entryEnt = entryEnt;
	newTeleporter.exitEnt = exitEnt;
	newTeleporter.beamFx = beamFX;
	newTeleporter.controlPoint = cpEnd;
	PlacedTeleporters.append( newTeleporter );

	thread Teleporter_Think( player, newTeleporter, PlacedTeleporters.len() - 1 );
}

entity function CreateTeleporterEntity( vector origin, vector angles, asset model = $"models/beacon/beacon_doorframe_04.mdl" )
{
	EnableExternalSpawnMode();
	entity prop_dynamic = CreateEntity( "prop_dynamic" );
	prop_dynamic.SetValueForModelKey( model );
	prop_dynamic.kv.fadedist = -1;
	prop_dynamic.kv.renderamt = 255;
	prop_dynamic.kv.rendercolor = "255 255 255";
	prop_dynamic.kv.solid = 6; // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
	SetTeam( prop_dynamic, TEAM_BOTH );	// need to have a team other then 0 or it won't take impact damage

	prop_dynamic.SetAngles( angles );
	prop_dynamic.SetOrigin( origin );
	DispatchSpawn( prop_dynamic );
	DisableExternalSpawnMode();
	return prop_dynamic;
}

void function Teleporter_Think( entity player, PlacedTeleporter teleporter, int teleporterIdx )
{
	EndSignal( teleporter.entryEnt, "OnDestroy" );
	EndSignal( teleporter.exitEnt, "OnDestroy" );

	// Cleanup teleporters if one of them is destroyed
	OnThreadEnd(
		function() : ( teleporter, teleporterIdx )
		{
			if ( IsValid( teleporter.entryEnt ) )
				teleporter.entryEnt.Destroy();
			if ( IsValid( teleporter.exitEnt ) )
				teleporter.exitEnt.Destroy();

			PlacedTeleporters.remove( teleporterIdx );
		}
	)

	while( true )
	{
		// Check if players are close enough and then perform a more expensive OOBB check for a plane in the teleporter gate
		entity entryEnt = teleporter.entryEnt;
		vector entryOrigin = entryEnt.GetOrigin();
		vector entryAngles = entryEnt.GetAngles();
		vector teleporterCenter = entryOrigin + AnglesToRight( entryAngles ) * TELEPORTER_OFFSET_X + AnglesToUp( entryAngles ) * TELEPORTER_OFFSET_Z;
		float distanceToPlayer = Distance( teleporterCenter, player.GetOrigin() );

		if( distanceToPlayer < TELEPORTER_TRIGGER_DISTANCE )
		{
			vector entryOBBOrigin = entryOrigin;
			vector entryOOBAngles = entryAngles;
			vector entryOOBMins = < 0, 0, 0 >;
			vector entryOOBMaxs = < 10, -120, 120 >;
			if( OBBIntersectsOBB( entryOBBOrigin, entryOOBAngles, entryOOBMins, entryOOBMaxs, player.GetOrigin(), <0.0,0.0,0.0>, player.GetPlayerMins(), player.GetPlayerMaxs(), 0.0 ) )
			{
				vector exitOrigin = teleporter.exitEnt.GetOrigin();
				vector exitAngles = teleporter.exitEnt.GetAngles();
				vector exitAngleDelta = exitAngles - entryAngles;
				vector exitCenter = exitOrigin + AnglesToRight( exitAngles ) * TELEPORTER_OFFSET_X;

				// Move the destination further towards the center of the exit if it is not on flat ground
				float exitUprightness = clamp( AnglesToUp( exitAngles ).Dot( < 0, 0, 1 > ), 0, 1 );
				exitCenter = exitCenter + AnglesToUp( exitAngles ) * TELEPORTER_OFFSET_Z * (1.0 - exitUprightness);

				// Teleport the player to the exit
				player.SetOrigin( exitCenter );

				// Adjust the players velocity relative to the exit
				vector playerVelocity = player.GetVelocity();
				vector playerVelocityAngle = VectorToAngles( playerVelocity );
				playerVelocityAngle = AnglesCompose( playerVelocityAngle, exitAngleDelta );
				playerVelocityAngle = AnglesCompose( playerVelocityAngle, < 0, 180, 0 > );
				player.SetVelocity( AnglesToForward( playerVelocityAngle ) * playerVelocity.Length() );

				// Rotate the player
				vector playerAng = player.GetAngles();
				playerAng = AnglesCompose( playerAng, exitAngleDelta );
				playerAng = AnglesCompose( playerAng, < 0, 180, 0 > );
				player.SetAngles( playerAng );

				// Play effects
				vector effectsOrigin = exitOrigin + AnglesToRight( exitAngles ) * TELEPORTER_OFFSET_X + AnglesToUp( exitAngles ) * TELEPORTER_OFFSET_Z;
				EmitSoundAtPosition( TEAM_UNASSIGNED, exitCenter, "training_scr_zen_player_fall" );
				entity pulseFXHandle = PlayFX( FX_TELEPORT, exitCenter, <0, 0, 0> );
				EffectSetControlPointVector( pulseFXHandle, 1, <2.5, 50, 0> );
				thread KillFX_Delayed( pulseFXHandle, 0.5 );
			}
		}

		// Show the connection beam only if we're holding the toolgun
		if( Toolgun_IsHoldingToolgun() )
		{
			teleporter.beamFx.Fire( "Start" );
		}
		else
		{
			teleporter.beamFx.Fire( "Stop" );
		}

		WaitFrame();
	}
}

void function KillFX_Delayed( entity fxHandle, float delay )
{
	fxHandle.EndSignal( "OnDestroy" );

	if ( delay > 0.0 )
		wait delay;

	if ( !IsValid_ThisFrame( fxHandle ) );
		return;

	fxHandle.SetStopType( "DestroyImmediately" );
	fxHandle.ClearParent();
	fxHandle.Destroy();
}
#endif
