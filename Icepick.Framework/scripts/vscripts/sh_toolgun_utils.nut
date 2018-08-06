global function printc
global function FloatStepTowards
global function VectorStepTowards
global function PackVectorToString
global function UnpackStringToVector
global function CreateAnchorEntity

void function printc( ... )
{
	string out = "";
	for( int i = 0; i < vargc; i++ )
	{
		out += ( "" + vargv[i] );
		if( i + 1 < vargc )
		{
			out += "\t";
		}
	}
	print( out );
}

float function FloatStepTowards( float a, float b, float MaxStep )
{
	float delta = clamp( b - a, MaxStep * -1, MaxStep );
	return a + delta;
}

vector function VectorStepTowards( vector a, vector b, float MaxStep )
{
	return Vector( FloatStepTowards(a.x, b.x, MaxStep), FloatStepTowards(a.y, b.y, MaxStep), FloatStepTowards(a.z, b.z, MaxStep) );
}

string function PackVectorToString( vector v, string separator = "|" )
{
	return v.x + separator + v.y + separator + v.z;
}

vector function UnpackStringToVector( string s, string separator = "|" )
{
	return StringToVector( s, separator )
}

entity function CreateAnchorEntity( vector origin, vector angles, asset modelAsset = $"models/weapons/titan_trip_wire/titan_trip_wire.mdl" )
{
#if SERVER
	EnableExternalSpawnMode();

	entity prop_dynamic = CreateEntity( "prop_dynamic" );
	prop_dynamic.SetValueForModelKey( modelAsset );
	prop_dynamic.kv.fadedist = -1;
	prop_dynamic.kv.renderamt = 255;
	prop_dynamic.kv.rendercolor = "255 255 255";
	prop_dynamic.kv.solid = 6; // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
	SetTeam( prop_dynamic, TEAM_BOTH );	// need to have a team other then 0 or it won't take impact damage

	prop_dynamic.SetOrigin( origin );
	prop_dynamic.SetAngles( angles );
	DispatchSpawn( prop_dynamic );
	
	DisableExternalSpawnMode();

	return prop_dynamic;
#endif
#if CLIENT
	return null;
#endif
}
