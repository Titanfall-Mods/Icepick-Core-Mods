untyped

global function Toolgun_RegisterTool_Rope
global function Toolgun_CreateRope

global struct PlacedRope
{
	vector Origin,
	vector Target,
	string Color
}
global array<PlacedRope> PlacedRopes;

table ToolRope = {};

const float DefaultColorR = 0;
const float DefaultColorG = 255;
const float DefaultColorB = 0;

void function Toolgun_RegisterTool_Rope()
{
	RegisterConVar( "rope_color_r", DefaultColorR, "rope_color_r value", "Set the red color component for the rope tool" );
	RegisterConVar( "rope_color_g", DefaultColorG, "rope_color_g value", "Set the green color component for the rope tool" );
	RegisterConVar( "rope_color_b", DefaultColorB, "rope_color_b value", "Set the blue color component for the rope tool" );
	AddOnToolOptionUpdateCallback( ToolRope_UpdateToolOption );

	// Create the tool
	ToolRope.id <- "rope";
	ToolRope.startLocation <- null;
	ToolRope.endLocation <- null;

	ToolRope.GetName <- function()
	{
		return "Rope";
	}

	ToolRope.GetHelp <- function()
	{
		if( ToolRope.startLocation == null )
		{
			return "Fire to select the rope start point.";
		}
		else
		{
			return "Fire to select the rope end point.";
		}
	}

	ToolRope.RegisterOptions <- function()
	{
		#if CLIENT
		AddSliderOption( "rope", "rope_color_r", "Red", DefaultColorR, 0, 255 );
		AddSliderOption( "rope", "rope_color_g", "Green", DefaultColorG, 0, 255 );
		AddSliderOption( "rope", "rope_color_b", "Blue", DefaultColorB, 0, 255 );
		#endif
	}

	ToolRope.OnSelected <- function()
	{
		ToolRope.Reset();
	}

	ToolRope.OnDeselected <- function()
	{
		ToolRope.Reset();
	}

	ToolRope.Reset <- function()
	{
		ToolRope.startLocation = null;
		ToolRope.endLocation = null;
	}

	ToolRope.OnFire <- function()
	{
	#if SERVER
		entity player = GetPlayerByIndex( 0 );
		Toolgun_Utils_FireToolTracer( player );
	#else
		entity player = GetLocalClientPlayer();
	#endif

		vector eyePosition = player.EyePosition();
		vector viewVector = player.GetViewVector();
		TraceResults traceResults = TraceLine( eyePosition, eyePosition + viewVector * 10000, player, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER );

		if( ToolRope.startLocation == null )
		{
			ToolRope.startLocation = traceResults.endPos + traceResults.surfaceNormal;
		}
		else
		{
			ToolRope.endLocation = traceResults.endPos + traceResults.surfaceNormal;

			float color_r = GetConVarValue( "rope_color_r", DefaultColorR );
			float color_g = GetConVarValue( "rope_color_g", DefaultColorG );
			float color_b = GetConVarValue( "rope_color_b", DefaultColorB );
			string colorString = color_r + " " + color_g + " " + color_b;

			printt("creating rope with color: ", colorString);

			Toolgun_CreateRope( expect vector( ToolRope.startLocation ), expect vector( ToolRope.endLocation ), colorString );
			ToolRope.Reset();
		}

		return true;
	}

	// Register the tool
	ToolGunTools.append( ToolRope );
}

void function Toolgun_CreateRope( vector start, vector end, string colorString )
{
#if SERVER
	entity target = CreateEntity( "info_placement_helper" );
	SetTargetName( target, UniqueString( "beam_helper_target" ) );
	target.SetOrigin( end );
	DispatchSpawn( target );

	entity emitter = CreateEntity( "info_placement_helper" );
	SetTargetName( emitter, UniqueString( "beam_helper_target" ) );
	emitter.SetOrigin( start );
	DispatchSpawn( emitter );

	entity env_laser = CreateEntity( "env_laser" );
	env_laser.kv.LaserTarget = target.GetTargetName();
	env_laser.kv.rendercolor = colorString;
	env_laser.kv.rendercolorFriendly = colorString;
	env_laser.kv.renderamt = 255;
	env_laser.kv.width = 4;
	env_laser.SetValueForTextureKey( $"sprites/physbeam.spr" );
	env_laser.kv.TextureScroll = 10;
	env_laser.kv.damage = "0";
	env_laser.kv.dissolvetype = -1; //-1 to 2 - none, energy, heavy elec, light elec
	env_laser.kv.spawnflags = 1;
	env_laser.kv.solid = -1;
	env_laser.SetOrigin( emitter.GetOrigin() );
	env_laser.SetAngles( emitter.GetAngles() );
	env_laser.SetParent( emitter );
	env_laser.s.parents <- [ target, emitter ];
	DispatchSpawn( env_laser );

	PlacedRope newRope;
	newRope.Origin = start;
	newRope.Target = end;
	newRope.Color = colorString;
	PlacedRopes.append( newRope );
#endif
}

void function ToolRope_UpdateToolOption( string id, var value )
{
#if CLIENT
	if( id.find( "rope_color_" ) != null )
	{
		SetConVarValue( id, float( value ) );
	}
#endif
}
