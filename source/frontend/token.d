module frontend.token;

enum TokenType
{
	Identifier,
	Decimal,
	Integer,
	Operator,
	Invalid
};

class Token
{
	TokenType type;
	string token;

	// Handles changes that can only be completed after 
	void postProcess()
	{
		switch( type )
		{
		default:
			return;
		}
	}
}
