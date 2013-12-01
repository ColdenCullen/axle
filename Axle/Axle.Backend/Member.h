#ifndef __AXLE_MEMBER
#define __AXLE_MEMBER

USING_NAMESPACE( Axle, Backend )

enum class Type
{
	Member,
	Scope,
	Class,
	Float,
	Integer,
	Object
};

class Scope;

class Member
{
public:
						Member( Type type = Type::Member ) : type( type ) { }

	Scope*				GetParentScope( void )	{ return parentScope; }
	const Type			GetType( void )			{ return type; }

protected:
	Scope*				parentScope;

	Type				type;
};

END_USING_NAMESPACE

#endif//__AXLE_MEMBER
