module app;

import frontend.parser, backend.dgen;
import std.stdio, std.path;

void main( string[] args )
{
	if( args.length == 1 )
	{
		printHelp();
	}
	else
	{
		// Get name of file to write to
		auto outFileName = args[1].stripExtension ~ ".d";

		// Translate the code
		auto gen = new DGenerator;
		gen.output = File( outFileName, "w" );
		gen.visit( parseFile( args[ 1 ] ) );
		
		// Call rdmd on file
		//wait( spawnProcess( [ "rdmd", outFileName ] ~ ( args.length > 2 ? args[ 2..$-1 ] : [] ) ) );
	}
}

void printHelp()
{

}
