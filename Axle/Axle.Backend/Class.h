#ifndef __AXLE_CLASS
#define __AXLE_CLASS

#include "Member.h"
#include "Scope.h"

NAMESPACE_AXLE

class Object;

class Class : public Scope, public Member
{
public:
	Class( Scope* parentScope ) : Scope( parentScope ), Member( parentScope ), StaticScope( parentScope ) { }

	Scope				StaticScope;

	Object*				CreateInstance( aString name, Scope* parentScope );
};

END_NAMESPACE

#endif//__AXLE_CLASS
