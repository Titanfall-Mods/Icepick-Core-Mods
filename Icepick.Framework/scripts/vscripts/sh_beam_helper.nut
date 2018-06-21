untyped

global struct BeamEntity
{
	entity Emitter,
	entity Target,
	entity Laser,
	entity Laser2
}

#if SERVER

global function CreateBeamHelper
global function UpdateBeamEmitterPosition
global function UpdateBeamTargetPosition
global function DestroyBeam
global function IsBeamEntityValid

void function CreateBeamHelper( BeamEntity Beam, string ColorString, entity StartEnt, entity EndEnt )
{
	entity target = CreateEntity( "info_placement_helper" );
	SetTargetName( target, UniqueString( "beam_helper_target" ) );
	target.SetOrigin( EndEnt.GetOrigin() );
	DispatchSpawn( target );

	entity emitter = CreateEntity( "info_placement_helper" );
	SetTargetName( emitter, UniqueString( "beam_helper_target" ) );
	emitter.SetOrigin( StartEnt.GetOrigin() );
	DispatchSpawn( emitter );

	entity env_laser = CreateEntity( "env_laser" );
	env_laser.kv.LaserTarget = target.GetTargetName();
	env_laser.kv.rendercolor = ColorString;
	env_laser.kv.rendercolorFriendly = ColorString;
	env_laser.kv.renderamt = 255;
	env_laser.kv.width = 4;
	env_laser.SetValueForTextureKey( $"sprites/laserbeam.spr" );
	env_laser.kv.TextureScroll = 10;
	env_laser.kv.damage = "0";
	env_laser.kv.dissolvetype = -1; //-1 to 2 - none, energy, heavy elec, light elec
	env_laser.kv.spawnflags = 1;
	env_laser.kv.solid = 0;
	env_laser.SetOrigin( emitter.GetOrigin() );
	env_laser.SetAngles( emitter.GetAngles() );
	env_laser.SetParent( emitter );
	env_laser.s.parents <- [StartEnt, EndEnt]
	DispatchSpawn( env_laser );

	entity env_laser2 = CreateEntity( "env_laser" );
	env_laser2.kv.LaserTarget = emitter.GetTargetName();
	env_laser2.kv.rendercolor = ColorString;
	env_laser2.kv.rendercolorFriendly = ColorString;
	env_laser2.kv.renderamt = 255;
	env_laser2.kv.width = 4;
	env_laser2.SetValueForTextureKey( $"sprites/laserbeam.spr" );
	env_laser2.kv.TextureScroll = 10;
	env_laser2.kv.damage = "0";
	env_laser2.kv.dissolvetype = -1; //-1 to 2 - none, energy, heavy elec, light elec
	env_laser2.kv.spawnflags = 1;
	env_laser2.kv.solid = 0;
	env_laser2.SetOrigin( target.GetOrigin() );
	env_laser2.SetAngles( target.GetAngles() );
	env_laser2.SetParent( target );
	env_laser2.s.parents <- [StartEnt, EndEnt]
	DispatchSpawn( env_laser2 );

	Beam.Emitter = emitter;
	Beam.Target = target;
	Beam.Laser = env_laser;
	Beam.Laser2 = env_laser2;
}

void function UpdateBeamEmitterPosition( BeamEntity Beam, vector NewPos )
{
	if( IsValid( Beam.Emitter ) )
	{
		Beam.Emitter.SetOrigin( NewPos );
	}
}

void function UpdateBeamTargetPosition( BeamEntity Beam, vector NewPos )
{
	if( IsValid( Beam.Target ) )
	{
		Beam.Target.SetOrigin( NewPos );
	}
}

void function DestroyBeam( BeamEntity Beam )
{
	if( IsValid( Beam.Emitter ) )
	{
		Beam.Emitter.Destroy();
	}
	if( IsValid( Beam.Target ) )
	{
		Beam.Target.Destroy();
	}
	if( IsValid( Beam.Laser ) )
	{
		Beam.Laser.Destroy();
	}
	if( IsValid( Beam.Laser2 ) )
	{
		Beam.Laser2.Destroy();
	}
}

bool function IsBeamEntityValid( BeamEntity Beam )
{
	return IsValid( Beam.Emitter ) && IsValid( Beam.Target );
}

#endif
