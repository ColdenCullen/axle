#include "Variable.h"

USING_NAMESPACE( Axle, Backend )

bool Variable::IsVariableType( Type type )
{
	return
		type == Type::Float ||
		type == Type::Integer;
}

void Variable::Cast( Type type )
{
	if( type == this->type )
		return;

	if( type == Type::Integer )
	{
		integer = static_cast<aInt>( floatingPoint );
	}
	else if( type == Type::Float )
	{
		floatingPoint = static_cast<aFloat>( integer );
	}
}

END_USING_NAMESPACE
