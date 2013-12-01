#ifndef __AXLE_SCOPE
#define __AXLE_SCOPE

#include <unordered_map>
#include <type_traits>

#include "Member.h"

USING_NAMESPACE( Axle, Backend )

class Scope : public Member
{
public:
	static Scope		Global;
	typedef std::unordered_map<aString, Member*> MemberMap;

						Scope( Type type = Type::Scope ) : Member( Type::Scope ) { }

	Member*				CreateMember( Type type, aString name );
	template<typename T>
	T*					CreateMember( aString name );
	template<typename T = Member>
	T*					GetMember( aString name );

protected:
	MemberMap			members;
};

END_USING_NAMESPACE

#endif//__AXLE_SCOPE
