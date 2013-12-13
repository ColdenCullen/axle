import std.stdio, std.conv;
import frontend.scanner, frontend.tokens;

void main()
{
	string input;

	while( true )
	{
		writefln( "Enter a string of tokens." );
		input = readln();

		foreach( token; Scanner.getAllTokens( input ) )
		{
			writeln( "Token: '" ~ token.toString ~ "'\tType: '" ~ token.classinfo.name ~ "'" );
		}
	}
}