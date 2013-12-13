module frontend.scanner;
import frontend.token;

class Scanner
{
static
{
public:
	static this()
	{
		// ======================================
		// Functions for parsing
		// ======================================
		TokenState ignore( Token working, TokenState state, char newChar )
		{
			return state;
		}

		TokenState identifier_save( Token working, TokenState state, char newChar )
		{
			working.token ~= newChar;
			return TokenState.Identifier;
		}

		TokenState identifier_start( Token working, TokenState state, char newChar )
		{
			working.type = TokenType.Identifier;
			return identifier_save( working, state, newChar );
		}

		TokenState number_save( Token working, TokenState state, char newChar )
		{
			working.token ~= newChar;
			return TokenState.Number;
		}

		TokenState number_start( Token working, TokenState state, char newChar )
		{
			working.type = TokenType.Integer;
			return number_save( working, state, newChar );
		}

		TokenState number_decimal( Token working, TokenState state, char newChar )
		{
			if( working.type == TokenType.Integer )
				working.type = TokenType.Decimal;
			else
				working.type = TokenType.Invalid;

			return number_save( working, state, newChar );
		}

		TokenState operator_save( Token working, TokenState state, char newChar )
		{
			working.token ~= newChar;
			working.type = TokenType.Operator;
			return TokenState.Operator;
		}

		TokenState end( Token working, TokenState state, char newChar )
		{
			return TokenState.End;
		}

		TokenState invalid( Token working, TokenState state, char newChar )
		{
			working.type = TokenType.Invalid;
			return state;
		}

		// ======================================
		// Initialize translation matrix
		// ======================================
		tm[ InputClass.WhiteSpace ][ TokenState.Begin ] =
			&ignore;

		// Done with token
		tm[ InputClass.WhiteSpace ][ TokenState.Identifier ] =
		tm[ InputClass.WhiteSpace ][ TokenState.Number ] =
		tm[ InputClass.WhiteSpace ][ TokenState.Operator ] =
			&end;

		// Token is identifier
		tm[ InputClass.UnderScore ][ TokenState.Begin ] =
		tm[ InputClass.Alpha ][ TokenState.Begin ] =
			&identifier_start;

		tm[ InputClass.UnderScore ][ TokenState.Identifier ] =
		tm[ InputClass.Alpha ][ TokenState.Identifier ] =
		tm[ InputClass.Zero ][ TokenState.Identifier ] =
		tm[ InputClass.OneNine ][ TokenState.Identifier ] =
			&identifier_save;

		tm[ InputClass.OneNine ][ TokenState.Begin ] =
			&number_start;

		tm[ InputClass.OneNine ][ TokenState.Number ] =
		tm[ InputClass.Zero ][ TokenState.Number ] =
			&number_save;

		tm[ InputClass.Decimal ][ TokenState.Number ] =
			&number_decimal;

		tm[ InputClass.Slash ][ TokenState.Begin ] =
		tm[ InputClass.Slash ][ TokenState.Operator ] =
		tm[ InputClass.Star ][ TokenState.Begin ] =
		tm[ InputClass.Star ][ TokenState.Operator ] =
		tm[ InputClass.OtherArith ][ TokenState.Begin ] =
		tm[ InputClass.OtherArith ][ TokenState.Operator ] =
			&operator_save;

		tm[ InputClass.WhiteSpace ][ TokenState.Operator ] =
		tm[ InputClass.Alpha ][ TokenState.Operator ] =
		tm[ InputClass.UnderScore ][ TokenState.Operator ] =
		tm[ InputClass.Zero ][ TokenState.Operator ] =
		tm[ InputClass.OneNine ][ TokenState.Operator ] =
		tm[ InputClass.Decimal ][ TokenState.Operator ] =
		tm[ InputClass.Other ][ TokenState.Operator ] =
			&end;

		tm[ InputClass.Zero ][ TokenState.Begin ] =
		tm[ InputClass.Other ][ TokenState.Begin ] =
			&invalid;
	}

	Token[] getAllTokens( string toParse )
	{
		workingString = toParse;
		uint numTokens = 0;
		Token[] tokensFound = new Token[ 1 ];
		Token temp;

		while( ( temp = getNextToken() ) !is null )
		{
			// If we hit the size of the array, double space
			if( numTokens == tokensFound.length )
				tokensFound.length *= 2;

			// Insert and increment counter
			tokensFound[ numTokens++ ] = temp;
		}

		return tokensFound;
	}

private:
	enum InputClass : uint
	{
		WhiteSpace = 0,
		Alpha = 1,
		UnderScore = 2,
		Zero = 3,
		OneNine = 4,
		Slash = 5,
		Star = 6,
		Decimal = 7,
		OtherArith = 8,
		Other
	};

	enum TokenState : uint {
		Begin = 0,
		Identifier = 1,
		Number = 2,
		Operator = 3,
		End = 99
	};

	string workingString;
	TokenState delegate( Token working, TokenState state, char newChar )[ TokenState ][ InputClass ] tm;

	InputClass getClass( char character )
	{
		// If letter
		if( ( character >= 'a' && character <= 'z' ) ||
			( character >= 'A' && character <= 'Z' ) )
			return InputClass.Alpha;

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
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			return InputClass.OneNine;
		case '.':
			return InputClass.Decimal;
		case '*':
			return InputClass.Star;
		case '/':
			return InputClass.Slash;
		case '+':
		case '-':
			return InputClass.OtherArith;
		default:
			return InputClass.Other;
		}
	}

	Token getNextToken()
	{
		if( workingString.length == 0 )
			return null;

		auto newTok = new Token();
		TokenState state = TokenState.Begin;

		while( state != TokenState.End && workingString.length )
		{
			// TODO: Get actual state
			char newChar = workingString[ 0 ];
			InputClass inputClass = getClass( newChar );
			
			state = tm[ inputClass ][ state ]( newTok, state, newChar );

			if( state != TokenState.End )
				workingString = workingString[ 1 .. $ ];
		}

		if( newTok.type == TokenType.Invalid )
		{
			// Handle error
		}

		newTok.postProcess();

		return newTok;
	}
}
}
