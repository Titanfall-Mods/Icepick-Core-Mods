
// https://github.com/opentk/opentk/blob/develop/src/OpenTK/Math/Quaternion.cs

globalize_all_functions

global struct Quaternion
{
	vector Xyz,
	float W = 1.0,
}

Quaternion function toQuaternion( vector angles )
{
	Quaternion out;

	float cz = cos( DegToRad( angles.z * 0.5 ) );
	float sz = sin( DegToRad( angles.z * 0.5 ) );
	float cy = cos( DegToRad( angles.y * 0.5 ) );
	float sy = sin( DegToRad( angles.y * 0.5 ) );
	float cx = cos( DegToRad( angles.x * 0.5 ) );
	float sx = sin( DegToRad( angles.x * 0.5 ) );

	out.W = cx * cy * cz - sx * sy * sz;
	float x = sx * cy * cz + cx * sy * sz;
	float y = cx * sy * cz - sx * cy * sz;
	float z = cx * cy * sz + sx * sy * cz;
	out.Xyz = Vector( x, y, z );
	return out;
}

vector function toEulerVector( Quaternion quat )
{
	float sqw = quat.W * quat.W;
	float sqx = quat.Xyz.x * quat.Xyz.x;
	float sqy = quat.Xyz.y * quat.Xyz.y;
	float sqz = quat.Xyz.z * quat.Xyz.z;
	float unit = sqx + sqy + sqz + sqw;
	float test = quat.Xyz.x * quat.W - quat.Xyz.y * quat.Xyz.z;
	vector v;

	if ( test > 0.4995 * unit )
	{
		v.y = 2.0 * atan2( quat.Xyz.y, quat.Xyz.x );
		v.x = PI / 2.0;
		v.z = 0.0;
		return Quaternion_NormalizeAngles( v * RAD_TO_DEG );
	}
	if ( test < -0.4995 * unit )
	{
		v.y = -2.0 * atan2( quat.Xyz.y, quat.Xyz.x );
		v.x = -PI / 2.0;
		v.z = 0.0;
		return Quaternion_NormalizeAngles( v * RAD_TO_DEG );
	}

	Quaternion q;
	q.W = quat.Xyz.y;
	q.Xyz = Vector( quat.W, quat.Xyz.z, quat.Xyz.x );

	v.y = atan2( 2.0 * q.Xyz.x * q.W + 2.0 * q.Xyz.y * q.Xyz.z, 1 - 2.0 * (q.Xyz.z * q.Xyz.z + q.W * q.W) ); // Yaw
	v.x = asin( 2.0 * (q.Xyz.x * q.Xyz.z - q.W * q.Xyz.y) ); // Pitch
	v.z = atan2( 2.0 * q.Xyz.x * q.Xyz.y + 2.0 * q.Xyz.z * q.W, 1 - 2.0 * (q.Xyz.y * q.Xyz.y + q.Xyz.z * q.Xyz.z) ); // Roll
	return Quaternion_NormalizeAngles( v * RAD_TO_DEG );

}

Quaternion function Quaternion_Multiply( Quaternion left, Quaternion right )
{
	Quaternion out;
	out.Xyz = right.W * left.Xyz + left.W * right.Xyz + CrossProduct( left.Xyz, right.Xyz );
	out.W = left.W * right.W - DotProduct( left.Xyz, right.Xyz );
	return out;
}

Quaternion function Quaternion_AngleAxis( float degrees, vector axis )
{
	Quaternion result;

	float radians = DegToRad( degrees );
	radians *= 0.5;

	vector rotateAxis = Normalize( axis );
	rotateAxis = rotateAxis * sin( radians );
	result.Xyz = rotateAxis;
	result.W = cos( radians );

	// Normalize
	float scale = 1.0 / sqrt( result.W * result.W + LengthSqr( result.Xyz ) );
	result.Xyz *= scale;
	result.W *= scale;

	return result;
}

vector function Quaternion_NormalizeAngles( vector angles )
{
	return Vector(
		Quaternion_NormalizeAngle( angles.x ),
		Quaternion_NormalizeAngle( angles.y ),
		Quaternion_NormalizeAngle( angles.z ),
	);
}

float function Quaternion_NormalizeAngle( float angle )
{
	while( angle > 360 )
		angle -= 360;
	while( angle < 0 )
		angle += 360;
	return angle;
}
