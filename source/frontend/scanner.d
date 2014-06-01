module frontend.scanner;
import frontend.tokens;

import std.range;

private struct Character
{
    char character;
    Type type;

    enum Type
    {
        Whitespace,
        Alpha,
        Underscore,
        Zero,
        OneNine,
        Dot,
        Semicolon,
        Assignment,
        SingleQuote,
        DoubleQuote,
        Asterisk,
        Slash,
        Other,
    }

    this( char newChar )
    {
        import std.typecons, std.conv;
        // Generate the case for a letter or group of letters.
        string letter( Letters... )( Type type, Letters chars )
        {
            import std.string, std.traits;
            string charToString( char ch )
            {
                auto newChar = ch.to!string
                    .replace( "\n", "\\n" )
                    .replace( "\t", "\\t" )
                    .replace( "\"", "\\\"" )
                    .replace( "'", "\\\'" );
                return ( "'" ~ newChar ~ "'" );
            }
            string str = "";
            foreach( ch; chars )
            {
                // If is tuple for range.
                static if( hasLength!( typeof(ch) ) && ch.length == 2 )
                {
                    str ~= q{
                        case $begin: .. case $end:
                    }
                    .replace( "$begin", charToString( ch[ 0 ] ) )
                    .replace( "$end", charToString( ch[ 1 ] ) );
                }
                else
                {
                    str ~= q{
                        case $letter:
                    }.replace( "$letter", charToString( ch ) );
                }
            }

            return str ~ q{
                type = Type.$type; break;
            }.replace( "$type", type.to!string ).strip;
        }

        character = newChar;

        switch( character )
        {
            mixin( letter( Type.Whitespace, '\t', '\n', ' ' ) );
            mixin( letter( Type.Alpha, tuple( 'a', 'z' ), tuple( 'A', 'Z' ) ) );
            mixin( letter( Type.Underscore, '_' ) );
            mixin( letter( Type.Zero, '0' ) );
            mixin( letter( Type.Dot, '.' ) );
            mixin( letter( Type.Assignment, '=' ) );
            mixin( letter( Type.OneNine, tuple( '1', '9' ) ) );
            mixin( letter( Type.Semicolon, ';' ) );
            mixin( letter( Type.SingleQuote, '\'' ) );
            mixin( letter( Type.DoubleQuote, '\"' ) );
            mixin( letter( Type.Asterisk, '*' ) );
            mixin( letter( Type.Slash, '/' ) );
            default: type = Type.Other; break;
        }
    }

    unittest
    {
        auto space = Character( ' ' );
        assert( space.character == ' ' );
        assert( space.type == Type.Whitespace );

        auto a = Character( 'a' );
        assert( a.character == 'a' );
        assert( a.type == Type.Alpha );

        auto singleQuote = Character( '\'' );
        assert( singleQuote.character == '\'' );
        assert( singleQuote.type == Type.SingleQuote );
    }
}

