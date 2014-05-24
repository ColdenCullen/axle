module app;

import frontend.parser, backend.dgen;
import std.stdio, std.path, std.process;

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
		auto xmlFileName = args[1].stripExtension ~ ".xml";

		writeln( "Translating..." );

		// Translate the code
		auto gen = new DGenerator;
		gen.output = File( outFileName, "w" );
		gen.visit( parseFile( args[ 1 ] ) );

		auto gen2 = new XMLPrinter;
		gen2.output = File( xmlFileName, "w" );
		gen2.visit( parseFile( args[ 1 ] ) );
		
		writeln( "Executing..." );

		// Call rdmd on file
		//wait( spawnProcess( [ "rdmd", outFileName ] ));//~ ( args.length > 2 ? args[ 2..$-1 ] : [] ) ) );
	}
}

void printHelp()
{

}
