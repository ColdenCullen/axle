#ifndef __AXLE_VARIABLE
#define __AXLE_VARIABLE

#include "Member.h"

USING_NAMESPACE( Axle, Backend )

class Variable : public Member
{
public:
	static bool			IsVariableType( Type type );

						Variable( Type type = Type::Integer ) : Member( type ) { }

	void				Cast( Type type );

	union
	{
		aFloat			floatingPoint;
		aInt			integer;
	};
};

END_USING_NAMESPACE

#endif//__AXLE_VARIABLE
