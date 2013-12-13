module frontend.tokens;
import std.conv, std.math;
import std.stdio;

abstract class Token
{
public:
	abstract void addChar( char toAdd );
	abstract override @property string toString();
}

class IdentifierToken : Token
{
public:
	string name;

	this( string name = "" )
	{
		this.name = name;
	}

	override void addChar( char toAdd ) { name ~= toAdd; }
	override @property string toString() { return name; }
}

class DecimalToken : Token
{
public:
	float value;

	this( float val = 0.0f )
	{
		value = val;
		digitCount = 0;
	}

	override void addChar( char toAdd )
	{
		value += cast(float)( toAdd - 48 ) / pow( 10, ++digitCount );
	}
	override @property string toString() { return to!string( value ); }

private:
	uint digitCount;
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
		value *= 10;
		value += toAdd - 48;
	}
	override @property string toString() { return to!string( value ); }
}

class OperatorToken : Token
{
public:
	enum OperatorType
	{
		Decimal,
		Star,
		Slash,
		Plus,
		Minus,
		OpenBrace,
		CloseBrace,
		OpenBracket,
		CloseBracket,
		OpenParenthesis,
		CloseParenthesis
	}

	OperatorType type;

	this( string op = "" )
	{
		if( op != "" )
			addChar( op[ 0 ] );
	}

	override void addChar( char toAdd )
	{
		switch( toAdd )
		{
		case '*':
			type = OperatorType.Star;
			break;
		case '/':
			type = OperatorType.Slash;
			break;
		case '+':
			type = OperatorType.Plus;
			break;
		case '-':
			type = OperatorType.Minus;
			break;
		case '{':
			type = OperatorType.OpenBrace;
			break;
		case '}':
			type = OperatorType.CloseBrace;
			break;
		case '[':
			type = OperatorType.OpenBracket;
			break;
		case ']':
			type = OperatorType.CloseBracket;
			break;
		case '(':
			type = OperatorType.OpenParenthesis;
			break;
		case ')':
			type = OperatorType.CloseParenthesis;
			break;
		default:
			break;
		}
	}
	override @property string toString() { return to!string( type ); }
}

class InvalidToken : IdentifierToken
{
	override @property string toString() { return "Invalid"; }
}
