untyped

global function CustomGauntlet_TrackPlayerSpeed

// Mostly copied from _cl_gauntlet.gnut, but whatever

struct CustomGauntletPlayerSpeedTracker
{
	float startTime 	= -1
	float topSpeed 		= 0.0
	float avgSpeed 		= 0.0
	float highSpeedTime = 0.0
	int highSpeedKills 	= 0
	float totalHours 	= 0.0
	float totalMiles 	= 0.0
}

void function CustomGauntlet_TrackPlayerSpeed()
{
	entity player = GetLocalClientPlayer();
	RuiTrackFloat3( CustomGauntletsUI.PlayerHudRui, "playerPos", player, RUI_TRACK_ABSORIGIN_FOLLOW );

	const float inchesPerMile = 63360.0;
	const float secondsPerHour = 3600.0;
	const bool useMetric = true;

	const float MPH_TO_KPH_SCALAR = 1.60934;
	const float HIGH_SPEED_THRESHOLD_KPH = 30.0;
	const float HIGH_SPEED_THRESHOLD_MPH = HIGH_SPEED_THRESHOLD_KPH / MPH_TO_KPH_SCALAR;
	const float SPEEDOMETER_PLAYERPOS_Z_SCALAR = 0.25;  // how much of the Z axis position change to include in the MPH calculation
	const float SPEEDOMETER_ARC_MAX_SPEED_MPH = 27.5;
	const float SPEEDOMETER_ARC_MAX_SPEED_KPH = SPEEDOMETER_ARC_MAX_SPEED_MPH * MPH_TO_KPH_SCALAR;
	const float SPEEDOMETER_MAX_INCHES_PER_TICK = 128.0;

	RuiSetBool( CustomGauntletsUI.PlayerHudRui, "useMetric", useMetric );

	CustomGauntletPlayerSpeedTracker tracker;
	tracker.startTime = Time();

	vector lastPos = player.GetOrigin();
	float lastTime = Time();
	int lastEnemiesKilled = 0;
	float tickWait = 0.1;
	int numTicks = 0;

	while( true )
	{
		wait tickWait;
		numTicks++;

		float lastTickDuration = 0;
		if ( lastTime > 0 );
			lastTickDuration = Time() - lastTime;

		vector currPos = player.GetOrigin();

		vector playerPos_adjusted 		= <currPos.x, currPos.y, currPos.z * SPEEDOMETER_PLAYERPOS_Z_SCALAR>;
		vector lastPlayerPos_adjusted 	= <lastPos.x, lastPos.y, lastPos.z * SPEEDOMETER_PLAYERPOS_Z_SCALAR>;
		float inchesSinceLastTick = Distance( playerPos_adjusted, lastPlayerPos_adjusted );

		// if player gets teleported or we just started, don't count it
		// - HACK re numTicks- first tick always seems to calculate an artificially high distance traveled
		if ( inchesSinceLastTick <= SPEEDOMETER_MAX_INCHES_PER_TICK && lastTickDuration > 0 && numTicks > 1 )
		{
			int enemiesKilledThisTick = 0;
			int TotalKilled = GetLocalClientPlayer().GetPlayerNetInt( "CGEnemiesKilled" );
			if ( lastEnemiesKilled < TotalKilled )
			{
				enemiesKilledThisTick = TotalKilled - lastEnemiesKilled;
				lastEnemiesKilled = TotalKilled;
			}

			float milesSinceLastTick = inchesSinceLastTick / inchesPerMile;
			float hoursSinceLastTick = lastTickDuration / secondsPerHour;

			tracker.totalHours += hoursSinceLastTick;
			tracker.totalMiles += milesSinceLastTick;

			float avgSpeedMPH_sinceLastTick = milesSinceLastTick / hoursSinceLastTick;
			//printt( "Tick", numTicks, "inchesSinceLastTick:", inchesSinceLastTick, "lastTickDuration:", lastTickDuration )
			//printt( "avg speed:", avgSpeedMPH_sinceLastTick * MPH_TO_KPH_SCALAR, "kph, hoursSinceLastTick:", hoursSinceLastTick )

			if ( avgSpeedMPH_sinceLastTick >= tracker.topSpeed )
			{
				tracker.topSpeed = avgSpeedMPH_sinceLastTick;
				//printt( "!!!!!!!! NEW TOP SPEED:", tracker.topSpeed * MPH_TO_KPH_SCALAR, "kph" )
			}

			if ( avgSpeedMPH_sinceLastTick > HIGH_SPEED_THRESHOLD_MPH )
			{
				tracker.highSpeedTime += lastTickDuration;
				tracker.highSpeedKills += enemiesKilledThisTick;
			}
		}
		else
		{
			#if DEV
			if ( inchesSinceLastTick > SPEEDOMETER_MAX_INCHES_PER_TICK )
				printt( "CLIENT SPEEDO couldn't track player because inchesSinceLastTick was too high:", inchesSinceLastTick );

			if ( lastTickDuration <= 0 )
				printt( "CLIENT SPEEDO couldn't track player because lastTickDuration was 0 or less" );
			#endif
		}

		lastPos = currPos;
		lastTime = Time();

		// If aborted or finished then break out of the update
		if( !GauntletRuntimeData.IsActive )
		{
			break;
		}
	}

	// Finished, update results
	if ( IsValid( player ) && numTicks >= 2 )
	{
		float avgSpeed = tracker.totalMiles / tracker.totalHours;
		float avgSpeedKPH = avgSpeed * MPH_TO_KPH_SCALAR;
		float topSpeedKPH = tracker.topSpeed * MPH_TO_KPH_SCALAR;
		tracker.avgSpeed = avgSpeedKPH;
		tracker.topSpeed = topSpeedKPH;

		// printt( "Run avgSpeed", tracker.avgSpeed, "kph" )
		// printt( "Run topSpeed", tracker.topSpeed, "kph" )
		// printt( "Run total time", Time() - tracker.startTime, "secs" )
		// printt( "Run highSpeedTime", tracker.highSpeedTime )
		// printt( "Run highSpeedKills", tracker.highSpeedKills )

		float highSpeedPercent = (tracker.highSpeedTime / (Time() - tracker.startTime)) * 100
		// printt( "Run highSpeedPercent", highSpeedPercent )

		if ( tracker.avgSpeed >= 0 )
		{
			CustomGauntlet_SetStatsBoardFloat( GauntletRuntimeData.ActiveTrack, "avgSpeed", tracker.avgSpeed );
		}
		if ( tracker.topSpeed >= 0 )
		{
			CustomGauntlet_SetStatsBoardFloat( GauntletRuntimeData.ActiveTrack, "topSpeed", tracker.topSpeed );
		}
		if ( highSpeedPercent >= 0 )
		{
			CustomGauntlet_SetStatsBoardFloat( GauntletRuntimeData.ActiveTrack, "highSpeedPercent", highSpeedPercent );
		}
		if ( tracker.highSpeedKills >= 0 )
		{
			CustomGauntlet_SetStatsBoardInt( GauntletRuntimeData.ActiveTrack, "highSpeedKills", tracker.highSpeedKills );
		}
	}
}
