#ifndef __AXLE_SCOPE
#define __AXLE_SCOPE

#include <unordered_map>
#include <type_traits>

#include "Member.h"

NAMESPACE_AXLE

class Scope : public Member
{
public:
	static Scope		Global;
	typedef std::unordered_map<aString, Member*> MemberMap;

	Scope( Scope* parentScope ) : Member( parentScope ) { }

	template<typename T>
	T*					CreateMember( aString name )
	{
		auto newMember = new T( this );
		members[ name ] = newMember;
		return newMember;
	}

	template<typename T = Member>
	T*					GetMember( aString name )
	{
		auto itr = members.find( name );

		if( itr != end( members ) )
			return static_cast<T*>( itr->second );
		else
			return nullptr;
	}

protected:
	MemberMap			members;
};

END_NAMESPACE

#endif//__AXLE_SCOPE
