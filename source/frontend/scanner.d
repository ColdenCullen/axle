module frontend.scanner;
import frontend.tokens;

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
		void ignore( ref Token working, TokenState state, char newChar ) { }

		void consume( ref Token working, TokenState state, char newChar )
		{
			workingString = workingString[ 1 .. $ ];
		}

		void save( ref Token working, TokenState state, char newChar )
		{
			working.addChar( newChar );
			consume( working, state, newChar );
		}

		void identifier_start( ref Token working, TokenState state, char newChar )
		{
			working = new IdentifierToken();
			save( working, state, newChar );
		}

		void number_start( ref Token working, TokenState state, char newChar )
		{
			working = new IntegerToken();
			save( working, state, newChar );
		}

		void number_decimal( ref Token working, TokenState state, char newChar )
		{
			if( working.classinfo == IntegerToken.classinfo )
				working = ( cast(IntegerToken)working ).toDecimal;
			else
				working = new InvalidToken();

			consume( working, state, newChar );
		}

		void operator( ref Token working, TokenState state, char newChar )
		{
			working = new OperatorToken( newChar ~ "" );
			consume( working, state, newChar );
		}

		void invalid( ref Token working, TokenState state, char newChar )
		{
			working = new InvalidToken();
			consume( working, state, newChar );
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
		tm[ TokenState.Number ][ InputClass.Decimal ] =
			TmEntry( TokenState.Number, &number_decimal );

		// Done with token
		tm[ TokenState.Number ][ InputClass.WhiteSpace ] =
		tm[ TokenState.Number ][ InputClass.SingleChar ] =
		tm[ TokenState.Invalid ][ InputClass.WhiteSpace ] =
		tm[ TokenState.Invalid ][ InputClass.SingleChar ] =
		tm[ TokenState.Invalid ][ InputClass.Decimal ] =
		tm[ TokenState.Identifier ][ InputClass.WhiteSpace ] =
		tm[ TokenState.Identifier ][ InputClass.SingleChar ] =
		tm[ TokenState.Identifier ][ InputClass.Decimal ] =
			TmEntry( TokenState.End, &ignore );

		// If at beginning and find invalid character, make invalid token
		tm[ TokenState.Begin ][ InputClass.Zero ] =
		tm[ TokenState.Begin ][ InputClass.Other ] =
			TmEntry( TokenState.Invalid, &invalid );

		// If token is invalid, continue collecting data
		tm[ TokenState.Invalid ][ InputClass.Alpha ] =
		tm[ TokenState.Invalid ][ InputClass.UnderScore ] =
		tm[ TokenState.Invalid ][ InputClass.Zero ] =
		tm[ TokenState.Invalid ][ InputClass.OneNine ] =
		tm[ TokenState.Invalid ][ InputClass.Other ] =
			TmEntry( TokenState.Invalid, &save );

		// If at beginning, and find an operator, save it
		tm[ TokenState.Begin ][ InputClass.SingleChar ] =
		tm[ TokenState.Begin ][ InputClass.Decimal ] =
			TmEntry( TokenState.End, &operator );
	}

	Token[] getAllTokens( string toParse )
	{
		// Save string to parse
		workingString = toParse;
		// Number of tokens found
		uint numTokens = 0;
		// Create array of tokens to save to
		Token[] tokensFound = new Token[ 1 ];
		// Token to save into
		Token temp = null;

		do
		{
			// Get next token
			temp = getNextToken();

			// If we hit the size of the array, double space.
			// Only doubling space when capacity is hit (as opposed
			// to incrementing size every time size changes) saves
			// allocation time.
			if( numTokens == tokensFound.length )
				tokensFound.length *= 2;

			// Insert and increment counter
			tokensFound[ numTokens++ ] = temp;
		} while( temp !is null );

		// Resize array to actual size to prevent garbage data being saved.
		tokensFound.length = numTokens;

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
		SingleChar,
		Decimal,
		Other
	};

	enum TokenState {
		Begin,
		Identifier,
		Number,
		Invalid,
		End
	};

	string workingString;

	struct TmEntry
	{
		TokenState next;
		void delegate( ref Token working, TokenState state, char newChar ) action;
	}

	TmEntry[ InputClass ][ TokenState ] tm;

	Token getNextToken()
	{
		if( workingString.length == 0 )
			return null;

		// Current working token
		Token token;
		// Beginning state
		TokenState state = TokenState.Begin;

		// Iterate until we hit the end or run out of characters
		while( state != TokenState.End && workingString.length )
		{
			// Get the character
			char newChar = workingString[ 0 ];
			// Get the class of the character
			auto inputClass = getClass( newChar );

			// Perform specified action
			tm[ state ][ inputClass ].action( token, state, newChar );
			// Set next state
			state = tm[ state ][ inputClass ].next;
		}

		if( token is null || token.classinfo == InvalidToken.classinfo )
		{
			// Handle error
		}

		return token;
	}

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
			case '/':
			case '+':
			case '-':
			case '{':
			case '}':
			case '[':
			case ']':
			case '(':
			case ')':
				return InputClass.SingleChar;
			default:
				return InputClass.Other;
		}
	}
}
}
