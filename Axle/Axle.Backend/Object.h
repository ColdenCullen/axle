#ifndef __AXLE_OBJECT
#define __AXLE_OBJECT

#include "Member.h"
#include "Scope.h"
#include "Class.h"

USING_NAMESPACE( Axle, Backend )

class Object : public Scope
{
public:
						Object( void ) : Scope( Type::Object ) { }

private:
	Class*				parentClass;
};

END_USING_NAMESPACE

#endif//__AXLE_OBJECT