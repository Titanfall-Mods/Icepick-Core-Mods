
bool function Toolgun_Func_RemoveProp( entity player, array<string> args )
{
#if SERVER
	vector eyePosition = player.EyePosition()
	vector viewVector = player.GetViewVector()
	TraceResults traceResults = TraceLine( eyePosition, eyePosition + viewVector * 10000, player, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )
	if( traceResults.hitEnt && traceResults.hitEnt.GetClassName() != "prop_static" )
	{
		Toolgun_Utils_FireToolTracer( player );
		traceResults.hitEnt.Destroy();
		return true
	}
	return false
#else
	return false
#endif
}
