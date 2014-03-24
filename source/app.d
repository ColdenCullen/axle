module app;

import frontend.parser, backend.dgen;
import std.stdio;

void main( string[] args )
{
	if( args.length == 1 )
	{
		printHelp();
	}
	else
	{
		auto mod = parseFile( args[ 1 ] );

		auto gen = new DGenerator;
		auto outfile = File( "test.d", "w" );
		gen.output = outfile;

		gen.visit( mod );
	}
}

void printHelp()
{

}
