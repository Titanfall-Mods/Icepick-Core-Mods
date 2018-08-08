untyped

global function CustomGauntlet_Think_Topology
global function ServerCallback_CustomGauntlet_SendStartFinishLine

const float SCOREBOARD_SIZE_W = 120.0;
const float SCOREBOARD_SIZE_H = 120.0;
const float SCOREBOARD_OFFSET_H = -120.0;
const float STATS_SIZE_W = 200.0;
const float STATS_SIZE_H = 120.0;
const float STATS_OFFSET_H = -120.0;

void function CustomGauntlet_Think_Topology()
{
	while( true )
	{
		CustomGauntlet_Think_UpdateTrackTopologies( CustomGauntletsGlobal.DevelopmentTrack, true );

		for( int i = 0; i < CustomGauntletsGlobal.RegisteredTracks.len(); ++i )
		{
			CustomGauntlet_Think_UpdateTrackTopologies( CustomGauntletsGlobal.RegisteredTracks[i] );
		}

		WaitFrame();
	}
}

void function CustomGauntlet_Think_UpdateTrackTopologies( GauntletTrack Track, bool RequireRefEnt = false )
{
	// Scoreboards
	for( int i = Track.Scoreboards.len() - 1; i >= 0; --i )
	{
		GauntletWorldUI CurrentUI = Track.Scoreboards[i];

		// Remove world ui if the reference has been deleted
		if( RequireRefEnt && !IsValid( CurrentUI.ReferenceEnt ) )
		{
			RuiTopology_Destroy( CurrentUI.Topology );
			RuiDestroy( CurrentUI.Rui );
			Track.Scoreboards.remove( i );
			continue;
		}

		// Create topology if it doesn't exist
		if( CurrentUI.Topology == null || CustomGauntlet_DoTopologiesNeedRefreshing() )
		{
			CurrentUI.Topology = CustomGauntlet_CreateCentredTopology( CurrentUI.ReferenceEnt.GetOrigin(), CurrentUI.ReferenceEnt.GetAngles(), SCOREBOARD_SIZE_W, SCOREBOARD_SIZE_H, 0.0, SCOREBOARD_OFFSET_H );
		}

		// Update topology position
		if( IsValid( CurrentUI.Topology ) && IsValid( CurrentUI.ReferenceEnt ) )
		{
			vector NewOrigin = CurrentUI.ReferenceEnt.GetOrigin();
			vector NewAngles = CurrentUI.ReferenceEnt.GetAngles();
			CustomGauntlet_UpdateCentredTopology( CurrentUI.Topology, NewOrigin, NewAngles, SCOREBOARD_SIZE_W, SCOREBOARD_SIZE_H, 0.0, SCOREBOARD_OFFSET_H );
		}

		// Create RUI if it doesn't exist
		if( CurrentUI.Rui == null )
		{
			CurrentUI.Rui = RuiCreate( $"ui/gauntlet_leaderboard.rpak", CurrentUI.Topology, RUI_DRAW_WORLD, 0 );
		}
	}

	// Stats Boards
	for( int i = Track.StatsBoards.len() - 1; i >= 0; --i )
	{
		GauntletWorldUI CurrentUI = Track.StatsBoards[i];

		// Remove world ui if the reference has been deleted
		if( RequireRefEnt && !IsValid( CurrentUI.ReferenceEnt ) )
		{
			RuiTopology_Destroy( CurrentUI.Topology );
			RuiDestroy( CurrentUI.Rui );
			Track.StatsBoards.remove( i );
			continue;
		}

		// Create topology if it doesn't exist
		if( CurrentUI.Topology == null )
		{
			CurrentUI.Topology = CustomGauntlet_CreateCentredTopology( CurrentUI.ReferenceEnt.GetOrigin(), CurrentUI.ReferenceEnt.GetAngles(), STATS_SIZE_W, STATS_SIZE_H, 0.0, STATS_OFFSET_H );
		}

		// Update topology position
		if( IsValid( CurrentUI.Topology ) && IsValid( CurrentUI.ReferenceEnt ) )
		{
			vector NewOrigin = CurrentUI.ReferenceEnt.GetOrigin();
			vector NewAngles = CurrentUI.ReferenceEnt.GetAngles();
			CustomGauntlet_UpdateCentredTopology( CurrentUI.Topology, NewOrigin, NewAngles, STATS_SIZE_W, STATS_SIZE_H, 0.0, STATS_OFFSET_H );
		}

		// Create RUI if it doesn't exist
		if( CurrentUI.Rui == null )
		{
			CurrentUI.Rui = RuiCreate( $"ui/gauntlet_results_display.rpak", CurrentUI.Topology, RUI_DRAW_WORLD, 0 );
		}
	}
}

// -----------------------------------------------------------------------------

