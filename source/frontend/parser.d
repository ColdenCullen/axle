module frontend.parser;

import stdx.allocator;
import stdx.d.parser, stdx.d.ast, stdx.d.lexer;
import std.file, std.array;

void doNothing( string, size_t, size_t, string, bool ) { }

Module parseFile( string fileName )
{
	Token[] tokens;
	foreach( token; byToken( cast(ubyte[])read( fileName ) ) )
		tokens ~= token;

	return parseWSDModule( tokens, fileName, null, &doNothing );
}

Module parseWSDModule( const(Token)[] tokens, string fileName, CAllocator allocator = null,
					void function(string, size_t, size_t, string, bool) messageFunction = null )
{
	auto parser = new WSDParser();
	parser.fileName = fileName;
	parser.tokens = tokens;
	parser.messageFunction = messageFunction;
	parser.allocator = allocator;
	auto mod = parser.parseModule();
	// writefln("Parsing finished with %d errors and %d warnings.",
	//     parser.errorCount, parser.warningCount);
	return mod;
}

class WSDParser : Parser
{

}
