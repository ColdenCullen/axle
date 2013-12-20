module console.scanner;
import frontend.scanner;

import std.stdio;

void runTerminal()
{
	uint inputs = 0;
	
	while( true )
	{
		writef( "%s> ", inputs++ );
		string input = readln();
		
		foreach( token; Scanner.getAllTokens( input ) )
		{
			writeln( "Token: '" ~ token.toString ~ "'\tType: '" ~ token.classinfo.name ~ "'" );
		}
	}
}
