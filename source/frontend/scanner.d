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
        workingString = stringToParse;

        // ======================================
        // Functions for parsing
        // ======================================
        void ignore( ref Token working, Character newChar ) { }

        void identifier_start( ref Token working, Character newChar )
        {
            working = new IdentifierToken();
            save( working, newChar );
        }

        void number_start( ref Token working, Character newChar )
        {
            working = new IntegerToken();
            save( working, newChar );
        }

        void number_decimal( ref Token working, Character newChar )
        {
            if( typeid(working) == typeid(IntegerToken) )
                working = ( cast(IntegerToken)working ).toDecimal;
            else
                working.isValid = false;

            working.addChar( newChar.character );
            consume();
        }

        void operator_start( ref Token working, Character newChar )
        {
            working = new OperatorToken( newChar.character ~ "" );
            consume();
        }

        void operator_working( ref Token working, Character newChar )
        {
            save( working, newChar );

            if( (cast(OperatorToken)working).type == OperatorToken.OperatorType.DoubleSlash )
            {
                working = new CommentToken( CommentToken.CommentType.SingleLine );
                working.token = "//";
                currentState = TokenState.Comment;
            }
        }

        void semicolon( ref Token working, Character newChar )
        {
            working = new SemicolonToken;
            consume();
        }

        void comment( ref Token working, Character newChar )
        {
            auto com = cast(CommentToken)working;

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

            save( working, newChar );
        }

        void invalid( ref Token working, Character newChar )
        {
            working.isValid = false;
            consume();
        }

        // ======================================
        // Initialize translation matrix
        // ======================================
        tm[ TokenState.Begin ][ Character.Type.Whitespace ] =
            TmEntry( TokenState.Begin, ( ref tok, ch ) => consume() );

        // Token is identifier
        tm[ TokenState.Begin ][ Character.Type.Underscore ] =
        tm[ TokenState.Begin ][ Character.Type.Alpha ] =
            TmEntry( TokenState.Identifier, &identifier_start );

        // If you have an identifier, and find a valid character, save it
        tm[ TokenState.Identifier ][ Character.Type.Underscore ] =
        tm[ TokenState.Identifier ][ Character.Type.Alpha ] =
        tm[ TokenState.Identifier ][ Character.Type.Zero ] =
        tm[ TokenState.Identifier ][ Character.Type.OneNine ] =
            TmEntry( TokenState.Identifier, ( ref tok, ch ) => save( tok, ch ) );

        // If at the beginning and find a number, start a number
        tm[ TokenState.Begin ][ Character.Type.OneNine ] =
            TmEntry( TokenState.Number, &number_start );

        // If have a number, and find a nother digit, save it
        tm[ TokenState.Number ][ Character.Type.OneNine ] =
        tm[ TokenState.Number ][ Character.Type.Zero ] =
        tm[ TokenState.Number ][ Character.Type.Underscore ] =
            TmEntry( TokenState.Number, ( ref tok, ch ) => save( tok, ch ) );

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

        import std.traits;
        foreach( member; EnumMembers!( Character.Type ) )
            tm[ TokenState.Comment ][ member ] =
                TmEntry( TokenState.Comment, &comment );

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

    Token[] getAllTokens()
    {
        // Create array of tokens to save to
        Token[] tokensFound;
        // Token to save into
        Token temp = null;

        // Get next token
        while( ( temp = getNextToken() ) !is null )
        {
            // Insert and increment counter
            tokensFound ~= temp;
        }

        return tokensFound;
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

    // Beginning state
    TokenState currentState;
    string workingString;

    static struct TmEntry
    {
        TokenState next;
        void delegate( ref Token, Character ) action;
    }

    TmEntry[ Character.Type ][ TokenState ] tm;

    Token getNextToken()
    {
        if( workingString.length == 0 )
            return null;

        // Reset state
        currentState = TokenState.Begin;

        // Current working token
        Token token;

        Character currentChar = Character( workingString[ 0 ] );

        // Iterate until we hit the end or run out of characters
        while( currentState != TokenState.End && workingString.length )
        {
            // Get the character
            currentChar = Character( workingString[ 0 ] );

            // Get next entry
            auto entry = &tm[ currentState ][ currentChar.type ];

            // Set next state
            currentState = entry.next;

            // Perform specified action
            entry.action( token, currentChar );
        }

        if( token is null || !token.isValid )
        {
            // Handle error
        }

        return token;
    }

    // Helper functions
    void consume()
    {
        workingString = workingString[ 1..$ ];
    }

    void save( Token tok, Character ch )
    {
        tok.addChar( ch.character );
        consume();
    }
}
