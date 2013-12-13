import std.stdio, std.conv;
import frontend.scanner;

void main()
{
	string input;

	while( true )
	{
		writefln( "Enter a string of tokens." );
		input = readln();

		foreach( token; Scanner.getAllTokens( input ) )
		{
			writeln( "Token: '" ~ token.token ~ "'\tType: '" ~ to!string( token.type ) ~ "'" );
		}
	}
}
