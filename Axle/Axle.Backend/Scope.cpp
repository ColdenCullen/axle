#include "Scope.h"
#include "Variable.h"
#include "Object.h"
#include "Class.h"

USING_NAMESPACE( Axle, Backend )

Scope Scope::Global;

#pragma region CreateMember
Member* Scope::CreateMember( Type type, aString name )
{
	Member* newMember = nullptr;

	switch( type )
	{
	case Type::Scope:
		newMember = new Scope;
		break;
	case Type::Class:
		newMember = new Class;
		break;
	case Type::Float:
	case Type::Integer:
		newMember = new Variable( type );
		break;
	case Type::Object:
		newMember = new Object;
		break;
	default:
		newMember = new Member;
		break;
	}

	members[ name ] = newMember;
	return newMember;
}

#define CREATE_MEMBER( TYPE )				\
template<>									\
TYPE* Scope::CreateMember( aString name )	\
{											\
	return static_cast<TYPE*>( CreateMember( Type::TYPE, name ) ); \
}
CREATE_MEMBER( Member )
CREATE_MEMBER( Scope )
CREATE_MEMBER( Class )
#undef CREATE_MEMBER
template<>
Variable* Scope::CreateMember( aString name )
{
	return static_cast<Variable*>( CreateMember( Type::Integer, name ) );
}
#pragma endregion

#pragma region GetMember
template<>
Member* Scope::GetMember( aString name )
{
	auto itr = members.find( name );

	if( itr != end( members ) )
		return itr->second;
	else
		return nullptr;
}

#define GET_MEMBER( TYPE ) \
template<> TYPE* Scope::GetMember( aString name ) { \
	return static_cast<TYPE*>( GetMember<Member>( name ) ); \
}
GET_MEMBER( Scope )
GET_MEMBER( Class )
GET_MEMBER( Variable )
#undef GET_MEMBER
#pragma endregion

END_USING_NAMESPACE
