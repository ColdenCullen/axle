#ifndef __AXLE_MEMBER
#define __AXLE_MEMBER

NAMESPACE_AXLE

class Scope;

class Member
{
public:
	Member( Scope* parentScope ) : parentScope( parentScope ) { }

	Scope*				GetParentScope( void )	{ return parentScope; }

protected:
	Scope*				parentScope;
};

END_NAMESPACE

#endif//__AXLE_MEMBER
