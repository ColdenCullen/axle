module frontend.tokens;
import std.conv, std.math, std.stdio, std.array;

abstract class Token
{
public:
    abstract void addChar( char toAdd );
    override string toString()
    {
        return token;
    }
    bool isValid = true;
    string token;
}

class IdentifierToken : Token
{
public:
    this( string name = "" )
    {
        this.token = name;
    }

    override void addChar( char toAdd ) { token ~= toAdd; }
}

class KeywordToken : IdentifierToken
{
public:
    enum Keyword
    {
        Auto = "auto",
        Return = "return",
        Class = "class",
        Struct = "struct",
    }

    this( string name )
    {
        super( name );
    }

    Keyword word;
}

IdentifierToken tryToKeyword( IdentifierToken tok )
{
    import std.traits;
    foreach( keyword; EnumMembers!( KeywordToken.Keyword ) )
    {
        if( cast(string)keyword == tok.token )
        {
            KeywordToken keyTok = new KeywordToken( tok.token );
            keyTok.word = keyword;
            return keyTok;
        }
    }

    // If not keyword, return original.
    return tok;
}

class DecimalToken : Token
{
public:
    float value;

    this( float val = 0.0f )
    {
        value = val;

        auto chars = value.to!string.split( '.' );
        if( chars.length < 2 )
        {
            decimalCount = 0;
        }
        else
        {
            decimalCount = cast(uint)chars[ 1 ].length;
        }
    }

    override void addChar( char toAdd )
    {
        token ~= toAdd;

        // Ignore underscores.
        if( toAdd == '_' || toAdd == '.' )
            return;

        value += cast(float)( toAdd - 48 ) / cast(float)pow( 10, ++decimalCount );
    }
    override @property string toString() { return to!string( value ); }

private:
    uint decimalCount;
}

class IntegerToken : Token
{
public:
    int value;

    this( int val = 0 )
    {
        value = val;
    }

    DecimalToken toDecimal()
    {
        return new DecimalToken( value );
    }

    override void addChar( char toAdd )
    {
        token ~= toAdd;

        // Ignore underscores.
        if( toAdd == '_' )
            return;

        value *= 10;
        value += toAdd - 48;
    }
    override @property string toString() { return to!string( value ); }
}

class SemicolonToken : Token
{
public:
    this()
    {
        token = ";";
    }

    override void addChar( char newChar ) { }
}

class CommentToken : Token
{
public:
    enum CommentType
    {
        SingleLine,
        MultiLine,
        Documentation,
    }

    CommentType type;

    this( CommentType type )
    {
        this.type = type;
    }

    override void addChar( char toAdd )
    {
        token ~= toAdd;
    }
}

class OperatorToken : Token
{
public:
    enum OperatorType
    {
        Assignment,
        Dot,
        Star,
        DoubleSlash,
        Slash,
        Plus,
        Minus,
        OpenBrace,
        CloseBrace,
        OpenBracket,
        CloseBracket,
        OpenParenthesis,
        CloseParenthesis,
        Invalid,
    }

    OperatorType type;

    override void addChar( char toAdd )
    {
        token ~= toAdd;

        switch( token )
        {
        case "=":
            type = OperatorType.Assignment;
            break;
        case ".":
            type = OperatorType.Dot;
            break;
        case "*":
            type = OperatorType.Star;
            break;
        case "//":
            type = OperatorType.DoubleSlash;
            break;
        case "/":
            type = OperatorType.Slash;
            break;
        case "+":
            type = OperatorType.Plus;
            break;
        case "-":
            type = OperatorType.Minus;
            break;
        case "{":
            type = OperatorType.OpenBrace;
            break;
        case "}":
            type = OperatorType.CloseBrace;
            break;
        case "[":
            type = OperatorType.OpenBracket;
            break;
        case "]":
            type = OperatorType.CloseBracket;
            break;
        case "(":
            type = OperatorType.OpenParenthesis;
            break;
        case ")":
            type = OperatorType.CloseParenthesis;
            break;
        default:
            type = OperatorType.Invalid;
            isValid = false;
            break;
        }
    }
    override @property string toString() { return to!string( type ); }
}
