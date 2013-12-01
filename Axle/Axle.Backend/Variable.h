#ifndef __AXLE_VARIABLE
#define __AXLE_VARIABLE

#include "Member.h"

USING_NAMESPACE( Axle, Backend )

template<typename T>
class Variable : public Member
{
public:
	T					value;
};

END_USING_NAMESPACE

#endif//__AXLE_VARIABLE