class Scanner
{
public:
    this( string stringToParse )
    {
        import std.algorithm, std.array : array;
        workingString = stringToParse.map!( ch => Character( cast(char)ch ) ).array;

        // ======================================
        // Functions for parsing
        // ======================================
        void ignore( Character newChar ) { }

        void identifier_start( Character newChar )
        {
            currentToken = new IdentifierToken();
            save( newChar );
        }

        void number_start( Character newChar )
        {
            currentToken = new IntegerToken();
            save( newChar );
        }

        void number_decimal( Character newChar )
        {
            if( auto intTok = cast(IntegerToken)currentToken )
                currentToken = intTok.toDecimal;
            else
                currentToken.isValid = false;

            currentToken.addChar( newChar.character );
            consume();
        }

        void operator_start( Character newChar )
        {
            currentToken = new OperatorToken;
            save( newChar );
        }

        void operator_working( Character newChar )
        {
            save( newChar );

            if( (cast(OperatorToken)currentToken).type == OperatorToken.OperatorType.DoubleSlash )
            {
                currentToken = new CommentToken( CommentToken.CommentType.SingleLine );
                currentToken.token = "//";
                currentState = TokenState.Comment;
            }
        }

        void semicolon( Character newChar )
        {
            currentToken = new SemicolonToken;
            consume();
        }

        void comment( Character newChar )
        {
            auto com = cast(CommentToken)currentToken;

            switch( com.type ) with( CommentToken.CommentType )
            {
                case SingleLine:
                    if( newChar.character == '\n' )
                    {
                        currentState = TokenState.End;
                        return;
                    }
                    break;
                default:
                    break;
            }

            save( newChar );
        }

        void invalid( Character newChar )
        {
            if( !currentToken )
            {
                currentToken = new IdentifierToken();
            }

            save( newChar );
            currentToken.isValid = false;
        }

        import std.traits;

        // Set default to invalid.
        foreach( state; EnumMembers!TokenState )
            foreach( type; EnumMembers!( Character.Type ) )
                tm[ state ][ type ] = TmEntry( state, &invalid );

        // Make comments eat everything.
        foreach( member; EnumMembers!( Character.Type ) )
            tm[ TokenState.Comment ][ member ] =
                TmEntry( TokenState.Comment, &comment );

        // ======================================
        // Initialize translation matrix
        // ======================================
        tm[ TokenState.Begin ][ Character.Type.Whitespace ] =
            TmEntry( TokenState.Begin, ( ch ) => consume() );

        // Token is identifier
        tm[ TokenState.Begin ][ Character.Type.Underscore ] =
        tm[ TokenState.Begin ][ Character.Type.Alpha ] =
            TmEntry( TokenState.Identifier, &identifier_start );

        // If you have an identifier, and find a valid character, save it
        tm[ TokenState.Identifier ][ Character.Type.Underscore ] =
        tm[ TokenState.Identifier ][ Character.Type.Alpha ] =
        tm[ TokenState.Identifier ][ Character.Type.Zero ] =
        tm[ TokenState.Identifier ][ Character.Type.OneNine ] =
            TmEntry( TokenState.Identifier, &save );

        // If at the beginning and find a number, start a number
        tm[ TokenState.Begin ][ Character.Type.OneNine ] =
            TmEntry( TokenState.Number, &number_start );

        // If have a number, and find a nother digit, save it
        tm[ TokenState.Number ][ Character.Type.OneNine ] =
        tm[ TokenState.Number ][ Character.Type.Zero ] =
        tm[ TokenState.Number ][ Character.Type.Underscore ] =
            TmEntry( TokenState.Number, &save );

        // If you have a number and find a decimal, convert number to decimal
        tm[ TokenState.Number ][ Character.Type.Dot ] =
            TmEntry( TokenState.Number, &number_decimal );

        // If in number and recieve digit, invalid
        tm[ TokenState.Number ][ Character.Type.Alpha ] =
            TmEntry( TokenState.Number, &invalid );

        // If at beginning and find invalid character, make invalid token
        tm[ TokenState.Begin ][ Character.Type.Zero ] =
        tm[ TokenState.Begin ][ Character.Type.Other ] =
            TmEntry( TokenState.Begin, &invalid );

        // If at beginning, and find an operator, save it
        /*tm[ TokenState.Begin ][ Character.Type.Operator ] =
            TmEntry( TokenState.Operator, &operator_start );

        tm[ TokenState.Operator ][ Character.Type.Operator ] =
            TmEntry( TokenState.Operator, &operator_working );*/

        tm[ TokenState.Begin ][ Character.Type.Semicolon ] =
            TmEntry( TokenState.End, &semicolon );

        // If at beginning and find a ., save it and end
        tm[ TokenState.Begin ][ Character.Type.Dot ] =
            TmEntry( TokenState.End, &operator_start );

        // Done with token
        tm[ TokenState.Number ][ Character.Type.Whitespace ] =
        //tm[ TokenState.Number ][ Character.Type.Operator ] =
        tm[ TokenState.Number ][ Character.Type.Semicolon ] =
        tm[ TokenState.Operator ][ Character.Type.Whitespace ] =
        tm[ TokenState.Operator ][ Character.Type.Dot ] =
        tm[ TokenState.Operator ][ Character.Type.Semicolon ] =
        tm[ TokenState.Identifier ][ Character.Type.Whitespace ] =
        //tm[ TokenState.Identifier ][ Character.Type.Operator ] =
        tm[ TokenState.Identifier ][ Character.Type.Dot ] =
        tm[ TokenState.Identifier ][ Character.Type.Semicolon ] =
            TmEntry( TokenState.End, &ignore );
    }

    /**
     * Get a lazy range for getting all tokens.
     */
    auto getAllTokens()
    {
        struct GetAllTokens
        {
            private Scanner scanner;
            Token front;

            this( Scanner scan )
            {
                scanner = scan;
                front = scanner.getNextToken();
            }

            void popFront()
            {
                front = scanner.getNextToken();
            }

            @property bool empty()
            {
                return scanner.workingString.length == 0;
            }
        }

        return GetAllTokens( this );
    }

    /**
     * Get the next token in the string.
     */
    Token getNextToken()
    {
        if( workingString.length == 0 )
            return null;

        // Reset state
        currentState = TokenState.Begin;
        currentToken = null;

        // The character currently being operated on.
        Character currentChar;

        // Iterate until we hit the end or run out of characters
        while( currentState != TokenState.End && workingString.length )
        {
            // Get the character
            currentChar = workingString[ 0 ];

            // Get next entry
            auto entry = &tm[ currentState ][ currentChar.type ];

            // Set next state
            currentState = entry.next;

            // Perform specified action
            entry.action( currentChar );
        }

        if( currentToken && !currentToken.isValid )
        {
            // Handle error
            import std.stdio;
            writeln( "WARNING: Invalid token ", currentToken.toString(), " of type ", typeid(currentToken).name );
        }

        // Check if token is keyword.
        if( auto ident = cast(IdentifierToken)currentToken )
        {
            currentToken = ident.tryToKeyword();
        }

        return currentToken;
    }

    unittest
    {
        auto scan = new Scanner( q{
            3.1;
        } );

        Token tok;

        tok = scan.getNextToken();
        assert( typeid(tok) == typeid(DecimalToken) );
        assert( (cast(DecimalToken)tok).value == 3.1f );

        tok = scan.getNextToken();
        assert( typeid(tok) == typeid(SemicolonToken) );
    }

private:
    enum TokenState
    {
        Begin,
        Identifier,
        Number,
        Operator,
        Comment,
        End,
    }

    // State of the current token.
    TokenState currentState;
    // The string of characters to lex.
    Character[] workingString;
    // The current working token.
    Token currentToken;

    static struct TmEntry
    {
        TokenState next;
        void delegate( Character ) action;
    }

    TmEntry[ Character.Type ][ TokenState ] tm;

    // Helper functions
    void consume()
    {
        workingString = workingString[ 1..$ ];
    }

    void save( Character ch )
    {
        currentToken.addChar( ch.character );
        consume();
    }
}
