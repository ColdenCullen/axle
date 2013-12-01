#ifndef __AXLE_SCOPE
#define __AXLE_SCOPE

#include <unordered_map>
#include <type_traits>

#include "Member.h"

USING_NAMESPACE( Axle, Backend )

class Scope
{
public:
	static Scope		Global;
	typedef std::unordered_map<aString, Member*> MemberMap;

	template<typename T>
	T*					CreateMember( aString name )
	{
		static_assert( std::is_base_of<Member, T>::value, "Invalid type parameter for CreateMember." );

		T* newMember = new T;
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

END_USING_NAMESPACE

#endif//__AXLE_SCOPE
