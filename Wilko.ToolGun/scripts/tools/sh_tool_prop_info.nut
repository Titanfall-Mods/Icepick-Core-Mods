
bool function Toolgun_Func_PropInfo( entity player, array<string> args )
{
#if SERVER
	Toolgun_Utils_FireToolTracer( player );
	return false;
#else
	vector eyePosition = player.EyePosition()
	vector viewVector = player.GetViewVector()
	TraceResults traceResults = TraceLine( eyePosition, eyePosition + viewVector * 10000, player, TRACE_MASK_PLAYERSOLID | TRACE_MASK_TITANSOLID | TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_NONE )
	if( traceResults.hitEnt )
	{
		AddPlayerHint( 2.0, 0.25, $"", "Output " + traceResults.hitEnt.GetModelName() + " to console" )
		printc( "Model: ", traceResults.hitEnt.GetModelName() )
		return true
	}
	return false
#endif
}
