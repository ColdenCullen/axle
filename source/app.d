import console.scanner;
import std.stdio;

void main( string[] args )
{
	switch( args[ 1 ] )
	{
		case "scanner":
			runTerminal();
			break;
		default:
			writeln( args );
			printHelp();
	}
}

void printHelp()
{

}
