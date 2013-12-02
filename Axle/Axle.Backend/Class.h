#ifndef __AXLE_CLASS
#define __AXLE_CLASS

#include "Member.h"
#include "Scope.h"

USING_NAMESPACE( Axle, Backend )

class Object;

class Class : public Scope
{
public:
	Class( Scope* parentScope ) : Scope( parentScope ), StaticScope( parentScope ) { }

	Scope				StaticScope;

	Object*				CreateInstance( aString name, Scope* parentScope );
};

END_USING_NAMESPACE

#endif//__AXLE_CLASS
