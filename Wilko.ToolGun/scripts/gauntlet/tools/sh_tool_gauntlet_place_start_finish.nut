
vector function Toolgun_Func_Gauntlet_GetPlaceLocation( entity player )
{
	vector eyePosition = player.EyePosition()
	vector viewVector = player.GetViewVector()
	TraceResults traceResults = TraceLine( eyePosition, eyePosition + viewVector * 10000, player, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )
	return traceResults.endPos;
}

vector function Toolgun_Func_Gauntlet_GetSurfaceNormal( entity player )
{
	vector eyePosition = player.EyePosition()
	vector viewVector = player.GetViewVector()
	TraceResults traceResults = TraceLine( eyePosition, eyePosition + viewVector * 10000, player, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )
	return traceResults.surfaceNormal;
}

vector function Toolgun_Func_Gauntlet_GetPlayerYaw( entity player )
{
	vector PlayerYaw = VectorToAngles( player.GetViewVector() );
	PlayerYaw.x = 0;
	PlayerYaw.z = 0;
	return PlayerYaw;
}

bool function Toolgun_Func_Gauntlet_PlaceStart( entity player, array<string> args )
{
#if CLIENT
	vector AimPos = Toolgun_Func_Gauntlet_GetPlaceLocation( player );
	vector PlayerYaw = Toolgun_Func_Gauntlet_GetPlayerYaw( player );
	CustomGauntlet_PlaceStartLine( AimPos + Vector(0, 0, 40), PlayerYaw );

	return true;
#else
	Toolgun_Utils_FireToolTracer( player );
	return false;
#endif
}

bool function Toolgun_Func_Gauntlet_PlaceFinish( entity player, array<string> args )
{
#if CLIENT
	vector AimPos = Toolgun_Func_Gauntlet_GetPlaceLocation( player );
	vector PlayerYaw = Toolgun_Func_Gauntlet_GetPlayerYaw( player );
	CustomGauntlet_PlaceFinishLine( AimPos + Vector(0, 0, 40), PlayerYaw );

	return true;
#else
	Toolgun_Utils_FireToolTracer( player );
	return false;
#endif
}

bool function Toolgun_Func_Gauntlet_PlaceTarget( entity player, array<string> args )
{
#if CLIENT
	vector AimPos = Toolgun_Func_Gauntlet_GetPlaceLocation( player );
	vector PlayerYaw = Toolgun_Func_Gauntlet_GetPlayerYaw( player );
	CustomGauntlet_PlaceTarget( AimPos, PlayerYaw + <0, 180, 0> );

	return true;
#else
	Toolgun_Utils_FireToolTracer( player );
	return false;
#endif
}

bool function Toolgun_Func_Gauntlet_PlaceLeaderboard( entity player, array<string> args )
{
#if CLIENT
	vector AimPos = Toolgun_Func_Gauntlet_GetPlaceLocation( player );
	vector SurfaceNormal = Toolgun_Func_Gauntlet_GetSurfaceNormal( player );
	vector Pos = AimPos + SurfaceNormal * 5.0;
	vector NormalAngs = VectorToAngles(SurfaceNormal) * -1;

	CustomGauntlet_PlaceLeaderboard( Pos, NormalAngs );

	return true;
#else
	Toolgun_Utils_FireToolTracer( player );
	return false;
#endif
}

bool function Toolgun_Func_Gauntlet_PlaceResults( entity player, array<string> args )
{
#if CLIENT
	vector AimPos = Toolgun_Func_Gauntlet_GetPlaceLocation( player );
	vector SurfaceNormal = Toolgun_Func_Gauntlet_GetSurfaceNormal( player );
	vector Pos = AimPos + SurfaceNormal * 5.0;
	vector NormalAngs = VectorToAngles(SurfaceNormal) * -1;

	CustomGauntlet_PlaceResults( Pos, NormalAngs );

	return true;
#else
	Toolgun_Utils_FireToolTracer( player );
	return false;
#endif
}

