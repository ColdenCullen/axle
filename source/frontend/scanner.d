module frontend.scanner;
import frontend.tokens;

import std.traits, std.range, std.conv, std.array, std.string, std.typecons;

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
        Assignment,
        Semicolon,
        SingleQuote,
        DoubleQuote,
        Asterisk,
        Slash,
        Other,
    }

    this( char newChar )
    {
        // Generate the case for a letter or group of letters.
        string letter( Letters... )( Type type, Letters chars )
        {
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
                static if( __traits( compiles, ch.length ) && ch.length == 2 )
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
        void ignore( ref Token working, char newChar ) { }

        void consume( ref Token working, char newChar )
        {
            workingString = workingString[ 1 .. $ ];
        }

        void addToToken( ref Token working, char newChar )
        {
            working.token ~= newChar;
            consume( working, newChar );
        }

        void save( ref Token working, char newChar )
        {
            working.addChar( newChar );
            consume( working, newChar );
        }

        void identifier_start( ref Token working, char newChar )
        {
            working = new IdentifierToken();
            save( working, newChar );
        }

        void number_start( ref Token working, char newChar )
        {
            working = new IntegerToken();
            save( working, newChar );
        }

        void number_decimal( ref Token working, char newChar )
        {
            if( typeid(working) == typeid(IntegerToken) )
                working = ( cast(IntegerToken)working ).toDecimal;
            else
                working.isValid = false;

            working.token ~= newChar;
            consume( working, newChar );
        }

        void operator_start( ref Token working, char newChar )
        {
            working = new OperatorToken( newChar ~ "" );
            consume( working, newChar );
        }

        void operator_working( ref Token working, char newChar )
        {
            save( working, newChar );

            if( (cast(OperatorToken)working).type == OperatorToken.OperatorType.DoubleSlash )
            {
                working = new CommentToken( CommentToken.CommentType.SingleLine );
                working.token = "//";
                currentState = TokenState.Comment;
            }
        }

        void semicolon( ref Token working, char newChar )
        {
            working = new SemicolonToken;
            consume( working, newChar );
        }

        void comment( ref Token working, char newChar )
            {
                auto com = cast(CommentToken)working;

                switch( com.type )
                {
                    case CommentToken.CommentType.SingleLine:
                        if( newChar == '\n' )
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

        void invalid( ref Token working, char newChar )
        {
            working.isValid = false;
            consume( working, newChar );
        }

        // ======================================
        // Initialize translation matrix
        // ======================================
        tm[ TokenState.Begin ][ InputClass.WhiteSpace ] =
            TmEntry( TokenState.Begin, &consume );

        // Token is identifier
        tm[ TokenState.Begin ][ InputClass.UnderScore ] =
        tm[ TokenState.Begin ][ InputClass.Alpha ] =
            TmEntry( TokenState.Identifier, &identifier_start );

        // If you have an identifier, and find a valid character, save it
        tm[ TokenState.Identifier ][ InputClass.UnderScore ] =
        tm[ TokenState.Identifier ][ InputClass.Alpha ] =
        tm[ TokenState.Identifier ][ InputClass.Zero ] =
        tm[ TokenState.Identifier ][ InputClass.OneNine ] =
            TmEntry( TokenState.Identifier, &save );

        // If at the beginning and find a number, start a number
        tm[ TokenState.Begin ][ InputClass.OneNine ] =
            TmEntry( TokenState.Number, &number_start );

        // If have a number, and find a nother digit, save it
        tm[ TokenState.Number ][ InputClass.OneNine ] =
        tm[ TokenState.Number ][ InputClass.Zero ] =
            TmEntry( TokenState.Number, &save );

        // If you have a number and find a decimal, convert number to decimal
        tm[ TokenState.Number ][ InputClass.Dot ] =
            TmEntry( TokenState.Number, &number_decimal );

        // If in number and recieve digit, invalid
        tm[ TokenState.Number ][ InputClass.Alpha ] =
            TmEntry( TokenState.Number, &invalid );

        tm[ TokenState.Number ][ InputClass.UnderScore ] =
            TmEntry( TokenState.Number, &addToToken );

        // If at beginning and find invalid character, make invalid token
        tm[ TokenState.Begin ][ InputClass.Zero ] =
        tm[ TokenState.Begin ][ InputClass.Other ] =
            TmEntry( TokenState.Begin, &invalid );

        // If at beginning, and find an operator, save it
        tm[ TokenState.Begin ][ InputClass.Operator ] =
            TmEntry( TokenState.Operator, &operator_start );

        tm[ TokenState.Operator ][ InputClass.Operator ] =
            TmEntry( TokenState.Operator, &operator_working );

        tm[ TokenState.Begin ][ InputClass.Semicolon ] =
                TmEntry( TokenState.End, &semicolon );

        // If at beginning and find a ., save it and end
        tm[ TokenState.Begin ][ InputClass.Dot ] =
            TmEntry( TokenState.End, &operator_start );

        foreach( member; EnumMembers!InputClass )
            tm[ TokenState.Comment ][ member ] =
                TmEntry( TokenState.Comment, &comment );

        // Done with token
        tm[ TokenState.Number ][ InputClass.WhiteSpace ] =
        tm[ TokenState.Number ][ InputClass.Operator ] =
        tm[ TokenState.Number ][ InputClass.Semicolon ] =
        tm[ TokenState.Operator ][ InputClass.WhiteSpace ] =
        tm[ TokenState.Operator ][ InputClass.Dot ] =
        tm[ TokenState.Operator ][ InputClass.Semicolon ] =
        tm[ TokenState.Identifier ][ InputClass.WhiteSpace ] =
        tm[ TokenState.Identifier ][ InputClass.Operator ] =
        tm[ TokenState.Identifier ][ InputClass.Dot ] =
        tm[ TokenState.Identifier ][ InputClass.Semicolon ] =
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
    enum InputClass : uint
    {
        WhiteSpace,
        Alpha,
        UnderScore,
        Zero,
        OneNine,
        Operator,
        Dot,
        Assignment,
        Semicolon,
        Other,
    };

    enum TokenState {
        Begin,
        Identifier,
        Number,
        Operator,
        Comment,
        End,
    };


    // Beginning state
    TokenState currentState;
    string workingString;

    static struct TmEntry
    {
        TokenState next;
        void delegate( ref Token working, char newChar ) action;
    }

    TmEntry[ InputClass ][ TokenState ] tm;

    Token getNextToken()
    {
        if( workingString.length == 0 )
            return null;

        // Reset state
        currentState = TokenState.Begin;

        // Current working token
        Token token;

        // Iterate until we hit the end or run out of characters
        while( currentState != TokenState.End && workingString.length )
        {
            // Get the character
            char newChar = workingString[ 0 ];
            // Get the class of the character
            auto inputClass = getClass( newChar );

            // Get next entry
            auto entry = &tm[ currentState ][ inputClass ];

            // Set next state
            currentState = entry.next;

            // Perform specified action
            entry.action( token, newChar );
        }

        if( token is null || !token.isValid )
        {
            // Handle error
        }

        return token;
    }

    static InputClass getClass( char character )
    {
        switch( character )
        {
            case '\n':
            case '\t':
            case ' ':
                return InputClass.WhiteSpace;
            case '_':
                return InputClass.UnderScore;
            case '0':
                return InputClass.Zero;
            case '1': .. case '9':
                return InputClass.OneNine;
            case '.':
                return InputClass.Dot;
            case '*':
            case '/':
            case '+':
            case '-':
            case '{':
            case '}':
            case '[':
            case ']':
            case '(':
            case ')':
            case '=':
                return InputClass.Operator;
            case ';':
                return InputClass.Semicolon;
            case 'a': .. case 'z':
            case 'A': .. case 'Z':
                return InputClass.Alpha;
            default:
                return InputClass.Other;
        }
    }
}
