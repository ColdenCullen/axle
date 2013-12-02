#include "Class.h"
#include "Object.h"
#include "Variable.h"

USING_NAMESPACE( Axle, Backend )

Object* Class::CreateInstance( aString name, Scope* parentScope )
{
	auto inst = parentScope->CreateMember<Object>( name );

	for( auto member : members )
	{
		if( SAME_TYPE( *member.second, Variable ) )
		{
			auto var = inst->CreateMember<Variable>( member.first );
			var->integer = static_cast<Variable*>( member.second )->integer;
		}
		else if( SAME_TYPE( *member.second, Object ) )
		{
			auto var = inst->CreateMember<Object>( member.first );
			
		}
	}

	return inst;
}

END_USING_NAMESPACE
