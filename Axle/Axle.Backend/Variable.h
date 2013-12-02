#ifndef __AXLE_VARIABLE
#define __AXLE_VARIABLE

#include "Member.h"

NAMESPACE_AXLE

class Variable : public Member
{
public:
						Variable( Scope* parentScope ) : Member( parentScope ) { }

	union
	{
		aFloat			floatingPoint;
		aInt			integer;
	};
};

END_NAMESPACE

#endif//__AXLE_VARIABLE
