globalize_all_functions

global struct Quaternion
{
	vector Xyz,
	float W = 1.0,
}

global struct Matrix3x4
{
	array<float> Row0 = [0.0,0.0,0.0,0.0],
	array<float> Row1 = [0.0,0.0,0.0,0.0],
	array<float> Row2 = [0.0,0.0,0.0,0.0],
}

global struct Matrix3x3
{
	array<vector> Rows = [Vector(0,0,0), Vector(0,0,0), Vector(0,0,0)],
}

Quaternion function toQuaternion( vector angles )
{
	Quaternion out;

	float cr = cos( DegToRad( angles.z ) * 0.5 );
	float sr = sin( DegToRad( angles.z ) * 0.5 );
	float cy = cos( DegToRad( angles.y ) * 0.5 );
	float sy = sin( DegToRad( angles.y ) * 0.5 );
	float cp = cos( DegToRad( angles.x ) * 0.5 );
	float sp = sin( DegToRad( angles.x ) * 0.5 );

	out.W = cy * cr * cp + sy * sr * sp;
	float x = cy * sr * cp - sy * cr * sp;
	float y = cy * cr * sp + sy * sr * cp;
	float z = sy * cr * cp - cy * sr * sp;
	
	out.Xyz = Vector( x, y, z );
	return out;
}

Quaternion function Quaternion_Invert( Quaternion q )
{
	float lengthSq = (q.W * q.W) + (q.Xyz.x * q.Xyz.x) + (q.Xyz.y * q.Xyz.y) + (q.Xyz.z * q.Xyz.z);
	if (lengthSq != 0.0) {
		float i = 1.0 / lengthSq;
		Quaternion out;
		out.Xyz = q.Xyz * -i;
		out.W = q.W * i;
		return out;
	}
	return q;
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

	float radians = DegToRad( degrees ) * 0.5;

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

Matrix3x3 function Quaternion_Matrix( Quaternion q )
{
	Matrix3x3 result;

	result.Rows[0] = Vector(
		1.0 - 2.0 * q.Xyz.y * q.Xyz.y - 2.0 * q.Xyz.z * q.Xyz.z,
		2.0 * q.Xyz.x * q.Xyz.y - 2.0 * q.W * q.Xyz.z,
		2.0 * q.Xyz.x * q.Xyz.z + 2.0 * q.W * q.Xyz.y
	);

	result.Rows[1] = Vector(
		2.0 * q.Xyz.x * q.Xyz.y + 2.0 * q.W * q.Xyz.z,
		1.0 - 2.0 * q.Xyz.x * q.Xyz.x - 2.0 * q.Xyz.z * q.Xyz.z,
		2.0 * q.Xyz.y * q.Xyz.z - 2.0 * q.W * q.Xyz.x
	);

	result.Rows[2] = Vector(
		2.0 * q.Xyz.x * q.Xyz.z - 2.0 * q.W * q.Xyz.y,
		2.0 * q.Xyz.y * q.Xyz.z + 2.0 * q.W * q.Xyz.x,
		1.0 - 2.0 * q.Xyz.x * q.Xyz.x - 2.0 * q.Xyz.y * q.Xyz.y
	);

	return result;
}

vector function Matrix3x3_Angles( Matrix3x3 matrix )
{
	vector result;

	vector forward = Vector( matrix.Rows[0].x, matrix.Rows[1].x, matrix.Rows[2].x );
	vector left = Vector( matrix.Rows[0].y, matrix.Rows[1].y, matrix.Rows[2].y );
	vector up = Vector( 0.0, 0.0, matrix.Rows[2].z ); // Don't need X or Y for up basis vector

	float xyDist = sqrt( forward.x * forward.x + forward.y * forward.y );

	if ( xyDist > 0.001 )
	{
		result.y = RAD_TO_DEG * atan2( forward.y, forward.x ); // yaw
		result.x = RAD_TO_DEG * atan2( -forward.z, xyDist ); // pitch
		result.z = RAD_TO_DEG * atan2( left.z, up.z ); // roll
	}
	else // gimbal lock
	{
	    result.y = RAD_TO_DEG * atan2( -left.x, left.y ); // yaw
	    result.x = RAD_TO_DEG * atan2( -forward.z, xyDist ); // pitch
	    result.z = 0.0; // roll
	}

	return result;
}

vector function Quaternion_Angles( Quaternion q )
{
	Matrix3x3 matrix = Quaternion_Matrix( q );
	return Matrix3x3_Angles( matrix );
}

vector function Vector_Rotate( vector vec, Matrix3x3 matrix )
{
	vector result;
	result.x = DotProduct( vec, matrix.Rows[0] );
	result.y = DotProduct( vec, matrix.Rows[1] );
	result.z = DotProduct( vec, matrix.Rows[2] );
	return result;
}

vector function Quaternion_VectorMultiply( Quaternion quat, vector vec )
{
	Matrix3x3 matRotate = Quaternion_Matrix( quat );
	return Vector_Rotate( vec, matRotate );
}
