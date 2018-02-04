
void function printc( ... )
{
	thread Dump_printc()
	for( int i = 0; i < vargc; i++ )
	{
		DevTextBufferWrite( "" + vargv[i] )
		if( i + 1 < vargc )
		{
			DevTextBufferWrite( "\t" )
		}
	}
}

void function Dump_printc()
{
	WaitFrame()
	DevTextBufferDumpToFile( "../console_log.txt" )
	DevTextBufferClear()
}