void function ServerCallback_CustomGauntlet_SendStartFinishLine( int type, int leftEntIdx, int rightEntIdx, float triggerHeight )
{
	entity left = GetEntityFromEncodedEHandle( leftEntIdx );
	entity right = GetEntityFromEncodedEHandle( rightEntIdx );

	// Check if we're just updating an existing gate
	for( int i = CustomGauntletsGlobal.DevelopmentTrack.Starts.len() - 1; i >= 0; --i )
	{
		GauntletTriggerLine startLine = CustomGauntletsGlobal.DevelopmentTrack.Starts[i];
		if( startLine.left == left && startLine.right == right )
		{
			startLine.triggerHeight = triggerHeight;
			return; // Early exit since the thread will automatically update it
		}
	}
	for( int i = CustomGauntletsGlobal.DevelopmentTrack.Finishes.len() - 1; i >= 0; --i )
	{
		GauntletTriggerLine finishLine = CustomGauntletsGlobal.DevelopmentTrack.Finishes[i];
		if( finishLine.left == left && finishLine.right == right )
		{
			finishLine.triggerHeight = triggerHeight;
			return; // Early exit since the thread will automatically update it
		}
	}

	GauntletTriggerLine triggerLine;
	triggerLine.left = left;
	triggerLine.right = right;
	triggerLine.triggerHeight = triggerHeight;

	string displayText = "NO TEXT";
	switch( type )
	{
		case 0:
			CustomGauntletsGlobal.DevelopmentTrack.Starts.append( triggerLine );
			displayText = "#GAUNTLET_START_TEXT";
			break;
		case 1:
			CustomGauntletsGlobal.DevelopmentTrack.Finishes.append( triggerLine );
			displayText = "#GAUNTLET_FINISH_TEXT";
			break;
	}

	vector zeroVector = Vector( 0, 0, 0 );
	triggerLine.topo = CustomGauntlet_CreateCentredTopology( zeroVector, zeroVector );
	triggerLine.rui = RuiCreate( $"ui/gauntlet_starting_line.rpak", triggerLine.topo, RUI_DRAW_WORLD, 0 );
	RuiSetString( triggerLine.rui, "displayText", displayText );

	thread CustomGauntlet_StartLine_Think( triggerLine );
	thread UpdateStartFinishLineTopology( triggerLine );
}

void function UpdateStartFinishLineTopology( GauntletTriggerLine triggerLine )
{
	EndSignal( triggerLine.left, "OnDestroy" );
	EndSignal( triggerLine.right, "OnDestroy" );

	OnThreadEnd(
		function() : ( triggerLine )
		{
			RuiDestroyIfAlive( triggerLine.rui );
			RuiTopology_Destroy( triggerLine.topo );

			for( int i = CustomGauntletsGlobal.DevelopmentTrack.Starts.len() - 1; i >= 0; --i )
			{
				if( triggerLine == CustomGauntletsGlobal.DevelopmentTrack.Starts[i] )
				{
					CustomGauntletsGlobal.DevelopmentTrack.Starts.remove( i );
					break;
				}
			}
			for( int i = CustomGauntletsGlobal.DevelopmentTrack.Finishes.len() - 1; i >= 0; --i )
			{
				if( triggerLine == CustomGauntletsGlobal.DevelopmentTrack.Finishes[i] )
				{
					CustomGauntletsGlobal.DevelopmentTrack.Finishes.remove( i );
					break;
				}
			}
		}
	)

	while( true )
	{
		wait 0.1;

		vector leftOrigin = triggerLine.left.GetOrigin();
		vector rightOrigin = triggerLine.right.GetOrigin();
		float width = Distance( leftOrigin, rightOrigin ) * 0.5;
		width = width < 60.0 ? 60.0 : width;
		float height = width * 0.5;
		if( height > triggerLine.triggerHeight * 0.66 )
		{
			height = triggerLine.triggerHeight * 0.66;
			width = height * 2.0;
		}

		vector topoOrigin = ( leftOrigin + rightOrigin ) / 2.0 + < 0, 0, triggerLine.triggerHeight * 0.5 >;
		vector topoAngles = VectorToAngles( rightOrigin - leftOrigin ) + < 0, 90, 0 >;
		topoAngles = < 0, topoAngles.y, 0 >;
		CustomGauntlet_UpdateCentredTopology( triggerLine.topo, topoOrigin, topoAngles, width, height );
	}
}

// -----------------------------------------------------------------------------

vector function _CustomGauntlet_Topology_GetPos( vector Pos, vector Ang, float Width, float Height )
{
	Pos += ( (AnglesToRight( Ang ) * -1) * (Width * 0.5) );
	Pos += ( AnglesToUp( Ang ) * (Height * 0.5) );
	return Pos;
}

var function CustomGauntlet_CreateCentredTopology( vector Pos, vector Ang, float Width = 60, float Height = 30, float WidthOffset = 0, float HeightOffset = 0 )
{
	Pos = _CustomGauntlet_Topology_GetPos( Pos, Ang, Width, Height );
	Pos.z -= HeightOffset;
	vector Right = ( AnglesToRight( Ang ) * Width );
	vector Down = ( (AnglesToUp( Ang ) * -1) * Height );
	return RuiTopology_CreatePlane( Pos, Right, Down, true );
}

var function CustomGauntlet_UpdateCentredTopology( var Topo, vector Pos, vector Ang, float Width = 60, float Height = 30, float WidthOffset = 0, float HeightOffset = 0 )
{
	Pos = _CustomGauntlet_Topology_GetPos( Pos, Ang, Width, Height );
	Pos.z -= HeightOffset;
	vector Right = ( AnglesToRight( Ang ) * Width );
	vector Down = ( (AnglesToUp( Ang ) * -1) * Height );
	return RuiTopology_UpdatePos( Topo, Pos, Right, Down );
}
