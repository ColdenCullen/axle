#ifndef __AXLE_MEMBER
#define __AXLE_MEMBER

USING_NAMESPACE( Axle, Backend )

class Scope;

class Member
{
public:
	Scope*				GetParentScope( void ) { return parentScope; }

protected:
	Scope*				parentScope;
};

END_USING_NAMESPACE

#endif//__AXLE_MEMBER
