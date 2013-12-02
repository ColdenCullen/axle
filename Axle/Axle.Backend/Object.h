#ifndef __AXLE_OBJECT
#define __AXLE_OBJECT

#include "Member.h"
#include "Scope.h"
#include "Class.h"

NAMESPACE_AXLE

class Object : public Scope, public Member
{
public:
	Object( Scope* parentScope ) : Scope( parentScope ), Member( parentScope ) { }

private:
	Class*				parentClass;
};

END_NAMESPACE

#endif//__AXLE_OBJECT
