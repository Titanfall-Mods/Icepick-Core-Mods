
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
