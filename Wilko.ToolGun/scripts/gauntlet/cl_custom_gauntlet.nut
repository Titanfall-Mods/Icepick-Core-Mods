
#if CLIENT

void function CustomGauntlet_Client_Init()
{
	
}

void function ServerCallback_CustomGauntlet_ShowError( int ErrorIdx )
{
	switch ( ErrorIdx )
	{
		case 1:
			CustomGauntlet_ShowError( "Remove the existing start line to place a new one!" );
			break;
		case 2:
			CustomGauntlet_ShowError( "Remove the existing finish line to place a new one!" );
			break;
	}
}

void function CustomGauntlet_ShowError( string Message )
{
	SmartAmmo_SetStatusWarning( Message, 2.0 );
}

#endif
