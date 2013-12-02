#include "Class.h"
#include "Object.h"
#include "Variable.h"

USING_NAMESPACE( Axle, Backend )

Object* Class::CreateInstance( aString name, Scope* parentScope )
{
	auto inst = parentScope->CreateMember<Object>( name );

	for( auto member : members )
	{
		//auto var = inst->CreateMember<member.second>( member.first );
		//static_cast<Variable*>( var )->integer = static_cast<Variable*>( member.second )->integer;
	}

	return inst;
}

END_USING_NAMESPACE
