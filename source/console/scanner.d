module console.scanner;
import frontend.scanner;

import std.stdio;

void runTerminal()
{
	uint inputs = 0;
	
	while( true )
	{
		writef( "%s> ", inputs++ );
		
		foreach( token; Scanner.getAllTokens( readln() ) )
		{
			writeln( "Token: '", token.toString, "'\tType: '", typeid(token).name, "'\tIs Valid: ", token.isValid  );
		}
	}
}
